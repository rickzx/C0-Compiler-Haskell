module Compile.Frontend.CheckEAST where

import Control.Monad.State
import Control.Monad.Trans.Except
import Data.Maybe

import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Set as Set

import Compile.Types
import Debug.Trace

type TypeCheckState = (Set.Set Ident, Set.Set Ident) -- (Declared, Defined)

type PolyState
     = ( Set.Set Type
       , Map.Map Ident [Type]
       , Map.Map Ident (Set.Set (Map.Map Type Type))
       , Map.Map Ident [Type]
       , Map.Map Ident (Set.Set (Map.Map Type Type)))

type Context = Map.Map Ident Type

type StructCtx = Map.Map Ident Context

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True = return ()
assertMsg s False = throwE s

checkEAST :: EAST -> Header -> Either String (TAST, [(Ident, Map.Map Ident Type)])
--checkEAST e _ | (trace $ show e) False = undefined
checkEAST east header =
    case checkInitialize east of
        Left s -> Left s
        Right _ ->
            case checkValid east header of
                Left s' -> Left s'
                Right (tt, smap) -> Right (tt, map (\(k, v) -> (k, Map.fromList v)) (Map.toList smap))

checkInitialize :: EAST -> Either String Bool
-- (trace $ "EAST: " ++ show east ++ "\n")
checkInitialize east = evalState (runExceptT typeCheck) initialState
  where
    initialState = (Set.empty, Set.empty)
    typeCheck = checkInit east

checkValid :: EAST -> Header -> Either String (TAST, Map.Map Ident [(Ident, Type)])
checkValid east header = evalState (runExceptT (runCheckValid east Map.empty Map.empty Map.empty)) initialState
  where
    initialState = (Set.empty, Map.empty, Map.empty, Map.empty, Map.empty)
    runCheckValid et prev prevs smap = do
        tast <- synthValid (Map.empty, Map.insert "main" (ARROW [] INTEGER) (fnDecl header), structDef header) et
        (_, _, polym, _, polysm) <- get
        if polym == prev && polysm == prevs
            then return (tast, smap)
            else do
                put (Set.empty, Map.empty, Map.empty, Map.empty, Map.empty)
                let (et', smap') = substPoly et (Map.difference polym prev, Map.difference polysm prevs)
                runCheckValid et' polym polysm (Map.union smap smap')

checkUse :: EExp -> ExceptT String (State TypeCheckState) Bool
checkUse (EInt _) = return True
checkUse ET = return True
checkUse EF = return True
checkUse (EChar _) = return True
checkUse (EString _) = return True
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
checkUse (ERefFun fn) = return True
checkUse (ERefFunAp fn args) = do
    (_, defined) <- get
    checkAll <- mapM checkUse args
    return $ Set.member fn defined && and checkAll

extractLValue :: ELValue -> Set.Set Ident -> Maybe Ident
extractLValue (EVIdent x) s =
    if Set.member x s
        then Just x
        else Nothing
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
checkInit (ERet e) =
    case e of
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
            assertMsg ("Function " ++ fn ++ " does not have return") t
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
checkInit (EGDef _ fn (ARROW args ret) et) = do
    let ndecl = foldr (\x s -> Set.insert (fst x) s) Set.empty args
        ndef = foldr (\x s -> Set.insert (fst x) s) Set.empty args
    put (ndecl, ndef)
    t <- checkInit et
    case ret of
        VOID -> return True
        _ -> do
            assertMsg ("Function " ++ fn ++ " does not have return") t
            return t
checkInit (EGSDef _ _ _ et) = checkInit et
checkInit (EGDecl _ _ _ et) = checkInit et

