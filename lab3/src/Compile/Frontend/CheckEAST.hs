module Compile.Frontend.CheckEAST where

import Control.Monad.State
import Control.Monad.Trans.Except
import Data.Maybe

import qualified Data.Map as Map
import qualified Data.Set as Set

import Compile.Types
import LiftIOE
import Debug.Trace

type TypeCheckState = (Set.Set Ident, Set.Set Ident)

type Context = Map.Map Ident Type

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

checkEAST :: EAST -> Either String ()
-- (trace $ "EAST: " ++ show east ++ "\n")
checkEAST east = evalState (runExceptT typeCheck) initialState
  where
    initialState = (Set.empty, Set.empty)
    typeCheck = do
        checkInit east
        synthValid Map.empty east

checkUse :: EExp -> ExceptT String (State TypeCheckState) Bool
checkUse (EInt _) = return True
checkUse ET = return True
checkUse EF = return True
checkUse (EIdent x) = do
    (_, defined) <- get
    return $ Set.member x defined
checkUse (EBinop _ e1 e2) = do
    t1 <- checkUse e1
    t2 <- checkUse e2
    return $ t1 && t2
checkUse (ETernop e1 e2 e3) = do
    t1 <- checkUse e1
    t2 <- checkUse e2
    t3 <- checkUse e3
    return $ t1 && t2 && t3
checkUse (EUnop _ e) = checkUse e

-- This function raises an exception if a variable is used before initialized.
-- Evaluates to true when each branch has a proper return statement, false otherwise.
checkInit :: EAST -> ExceptT String (State TypeCheckState) Bool
checkInit (ESeq et1 et2) = do
    t1 <- checkInit et1
    t2 <- checkInit et2
    return $ t1 || t2
checkInit (EAssign x e) = do
    (declared, defined) <- get
    t <- checkUse e
    assertMsg "Variable used before initialization" t
    put (declared, Set.insert x defined)
    return False
checkInit (EIf e et1 et2) = do
    (declared, defined) <- get
    t <- checkUse e
    assertMsg "Variable used before initialization" t
    t1 <- checkInit et1
    (_, defined1) <- get
    put (declared, defined)
    t2 <- checkInit et2
    (_, defined2) <- get
    put (declared, Set.intersection defined1 defined2)
    return $ t1 && t2
checkInit (EWhile e et) = do
    s0 <- get
    t <- checkUse e
    assertMsg "Variable used before initialization" t
    _ <- checkInit et
    put s0
    return False
checkInit (ERet e) = case e of
    Just expr -> do
        t <- checkUse expr
        assertMsg "Variable used before initialization" t
        (declared, _) <- get
        put (declared, declared)
        return True
    Nothing -> do
        (declared, _) <- get
        put (declared, declared)
        return True
checkInit ENop = return False
checkInit (EDecl x _t et) = do
    (declared, defined) <- get
    put (Set.insert x declared, defined)
    t <- checkInit et
    (_, defined') <- get
    put (declared, Set.delete x defined')
    return t
checkInit (EDef fn (ARROW args ret) et) = do
    (declared, defined) <- get
    let ndecl = foldr (\x s -> Set.insert (fst x) s) declared args
        ndef = foldr (\x s -> Set.insert (fst x) s) defined args
    put (ndecl, ndef)
    t <- checkInit et
    case ret of
        VOID -> return True
        _ -> do
            assertMsg ("Function " ++ fn ++ "does not have return") t
            put (declared, defined)
            return t
checkInit (ELeaf _e) = return False

synthValid :: Context -> EAST -> ExceptT String (State TypeCheckState) ()
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
        EDecl fn typ@(ARROW _args _ret) et -> synthValid (Map.insert fn typ ctx) et
        EDecl x typ et ->
            case typ of
                VOID -> throwE "Variable cannot be declared as void"
                _ -> do
                    assertMsg "Variable already defined" (not $ Map.member x ctx)
                    synthValid (Map.insert x typ ctx) et
        ELeaf e -> do
            _ <- synthType ctx e
            return ()
        EAssert e -> do
            te <- synthType ctx e
            case te of
                Just BOOLEAN -> return ()
                _ -> throwE "Tycon mismatch"

synthType :: Context -> EExp -> ExceptT String (State TypeCheckState) (Maybe Type)
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
        EFunc fn args -> do
            let fnTyp = fromMaybe (error $ "Undefined function " ++ fn) (Map.lookup fn ctx)
            argTyp <- mapM (synthType ctx) args
            let retTyp = checkArgTyp argTyp fnTyp
            return $ Just retTyp
            
checkArgTyp :: [Maybe Type] -> Type -> Type
checkArgTyp argTyp (ARROW args ret)
    | length argTyp /= length args = error "Function type mismatch"
    | all (\(x, y) ->
               case x of
                   Nothing -> error "Tycon mismatch"
                   Just typ -> typ == snd y) $
          zip argTyp args = ret
    | otherwise = error "Function type mismatch"
checkArgTyp _ _ = error "Invalid type"

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