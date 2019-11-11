module Compile.Backend.TAST2AAsm where

import Compile.Types
import Control.Monad
import qualified Control.Monad.State.Strict as State
import Data.Int
import qualified Data.Map as Map
import Debug.Trace

-- | The state during code generation.
data CodeGenState =
    CodeGenState
        { variables :: Map.Map String Int
    -- ^ Map from source variable names to unique variable ids.
        , uniqueIDCounter :: Int
    -- ^ Value greater than any id in the map.
        , uniqueLabelCounter :: Int
    -- ^ Next label to generate.
        , genFunctions :: [(Ident, ([AAsm], Int))]
    -- ^ generated AASM for each function (funcname, (AASM, #vars used))
        , currentFunction :: String
    -- ^ current function we are in
        , structInfo :: StructInfo
        , unsafeflag :: Bool 
        } deriving Show

-- Using the state monad with CodeGenState as the state allows us to implicitly
-- thread the variable map and the next unique ID through the entire
-- computation. (The M in CodeGenStateM stands for "Monad".)
type CodeGenStateM = State.State CodeGenState

type StructInfo = Map.Map Ident (Int, Int, Map.Map Ident (Int, Int)) -- (Struct size, Struct alignment constraint, Map : field -> (offset, size))

getNewUniqueID :: CodeGenStateM Int
getNewUniqueID = do
    currentCount <- State.gets uniqueIDCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf si us) -> CodeGenState vs (counter + 1) lab genf cf si us
    return currentCount

getNewUniqueLabel :: CodeGenStateM String
getNewUniqueLabel = do
    currentCount <- State.gets uniqueLabelCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf si us) -> CodeGenState vs counter (lab + 1) genf cf si us
    let lab = "L" ++ show currentCount
    return lab

