{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Defines a flat abstract assembly.
-}
module Compile.Types.AbstractAssembly where

import Compile.Types.Ops

type ALabel = String

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
  | ARet AVal
  | AControl ACtrl
  | AComment String

data AVal
  = ALoc ALoc
  | AImm Int deriving (Eq, Ord)

data ALoc
  = AReg Int
  | ATemp Int deriving (Eq, Ord)

data ACtrl
  = ALab ALabel
  | AJump ALabel
  | ACJump AVal ALabel ALabel   -- Conditional Jump, if x then l1 else l2
  | ACJump' ARelOp AVal AVal ALabel ALabel  -- Conditional Jump, if (x ? y) then l1 else l2

instance Show AAsm where
  show (AAsm [dest] ANop [src]) = "\t" ++ show dest ++ " <-- " ++ show src ++ "\n"
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
  show _ = "ill-formed\n"

instance Show AVal where
  show (ALoc loc) = show loc
  show (AImm n) = "$" ++ (show n)

instance Show ALoc where
  show (AReg 0) = "%eax"
  show (AReg 1) = "%edx"
  show (AReg 2) = "%ecx"
  show (AReg _) = "%ill-formed"
  show (ATemp n) = "%t" ++ (show n)

instance Show ACtrl where
  show (ALab s) = ".L" ++ s ++ ":"
  show (AJump s) = "\tGoto L" ++ s
  show (ACJump x l1 l2) = "\tIf " ++ show x ++ " goto L" ++ l1 ++ " else goto L" ++ l2
  show (ACJump' op a b l1 l2) = "\tIf " ++ show a ++ " " ++ show op ++ " " ++ show b ++ " goto L" ++ l1 ++ " else goto L" ++ l2

-- A hack to work with an AAsm tool
testPrintAAsm :: [AAsm] -> String -> String
testPrintAAsm prog filename =
  let
    header = "\t.file\t\"" ++ filename ++ "\"\n"
    footer = "\t.ident\t\"15-411 L1 Haskell Starter Code\"\n"
  in
  header ++ concatMap (\line -> show line) prog ++ footer


