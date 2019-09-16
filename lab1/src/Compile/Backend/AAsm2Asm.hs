module Compile.Backend.AAsm2Asm where

import           Compile.Backend.RegisterAlloc
import           Compile.Types.Ops
import           Compile.Types.Assembly
import           Compile.Types.AbstractAssembly
import qualified Data.Map                      as Map
import qualified Data.List                     as List
import Debug.Trace

toAsm :: AAsm -> Coloring -> [Inst]
toAsm (AAsm [assign] ANop [arg]) coloring =
    let assign' = mapToReg64 assign coloring
        arg'    = case arg of
            ALoc loc -> mapToReg64 loc coloring
            AImm x   -> Imm x
    in  case arg' of
            Mem{} -> [Movq arg' (Reg R11), Movq (Reg R11) assign']
            Mem'{} -> [Movq arg' (Reg R11), Movq (Reg R11) assign']
            _     -> [Movq arg' assign']
toAsm (AAsm [assign] AAdd [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
    in  case (src1', src2') of
            (Mem{}, _) ->
                [ Movl src1' (Reg R11D)
                , Addl src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (Mem'{}, _) ->
                [ Movl src1' (Reg R11D)
                , Addl src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem{}) ->
                [ Movl src2' (Reg R11D)
                , Addl src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem'{}) ->
                [ Movl src2' (Reg R11D)
                , Addl src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            _ -> if src2' == assign'
                then [Addl src1' assign']
                else [Movl src1' assign', Addl src2' assign']
toAsm (AAsm [assign] AAddq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg64 loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg64 loc coloring
            AImm x   -> Imm x
    in  case (src1', src2') of
            (Mem{}, _) ->
                [ Movq src1' (Reg R11)
                , Addq src2' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (Mem'{}, _) ->
                [ Movq src1' (Reg R11)
                , Addq src2' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (_, Mem{}) ->
                [ Movq src2' (Reg R11)
                , Addq src1' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (_, Mem'{}) ->
                [ Movq src2' (Reg R11)
                , Addq src1' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            _ -> if src2' == assign'
                then [Addq src1' assign']
                else [Movq src1' assign', Addq src2' assign']
toAsm (AAsm [assign] ASub [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
    in  case (src1', src2') of
            (Mem{}, _) ->
                [ Movl src1' (Reg R11D)
                , Subl src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (Mem'{}, _) ->
                [ Movl src1' (Reg R11D)
                , Subl src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem{}) ->
                [ Movl src2' (Reg R11D)
                , Subl src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem'{}) ->
                [ Movl src2' (Reg R11D)
                , Subl src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            _ -> if src2' == assign'
                then [Negl src2', Addl src1' src2']
                else [Movl src1' assign', Subl src2' assign']
toAsm (AAsm [assign] ASubq [src1, src2]) coloring =
    let assign' = mapToReg64 assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg64 loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg64 loc coloring
            AImm x   -> Imm x
    in  case (src1', src2') of
            (Mem{}, _) ->
                [ Movq src1' (Reg R11)
                , Subq src2' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (Mem'{}, _) ->
                [ Movq src1' (Reg R11)
                , Subq src2' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (_, Mem{}) ->
                [ Movq src2' (Reg R11)
                , Subq src1' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            (_, Mem'{}) ->
                [ Movq src2' (Reg R11)
                , Subq src1' (Reg R11)
                , Movq (Reg R11) assign'
                ]
            _ -> if src2' == assign'
                then [Negq src2', Addq src1' src2']
                else [Movq src1' assign', Subq src2' assign']
toAsm (AAsm [assign] ADiv [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
    in  case src2' of
            Imm _ ->
                [ Movl src2' (Reg R11D)
                , Movl src1' (Reg EAX)
                , Cdq
                , Idivl (Reg R11D)
                , Movl (Reg EAX) assign'
                ]
            _ ->
                [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EAX) assign']
toAsm (AAsm [assign] AMul [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
    in  case (src1', src2') of
            (Mem{}, _) ->
                [ Movl src1' (Reg R11D)
                , Imull src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (Mem'{}, _) ->
                [ Movl src1' (Reg R11D)
                , Imull src2' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem{}) ->
                [ Movl src2' (Reg R11D)
                , Imull src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            (_, Mem'{}) ->
                [ Movl src2' (Reg R11D)
                , Imull src1' (Reg R11D)
                , Movl (Reg R11D) assign'
                ]
            _ -> if src2' == assign'
                then [Imull src1' assign']
                else (case assign' of
                    Mem'{} -> [Movl src1' (Reg R11D), Imull src2' (Reg R11D), Movl (Reg R11D) assign']
                    _ -> [Movl src1' assign', Imull src2' assign'])
toAsm (AAsm [assign] AMod [src1, src2]) coloring =
    let assign' = mapToReg assign coloring
        src1'   = case src1 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
        src2' = case src2 of
            ALoc loc -> mapToReg loc coloring
            AImm x   -> Imm x
    in  case src2' of
            Imm _ ->
                [ Movl src2' (Reg R11D)
                , Movl src1' (Reg EAX)
                , Cdq
                , Idivl (Reg R11D)
                , Movl (Reg EDX) assign'
                ]
            _ ->
                [Movl src1' (Reg EAX), Cdq, Idivl src2', Movl (Reg EDX) assign']
toAsm (ARet _) _ = [Ret]
toAsm _        _ = error "ill-formed abstract assembly"

removeDeadcode :: [Inst] -> [Inst]
removeDeadcode insts = case List.elemIndex Ret insts of
    Just i  -> List.take i insts
    Nothing -> insts

printAsm :: [AAsm] -> String
printAsm aasms =
    concatMap (\line -> "\t" ++ show line ++ "\n")
        $  [ Pushq (Reg RBP)
           , Movq (Reg RSP) (Reg RBP)
           , Subq (Imm (stackVar * 8)) (Reg RSP)
           ]
        ++ insts
        ++ [Addq (Imm (stackVar * 8)) (Reg RSP), Popq (Reg RBP), Ret]  where
    coloring = Map.fromList
        [ (AReg 0  , 0)
        , (ATemp 0 , 1)
        , (ATemp 1 , 2)
        , (ATemp 2 , 3)
        , (ATemp 3 , 4)
        , (ATemp 4 , 5)
        , (ATemp 5 , 6)
        , (ATemp 6 , 7)
        , (ATemp 7 , 8)
        , (ATemp 8 , 9)
        , (ATemp 9 , 10)
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
    nonTrivial asm = case asm of
        Movl op1 op2 -> op1 /= op2
        Movq op1 op2 -> op1 /= op2
        _            -> True
    insts = removeDeadcode $ foldl
        (\l aasm -> l ++ List.filter nonTrivial (toAsm aasm coloring))
        []
        aasms
