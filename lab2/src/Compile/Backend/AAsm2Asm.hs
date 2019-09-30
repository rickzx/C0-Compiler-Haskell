module Compile.Backend.AAsm2Asm where

import Compile.Backend.RegisterAlloc
import Compile.Types
import qualified Data.List as List
import qualified Data.Map as Map

getRegAlloc :: [AVal] -> Coloring -> Bool -> [Operand]
getRegAlloc [] _ _ = []
getRegAlloc (x:xs) c is64 =
    (case x of
         ALoc loc ->
             if is64
                 then mapToReg64 loc c
                 else mapToReg loc c
         AImm v -> Imm v) :
    getRegAlloc xs c is64

toAsm :: AAsm -> Coloring -> [Inst]
toAsm (AAsm [assign] ANop [arg]) coloring =
    let assign' = mapToReg assign coloring
        [arg'] = getRegAlloc [arg] coloring False
     in case arg' of
            Mem {} -> [Movl arg' (Reg R11D), Movl (Reg R11D) assign']
            Mem' {} -> [Movl arg' (Reg R11D), Movl (Reg R11D) assign']
            _ -> [Movl arg' assign']
toAsm (AAsm [assign] AAdd [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Addl src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Addl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Addl src1' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src2' (Reg R11D), Addl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Addl src1' assign']
                    else [Movl src1' assign', Addl src2' assign']
toAsm (AAsm [assign] AAddq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring True
     in case (src1', src2') of
            (Mem {}, _) -> [Movq src1' (Reg R11), Addq src2' (Reg R11), Movq (Reg R11) assign']
            (Mem' {}, _) -> [Movq src1' (Reg R11), Addq src2' (Reg R11), Movq (Reg R11) assign']
            (_, Mem {}) -> [Movq src2' (Reg R11), Addq src1' (Reg R11), Movq (Reg R11) assign']
            (_, Mem' {}) -> [Movq src2' (Reg R11), Addq src1' (Reg R11), Movq (Reg R11) assign']
            _ ->
                if src2' == assign'
                    then [Addq src1' assign']
                    else [Movq src1' assign', Addq src2' assign']
toAsm (AAsm [assign] ASub [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Subl src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Subl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src1' (Reg R11D), Subl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src1' (Reg R11D), Subl src2' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Negl src2', Addl src1' src2']
                    else [Movl src1' assign', Subl src2' assign']
toAsm (AAsm [assign] ASubq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring True
     in case (src1', src2') of
            (Mem {}, _) -> [Movq src1' (Reg R11), Subq src2' (Reg R11), Movq (Reg R11) assign']
            (Mem' {}, _) -> [Movq src1' (Reg R11), Subq src2' (Reg R11), Movq (Reg R11) assign']
            (_, Mem {}) -> [Movq src1' (Reg R11), Subq src2' (Reg R11), Movq (Reg R11) assign']
            (_, Mem' {}) -> [Movq src1' (Reg R11), Subq src2' (Reg R11), Movq (Reg R11) assign']
            _ ->
                if src2' == assign'
                    then [Negq src2', Addq src1' src2']
                    else [Movq src1' assign', Subq src2' assign']
toAsm (AAsm [assign] ADiv [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case src2' of
            Imm _ -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EAX) assign']
            Reg EAX -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EAX) assign']
            Reg EDX -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EAX) assign']
            _ -> [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EAX) assign']
toAsm (AAsm [assign] ADivq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring True
     in case src2' of
            Imm _ -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RAX) assign']
            Reg RAX -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RAX) assign']
            Reg RDX -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RAX) assign']
            _ -> [Movq src1' (Reg RAX), Cqto, Idivq src2', Movq (Reg RAX) assign']
toAsm (AAsm [assign] AMul [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Imull src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Imull src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Imull src1' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src2' (Reg R11D), Imull src1' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Imull src1' assign']
                    else (case assign' of
                              Mem' {} -> [Movl src1' (Reg R11D), Imull src2' (Reg R11D), Movl (Reg R11D) assign']
                              _ -> [Movl src1' assign', Imull src2' assign'])
toAsm (AAsm [assign] AMod [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case src2' of
            Imm _ -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EDX) assign']
            Reg EAX -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EDX) assign']
            Reg EDX -> [Movl src2' (Reg R11D), Movl src1' (Reg EAX), Cdq, Idivl (Reg R11D), Movl (Reg EDX) assign']
            _ -> [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EDX) assign']
toAsm (AAsm [assign] AModq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring True
     in case src2' of
            Imm _ -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RDX) assign']
            Reg RAX -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RDX) assign']
            Reg RDX -> [Movq src2' (Reg R11), Movq src1' (Reg RAX), Cqto, Idivq (Reg R11), Movq (Reg RDX) assign']
            _ -> [Movq src1' (Reg RAX), Cqto, Idivq src2', Movq (Reg RDX) assign']
toAsm (AAsm [assign] ABAnd [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Andl src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Andl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Andl src1' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src2' (Reg R11D), Andl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Andl src1' assign']
                    else [Movl src1' assign', Andl src2' assign']
toAsm (AAsm [assign] ABOr [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Orl src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Orl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Orl src1' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src2' (Reg R11D), Orl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Orl src1' assign']
                    else [Movl src1' assign', Orl src2' assign']
toAsm (AAsm [assign] ABNot [src]) coloring =
    let assign' = mapToReg assign coloring
        [src'] = getRegAlloc [src] coloring False
     in case src' of
            Mem {} -> [Movl src' (Reg R11D), Movl (Reg R11D) assign', Notl assign']
            Mem' {} -> [Movl src' (Reg R11D), Movl (Reg R11D) assign', Notl assign']
            _ -> [Movl src' assign', Notl assign']
toAsm (AAsm [assign] AXor [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (src1', src2') of
            (Mem {}, _) -> [Movl src1' (Reg R11D), Xorl src2' (Reg R11D), Movl (Reg R11D) assign']
            (Mem' {}, _) -> [Movl src1' (Reg R11D), Xorl src2' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem {}) -> [Movl src2' (Reg R11D), Xorl src1' (Reg R11D), Movl (Reg R11D) assign']
            (_, Mem' {}) -> [Movl src2' (Reg R11D), Xorl src1' (Reg R11D), Movl (Reg R11D) assign']
            _ ->
                if src2' == assign'
                    then [Xorl src1' assign']
                    else [Movl src1' assign', Xorl src2' assign']
toAsm (AAsm [assign] ASal [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (assign', src1') of
            (Mem {}, Mem {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            (Mem' {}, Mem {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            (Mem {}, Mem' {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            (Mem' {}, Mem' {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            (_, Reg ECX) ->
                [Movl (Reg ECX) (Reg R11D), Movl src2' (Reg ECX), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            _ -> [Movl src2' (Reg ECX), Movl src1' assign', Sall (Reg CL) assign']
toAsm (AAsm [assign] ASar [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in case (assign', src1') of
            (Mem {}, Mem {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            (Mem' {}, Mem {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            (Mem {}, Mem' {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            (Mem' {}, Mem' {}) ->
                [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            (_, Reg ECX) ->
                [Movl (Reg ECX) (Reg R11D), Movl src2' (Reg ECX), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            _ -> [Movl src2' (Reg ECX), Movl src1' assign', Sarl (Reg CL) assign']
toAsm (AControl (ALab l)) _ = [Label l]
toAsm (AControl (AJump l)) _ = [Jmp l]
toAsm (AControl (ACJump v l l')) coloring =
    let [v'] = getRegAlloc [v] coloring False
     in case v' of
            Mem {} -> [Movl v' (Reg R11D), Test (Reg R11D) (Reg R11D), Je l', Jmp l]
            Mem' {} -> [Movl v' (Reg R11D), Test (Reg R11D) (Reg R11D), Je l', Jmp l]
            _ -> [Test v' v', Je l', Jmp l]
toAsm (AControl (ACJump' rop x y l l')) coloring =
    let asmOp =
            case rop of
                AEq -> Je
                ANe -> Jne
                ALt -> Jl
                AGt -> Jg
                ALe -> Jle
                AGe -> Jge
        [x', y'] = getRegAlloc [x, y] coloring False
     in case x' of
            Mem {} -> [Movl x' (Reg R11D), Cmp y' (Reg R11D), asmOp l, Jmp l']
            Mem' {} -> [Movl x' (Reg R11D), Cmp y' (Reg R11D), asmOp l, Jmp l']
            _ -> [Cmp y' x', asmOp l, Jmp l']
toAsm (ARel [assign] AEq [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Sete (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Sete (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ARel [assign] ANe [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Setne (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Setne (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ARel [assign] ALt [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Setl (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Setl (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ARel [assign] AGt [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Setg (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Setg (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ARel [assign] ALe [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Setle (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Setle (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ARel [assign] AGe [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
        asm =
            [ Movl src1' (Reg R11D)
            , Cmp src2' (Reg R11D)
            , Setge (Reg R11B)
            , Movzbl (Reg R11B) (Reg R11D)
            , Movl (Reg R11D) assign'
            ]
     in case (assign', src1') of
            (Mem {}, _) -> asm
            (Mem' {}, _) -> asm
            (_, Mem {}) -> asm
            (_, Mem' {}) -> asm
            _ -> [Cmp src2' src1', Setge (Reg R11B), Movzbl (Reg R11B) assign']
toAsm _ _ = error "ill-formed abstract assembly"

printAsm :: [AAsm] -> String
printAsm aasms =
    concatMap (\line -> "\t" ++ show line ++ "\n") $
    [Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP), Subq (Imm (stackVar * 8)) (Reg RSP)] ++
    insts ++ [Addq (Imm (stackVar * 8)) (Reg RSP), Popq (Reg RBP), Ret]
  where
    coloring =
        Map.fromList
            [ (AReg 0, 0)
            , (ATemp 0, 1)
            , (ATemp 1, 2)
            , (ATemp 2, 3)
            , (ATemp 3, 4)
            , (ATemp 4, 5)
            , (ATemp 5, 6)
            , (ATemp 6, 7)
            , (ATemp 7, 8)
            , (ATemp 8, 9)
            , (ATemp 9, 10)
            , (ATemp 10, 11)
            , (ATemp 11, 12)
            , (ATemp 12, 13)
            , (ATemp 13, 14)
            , (ATemp 14, 15)
            , (ATemp 15, 16)
            , (ATemp 16, 17)
            , (ATemp 17, 18)
            , (ATemp 18, 19)
            , (ATemp 19, 20)
            , (ATemp 20, 21)
            , (ATemp 21, 22)
            , (ATemp 22, 23)
            , (ATemp 23, 24)
            , (ATemp 24, 25)
            , (ATemp 25, 26)
            , (ATemp 26, 27)
            , (ATemp 27, 28)
            , (ATemp 28, 29)
            , (ATemp 29, 30)
            , (ATemp 30, 31)
            , (ATemp 31, 32)
            , (ATemp 32, 33)
            , (ATemp 33, 34)
            , (ATemp 34, 35)
            , (ATemp 35, 36)
            , (ATemp 36, 37)
            , (ATemp 37, 38)
            , (ATemp 38, 39)
            , (ATemp 39, 40)
            , (ATemp 40, 41)
            ]
    stackVar = 25
    nonTrivial asm =
        case asm of
            Movl op1 op2 -> op1 /= op2
            Movq op1 op2 -> op1 /= op2
            _ -> True
    insts = foldl (\l aasm -> l ++ List.filter nonTrivial (toAsm aasm coloring)) [] aasms