--for each term, (function name, AASM generated, # of var)
aasmGen :: TAST -> [(Ident, Map.Map Ident Type)] -> Bool -> [(Ident, ([AAsm], Int))]
aasmGen tast structs unsafe = State.evalState assemM initialState
  where
    initialState =
        CodeGenState
            { variables = Map.empty
            , uniqueIDCounter = 0
            , uniqueLabelCounter = 0
            , genFunctions = []
            , currentFunction = ""
            , structInfo = buildStructInfo structs
            , unsafeflag = unsafe
            }
    assemM :: CodeGenStateM [(Ident, ([AAsm], Int))]
    assemM = do
        _genAAsm <- genTast tast
        CodeGenState _ _ _ genf _ _ _<- State.get
        return (reverse genf)

buildStructInfo :: [(Ident, Map.Map Ident Type)] -> StructInfo
buildStructInfo =
    foldr
        (\(snme, fields) sinfo ->
             let (size, maxsize, offsets) = buildStruct fields sinfo
                 size' =
                     if maxsize == 0 || mod size maxsize == 0
                         then size
                         else size + maxsize - mod size maxsize
              in Map.insert snme (size', maxsize, offsets) sinfo)
        Map.empty
  where
    buildStruct :: Map.Map Ident Type -> StructInfo -> (Int, Int, Map.Map Ident (Int, Int))
    buildStruct fields sinfo =
        Map.foldrWithKey
            (\fnme ftyp (size, maxsize, offsets) ->
                 let (fsize, falign) =
                         case ftyp of
                             INTEGER -> (4, 4)
                             BOOLEAN -> (4, 4)
                             POINTER _ -> (8, 8)
                             ARRAY _ -> (8, 8)
                             STRUCT s ->
                                 case Map.lookup s sinfo of
                                     Just (ssize, salign, _) -> (ssize, salign)
                                     Nothing -> error "Malformed struct. Check the implementation of type-checker."
                             _ -> error $ "Malformed struct. Check the implementation of type-checker " ++ show ftyp
                     offset =
                         if falign == 0 || mod size falign == 0
                             then size
                             else size + falign - mod size falign
                  in (offset + fsize, max maxsize falign, Map.insert fnme (offset, fsize) offsets))
            (0, 0, Map.empty)
            fields

-- Get the decls from a sequence of stmts.
getDecls :: TAST -> [Ident]
getDecls (TSeq e1 e2) = getDecls e1 ++ getDecls e2
getDecls (TIf _ e1 e2) = getDecls e1 ++ getDecls e2
getDecls (TWhile _ e) = getDecls e
getDecls (TDecl x _ e) = x : getDecls e
getDecls _ = []

genTast :: TAST -> CodeGenStateM [AAsm]
genTast (TSeq e1 e2) = do
    gen1 <- genTast e1
    gen2 <- genTast e2
    return $ gen1 ++ gen2
genTast (TAssign (TVIdent x _) expr _b) = do
    allocMap <- State.gets variables
    let tmpNum = ATemp $ allocMap Map.! x
    genExp expr tmpNum
genTast (TAssign lv expr _b) = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    sinfo <- State.gets structInfo
    lvgen <- genAddr (toTExp lv) (ATemp n) sinfo
    gen <- genExp expr (ATemp n')
    nullcheck <- checkNull (ATemp n)
    if findSize (typeOfLVal lv) sinfo == 4 then
        return $ lvgen ++ gen ++ nullcheck ++ [AAsm [APtr $ ATemp n] ANop [ALoc $ ATemp n']]
        else
            return $ lvgen ++ gen ++ nullcheck ++ [AAsm [APtrq $ ATemp n] ANopq [ALoc $ ATemp n']]
genTast (TPtrAssign (TVIdent x typ) (AsnOp b) e) = do
    allocMap <- State.gets variables
    let tmpNum = ATemp $ allocMap Map.! x
    genExp (TBinop b (TIdent x typ) e) tmpNum
genTast (TPtrAssign lv (AsnOp b) e) = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    n'' <- getNewUniqueID
    sinfo <- State.gets structInfo
    lvgen <- genAddr (toTExp lv) (ATemp n) sinfo
    asgnmnt <- genExp e (ATemp n')
    nullchk <- checkNull (ATemp n)
    unsafe <- State.gets unsafeflag
    shiftcheck <- case (b, unsafe) of
        (Sal, False) -> do
            n2 <- getNewUniqueID
            n3 <- getNewUniqueID
            l1 <- getNewUniqueLabel
            l2 <- getNewUniqueLabel
            l3 <- getNewUniqueLabel
            let
                checker = [
                    ARel [ATemp n2] (genRelOp Ge) [ALoc $ ATemp n', AImm 0],
                    ARel [ATemp n3] (genRelOp Lt) [ALoc $ ATemp n', AImm 32],
                    AControl $ ACJump (ALoc $ ATemp n2) l1 l2,
                    AControl $ ALab l1,
                    AControl $ ACJump (ALoc $ ATemp n3) l3 l2,
                    AControl $ ALab l2
                    ]
            failure <- genExp (TBinop Div (TInt 1) (TInt 0)) (APtr $ ATemp n)
            return $ checker ++ failure ++ [AControl $ ALab l3]
        (Sar, False) -> do
            n2 <- getNewUniqueID
            n3 <- getNewUniqueID
            l1 <- getNewUniqueLabel
            l2 <- getNewUniqueLabel
            l3 <- getNewUniqueLabel
            let
                checker = [
                    ARel [ATemp n2] (genRelOp Ge) [ALoc $ ATemp n', AImm 0],
                    ARel [ATemp n3] (genRelOp Lt) [ALoc $ ATemp n', AImm 32],
                    AControl $ ACJump (ALoc $ ATemp n2) l1 l2,
                    AControl $ ALab l1,
                    AControl $ ACJump (ALoc $ ATemp n3) l3 l2,
                    AControl $ ALab l2
                    ]
            failure <- genExp (TBinop Div (TInt 1) (TInt 0)) (APtr $ ATemp n)
            return $ checker ++ failure ++ [AControl $ ALab l3]
        _ -> return []
    let performOp = [AAsm [ATemp n''] (genBinOp b) [ALoc $ APtr $ ATemp n, ALoc $ ATemp n']]
    if findSize (typeOfLVal lv) sinfo == 4 then
        return $ lvgen ++ asgnmnt ++ nullchk ++ shiftcheck ++ performOp ++ [AAsm [APtr $ ATemp n] ANop [ALoc $ ATemp n'']]
        else
            return $ lvgen ++ asgnmnt ++ nullchk ++ shiftcheck ++ performOp ++ [AAsm [APtr $ ATemp n] ANopq [ALoc $ ATemp n'']]
genTast (TDef fn t e) = do
    let ARROW ts _r = t
        args = map fst ts
        decls = args ++ getDecls e
        v' = Map.fromList $ zip decls [0 ..]
    State.modify' $ \(CodeGenState _vs _counter lab genf _cf si us) -> CodeGenState v' (length decls) lab genf fn si us
    let (inReg, inStk) = splitAt 6 (map (\a -> ATemp $ v' Map.! a) args)
        movArg = map (\(i, tmp) -> AAsm [tmp] ANopq [ALoc $ argRegs !! i]) $ zip [0 ..] inReg
    gen <- genTast e
    let funGen = [AFun fn inStk] ++ movArg ++ gen
    State.modify' $ \(CodeGenState vs counter lab genf cf si us) ->
        CodeGenState vs counter lab ((fn, (funGen, counter)) : genf) cf si us
    return funGen
genTast (TAssert expr) = do
    let trans = TIf expr TNop (TLeaf $ TFunc "abort" [] VOID)
    genTast trans
genTast (TIf TT e1 _e2) = genTast e1
genTast (TIf TF _e1 e2) = genTast e2
genTast (TIf expr e1 e2) = do
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    l3 <- getNewUniqueLabel
    cmp <- genCmp expr l1 l2
    gen1 <- genTast e1
    gen2 <- genTast e2
    return $
        cmp ++
        [AControl $ ALab l1] ++
        gen1 ++ [AControl $ AJump l3, AControl $ ALab l2] ++ gen2 ++ [AControl $ AJump l3, AControl $ ALab l3]
genTast (TWhile expr e) = do
    l1 <- getNewUniqueLabel -- label before while guard
    l2 <- getNewUniqueLabel -- label of the while block
    l3 <- getNewUniqueLabel -- label after while block
    cmp <- genCmp expr l2 l3
    gen <- genTast e
    return $ [AControl $ ALab l1] ++ cmp ++ [AControl $ ALab l2] ++ gen ++ [AControl $ AJump l1, 
        AControl $ ALab l3]
-- --change while loops into a repeat loop
-- genTast (TWhile expr e) = do
--     l1 <- getNewUniqueLabel -- label before while guard
--     l2 <- getNewUniqueLabel -- label of the while block
--     l3 <- getNewUniqueLabel -- label after while block
--     cmp <- genCmp expr l1 l2
--     gen <- genTast e
--     return $ cmp ++ [AControl $ ALab l1] ++ gen ++ cmp ++ [AControl $ ALab l2]
genTast (TRet expr) = do
    fn <- State.gets currentFunction
    let fname =
            if fn == "a bort"
                then "_c0_abort_local411"
                else "_c0_" ++ fn
    case expr of
        Just e@(TFunc fun args _tp) -> if fun == fn then do
                let argLen = length args
                ids <- replicateM argLen getNewUniqueID
                let tmpVars = map ATemp ids
                gens <- mapM (\(i, ex) -> genExp ex (tmpVars !! i)) $ zip [0 ..] args
                let gen = join gens
                let (inReg, _inStk) = splitAt 6 tmpVars
                    movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANopq [ALoc tmp]) $ zip [0 ..] inReg
                return $ gen ++ movArg ++ [AControl $ AJump $ fname ++ "_start"]  
            else do
                gen <- genExp e (AReg 0)
                return $ gen ++ [AControl $ AJump $ fname ++ "_ret"]
        Just e -> do
            gen <- genExp e (AReg 0)
            return $ gen ++ [AControl $ AJump $ fname ++ "_ret"]
        Nothing -> return [AControl $ AJump $ fname ++ "_ret"]
genTast TNop = return []
genTast (TDecl _ _ e) = genTast e
genTast (TLeaf e) = genSideEffect e
genTast (TSDef _ _ e) = genTast e

genSideEffect :: TExp -> CodeGenStateM [AAsm]
genSideEffect (TFunc fn args _) = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANopq [ALoc tmp]) $ zip [0 ..] inReg
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg)]
genSideEffect expr = do
    n <- getNewUniqueID
    genExp expr (ATemp n)

typeOfLVal :: TLValue -> Type
typeOfLVal (TVIdent _ t) = t
typeOfLVal (TVField _ _ t) = t
typeOfLVal (TVDeref _ t) = t
typeOfLVal (TVArrAccess _ _ t) = t

typeOfTExp :: TExp -> Type
typeOfTExp (TIdent _ t) = t
typeOfTExp (TField _ _ t) = t
typeOfTExp (TDeref _ t) = t
typeOfTExp (TArrAccess _ _ t) = t

toLVal :: TExp -> TLValue
toLVal (TIdent x t) = TVIdent x t
toLVal (TField e field t) = TVField (toLVal e) field t
toLVal (TDeref p t) = TVDeref (toLVal p) t
toLVal (TArrAccess arr idx t) = TVArrAccess (toLVal arr) idx t
toLVal _ = error "Invalid conversion"

toTExp :: TLValue -> TExp
toTExp (TVIdent x t) = TIdent x t
toTExp (TVField e field t) = TField (toTExp e) field t
toTExp (TVDeref p t) = TDeref (toTExp p) t
toTExp (TVArrAccess arr idx t) = TArrAccess (toTExp arr) idx t

fieldOffset :: TExp -> StructInfo -> (TExp, Int)
fieldOffset (TField e field _) sinfo =
    let offset =
            case typeOfTExp e of
                STRUCT s ->
                    case Map.lookup s sinfo of
                        Just (_, _, offsets) ->
                            case Map.lookup field offsets of
                                Just (o, _) -> o
                                _ -> error "Malformed. Check type-checker."
                        _ -> error "Malformed. Check type-checker."
                _ -> error "Malformed. Check type-checker."
        (b, boffset) = fieldOffset e sinfo
    in
        (b, boffset + offset)
fieldOffset texp _ = (texp, 0)

genAddr :: TExp -> ALoc -> StructInfo -> CodeGenStateM [AAsm]
genAddr (TDeref (TIdent x _) _) dest _sinfo = do
    allocmap <- State.gets variables
    return [AAsm [dest] ANopq [ALoc $ ATemp $ allocmap Map.! x]]
genAddr (TDeref e _) dest _ = genExp e dest
genAddr (TField (TIdent x tp) field _) dest sinfo = do
    allocmap <- State.gets variables
    let st = ATemp $ allocmap Map.! x
    let offset =
            case tp of
                STRUCT s ->
                    case Map.lookup s sinfo of
                        Just (_, _, offsets) ->
                            case Map.lookup field offsets of
                                Just (o, _) -> o
                                _ -> error "Malformed. Check type-checker."
                        _ -> error "Malformed. Check type-checker."
                _ -> error "Malformed. Check type-checker."
    nullcheck <- checkNull st
    return $
        nullcheck ++ [AAsm [dest] AAddq [ALoc st, AImm offset]]
genAddr (TField e field _) dest sinfo = do
    let
        (b, boffset) = fieldOffset e sinfo
    gen <- genAddr b dest sinfo
    let
        addBOffset = [AAsm [dest] AAddq [ALoc dest, AImm boffset]]
        offset =
            case typeOfTExp e of
                STRUCT s ->
                    case Map.lookup s sinfo of
                        Just (_, _, offsets) ->
                            case Map.lookup field offsets of
                                Just (o, _) -> o
                                _ -> error "Malformed. Check type-checker."
                        _ -> error "Malformed. Check type-checker."
                _ -> error "Malformed. Check type-checker."
    nullcheck1 <- checkNull dest
    nullcheck2 <- checkNull dest
    return $
        gen ++ nullcheck1 ++ addBOffset ++ nullcheck2 ++ [AAsm [dest] AAddq [ALoc dest, AImm offset]]
genAddr (TArrAccess (TIdent a _) (TInt x) typ) dest sinfo = do
    let siz = findSize typ sinfo
    if x > 1073741816 `div` siz then return [AControl $ AJump "memerror"] else do
        allocmap <- State.gets variables
        let arr = ATemp $ allocmap Map.! a
        boundcheck <- checkBounds arr (AImm x)
        let off = siz * x
        return $
            boundcheck ++
            [ AAsm [dest] AAddq [ALoc arr, AImm off] ]
genAddr (TArrAccess arr (TInt x) typ) dest sinfo = do
    let siz = findSize typ sinfo
    if x > 1073741816 `div` siz then return [AControl $ AJump "memerror"] else do
        n <- getNewUniqueID
        genArr <- genExp arr (ATemp n)
        boundcheck <- checkBounds (ATemp n) (AImm x)
        let off = siz * x
        return $
            genArr ++
            boundcheck ++
            [ AAsm [dest] AAddq [ALoc $ ATemp n, AImm off] ]
genAddr (TArrAccess (TIdent a _) idx typ) dest sinfo = do
    n' <- getNewUniqueID
    allocmap <- State.gets variables
    genIdx <- genExp idx (ATemp n')
    let arr = ATemp $ allocmap Map.! a
    boundcheck <- checkBounds arr (ALoc $ ATemp n')
    let sizefact = findSize typ sinfo
    return $
        genIdx ++
        boundcheck ++
        [ AAsm [dest] AMulq [AImm sizefact, ALoc $ ATemp n']
        , AAsm [dest] AAddq [ALoc dest, ALoc arr]
        ]
genAddr (TArrAccess arr idx typ) dest sinfo = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    genArr <- genExp arr (ATemp n)
    genIdx <- genExp idx (ATemp n')
    boundcheck <- checkBounds (ATemp n) (ALoc $ ATemp n')
    let sizefact = findSize typ sinfo
    return $
        genArr ++
        genIdx ++
        boundcheck ++
        [ AAsm [dest] AMulq [AImm sizefact, ALoc $ ATemp n']
        , AAsm [dest] AAddq [ALoc dest, ALoc $ ATemp n]
        ]

--check if a we are writing to or dereferencing NULL
checkNull :: ALoc -> CodeGenStateM [AAsm]
checkNull ptr = do
    unsafe <- State.gets unsafeflag
    l1 <- getNewUniqueLabel
    if unsafe then return [] else 
        return [AControl $ ACJump' AEqq (ALoc ptr) (AImm 0) "memerror" l1, AControl $ ALab l1]

--creates the labels and temps needed to check the bounds of the array access
--input is the ALoc representing the first element of the Array, and second ALoc representing index
checkBounds :: ALoc -> AVal -> CodeGenStateM [AAsm]
checkBounds arr idx = do
    unsafe <- State.gets unsafeflag
    if unsafe then return [] else do
        l2 <- getNewUniqueLabel
        l3 <- getNewUniqueLabel
        size <- getNewUniqueID
        let
            gensize = [AAsm [ATemp size] ASubq [ALoc arr, AImm 8],
                AAsm [ATemp size] ANop [ALoc $ APtr $ ATemp size]]
            sizechk =
                case idx of
                    AImm x | x < 0 -> [AControl $ AJump "memerror"]
                        | otherwise ->
                                [
                                AControl $ ACJump' ALe (ALoc $ ATemp size) idx "memerror" l3,
                                AControl $ ALab l3
                                ]
                    _ -> [
                            AControl $ ACJump' ALt idx (AImm 0) "memerror" l2,
                            AControl $ ALab l2,
                            AControl $ ACJump' ALe (ALoc $ ATemp size) idx "memerror" l3,
                            AControl $ ALab l3
                        ]
        nullcheck <- checkNull arr
        return $ nullcheck ++ gensize ++ sizechk

findSize :: Type -> StructInfo -> Int
findSize tp info = 
    case tp of
        INTEGER -> 4
        BOOLEAN -> 4
        POINTER _ -> 8
        ARRAY _ -> 8
        STRUCT a -> 
                case Map.lookup a info of
                    Just (size, _, _) -> size
                    Nothing -> error "accessing undeclared struct"
        _ -> error "Invalid type to findSize"

genExp :: TExp -> ALoc -> CodeGenStateM [AAsm]
-- genExp e _ | trace ("genExp " ++ show e ++ "\n") False = undefined
genExp (TInt n) dest = return [AAsm [dest] ANop [AImm $ fromIntegral (fromIntegral n :: Int32)]]
genExp (TIdent var typ) dest = do
    allocmap <- State.gets variables
    return $ assignType typ (ATemp $ allocmap Map.! var) dest
genExp TT dest = return [AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)]]
genExp TF dest = return [AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]]
genExp TNULL dest = return [AAsm [dest] ANopq [AImm $ fromIntegral (0 :: Int64)]]
genExp expr@(TBinop binop exp1 exp2) dest
    | isRelOp binop = do
        n <- getNewUniqueID
        codegen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        codegen2 <- genExp exp2 (ATemp n')
        let combine = [ARel [dest] (genRelOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
        return $ codegen1 ++ codegen2 ++ combine
    | binop == LAnd || binop == LOr = do
        l1 <- getNewUniqueLabel
        l2 <- getNewUniqueLabel
        l3 <- getNewUniqueLabel
        cmp <- genCmp expr l1 l2
        return $
            cmp ++
            [AControl $ ALab l1, AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)], AControl $ AJump l3] ++
            [AControl $ ALab l2, AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)], AControl $ AJump l3] ++
            [AControl $ ALab l3]
    | binop == Sal || binop == Sar = do
        unsafe <- State.gets unsafeflag
        n <- getNewUniqueID
        gen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        gen2 <- genExp exp2 (ATemp n')
        if unsafe then
            return [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
            else do
                n2 <- getNewUniqueID
                n3 <- getNewUniqueID
                l1 <- getNewUniqueLabel
                l2 <- getNewUniqueLabel
                l3 <- getNewUniqueLabel
                l4 <- getNewUniqueLabel

                let
                    checker = [ARel [ATemp n2] (genRelOp Ge) [ALoc $ ATemp n', AImm 0],
                            ARel [ATemp n3] (genRelOp Lt) [ALoc $ ATemp n', AImm 32],
                            AControl $ ACJump (ALoc $ ATemp n2) l4 l2,
                            AControl $ ALab l4,
                            AControl $ ACJump (ALoc $ ATemp n3) l1 l2]
                    combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
                failure <- genExp (TBinop Div (TInt 1) (TInt 0)) dest
                return $
                    gen1 ++
                    gen2 ++ 
                    checker ++
                    [AControl $ ALab l1] ++ combine ++ [AControl $ AJump l3, AControl $ ALab l2] ++ 
                    failure ++ [AControl $ AJump l3, AControl $ ALab l3]
    | binop == Add || binop == Sub =
        case (exp1, exp2) of
            (TInt x1, _) -> do
                n <- getNewUniqueID
                codegen <- genExp exp2 (ATemp n)
                let combine = [AAsm [dest] (genBinOp binop) [AImm x1, ALoc $ ATemp n]]
                return $ codegen ++ combine
            (_, TInt x2) -> do
                n <- getNewUniqueID
                codegen <- genExp exp1 (ATemp n)
                let combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, AImm x2]]
                return $ codegen ++ combine
            _ -> do
                n <- getNewUniqueID
                codegen1 <- genExp exp1 (ATemp n)
                n' <- getNewUniqueID
                codegen2 <- genExp exp2 (ATemp n')
                let combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
                return $ codegen1 ++ codegen2 ++ combine
    | binop == Mul = mulOptimize exp1 exp2 dest
    | binop == Div = divOptimize exp1 exp2 dest
    | otherwise = do
        n <- getNewUniqueID
        codegen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        codegen2 <- genExp exp2 (ATemp n')
        let combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
        return $ codegen1 ++ codegen2 ++ combine
genExp (TUnop unop expr) dest =
    case unop of
        LNot -> do
            l1 <- getNewUniqueLabel
            l2 <- getNewUniqueLabel
            l3 <- getNewUniqueLabel
            cmp <- genCmp expr l1 l2
            return $
                cmp ++
                [AControl $ ALab l1, AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)], AControl $ AJump l3] ++
                [AControl $ ALab l2, AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)], AControl $ AJump l3] ++
                [AControl $ ALab l3]
        BNot -> do
            n <- getNewUniqueID
            gen <- genExp expr (ATemp n)
            return $ gen ++ [AAsm [dest] ABNot [ALoc $ ATemp n]]
        Neg ->
            case expr of
                (TInt n) -> return [AAsm [dest] ANop [AImm $ fromIntegral ((fromIntegral $ -n) :: Int32)]]
                _ -> do
                    n <- getNewUniqueID
                    cogen <- genExp expr (ATemp n)
                    let assign = [AAsm [dest] ASub [AImm 0, ALoc $ ATemp n]]
                    return $ cogen ++ assign
genExp (TTernop e1 e2 e3) dest =
    case e1 of
        TT -> genExp e2 dest
        TF -> genExp e3 dest
        _ -> do
            l1 <- getNewUniqueLabel
            l2 <- getNewUniqueLabel
            l3 <- getNewUniqueLabel
            cmp <- genCmp e1 l1 l2
            gen1 <- genExp e2 dest
            gen2 <- genExp e3 dest
            return $
                cmp ++
                [AControl $ ALab l1] ++
                gen1 ++ [AControl $ AJump l3, AControl $ ALab l2] ++ gen2 ++ [AControl $ AJump l3, AControl $ ALab l3]
genExp (TFunc fn args typ) dest = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANopq [ALoc tmp]) $ zip [0 ..] inReg
        assign = assignType typ (AReg 0) dest
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg)] ++ assign
genExp expr@(TField _ _ typ) dest = do
    sinfo <- State.gets structInfo
    addr <- genAddr expr dest sinfo
    return $ addr ++ assignHeap typ dest dest
genExp (TAlloc tp) dest = do
    info <- State.gets structInfo
    let
        sizefact = findSize tp info
    return [
                AAsm [AReg 3] ANopq [AImm 1],
                AAsm [AReg 4] ANopq [AImm sizefact],
                ACall "calloc" [] 2,
                AAsm [dest] ANopq [ALoc $ AReg 0]
            ]            
genExp (TArrAlloc tp (TInt x)) dest = do
    info <- State.gets structInfo
    unsafe <- State.gets unsafeflag
    let siz = findSize tp info
    if x < 0 || (siz /= 0 && x > 2147483648 `div` siz)
        then return [AControl $ AJump "memerror"]
        else if unsafe then
            return
                [ AAsm [AReg 3] ANopq [AImm 1]
                , AAsm [AReg 4] ANopq [AImm (x * siz)]
                , ACall "calloc" [] 2
                , AAsm [dest] ANopq [ALoc $ AReg 0]
                ]
        else
            return
                [ AAsm [AReg 3] ANopq [AImm 1]
                , AAsm [AReg 4] ANopq [AImm (x * siz + 8)]
                , ACall "calloc" [] 2
                , AAsm [APtr $ AReg 0] ANop [AImm x]
                , AAsm [dest] AAddq [ALoc $ AReg 0, AImm 8]
                ]
genExp (TArrAlloc tp size) dest = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    n'' <- getNewUniqueID
    l1 <- getNewUniqueLabel
    siz <- genExp size (ATemp n)
    info <- State.gets structInfo
    let
        sizefact = findSize tp info
        sizechk = [AControl $ ACJump' ALt (ALoc $ ATemp n) (AImm 0) "memerror" l1]
        success = [
            AControl $ ALab l1,
            AAsm [ATemp n'] AMulq [AImm sizefact, ALoc $ ATemp n],
            AAsm [ATemp n''] AAddq [ALoc $ ATemp n', AImm 8],
            AAsm [AReg 3] ANopq [AImm 1],
            AAsm [AReg 4] ANopq [ALoc $ ATemp n''],
            ACall "calloc" [] 2,
            AAsm [APtr $ AReg 0] ANop [ALoc $ ATemp n], -- put the size in the block before beginning of array
            AAsm [dest] AAddq [ALoc $ AReg 0, AImm 8]
            ]
    return $ siz ++ sizechk ++ success
genExp (TArrAccess (TIdent a _) (TInt x) tp) dest = do
    info <- State.gets structInfo
    let siz = findSize tp info
    if x > 1073741816 `div` siz then return [AControl $ AJump "memerror"] else do
        allocmap <- State.gets variables
        let arr = ATemp $ allocmap Map.! a
        bounds <- checkBounds arr (AImm x)
        let off = siz * x
        return $ bounds ++ [AAsm [dest] AAddq [ALoc arr, AImm off]] ++ assignHeap tp dest dest
genExp (TArrAccess exp1 (TInt x) tp) dest = do
    info <- State.gets structInfo
    let siz = findSize tp info
    if x > 1073741816 `div` siz then return [AControl $ AJump "memerror"] else do
        n <- getNewUniqueID
        arr <- genExp exp1 (ATemp n)
        bounds <- checkBounds (ATemp n) (AImm x)
        let off = siz * x
        return $ arr ++ bounds ++ [AAsm [dest] AAddq [ALoc $ ATemp n, AImm off]] ++ assignHeap tp dest dest
genExp (TArrAccess (TIdent a _) exp2 tp) dest = do
    n' <- getNewUniqueID
    allocmap <- State.gets variables
    access <- genExp exp2 (ATemp n')
    let arr = ATemp $ allocmap Map.! a
    bounds <- checkBounds arr (ALoc $ ATemp n')
    info <- State.gets structInfo
    let
        sizefact = findSize tp info
        offset =
            [
            AAsm [dest] AMulq [AImm sizefact, ALoc $ ATemp n'],
            AAsm [dest] AAddq [ALoc dest, ALoc arr]
            ]
    return $ access ++ bounds ++ offset ++ assignHeap tp dest dest
genExp (TArrAccess exp1 exp2 tp) dest = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    arr <- genExp exp1 (ATemp n)
    access <- genExp exp2 (ATemp n')
    bounds <- checkBounds (ATemp n) (ALoc $ ATemp n')
    info <- State.gets structInfo
    let
        sizefact = findSize tp info
        offset = 
            [
            AAsm [dest] AMulq [AImm sizefact, ALoc $ ATemp n'],
            AAsm [dest] AAddq [ALoc dest, ALoc $ ATemp n]
            ]
    return $ arr ++ access ++ bounds ++ offset ++ assignHeap tp dest dest
genExp (TDeref exp1 tp) dest = do
    ptr <- genExp exp1 dest
    nullchk <- checkNull dest
    return $ ptr ++ nullchk ++ assignHeap tp dest dest

--expr1, expr2, dest
mulOptimize :: TExp -> TExp -> ALoc -> CodeGenStateM[AAsm]
mulOptimize exp1 exp2 dest = 
    case (exp1, exp2) of
        (TInt x1, _) -> do
            n <- getNewUniqueID
            codegen <- genExp exp2 (ATemp n)
            if x1 == 0 then return $ codegen ++ [AAsm [dest] ANop [AImm 0]] else do
                let
                    flr = (floor . logBase 2.0 . fromIntegral) x1
                    ceil = (ceiling . logBase 2.0 . fromIntegral) x1
                    combine = if flr == ceil then
                            [AAsm [dest] (genBinOp Sal) [ALoc $ ATemp n, AImm flr]]
                        else
                            [AAsm [dest] (genBinOp Mul) [AImm x1, ALoc $ ATemp n]]
                return $ codegen ++ combine
        (_, TInt x1) -> do
            n <- getNewUniqueID
            codegen <- genExp exp1 (ATemp n)
            if x1 == 0 then return $ codegen ++ [AAsm [dest] ANop [AImm 0]] else do
                let
                    flr = (floor . logBase 2.0 . fromIntegral) x1
                    ceil = (ceiling . logBase 2.0 . fromIntegral) x1
                    combine = if flr == ceil then
                            [AAsm [dest] (genBinOp Sal) [ALoc $ ATemp n, AImm flr]]
                        else
                            [AAsm [dest] (genBinOp Mul) [AImm x1, ALoc $ ATemp n]]
                return $ codegen ++ combine
        (_, _) -> do 
            n <- getNewUniqueID
            codegen1 <- genExp exp1 (ATemp n)
            n' <- getNewUniqueID
            codegen2 <- genExp exp2 (ATemp n')
            let combine = [AAsm [dest] (genBinOp Mul) [ALoc $ ATemp n, ALoc $ ATemp n']]
            return $ codegen1 ++ codegen2 ++ combine

divOptimize :: TExp -> TExp -> ALoc -> CodeGenStateM[AAsm]
divOptimize exp1 exp2 dest = 
    case (exp1, exp2) of 
        (_, TInt x1) -> do 
            n <- getNewUniqueID
            codegen <- genExp exp1 (ATemp n)
            if x1 == 0 then return $ codegen ++ [AAsm [dest] (genBinOp Div) [ALoc $ ATemp n, AImm 0]]
            else do
                let
                    flr = (floor . logBase 2.0 . fromIntegral) x1
                    ceil = (ceiling . logBase 2.0 . fromIntegral) x1
                    combine = if flr == ceil then
                            [AAsm [dest] (genBinOp Sar) [ALoc $ ATemp n, AImm flr]]
                        else
                            [AAsm [dest] (genBinOp Div) [ALoc $ ATemp n, AImm x1]]
                return $ codegen ++ combine
        _ -> do 
            n <- getNewUniqueID
            codegen1 <- genExp exp1 (ATemp n)
            n' <- getNewUniqueID
            codegen2 <- genExp exp2 (ATemp n')
            let combine = [AAsm [dest] (genBinOp Div) [ALoc $ ATemp n, ALoc $ ATemp n']]
            return $ codegen1 ++ codegen2 ++ combine
                
--Type, src temp, dest temp
assignType :: Type -> ALoc -> ALoc -> [AAsm]
assignType tp src dest =
    case tp of
        POINTER _ -> [AAsm [dest] ANopq [ALoc src]]
        ARRAY _ -> [AAsm [dest] ANopq [ALoc src]]
        STRUCT _ -> error "Invalid assignment of large type (struct)"
        _ -> [AAsm [dest] ANop [ALoc src]]

assignHeap :: Type -> ALoc -> ALoc -> [AAsm]
assignHeap tp src dest =
    case tp of
        POINTER _ -> [AAsm [dest] ANopq [ALoc $ APtrq src]]
        ARRAY _ -> [AAsm [dest] ANopq [ALoc $ APtrq src]]
        STRUCT _ -> error "Invalid assignment of large type (struct)"
        _ -> [AAsm [dest] ANop [ALoc $ APtr src]]

genCmp :: TExp -> ALabel -> ALabel -> CodeGenStateM [AAsm]
-- genCmp e _ _ | trace ("genCmp " ++ show e ++ "\n") False = undefined
genCmp (TBinop op e1 e2) l l'
    | isRelOp op = do
        n <- getNewUniqueID
        gen1 <- genExp e1 (ATemp n)
        n' <- getNewUniqueID
        gen2 <- genExp e2 (ATemp n')
        return $ gen1 ++ gen2 ++ [AControl $ ACJump' (genRelOp op) (ALoc $ ATemp n) (ALoc $ ATemp n') l l']
    | op == LAnd = do
        l2 <- getNewUniqueLabel
        gen1 <- genCmp e1 l2 l'
        gen2 <- genCmp e2 l l'
        return $ gen1 ++ [AControl $ ALab l2] ++ gen2
    | op == LOr = do
        l2 <- getNewUniqueLabel
        gen1 <- genCmp e1 l l2
        gen2 <- genCmp e2 l l'
        return $ gen1 ++ [AControl $ ALab l2] ++ gen2
genCmp (TUnop LNot e) l l' = genCmp e l' l
genCmp TF _l l' = return [AControl $ AJump l']
genCmp TT l _l' = return [AControl $ AJump l]
genCmp e l l' = do
    n <- getNewUniqueID
    gen <- genExp e (ATemp n)
    return $ gen ++ [AControl $ ACJump (ALoc $ ATemp n) l l']

genBinOp :: Binop -> AOp
genBinOp Add = AAdd
genBinOp Sub = ASub
genBinOp Div = ADiv
genBinOp Mul = AMul
genBinOp Mod = AMod
genBinOp BAnd = ABAnd
genBinOp BOr = ABOr
genBinOp Xor = AXor
genBinOp Sal = ASal
genBinOp Sar = ASar
genBinOp o = error $ "Operator not found: " ++ show o

genRelOp :: Binop -> ARelOp
genRelOp Eql = AEq
genRelOp Neq = ANe
genRelOp Lt = ALt
genRelOp Gt = AGt
genRelOp Le = ALe
genRelOp Ge = AGe
genRelOp Eqlq = AEqq
genRelOp Neqq = ANeq
genRelOp o = error $ "Operator is not a RelOp: " ++ show o

argRegs :: [ALoc]
argRegs = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6]

testGenEast :: IO ()
testGenEast = do
    let east =
            TSeq
                (TDecl
                     "f"
                     (ARROW [] (ARRAY INTEGER))
                     (TDef
                          "f"
                          (ARROW [] (ARRAY INTEGER))
                          (TDecl
                               "x"
                               (ARRAY INTEGER)
                               (TSeq
                                    (TAssign (TVIdent "x" (ARRAY INTEGER)) (TArrAlloc (ARRAY INTEGER) (TInt 10)) True)
                                    (TRet (Just $ TIdent "x" (ARRAY INTEGER)))))))
                (TDecl
                     "g"
                     (ARROW [("x", (ARRAY INTEGER))] INTEGER)
                     (TDef
                          "g"
                          (ARROW [("x", (ARRAY INTEGER))] INTEGER)
                          (TRet (Just $ TArrAccess (TIdent "x" (ARRAY INTEGER)) (TInt 3) INTEGER))))
        funs = aasmGen east [] True
    putStr $ show funs
testGenRecursive :: IO ()
testGenRecursive = do
    let east = 
            TSeq
                (TDecl 
                    "f" (ARROW [("x", INTEGER)] INTEGER)
                    (TDef "f"
                        (ARROW [("x", INTEGER)] INTEGER)
                        (TIf (TBinop Le (TIdent "x" INTEGER) (TInt 0))
                        (TRet (Just $ TIdent "x" INTEGER))(TRet (Just $ TFunc "f" [TBinop Add (TIdent "x" INTEGER) (TInt 2)] INTEGER)
                        ))))
                (TDecl
                     "g"
                     (ARROW [("x", (ARRAY INTEGER))] INTEGER)
                     (TDef
                          "g"
                          (ARROW [("x", (ARRAY INTEGER))] INTEGER)
                          (TRet (Just $ TArrAccess (TIdent "x" (ARRAY INTEGER)) (TInt 3) INTEGER))))
        funs = aasmGen east [] False
    putStr $ show funs
