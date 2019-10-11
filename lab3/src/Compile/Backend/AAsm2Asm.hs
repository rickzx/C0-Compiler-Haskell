module Compile.Backend.AAsm2Asm where

import Compile.Backend.RegisterAlloc
import Compile.Types
import Debug.Trace

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

getRegAlloc' :: [ALoc] -> Coloring -> Bool -> [Operand]
getRegAlloc' [] _ _ = []
getRegAlloc' (x:xs) c is64 =
    (if is64
         then mapToReg64 x c
         else mapToReg x c) :
    getRegAlloc' xs c is64

toAsm :: AAsm -> Coloring -> [Inst]
-- toAsm e _ | trace ("toAsm " ++ show e ++ "\n") False = undefined
toAsm (AAsm [assign] ANop [arg]) coloring =
    let assign' = mapToReg assign coloring
        [arg'] = getRegAlloc [arg] coloring False
     in genMovl arg' assign'
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
     in if isMem assign' && isMem src1'
            then [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sall (Reg CL) assign']
            else if src1' == Reg ECX
                     then [ Movl (Reg ECX) (Reg R11D)
                          , Movl src2' (Reg ECX)
                          , Movl (Reg R11D) assign'
                          , Sall (Reg CL) assign'
                          ]
                     else [Movl src2' (Reg ECX), Movl src1' assign', Sall (Reg CL) assign']
toAsm (AAsm [assign] ASar [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        [src1', src2'] = getRegAlloc [src1, src2] coloring False
     in if isMem assign' && isMem src1'
            then [Movl src2' (Reg ECX), Movl src1' (Reg R11D), Movl (Reg R11D) assign', Sarl (Reg CL) assign']
            else if src1' == Reg ECX
                     then [ Movl (Reg ECX) (Reg R11D)
                          , Movl src2' (Reg ECX)
                          , Movl (Reg R11D) assign'
                          , Sarl (Reg CL) assign'
                          ]
                     else [Movl src2' (Reg ECX), Movl src1' assign', Sarl (Reg CL) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Sete (Reg R11B), Movzbl (Reg R11B) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Setne (Reg R11B), Movzbl (Reg R11B) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Setl (Reg R11B), Movzbl (Reg R11B) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Setg (Reg R11B), Movzbl (Reg R11B) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Setle (Reg R11B), Movzbl (Reg R11B) assign']
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
     in if isMem assign' && isMem src1'
            then asm
            else [Cmp src2' src1', Setge (Reg R11B), Movzbl (Reg R11B) assign']
toAsm (ACall fun stks) coloring =
    let stks' = getRegAlloc' stks coloring False
        pushStks = map Pushq stks'
        popStks =
            if Reg EAX `elem` stks'
                then [Movl (Reg EAX) (Reg R11D)] ++ map Popq (reverse stks') ++ [Movl (Reg R11D) (Reg EAX)]
                else map Popq (reverse stks')
     in if length stks' `mod` 2 == 0
            then pushStks ++ [Xorl (Reg EAX) (Reg EAX), Call fun] ++ popStks
            else pushStks ++
                 [Subq (Imm 8) (Reg RSP), Xorl (Reg EAX) (Reg EAX), Call fun, Addq (Imm 8) (Reg RSP)] ++ popStks
toAsm (AFun _fn stks) coloring =
    let stks' = getRegAlloc' stks coloring False
     in concatMap (\(i, s) -> genMovl (Mem' (i * 8) RBP) s) $ zip [2 ..] stks'
toAsm _ _ = error "ill-formed abstract assembly"

genMovl :: Operand -> Operand -> [Inst]
genMovl src dest =
    case (src, dest) of
        (Mem {}, Mem {}) -> [Movl src (Reg R11D), Movl (Reg R11D) dest]
        (Mem' {}, Mem {}) -> [Movl src (Reg R11D), Movl (Reg R11D) dest]
        (Mem {}, Mem' {}) -> [Movl src (Reg R11D), Movl (Reg R11D) dest]
        (Mem' {}, Mem' {}) -> [Movl src (Reg R11D), Movl (Reg R11D) dest]
        _ -> [Movl src dest]

genMovq :: Operand -> Operand -> [Inst]
genMovq src dest =
    case (src, dest) of
        (Mem {}, Mem {}) -> [Movq src (Reg R11), Movq (Reg R11) dest]
        (Mem' {}, Mem {}) -> [Movq src (Reg R11), Movq (Reg R11) dest]
        (Mem {}, Mem' {}) -> [Movq src (Reg R11), Movq (Reg R11) dest]
        (Mem' {}, Mem' {}) -> [Movq src (Reg R11), Movq (Reg R11) dest]
        _ -> [Movq src dest]

isMem :: Operand -> Bool
isMem oper =
    case oper of
        Mem {} -> True
        Mem' {} -> True
        _ -> False