module Compile.Frontend.CheckEAST where

import Control.Monad.State
import Control.Monad.Trans.Except

import qualified Data.Map as Map
import qualified Data.Set as Set

import Compile.Types
import Debug.Trace

data CheckState =
    CheckState
        { varDeclared :: Set.Set Ident
        , varDefined :: Set.Set Ident
        , funDeclared :: Map.Map Ident Type
        , funDefined :: Map.Map Ident Type
        , typeDefined :: Map.Map Ident Type
        }

type Context = Map.Map Ident Type

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

--checkGlobals :: EAST -> Header -> Either String ()
--checkGlobals east header =
--    let initialState = FunCheckState Map.empty Set.empty Set.empty
--        funCheck = checkFun east header
--     in evalState (runExceptT funCheck) initialState
checkEAST :: EAST -> Header -> Either String ()
-- (trace $ "EAST: " ++ show east ++ "\n")
checkEAST east header =
    let initialState =
            CheckState
                { varDeclared = Set.empty
                , varDefined = Set.empty
                , funDeclared = Map.singleton "main" (ARROW [] INTEGER)
                , funDefined = Map.empty
                , typeDefined = Map.empty
                }
        typeCheck = do
            _ <- checkInit east header
            synthValid Map.empty east
     in evalState (runExceptT typeCheck) initialState

checkUse :: EExp -> Header -> ExceptT String (State CheckState) Bool
checkUse (EInt _) header = return True
checkUse ET header = return True
checkUse EF header = return True
checkUse (EIdent x) header = do
    defined <- gets varDefined
    return $ Set.member x defined
checkUse (EBinop _ e1 e2) header = do
    t1 <- checkUse e1 header
    t2 <- checkUse e2 header
    return $ t1 && t2
checkUse (ETernop e1 e2 e3) header = do
    t1 <- checkUse e1 header
    t2 <- checkUse e2 header
    t3 <- checkUse e3 header
    return $ t1 && t2 && t3
checkUse (EUnop _ e) header = checkUse e header
checkUse (EFunc fn args) header = do
    fDefined <- gets funDefined
    assertMsg ("Undefined function: " ++ fn) (Map.member fn fDefined || Map.member fn (fnDecl header))
    checkAll <- mapM (`checkUse` header) args
    return $ and checkAll

-- This function raises an exception if a variable is used before initialized.
-- Evaluates to true when each branch has a proper return statement, false otherwise.
checkInit :: EAST -> Header -> ExceptT String (State CheckState) Bool
checkInit (ESeq et1 et2) header = do
    t1 <- checkInit et1 header
    t2 <- checkInit et2 header
    return $ t1 || t2
checkInit (EAssign x e) header = do
    t <- checkUse e header
    assertMsg "Variable used before initialization" t
    modify' $ \(CheckState vdec vdef fdec fdef td) -> CheckState vdec (Set.insert x vdef) fdec fdef td
    return False
checkInit (EIf e et1 et2) header = do
    currState <- get
    t <- checkUse e header
    assertMsg "Variable used before initialization" t
    t1 <- checkInit et1 header
    defined1 <- gets varDefined
    put currState
    t2 <- checkInit et2 header
    defined2 <- gets varDefined
    let newState = currState {varDefined = Set.intersection defined1 defined2}
    put newState
    return $ t1 && t2
checkInit (EWhile e et) header = do
    s0 <- get
    t <- checkUse e header
    assertMsg "Variable used before initialization" t
    _ <- checkInit et header
    put s0
    return False
checkInit (ERet e) header =
    case e of
        Just expr -> do
            t <- checkUse expr header
            assertMsg "Variable used before initialization" t
            modify' $ \(CheckState vdec _vdef fdec fdef td) -> CheckState vdec vdec fdec fdef td
            return True
        Nothing -> do
            modify' $ \(CheckState vdec _vdef fdec fdef td) -> CheckState vdec vdec fdec fdef td
            return True
checkInit ENop _ = return False
checkInit (EDecl fn typ@(ARROW _args _ret) et) header = do
    declared <- gets funDeclared
    case Map.lookup fn declared of
        Just typ1 -> do
            assertMsg ("Type of function " ++ fn ++ "does not match with previous declaration") (arrowEq (typ, typ1))
            checkInit et header
        Nothing ->
            case Map.lookup fn $ fnDecl header of
                Just typ1 -> do
                    assertMsg
                        ("Type of function " ++ fn ++ "does not match with previous declaration in header")
                        (arrowEq (typ, typ1))
                    checkInit et header
                Nothing -> do
                    modify' $ \(CheckState vdec vdef fdec fdef td) ->
                        CheckState vdec vdef (Map.insert fn typ fdec) fdef td
                    checkInit et header
