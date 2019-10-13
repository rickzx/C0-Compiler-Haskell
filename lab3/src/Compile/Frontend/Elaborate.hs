module Compile.Frontend.Elaborate where

import Compile.Types
import Control.Monad.State
import Control.Monad.Trans.Except

import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set

import Debug.Trace

--map each function to (Arg type, return type).
type Fnmap = Map.Map Ident Type

data GlobState =
    GlobState
        { funDeclared :: Map.Map Ident Type
        , funDefined :: Map.Map Ident Type
        , typeDefined :: Map.Map Ident Type
        }

eGenHeader :: AST -> Header
eGenHeader (Program l) =
    let initialState = GlobState {funDeclared = Map.empty, funDefined = Map.empty, typeDefined = Map.empty}
        elaborate = do
            elabHeader l
            s0 <- get
            return $ Header (funDeclared s0) (typeDefined s0)
        h = evalState (runExceptT elaborate) initialState
     in case h of
            Left err -> error err
            Right header -> header

eGen :: AST -> Header -> EAST
eGen (Program l) header =
    let initialState = GlobState {funDeclared = Map.singleton "main" (ARROW [] INTEGER), funDefined = Map.empty, typeDefined = Map.empty}
        allDef = findDefFunc l
        elaborate = elabGdecls l header allDef
        e = evalState (runExceptT elaborate) initialState
     in case e of
            Left err -> error err
            Right east -> east

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

arrowEq :: (Type, Type) -> Bool
arrowEq (ARROW args1 ret1, ARROW args2 ret2) =
    (length args1 == length args2) && (all (\(a1, a2) -> snd a1 == snd a2) $ zip args1 args2) && ret1 == ret2
arrowEq (_, _) = error "Expect arrow types for comparison"

findDefFunc :: [Gdecl] -> Set.Set Ident
findDefFunc =
    foldr
        (\x s ->
             case x of
                 Fdefn _ nme _ _ -> Set.insert nme s
                 _ -> s)
        Set.empty

elabHeader :: [Gdecl] -> ExceptT String (State GlobState) ()
elabHeader [] = return ()
elabHeader (x:xs) =
    case x of
        Fdecl rtp nme param -> do
            declared <- gets funDeclared
            typDefed <- gets typeDefined
            let typ = ARROW (extractParam' param typDefed) (findType' rtp typDefed)
            case Map.lookup nme declared of
                Just typ1 -> do
                    assertMsg
                        ("Type of function " ++ nme ++ "does not match with previous declaration")
                        (arrowEq (typ, typ1))
                    elabHeader xs
                Nothing -> do
                    modify' $ \(GlobState fdec fdef tdef) -> GlobState (Map.insert nme typ fdec) fdef tdef
                    elabHeader xs
        Typedef typ nme -> do
            typDefed <- gets typeDefined
            case Map.lookup nme typDefed of
                Just _ -> throwE $ "Type defined more than once: " ++ nme
                Nothing ->
                    case typ of
                        DEF ident ->
                            case Map.lookup ident typDefed of
                                Just primTyp -> do
                                    modify' $ \(GlobState fdec fdef tdef) ->
                                        GlobState fdec fdef (Map.insert nme primTyp tdef)
                                    elabHeader xs
                                Nothing -> throwE $ "Undefined type: " ++ nme
                        _ -> do
                            modify' $ \(GlobState fdec fdef tdef) -> GlobState fdec fdef (Map.insert nme typ tdef)
                            elabHeader xs
        _ -> throwE "Header only supports function declaration and typedef!"

