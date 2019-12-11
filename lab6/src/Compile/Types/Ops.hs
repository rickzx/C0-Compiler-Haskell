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
  | ANopq
  | ANopb -- for char
  | ABAnd -- Bitwise And
  | ALAnd -- Logical And
  | ABOr  -- Bitwise Or
  | ALOr  -- Logical Or
  | ABNot -- Bitwise Not
  | ALNot -- Logical Not
  | ASal
  | ASar
  | AXor
  | ALeaq
  deriving Eq

data ARelOp
  = AEq
  | AEqq
  | ANe
  | ANeq
  | ALt
  | AGt
  | ALe
  | AGe
  | AEqb
  | ANeb
  | ALtb
  | AGtb
  | ALeb
  | AGeb
  deriving Eq

-- For AST
data Binop = Add | Sub | Mul | Div | Mod |
  BAnd | LAnd | BOr | LOr | Xor |
  Eql | Neq | Lt | Gt | Le | Ge | Sal | Sar |
  Eqlq | Neqq | Eqlb | Neqb | Ltb | Gtb | Leb | Geb  deriving Eq

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
  show ANopq = "[nop]"
  show ANopb = "[nop]"
  show ABAnd = "&"
  show ALAnd = "&&"
  show ABOr  = "|"
  show ALOr  = "||"
  show ABNot = "~"
  show ALNot = "!"
  show AXor  = "^"
  show ASal = "<<"
  show ASar = ">>"
  show ALeaq = "leaq"

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
  show Eql = "=="
  show Eqlq = "=="
  show Neq = "!="
  show Neqq = "!="
  show Lt = "<"
  show Gt = ">"
  show Le = "<="
  show Ge = ">="
  show Sal = "<<"
  show Sar = ">>"
  show Eqlb = "=="
  show Neqb = "!="
  show Ltb = "<"
  show Gtb = ">"
  show Leb = "<="
  show Geb = ">="

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
  show AEqq = "="
  show ANe = "!="
  show ANeq = "!="
  show ALt = "<"
  show AGt = ">"
  show ALe = "<="
  show AGe = ">="
  show AEqb = "="
  show ANeb = "!="
  show ALtb = "<"
  show AGtb = ">"
  show ALeb = "<="
  show AGeb = ">="


isRelOp :: Binop -> Bool
isRelOp op
  | op == Eql || op == Neq || op == Lt || op == Gt || op == Le || op == Ge || op == Eqlq || op == Neqq || op == Eqlb 
  || op == Neqb || op == Ltb || op == Gtb || op == Leb || op == Geb 
  = True
  | otherwise
  = False

