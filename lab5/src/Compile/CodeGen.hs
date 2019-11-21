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
import Compile.Backend.SSA
import Compile.Backend.SSAOptimize
import Compile.Backend.Inline
import Compile.Types
import qualified Data.List as List
import qualified Data.Map as Map
import Debug.Trace

codeGen :: TAST -> [(Ident,Map.Map Ident Type)] -> Bool -> [AAsm]
--codeGen t | (trace $ show t) False = undefined
codeGen tast structs unsafe =
    let 
        (tastGen, _tr) = inlineOpt $ aasmGen tast structs unsafe
        --(tastGen, _tr) = aasmGen tast structs unsafe
        memerr = [
            AControl $ ALab "memerror",
            AAsm [AReg 3] ANop [AImm 12],
            ACall "raise" [] 1
            ]
     in memerr ++ concatMap (\(_fn, (aasm, _lv)) -> aasm) tastGen

asmGen :: TAST -> Header -> [(Ident,Map.Map Ident Type)] -> Bool -> String
--asmGen t h | (trace $ show t ++ "\n\n" ++ show h) False = undefined
asmGen tast header structs unsafe =
    let memerr = ".memerror:\n\tmovl $12, %edi\n\txorl %eax, %eax\n\tcall raise\n"
        (tastGen, tr) = inlineOpt $ aasmGen tast structs unsafe
        --(tastGen, tr) = aasmGen tast structs unsafe
        globs = map (\(x, _) -> if x == "a bort" then Global "_c0_abort_local411" else Global $ "_c0_" ++ x) tastGen
        globString = concatMap (\line -> show line ++ "\n") globs
     in globString ++ concatMap (\(fn, (aasms, lv)) -> generateFunc (fn, aasms, lv) header tr) tastGen ++ memerr

generateFunc :: (String, [AAsm], Int) -> Header -> Map.Map String String -> String
generateFunc (fn, aasms, localVar) header trdict =
    let
        fname
            | Map.member fn (fnDecl header) = fn
            | fn == "a bort" = "_c0_abort_local411"
            | otherwise = "_c0_" ++ fn
        (renamed, finalblk, finalG, finalP, serial) = ssa aasms fname
        (optSSA, allVars) = ssaOptimize renamed
        elim = deSSA finalP optSSA serial
        hd = [AControl $ ALab $ "_c0_"++ fn ++ "_ret", AAsm [AReg 9] ANop [ALoc $ AReg 9]]
        trelim = case Map.lookup fn trdict of
            Just _ -> hd ++ elim
            Nothing -> elim
        (coloring, stackVar, calleeSaved) = 
            if length allVars >= 1000 then allStackColor allVars else
            let  gr = computerInterfere trelim
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
                         , (AReg 9, 7)
                         ]
                 seo = mcs gr precolor
             in color gr seo precolor
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
        prolog =
            if stackVarAligned > 0
                then [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] -- Save rbp of parent, update rbp using rsp
                      ++
                     map (Pushq . Reg . toReg64) calleeSaved -- Save callee-saved registers used in the function
                      ++
                     [Subq (Imm (stackVarAligned * 8)) (Reg RSP)] -- Allocate stack space

                else [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] ++ map (Pushq . Reg . toReg64) calleeSaved
        epilog = case Map.lookup fn trdict of
            Just "ADD" -> 
                if stackVarAligned > 0
                then [Label $ fname ++ "_ret", Addl (Reg R12D) (Reg EAX), Addq (Imm (stackVarAligned * 8)) (Reg RSP)] ++
                     map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                else [Label $ fname ++ "_ret", Addl (Reg R12D) (Reg EAX)] ++ map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
            Just "MUL" -> 
                if stackVarAligned > 0
                then [Label $ fname ++ "_ret", Imull (Reg R12D) (Reg EAX), Addq (Imm (stackVarAligned * 8)) (Reg RSP)] ++
                     map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                else [Label $ fname ++ "_ret", Imull (Reg R12D) (Reg EAX)] ++ map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
            _ ->
                if stackVarAligned > 0
                then [Label $ fname ++ "_ret", Addq (Imm (stackVarAligned * 8)) (Reg RSP)] ++
                        map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                else [Label $ fname ++ "_ret"] ++ map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]

        insts = concatMap (\x -> List.filter nonTrivial (toAsm x coloring header)) (findstart elim)
                    where 
                        findstart :: [AAsm] -> [AAsm]
                        findstart [] = []
                        findstart (x:rest) = case x of
                            AFun _fn _instk -> x:rest
                            _ -> findstart rest
        --optimize out the redundant move operations
        optinsts = remove_move insts
                where
                    remove_move :: [Inst] -> [Inst]
                    remove_move [] = []
                    remove_move [x] = [x]
                    remove_move (x:y:xs) = case (x, y) of
                        (Jmp l1 , Label l2) -> if l1 == l2 then remove_move(y:xs) else x:remove_move(y:xs) --delete redundant jumps
                        _ -> x:remove_move(y:xs)
        fun = prolog ++ optinsts ++ epilog
        -- (trace $ "AAsm:\n" ++ show aasms ++ "\n\nRenamed:\n" ++ show renamed ++ "\n\nElim:\n" ++ show elim)
     in 
    --    (trace $ "allVars: " ++ show allVars ++ "\n\n") 
        concatMap (\line -> show line ++ "\n") fun
