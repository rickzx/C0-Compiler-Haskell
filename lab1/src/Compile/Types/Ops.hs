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

-- For AST
data Binop = Add | Sub | Mul | Div | Mod | Lshift
  | Rshift | And | Xor | Or | BoolAnd | BoolOr deriving Eq
data Unop = Neg | Not | Cmpl deriving Eq
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

instance Show Unop where
  show Neg = "-"

instance Show Asnop where
  show (AsnOp binop) = (show binop) ++ "="
  show Equal = "="

