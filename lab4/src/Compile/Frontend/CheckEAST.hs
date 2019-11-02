module Compile.Frontend.CheckEAST where

import Control.Monad.State
import Control.Monad.Trans.Except
import Data.Maybe

import qualified Data.Map as Map
import qualified Data.Set as Set

import Compile.Types
import Debug.Trace

type TypeCheckState = (Set.Set Ident, Set.Set Ident)    -- (Declared, Defined)

type Context = Map.Map Ident Type
type StructCtx = Map.Map Ident Context

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

checkEAST :: EAST -> Header -> Either String TAST
-- (trace $ "EAST: " ++ show east ++ "\n")
checkEAST east header = evalState (runExceptT typeCheck) initialState
  where
    initialState = (Set.empty, Set.empty)
    typeCheck = do
        checkInit east
        synthValid (Map.empty, Map.insert "main" (ARROW [] INTEGER) (fnDecl header), structDef header) east

checkUse :: EExp -> ExceptT String (State TypeCheckState) Bool
checkUse (EInt _) = return True
checkUse ET = return True
checkUse EF = return True
checkUse ENULL = return True
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
checkUse (EFunc fn args) = do
    (declared, _) <- get
    assertMsg ("Variable shadows the function declaration " ++ fn) (not (Set.member fn declared))
    checkAll <- mapM checkUse args
    return $ and checkAll
checkUse (EAlloc _) = return True
checkUse (EArrAlloc _ e) = checkUse e
checkUse (EArrAccess e1 e2) = do
    t1 <- checkUse e1
    t2 <- checkUse e2
    return $ t1 && t2
checkUse (EField e _) = checkUse e
checkUse (EDeref e) = checkUse e
    
extractLValue :: ELValue -> Set.Set Ident -> Maybe Ident
extractLValue (EVIdent x) s = 
    if Set.member x s then Just x else Nothing
extractLValue (EVField l _) s = extractLValue l s
extractLValue (EVDeref l) s = extractLValue l s
extractLValue (EVArrAccess l _) s = extractLValue l s

assertLValueDefined :: ELValue -> Set.Set Ident -> Bool
assertLValueDefined (EVIdent x) s = Set.member x s
assertLValueDefined (EVField l _) s = assertLValueDefined l s
assertLValueDefined (EVDeref l) s = assertLValueDefined l s
assertLValueDefined (EVArrAccess l _) s = assertLValueDefined l s

-- This function raises an exception if a variable is used before initialized.
-- Evaluates to true when each branch has a proper return statement, false otherwise.
checkInit :: EAST -> ExceptT String (State TypeCheckState) Bool
--checkInit et | (trace $ show et) False = undefined
checkInit (ESeq et1 et2) = do
    t1 <- checkInit et1
    t2 <- checkInit et2
    return $ t1 || t2
checkInit (EAssign (EVIdent x) e True) = do
        (declared, defined) <- get
        let newdecl = Set.delete x declared
        put (newdecl, defined)
        t <- checkUse e
        assertMsg ("Variable used before initialization " ++ show e) t
        put (declared, Set.insert x defined)
        return False
checkInit (EAssign (EVIdent x) e False) = do
        (declared, defined) <- get
        t <- checkUse e
        assertMsg ("Variable used before initialization " ++ show e) t
        put (declared, Set.insert x defined)
        return False
checkInit (EAssign lval@(EVArrAccess _ idx) e _) = do
        (declared, defined) <- get
        t1 <- checkUse e
        t2 <- checkUse idx
        assertMsg ("Variable used before initialization " ++ show e) (t1 && t2)
        let x' = extractLValue lval declared
        assertMsg ("Assignment use uninitialized variables " ++ show lval) (assertLValueDefined lval defined)
        case x' of
            Nothing -> throwE $ "Assignment uses undeclared variables " ++ show lval
            Just x -> do
                put (declared, Set.insert x defined)
                return False
checkInit (EAssign lval e _) = do
        (declared, defined) <- get
        t <- checkUse e
        assertMsg ("Variable used before initialization " ++ show e) t
        let x' = extractLValue lval declared
        assertMsg ("Assignment use uninitialized variables " ++ show lval) (assertLValueDefined lval defined)
        case x' of
            Nothing -> throwE $ "Assignment uses undeclared variables " ++ show lval
            Just x -> do
                put (declared, Set.insert x defined)
                return False