checkInit (EDecl x (DEF ident) et) header = do
    typDefed <- gets typeDefined
    case Map.lookup ident typDefed of
        Just typ -> checkInit (EDecl x typ et) header
        Nothing ->
            case Map.lookup ident $ typDef header of
                Just typ -> checkInit (EDecl x typ et) header
                Nothing -> throwE $ "Undeclared type name: " ++ ident
checkInit (EDecl x _typ et) header = do
    typDefed <- gets typeDefined
    if Map.member x typDefed
        then throwE $ "Type name " ++ x ++ "used as variable name"
        else do
            declared <- gets varDeclared
            modify' $ \(CheckState vdec vdef fdec fdef td) -> CheckState (Set.insert x vdec) vdef fdec fdef td
            t <- checkInit et header
            defined <- gets varDefined
            modify' $ \(CheckState _vdec _vdef fdec fdef td) -> CheckState declared (Set.delete x defined) fdec fdef td
            return t
checkInit (EDef fn typ@(ARROW args _ret) et) header = do
    defined <- gets funDefined
    case Map.lookup fn defined of
        Just _ -> throwE $ "Function defined more than once: " ++ fn
        Nothing ->
            case Map.lookup fn (fnDecl header) of
                Just _ -> throwE $ "External functions must not be defined " ++ fn
                Nothing -> do
                    vdeclared <- gets varDeclared
                    vdefined <- gets varDefined
                    let ndecl = foldr (\x s -> Set.insert (fst x) s) vdeclared args
                        ndef = foldr (\x s -> Set.insert (fst x) s) vdefined args
                    modify' $ \(CheckState _vdec _vdef fdec fdef td) ->
                        CheckState ndecl ndef fdec (Map.insert fn typ fdef) td
                    t <- checkInit et header
                    assertMsg ("Function " ++ fn ++ "does not have return") t
                    modify' $ \(CheckState _vdec _vdef fdec fdef td) -> CheckState vdeclared vdefined fdec fdef td
                    return t
checkInit (EDef _ _ _) _header = throwE "EDef must have arrow type!"
checkInit (ETDef typ x) header = do
    defined <- gets typeDefined
    case Map.lookup x defined of
        Just _ -> throwE $ "Type defined more than once: " ++ x
        Nothing ->
            case Map.lookup x (typDef header) of
                Just _ -> throwE $ "Type defined more than once: " ++ x
                Nothing ->
                    case typ of
                        DEF ident ->
                            case Map.lookup ident defined of
                                Just typ' -> do
                                    modify' $ \(CheckState vdec vdef fdec fdef td) ->
                                        CheckState vdec vdef fdec fdef (Map.insert x typ' td)
                                    return True
                                Nothing -> throwE $ "Undefined type: " ++ ident
                        _ -> do
                            modify' $ \(CheckState vdec vdef fdec fdef td) ->
                                CheckState vdec vdef fdec fdef (Map.insert x typ td)
                            return True
checkInit (EAssert e) header = do
    t <- checkUse e header
    assertMsg "Variable used before initialization" t
    return False
checkInit (ELeaf _e) header = return False

synthValid :: Context -> EAST -> ExceptT String (State CheckState) ()
synthValid ctx east =
    case east of
        ESeq et1 et2 -> do
            synthValid ctx et1
            synthValid ctx et2
        EAssign x e ->
            case Map.lookup x ctx of
                Just t -> do
                    te <- synthType ctx e
                    case te of
                        Just t' -> assertMsg "Tycon mismatch" (t == t')
                        _ -> throwE "Variable used before declared"
                _ -> throwE "Variable used before declared"
        EIf e et1 et2 -> do
            te <- synthType ctx e
            case te of
                Just BOOLEAN -> do
                    synthValid ctx et1
                    synthValid ctx et2
                _ -> throwE "Tycon mismatch"
        EWhile e et -> do
            te <- synthType ctx e
            case te of
                Just BOOLEAN -> synthValid ctx et
                _ -> throwE "Tycon mismatch"
        ERet e ->
            case e of
                Just expr -> do
                    te <- synthType ctx expr
                    case te of
                        Just INTEGER -> return ()
                        _ -> throwE "Tycon mismatch"
                Nothing -> return ()
        ENop -> return ()
        EDecl x typ@(ARROW args ret) et -> do
        
        EDecl x typ et -> do
            assertMsg "Variable already declared" (not $ Map.member x ctx)
            synthValid (Map.insert x typ ctx) et
        ELeaf e -> do
            _ <- synthType ctx e
            return ()

