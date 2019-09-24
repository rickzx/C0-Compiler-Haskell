{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Defines the AST we parse to
-}
module Compile.Types.AST where

import Compile.Types.Ops

type Ident = String

data AST = Block [Stmt] deriving Eq

data Stmt
  = Decl Decl
  | Simp Simp
  | Retn Exp
  | Block [Stmt]
  | Control Control
  | Exp Exp
  deriving Eq

data Simpopt
  = Nop
  | Simp Simp

data Elseopt
  = Nop
  | Else Stmt

data Decl
  = JustDecl { dVar :: Ident }
  | DeclAsgn { dVar :: Ident, dExp :: Exp }
  deriving Eq

data Simp = Asgn Ident Asnop Exp deriving Eq
data Exp
  = Int Int
  | Bool Int
  | Ident Ident
  | Binop Binop Exp Exp
  | Unop Unop Exp
  | Control Control
  deriving Eq

data Control
  = Condition { dBool :: Exp, dTrue :: Stmt, dElse :: Elseopt}
  | Loop {init :: Simpopt, cond :: Exp, step :: Simpopt, body :: Stmt}
  | Retn Exp
  deriving Eq

-- Note to the student: You will probably want to write a new pretty printer
-- using the module Text.PrettyPrint.HughesPJ from the pretty package
-- This is a quick and dirty pretty printer.
-- Once that is written, you may find it helpful for debugging to switch
-- back to the deriving Show instances.

instance Show AST where
  show (Block stmts) =
    "int main () {\n" ++ (unlines $ map (\stmt ->"\t" ++ show stmt) stmts) ++ "}\n"

instance Show Stmt where
  show (Decl d) = show d
  show (Simp simp) = show simp
  show (Retn e) = "return " ++ show e ++ ";"

instance Show Decl where
  show (JustDecl i) = "int " ++ i ++ ";"
  show (DeclAsgn x e) = "int " ++ x ++ " = " ++ show e ++ ";"

instance Show Simp where
  show (Asgn lval asnop expr) = lval ++ " " ++ show asnop ++ " " ++ show expr ++ ";"

instance Show Exp where
  show (Int x) = show x
  show (Ident var) = var
  show (Binop binop expr1 expr2) =
    show expr1 ++ " " ++ show binop ++ " " ++ show expr2
  show (Unop unop expr) = show unop ++ show expr
