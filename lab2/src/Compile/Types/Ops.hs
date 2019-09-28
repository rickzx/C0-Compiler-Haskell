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
  | ABAnd -- Bitwise And
  | ALAnd -- Logical And
  | ABOr  -- Bitwise Or
  | ALOr  -- Logical Or
  | ABNot -- Bitwise Not
  | ALNot -- Logical Not
  | AXor
  deriving Eq

data ARelOp
  = AEq
  | ANe
  | ALt
  | AGt
  | ALe
  | AGe

-- For AST
data Binop = Add | Sub | Mul | Div | Mod |
  BAnd | LAnd | BOr | LOr | Xor |
  Eql | Neq | Lt | Gt | Le | Ge | Sal | Sar deriving Eq

data Unop = Neg | LNot | BNot deriving Eq

data Postop = Incr | Decr deriving Eq

data Asnop
  = AsnOp Binop
  | Equal
  deriving Eq

instance Show AOp where
  show AAdd  = "+"
  show AAddq = "+"
  show ASub  = "-"
  show ASubq = "-"
  show ADiv  = "/"
  show ADivq = "/"
  show AMul  = "*"
  show AMulq = "*"
  show AMod  = "%"
  show AModq = "%"
  show ANop  = "[nop]"
  show ABAnd = "&"
  show ALAnd = "&&"
  show ABOr  = "|"
  show ALOr  = "||"
  show ABNot = "~"
  show ALNot = "!"
  show AXor  = "^"

instance Show Binop where
  show Mul = "*"
  show Add = "+"
  show Sub = "-"
  show Div = "/"
  show Mod = "%"
  show BAnd = "&"
  show LAnd = "&&"
  show BOr  = "|"
  show LOr  = "||"
  show Xor  = "^"
  show Eql = "="
  show Neq = "!="
  show Lt = "<"
  show Gt = ">"
  show Le = "<="
  show Ge = ">="
  show Sal = "<<"
  show Sar = ">>"

instance Show Unop where
  show Neg = "-"
  show LNot = "!"
  show BNot = "~"

instance Show Asnop where
  show (AsnOp binop) = (show binop) ++ "="
  show Equal         = "="

instance Show Postop where
  show Incr = "++"
  show Decr = "--"

instance Show ARelOp where
  show AEq = "="
  show ANe = "!="
  show ALt = "<"
  show AGt = ">"
  show ALe = "<="
  show AGe = ">="

isRelOp :: Binop -> Bool
isRelOp op
  | op == Eql || op == Neq || op == Lt || op == Gt || op == Le || op == Ge
  = True
  | otherwise
  = False

