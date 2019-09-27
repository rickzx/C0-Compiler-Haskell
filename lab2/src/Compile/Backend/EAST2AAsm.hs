module Compile.Backend.EAST2AAsm where

import           Compile.Types
import qualified Control.Monad.State.Strict    as State
import           Data.Int
import qualified Data.Map                      as Map
import           Debug.Trace

-- | The state during code generation.
data Alloc = Alloc
  { variables :: Map.Map String Int
    -- ^ Map from source variable names to unique variable ids.
  , uniqueIDCounter :: Int
    -- ^ Value greater than any id in the map.
  , uniqueLabelCounter :: Int
    -- ^ Next label to generate.
  }

-- Using the state monad with Alloc as the state allows us to implicitly
-- thread the variable map and the next unique ID through the entire
-- computation. (The M in AllocM stands for "Monad".)
type AllocM = State.State Alloc

getNewUniqueID :: AllocM Int
getNewUniqueID = do
  currentCount <- State.gets uniqueIDCounter
  State.modify' $ \(Alloc vs counter lab) -> Alloc vs (counter + 1) lab
  return currentCount

getNewUniqueLabel :: AllocM Int
getNewUniqueLabel = do
  currentCount <- State.gets uniqueLabelCounter
  State.modify' $ \(Alloc vs counter lab) -> Alloc vs counter (lab + 1)
  return currentCount

-- Get the decls from a sequence of stmts.

aasmGen :: EAST -> ([AAsm], Int)
aasmGen east = State.evalState assemM initialState
 where
  initialState = Alloc { variables          = Map.fromList $ zip decls [0 ..]
                       , uniqueIDCounter    = length decls
                       , uniqueLabelCounter = 0
                       }
    where decls = getDecls east

  assemM :: AllocM ([AAsm], Int)
  assemM = do
    eastAssm <- genEast east
    localVar <- getNewUniqueID
    return (eastAssm, localVar)

getDecls :: EAST -> [Ident]
getDecls (ESeq e1 e2 ) = getDecls e1 ++ getDecls e2
getDecls (EIf _ e1 e2) = getDecls e1 ++ getDecls e2
getDecls (EWhile _ e ) = getDecls e
getDecls (EDecl x _ e) = x : getDecls e
getDecls _             = []

genEast :: EAST -> AllocM [AAsm]
genEast (ESeq e1 e2) = do
  gen1 <- genEast e1
  gen2 <- genEast e2
  return $ gen1 ++ gen2
genEast (EAssign x expr) = do
  allocMap <- State.gets variables
  let tmpNum = ATemp $ allocMap Map.! x
  genExp expr tmpNum
genEast (EIf expr e1 e2) = do
  l1   <- fmap show getNewUniqueLabel
  l2   <- fmap show getNewUniqueLabel
  l3   <- fmap show getNewUniqueLabel

  cmp  <- genCmp expr l1 l2
  gen1 <- genEast e1
  gen2 <- genEast e2

  return
    $  cmp
    ++ [AControl $ ALab l1]
    ++ gen1
    ++ [AControl $ AJump l3, AControl $ ALab l2]
    ++ gen2
    ++ [AControl $ AJump l3, AControl $ ALab l3]
genEast (EWhile expr e) = do
  l1  <- fmap show getNewUniqueLabel   -- label before while guard
  l2  <- fmap show getNewUniqueLabel   -- label of the while block
  l3  <- fmap show getNewUniqueLabel   -- label after while block

  cmp <- genCmp expr l2 l3
  gen <- genEast e

  return
    $  [AControl $ ALab l1]
    ++ cmp
    ++ [AControl $ ALab l2]
    ++ gen
    ++ [AControl $ AJump l1, AControl $ ALab l3]
genEast (ERet expr) = do
  gen <- genExp expr (AReg 0)
  return $ gen ++ [ARet (ALoc $ AReg 0)]
genEast ENop          = return []
genEast (EDecl _ _ e) = genEast e

genExp :: EExp -> ALoc -> AllocM [AAsm]
genExp (EInt n) dest =
  return [AAsm [dest] ANop [AImm $ fromIntegral (fromIntegral n :: Int32)]]
genExp (EIdent var) dest = do
  allocmap <- State.gets variables
  return [AAsm [dest] ANop [ALoc $ ATemp $ allocmap Map.! var]]
