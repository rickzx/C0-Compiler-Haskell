{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>

   Currently just a pseudolanguage with 3-operand instructions and arbitrarily many temps.
-}
module Compile.CodeGen where

import Compile.Backend.TAST2AAsm
import Compile.Backend.SSA
import Compile.Backend.SCC
import Compile.Backend.SSAOptimize
import Compile.Backend.SSARegAlloc
import Compile.Types
import Compile.Backend.Inline
import qualified Data.Map as Map
import Debug.Trace

codeGen :: TAST -> [(Ident,Map.Map Ident Type)] -> Bool -> Int -> [AAsm]
--codeGen t | (trace $ show t) False = undefined
codeGen tast structs unsafe optimization =
    let 
        (tastGen, _tr) = inlineOpt $ aasmGen tast structs unsafe
        memerr = [
            AControl $ ALab "memerror",
            AAsm [AReg 3] ANop [AImm 12],
            ACall "raise" [] 1
            ]
     in memerr ++ concatMap (\(_fn, (aasm, _lv)) -> aasm) tastGen

asmGen :: TAST -> Header -> [(Ident,Map.Map Ident Type)] -> Bool -> Int -> String
--asmGen t h | (trace $ show t ++ "\n\n" ++ show h) False = undefined
asmGen tast header structs unsafe optimization =
    let memerr = ".memerror:\n\tmovl $12, %edi\n\txorl %eax, %eax\n\tcall raise\n"
        (tastGen, tr) = inlineOpt $ aasmGen tast structs unsafe
        globs = map (\(x, _) -> if x == "a bort" then Global "_c0_abort_local411" else Global $ "_c0_" ++ x) tastGen
        globString = concatMap (\line -> show line ++ "\n") globs
     in globString ++ concatMap (\(fn, (aasms, lv)) -> generateFunc (fn, aasms, lv) header tr optimization) tastGen ++ memerr

generateFunc :: (String, [AAsm], Int) -> Header -> Map.Map String String -> Int -> String
generateFunc (fn, aasms, localVar) header trdict optimization =
    let fname
            | Map.member fn (fnDecl header) = fn
            | fn == "a bort" = "_c0_abort_local411"
            | otherwise = "_c0_" ++ fn
        (renamed, _, finalG, finalP, serial) = ssa aasms fname
--        (optSSA', allVars',_ , newP') = runSCC renamed finalG finalP fname
        (optSSA, allVars, newG, newP) = ssaOptimize renamed finalG finalP fname
        colorssa =
            if length allVars >= 7000 && optimization == 0
                then colorSSA fn optSSA newP allVars header serial trdict optimization
                else let (optSSA', allVars', _, newP') = runSCC optSSA newG newP fname
                      in colorSSA fn optSSA' newP' allVars' header serial trdict optimization
     in colorssa
