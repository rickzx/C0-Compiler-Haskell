{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Currently just a pseudolanguage with 3-operand instructions and arbitrarily many temps.
-}
module Compile.CodeGen where

import Compile.Types
import qualified Control.Monad.State.Strict as State
import Data.Int
import qualified Data.Map as Map
import qualified Data.List as List
import Data.Maybe (mapMaybe)
import Compile.Backend.LiveVariable
import Compile.Backend.EAST2AAsm
import Compile.Backend.AAsm2Asm
import Compile.Backend.RegisterAlloc
import Debug.Trace

codeGen :: EAST -> ([AAsm], Int)
codeGen = aasmGen

asmGen :: EAST -> String
asmGen east =
  let
    (aasms, localVar) = aasmGen east

    (coloring, stackVar) = if localVar > 500 then allStackColor localVar 
      else
        let
          (livelist, _) = computeLive([], reverseAAsm [] aasms)
          graph = buildInterfere aasms livelist Map.empty 0

          precolor = Map.fromList [(AReg 0, 0), (AReg 1, 3), (AReg 2, 4)]
          seo = mcs graph precolor
        in 
          color graph seo precolor

    nonTrivial asm = case asm of
        Movl op1 op2 -> op1 /= op2
        Movq op1 op2 -> op1 /= op2
        _            -> True

    -- (trace $ show coloring ++ "\n\n" ++ show graph ++ "\n\n" ++ show livelist ++ "\n\n" ++ show aasms) 
    insts = removeDeadcode $
        foldl
        (\l aasm -> l ++ List.filter nonTrivial (toAsm aasm coloring))
        []
        aasms
  in
    if stackVar > 0 then
    concatMap (\line -> show line ++ "\n")
    $  [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP), Subq (Imm (stackVar * 8)) (Reg RSP)]
    ++ insts ++ [Addq (Imm (stackVar * 8)) (Reg RSP), Popq (Reg RBP), Ret]
    else
    concatMap (\line -> show line ++ "\n")
    $  [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)]
    ++ insts ++ [Popq (Reg RBP), Ret]