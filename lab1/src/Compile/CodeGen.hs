{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Currently just a pseudolanguage with 3-operand instructions and arbitrarily many temps.
-}
module Compile.CodeGen where

import Compile.Types
import qualified Control.Monad.State.Strict as State
import Data.Int
import qualified Data.Map as Map
import Data.Maybe (mapMaybe)

-- | The state during code generation.
data Alloc = Alloc
  { variables :: Map.Map String Int
    -- ^ Map from source variable names to unique variable ids.
  , uniqueIDCounter :: Int
    -- ^ Value greater than any id in the map.
  }

-- Using the state monad with Alloc as the state allows us to implicitly
-- thread the variable map and the next unique ID through the entire
-- computation. (The M in AllocM stands for "Monad".)
type AllocM = State.State Alloc

getNewUniqueID :: AllocM Int
getNewUniqueID = do
  currentCount <- State.gets uniqueIDCounter
  State.modify' $ \(Alloc vs counter) -> Alloc vs (counter + 1)
  return currentCount

-- Get the decls from a sequence of stmts.
getDecls :: [Stmt] -> [Decl]
getDecls = mapMaybe f
  where
    f :: Stmt -> Maybe Decl
    f (Decl d) = Just d
    f _ = Nothing

codeGen :: AST -> [AAsm]
codeGen (Block stmts) = State.evalState assemM initialState
  where
    initialState = Alloc
      { variables = Map.fromList $ zip (map dVar decls) [0..]
      , uniqueIDCounter = length decls
      }
      where
        decls = getDecls stmts

    assemM :: AllocM [AAsm]
    assemM = do
      stmtAssemBlocks <- mapM genStmt stmts
      return $ concat stmtAssemBlocks

genStmt :: Stmt -> AllocM [AAsm]
genStmt (Decl d) = genDecl d
genStmt (Simp simp) = genSimp simp
genStmt (Ret e) = do
  codegen <- genExp e (AReg 0)
  return $ codegen ++ [ARet (ALoc $ AReg 0)]

genDecl :: Decl -> AllocM [AAsm]
genDecl (JustDecl _) = return []
genDecl (DeclAsgn v e) = genSimp (Asgn v Equal e)

genSimp :: Simp -> AllocM [AAsm]
genSimp (Asgn v asnop expr) = do
  allocmap <- State.gets variables
  let
    tmpNum = ATemp $ allocmap Map.! v
    expr' = case asnop of
      Equal -> expr
      AsnOp binop -> Binop binop (Ident v) expr
  genExp expr' tmpNum

genExp :: Exp -> ALoc -> AllocM [AAsm]
genExp (Int n) dest = return [AAsm [dest] ANop [AImm $ fromIntegral $ ((fromIntegral n) :: Int32)]]
genExp (Ident var) dest = do
  allocmap <- State.gets variables
  return [AAsm [dest] ANop [ALoc $ ATemp $ allocmap Map.! var]]
genExp (Binop binop exp1 exp2) dest = do
  n <- getNewUniqueID
  codegen1 <- genExp exp1 (ATemp n)
  n' <- getNewUniqueID
  codegen2 <- genExp exp2 (ATemp n')
  let combine = [AAsm [dest] (genBinOp binop) [ALoc $ ATemp n, ALoc $ ATemp n']]
  return $ codegen1 ++ codegen2 ++ combine
genExp (Unop _unop expr) dest = do
  n <- getNewUniqueID
  cogen <- genExp expr (ATemp n)
  let assign = [AAsm [dest] ASub [AImm 0, ALoc $ ATemp n]]
  return $ cogen ++ assign

genBinOp :: Binop -> AOp
genBinOp Add = AAdd
genBinOp Sub = ASub
genBinOp Div = ADiv
genBinOp Mul = AMul
genBinOp Mod = AMod