checkInit (EPtrAssign lval _ e) = do
        (declared, defined) <- get
        t <- checkUse e
        assertMsg ("Variable used before initialization " ++ show e) t  
        let x' = extractLValue lval declared
        assertMsg ("Assignment use uninitialized variables " ++ show lval) (assertLValueDefined lval defined)
        case x' of
            Nothing -> throwE $ "Assignment uses undeclared variables " ++ show lval
            Just x -> do
                put (declared, Set.insert x defined)
                return False
checkInit (EIf e et1 et2) = do
    (declared, defined) <- get
    t <- checkUse e
    assertMsg ("Variable used before initialization " ++ show e) t
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
    assertMsg ("Variable used before initialization " ++ show e) t
    _ <- checkInit et
    put s0
    return False
checkInit (ERet e) = case e of
    Just expr -> do
        t <- checkUse expr
        assertMsg ("Variable used before initialization " ++ show e) t
        (declared, _) <- get
        put (declared, declared)
        return True
    Nothing -> do
        (declared, _) <- get
        put (declared, declared)
        return True
checkInit ENop = return False
checkInit (EDecl _x (ARROW _ _) et) = checkInit et
checkInit (EDecl x _t et) = do
    (declared, defined) <- get
    put (Set.insert x declared, defined)
    t <- checkInit et
    (_, defined') <- get
    put (declared, Set.delete x defined')
    return t
checkInit (EDef fn (ARROW args ret) et) = do
    let ndecl = foldr (\x s -> Set.insert (fst x) s) Set.empty args
        ndef = foldr (\x s -> Set.insert (fst x) s) Set.empty args
    put (ndecl, ndef)
    t <- checkInit et
    case ret of
        VOID -> return True
        _ -> do
            assertMsg ("Function " ++ fn ++ "does not have return") t
            return t
checkInit (ESDef _ _ et) = checkInit et
checkInit (EAssert e) = do
    t <- checkUse e
    assertMsg ("Variable used before initialization " ++ show e) t
    return False
checkInit (ELeaf e) = do
    t <- checkUse e
    assertMsg ("Variable used before initialization " ++ show e) t
    return False
    
synthLValType :: (Context, Context, StructCtx) -> ELValue -> ExceptT String (State TypeCheckState) (Maybe (Type, TLValue))
synthLValType (ctx, _, _) (EVIdent x) =
    return $ maybe Nothing (\t -> Just (t, TVIdent x t)) (Map.lookup x ctx)
synthLValType (ctx, fctx, sctx) (EVField lval fld) = do
    synth <- synthLValType (ctx, fctx, sctx) lval
    case synth of
        Nothing -> return Nothing
        Just (STRUCT s, tlval) ->
            case Map.lookup s sctx of
                Just ctx' -> return $ maybe Nothing (\t -> Just (t, TVField tlval fld t)) (Map.lookup fld ctx')
                Nothing -> return Nothing
        _ -> return Nothing
synthLValType (ctx, fctx, sctx) (EVDeref lval) = do
    synth <- synthLValType (ctx, fctx, sctx) lval
    case synth of
        Nothing -> return Nothing
        Just (POINTER ptr, tlval) -> return $ Just (ptr, TVDeref tlval ptr)
        _ -> return Nothing
synthLValType (ctx, fctx, sctx) (EVArrAccess lval idx) = do
    synth <- synthLValType (ctx, fctx, sctx) lval
    case synth of
        Nothing -> return Nothing
        Just (ARRAY t, tlval) -> do
            tidx <- synthType (ctx, fctx, sctx) idx
            case tidx of
                Just (INTEGER, texp) -> return $ Just (t, TVArrAccess tlval texp t)
                _ -> return Nothing
        _ -> return Nothing

synthValid :: (Context, Context, StructCtx) -> EAST -> ExceptT String (State TypeCheckState) TAST
--synthValid _ e | (trace $ show e) False = undefined
synthValid (ctx, fctx, sctx) east =
    case east of
        ESeq et1 et2 -> do
            tt1 <- synthValid (ctx, fctx, sctx) et1
            tt2 <- synthValid (ctx, fctx, sctx) et2
            return $ TSeq tt1 tt2
        EAssign lval e b -> do
            lTyp <- synthLValType (ctx, fctx, sctx) lval
            case lTyp of
                Just (t, tlval) -> do
                    eTyp <- synthType (ctx, fctx, sctx) e
                    case eTyp of
                        Just (STRUCT _, _) -> throwE $ "Assignment must have small type " ++ show e
                        Just (ANY, texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (isPointer t)
                            return $ TAssign tlval texp b
                        Just (t', texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (t == t')
                            return $ TAssign tlval texp b
                        Nothing -> throwE $ "Variable used before declared " ++ show e
                Nothing -> throwE $ "Cannot synthesize the type of lvalue: " ++ show lval
        EPtrAssign lval asop e -> do
            lTyp <- synthLValType (ctx, fctx, sctx) lval
            case lTyp of
                Just (t, tlval) -> do
                    eTyp <- synthType (ctx, fctx, sctx) e
                    case eTyp of
                        Just (STRUCT _, _) -> throwE $ "Assignment must have small type " ++ show e
                        Just (ANY, texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (isPointer t)
                            return $ TPtrAssign tlval asop texp
                        Just (t', texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (t == t')
                            return $ TPtrAssign tlval asop texp
                        Nothing -> throwE $ "Variable used before declared " ++ show e
                Nothing -> throwE $ "Cannot synthesize the type of lvalue: " ++ show lval
        EIf e et1 et2 -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (BOOLEAN, texp) -> do
                    tt1 <- synthValid (ctx, fctx, sctx) et1
                    tt2 <- synthValid (ctx, fctx, sctx) et2
                    return $ TIf texp tt1 tt2
                _ -> throwE $ "tycon mismatch " ++ show east
        EWhile e et -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (BOOLEAN, texp) -> do
                    tt <- synthValid (ctx, fctx, sctx) et
                    return $ TWhile texp tt
                _ -> throwE $ "tycon mismatch " ++ show east
        ERet e ->
            let ret = fromMaybe (error "Cannot find return type") (Map.lookup "return type" ctx)
             in case e of
                    Just expr -> do
                        te <- synthType (ctx, fctx, sctx) expr
                        case te of
                            Just (VOID, _) -> throwE $ "Returning void must invoke return, not " ++ show e
                            Just (ANY, texp) -> case ret of
                                POINTER _ -> return $ TRet (Just texp)
                                _ -> throwE $ "Function return does not match with declared type" ++ show e
                            Just (typ, texp) -> do
                                assertMsg "Function return does not match with declared type" (typ == ret)
                                return $ TRet (Just texp)
                            Nothing -> throwE $ "tycon mismatch " ++ show expr
                    Nothing -> do
                        assertMsg "Function return does not match with declared type" (ret == VOID)
                        return $ TRet Nothing
        ENop -> return TNop
        EDecl fn typ@(ARROW args ret) et -> do
            let allSmall = all (\(_, t) -> isSmallType t) args
            assertMsg ("Function parameters must have small type: " ++ fn) allSmall
            assertMsg ("Return values must have small type: " ++ fn) (isSmallType ret)
            tt <- synthValid (ctx, Map.insert fn typ fctx, sctx) et
            return $ TDecl fn typ tt
        EDecl _x struct@(STRUCT _) _et -> throwE $ "Local variables must have small type: " ++ show struct
        EDecl x typ et ->
            if not (isTypeValid typ)
                then throwE ("Invalid type " ++ x ++ ":" ++ show typ)
                else case typ of
                         VOID -> throwE "Variable cannot be declared as void"
                         _ ->
                             case Map.lookup x ctx of
                                 Just _ -> throwE ("Variable already defined " ++ x)
                                 Nothing -> do
                                    tt <- synthValid (Map.insert x typ ctx, fctx, sctx) et
                                    return $ TDecl x typ tt
        ELeaf e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (typ, texp) -> do
                    assertMsg ("Expressions used as statements must have small type "  ++ show east) (isSmallType typ)
                    return $ TLeaf texp
                _ -> throwE ("tycon mismatch " ++ show e)
        EAssert e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (BOOLEAN, texp) -> return $ TAssert texp
                _ -> throwE $ "tycon mismatch " ++ show east
        EDef fn fnTyp@(ARROW args ret) et -> do
            let nctx =
                    foldr
                        (\(x, typ) m ->
                             if not (isTypeValid typ)
                                 then error ("Invalid type " ++ x ++ ":" ++ show typ)
                                 else case typ of
                                          VOID -> error "Function parameter cannot be VOID"
                                          _ -> Map.insert x typ m)
                        Map.empty
                        args
            tt <- synthValid (Map.insert "return type" ret nctx, fctx, sctx) et
            return $ TDef fn fnTyp tt
        ESDef s fields et -> do
            let fieldMap = Map.fromList fields
            assertMsg ("Duplicated field name in struct " ++ s) (length fields == length fieldMap)
            let allDefned = all (\(_fld, typ) -> case typ of
                    STRUCT st -> Map.member st sctx && st /= s
                    VOID -> False
                    _ -> isTypeValid typ) fields
            assertMsg ("Undefined struct " ++ s) allDefned
            tt <- synthValid (ctx, fctx, Map.insert s fieldMap sctx) et
            return $ TSDef s fields tt
            
             
synthType :: (Context, Context, StructCtx) -> EExp -> ExceptT String (State TypeCheckState) (Maybe (Type, TExp))
--synthType _ e | (trace $ "synthType " ++ show e) False = undefined
synthType (ctx, fctx, sctx) expr =
    case expr of
        ET -> return $ Just (BOOLEAN, TT)
        EF -> return $ Just (BOOLEAN, TT)
        ENULL -> return $ Just (ANY, TNULL)
        EInt x -> return $ Just (INTEGER, TInt x)
        EIdent x ->
            case Map.lookup x ctx of
                Just t -> return $ Just (t, TIdent x t)
                Nothing -> throwE $ "Variable used before declared " ++ x
        EBinop op e1 e2
            | op == Lt || op == Gt || op == Le || op == Ge -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                case (t1, t2) of
                    (Just (INTEGER, texp1), Just (INTEGER, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    _ -> throwE $ "tycon mismatch " ++ show expr
            | op == Eql || op == Neq -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                case (t1, t2) of
                    (Just (VOID, _), _) -> throwE $ "tycon mismatch " ++ show expr
                    (_, Just (VOID, _)) -> throwE $ "tycon mismatch " ++ show expr
                    (Just (STRUCT _, _), _) -> throwE $ "Cannot compare structs " ++ show expr
                    (_, Just (STRUCT _, _)) -> throwE $ "Cannot compare structs " ++ show expr
                    (Just (ANY, texp1), Just (POINTER _, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    (Just (POINTER _, texp1), Just (ANY, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    (Just (typ1, texp1), Just (typ2, texp2)) ->
                        if typ1 == typ2
                            then return $ Just (BOOLEAN, TBinop op texp1 texp2)
                            else throwE $ "tycon mismatch " ++ show expr
                    _ -> throwE $ "tycon mismatch " ++ show expr
            | op == LAnd || op == LOr -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                case (t1, t2) of
                    (Just (BOOLEAN, texp1), Just (BOOLEAN, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    _ -> throwE $ "tycon mismatch " ++ show expr
            | otherwise -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                case (t1, t2) of
                    (Just (INTEGER, texp1), Just (INTEGER, texp2)) -> return $ Just (INTEGER, TBinop op texp1 texp2)
                    _ -> throwE $ "tycon mismatch " ++ show expr
        EUnop LNot e -> do
            t <- synthType (ctx, fctx, sctx) e
            case t of
                Just (BOOLEAN, texp) -> return $ Just (BOOLEAN, TUnop LNot texp)
                _ -> throwE $ "tycon mismatch " ++ show expr
        EUnop op e -> do
            t <- synthType (ctx, fctx, sctx) e
            case t of
                Just (INTEGER, texp) -> return $ Just (INTEGER, TUnop op texp)
                _ -> throwE $ "tycon mismatch " ++ show expr
        ETernop e1 e2 e3 -> do
            t1 <- synthType (ctx, fctx, sctx) e1
            t2 <- synthType (ctx, fctx, sctx) e2
            t3 <- synthType (ctx, fctx, sctx) e3
            case (t1, t2, t3) of
                (Just (BOOLEAN, _), Just (STRUCT _, _), _) ->
                    throwE "Conditional expression has large type"
                (Just (BOOLEAN, _), _, Just (STRUCT _, _)) ->
                    throwE "Conditional expression has large type"
                (Just (BOOLEAN, texp1), Just (t, texp2), Just (t', texp3))
                    | t == VOID || t' == VOID -> throwE "Conditional expression has large type"
                    | t == ANY && isPointer t' -> return $ Just (t', TTernop texp1 texp2 texp3 t')
                    | isPointer t && t' == ANY -> return $ Just  (t, TTernop texp1 texp2 texp3 t)
                    | t == t' -> return $ Just  (t, TTernop texp1 texp2 texp3 t)
                    | otherwise -> throwE $ "tycon mismatch " ++ show expr
                _ -> throwE $ "tycon mismatch " ++ show expr
        EFunc fn args -> do
            let fnTyp = fromMaybe (error $ "Undefined function " ++ fn) (Map.lookup fn fctx)
            argTyp <- mapM (synthType (ctx, fctx, sctx)) args
            let (typeChecked, targs, retTyp) = checkArgTyp argTyp fnTyp
            assertMsg ("Function type mismatch" ++ fn) typeChecked
            return $! Just $! (retTyp, TFunc fn targs retTyp)
        EAlloc typ ->
            case typ of
                VOID -> throwE "Cannot allocate a void pointer in l4"
                STRUCT s -> case Map.lookup s sctx of
                    Just _ -> return $ Just (POINTER typ, TAlloc typ)
                    Nothing -> throwE $ "Cannot allocate an undefined struct " ++ show typ
                _ -> return $ Just (POINTER typ, TAlloc typ)
        EArrAlloc typ len -> do
            lenTyp <- synthType (ctx, fctx, sctx) len
            case lenTyp of
                Just (INTEGER, texp) -> case typ of
                    VOID -> throwE "Cannot allocate an array of void type"
                    STRUCT s -> case Map.lookup s sctx of
                        Just _ -> return $ Just (ARRAY typ, TArrAlloc typ texp)
                        Nothing -> throwE $ "Cannot allocate an array of an undefined struct " ++ show typ ++ "[]"
                    _ -> return $ Just (ARRAY typ, TArrAlloc typ texp)
                _ -> throwE $ "The second argument of array_alloc must have int type " ++ show expr
        EArrAccess e1 e2 -> do
            t1 <- synthType (ctx, fctx, sctx) e1
            t2 <- synthType (ctx, fctx, sctx) e2
            case (t1, t2) of
                (Just (ARRAY t, texp1), Just (INTEGER, texp2)) -> return $ Just (t, TArrAccess texp1 texp2 t)
                _ -> throwE $ "Tycon mismatch for array access " ++ show expr
        EField e fld -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (STRUCT st, texp) -> case Map.lookup st sctx of
                    Just fields -> return $ maybe Nothing (\t -> Just (t, TField texp fld t)) (Map.lookup fld fields)
                    Nothing -> throwE $ "Undeclared field " ++ fld ++ " in struct " ++ st
                _ -> throwE $ "Invalid field access " ++ show expr
        EDeref e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (ANY, _) -> throwE $ "Segmentation fault: attempting to dereference null pointer " ++ show expr
                Just (POINTER typ, texp) -> return $ Just (typ, TDeref texp typ)
                Just typ -> throwE $ "Cannot dereference a non-pointer " ++ show expr ++ ": " ++ show typ
                Nothing -> throwE $ "Tycon mismatch " ++ show expr
                
            
checkArgTyp :: [Maybe (Type, TExp)] -> Type -> (Bool, [TExp], Type)
--checkArgTyp arg arr | (trace $ "CheckArgTyp " ++ show arg ++ show arr) False = undefined
checkArgTyp argTyp (ARROW args ret)
    | length argTyp /= length args = error "Function type mismatch"
    | otherwise = 
        foldr (\(x, y) (err, texps, r) ->
            case x of
                Nothing -> (False, [], r)
                Just (VOID, _) -> (False, [], r)
                Just (ANY, texp) -> case snd y of
                    POINTER _ -> (err, texp : texps, r)
                    _ -> (False, [], r)
                Just (typ, texp) -> if typ == snd y then (err, texp : texps, r) else (False, [], r)) 
            (True, [], ret) 
            (zip argTyp args)
checkArgTyp _ _ = error "Invalid type"

isSmallType :: Type -> Bool
isSmallType (STRUCT _) = False
isSmallType _ = True

isTypeValid :: Type -> Bool
isTypeValid (ARRAY VOID) = False
isTypeValid (ARRAY t) = isTypeValid t
isTypeValid (POINTER VOID) = False
isTypeValid (POINTER t) = isTypeValid t
isTypeValid _ = True

isPointer :: Type -> Bool
isPointer (POINTER _) = True
isPointer _ = False

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