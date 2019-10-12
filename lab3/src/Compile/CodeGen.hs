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

codeGen :: EAST -> [AAsm]
--codeGen t | (trace $ show t) False = undefined
codeGen east =
    let eastGen = aasmGen east
     in concatMap (\(_fn, (aasm, _lv)) -> aasm) eastGen
    
asmGen :: EAST -> String
asmGen east =
    let
        eastGen = aasmGen east
    in
        concatMap (\(fn, (aasms, lv)) -> generateFunc (fn, aasms, lv)) eastGen

generateFunc :: (String, [AAsm], Int) -> String
generateFunc (fn, aasms, localVar) =
    let
        (coloring, stackVar, calleeSaved) = if localVar > 200 then allStackColor localVar else
            let
              graph = computerInterfere aasms
              
              -- (trace $ "Interference graph: " ++ show graph ++ "\n\n")
              precolor = Map.fromList [(AReg 0, 0), (AReg 1, 3), (AReg 2, 4),
                                        (AReg 3, 1), (AReg 4, 2), (AReg 5, 5), (AReg 6, 6)]
              
              seo = mcs graph precolor
            in
              color graph seo precolor

        nonTrivial asm = case asm of
            Movl op1 op2 -> op1 /= op2
            Movq op1 op2 -> op1 /= op2
            _            -> True
        
        stackVarAligned
          | (length calleeSaved + 1) `mod` 2 == 0 =
            (if stackVar `mod` 2 == 0 then stackVar + 1 else stackVar)
          | stackVar `mod` 2 == 0 = stackVar
          | otherwise = stackVar + 1
          
        prolog = if stackVarAligned > 0 then        
            [Fun fn, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)]   -- Save rbp of parent, update rbp using rsp
            ++ map (Pushq . Reg) calleeSaved    -- Save callee-saved registers used in the function
            ++ [Subq (Imm (stackVarAligned * 8)) (Reg RSP)]    -- Allocate stack space
            else
            [Fun fn, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)]
            ++ map (Pushq . Reg) calleeSaved

        epilog = if stackVarAligned > 0 then 
            [Label $ fn ++ "_ret", Addq (Imm (stackVarAligned * 8)) (Reg RSP)]
            ++ map (Pushq . Reg) (reverse calleeSaved)
            ++ [Popq (Reg RBP), Ret]
            else
            [Label $ fn ++ "_ret"]
            ++ map (Pushq . Reg) (reverse calleeSaved)
            ++ [Popq (Reg RBP), Ret]
            
        -- (trace $ show fn ++ "\n" ++ show coloring ++ "\n\n" ++ show aasms)
        insts = concatMap (\x -> List.filter nonTrivial (toAsm x coloring)) aasms
        
        fun = prolog ++ insts ++ epilog
  in
    concatMap (\line -> show line ++ "\n") fun