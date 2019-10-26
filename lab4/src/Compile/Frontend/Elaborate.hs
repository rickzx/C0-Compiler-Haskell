{-# LANGUAGE BangPatterns, Strict #-}

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
type Structmap = Map.Map Ident [(Type, Ident)]

data GlobState =
    GlobState
        { funDeclared :: Map.Map Ident Type
        , funDefined :: Map.Map Ident Type
        , typeDefined :: Map.Map Ident Type
        , structDefined :: Map.Map Ident [(Type, Ident)]
        }

eGenHeader :: AST -> Header
eGenHeader (Program l) =
    let initialState = GlobState {funDeclared = Map.empty, funDefined = Map.empty, typeDefined = Map.empty,
        structDefined = Map.empty}
        elaborate = do
            elabHeader l
            s0 <- get
            return $ Header (funDeclared s0) (typeDefined s0) (structDefined s0)
        h = evalState (runExceptT elaborate) initialState
     in case h of
            Left err -> error err
            Right header -> header

eGen :: AST -> Header -> EAST
eGen (Program l) header =
    let initialState = GlobState {funDeclared = Map.singleton "main" (ARROW [] INTEGER), funDefined = Map.empty, typeDefined = Map.empty,
        structDefined = Map.empty}
        allDef = findDefFunc l
        elaborate = if not (Set.member "main" allDef) then error "Cannot find main function" else elabGdecls l header allDef
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

--check if a typedef for an array is valid
checkArrayTypedef :: (Fnmap, Structmap) -> Type -> Bool
checkArrayTypedef (typemap, strucmap) tpe@(ARRAY atype) = 
    case atype of
        DEF idd ->
            case Map.lookup idd typemap of
                Just primTyp -> True
                Nothing -> False
        STRUCT ident ->
            case Map.lookup ident strucmap of
                Just _ -> True
                Nothing -> False
        ARRAY arrtype -> checkArrayTypedef (typemap, strucmap) atype
        POINTER ptype -> checkPointerTypedef (typemap, strucmap) ptype
        VOID -> error "Can't have an array of void type"
        _ -> True
checkArrayTypedef (typemap, strucmap) _ = False

--check if a typedef for a pointer is valid
checkPointerTypedef :: (Fnmap, Structmap) -> Type -> Bool
checkPointerTypedef (typemap, strucmap) tpe@(POINTER ptype) = 
    case ptype of
        DEF idd ->
            case Map.lookup idd typemap of
                Just primTyp -> True
                Nothing -> False
        STRUCT ident ->
            case Map.lookup ident strucmap of
                Just _ -> True
                Nothing -> False
        ARRAY arrtype -> checkArrayTypedef (typemap, strucmap) ptype
        POINTER potype -> checkPointerTypedef (typemap, strucmap) potype
        VOID -> error "Can't have an array of void type"
        _ -> True
checkPointerTypedef (typemap, strucmap) _ = False


elabHeader :: [Gdecl] -> ExceptT String (State GlobState) ()
elabHeader [] = return ()
elabHeader (x:xs) =
    case x of
        Fdecl rtp fnname param -> do
            let nme = if fnname == "abort" then "a bort" else fnname
            declared <- gets funDeclared
            typDefed <- gets typeDefined
            if Map.member nme typDefed then throwE $ "Function uses a typedef name " ++ nme else do
                let !argtyp = extractParam' param typDefed
                    typ = ARROW argtyp (findType' rtp typDefed)
                case Map.lookup nme declared of
                    Just typ1 -> do
                        assertMsg
                            ("Type of function " ++ nme ++ "does not match with previous declaration")
                            (arrowEq (typ, typ1))
                        elabHeader xs
                    Nothing -> do
                        modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState (Map.insert nme typ fdec) fdef tdef sdef
                        elabHeader xs
        Typedef typ nme -> do
            declared <- gets funDeclared
            if typ == VOID then throwE "Cannot typdef VOID" else
                if Map.member nme declared then throwE $ "Typdef uses a function name " ++ nme else do
                typDefed <- gets typeDefined
                strucDefed <- gets structDefined
                case Map.lookup nme typDefed of
                    Just _ -> throwE $ "Type defined more than once: " ++ nme
                    Nothing ->
                        case typ of
                            DEF ident ->
                                case Map.lookup ident typDefed of
                                    Just primTyp -> do
                                        modify' $ \(GlobState fdec fdef tdef sdef) ->
                                            GlobState fdec fdef (Map.insert nme primTyp tdef) sdef
                                        elabHeader xs
                                    Nothing -> throwE $ "Undefined type: " ++ ident
                            STRUCT ident ->
                                case Map.lookup ident strucDefed of
                                    Just _ -> do
                                        modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                        elabHeader xs
                                    Nothing -> throwE $ "Undefined struct type: " ++ ident
                            ARRAY atype -> if checkArrayTypedef (typDefed, strucDefed) atype then 
                                do
                                    modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                    elabHeader xs
                                else throwE $ "Undefined type: " ++ show atype 
                            POINTER ptype -> if checkPointerTypedef (typDefed, strucDefed) ptype then 
                                do
                                    modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                    elabHeader xs
                                else throwE $ "Undefined type: " ++ show ptype               
                            _ -> do
                                modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                elabHeader xs
        Sdecl nme -> do
            strucDefed <- gets structDefined
            case Map.lookup nme strucDefed of 
                Just _ -> elabHeader xs
                Nothing -> do
                    modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef tdef (Map.insert nme [] sdef)
                    elabHeader xs
        Sdef nme param -> do
            strucDefed <- gets structDefined
            case Map.lookup nme strucDefed of
                Just (y:ys) -> throwE $ "struct" ++ nme ++ "is defined more than once"
                _ -> do 
                    modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef tdef (Map.insert nme param sdef)
                    elabHeader xs

        _ -> throwE "Header only supports function declaration and typedef!"

--do it for gdecl in main file, need to consider header
--(typedef + structdef) for main file -> typedef header -> structdef header
checkArrayTypedef' :: (Fnmap, Structmap) -> Fnmap -> Structmap -> Type -> Bool
checkArrayTypedef' (typemap, strucmap) headertype headerstruct tpe@(ARRAY atype) = 
    case atype of
        DEF idd ->
            case Map.lookup idd typemap of
                Just primTyp -> True
                Nothing -> case Map.lookup idd headertype of
                    Just _ -> True
                    Nothing -> False
        STRUCT ident ->
            case Map.lookup ident strucmap of
                Just _ -> True
                Nothing -> case Map.lookup ident headerstruct of 
                    Just _ -> True
                    Nothing -> False
        ARRAY arrtype -> checkArrayTypedef' (typemap, strucmap) headertype headerstruct atype
        POINTER ptype -> checkPointerTypedef' (typemap, strucmap) headertype headerstruct ptype
        VOID -> error "Can't have an array of void type"
        _ -> True
checkArrayTypedef' (typemap, strucmap) _ _ _ = False

--do it for gdecl in main file, need to consider header
--(typedef + structdef) for main file -> typdef header -> structdef header
checkPointerTypedef' :: (Fnmap, Structmap) -> Fnmap -> Structmap -> Type -> Bool
checkPointerTypedef' (typemap, strucmap) headertype headerstruct tpe@(POINTER ptype) = 
    case ptype of
        DEF idd ->
            case Map.lookup idd typemap of
                Just primTyp -> True
                Nothing -> case Map.lookup idd headertype of
                    Just _ -> True
                    Nothing -> False
        STRUCT ident ->
            case Map.lookup ident strucmap of
                Just _ -> True
                Nothing -> case Map.lookup ident headerstruct of 
                    Just _ -> True
                    Nothing -> False
        ARRAY arrtype -> checkArrayTypedef' (typemap, strucmap) headertype headerstruct ptype
        POINTER potype -> checkPointerTypedef' (typemap, strucmap) headertype headerstruct potype
        _ -> True
checkPointerTypedef' (typemap, strucmap) _ _ _ = False

elabGdecls :: [Gdecl] -> Header -> Set.Set Ident -> ExceptT String (State GlobState) EAST
elabGdecls [] header allDef = return ENop
elabGdecls (x:xs) header allDef =
    case x of
        Fdecl rtp fnname param -> do
            let nme = if fnname == "abort" then "a bort" else fnname
            declared <- gets funDeclared
            typDefed <- gets typeDefined
            if Map.member nme typDefed || Map.member nme (typDef header) then throwE $ "Function uses a typedef name " ++ nme else do
                let !argtyp = extractParam param (typDefed, typDef header)
                    typ = ARROW argtyp (findType rtp (typDefed, typDef header))
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
                                modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState (Map.insert nme typ fdec) fdef tdef sdef
                                elab' <- elabGdecls xs header allDef
                                return $ EDecl nme typ elab'
        Fdefn rtp fnname param blk -> do
            let nme = if fnname == "abort" then "a bort" else fnname
            declared <- gets funDeclared
            defined <- gets funDefined
            typDefed <- gets typeDefined
            if Map.member nme typDefed || Map.member nme (typDef header) then throwE $ "Function uses a typedef name " ++ nme else
                if nme == "main" && (findType rtp (typDefed, typDef header) /= INTEGER || length param > 0) then throwE "Bad declaration for main" else do
                    let !argtyp = extractParam param (typDefed, typDef header)
                        typ = ARROW argtyp (findType rtp (typDefed, typDef header))
                    _ <- elabGdecls [Fdecl rtp nme param] header allDef
                    case Map.lookup nme defined of
                        Just _ -> throwE $ "Function defined more than once: " ++ nme
                        Nothing ->
                            case Map.lookup nme (fnDecl header) of
                                Just _ -> throwE $ "External functions must not be defined " ++ nme
                                Nothing -> do
                                    modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState (Map.insert nme typ fdec) (Map.insert nme typ fdef) tdef sdef
                                    gState <- get
                                    let blk' = eBlock blk (gState, header) allDef
                                    elab' <- elabGdecls xs header allDef
                                    return $ EDecl nme typ (ESeq (EDef nme typ blk') elab')
        Typedef typ nme ->
            if typ == VOID then throwE "Cannot typdef VOID" else do
            typDefed <- gets typeDefined
            fnDeclared <- gets funDeclared
            strucDefed <- gets structDefined
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
                                                modify' $ \(GlobState fdec fdef tdef sdef) ->
                                                    GlobState fdec fdef (Map.insert nme primTyp tdef) sdef
                                                elabGdecls xs header allDef
                                            Nothing -> case Map.lookup ident (typDef header) of
                                                Just primTyp -> do
                                                    modify' $ \(GlobState fdec fdef tdef sdef) ->
                                                        GlobState fdec fdef (Map.insert nme primTyp tdef) sdef
                                                    elabGdecls xs header allDef
                                                Nothing -> throwE $ "Undefined type: " ++ ident
                                    STRUCT ident ->
                                        case Map.lookup ident strucDefed of
                                            Just _ -> do
                                                modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                                elabGdecls xs header allDef
                                            Nothing -> case Map.lookup ident (typDef header) of
                                                Just primTyp -> do
                                                    modify' $ \(GlobState fdec fdef tdef sdef) ->
                                                        GlobState fdec fdef (Map.insert nme primTyp tdef) sdef
                                                    elabGdecls xs header allDef
                                                Nothing -> throwE $ "Undefined struct type: " ++ ident
                                    ARRAY atype -> if checkArrayTypedef' (typDefed, strucDefed) (typDef header) (structDef header) atype then 
                                        do
                                            modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                            elabGdecls xs header allDef
                                        else throwE $ "Undefiend type: " ++ show atype 
                                    POINTER ptype -> if checkPointerTypedef' (typDefed, strucDefed) (typDef header) (structDef header) ptype then 
                                        do
                                            modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                            elabGdecls xs header allDef
                                        else throwE $ "Undefiend type: " ++ show ptype               
                                    _ -> do
                                        modify' $ \(GlobState fdec fdef tdef sdef) ->
                                            GlobState fdec fdef (Map.insert nme typ tdef) sdef
                                        elabGdecls xs header allDef
        Sdecl nme -> do
            strucDefed <- gets structDefined
            case Map.lookup nme strucDefed of 
                Just _ -> do
                    elab' <- elabGdecls xs header allDef
                    return $ EDecl nme (STRUCT nme) elab'
                Nothing -> case Map.lookup nme (structDef header) of
                    Just _ -> do
                        elab' <- elabGdecls xs header allDef
                        return $ EDecl nme (STRUCT nme) elab'
                    Nothing -> do
                        modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef tdef (Map.insert nme [] sdef)
                        elab' <- elabGdecls xs header allDef
                        return $ EDecl nme (STRUCT nme) elab'
        Sdef nme param -> do
            structDefed <- gets structDefined
            case Map.lookup nme structDefed of
                Just (y:ys) -> throwE $ "struct" ++ nme ++ "is defined more than once"
                _ -> case Map.lookup nme (structDef header) of
                    Just (z:zs) -> throwE $ "struct" ++ nme ++ "is defined more than once"
                    _ -> do 
                        modify' $ \(GlobState fdec fdef tdef sdef) -> GlobState fdec fdef tdef (Map.insert nme param sdef)
                        elab' <- elabGdecls xs header allDef
                        return $ ESDef nme param elab'


findType' :: Type -> Map.Map Ident Type -> Type
findType' typ typGlob =
    case typ of
        DEF tname -> Maybe.fromMaybe (error $ "Type undefined " ++ tname) (Map.lookup tname typGlob)
        _ -> typ

extractParam' :: [(Type, Ident)] -> Map.Map Ident Type -> [(Ident, Type)]
extractParam' [] typGlob = []
extractParam' l typGlob = fst (foldr f ([], Set.empty) l)
    where
      f :: (Type, Ident) -> ([(Ident, Type)], Set.Set Ident) -> ([(Ident, Type)], Set.Set Ident)
      f (ty, arg) (curr, setVars)
          | Map.member arg typGlob = error "Function parameter uses a typedef name"
          | Set.member arg setVars = error "Function parameter contains duplicated parameters"
          | ty == VOID = error "Function parameter cannot be VOID"
          | otherwise =
              let primTyp = findType' ty typGlob
               in if primTyp == VOID
                      then error "Function parameter cannot be VOID"
                      else ((arg, primTyp) : curr, Set.insert arg setVars)

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
extractParam l (typGlob, typHeader) = fst (foldr f ([], Set.empty) l)
  where
    f :: (Type, Ident) -> ([(Ident, Type)], Set.Set Ident) -> ([(Ident, Type)], Set.Set Ident)
    f (ty, arg) (curr, setVars)
        | Map.member arg typGlob || Map.member arg typHeader = error "Function parameter uses a typedef name"
        | Set.member arg setVars = error "Function parameter contains duplicated parameters"
        | ty == VOID = error "Function parameter cannot be VOID"
        | otherwise =
            let primTyp = findType ty (typGlob, typHeader)
             in if primTyp == VOID
                    then error "Function parameter cannot be VOID"
                    else ((arg, primTyp) : curr, Set.insert arg setVars)

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
                        then error $ "Type name " ++ show var ++ " used as variable name"
                        else let primTyp = findType tp (typeDefined $ fst context, typDef $ snd context)
                              in EDecl var primTyp (ESeq (EAssign (pLvalue (Ident var) context allDef) (pExp expr context allDef) True) (eBlock l context allDef))
        _ -> ESeq (eStmt x context allDef) (eBlock l context allDef)

pLvalue :: Exp -> (GlobState, Header) -> Set.Set Ident -> ELValue
pLvalue (Ident x) context allDef = EVIdent x
pLvalue (Access expr nme) context allDef = EVField (EVDeref (pLvalue expr context allDef)) nme
pLvalue (Field expr nme) context allDef = EVField (pLvalue expr context allDef) nme
pLvalue (Ptrderef expr) context allDef = EVDeref(pLvalue expr context allDef)
pLvalue (ArrayAccess expr1 expr2) context allDef = EVArrAccess (pLvalue expr1 context allDef) (pExp expr2 context allDef)
pLvalue _ _ _= error "Following expression can not be a lvalue"

pExp :: Exp -> (GlobState, Header) -> Set.Set Ident -> EExp
pExp (Int a) context allDef = EInt a
pExp T context allDef = ET
pExp F context allDef = EF
pExp (Ident x) context allDef = EIdent x
pExp (Binop b expr1 expr2) context allDef = EBinop b (pExp expr1 context allDef) (pExp expr2 context allDef)
pExp (Ternop expr1 expr2 expr3) context allDef = ETernop (pExp expr1 context allDef) (pExp expr2 context allDef) (pExp expr3 context allDef)
pExp (Unop u expr1) context allDef = EUnop u (pExp expr1 context allDef)
pExp NULL context allDef = ENULL
pExp (Alloc typ) context allDef = EAlloc typ
pExp (ArrayAlloc typ expr1) context allDef = EArrAlloc typ (pExp expr1 context allDef)
pExp (ArrayAccess expr1 expr2) context allDef = EArrAccess (pExp expr1 context allDef) (pExp expr2 context allDef)
pExp (Field expr1 nme) context allDef = EField (pExp expr1 context allDef) nme
pExp (Access expr1 nme) context allDef = EField (EDeref(pExp expr1 context allDef)) nme
pExp (Ptrderef expr1) context allDef = EDeref (pExp expr1 context allDef)
pExp (Function fnname exprlist) context allDef =
    let declGlob = funDeclared $ fst context
        defGlob = funDefined $ fst context
        declHeader = fnDecl $ snd context
        fn = if fnname == "abort" then "a bort" else fnname
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
                                         (EAssign (pLvalue (Ident var) context allDef) (pExp expr context allDef) True)
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
                        AsnOp b -> pExp (Binop b i expr) context allDef
             in EAssign (pLvalue i context allDef) expression False
        AsgnP i pos ->
            if pos == Incr
                then EAssign (pLvalue i context allDef) (pExp (Binop Add i (Int 1)) context allDef) False
                else EAssign (pLvalue i context allDef) (pExp (Binop Sub i (Int 1)) context allDef) False
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
                              in EDecl var primTyp (EAssign (pLvalue (Ident var) context allDef) (pExp expr context allDef) True)
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
                         Retn (Binop Mul (Ident "n") (Function "fact_spec" [(Binop Sub (Ident "n") (Int 1))]))))
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
                   (Stmts [Simp (AsgnP (Ident "count") Incr), Simp (Asgn (Ident "total") (AsnOp Mul) (Ident "count"))])
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
                   (Opt (AsgnP (Ident "i") Incr))
                   (Stmts [Simp $ Exp $ Function "factorial" [Ident "i"]])
             , ControlStmt $ Retn (Int 0)
             ]
       ]
testEAST :: IO ()
testEAST =
   let 
    east = eGen exAST (Header (Map.empty) (Map.empty) (Map.empty))
    in do 
        print east;
        print "____________________________________"