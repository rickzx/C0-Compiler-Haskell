module Compile.Backend.AAsm2Asm where

import Compile.Backend.RegisterAlloc
import Compile.Types.Ops
import Compile.Types.Assembly
import Compile.Types.AbstractAssembly
import qualified Data.Map as Map
import qualified Data.List as List

toAsm :: AAsm -> Coloring -> [Inst]
toAsm (AAsm [assign] ANop [arg]) coloring =
    let
        assign' = mapToReg64 assign coloring
        arg' = case arg of
                ALoc loc -> mapToReg64 loc coloring
                AImm x -> Imm x
    in
        case arg' of
            Mem {} -> [Movq arg' (Reg R11), Movq (Reg R11) assign']
            _ -> [Movq arg' assign']
toAsm (AAsm [assign] AAdd [src1, src2]) coloring =
    let
        assign' = mapToReg assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
    in
        case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Addl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Addl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ -> [Movl src1' assign', Addl src2' assign']
toAsm (AAsm [assign] AAddq [src1, src2]) coloring =
    let
        assign' = mapToReg64 assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg64 loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg64 loc coloring
                AImm x -> Imm x
    in
        case (src1', src2') of
            (Mem {}, _) -> [Movq src1' (Reg R11), Addq src2' (Reg R11), Movq (Reg R11) assign']
            (_, Mem {}) -> [Movq src2' (Reg R11), Addq src1' (Reg R11), Movq (Reg R11) assign']
            _ -> [Movq src1' assign', Addq src2' assign']
toAsm (AAsm [assign] ASub [src1, src2]) coloring =
    let
        assign' = mapToReg assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
    in
        case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Subl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Subl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ -> [Movl src1' assign', Subl src2' assign']
toAsm (AAsm [assign] ASubq [src1, src2]) coloring =
    let
        assign' = mapToReg64 assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg64 loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg64 loc coloring
                AImm x -> Imm x
    in
        case (src1', src2') of
            (Mem {}, _) -> [Movq src1' (Reg R11), Subq src2' (Reg R11), Movq (Reg R11) assign']
            (_, Mem {}) -> [Movq src2' (Reg R11), Subq src1' (Reg R11), Movq (Reg R11) assign']
            _ -> [Movq src1' assign', Subq src2' assign']
toAsm (AAsm [assign] ADiv [src1, src2]) coloring =
    let
        assign' = mapToReg assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
    in
        case src2' of
            Imm _ -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EAX) assign']
            _ -> [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EAX) assign']
toAsm (AAsm [assign] AMul [src1, src2]) coloring =
    let
        assign' = mapToReg assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
    in
        case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Imull src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Imull src1' (Reg R11D), Movl (Reg R11D) assign']
            _ -> [Movl src1' assign', Imull src2' assign']
toAsm (AAsm [assign] AMod [src1, src2]) coloring =
    let
        assign' = mapToReg assign coloring
        src1' = case src1 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
        src2' = case src2 of
                ALoc loc -> mapToReg loc coloring
                AImm x -> Imm x
    in
        case src2' of
            Imm _ -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EDX) assign']
            _ -> [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EDX) assign']
toAsm (ARet _) _ = [Popq (Reg RBP), Ret]
toAsm _ _ = error "ill-formed abstract assembly"

printAsm :: [AAsm] -> String
printAsm aasms = concatMap (\line -> "\t" ++ show line ++ "\n") $ 
    [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] ++ insts where
        coloring = Map.fromList [(AReg 0, 0), (ATemp 0, 1), (ATemp 1, 2), (ATemp 2, 3), (ATemp 3, 4), (ATemp 4, 5), (ATemp 5, 6), (ATemp 6, 7)]
        nonTrivial asm = case asm of
            Movl op1 op2 -> op1 /= op2
            Movq op1 op2 -> op1 /= op2
            _ -> True
        insts = foldl (\l aasm -> l ++ List.filter nonTrivial (toAsm aasm coloring)) [] aasms