synthLValType :: (Context, Context, StructCtx) -> ELValue -> ExceptT String (State PolyState) (Maybe (Type, TLValue))
synthLValType (ctx, _, _) (EVIdent x) = return $ maybe Nothing (\t -> Just (t, TVIdent x t)) (Map.lookup x ctx)
synthLValType (ctx, fctx, sctx) (EVField lval fld) = do
    (_, _, _, polys, _) <- get
    synth <- synthLValType (ctx, fctx, sctx) lval
    case synth of
        Nothing -> return Nothing
        Just (STRUCT s, tlval) ->
            case Map.lookup s sctx of
                Just ctx' -> return $ maybe Nothing (\t -> Just (t, TVField tlval fld t)) (Map.lookup fld ctx')
                Nothing -> return Nothing
        Just (GENSTRUCT ptyp s, tlval) ->
            case Map.lookup s sctx of
                Just ctx' ->
                    let ptyp' = fromMaybe (error "Undefined generic struct") (Map.lookup s polys)
                        polysm = foldr (\(t1, t2) m -> Map.insert t1 t2 m) Map.empty (zip ptyp' ptyp)
                     in return $
                        maybe
                            Nothing
                            (\t ->
                                 let t' = substPolyType t polysm
                                  in Just (t', TVField tlval fld t'))
                            (Map.lookup fld ctx')
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

synthValid :: (Context, Context, StructCtx) -> EAST -> ExceptT String (State PolyState) TAST
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
                        Just (GENSTRUCT _ _, _) -> throwE $ "Assignment must have small type " ++ show e
                        Just (ANY, texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (isPointer t)
                            return $ TAssign tlval texp b
                        Just (t', texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " : " ++ show t ++ " = " ++ show e ++ " : " ++ show t') (t == t')
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
                        Just (GENSTRUCT _ _, _) -> throwE $ "Assignment must have small type " ++ show e
                        Just (ANY, texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " = " ++ show e) (isPointer t)
                            return $ TPtrAssign tlval asop texp
                        Just (t', texp) -> do
                            assertMsg ("Tycon mismatch " ++ show lval ++ " : " ++ show t ++ " = " ++ show e ++ " : " ++ show t') (t == t')
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
                            Just (ANY, texp) ->
                                case ret of
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
                allValid = all (\(_, t) -> isTypeValid t || not (isVoid t)) args
            assertMsg ("Function parameters must have small type: " ++ fn) allSmall
            assertMsg ("Function parameters' type not valid: " ++ fn) allValid
            assertMsg ("Return values must have small type: " ++ fn) (isSmallType ret)
            let args' = map (\(nme, typ) -> (nme, substPolyStruct typ)) args
                ret' = substPolyStruct ret
            tt <- synthValid (ctx, Map.insert fn typ fctx, sctx) et
            return $ TDecl fn (ARROW args' ret') tt
        EDecl _x struct@(STRUCT _) _et -> throwE $ "Local variables must have small type: " ++ show struct
        EDecl _x struct@(GENSTRUCT _ _) _et -> throwE $ "Local variables must have small type: " ++ show struct
        EDecl x typ et ->
            if not (isTypeValid typ)
                then throwE ("Invalid type " ++ x ++ ":" ++ show typ)
                else case typ of
                         VOID -> throwE "Variable cannot be declared as void"
                         _ -> do
                             (currpoly, _, _, _, _) <- get
                             if Set.null currpoly
                                 then case Map.lookup x ctx of
                                          Just _ -> throwE ("Variable already defined " ++ x)
                                          Nothing -> do
                                              let typ' = substPolyStruct typ
                                              tt <- synthValid (Map.insert x typ ctx, fctx, sctx) et
                                              return $ TDecl x typ' tt
                                 else do
                                     let validPoly =
                                             foldr (\t flag -> flag && Set.member t currpoly) True (extractPoly typ)
                                     assertMsg "Poly type out of scope1" validPoly
                                     case Map.lookup x ctx of
                                         Just _ -> throwE ("Variable already defined " ++ x)
                                         Nothing -> do
                                             tt <- synthValid (Map.insert x typ ctx, fctx, sctx) et
                                             return $ TDecl x typ tt
        ELeaf e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (typ, texp) -> do
                    assertMsg ("Expressions used as statements must have small type " ++ show east) (isSmallType typ)
                    return $ TLeaf texp
                _ -> throwE ("tycon mismatch " ++ show e)
        EAssert e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (BOOLEAN, texp) -> return $ TAssert texp
                _ -> throwE $ "tycon mismatch " ++ show east
        EDef fn (ARROW args ret) et -> do
            let nctx = foldr (\(x, typ) m -> Map.insert x typ m) Map.empty args
                args' = map (\(nme, typ) -> (nme, substPolyStruct typ)) args
                ret' = substPolyStruct ret
            tt <- synthValid (Map.insert "return type" ret nctx, fctx, sctx) et
            return $ TDef fn (ARROW args' ret') tt
        ESDef s fields et -> do
            let fieldMap = Map.fromList fields
            assertMsg ("Duplicated field name in struct " ++ s) (length fields == length fieldMap)
            let allDefned =
                    all
                        (\(_fld, typ) ->
                             case typ of
                                 STRUCT st -> Map.member st sctx && st /= s
                                 GENSTRUCT _ st -> Map.member st sctx && st /= s
                                 VOID -> False
                                 _ -> isTypeValid typ)
                        fields
            assertMsg ("Undefined struct " ++ s) allDefned
            tt <- synthValid (ctx, fctx, Map.insert s fieldMap sctx) et
            return $ TSDef s fields tt
        EGDecl ptyps fn (ARROW args ret) et -> do
            let allSmall = all (\(_, t) -> isSmallType t) args
                allValid = all (\(_, t) -> isTypeValid t || not (isVoid t)) args
            assertMsg ("Function parameters must have small type: " ++ fn) allSmall
            assertMsg ("Function parameters' type not valid: " ++ fn) allValid
            assertMsg ("Return values must have small type: " ++ fn) (isSmallType ret)
            let polyArgs = foldr (\a s -> foldr Set.insert s (extractPoly (snd a))) Set.empty args
                polyDef = Set.fromList ptyps
                retValid = foldr (\a flag -> flag && Set.member a polyDef) True (extractPoly ret)
                polyValid = (length polyDef == length ptyps) && (polyDef == polyArgs) && retValid
            assertMsg ("Invalid generic function declaration: " ++ fn) polyValid
            (currpoly, polyfn, polydict, polys, polysdict) <- get
            put (currpoly, Map.insert fn ptyps polyfn, polydict, polys, polysdict)
            tt <- synthValid (ctx, Map.insert fn (ARROW args ret) fctx, sctx) et
            return $ TGDecl ptyps fn (ARROW args ret) tt
        EGDef ptyp fn (ARROW args ret) et -> do
            let nctx = foldr (\(x, typ) m -> Map.insert x typ m) Map.empty args
            (_, polyfn, polydict, polys, polysdict) <- get
            put (Set.fromList ptyp, polyfn, polydict, polys, polysdict)
            tt <- synthValid (Map.insert "return type" ret nctx, fctx, sctx) et
            (_, polyfn', polydict', polys', polysdict') <- get
            put (Set.empty, polyfn', polydict', polys', polysdict')
            return $ TGDef ptyp fn (ARROW args ret) tt
        EGSDef ptyp s fields et -> do
            let fieldMap = Map.fromList fields
            assertMsg ("Duplicated field name in struct " ++ s) (length fields == length fieldMap)
            let polyDef = Set.fromList ptyp
                allDefned =
                    all
                        (\(_fld, typ) ->
                             case typ of
                                 GENSTRUCT _ st -> Map.member st sctx && st /= s
                                 STRUCT st -> Map.member st sctx && st /= s
                                 VOID -> False
                                 _ -> isTypeValid typ)
                        fields
                polyValid = all (\(_fld, typ) -> all (`Set.member` polyDef) (extractPoly typ)) fields
            assertMsg ("Undefined struct " ++ s) allDefned
            assertMsg ("Invalid generic struct definition " ++ s) polyValid
            (currpoly, polyfn, polydict, polys, polysdict) <- get
            put (currpoly, polyfn, polydict, Map.insert s ptyp polys, polysdict)
            tt <- synthValid (ctx, fctx, Map.insert s fieldMap sctx) et
            return $ TGSDef ptyp s fields tt

synthType :: (Context, Context, StructCtx) -> EExp -> ExceptT String (State PolyState) (Maybe (Type, TExp))
--synthType _ e | (trace $ "synthType " ++ show e) False = undefined
synthType (ctx, fctx, sctx) expr =
    case expr of
        ET -> return $ Just (BOOLEAN, TT)
        EF -> return $ Just (BOOLEAN, TF)
        ENULL -> return $ Just (ANY, TNULL)
        EInt x -> return $ Just (INTEGER, TInt x)
        EChar x -> return $ Just (CHAR, TChar x)
        EString id -> return $ Just (STRING, TString id)
        EIdent x ->
            case Map.lookup x ctx of
                Just t -> return $ Just (t, TIdent x t)
                Nothing -> throwE $ "Variable used before declared " ++ x
        EBinop op e1 e2
            | op == Lt || op == Gt || op == Le || op == Ge -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                let bop =
                        case op of
                            Lt -> Ltb
                            Gt -> Gtb
                            Le -> Leb
                            Ge -> Geb
                case (t1, t2) of
                    (Just (INTEGER, texp1), Just (INTEGER, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    (Just (CHAR, texp1), Just (CHAR, texp2)) -> return $ Just (BOOLEAN, TBinop bop texp1 texp2)
                    _ -> throwE $ "tycon mismatch " ++ show expr
            | op == Eql || op == Neq -> do
                t1 <- synthType (ctx, fctx, sctx) e1
                t2 <- synthType (ctx, fctx, sctx) e2
                let lop =
                        case op of
                            Eql -> Eqlq
                            Neq -> Neqq
                    bop =
                        case op of
                            Eql -> Eqlb
                            Neq -> Neqb
                case (t1, t2) of
                    (Just (VOID, _), _) -> throwE $ "tycon mismatch " ++ show expr
                    (_, Just (VOID, _)) -> throwE $ "tycon mismatch " ++ show expr
                    (Just (STRUCT _, _), _) -> throwE $ "Cannot compare structs " ++ show expr
                    (_, Just (STRUCT _, _)) -> throwE $ "Cannot compare structs " ++ show expr
                    (Just (GENSTRUCT {}, _), _) -> throwE $ "Cannot compare structs " ++ show expr
                    (_, Just (GENSTRUCT {}, _)) -> throwE $ "Cannot compare structs " ++ show expr
                    (Just (ANY, texp1), Just (POINTER _, texp2)) -> return $ Just (BOOLEAN, TBinop lop texp1 texp2)
                    (Just (POINTER _, texp1), Just (ANY, texp2)) -> return $ Just (BOOLEAN, TBinop lop texp1 texp2)
                    (Just (INTEGER, texp1), Just (INTEGER, texp2)) -> return $ Just (BOOLEAN, TBinop op texp1 texp2)
                    (Just (BOOLEAN, texp1), Just (BOOLEAN, texp2)) -> return $ Just (BOOLEAN, TBinop bop texp1 texp2)
                    (Just (CHAR, texp1), Just (CHAR, texp2)) -> return $ Just (BOOLEAN, TBinop bop texp1 texp2)
                    (Just (STRING, _), _) -> throwE $ "Use string compare for strings " ++ show expr
                    (_, Just (STRING, _)) -> throwE $ "Use string compare for strings " ++ show expr
                    (Just (typ1, texp1), Just (typ2, texp2)) ->
                        if typ1 == typ2
                            then return $ Just (BOOLEAN, TBinop lop texp1 texp2)
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
                (Just (BOOLEAN, _), Just (STRUCT _, _), _) -> throwE "Conditional expression has large type"
                (Just (BOOLEAN, _), _, Just (STRUCT _, _)) -> throwE "Conditional expression has large type"
                (Just (BOOLEAN, _), Just (GENSTRUCT _ _, _), _) -> throwE "Conditional expression has large type"
                (Just (BOOLEAN, _), _, Just (GENSTRUCT _ _, _)) -> throwE "Conditional expression has large type"
                (Just (BOOLEAN, texp1), Just (t, texp2), Just (t', texp3))
                    | t == VOID || t' == VOID -> throwE "Conditional expression has large type"
                    | t == ANY && isPointer t' -> return $ Just (t', TTernop texp1 texp2 texp3)
                    | isPointer t && t' == ANY -> return $ Just (t, TTernop texp1 texp2 texp3)
                    | t == t' -> return $ Just (t, TTernop texp1 texp2 texp3)
                    | otherwise -> throwE $ "tycon mismatch " ++ show expr
                _ -> throwE $ "tycon mismatch " ++ show expr
        EFunc fn args -> do
            let fnTyp = fromMaybe (error $ "Undefined function " ++ fn) (Map.lookup fn fctx)
            argTyp <- mapM (synthType (ctx, fctx, sctx)) args
            let (typeChecked, targs, rtp) = checkArgTyp argTyp fnTyp
            assertMsg ("Function type mismatch " ++ fn) typeChecked
            (currpoly, polyfn, polydict, polys, polysdict) <- get
            if not (Map.member fn polyfn)
                then return $! Just $! (rtp, TFunc fn targs rtp)
                else do
                    let ARROW at rt = fnTyp
                        polym =
                            foldr
                                (\(aa, fa) m ->
                                     case aa of
                                         Just (t, _) -> foldr (\(k, v) m' -> Map.insert k v m') m (polyMatch fa t)
                                         Nothing -> error "Invalid type-check state")
                                Map.empty
                                (zip argTyp (map snd at))
                        retTyp = substPolyType rt polym
                    if Set.null currpoly
                        then do
                            let npolydict =
                                    case Map.lookup fn polydict of
                                        Just s -> Map.insert fn (Set.insert polym s) polydict
                                        Nothing -> Map.insert fn (Set.singleton polym) polydict
                                suff =
                                    foldl
                                        (\s t ->
                                             s ++ "_" ++ compactShow (fromMaybe (error "Generic error") (Map.lookup t polym)))
                                        ""
                                        (polyfn Map.! fn)
                                nfn = "'" ++ fn ++ suff
                            put (currpoly, polyfn, npolydict, polys, polysdict)
                            return $! Just $! (retTyp, TFunc nfn targs retTyp)
                        else return $! Just $! (retTyp, TFunc fn targs retTyp)
        EAlloc typ -> do
            (currpoly, polyfn, polydict, polys, polysdict) <- get
            let validPoly = foldr (\t flag -> flag && Set.member t currpoly) True (extractPoly typ)
            assertMsg "Poly type out of scope2" validPoly
            case typ of
                VOID -> throwE "Cannot allocate a void pointer in l4"
                GENSTRUCT ptyp s ->
                    case Map.lookup s sctx of
                        Just _ ->
                            case Map.lookup s polys of
                                Just ptyp' ->
                                    if Set.null currpoly
                                        then do
                                            let suff = foldl (\nme t -> nme ++ "_" ++ compactShow t) "" ptyp
                                                ntyp = STRUCT ("'" ++ s ++ suff)
                                                polysm =
                                                    foldr (\(t1, t2) m -> Map.insert t1 t2 m) Map.empty (zip ptyp' ptyp)
                                                npolysdict =
                                                    case Map.lookup s polysdict of
                                                        Just ss -> Map.insert s (Set.insert polysm ss) polysdict
                                                        Nothing -> Map.insert s (Set.singleton polysm) polysdict
                                            put (currpoly, polyfn, polydict, polys, npolysdict)
                                            return $ Just (POINTER typ, TAlloc ntyp)
                                        else return $ Just (POINTER typ, TAlloc typ)
                                Nothing -> throwE $ "Invalid use of generic struct: " ++ show expr
                        Nothing -> throwE $ "Cannot allocate an array of an undefined struct " ++ show typ ++ "[]"
                STRUCT s ->
                    case Map.lookup s sctx of
                        Just _ -> return $ Just (POINTER typ, TAlloc typ)
                        Nothing -> throwE $ "Cannot allocate an undefined struct " ++ show typ
                _ -> return $ Just (POINTER typ, TAlloc typ)
        EArrAlloc typ len -> do
            (currpoly, polyfn, polydict, polys, polysdict) <- get
            let validPoly = foldr (\t flag -> flag && Set.member t currpoly) True (extractPoly typ)
            assertMsg "Poly type out of scope3" validPoly
            lenTyp <- synthType (ctx, fctx, sctx) len
            case lenTyp of
                Just (INTEGER, texp) ->
                    case typ of
                        VOID -> throwE "Cannot allocate an array of void type"
                        GENSTRUCT ptyp s ->
                            case Map.lookup s sctx of
                                Just _ ->
                                    case Map.lookup s polys of
                                        Just ptyp' ->
                                            if Set.null currpoly
                                                then do
                                                    let suff = foldl (\nme t -> nme ++ "_" ++ compactShow t) "" ptyp
                                                        ntyp = STRUCT ("'" ++ s ++ suff)
                                                        polysm =
                                                            foldr
                                                                (\(t1, t2) m -> Map.insert t1 t2 m)
                                                                Map.empty
                                                                (zip ptyp' ptyp)
                                                        npolysdict =
                                                            case Map.lookup s polysdict of
                                                                Just ss -> Map.insert s (Set.insert polysm ss) polysdict
                                                                Nothing -> Map.insert s (Set.singleton polysm) polysdict
                                                    put (currpoly, polyfn, polydict, polys, npolysdict)
                                                    return $ Just (ARRAY typ, TArrAlloc ntyp texp)
                                                else return $ Just (ARRAY typ, TArrAlloc typ texp)
                                        Nothing -> throwE $ "Invalid use of generic struct: " ++ show expr
                                Nothing ->
                                    throwE $ "Cannot allocate an array of an undefined struct " ++ show typ ++ "[]"
                        STRUCT s ->
                            case Map.lookup s sctx of
                                Just _ -> return $ Just (ARRAY typ, TArrAlloc typ texp)
                                Nothing ->
                                    throwE $ "Cannot allocate an array of an undefined struct " ++ show typ ++ "[]"
                        _ -> return $ Just (ARRAY typ, TArrAlloc typ texp)
                _ -> throwE $ "The second argument of array_alloc must have int type " ++ show expr
        EArrAccess e1 e2 -> do
            t1 <- synthType (ctx, fctx, sctx) e1
            t2 <- synthType (ctx, fctx, sctx) e2
            case (t1, t2) of
                (Just (ARRAY t, texp1), Just (INTEGER, texp2)) -> return $ Just (t, TArrAccess texp1 texp2 t)
                _ -> throwE $ "Tycon mismatch for array access " ++ show expr
        EField e fld -> do
            (_, _, _, polys, _) <- get
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (STRUCT st, texp) ->
                    case Map.lookup st sctx of
                        Just fields ->
                            return $ maybe Nothing (\t -> Just (t, TField texp fld t)) (Map.lookup fld fields)
                        Nothing -> throwE $ "Undeclared field " ++ fld ++ " in struct " ++ st
                Just (GENSTRUCT ptyp st, texp) ->
                    case Map.lookup st sctx of
                        Just fields ->
                            let ptyp' = fromMaybe (error "Undefined generic struct") (Map.lookup st polys)
                                polysm = foldr (\(t1, t2) m -> Map.insert t1 t2 m) Map.empty (zip ptyp' ptyp)
                             in return $
                                maybe
                                    Nothing
                                    (\t ->
                                         let t' = substPolyType t polysm
                                          in Just (t', TField texp fld t'))
                                    (Map.lookup fld fields)
                        Nothing -> throwE $ "Undeclared field " ++ fld ++ " in struct " ++ st
                _ -> throwE $ "Invalid field access " ++ show expr
        EDeref e -> do
            te <- synthType (ctx, fctx, sctx) e
            case te of
                Just (ANY, _) -> throwE $ "Segmentation fault: attempting to dereference null pointer " ++ show expr
                Just (POINTER typ, texp) -> return $ Just (typ, TDeref texp typ)
                Just typ -> throwE $ "Cannot dereference a non-pointer " ++ show expr ++ ": " ++ show typ
                Nothing -> throwE $ "Tycon mismatch " ++ show expr
        ERefFun fn -> do
            (_, polyfn, _, _, _) <- get
            if Map.member fn polyfn
                then error "Pointer to generic function not supported"
                else do
                    let ARROW args ret = fromMaybe (error $ "Undefined function " ++ fn) (Map.lookup fn fctx)
                    return $ Just (FUNPTR (map snd args) ret, TRefFun fn)
        ERefFunAp fn args ->
            case Map.lookup fn ctx of
                Just (FUNPTR a r) -> do
                    argTyp <- mapM (synthType (ctx, fctx, sctx)) args
                    let (typeChecked, targs, rtp) = checkArgTyp argTyp (ARROW (map (\t -> ("", t)) a) r)
                    assertMsg ("Function type mismatch " ++ fn) typeChecked
                    return $! Just $! (rtp, TRefFunAp fn targs rtp)
                _ -> throwE $ "Variable used before declared " ++ fn

checkArgTyp :: [Maybe (Type, TExp)] -> Type -> (Bool, [TExp], Type)
--checkArgTyp arg arr | (trace $ "CheckArgTyp " ++ show arg ++ show arr) False = undefined
checkArgTyp argTyp (ARROW args ret)
    | length argTyp /= length args = error "Function type mismatch"
    | otherwise =
        foldr
            (\(x, y) (err, texps, r) ->
                 case x of
                     Nothing -> (False, [], r)
                     Just (VOID, _) -> (False, [], r)
                     Just (ANY, texp) ->
                         case snd y of
                             POINTER _ -> (err, texp : texps, r)
                             FUNPTR _ _ -> (err, texp : texps, r)
                             _ -> (False, [], r)
                     Just (typ, texp) ->
                         if typeMatch (snd y) typ
                             then (err, texp : texps, r)
                             else (False, [], r))
            (True, [], ret)
            (zip argTyp args)
checkArgTyp _ _ = error "Invalid type"

isSmallType :: Type -> Bool
isSmallType (STRUCT _) = False
isSmallType (GENSTRUCT _ _) = False
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

typeMatch :: Type -> Type -> Bool
typeMatch (POLY _) _ = True
typeMatch (POINTER t1) (POINTER t2) = typeMatch t1 t2
typeMatch (ARRAY t1) (ARRAY t2) = typeMatch t1 t2
typeMatch (GENSTRUCT ptyp1 _) (GENSTRUCT ptyp2 _) = all (uncurry typeMatch) (zip ptyp1 ptyp2)
typeMatch (FUNPTR arg1 ret1) (FUNPTR arg2 ret2) = all (uncurry typeMatch) (zip arg1 arg2) && typeMatch ret1 ret2
typeMatch t1 t2 = t1 == t2

isVoid :: Type -> Bool
isVoid VOID = True
isVoid _ = False

extractPoly :: Type -> [Type]
extractPoly (POLY u) = [POLY u]
extractPoly (POINTER ptr) = extractPoly ptr
extractPoly (ARRAY typ) = extractPoly typ
extractPoly (GENSTRUCT ptyp _) = concatMap extractPoly ptyp
extractPoly (FUNPTR arg ret) = concatMap extractPoly arg ++ extractPoly ret
extractPoly _ = []

polyMatch :: Type -> Type -> [(Type, Type)]
polyMatch (POLY u) typ = [(POLY u, typ)]
polyMatch (POINTER t1) (POINTER t2) = polyMatch t1 t2
polyMatch (ARRAY t1) (ARRAY t2) = polyMatch t1 t2
polyMatch (GENSTRUCT ptyp1 _) (GENSTRUCT ptyp2 _) = foldr (\(t1, t2) l -> polyMatch t1 t2 ++ l) [] (zip ptyp1 ptyp2)
polyMatch (FUNPTR arg1 ret1) (FUNPTR arg2 ret2) =
    foldr (\(t1, t2) l -> polyMatch t1 t2 ++ l) [] (zip arg1 arg2) ++ polyMatch ret1 ret2
polyMatch _ _ = []

substPolyType :: Type -> Map.Map Type Type -> Type
substPolyType (POLY u) polym = fromMaybe (error $ "Invalid poly type: " ++ u) (Map.lookup (POLY u) polym)
substPolyType (POINTER ptr) polym = POINTER (substPolyType ptr polym)
substPolyType (ARRAY typ) polym = ARRAY (substPolyType typ polym)
substPolyType (GENSTRUCT ptyp struct) polym = GENSTRUCT (map (`substPolyType` polym) ptyp) struct
substPolyType (FUNPTR arg ret) polym = FUNPTR (map (`substPolyType` polym) arg) (substPolyType ret polym)
substPolyType t _ = t

substPolyStruct :: Type -> Type
substPolyStruct (POINTER ptr) = POINTER (substPolyStruct ptr)
substPolyStruct (ARRAY typ) = ARRAY (substPolyStruct typ)
substPolyStruct (GENSTRUCT ptyp struct) =
    let suff = foldl (\s t -> s ++ "_" ++ compactShow t) "" ptyp
     in STRUCT ("'" ++ struct ++ suff)
substPolyStruct t = t

substExp :: EExp -> Map.Map Type Type -> EExp
substExp expr substm =
    case expr of
        EIdent x -> EIdent x
        EBinop op e1 e2 -> EBinop op (substExp e1 substm) (substExp e2 substm)
        ETernop e1 e2 e3 -> ETernop (substExp e1 substm) (substExp e2 substm) (substExp e3 substm)
        EUnop op e -> EUnop op (substExp e substm)
        EFunc fn args -> EFunc fn (map (`substExp` substm) args)
        EAlloc typ -> EAlloc (substPolyType typ substm)
        EArrAlloc typ e -> EArrAlloc (substPolyType typ substm) (substExp e substm)
        EArrAccess e1 e2 -> EArrAccess (substExp e1 substm) (substExp e2 substm)
        EField e f -> EField (substExp e substm) f
        EDeref e -> EDeref (substExp e substm)
        _ -> expr

substLVal :: ELValue -> Map.Map Type Type -> ELValue
substLVal lval substm =
    case lval of
        EVIdent x -> EVIdent x
        EVField lv f -> EVField (substLVal lv substm) f
        EVDeref lv -> EVDeref (substLVal lv substm)
        EVArrAccess lv e -> EVArrAccess (substLVal lv substm) (substExp e substm)

substFun :: EAST -> Map.Map Type Type -> EAST
substFun tast substm =
    case tast of
        ESeq et1 et2 -> ESeq (substFun et1 substm) (substFun et2 substm)
        EAssign lv e b -> EAssign (substLVal lv substm) (substExp e substm) b
        EPtrAssign lv anop e -> EPtrAssign (substLVal lv substm) anop (substExp e substm)
        EIf e et1 et2 -> EIf (substExp e substm) (substFun et1 substm) (substFun et2 substm)
        EWhile e et -> EWhile (substExp e substm) (substFun et substm)
        EAssert e -> EAssert (substExp e substm)
        ERet me ->
            case me of
                Just e -> ERet (Just (substExp e substm))
                Nothing -> ERet Nothing
        ENop -> ENop
        EDecl x typ et -> EDecl x (substPolyType typ substm) (substFun et substm)
        ELeaf e -> ELeaf (substExp e substm)
        _ -> error "Invalid polymorphic substitution"

substGDecl :: EAST -> [Map.Map Type Type] -> EAST
substGDecl (EGDecl ptyp fn ftyps et) [] = (EGDecl ptyp fn ftyps et)
substGDecl poly@(EGDecl ptyp fn ftyps et) (x:xs) =
    let ARROW at rt = ftyps
        at' = foldr (\(nme, t) l -> (nme, substPolyType t x) : l) [] at
        rt' = substPolyType rt x
        suff = foldl (\s t -> s ++ "_" ++ compactShow (fromMaybe (error "Generic error") (Map.lookup t x))) "" ptyp
        nfn = "'" ++ fn ++ suff
     in EDecl nfn (ARROW at' rt') (substGDecl poly xs)

substGDef :: EAST -> [Map.Map Type Type] -> EAST
substGDef (EGDef ptyp fn ftyps et) [] = EGDef ptyp fn ftyps et
substGDef poly@(EGDef ptyp fn ftyps et) (x:xs) =
    let ARROW at rt = ftyps
        at' = foldr (\(nme, t) l -> (nme, substPolyType t x) : l) [] at
        rt' = substPolyType rt x
        suff = foldl (\s t -> s ++ "_" ++ compactShow (fromMaybe (error "Generic error") (Map.lookup t x))) "" ptyp
        nfn = "'" ++ fn ++ suff
     in ESeq (EDef nfn (ARROW at' rt') (substFun et x)) (substGDef poly xs)

substGSDef :: EAST -> [Map.Map Type Type] -> (EAST, Map.Map Ident [(Ident, Type)])
substGSDef (EGSDef ptyp struct flds et) [] = (EGSDef ptyp struct flds et, Map.empty)
substGSDef poly@(EGSDef ptyp struct flds et) (x:xs) =
    let nflds = foldr (\(nme, t) l -> (nme, substPolyType t x) : l) [] flds
        suff = foldl (\s t -> s ++ "_" ++ compactShow (fromMaybe (error "Generic struct error") (Map.lookup t x))) "" ptyp
        nstruct = "'" ++ struct ++ suff
        (cont, smap) = substGSDef poly xs
     in (ESDef nstruct nflds cont, Map.insert nstruct nflds smap)

substPoly :: EAST -> (Map.Map Ident (Set.Set (Map.Map Type Type)), Map.Map Ident (Set.Set (Map.Map Type Type))) -> (EAST, Map.Map Ident [(Ident, Type)])
substPoly (EGDecl ptyp fn ftyps et) (polym, polysm) =
    case Map.lookup fn polym of
        Just s ->
            let (cont, smap) = substPoly et (polym, polysm)
             in (substGDecl (EGDecl ptyp fn ftyps cont) (Set.toList s), smap)
        Nothing ->
            let (cont, smap) = substPoly et (polym, polysm)
            in (EGDecl ptyp fn ftyps cont, smap)
substPoly gdef@(EGDef ptyp fn ftyps et) (polym, polysm) =
    case Map.lookup fn polym of
        Just s -> (substGDef gdef (Set.toList s), Map.empty)
        Nothing -> (EGDef ptyp fn ftyps et, Map.empty)
substPoly (ESeq et1 et2) (polym, polysm) =
    let
        (cont1, smap1) = substPoly et1 (polym, polysm)
        (cont2, smap2) = substPoly et2 (polym, polysm)
    in (ESeq cont1 cont2, Map.union smap1 smap2)
substPoly (EDecl fn ftyps et) (polym, polysm) =
    let (cont, smap) = substPoly et (polym, polysm)
    in (EDecl fn ftyps cont, smap)
substPoly (EDef fn ftyps et) _ = (EDef fn ftyps et, Map.empty)
substPoly (ESDef s flds et) (polym, polysm) =
    let (cont, smap) = substPoly et (polym, polysm)
    in (ESDef s flds cont, smap)
substPoly (EGSDef ptyp s flds et) (polym, polysm) =
    case Map.lookup s polysm of
        Just ss ->
            let (cont, smap) = substPoly et (polym, polysm)
                (et', smap') = substGSDef (EGSDef ptyp s flds cont) (Set.toList ss)
             in (et', Map.union smap smap')
        Nothing ->
            let (cont, smap) = substPoly et (polym, polysm)
            in (EGSDef ptyp s flds cont, smap)
substPoly ENop _ = (ENop, Map.empty)
substPoly tt _ = error $ "Invalid top-level TAST: " ++ show tt

compactShow :: Type -> String
compactShow INTEGER = "int"
compactShow BOOLEAN = "bool"
compactShow VOID = "void"
compactShow CHAR = "char"
compactShow STRING = "string"
compactShow ANY = "NULL"
compactShow (ARROW args res) = show args ++ "_arrow_" ++ show res
compactShow (FUNPTR args res) = filter (\c -> c /= '[' && c /= ']' && c /= ',') (show args ++ "_arrow_" ++ show res)
compactShow (DEF a) = "def " ++ a
compactShow (ARRAY a) = compactShow a ++ "_arr"
compactShow (POINTER a) = compactShow a ++ "_ptr"
compactShow (STRUCT a) = "STRUCT" ++ a
compactShow (POLY a) = "\'" ++ a
compactShow (GENSTRUCT gentypes nme) = filter (\c -> c /= '[' && c /= ']' && c /= ',') $ "STRUCT" ++ show gentypes ++ "" ++ nme