--typeCheck :: EAST -> Either String ()
synthType :: Context -> EExp -> ExceptT String (State CheckState) (Maybe Type)
synthType ctx expr =
    case expr of
        ET -> return $ Just BOOLEAN
        EF -> return $ Just BOOLEAN
        EInt _ -> return $ Just INTEGER
        EIdent x ->
            case Map.lookup x ctx of
                Just t -> return $ Just t
                Nothing -> do
                    _ <- throwE "Variable used before declared"
                    return Nothing
        EBinop op e1 e2
            | op == Lt || op == Gt || op == Le || op == Ge -> do
                t1 <- synthType ctx e1
                t2 <- synthType ctx e2
                case (t1, t2) of
                    (Just INTEGER, Just INTEGER) -> return $ Just BOOLEAN
                    _ -> do
                        _ <- throwE "Tycon mismatch"
                        return Nothing
            | op == Eql || op == Neq -> do
                t1 <- synthType ctx e1
                t2 <- synthType ctx e2
                if t1 == t2
                    then return $ Just BOOLEAN
                    else do
                        _ <- throwE "Tycon mismatch"
                        return Nothing
            | op == LAnd || op == LOr -> do
                t1 <- synthType ctx e1
                t2 <- synthType ctx e2
                case (t1, t2) of
                    (Just BOOLEAN, Just BOOLEAN) -> return $ Just BOOLEAN
                    _ -> do
                        _ <- throwE "Tycon mismatch"
                        return Nothing
            | otherwise -> do
                t1 <- synthType ctx e1
                t2 <- synthType ctx e2
                case (t1, t2) of
                    (Just INTEGER, Just INTEGER) -> return $ Just INTEGER
                    _ -> do
                        _ <- throwE "Tycon mismatch"
                        return Nothing
        EUnop LNot e -> do
            t <- synthType ctx e
            case t of
                Just BOOLEAN -> return $ Just BOOLEAN
                _ -> do
                    _ <- throwE "Tycon mismatch"
                    return Nothing
        EUnop _ e -> do
            t <- synthType ctx e
            case t of
                Just INTEGER -> return $ Just INTEGER
                _ -> do
                    _ <- throwE "Tycon mismatch"
                    return Nothing
        ETernop e1 e2 e3 -> do
            t1 <- synthType ctx e1
            t2 <- synthType ctx e2
            t3 <- synthType ctx e3
            case (t1, t2, t3) of
                (Just BOOLEAN, Just t, Just t') ->
                    if t == t'
                        then return $ Just t
                        else do
                            _ <- throwE "Tycon mismatch"
                            return Nothing
                _ -> do
                    _ <- throwE "Tycon mismatch"
                    return Nothing

arrowEq :: (Type, Type) -> Bool
arrowEq (ARROW args1 ret1, ARROW args2 ret2) =
    (length args1 == length args2) && (all (\(a1, a2) -> snd a1 == snd a2) $ zip args1 args2) && ret1 == ret2
arrowEq (_, _) = error "Expect arrow types for comparison"
--testCheckEAST :: IO ()
--testCheckEAST = do
--    let east =
--            EDecl
--                "x"
--                INTEGER
--                (EDecl
--                     "y"
--                     INTEGER
--                     (ESeq
--                          (EAssign "y" (EInt 2))
--                          (ESeq
--                               (EIf (EBinop Lt (EIdent "y") (EInt 1)) (EAssign "x" (EInt 1)) (EAssign "x" (EInt 2)))
--                               (ERet (EBinop Add (EIdent "x") (EIdent "y"))))))
--    res <- runExceptT $ liftEIO $ checkEAST east
--    case res of
--        Left s -> putStrLn s
--        Right _ -> putStrLn "Type-check suceeded"