genExp expr@(EBinop binop exp1 exp2) dest
  | isRelOp binop = do
    n        <- getNewUniqueID
    codegen1 <- genExp exp1 (ATemp n)
    n'       <- getNewUniqueID
    codegen2 <- genExp exp2 (ATemp n')
    let combine =
          [ARel [dest] (genRelOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
    return $ codegen1 ++ codegen2 ++ combine
  | binop == LAnd || binop == LOr = do
    l1  <- fmap show getNewUniqueLabel
    l2  <- fmap show getNewUniqueLabel
    l3  <- fmap show getNewUniqueLabel

    cmp <- genCmp expr l1 l2
    return
      $  cmp
      ++ [ AControl $ ALab l1
         , AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)]
         , AControl $ AJump l3
         ]
      ++ [ AControl $ ALab l2
         , AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]
         , AControl $ AJump l3
         ]
      ++ [AControl $ ALab l3]
  | otherwise = do
    n        <- getNewUniqueID
    codegen1 <- genExp exp1 (ATemp n)
    n'       <- getNewUniqueID
    codegen2 <- genExp exp2 (ATemp n')
    let combine =
          [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
    return $ codegen1 ++ codegen2 ++ combine

genExp (EUnop unop expr) dest = case unop of
  LNot -> do
    l1  <- fmap show getNewUniqueLabel
    l2  <- fmap show getNewUniqueLabel
    l3  <- fmap show getNewUniqueLabel

    cmp <- genCmp expr l1 l2
    return
      $  cmp
      ++ [ AControl $ ALab l1
         , AAsm [dest] ANop [AImm $ fromIntegral (1 :: Int32)]
         , AControl $ AJump l3
         ]
      ++ [ AControl $ ALab l2
         , AAsm [dest] ANop [AImm $ fromIntegral (0 :: Int32)]
         , AControl $ AJump l3
         ]
      ++ [AControl $ ALab l3]
  _ -> case expr of
    (EInt n) -> return
      [AAsm [dest] ANop [AImm $ fromIntegral ((fromIntegral $ -n) :: Int32)]]
    _ -> do
      n     <- getNewUniqueID
      cogen <- genExp expr (ATemp n)
      let assign = [AAsm [dest] ASub [AImm 0, ALoc $ ATemp n]]
      return $ cogen ++ assign

genCmp :: EExp -> ALabel -> ALabel -> AllocM [AAsm]
genCmp (EBinop op e1 e2) l l'
  | isRelOp op = do
    n    <- getNewUniqueID
    gen1 <- genExp e1 (ATemp n)
    n'   <- getNewUniqueID
    gen2 <- genExp e2 (ATemp n')
    return
      $  gen1
      ++ gen2
      ++ [ AControl
             $ ACJump' (genRelOp op) (ALoc $ ATemp n) (ALoc $ ATemp n') l l'
         ]
  | op == LAnd = do
    l2   <- fmap show getNewUniqueLabel
    gen1 <- genCmp e1 l2 l
    gen2 <- genCmp e2 l l'
    return $ gen1 ++ [AControl $ ALab l2] ++ gen2
  | op == LOr = do
    l2   <- fmap show getNewUniqueLabel
    gen1 <- genCmp e1 l l2
    gen2 <- genCmp e2 l l'
    return $ gen1 ++ [AControl $ ALab l2] ++ gen2
genCmp (EUnop LNot e) l  l'  = genCmp e l' l
genCmp (EInt 0      ) _l l'  = return [AControl $ AJump l']
genCmp (EInt 1      ) l  _l' = return [AControl $ AJump l]
genCmp e             l  l'  = do
  n   <- getNewUniqueID
  gen <- genExp e (ATemp n)
  return $ gen ++ [AControl $ ACJump (ALoc $ ATemp n) l l']


genBinOp :: Binop -> AOp
genBinOp Add  = AAdd
genBinOp Sub  = ASub
genBinOp Div  = ADiv
genBinOp Mul  = AMul
genBinOp Mod  = AMod
genBinOp BAnd = ABAnd
genBinOp BOr  = ABOr
genBinOp BNot = ABNot
genBinOp Xor  = AXor
genBinOp o    = error $ "Operator not found: " ++ show o

genRelOp :: Binop -> ARelOp
genRelOp Eql = AEq
genRelOp Neq = ANe
genRelOp Lt  = ALt
genRelOp Gt  = AGt
genRelOp Le  = ALe
genRelOp Ge  = AGe
genRelOp o   = error $ "Operator is not a RelOp: " ++ show o


testGenEast :: IO ()
testGenEast = do
  let east = EDecl
        "x"
        Integer
        (EDecl
          "y"
          Integer
          (ESeq (EIf (EInt 1) (EAssign "x" (EInt 1)) (EAssign "x" (EInt 2)))
                (ERet (EBinop Add (EIdent "x") (EIdent "y")))
          )
        )
      (aasms, _) = aasmGen east
  putStr $ show $ getDecls east
  putStr "\n"
  putStr $ show aasms
