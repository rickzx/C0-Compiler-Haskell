{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>

   Abstract Assembly operations
-}
module Compile.Types.Ops where

-- For abstract assembly
data AOp
  = AAdd
  | AAddq
  | ASub
  | ASubq
  | ADiv
  | ADivq
  | AMul
  | AMulq
  | AMod
  | AModq
  | ANop
  deriving Eq

data ARelOp
  = Aeq
  | Ane
  | Alt
  | Agt
  | Ale
  | Age

-- For AST
data Binop = Add | Sub | Mul | Div | Mod 
  | Xor | And | Lshift | Rshift | Or | Leq 
  | Geq | Less | Greater | BoolAnd | BoolEq | NotEq | BoolOr
  deriving Eq

data Unop = Neg | Not | Cmpl deriving Eq

data Postop = Incr | Decr deriving Eq

data Asnop
  = AsnOp Binop
  | Equal
  deriving Eq

instance Show AOp where
  show AAdd = "+"
  show AAddq = "+"
  show ASub = "-"
  show ASubq = "-"
  show ADiv = "/"
  show ADivq = "/"
  show AMul = "*"
  show AMulq = "*"
  show AMod = "%"
  show AModq = "%"
  show ANop = "[nop]"

instance Show Binop where
  show Mul = "*"
  show Add = "+"
  show Sub = "-"
  show Div = "/"
  show Mod = "%"
  show Xor = "^"
  show And = "&"
  show Lshift = "<<"
  show Rshift = ">>"
  show BoolAnd = "&&"
  show BoolEq = "=="
  show NotEq = "!="
  show BoolOr = "||"
  show Or = "|"
  show Leq = "<="
  show Geq = ">="
  show Less = "<"
  show Greater = ">"

instance Show Unop where
  show Neg = "-"
  show Not = "!"
  show Cmpl = "~"

instance Show Asnop where
  show (AsnOp binop) = (show binop) ++ "="
  show Equal = "="

instance Show Postop where
  show Incr = "++"
  show Decr = "--"

instance Show ARelOp where
  show Aeq = "="
  show Ane = "!="
  show Alt = "<"
  show Agt = ">"
  show Ale = "<="
  show Age = ">="

