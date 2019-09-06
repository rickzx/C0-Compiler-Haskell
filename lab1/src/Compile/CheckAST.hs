{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
   Beginnings of a typechecker
-}
module Compile.CheckAST where

import Control.Monad.State
import Control.Monad.Trans.Except

import qualified Data.Set as Set

import Compile.Types

-- Note to the student:
-- When your checker gets larger, you may wish to use something like a record
-- to make the state a little more explicit. A tuple does not scale.

type TypeCheckState = (Set.Set Ident, Set.Set Ident)

runExceptState :: ExceptT String (State s) a -> s -> Either String a
runExceptState m = evalState (runExceptT m)

assertMsg :: (Monad m) => String -> Bool -> ExceptT String m ()
assertMsg _ True  = return ()
assertMsg s False = throwE s

assertMsgE :: String -> Bool -> Either String ()
assertMsgE _ True  = Right ()
assertMsgE s False = Left s

typeCheck :: AST -> Either String ()
typeCheck (Block stmts) = do
  hasReturn <- or <$> runExceptState (mapM checkStmt stmts) (Set.empty, Set.empty)
  assertMsgE "main does not return" hasReturn
  return ()

checkStmt :: Stmt -> ExceptT String (State TypeCheckState) Bool
checkStmt (Decl decl) = do
  _ <- checkDecl decl
  return False
checkStmt (Simp simp) = do
  _ <- checkSimp simp
  return False
checkStmt (Ret e) = do
  checkExp e
  -- Because we only have straightline code, at each ret, we'll "define" each declared variable.
  (declared, defined) <- get
  put (declared, Set.union declared defined)
  return True

checkDecl :: Decl -> ExceptT String (State TypeCheckState) Bool
checkDecl (JustDecl var) = do
  (declared, defined) <- get
  assertMsg "Variable already declared" (Set.notMember var declared)
  assertMsg "Variable already defined" (Set.notMember var defined)
  put (Set.insert var declared, defined)
  return False
checkDecl (DeclAsgn var expr) = do
  (declared, defined) <- get
  assertMsg "Variable already declared" (Set.notMember var declared)
  assertMsg "Variable already defined" (Set.notMember var defined)
  checkExp expr
  put (Set.insert var declared, Set.insert var defined)
  return False

checkSimp :: Simp -> ExceptT String (State TypeCheckState) Bool
checkSimp (Asgn var asnop expr) = do
  (declared, defined) <- get
  assertMsg "Variable not declared earlier" (Set.member var declared)
  case asnop of
    AsnOp _ -> do
      assertMsg "Variable not defined earlier" (Set.member var defined)
      checkExp expr
      return False
    Equal -> do
      checkExp expr
      put (declared, Set.insert var defined)
      return False

checkExp :: Exp -> ExceptT String (State TypeCheckState) ()
checkExp (Int _) = return () -- We already checked int sizes in the parser
checkExp (Ident var) = do
  (declared, defined) <- get
  assertMsg "Variable not declared" (Set.member var declared)
  assertMsg "Variable not defined" (Set.member var defined)
checkExp (Binop _ exp1 exp2) = do
  checkExp exp1
  checkExp exp2
checkExp (Unop _ expr) = checkExp expr
