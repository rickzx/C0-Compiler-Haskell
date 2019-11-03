{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Currently just a pseudolanguage with 3-operand instructions and arbitrarily many temps.
-}
module Compile.CodeGen where

import Compile.Backend.AAsm2Asm
import Compile.Backend.TAST2AAsm
import Compile.Backend.LiveVariable
import Compile.Backend.RegisterAlloc
import Compile.Types
import qualified Data.List as List
import qualified Data.Map as Map
import Debug.Trace

codeGen :: TAST -> Map.Map Ident (Map.Map Ident Type) -> [AAsm]
--codeGen t | (trace $ show t) False = undefined
codeGen tast structs =
    let 
        tastGen = aasmGen tast structs
        memerr = [
            AControl $ ALab "memerror",
            AAsm [AReg 3] ANop [AImm 12],
            ACall "raise" [] 1
            ]
     in memerr ++ concatMap (\(_fn, (aasm, _lv)) -> aasm) tastGen

asmGen :: TAST -> Header -> Map.Map Ident (Map.Map Ident Type) -> String
--asmGen t h | (trace $ show t ++ "\n\n" ++ show h) False = undefined
asmGen tast header structs =
    let memerr = ".memerror:\n\tmovl $12, %edi\n\txorl %eax, %eax\n\tcall raise\n"
        tastGen = aasmGen tast structs
        globs = map (\(x, _) -> if x == "a bort" then Global "_c0_abort_local411" else Global $ "_c0_" ++ x) tastGen
        globString = concatMap (\line -> show line ++ "\n") globs
     in globString ++ concatMap (\(fn, (aasms, lv)) -> generateFunc (fn, aasms, lv) header) tastGen ++ memerr

generateFunc :: (String, [AAsm], Int) -> Header -> String
generateFunc (fn, aasms, localVar) header =
    let (coloring, stackVar, calleeSaved) =
            if localVar > 1000 && localVar /= 2007 then allStackColor localVar--2007 was a bad year
                else let graph = computerInterfere aasms
              -- (trace $ "Interference graph: " ++ show graph ++ "\n\n")
                         precolor =
                             Map.fromList
                                 [ (AReg 0, 0)
                                 , (AReg 1, 3)
                                 , (AReg 2, 4)
                                 , (AReg 3, 1)
                                 , (AReg 4, 2)
                                 , (AReg 5, 5)
                                 , (AReg 6, 6)
                                 , (AReg 7, 7)
                                 ]
                         seo = mcs graph precolor
                         in color graph seo precolor
        nonTrivial asm =
            case asm of
                Movl op1 op2 -> op1 /= op2
                Movq op1 op2 -> op1 /= op2
                _ -> True
        stackVarAligned
            | (length calleeSaved + 1) `mod` 2 == 0 =
                (if stackVar `mod` 2 == 0
                     then stackVar + 1
                     else stackVar)
            | stackVar `mod` 2 == 0 = stackVar
            | otherwise = stackVar + 1
        fname
            | Map.member fn (fnDecl header) = fn
            | fn == "a bort" = "_c0_abort_local411"
            | otherwise = "_c0_" ++ fn
        prolog =
            if stackVarAligned > 0
                then [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] -- Save rbp of parent, update rbp using rsp
                      ++
                     map (Pushq . Reg . toReg64) calleeSaved -- Save callee-saved registers used in the function
                      ++
                     [Subq (Imm (stackVarAligned * 8)) (Reg RSP)] -- Allocate stack space
                else [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] ++ map (Pushq . Reg . toReg64) calleeSaved
        epilog =
            if stackVarAligned > 0
                then [Label $ fname ++ "_ret", Addq (Imm (stackVarAligned * 8)) (Reg RSP)] ++
                     map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                else [Label $ fname ++ "_ret"] ++ map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
        -- (trace $ show fn ++ "\n" ++ show coloring ++ "\n\n" ++ show aasms)
        insts = concatMap (\x -> List.filter nonTrivial (toAsm x coloring header)) aasms
        fun = prolog ++ insts ++ epilog
     in concatMap (\line -> show line ++ "\n") fun
