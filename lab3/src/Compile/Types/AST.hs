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

data Type = 
    INTEGER 
  | BOOLEAN 
  | VOID
  | NONE --for debug
  | DEF Ident
  | ARROW [(Ident, Type)] Type deriving Eq

data AST = Program [Gdecl] deriving Eq

data Gdecl =
    Fdecl {rtype :: Type, name :: Ident, parameters :: [(Type, Ident)]}
  | Fdefn {rtype :: Type, name :: Ident, parameters :: [(Type, Ident)], block :: [Stmt]}
  | Typedef {rtype :: Type, name :: Ident}
  deriving Eq

data Stmt
  = Simp Simp
  | Stmts [Stmt]
  | ControlStmt Control
  deriving Eq

data Simpopt 
  = SimpNop
  | Opt Simp
  deriving Eq

data Elseopt
  = ElseNop
  | Else Stmt
  deriving Eq

data Decl
  = JustDecl { dVar :: Ident, dType :: Type}
  | DeclAsgn { dVar :: Ident, dType :: Type, dExp :: Exp}
  deriving Eq

data Simp = Asgn Ident Asnop Exp
  | AsgnP Ident Postop
  | Decl Decl
  | Exp Exp deriving Eq

data Exp
  = Int Int
  | T
  | F
  | Ident Ident
  | Binop Binop Exp Exp
  | Unop Unop Exp
  | Ternop Exp Exp Exp -- e1 ? e2 : e3
  | Function Ident [Exp]
  deriving Eq

data Control
  = Condition { dBool :: Exp, dTrue :: Stmt, dElse :: Elseopt}
  | For {initial :: Simpopt, cond :: Exp, step :: Simpopt, body :: Stmt}
  | While {cond :: Exp, body :: Stmt}
  | Assert {cond :: Exp}
  | Void
  | Retn Exp
  deriving Eq
{-
-- Note to the student: You will probably want to write a new pretty printer
-- using the module Text.PrettyPrint.HughesPJ from the pretty package
-- This is a quick and dirty pretty printer.
-- Once that is written, you may find it helpful for debugging to switch
-- back to the deriving Show instances.

--TODO: Change this to match our new structures
instance Show AST where
  show (Block stmts) =
    "int main () {\n" ++ (unlines $ map (\stmt ->"\t" ++ show stmt) stmts) ++ "}\n"

instance Show Stmt where
  show (Stmts [Stmt]) = show Stmt
  show (ControlStmt Control) = show Control
  show (Simp simp) = show simp
  show (Exp e) = show e

instance Show Control where 
  show (Condition b t e) = "if " + show b + " then " + show t + " else " + show e
  show (Retn e) = "return " ++ show e ++ ";"

instance Show Decl where
  show (JustDecl i) = "int " ++ i ++ ";"
  show (DeclAsgn x e) = "int " ++ x ++ " = " ++ show e ++ ";"

instance Show Simp where
  show (Asgn lval asnop expr) = lval ++ " " ++ show asnop ++ " " ++ show expr ++ ";"
-}
instance Show Type where
  show INTEGER = "int"
  show BOOLEAN = "bool"
  show VOID = "void"
  show (ARROW args res) = show args ++ " -> " ++ show res
  show NONE = "error"
  show (DEF a) = "def " ++ a

instance Show Exp where
  show (Int x) = show x
  show (Ident var) = var
  show T = "True"
  show F = "False"
  show (Binop binop expr1 expr2) =
    show expr1 ++ " " ++ show binop ++ " " ++ show expr2
  show (Ternop expr1 expr2 expr3) = 
    show expr1 ++ " ? " ++ show expr2 ++ " :" ++ show expr3
  show (Unop unop expr) = show unop ++ show expr
  show (Function identi exprlist) = 
      identi ++ "(" ++ (foldr redu_fn "" exprlist) ++ ")"
      where 
        redu_fn :: Exp -> String -> String
        redu_fn e stri = show e ++ "," ++ stri
