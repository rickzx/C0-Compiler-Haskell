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
    | CHAR
    | STRING
    | POLY Ident -- generic type
    | DEF Ident
    | POINTER Type
    | ARRAY Type
    | STRUCT Ident
    | ARROW [(Ident, Type)] Type
    | FUNPTR [Type] Type
    | GENSTRUCT [Type] Ident
    | ANY deriving (Eq, Ord)
  
  data AST = Program [Gdecl] deriving (Eq, Show)
  
  data Gdecl =
      Fdecl {rtype :: Type, name :: Ident, parameters :: [(Type, Ident)]}
    | Fdefn {rtype :: Type, name :: Ident, parameters :: [(Type, Ident)], block :: [Stmt]}
    | GenFdecl {genTypes :: [Type], rtype :: Type, name :: Ident, parameters :: [(Type, Ident)]}
    | GenFdefn {genTypes :: [Type], rtype :: Type, name :: Ident, parameters :: [(Type, Ident)], block :: [Stmt]}
    | Sdecl {name :: Ident}
    | GenSdecl {name :: Ident, genTypes :: [Type]}
    | Sdef {name :: Ident, param :: [(Ident, Type)]}
    | GenSdef {name :: Ident, genTypes :: [Type], param :: [(Ident, Type)]}
    | Typedef {rtype :: Type, name :: Ident}
    deriving (Eq, Show)
  
  data Stmt
    = Simp Simp
    | Stmts [Stmt]
    | ControlStmt Control
    deriving (Eq, Show)
  
  data Simpopt
    = SimpNop
    | Opt Simp
    deriving (Eq, Show)
  
  data Elseopt
    = ElseNop
    | Else Stmt
    deriving (Eq, Show)
  
  data Decl
    = JustDecl { dVar :: Ident, dType :: Type}
    | DeclAsgn { dVar :: Ident, dType :: Type, dExp :: Exp}
    deriving (Eq, Show)
  
  data Simp = Asgn Exp Asnop Exp -- Exp = all possible lvals
    | AsgnP Exp Postop -- Exp = all possible lvals
    | Decl Decl
    | Exp Exp deriving (Eq, Show)
  
  data Exp
    = Int Int
    | T
    | F
    | NULL
    | Char Char
    | String Ident
    | Ident Ident
    | Alloc Type
    | ArrayAlloc Type Exp -- type, length of array
    | ArrayAccess Exp Exp -- first is the array, second is the idx
    | Binop Binop Exp Exp
    | Unop Unop Exp
    | Ternop Exp Exp Exp -- e1 ? e2 : e3
    | Function Ident [Exp]
    | RefFun Ident
    | RefFunApply Ident [Exp]
    | Field Exp Ident -- Exp repressents struct, Ident = field name
    | Access Exp Ident -- Struct and name for ptr access
    | Ptrderef Exp 
    deriving Eq
  
  data Control
    = Condition { dBool :: Exp, dTrue :: Stmt, dElse :: Elseopt}
    | For {initial :: Simpopt, cond :: Exp, step :: Simpopt, body :: Stmt}
    | While {cond :: Exp, body :: Stmt}
    | Assert {cond :: Exp}
    | Void
    | Retn Exp
    deriving (Eq, Show)
  
  -- Note to the student: You will probably want to write a new pretty printer
  -- using the module Text.PrettyPrint.HughesPJ from the pretty package
  -- This is a quick and dirty pretty printer.
  -- Once that is written, you may find it helpful for debugging to switch
  -- back to the deriving Show instances.
  
  --TODO: add prints
  instance Show Type where
    show INTEGER = "int"
    show BOOLEAN = "bool"
    show VOID = "void"
    show CHAR = "char"
    show STRING = "string"
    show (ARROW args res) = show args ++ " -> " ++ show res
    show (FUNPTR args res) = show args ++ "->" ++ show res
    show (DEF a) = "def " ++ a
    show (ARRAY a) = show a ++ "[]"
    show (POINTER a) = show a ++ "*"
    show (STRUCT a) = "Struct:" ++ show a
    show (POLY a) = "\'" ++ a
    show (GENSTRUCT gentypes name) = "Struct<" ++ show gentypes ++ ">" ++ show name
  
  instance Show Exp where
    show (Int x) = show x
    show (Ident var) = var
    show (Char x) = show x
    show (String x) = x
    show T = "True"
    show F = "False"
    show NULL = "NULL"
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
    show (RefFun fn) = "&" ++ fn
    show (RefFunApply identi exprlist) =
        "*" ++ identi ++ "(" ++ (foldr redu_fn "" exprlist) ++ ")"
        where
          redu_fn :: Exp -> String -> String
          redu_fn e stri = show e ++ "," ++ stri
    show (Ptrderef e) = "*("++ show e ++ ")"
    show (Alloc typ) = "alloc(" ++ show typ ++ ")"
    show (ArrayAlloc typ len) = "alloc_array(" ++ show typ ++ "," ++ show len ++ ")"
    show (ArrayAccess exp1 exp2) = show exp1 ++ "[" ++ show exp2 ++ "]"
    show (Field exp1 nme) = show exp1 ++ "." ++ show nme
    show (Access exp1 nme) = show exp1 ++ "->" ++ show nme
  
  
  