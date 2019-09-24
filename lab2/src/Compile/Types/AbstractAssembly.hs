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
  | ACJump 
        { aRelOp :: ARelOp
        , aA :: AVal
        , aB :: AVal
        , aL1 :: ALabel
        , aL2 :: ALabel
        }

instance Show AAsm where
  show (AAsm [dest] ANop [src]) = show dest ++ " <-- " ++ show src ++ "\n"
  show (AAsm [dest] asnop [src1, src2]) =
    show dest ++ " <-- "
      ++ show src1 ++ " " ++ show asnop ++ " " ++ show src2 ++ "\n"
  show (ARet _) = "ret %eax\n"
  show _ = "ill-formed"

instance Show AVal where
  show (ALoc loc) = show loc
  show (AImm n) = "$" ++ (show n)

instance Show ALoc where
  show (AReg 0) = "%eax"
  show (AReg _) = "%edx"
  show (ATemp n) = "%t" ++ (show n)

instance Show ACtrl where
  show (ALab s) = s ++ ":"
  show (AJump s) = "Jmp " ++ s
  show (ACJump op a b l1 l2) = "If " ++ show a ++ " " ++ show op ++ " " ++ show b ++ " goto " ++ l1 ++ " else goto " ++ l2

-- A hack to work with an AAsm tool
testPrintAAsm :: [AAsm] -> String -> String
testPrintAAsm prog filename =
  let
    header = "\t.file\t\"" ++ filename ++ "\"\n"
    footer = "\t.ident\t\"15-411 L1 Haskell Starter Code\"\n"
  in
  header ++ concatMap (\line -> "\t" ++ show line) prog ++ footer


