{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Defines a flat abstract assembly.
-}
module Compile.Types.AbstractAssembly where

import Compile.Types.Ops
import qualified Data.Set as Set

type ALabel = String
type ALabelP = (String, [ALoc])

data AAsm
  = AAsm
      { aAssign :: [ALoc]
      , aOp     :: AOp
      , aArgs   :: [AVal]
      }
  | ARel
      {
        aAssign :: [ALoc]
      , aRelOp  :: ARelOp
      , aArgs   :: [AVal]
      }
  | AFun ALabel [ALoc]      -- Here, [ALoc] only contains the arguments that should be placed on the stack, if any
  | ACall ALabel [ALoc] Int     -- Here, [ALoc] only contains the arguments that should be placed on the stack, if any
  | ARet AVal
  | AControl ACtrl
  | AComment String

data AVal
  = ALoc ALoc
  | AImm Int deriving (Eq, Ord)

data ALoc
  = AReg Int
  | ATemp Int 
  | APtr ALoc 
  | APtrq ALoc deriving (Eq, Ord)

data ACtrl
  = ALab ALabel
  | AJump ALabel
  | ACJump AVal ALabel ALabel   -- Conditional Jump, if x then l1 else l2
  | ACJump' ARelOp AVal AVal ALabel ALabel  -- Conditional Jump, if (x ? y) then l1 else l2

instance Show AAsm where
  show (AAsm [dest] ANop [src]) = "\t" ++ show dest ++ " <-- " ++ show src ++ "\n"
  show (AAsm [dest] ANopq [src]) = "\t" ++ show dest ++ " <-- " ++ show src ++ "\n"
  show (AAsm [dest] asnop [src1, src2]) =
    "\t" ++ show dest ++ " <-- "
      ++ show src1 ++ " " ++ show asnop ++ " " ++ show src2 ++ "\n"
  show (AAsm [dest] asnop [src]) =
    "\t" ++ show dest ++ " <-- "
      ++ show asnop ++ " " ++ show src ++ "\n"
  show (ARel [dest] relop [src1, src2]) =
    "\t" ++ show dest ++ " <-- "
      ++ show src1 ++ " " ++ show relop ++ " " ++ show src2 ++ "\n"
  show (ARet _) = "\tret %eax\n"
  show (AControl ctrl) = show ctrl ++ "\n"
  show (ACall f xs argNum) = "\tCall " ++ f ++ " with parameters on stack: " ++ show xs ++ ", use " ++ show argNum ++ " registers\n"
  show (AFun f xs) = f ++ " with parameters on stack: " ++ show xs ++ ":\n"
  show _ = "ill-formed\n"

instance Show AVal where
  show (ALoc loc) = show loc
  show (AImm n) = "$" ++ show n

instance Show ALoc where
  show (AReg 0) = "%eax"
  show (AReg 1) = "%edx"
  show (AReg 2) = "%ecx"
  show (AReg 3) = "%edi"
  show (AReg 4) = "%esi"
  show (AReg 5) = "%r8d"
  show (AReg 6) = "%r9d"
  show (AReg 7) = "%r10d"
  show (AReg 8) = "%r11d"
  show (AReg 9) = "%r12d"
  show (AReg 10) = "%r13d"
  show (AReg _) = "%ill-formed"
  show (ATemp n) = "%t" ++ show n
  show (APtr n) = "(" ++ show n ++ ")"
  show (APtrq n) = "(" ++ show n ++ ")"

instance Show ACtrl where
  show (ALab s) = "." ++ s ++ ":"
  show (AJump s) = "\tGoto ." ++ s
  show (ACJump x l1 l2) = "\tIf " ++ show x ++ " goto ." ++ l1 ++ " else goto ." ++ l2
  show (ACJump' op a b l1 l2) = "\tIf " ++ show a ++ " " ++ show op ++ " " ++ show b ++ " goto ." ++ l1 ++ " else goto ." ++ l2

-- A hack to work with an AAsm tool
testPrintAAsm :: [AAsm] -> String -> String
testPrintAAsm prog filename = "\t.file\t\"" ++ filename ++ "\"\n" ++ concatMap show prog


