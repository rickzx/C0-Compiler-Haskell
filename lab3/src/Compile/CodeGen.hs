{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Currently just a pseudolanguage with 3-operand instructions and arbitrarily many temps.
-}
module Compile.CodeGen where

import Compile.Types
import qualified Data.Map as Map
import qualified Data.List as List
import Compile.Backend.LiveVariable
import Compile.Backend.EAST2AAsm
import Compile.Backend.AAsm2Asm
import Compile.Backend.RegisterAlloc
import Debug.Trace

codeGen :: EAST -> ([AAsm], Int)
codeGen e = ([], 1)
    

asmGen :: EAST -> String
asmGen east =
  let
    (aasms, localVar) = codeGen east

    (coloring, stackVar) = if localVar > 200 then allStackColor localVar
      else
        let
          graph = computerInterfere aasms

          -- (trace $ "Interference graph: " ++ show graph ++ "\n\n")
          precolor = Map.fromList [(AReg 0, 0), (AReg 1, 3), (AReg 2, 4)]
          
          seo = mcs graph precolor
        in
          color graph seo precolor

    nonTrivial asm = case asm of
        Movl op1 op2 -> op1 /= op2
        Movq op1 op2 -> op1 /= op2
        _            -> True

    -- (trace $ show coloring ++ "\n\n" ++ show aasms)
    insts = concatMap (\x -> List.filter nonTrivial (toAsm x coloring)) aasms
  in
    if stackVar > 0 then
    concatMap (\line -> show line ++ "\n")
    $  [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP), Subq (Imm (stackVar * 8)) (Reg RSP)]
    ++ insts ++ [Label "RET", Addq (Imm (stackVar * 8)) (Reg RSP), Popq (Reg RBP), Ret]
    else
    concatMap (\line -> show line ++ "\n")
    $  [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)]
    ++ insts ++ [Label "RET", Popq (Reg RBP), Ret]