elabGdecls :: [Gdecl] -> Header -> Set.Set Ident -> ExceptT String (State GlobState) EAST
elabGdecls [] header allDef = return ENop
elabGdecls (x:xs) header allDef =
    case x of
        Fdecl rtp nme param -> do
            declared <- gets funDeclared
            typDefed <- gets typeDefined
            if Map.member nme typDefed || Map.member nme (typDef header) then throwE $ "Function uses a typedef name " ++ nme else do
                let typ = ARROW (extractParam param (typDefed, typDef header)) (findType rtp (typDefed, typDef header))
                case Map.lookup nme declared of
                    Just typ1 -> do
                        assertMsg
                            ("Type of function " ++ nme ++ " does not match with previous declaration")
                            (arrowEq (typ, typ1))
                        elab' <- elabGdecls xs header allDef
                        return $ EDecl nme typ elab'
                    Nothing ->
                        case Map.lookup nme (fnDecl header) of
                            Just typ1 -> do
                                assertMsg
                                    ("Type of function " ++ nme ++ " does not match with previous declaration in header")
                                    (arrowEq (typ, typ1))
                                elab' <- elabGdecls xs header allDef
                                return $ EDecl nme typ elab'
                            Nothing -> do
                                modify' $ \(GlobState fdec fdef tdef) -> GlobState (Map.insert nme typ fdec) fdef tdef
                                elab' <- elabGdecls xs header allDef
                                return $ EDecl nme typ elab'
        Fdefn rtp nme param blk -> do
            declared <- gets funDeclared
            defined <- gets funDefined
            typDefed <- gets typeDefined
            if Map.member nme typDefed || Map.member nme (typDef header) then throwE $ "Function uses a typedef name " ++ nme else 
                if nme == "main" && (findType rtp (typDefed, typDef header) /= INTEGER || length param > 0) then throwE "Bad declaration for main" else do 
                    let typ = ARROW (extractParam param (typDefed, typDef header)) (findType rtp (typDefed, typDef header))
                    _ <- elabGdecls [Fdecl rtp nme param] header allDef
                    case Map.lookup nme defined of
                        Just _ -> throwE $ "Function defined more than once: " ++ nme
                        Nothing ->
                            case Map.lookup nme (fnDecl header) of
                                Just _ -> throwE $ "External functions must not be defined " ++ nme
                                Nothing -> do
                                    modify' $ \(GlobState fdec fdef tdef) -> GlobState (Map.insert nme typ fdec) (Map.insert nme typ fdef) tdef
                                    gState <- get
                                    let blk' = eBlock blk (gState, header) allDef
                                    elab' <- elabGdecls xs header allDef
                                    return $ EDecl nme typ (ESeq (EDef nme typ blk') elab')
        Typedef typ nme -> do
            typDefed <- gets typeDefined
            fnDeclared <- gets funDeclared
            if Map.member nme fnDeclared || Map.member nme (fnDecl header) then throwE $ "Typedef uses a function name " ++ nme else
                case Map.lookup nme typDefed of
                    Just _ -> throwE $ "Type defined more than once: " ++ nme
                    Nothing ->
                        case Map.lookup nme (typDef header) of
                            Just _ -> throwE $ "Type defined more than once: " ++ nme
                            Nothing ->
                                case typ of
                                    DEF ident ->
                                        case Map.lookup ident typDefed of
                                            Just primTyp -> do
                                                modify' $ \(GlobState fdec fdef tdef) ->
                                                    GlobState fdec fdef (Map.insert nme primTyp tdef)
                                                elabGdecls xs header allDef
                                            Nothing -> throwE $ "Undefined type: " ++ nme
                                    _ -> do
                                        modify' $ \(GlobState fdec fdef tdef) ->
                                            GlobState fdec fdef (Map.insert nme typ tdef)
                                        elabGdecls xs header allDef

findType' :: Type -> Map.Map Ident Type -> Type
findType' typ typGlob =
    case typ of
        DEF tname -> Maybe.fromMaybe (error $ "Type undefined " ++ tname) (Map.lookup tname typGlob)
        _ -> typ

extractParam' :: [(Type, Ident)] -> Map.Map Ident Type -> [(Ident, Type)]
extractParam' [] typGlob = []
extractParam' l typGlob = foldr f [] l
  where
    f :: (Type, Ident) -> [(Ident, Type)] -> [(Ident, Type)]
    f (ty, arg) curr =
        let primTyp = findType' ty typGlob
         in (arg, primTyp) : curr

findType :: Type -> (Map.Map Ident Type, Map.Map Ident Type) -> Type
findType typ (typGlob, typHeader) =
    case typ of
        DEF tname ->
            Maybe.fromMaybe
                (Maybe.fromMaybe (error $ "Type undefined " ++ tname) (Map.lookup tname typHeader))
                (Map.lookup tname typGlob)
        _ -> typ

--extract the parameter of the function
extractParam :: [(Type, Ident)] -> (Map.Map Ident Type, Map.Map Ident Type) -> [(Ident, Type)]
extractParam [] (typGlob, typHeader) = []
extractParam l (typGlob, typHeader) = foldr f [] l
  where
    f :: (Type, Ident) -> [(Ident, Type)] -> [(Ident, Type)]
    f (ty, arg) curr =
        let primTyp = findType ty (typGlob, typHeader)
         in (arg, primTyp) : curr

eBlock :: [Stmt] -> (GlobState, Header) -> Set.Set Ident -> EAST
eBlock [] context allDef = ENop
eBlock [x] context allDef = eStmt x context allDef
--give declare precedence
eBlock (x:l) context allDef =
    case x of
        Simp (Decl d) ->
            case d of
                JustDecl var tp ->
                    if Map.member var (typeDefined $ fst context) || Map.member var (typDef $ snd context)
                        then error $ "Type name " ++ var ++ " used as variable name"
                        else let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                              in EDecl var primTyp (eBlock l context allDef)
                DeclAsgn var tp expr ->
                    if Map.member var (typeDefined $ fst context) || Map.member var (typDef $ snd context)
                        then error $ "Type name " ++ var ++ " used as variable name"
                        else let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                              in EDecl var primTyp (ESeq (EAssign var (pExp expr context allDef)) (eBlock l context allDef))
        _ -> ESeq (eStmt x context allDef) (eBlock l context allDef)

pExp :: Exp -> (GlobState, Header) -> Set.Set Ident -> EExp
pExp (Int a) context allDef = EInt a
pExp T context allDef = ET
pExp F context allDef = EF
pExp (Ident x) context allDef = EIdent x
pExp (Binop b expr1 expr2) context allDef = EBinop b (pExp expr1 context allDef) (pExp expr2 context allDef)
pExp (Ternop expr1 expr2 expr3) context allDef = ETernop (pExp expr1 context allDef) (pExp expr2 context allDef) (pExp expr3 context allDef)
pExp (Unop u expr1) context allDef = EUnop u (pExp expr1 context allDef)
pExp (Function fn exprlist) context allDef =
    let declGlob = funDeclared $ fst context
        defGlob = funDefined $ fst context
        declHeader = fnDecl $ snd context
     in if Map.member fn declHeader || Map.member fn defGlob || (Map.member fn declGlob && Set.member fn allDef)
            then EFunc fn (fmap (\x -> pExp x context allDef) exprlist)
            else error $ "Undefined function: " ++ fn

eStmt :: Stmt -> (GlobState, Header) -> Set.Set Ident -> EAST
eStmt x context allDef =
    case x of
        Simp s -> eSimp s context allDef
        Stmts b -> eBlock b context allDef
        ControlStmt c ->
            case c of
                Condition b t el -> EIf (pExp b context allDef) (eStmt t context allDef) (eElse el context allDef)
        --declaration still need to be prioritized
                For _initr _condi (Opt (Decl _)) _bodyi -> error "Declaration not meaningful as step of for-loop"
                For initr condi stepi bodyi ->
                    case initr of
                        Opt (Decl (JustDecl var tp)) ->
                            let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                             in EDecl
                                    var
                                    primTyp
                                    (EWhile (pExp condi context allDef) (ESeq (eStmt bodyi context allDef) (eSimpopt stepi context allDef)))
                        Opt (Decl (DeclAsgn var tp expr)) ->
                            let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                             in EDecl
                                    var
                                    primTyp
                                    (ESeq
                                         (EAssign var (pExp expr context allDef))
                                         (EWhile
                                              (pExp condi context allDef)
                                              (ESeq (eStmt bodyi context allDef) (eSimpopt stepi context allDef))))
                        _ ->
                            ESeq
                                (eSimpopt initr context allDef)
                                (EWhile (pExp condi context allDef) (ESeq (eStmt bodyi context allDef) (eSimpopt stepi context allDef)))
                While condi bodyi -> EWhile (pExp condi context allDef) (eStmt bodyi context allDef)
                Assert condi -> EAssert (pExp condi context allDef)
                Retn ret -> ERet (Maybe.Just (pExp ret context allDef))
                Void -> ERet Maybe.Nothing

eSimp :: Simp -> (GlobState, Header) -> Set.Set Ident -> EAST
eSimp simp context allDef =
    case simp of
        Asgn i asop expr ->
            let expression =
                    case asop of
                        Equal -> pExp expr context allDef
                        AsnOp b -> pExp (Binop b (Ident i) expr) context allDef
             in EAssign i expression
        AsgnP i pos ->
            if pos == Incr
                then EAssign i (pExp (Binop Add (Ident i) (Int 1)) context allDef)
                else EAssign i (pExp (Binop Sub (Ident i) (Int 1)) context allDef)
        Decl d ->
            case d of
                JustDecl var tp ->
                    if Map.member var (typeDefined $ fst context) || Map.member var (typDef $ snd context)
                        then error $ "Type name " ++ var ++ " used as variable name"
                        else let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                              in EDecl var primTyp ENop
                DeclAsgn var tp expr ->
                    if Map.member var (typeDefined $ fst context) || Map.member var (typDef $ snd context)
                        then error $ "Type name " ++ var ++ " used as variable name"
                        else let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                              in EDecl var primTyp (EAssign var (pExp expr context allDef))
        Exp expr -> ELeaf (pExp expr context allDef)

eSimpopt :: Simpopt -> (GlobState, Header) -> Set.Set Ident -> EAST
eSimpopt sopt context allDef =
    case sopt of
        SimpNop -> ENop
        Opt s -> eSimp s context allDef

eElse :: Elseopt -> (GlobState, Header) -> Set.Set Ident -> EAST
eElse eopt context allDef =
    case eopt of
        ElseNop -> ENop
        Else stmt -> eStmt stmt context allDef

--compute the factorial of a number example.
exAST :: AST
exAST =
    Program
        [ Typedef INTEGER "hh"
        , Fdecl VOID "o98k" [(INTEGER, "n"), (DEF "hh", "j")]
        , Fdefn
              (DEF "hh")
              "fact_spec"
              [(INTEGER, "n")]
              [ ControlStmt
                    (Condition
                         (Binop Eql (Ident "n") (Int 0))
                         (ControlStmt $ Retn (Int 1))
                         (Else $
                          ControlStmt $
                          Retn (Binop Mul (Ident "n") (Function "fast_spec" [(Binop Sub (Ident "n") (Int 1))]))))
              ]
        , Fdefn
              (DEF "hh")
              "factorial"
              [(INTEGER, "n")]
              [ Simp $ Decl $ DeclAsgn "total" (DEF "hh") (Int 1)
              , Simp $ Decl $ DeclAsgn "count" INTEGER (Int 0)
              , ControlStmt $
                While
                    (Binop Lt (Ident "count") (Ident "n"))
                    (Stmts [Simp (AsgnP "count" Incr), Simp (Asgn "total" (AsnOp Mul) (Ident "count"))])
              , ControlStmt $ Retn (Ident "total")
              ]
        , Fdefn
              INTEGER
              "main"
              []
              [ ControlStmt $
                For
                    (Opt $ Decl (DeclAsgn "i" (DEF "hh") (Int 0)))
                    (Binop Lt (Ident "i") (Int 10))
                    (Opt (AsgnP "i" Incr))
                    (Stmts [Simp $ Exp $ Function "factorial" [Ident "i"]])
              , ControlStmt $ Retn (Int 0)
              ]
        ]
--testEAST :: IO ()
--testEAST =
--    let (east, globs) = eGen exAST
--     in do print east
--           print "____________________________________"
--           print globs