module Compile.Backend.EAST2AAsm where

import Compile.Types
import Control.Monad
import qualified Control.Monad.State.Strict as State
import Data.Int
import qualified Data.Map as Map
import Debug.Trace

--TODO: do a global label for raise mem error.
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
        , arrays :: Map.Map String Type
    -- ^ current array names and their length, type
        }

-- Using the state monad with CodeGenState as the state allows us to implicitly
-- thread the variable map and the next unique ID through the entire
-- computation. (The M in CodeGenStateM stands for "Monad".)
type CodeGenStateM = State.State CodeGenState

getNewUniqueID :: CodeGenStateM Int
getNewUniqueID = do
    currentCount <- State.gets uniqueIDCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf arr) -> CodeGenState vs (counter + 1) lab genf cf arr
    return currentCount

getNewUniqueLabel :: CodeGenStateM String
getNewUniqueLabel = do
    currentCount <- State.gets uniqueLabelCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf arr) -> CodeGenState vs counter (lab + 1) genf cf arr
    let lab = "L" ++ show currentCount
    return lab

--for each term, (function name, AASM generated, # of var)
aasmGen :: EAST -> [(Ident, ([AAsm], Int))]
aasmGen east = State.evalState assemM initialState
  where
    initialState =
        CodeGenState
            { variables = Map.empty
            , uniqueIDCounter = 0
            , uniqueLabelCounter = 0
            , genFunctions = []
            , currentFunction = ""
            , arrays = Map.empty
            }
    assemM :: CodeGenStateM [(Ident, ([AAsm], Int))]
    assemM = do
        _genAAsm <- genEast east
        CodeGenState _ _ _ genf _ _<- State.get
        return (reverse genf)

-- Get the decls from a sequence of stmts.
getDecls :: EAST -> [Ident]
getDecls (ESeq e1 e2) = getDecls e1 ++ getDecls e2
getDecls (EIf _ e1 e2) = getDecls e1 ++ getDecls e2
getDecls (EWhile _ e) = getDecls e
getDecls (EDecl x _ e) = x : getDecls e
getDecls _ = []

genEast :: EAST -> CodeGenStateM [AAsm]
genEast (ESeq e1 e2) = do
    gen1 <- genEast e1
    gen2 <- genEast e2
    return $ gen1 ++ gen2
--TODO: Added Stuff
genEast (EAssign (EVIdent x) (ArrayAlloc tp exp)) = do 
    n <- getNewUniqueID
    n' <- getNewUniqueID
    n'' <- getNewUniqueID
    sizeinfo <- getNewUniqueID
    genE <- genExp exp (ATemp n)
    State.modify' $ \(CodeGenState vs counter lab genf cf arr) -> 
        CodeGenState vs counter lab genf cf (Map.insert x tp)
    allocMap <- State.gets variables
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    let tmpNum = APtr $ ATemp $ allocMap Map.! x
        sizefact = case tp of
            INTEGER -> 4
            BOOLEAN -> 4
            --TODO: modify this to find size of struct
            STRUCT s -> 8
            _ -> 8
        sizechk = [AControl $ ACJump' (ALt) (ALoc $ ATemp n) (AImm 0) l1 l2]
        --change abort mem to raise(12)
        fail = [AControl $ ALab l1, ACall "abort_mem" [] 0]
        success = [
            AControl $ ALab l2, 
            AAsm [ATemp n'] AMul [AImm (sizefact), ALoc $ ATemp n],
            AASM [ATemp n''] AAdd [ALoc $ ATemp n', AImm 8],
            AASM [AReg 3] ANop [ALoc $ ATemp n''],
            ACall "alloc_array" [] 1, 
            AAsm [APtr $ ATemp sizeinfo] ANop [ALoc $ ATemp n'],
            AAsm [tmpNum] AAdd [ALoc $ AReg 0, AImm 8]
            ]
    return $ sizechk ++ fail ++ success
genEast (EAssign(EVArrAccess lv expr) expr) = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    n'' <- getNewUniqueID
    item <- getNewUniqueID
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    l3 <- getNewUniqueLabel
    --TODO: implement genLval
    arr <- genLval lv (APtr $ ATemp n)
    gen <- genSideEffect e2 (ATemp n'')
    --Temp n' is the length of array
    findsize <- genSize arr (ATemp n')
    let
        sizechk = [
            AControl $ ACJump' (ALt) (ALoc $ ATemp n'') (AImm 0) l1 l2,
            AControl $ ALab l2,
            AControl $ ACJump' (AGt) (ALoc $ ATemp n'') (ALoc $ ATemp n') l1 l3
            ]
        fail = [
            AControl $ ALab l1,
            ACall "abort_mem" [] 0]
        success = [
            AControl $ ALab l3,
            AAsm [item] AAdd [ALoc $ ATemp n, ]
            AAsm [dest] (genBinOp b) [A]
            ]
genEast (EAssign (EVIdent x) (E))
genEast (EAssign (EVIdent x) expr _b) = do
    allocMap <- State.gets variables
    let tmpNum = ATemp $ allocMap Map.! x
    genExp expr tmpNum
--TODO:Add type map to the EDef
genEast (EDef fn t e) = do
    let ARROW ts _r = t
        args = map fst ts
        decls = args ++ getDecls e
        v' = Map.fromList $ zip decls [0 ..]
    State.modify' $ \(CodeGenState _vs _counter lab genf _cf arr) -> CodeGenState v' (length decls) lab genf fn arr
    let (inReg, inStk) = splitAt 6 (map (\a -> ATemp $ v' Map.! a) args)
        movArg = map (\(i, tmp) -> AAsm [tmp] ANop [ALoc $ argRegs !! i]) $ zip [0 ..] inReg
    gen <- genEast e
    let funGen = [AFun fn inStk] ++ movArg ++ gen
    State.modify' $ \(CodeGenState vs counter lab genf cf arr) -> CodeGenState vs counter lab ((fn, (funGen, counter)) : genf) cf arr
    return funGen
genEast (EAssert expr) = do
    let trans = EIf expr ENop (ELeaf $ EFunc "abort" [])
    genEast trans
genEast (EIf ET e1 _e2) = genEast e1
genEast (EIf EF _e1 e2) = genEast e2
genEast (EIf expr e1 e2) = do
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    l3 <- getNewUniqueLabel
    cmp <- genCmp expr l1 l2
    gen1 <- genEast e1
    gen2 <- genEast e2
    return $
        cmp ++
        [AControl $ ALab l1] ++
        gen1 ++ [AControl $ AJump l3, AControl $ ALab l2] ++ gen2 ++ [AControl $ AJump l3, AControl $ ALab l3]
genEast (EWhile expr e) = do
    l1 <- getNewUniqueLabel -- label before while guard
    l2 <- getNewUniqueLabel -- label of the while block
    l3 <- getNewUniqueLabel -- label after while block
    cmp <- genCmp expr l2 l3
    gen <- genEast e
    return $ [AControl $ ALab l1] ++ cmp ++ [AControl $ ALab l2] ++ gen ++ [AControl $ AJump l1, AControl $ ALab l3]
genEast (ERet expr) = do
    fn <- State.gets currentFunction
    let fname = if fn == "a bort" then "_c0_abort_local411" else "_c0_" ++ fn
    case expr of
        Just e -> do
            gen <- genExp e (AReg 0)
            return $ gen ++ [AControl $ AJump $ fname ++ "_ret"]
        Nothing -> return [AControl $ AJump $ fname ++ "_ret"]
genEast ENop = return []
genEast (EDecl _ _ e) = genEast e
genEast (ELeaf e) = genSideEffect e

genSideEffect :: EExp -> ALoc -> CodeGenStateM [AAsm]
genSideEffect (EFunc fn args) dest = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANop [ALoc tmp]) $ zip [0 ..] inReg
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg)]
genSideEffect expr dest = do
    genExp expr (ATemp n dest)

--creates the labels and temps needed to check the bounds of the array access
--input is the ALoc representing the first element of the Array, and second ALoc representing index
checkbounds :: ALoc -> ALoc -> CodeGenStateM [AAsm] 
checkbounds arr idx = do
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    l3 <- getNewUniqueLabel
    size <- getNewUniqueID
    let
        gensize <- [AAsm [ATemp size] ASub [ALoc t, AImm 8]]
        sizechk = [
            AControl $ ACJump' (ALt) (ALoc idx) (AImm 0) l1 l2,
            AControl $ ALab l2,
            AControl $ ACJump' (AGt) (ALoc idx) (ALoc size) l1 l3
            ]
        fail = [
            AControl $ ALab l1,
            ACall "abort_mem" [] 0]
        success = [
            AControl $ ALab l3,
            ]
    return gensize ++ fail ++ success

getSize :: Ident -> Int -> Map.Map String Ident
getSize var tpemap = 
    n <-
--Second parameter gives the size of the Lvalue
genLVal :: ELValue -> ALoc -> (CodeGenStateM [AAsm], Int)
genLVal (EVIdent var) dest = do
    allocmap <- State.gets variables
    return ([AAsm [dest] ANop [ALoc $ ATemp $ allocmap Map.! var]], getSize(var (State.gets arrays)))
genLVal (EVField lv var) dest = return []
genLVal (EVDeref lv) dest = return []
genLVal (EVArrAccess lv expr) dest = do
    n <- getNewUniqueID
    n' <- getNewUniqueID
    n'' <- getNewUniqueID
    l1 <- getNewUniqueLabel
    l2 <- getNewUniqueLabel
    l3 <- getNewUniqueLabel
    arr <- case lv of 
        EVIdent _ -> (ATemp n)
        _ -> (APtr $ ATemp n)
    gen <- genLVal lv arr
    expgen <- genExp expr (ATemp n')
    boundcheck <- checkbounds arr (ATemp n')
    let
    --TODO: Need to find a way to find the size
        access = [
            AAsm [dest] AAdd [ALoc $ ATemp n, ]
        ]

genExp :: EExp -> ALoc -> CodeGenStateM [AAsm]
-- genExp e _ | trace ("genExp " ++ show e ++ "\n") False = undefined
genExp (EInt n) dest = return [AAsm [dest] ANop [AImm $ fromIntegral (fromIntegral n :: Int32)]]
genExp (EIdent var) dest = do
    allocmap <- State.gets variables
    return [AAsm [dest] ANop [ALoc $ ATemp $ allocmap Map.! var]]
genExp ET dest = return [AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)]]
genExp EF dest = return [AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]]
genExp ENULL dest = return [AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]]
genExp expr@(EBinop binop exp1 exp2) dest
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
        n <- getNewUniqueID
        gen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        gen2 <- genExp exp2 (ATemp n')
        let checker = EBinop LAnd (EBinop Le (EInt 0) exp2) (EBinop Lt exp2 (EInt 32))
            combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
        l1 <- getNewUniqueLabel
        l2 <- getNewUniqueLabel
        l3 <- getNewUniqueLabel
        cmp <- genCmp checker l1 l2
        genl2 <- genExp (EBinop Div (EInt 1) (EInt 0)) dest
        return $ gen1 ++ gen2 ++ cmp ++ [AControl $ ALab l1] ++ combine ++ [AControl $ AJump l3, AControl $ ALab l2]
                ++ genl2 ++ [AControl $ AJump l3, AControl $ ALab l3]
    | binop == Add || binop == Sub || binop == Mul =
        case (exp1, exp2) of
            (EInt x1, _) -> do
                n <- getNewUniqueID
                codegen <- genExp exp2 (ATemp n)
                let combine = [AAsm [dest] (genBinOp binop) [AImm x1, ALoc $ ATemp n]]
                return $ codegen ++ combine
            (_, EInt x2) -> do
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
    | otherwise = do
        n <- getNewUniqueID
        codegen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        codegen2 <- genExp exp2 (ATemp n')
        let combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
        return $ codegen1 ++ codegen2 ++ combine
genExp (EUnop unop expr) dest =
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
                (EInt n) -> return [AAsm [dest] ANop [AImm $ fromIntegral ((fromIntegral $ -n) :: Int32)]]
                _ -> do
                    n <- getNewUniqueID
                    cogen <- genExp expr (ATemp n)
                    let assign = [AAsm [dest] ASub [AImm 0, ALoc $ ATemp n]]
                    return $ cogen ++ assign
genExp (ETernop e1 e2 e3) dest =
    case e1 of
        ET -> genExp e2 dest
        EF -> genExp e3 dest
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
genExp (EFunc fn args) dest = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANop [ALoc tmp]) $ zip [0 ..] inReg
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg), AAsm [dest] ANop [ALoc $ AReg 0]]
--This is already completed in the checkEAST
genExp (EArrAlloc tp size) dest = []
genExp (EArrAccess expr1 expr2) dest = do



genCmp :: EExp -> ALabel -> ALabel -> CodeGenStateM [AAsm]
-- genCmp e _ _ | trace ("genCmp " ++ show e ++ "\n") False = undefined
genCmp (EBinop op e1 e2) l l'
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
genCmp (EUnop LNot e) l l' = genCmp e l' l
genCmp EF _l l' = return [AControl $ AJump l']
genCmp ET l _l' = return [AControl $ AJump l]
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
genRelOp o = error $ "Operator is not a RelOp: " ++ show o

argRegs :: [ALoc]
argRegs = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6]

testGenEast :: IO ()
testGenEast = do
    let east =
            ESeq
                (EDecl
                     "f"
                     (ARROW [("x", INTEGER)] INTEGER)
                     (EDef "f" (ARROW [("x", INTEGER)] INTEGER) (ERet (Just $ EInt 1))))
                (EDecl
                     "g"
                     (ARROW [("x", INTEGER)] INTEGER)
                     (EDef "g" (ARROW [("x", INTEGER)] INTEGER) (ERet (Just $ EFunc "f" [EIdent "x"]))))
        funs = aasmGen east
    putStr $ show funs

testGenRecursion :: IO ()
testGenRecursion = do
    let east =
            EDecl
                "fact"
                (ARROW [("x", INTEGER)] INTEGER)
                (EDef
                     "fact"
                     (ARROW [("x", INTEGER)] INTEGER)
                     (EIf (EBinop Eql (EIdent "x") (EInt 0))
                          (ERet (Just $ EInt 1))
                          (ERet $ Just $ EBinop Mul (EFunc "fact" [EBinop Sub (EIdent "x") (EInt 1)]) (EIdent "x"))))
        funs = aasmGen east
    putStr $ show east
    putStr "\n"
    putStr $ show funs