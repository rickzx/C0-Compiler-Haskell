module Compile.Frontend.Elaborate where

import Compile.Types
import Control.Monad.State
import Control.Monad.Trans.Except

import qualified Data.Map as Map
import qualified Data.Maybe as Maybe

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
    let initialState =
                    GlobState
                    { funDeclared = Map.empty
                    , funDefined = Map.empty
                    , typeDefined = Map.empty
                    }
        elaborate = do
            elabHeader l
            s0 <- get
            return $ Header (funDeclared s0) (typeDefined s0)
        h = evalState (runExceptT elaborate) initialState
    in 
        case h of
            Left err -> error err
            Right header -> header
        
        
eGen :: AST -> Header -> EAST
eGen (Program l) header =
    let initialState =
            GlobState
            { funDeclared = Map.empty
            , funDefined = Map.empty
            , typeDefined = Map.empty
            }
        elaborate = elabGdecls l header
        e = evalState (runExceptT elaborate) initialState
    in
        case e of
            Left err -> error err
            Right east -> east
    
        
assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

arrowEq :: (Type, Type) -> Bool
arrowEq (ARROW args1 ret1, ARROW args2 ret2) =
    (length args1 == length args2) && (all (\(a1, a2) -> snd a1 == snd a2) $ zip args1 args2) && ret1 == ret2
