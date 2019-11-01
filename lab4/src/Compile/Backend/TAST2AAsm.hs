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
        }

-- Using the state monad with CodeGenState as the state allows us to implicitly
-- thread the variable map and the next unique ID through the entire
-- computation. (The M in CodeGenStateM stands for "Monad".)
type CodeGenStateM = State.State CodeGenState

getNewUniqueID :: CodeGenStateM Int
getNewUniqueID = do
    currentCount <- State.gets uniqueIDCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf) -> CodeGenState vs (counter + 1) lab genf cf
    return currentCount

getNewUniqueLabel :: CodeGenStateM String
getNewUniqueLabel = do
    currentCount <- State.gets uniqueLabelCounter
    State.modify' $ \(CodeGenState vs counter lab genf cf) -> CodeGenState vs counter (lab + 1) genf cf
    let lab = "L" ++ show currentCount
    return lab

--for each term, (function name, AASM generated, # of var)
aasmGen :: TAST -> [(Ident, ([AAsm], Int))]
aasmGen east = State.evalState assemM initialState
  where
    initialState =
        CodeGenState
            { variables = Map.empty
            , uniqueIDCounter = 0
            , uniqueLabelCounter = 0
            , genFunctions = []
            , currentFunction = ""
            }
    assemM :: CodeGenStateM [(Ident, ([AAsm], Int))]
    assemM = do
        _genAAsm <- genEast east
        CodeGenState _ _ _ genf _ <- State.get
        return (reverse genf)

-- Get the decls from a sequence of stmts.
getDecls :: TAST -> [Ident]
getDecls (TSeq e1 e2) = getDecls e1 ++ getDecls e2
getDecls (TIf _ e1 e2) = getDecls e1 ++ getDecls e2
getDecls (TWhile _ e) = getDecls e
getDecls (TDecl x _ e) = x : getDecls e
getDecls _ = []

genEast :: TAST -> CodeGenStateM [AAsm]
genEast (TSeq e1 e2) = do
    gen1 <- genEast e1
    gen2 <- genEast e2
    return $ gen1 ++ gen2
genEast (TAssign (TVIdent x _) expr _b) = do
    allocMap <- State.gets variables
    let tmpNum = ATemp $ allocMap Map.! x
    genExp expr tmpNum
genEast (TDef fn t e) = do
    let ARROW ts _r = t
        args = map fst ts
        decls = args ++ getDecls e
        v' = Map.fromList $ zip decls [0 ..]
    State.modify' $ \(CodeGenState _vs _counter lab genf _cf) -> CodeGenState v' (length decls) lab genf fn
    let (inReg, inStk) = splitAt 6 (map (\a -> ATemp $ v' Map.! a) args)
        movArg = map (\(i, tmp) -> AAsm [tmp] ANop [ALoc $ argRegs !! i]) $ zip [0 ..] inReg
    gen <- genEast e
    let funGen = [AFun fn inStk] ++ movArg ++ gen
    State.modify' $ \(CodeGenState vs counter lab genf cf) -> CodeGenState vs counter lab ((fn, (funGen, counter)) : genf) cf
    return funGen
genEast (TAssert expr) = do
    let trans = TIf expr TNop (TLeaf $ TFunc "abort" [] VOID)
    genEast trans
genEast (TIf TT e1 _e2) = genEast e1
genEast (TIf TF _e1 e2) = genEast e2
genEast (TIf expr e1 e2) = do
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
genEast (TWhile expr e) = do
    l1 <- getNewUniqueLabel -- label before while guard
    l2 <- getNewUniqueLabel -- label of the while block
    l3 <- getNewUniqueLabel -- label after while block
    cmp <- genCmp expr l2 l3
    gen <- genEast e
    return $ [AControl $ ALab l1] ++ cmp ++ [AControl $ ALab l2] ++ gen ++ [AControl $ AJump l1, AControl $ ALab l3]
genEast (TRet expr) = do
    fn <- State.gets currentFunction
    let fname = if fn == "a bort" then "_c0_abort_local411" else "_c0_" ++ fn
    case expr of
        Just e -> do
            gen <- genExp e (AReg 0)
            return $ gen ++ [AControl $ AJump $ fname ++ "_ret"]
        Nothing -> return [AControl $ AJump $ fname ++ "_ret"]
genEast TNop = return []
genEast (TDecl _ _ e) = genEast e
genEast (TLeaf e) = genSideEffect e

genSideEffect :: TExp -> CodeGenStateM [AAsm]
genSideEffect (TFunc fn args _) = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANop [ALoc tmp]) $ zip [0 ..] inReg
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg)]
genSideEffect expr = do
    n <- getNewUniqueID
    genExp expr (ATemp n)

genExp :: TExp -> ALoc -> CodeGenStateM [AAsm]
-- genExp e _ | trace ("genExp " ++ show e ++ "\n") False = undefined
genExp (TInt n) dest = return [AAsm [dest] ANop [AImm $ fromIntegral (fromIntegral n :: Int32)]]
genExp (TIdent var _) dest = do
    allocmap <- State.gets variables
    return [AAsm [dest] ANop [ALoc $ ATemp $ allocmap Map.! var]]
genExp TT dest = return [AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)]]
genExp TF dest = return [AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]]
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
        n <- getNewUniqueID
        gen1 <- genExp exp1 (ATemp n)
        n' <- getNewUniqueID
        gen2 <- genExp exp2 (ATemp n')
        let checker = TBinop LAnd (TBinop Le (TInt 0) exp2) (TBinop Lt exp2 (TInt 32))
            combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
        l1 <- getNewUniqueLabel
        l2 <- getNewUniqueLabel
        l3 <- getNewUniqueLabel
        cmp <- genCmp checker l1 l2
        genl2 <- genExp (TBinop Div (TInt 1) (TInt 0)) dest
        return $ gen1 ++ gen2 ++ cmp ++ [AControl $ ALab l1] ++ combine ++ [AControl $ AJump l3, AControl $ ALab l2]
                ++ genl2 ++ [AControl $ AJump l3, AControl $ ALab l3]
    | binop == Add || binop == Sub || binop == Mul =
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
genExp (TTernop e1 e2 e3 _) dest =
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
genExp (TFunc fn args _) dest = do
    let argLen = length args
    ids <- replicateM argLen getNewUniqueID
    let tmpVars = map ATemp ids
    gens <- mapM (\(i, e) -> genExp e (tmpVars !! i)) $ zip [0 ..] args
    let gen = join gens
    let (inReg, inStk) = splitAt 6 tmpVars
        movArg = map (\(i, tmp) -> AAsm [argRegs !! i] ANop [ALoc tmp]) $ zip [0 ..] inReg
    return $ gen ++ movArg ++ [ACall fn inStk (length inReg), AAsm [dest] ANop [ALoc $ AReg 0]]

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
genRelOp o = error $ "Operator is not a RelOp: " ++ show o

argRegs :: [ALoc]
argRegs = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6]