arrowEq (_, _) = error "Expect arrow types for comparison"

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
elabGdecls :: [Gdecl] -> Header -> ExceptT String (State GlobState) EAST
elabGdecls [] header = return ENop
elabGdecls (x : xs) header =
    case x of
        Fdecl rtp nme param -> do
            declared <- gets funDeclared
            typDefed <- gets typeDefined
            let typ = ARROW (extractParam param (typDefed, typDef header)) (findType rtp (typDefed, typDef header))
            case Map.lookup nme declared of
                Just typ1 -> do
                    assertMsg ("Type of function " ++ nme ++ "does not match with previous declaration") (arrowEq (typ, typ1))
                    elabGdecls xs header
                Nothing -> case Map.lookup nme (fnDecl header) of
                    Just typ1 -> do
                        assertMsg ("Type of function " ++ nme ++ "does not match with previous declaration in header") (arrowEq (typ, typ1))
                        elabGdecls xs header
                    Nothing -> do
                        modify' $ \(GlobState fdec fdef tdef) -> GlobState (Map.insert nme typ fdec) fdef tdef
                        elabGdecls xs header
        Fdefn rtp nme param blk -> do
            defined <- gets funDefined
            typDefed <- gets typeDefined
            let typ = ARROW (extractParam param (typDefed, typDef header)) (findType rtp (typDefed, typDef header))
            case Map.lookup nme defined of
                Just _ -> throwE $ "Function defined more than once: " ++ nme
                Nothing -> case Map.lookup nme (fnDecl header) of
                    Just _ -> throwE $ "External functions must not be defined " ++ nme
                    Nothing -> do
                        modify' $ \(GlobState fdec fdef tdef) -> GlobState fdec (Map.insert nme typ fdef) tdef
                        gState <- get
                        let blk' = eBlock blk (gState, header)
                        elab' <- elabGdecls xs header
                        return $ ESeq (EDef nme typ blk') elab'
        Typedef typ nme -> do
            typDefed <- gets typeDefined
            case Map.lookup nme typDefed of
                    Just _ -> throwE $ "Type defined more than once: " ++ nme
                    Nothing -> case Map.lookup nme (typDef header) of
                        Just _ ->  throwE $ "Type defined more than once: " ++ nme
                        Nothing -> case typ of
                            DEF ident -> 
                                case Map.lookup ident typDefed of
                                    Just primTyp -> do
                                        modify' $ \(GlobState fdec fdef tdef) -> GlobState fdec fdef (Map.insert nme primTyp tdef)
                                        elabGdecls xs header
                                    Nothing -> throwE $ "Undefined type: " ++ nme
                            _ -> do
                                modify' $ \(GlobState fdec fdef tdef) -> GlobState fdec fdef (Map.insert nme typ tdef)
                                elabGdecls xs header

findType' :: Type -> Map.Map Ident Type -> Type
findType' typ typGlob =
    case typ of
        DEF tname ->
            Maybe.fromMaybe (error $ "Type undefined " ++ tname) (Map.lookup tname typGlob)
        _ -> typ

extractParam' :: [(Type, Ident)] -> Map.Map Ident Type -> [(Ident, Type)]
extractParam' [] typGlob = [("", VOID)]
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
extractParam [] (typGlob, typHeader) = [("", VOID)]
extractParam l (typGlob, typHeader) = foldr f [] l
  where
    f :: (Type, Ident) -> [(Ident, Type)] -> [(Ident, Type)]
    f (ty, arg) curr =
        let primTyp = findType ty (typGlob, typHeader)
        in (arg, primTyp) : curr

eBlock :: [Stmt] -> (GlobState, Header) -> EAST
eBlock [] context = ENop
eBlock [x] context = eStmt x context
--give declare precedence
eBlock (x:l) context =
    case x of
        Simp (Decl d) ->
            case d of
                JustDecl var tp -> 
                    let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                    in EDecl var primTyp (eBlock l context)
                DeclAsgn var tp expr -> 
                    let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                    in EDecl var primTyp (ESeq (EAssign var (pExp expr context)) (eBlock l context))
        _ -> ESeq (eStmt x context) (eBlock l context)

pExp :: Exp -> (GlobState, Header) -> EExp
pExp (Int a) context = EInt a
pExp T context = ET
pExp F context = EF
pExp (Ident x) context = EIdent x
pExp (Binop b expr1 expr2) context = EBinop b (pExp expr1 context) (pExp expr2 context)
pExp (Ternop expr1 expr2 expr3) context = ETernop (pExp expr1 context) (pExp expr2 context) (pExp expr3 context)
pExp (Unop u expr1) context = EUnop u (pExp expr1 context)
pExp (Function fn exprlist) context =
    let defGlob = funDefined $ fst context
        declHeader = fnDecl $ snd context
     in if Map.member fn declHeader || Map.member fn defGlob
            then EFunc fn (fmap (`pExp` context) exprlist)
                else error $ "Undefined function: " ++ fn
            
eStmt :: Stmt -> (GlobState, Header) -> EAST
eStmt x context =
    case x of
        Simp s -> eSimp s context
        Stmts b -> eBlock b context
        ControlStmt c ->
            case c of
                Condition b t el -> EIf (pExp b context) (eStmt t context) (eElse el context)
        --declaration still need to be prioritized
                For _initr _condi (Opt (Decl _)) _bodyi -> error "Declaration not meaningful as step of for-loop"
                For initr condi stepi bodyi ->
                    case initr of
                        Opt (Decl (JustDecl var tp)) ->
                            let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                            in EDecl var primTyp (EWhile (pExp condi context) (ESeq (eStmt bodyi context) (eSimpopt stepi context)))
                        Opt (Decl (DeclAsgn var tp expr)) ->
                            let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                            in  EDecl
                                var
                                primTyp
                                (ESeq
                                     (EAssign var (pExp expr context))
                                     (EWhile (pExp condi context) (ESeq (eStmt bodyi context) (eSimpopt stepi context))))
                        _ -> ESeq (eSimpopt initr context) (EWhile (pExp condi context) (ESeq (eStmt bodyi context) (eSimpopt stepi context)))
                While condi bodyi -> EWhile (pExp condi context) (eStmt bodyi context)
                Assert condi -> EAssert (pExp condi context)
                Retn ret -> ERet (Maybe.Just (pExp ret context))
                Void -> ERet Maybe.Nothing

eSimp :: Simp -> (GlobState, Header) -> EAST
eSimp simp context =
    case simp of
        Asgn i asop expr ->
            let expression =
                    case asop of
                        Equal -> pExp expr context
                        AsnOp b -> pExp (Binop b (Ident i) expr) context
             in EAssign i expression
        AsgnP i pos ->
            if pos == Incr
                then EAssign i (pExp (Binop Add (Ident i) (Int 1)) context)
                else EAssign i (pExp (Binop Sub (Ident i) (Int 1)) context)
        Decl d ->
            case d of
                JustDecl var tp ->
                    let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                    in EDecl var primTyp ENop
                DeclAsgn var tp expr ->
                    let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                    in EDecl var primTyp (EAssign var (pExp expr context))
        Exp expr -> ELeaf (pExp expr context)

eSimpopt :: Simpopt -> (GlobState, Header) -> EAST
eSimpopt sopt context =
    case sopt of
        SimpNop -> ENop
        Opt s -> eSimp s context

eElse :: Elseopt -> (GlobState, Header) -> EAST
eElse eopt context =
    case eopt of
        ElseNop -> ENop
        Else stmt -> eStmt stmt context

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