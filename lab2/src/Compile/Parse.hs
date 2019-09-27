{-# OPTIONS_GHC -w #-}
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.11

data HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17
	= HappyTerminal (Token)
	| HappyErrorToken Int
	| HappyAbsSyn4 t4
	| HappyAbsSyn5 t5
	| HappyAbsSyn6 t6
	| HappyAbsSyn7 t7
	| HappyAbsSyn8 t8
	| HappyAbsSyn9 t9
	| HappyAbsSyn10 t10
	| HappyAbsSyn11 t11
	| HappyAbsSyn12 t12
	| HappyAbsSyn13 t13
	| HappyAbsSyn14 t14
	| HappyAbsSyn15 t15
	| HappyAbsSyn16 t16
	| HappyAbsSyn17 t17

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,547) ([0,512,0,0,0,128,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,29312,64007,3,0,0,32,32768,1,1024,0,0,0,0,0,0,0,4,0,0,40960,33244,254,0,32768,0,0,0,0,0,0,0,0,1148,61416,1,0,0,0,0,0,0,0,0,4546,864,0,32768,1906,1018,0,0,0,0,0,0,0,0,0,0,0,0,0,28800,55300,0,0,0,0,0,0,18184,3456,0,0,2,0,0,32768,1136,216,0,8192,284,54,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,4546,864,0,32768,1648,472,0,0,0,0,0,2048,32839,13,0,0,0,0,0,0,0,0,0,7200,13825,0,0,0,0,0,0,61472,32785,1983,0,4,0,0,16384,0,0,0,4096,18368,65024,30,49664,24593,3,0,28800,55300,0,0,7200,13825,0,0,18184,3456,0,0,4546,864,0,32768,1136,216,0,40960,33244,254,0,2048,32839,13,0,49664,24593,3,0,28800,55300,0,0,7200,13825,0,0,18184,3456,0,0,4546,864,0,32768,1136,216,0,8192,284,54,0,2048,32839,13,0,49664,24593,3,0,28800,55300,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,8192,284,54,0,0,0,0,0,0,0,0,0,0,1148,61408,1,7200,13825,0,0,49152,7,0,0,61440,1,0,0,31744,57348,423,0,7936,63488,97,0,18368,32256,30,0,496,1920,6,0,124,33248,1,0,31,24576,0,49152,7,6144,0,61440,1,1536,0,31744,0,384,0,0,1024,0,0,1984,32256,26,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,49152,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,1148,61408,1,0,0,0,0,128,0,0,0,61440,32785,1983,0,31745,57348,495,40960,33244,254,0,2048,32839,13,0,51712,59421,15,0,0,0,4,0,0,287,31736,0,0,0,0,0,7626,4072,0,0,0,0,0,0,7938,63489,123,0,0,64,0,0,0,0,0,28800,55302,1,0,0,0,0,0,16,0,0,0,7626,4072,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Block","Lval","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","Operation","Intconst","'('","')'","'{'","'}'","';'","dec","hex","ident","tokmain","ret","int","'-'","'+'","'*'","'/'","'%'","asgnop","kill","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 62
        bit_end = (st + 1) * 62
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..61]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (26) = happyShift action_2
action_0 (4) = happyGoto action_3
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (26) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (20) = happyShift action_5
action_2 (5) = happyGoto action_4
action_2 _ = happyFail (happyExpListPerState 2)

action_3 (62) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_1

action_5 (18) = happyShift action_16
action_5 (20) = happyShift action_17
action_5 (23) = happyShift action_18
action_5 (24) = happyShift action_19
action_5 (25) = happyShift action_20
action_5 (27) = happyShift action_21
action_5 (28) = happyShift action_22
action_5 (29) = happyShift action_23
action_5 (36) = happyShift action_24
action_5 (38) = happyShift action_25
action_5 (39) = happyShift action_26
action_5 (40) = happyShift action_27
action_5 (41) = happyShift action_28
action_5 (42) = happyShift action_29
action_5 (43) = happyShift action_30
action_5 (44) = happyShift action_31
action_5 (6) = happyGoto action_6
action_5 (7) = happyGoto action_7
action_5 (8) = happyGoto action_8
action_5 (9) = happyGoto action_9
action_5 (10) = happyGoto action_10
action_5 (11) = happyGoto action_11
action_5 (14) = happyGoto action_12
action_5 (15) = happyGoto action_13
action_5 (16) = happyGoto action_14
action_5 (17) = happyGoto action_15
action_5 _ = happyReduce_9

action_6 (34) = happyShift action_66
action_6 (60) = happyShift action_67
action_6 (61) = happyShift action_68
action_6 _ = happyFail (happyExpListPerState 6)

action_7 (25) = happyShift action_65
action_7 _ = happyFail (happyExpListPerState 7)

action_8 _ = happyReduce_17

action_9 (21) = happyShift action_64
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (18) = happyShift action_16
action_10 (20) = happyShift action_17
action_10 (23) = happyShift action_18
action_10 (24) = happyShift action_19
action_10 (25) = happyShift action_20
action_10 (27) = happyShift action_21
action_10 (28) = happyShift action_22
action_10 (29) = happyShift action_23
action_10 (36) = happyShift action_24
action_10 (38) = happyShift action_25
action_10 (39) = happyShift action_26
action_10 (40) = happyShift action_27
action_10 (41) = happyShift action_28
action_10 (42) = happyShift action_29
action_10 (43) = happyShift action_30
action_10 (44) = happyShift action_31
action_10 (6) = happyGoto action_6
action_10 (7) = happyGoto action_7
action_10 (8) = happyGoto action_8
action_10 (9) = happyGoto action_63
action_10 (10) = happyGoto action_10
action_10 (11) = happyGoto action_11
action_10 (14) = happyGoto action_12
action_10 (15) = happyGoto action_13
action_10 (16) = happyGoto action_14
action_10 (17) = happyGoto action_15
action_10 _ = happyReduce_9

action_11 (22) = happyShift action_62
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_11

action_13 (29) = happyShift action_44
action_13 (30) = happyShift action_45
action_13 (31) = happyShift action_46
action_13 (32) = happyShift action_47
action_13 (33) = happyShift action_48
action_13 (37) = happyShift action_49
action_13 (46) = happyShift action_50
action_13 (48) = happyShift action_51
action_13 (49) = happyShift action_52
action_13 (50) = happyShift action_53
action_13 (51) = happyShift action_54
action_13 (52) = happyShift action_55
action_13 (53) = happyShift action_56
action_13 (54) = happyShift action_57
action_13 (56) = happyShift action_58
action_13 (57) = happyShift action_59
action_13 (58) = happyShift action_60
action_13 (59) = happyShift action_61
action_13 _ = happyReduce_18

action_14 _ = happyReduce_34

action_15 _ = happyReduce_32

action_16 (18) = happyShift action_16
action_16 (23) = happyShift action_18
action_16 (24) = happyShift action_19
action_16 (25) = happyShift action_20
action_16 (29) = happyShift action_23
action_16 (38) = happyShift action_25
action_16 (39) = happyShift action_26
action_16 (41) = happyShift action_28
action_16 (42) = happyShift action_29
action_16 (6) = happyGoto action_42
action_16 (15) = happyGoto action_43
action_16 (16) = happyGoto action_14
action_16 (17) = happyGoto action_15
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (18) = happyShift action_16
action_17 (20) = happyShift action_17
action_17 (23) = happyShift action_18
action_17 (24) = happyShift action_19
action_17 (25) = happyShift action_20
action_17 (27) = happyShift action_21
action_17 (28) = happyShift action_22
action_17 (29) = happyShift action_23
action_17 (36) = happyShift action_24
action_17 (38) = happyShift action_25
action_17 (39) = happyShift action_26
action_17 (40) = happyShift action_27
action_17 (41) = happyShift action_28
action_17 (42) = happyShift action_29
action_17 (43) = happyShift action_30
action_17 (44) = happyShift action_31
action_17 (6) = happyGoto action_6
action_17 (7) = happyGoto action_7
action_17 (8) = happyGoto action_8
action_17 (9) = happyGoto action_41
action_17 (10) = happyGoto action_10
action_17 (11) = happyGoto action_11
action_17 (14) = happyGoto action_12
action_17 (15) = happyGoto action_13
action_17 (16) = happyGoto action_14
action_17 (17) = happyGoto action_15
action_17 _ = happyReduce_9

action_18 _ = happyReduce_55

action_19 _ = happyReduce_56

action_20 (19) = happyReduce_33
action_20 (34) = happyReduce_3
action_20 (60) = happyReduce_3
action_20 (61) = happyReduce_3
action_20 _ = happyReduce_33

action_21 (18) = happyShift action_35
action_21 (23) = happyShift action_18
action_21 (24) = happyShift action_19
action_21 (25) = happyShift action_36
action_21 (29) = happyShift action_23
action_21 (38) = happyShift action_25
action_21 (39) = happyShift action_26
action_21 (41) = happyShift action_28
action_21 (42) = happyShift action_29
action_21 (15) = happyGoto action_40
action_21 (16) = happyGoto action_14
action_21 (17) = happyGoto action_15
action_21 _ = happyFail (happyExpListPerState 21)

action_22 _ = happyReduce_5

action_23 (18) = happyShift action_35
action_23 (23) = happyShift action_18
action_23 (24) = happyShift action_19
action_23 (25) = happyShift action_36
action_23 (29) = happyShift action_23
action_23 (38) = happyShift action_25
action_23 (39) = happyShift action_26
action_23 (41) = happyShift action_28
action_23 (42) = happyShift action_29
action_23 (15) = happyGoto action_39
action_23 (16) = happyGoto action_14
action_23 (17) = happyGoto action_15
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (18) = happyShift action_38
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (18) = happyShift action_35
action_25 (23) = happyShift action_18
action_25 (24) = happyShift action_19
action_25 (25) = happyShift action_36
action_25 (29) = happyShift action_23
action_25 (38) = happyShift action_25
action_25 (39) = happyShift action_26
action_25 (41) = happyShift action_28
action_25 (42) = happyShift action_29
action_25 (15) = happyGoto action_37
action_25 (16) = happyGoto action_14
action_25 (17) = happyGoto action_15
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (18) = happyShift action_35
action_26 (23) = happyShift action_18
action_26 (24) = happyShift action_19
action_26 (25) = happyShift action_36
action_26 (29) = happyShift action_23
action_26 (38) = happyShift action_25
action_26 (39) = happyShift action_26
action_26 (41) = happyShift action_28
action_26 (42) = happyShift action_29
action_26 (15) = happyGoto action_34
action_26 (16) = happyGoto action_14
action_26 (17) = happyGoto action_15
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (18) = happyShift action_33
action_27 _ = happyFail (happyExpListPerState 27)

action_28 _ = happyReduce_30

action_29 _ = happyReduce_31

action_30 _ = happyReduce_6

action_31 (18) = happyShift action_32
action_31 _ = happyFail (happyExpListPerState 31)

action_32 (18) = happyShift action_35
action_32 (23) = happyShift action_18
action_32 (24) = happyShift action_19
action_32 (25) = happyShift action_36
action_32 (29) = happyShift action_23
action_32 (38) = happyShift action_25
action_32 (39) = happyShift action_26
action_32 (41) = happyShift action_28
action_32 (42) = happyShift action_29
action_32 (15) = happyGoto action_97
action_32 (16) = happyGoto action_14
action_32 (17) = happyGoto action_15
action_32 _ = happyFail (happyExpListPerState 32)

action_33 (18) = happyShift action_16
action_33 (23) = happyShift action_18
action_33 (24) = happyShift action_19
action_33 (25) = happyShift action_20
action_33 (28) = happyShift action_22
action_33 (29) = happyShift action_23
action_33 (38) = happyShift action_25
action_33 (39) = happyShift action_26
action_33 (41) = happyShift action_28
action_33 (42) = happyShift action_29
action_33 (43) = happyShift action_30
action_33 (6) = happyGoto action_6
action_33 (7) = happyGoto action_7
action_33 (8) = happyGoto action_8
action_33 (11) = happyGoto action_94
action_33 (12) = happyGoto action_95
action_33 (15) = happyGoto action_96
action_33 (16) = happyGoto action_14
action_33 (17) = happyGoto action_15
action_33 _ = happyReduce_19

action_34 _ = happyReduce_53

action_35 (18) = happyShift action_35
action_35 (23) = happyShift action_18
action_35 (24) = happyShift action_19
action_35 (25) = happyShift action_36
action_35 (29) = happyShift action_23
action_35 (38) = happyShift action_25
action_35 (39) = happyShift action_26
action_35 (41) = happyShift action_28
action_35 (42) = happyShift action_29
action_35 (15) = happyGoto action_43
action_35 (16) = happyGoto action_14
action_35 (17) = happyGoto action_15
action_35 _ = happyFail (happyExpListPerState 35)

action_36 _ = happyReduce_33

action_37 _ = happyReduce_52

action_38 (18) = happyShift action_35
action_38 (23) = happyShift action_18
action_38 (24) = happyShift action_19
action_38 (25) = happyShift action_36
action_38 (29) = happyShift action_23
action_38 (38) = happyShift action_25
action_38 (39) = happyShift action_26
action_38 (41) = happyShift action_28
action_38 (42) = happyShift action_29
action_38 (15) = happyGoto action_93
action_38 (16) = happyGoto action_14
action_38 (17) = happyGoto action_15
action_38 _ = happyFail (happyExpListPerState 38)

action_39 _ = happyReduce_54

action_40 (22) = happyShift action_92
action_40 (29) = happyShift action_44
action_40 (30) = happyShift action_45
action_40 (31) = happyShift action_46
action_40 (32) = happyShift action_47
action_40 (33) = happyShift action_48
action_40 (37) = happyShift action_49
action_40 (48) = happyShift action_51
action_40 (49) = happyShift action_52
action_40 (50) = happyShift action_53
action_40 (51) = happyShift action_54
action_40 (52) = happyShift action_55
action_40 (53) = happyShift action_56
action_40 (54) = happyShift action_57
action_40 (56) = happyShift action_58
action_40 (57) = happyShift action_59
action_40 (58) = happyShift action_60
action_40 (59) = happyShift action_61
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (21) = happyShift action_91
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (19) = happyShift action_90
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (19) = happyShift action_89
action_43 (29) = happyShift action_44
action_43 (30) = happyShift action_45
action_43 (31) = happyShift action_46
action_43 (32) = happyShift action_47
action_43 (33) = happyShift action_48
action_43 (37) = happyShift action_49
action_43 (48) = happyShift action_51
action_43 (49) = happyShift action_52
action_43 (50) = happyShift action_53
action_43 (51) = happyShift action_54
action_43 (52) = happyShift action_55
action_43 (53) = happyShift action_56
action_43 (54) = happyShift action_57
action_43 (56) = happyShift action_58
action_43 (57) = happyShift action_59
action_43 (58) = happyShift action_60
action_43 (59) = happyShift action_61
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (18) = happyShift action_35
action_44 (23) = happyShift action_18
action_44 (24) = happyShift action_19
action_44 (25) = happyShift action_36
action_44 (29) = happyShift action_23
action_44 (38) = happyShift action_25
action_44 (39) = happyShift action_26
action_44 (41) = happyShift action_28
action_44 (42) = happyShift action_29
action_44 (15) = happyGoto action_88
action_44 (16) = happyGoto action_14
action_44 (17) = happyGoto action_15
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (18) = happyShift action_35
action_45 (23) = happyShift action_18
action_45 (24) = happyShift action_19
action_45 (25) = happyShift action_36
action_45 (29) = happyShift action_23
action_45 (38) = happyShift action_25
action_45 (39) = happyShift action_26
action_45 (41) = happyShift action_28
action_45 (42) = happyShift action_29
action_45 (15) = happyGoto action_87
action_45 (16) = happyGoto action_14
action_45 (17) = happyGoto action_15
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (18) = happyShift action_35
action_46 (23) = happyShift action_18
action_46 (24) = happyShift action_19
action_46 (25) = happyShift action_36
action_46 (29) = happyShift action_23
action_46 (38) = happyShift action_25
action_46 (39) = happyShift action_26
action_46 (41) = happyShift action_28
action_46 (42) = happyShift action_29
action_46 (15) = happyGoto action_86
action_46 (16) = happyGoto action_14
action_46 (17) = happyGoto action_15
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (18) = happyShift action_35
action_47 (23) = happyShift action_18
action_47 (24) = happyShift action_19
action_47 (25) = happyShift action_36
action_47 (29) = happyShift action_23
action_47 (38) = happyShift action_25
action_47 (39) = happyShift action_26
action_47 (41) = happyShift action_28
action_47 (42) = happyShift action_29
action_47 (15) = happyGoto action_85
action_47 (16) = happyGoto action_14
action_47 (17) = happyGoto action_15
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (18) = happyShift action_35
action_48 (23) = happyShift action_18
action_48 (24) = happyShift action_19
action_48 (25) = happyShift action_36
action_48 (29) = happyShift action_23
action_48 (38) = happyShift action_25
action_48 (39) = happyShift action_26
action_48 (41) = happyShift action_28
action_48 (42) = happyShift action_29
action_48 (15) = happyGoto action_84
action_48 (16) = happyGoto action_14
action_48 (17) = happyGoto action_15
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (18) = happyShift action_35
action_49 (23) = happyShift action_18
action_49 (24) = happyShift action_19
action_49 (25) = happyShift action_36
action_49 (29) = happyShift action_23
action_49 (38) = happyShift action_25
action_49 (39) = happyShift action_26
action_49 (41) = happyShift action_28
action_49 (42) = happyShift action_29
action_49 (15) = happyGoto action_83
action_49 (16) = happyGoto action_14
action_49 (17) = happyGoto action_15
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (18) = happyShift action_16
action_50 (20) = happyShift action_17
action_50 (23) = happyShift action_18
action_50 (24) = happyShift action_19
action_50 (25) = happyShift action_20
action_50 (27) = happyShift action_21
action_50 (28) = happyShift action_22
action_50 (29) = happyShift action_23
action_50 (36) = happyShift action_24
action_50 (38) = happyShift action_25
action_50 (39) = happyShift action_26
action_50 (40) = happyShift action_27
action_50 (41) = happyShift action_28
action_50 (42) = happyShift action_29
action_50 (43) = happyShift action_30
action_50 (44) = happyShift action_31
action_50 (6) = happyGoto action_6
action_50 (7) = happyGoto action_7
action_50 (8) = happyGoto action_8
action_50 (10) = happyGoto action_82
action_50 (11) = happyGoto action_11
action_50 (14) = happyGoto action_12
action_50 (15) = happyGoto action_13
action_50 (16) = happyGoto action_14
action_50 (17) = happyGoto action_15
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (18) = happyShift action_35
action_51 (23) = happyShift action_18
action_51 (24) = happyShift action_19
action_51 (25) = happyShift action_36
action_51 (29) = happyShift action_23
action_51 (38) = happyShift action_25
action_51 (39) = happyShift action_26
action_51 (41) = happyShift action_28
action_51 (42) = happyShift action_29
action_51 (15) = happyGoto action_81
action_51 (16) = happyGoto action_14
action_51 (17) = happyGoto action_15
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (18) = happyShift action_35
action_52 (23) = happyShift action_18
action_52 (24) = happyShift action_19
action_52 (25) = happyShift action_36
action_52 (29) = happyShift action_23
action_52 (38) = happyShift action_25
action_52 (39) = happyShift action_26
action_52 (41) = happyShift action_28
action_52 (42) = happyShift action_29
action_52 (15) = happyGoto action_80
action_52 (16) = happyGoto action_14
action_52 (17) = happyGoto action_15
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (18) = happyShift action_35
action_53 (23) = happyShift action_18
action_53 (24) = happyShift action_19
action_53 (25) = happyShift action_36
action_53 (29) = happyShift action_23
action_53 (38) = happyShift action_25
action_53 (39) = happyShift action_26
action_53 (41) = happyShift action_28
action_53 (42) = happyShift action_29
action_53 (15) = happyGoto action_79
action_53 (16) = happyGoto action_14
action_53 (17) = happyGoto action_15
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (18) = happyShift action_35
action_54 (23) = happyShift action_18
action_54 (24) = happyShift action_19
action_54 (25) = happyShift action_36
action_54 (29) = happyShift action_23
action_54 (38) = happyShift action_25
action_54 (39) = happyShift action_26
action_54 (41) = happyShift action_28
action_54 (42) = happyShift action_29
action_54 (15) = happyGoto action_78
action_54 (16) = happyGoto action_14
action_54 (17) = happyGoto action_15
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (18) = happyShift action_35
action_55 (23) = happyShift action_18
action_55 (24) = happyShift action_19
action_55 (25) = happyShift action_36
action_55 (29) = happyShift action_23
action_55 (38) = happyShift action_25
action_55 (39) = happyShift action_26
action_55 (41) = happyShift action_28
action_55 (42) = happyShift action_29
action_55 (15) = happyGoto action_77
action_55 (16) = happyGoto action_14
action_55 (17) = happyGoto action_15
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (18) = happyShift action_35
action_56 (23) = happyShift action_18
action_56 (24) = happyShift action_19
action_56 (25) = happyShift action_36
action_56 (29) = happyShift action_23
action_56 (38) = happyShift action_25
action_56 (39) = happyShift action_26
action_56 (41) = happyShift action_28
action_56 (42) = happyShift action_29
action_56 (15) = happyGoto action_76
action_56 (16) = happyGoto action_14
action_56 (17) = happyGoto action_15
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (18) = happyShift action_35
action_57 (23) = happyShift action_18
action_57 (24) = happyShift action_19
action_57 (25) = happyShift action_36
action_57 (29) = happyShift action_23
action_57 (38) = happyShift action_25
action_57 (39) = happyShift action_26
action_57 (41) = happyShift action_28
action_57 (42) = happyShift action_29
action_57 (15) = happyGoto action_75
action_57 (16) = happyGoto action_14
action_57 (17) = happyGoto action_15
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (18) = happyShift action_35
action_58 (23) = happyShift action_18
action_58 (24) = happyShift action_19
action_58 (25) = happyShift action_36
action_58 (29) = happyShift action_23
action_58 (38) = happyShift action_25
action_58 (39) = happyShift action_26
action_58 (41) = happyShift action_28
action_58 (42) = happyShift action_29
action_58 (15) = happyGoto action_74
action_58 (16) = happyGoto action_14
action_58 (17) = happyGoto action_15
action_58 _ = happyFail (happyExpListPerState 58)

action_59 (18) = happyShift action_35
action_59 (23) = happyShift action_18
action_59 (24) = happyShift action_19
action_59 (25) = happyShift action_36
action_59 (29) = happyShift action_23
action_59 (38) = happyShift action_25
action_59 (39) = happyShift action_26
action_59 (41) = happyShift action_28
action_59 (42) = happyShift action_29
action_59 (15) = happyGoto action_73
action_59 (16) = happyGoto action_14
action_59 (17) = happyGoto action_15
action_59 _ = happyFail (happyExpListPerState 59)

action_60 (18) = happyShift action_35
action_60 (23) = happyShift action_18
action_60 (24) = happyShift action_19
action_60 (25) = happyShift action_36
action_60 (29) = happyShift action_23
action_60 (38) = happyShift action_25
action_60 (39) = happyShift action_26
action_60 (41) = happyShift action_28
action_60 (42) = happyShift action_29
action_60 (15) = happyGoto action_72
action_60 (16) = happyGoto action_14
action_60 (17) = happyGoto action_15
action_60 _ = happyFail (happyExpListPerState 60)

action_61 (18) = happyShift action_35
action_61 (23) = happyShift action_18
action_61 (24) = happyShift action_19
action_61 (25) = happyShift action_36
action_61 (29) = happyShift action_23
action_61 (38) = happyShift action_25
action_61 (39) = happyShift action_26
action_61 (41) = happyShift action_28
action_61 (42) = happyShift action_29
action_61 (15) = happyGoto action_71
action_61 (16) = happyGoto action_14
action_61 (17) = happyGoto action_15
action_61 _ = happyFail (happyExpListPerState 61)

action_62 _ = happyReduce_12

action_63 _ = happyReduce_10

action_64 _ = happyReduce_2

action_65 (34) = happyShift action_70
action_65 _ = happyReduce_8

action_66 (18) = happyShift action_35
action_66 (23) = happyShift action_18
action_66 (24) = happyShift action_19
action_66 (25) = happyShift action_36
action_66 (29) = happyShift action_23
action_66 (38) = happyShift action_25
action_66 (39) = happyShift action_26
action_66 (41) = happyShift action_28
action_66 (42) = happyShift action_29
action_66 (15) = happyGoto action_69
action_66 (16) = happyGoto action_14
action_66 (17) = happyGoto action_15
action_66 _ = happyFail (happyExpListPerState 66)

action_67 _ = happyReduce_15

action_68 _ = happyReduce_16

action_69 (29) = happyShift action_44
action_69 (30) = happyShift action_45
action_69 (31) = happyShift action_46
action_69 (32) = happyShift action_47
action_69 (33) = happyShift action_48
action_69 (37) = happyShift action_49
action_69 (48) = happyShift action_51
action_69 (49) = happyShift action_52
action_69 (50) = happyShift action_53
action_69 (51) = happyShift action_54
action_69 (52) = happyShift action_55
action_69 (53) = happyShift action_56
action_69 (54) = happyShift action_57
action_69 (56) = happyShift action_58
action_69 (57) = happyShift action_59
action_69 (58) = happyShift action_60
action_69 (59) = happyShift action_61
action_69 _ = happyReduce_14

action_70 (18) = happyShift action_35
action_70 (23) = happyShift action_18
action_70 (24) = happyShift action_19
action_70 (25) = happyShift action_36
action_70 (29) = happyShift action_23
action_70 (38) = happyShift action_25
action_70 (39) = happyShift action_26
action_70 (41) = happyShift action_28
action_70 (42) = happyShift action_29
action_70 (15) = happyGoto action_102
action_70 (16) = happyGoto action_14
action_70 (17) = happyGoto action_15
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (29) = happyShift action_44
action_71 (30) = happyShift action_45
action_71 (31) = happyShift action_46
action_71 (32) = happyShift action_47
action_71 (33) = happyShift action_48
action_71 _ = happyReduce_41

action_72 (29) = happyShift action_44
action_72 (30) = happyShift action_45
action_72 (31) = happyShift action_46
action_72 (32) = happyShift action_47
action_72 (33) = happyShift action_48
action_72 _ = happyReduce_40

action_73 (29) = happyShift action_44
action_73 (30) = happyShift action_45
action_73 (31) = happyShift action_46
action_73 (32) = happyShift action_47
action_73 (33) = happyShift action_48
action_73 (37) = happyShift action_49
action_73 (48) = happyShift action_51
action_73 (49) = happyShift action_52
action_73 (50) = happyShift action_53
action_73 (51) = happyShift action_54
action_73 (52) = happyShift action_55
action_73 (53) = happyShift action_56
action_73 (56) = happyShift action_58
action_73 (58) = happyShift action_60
action_73 (59) = happyShift action_61
action_73 _ = happyReduce_43

action_74 (29) = happyShift action_44
action_74 (30) = happyShift action_45
action_74 (31) = happyShift action_46
action_74 (32) = happyShift action_47
action_74 (33) = happyShift action_48
action_74 (48) = happyShift action_51
action_74 (49) = happyShift action_52
action_74 (50) = happyShift action_53
action_74 (51) = happyShift action_54
action_74 (52) = happyShift action_55
action_74 (53) = happyShift action_56
action_74 (58) = happyShift action_60
action_74 (59) = happyShift action_61
action_74 _ = happyReduce_42

action_75 (29) = happyShift action_44
action_75 (30) = happyShift action_45
action_75 (31) = happyShift action_46
action_75 (32) = happyShift action_47
action_75 (33) = happyShift action_48
action_75 (37) = happyShift action_49
action_75 (48) = happyShift action_51
action_75 (49) = happyShift action_52
action_75 (50) = happyShift action_53
action_75 (51) = happyShift action_54
action_75 (52) = happyShift action_55
action_75 (53) = happyShift action_56
action_75 (56) = happyShift action_58
action_75 (57) = happyShift action_59
action_75 (58) = happyShift action_60
action_75 (59) = happyShift action_61
action_75 _ = happyReduce_45

action_76 (29) = happyShift action_44
action_76 (30) = happyShift action_45
action_76 (31) = happyShift action_46
action_76 (32) = happyShift action_47
action_76 (33) = happyShift action_48
action_76 (48) = happyShift action_51
action_76 (49) = happyShift action_52
action_76 (50) = happyShift action_53
action_76 (51) = happyShift action_54
action_76 (58) = happyShift action_60
action_76 (59) = happyShift action_61
action_76 _ = happyReduce_51

action_77 (29) = happyShift action_44
action_77 (30) = happyShift action_45
action_77 (31) = happyShift action_46
action_77 (32) = happyShift action_47
action_77 (33) = happyShift action_48
action_77 (48) = happyShift action_51
action_77 (49) = happyShift action_52
action_77 (50) = happyShift action_53
action_77 (51) = happyShift action_54
action_77 (58) = happyShift action_60
action_77 (59) = happyShift action_61
action_77 _ = happyReduce_50

action_78 (29) = happyShift action_44
action_78 (30) = happyShift action_45
action_78 (31) = happyShift action_46
action_78 (32) = happyShift action_47
action_78 (33) = happyShift action_48
action_78 (58) = happyShift action_60
action_78 (59) = happyShift action_61
action_78 _ = happyReduce_47

action_79 (29) = happyShift action_44
action_79 (30) = happyShift action_45
action_79 (31) = happyShift action_46
action_79 (32) = happyShift action_47
action_79 (33) = happyShift action_48
action_79 (58) = happyShift action_60
action_79 (59) = happyShift action_61
action_79 _ = happyReduce_49

action_80 (29) = happyShift action_44
action_80 (30) = happyShift action_45
action_80 (31) = happyShift action_46
action_80 (32) = happyShift action_47
action_80 (33) = happyShift action_48
action_80 (58) = happyShift action_60
action_80 (59) = happyShift action_61
action_80 _ = happyReduce_48

action_81 (29) = happyShift action_44
action_81 (30) = happyShift action_45
action_81 (31) = happyShift action_46
action_81 (32) = happyShift action_47
action_81 (33) = happyShift action_48
action_81 (58) = happyShift action_60
action_81 (59) = happyShift action_61
action_81 _ = happyReduce_46

action_82 (47) = happyShift action_101
action_82 _ = happyReduce_25

action_83 (29) = happyShift action_44
action_83 (30) = happyShift action_45
action_83 (31) = happyShift action_46
action_83 (32) = happyShift action_47
action_83 (33) = happyShift action_48
action_83 (48) = happyShift action_51
action_83 (49) = happyShift action_52
action_83 (50) = happyShift action_53
action_83 (51) = happyShift action_54
action_83 (52) = happyShift action_55
action_83 (53) = happyShift action_56
action_83 (56) = happyShift action_58
action_83 (58) = happyShift action_60
action_83 (59) = happyShift action_61
action_83 _ = happyReduce_44

action_84 _ = happyReduce_39

action_85 _ = happyReduce_38

action_86 _ = happyReduce_37

action_87 (31) = happyShift action_46
action_87 (32) = happyShift action_47
action_87 (33) = happyShift action_48
action_87 _ = happyReduce_36

action_88 (31) = happyShift action_46
action_88 (32) = happyShift action_47
action_88 (33) = happyShift action_48
action_88 _ = happyReduce_35

action_89 _ = happyReduce_29

action_90 _ = happyReduce_4

action_91 _ = happyReduce_13

action_92 _ = happyReduce_28

action_93 (19) = happyShift action_100
action_93 (29) = happyShift action_44
action_93 (30) = happyShift action_45
action_93 (31) = happyShift action_46
action_93 (32) = happyShift action_47
action_93 (33) = happyShift action_48
action_93 (37) = happyShift action_49
action_93 (48) = happyShift action_51
action_93 (49) = happyShift action_52
action_93 (50) = happyShift action_53
action_93 (51) = happyShift action_54
action_93 (52) = happyShift action_55
action_93 (53) = happyShift action_56
action_93 (54) = happyShift action_57
action_93 (56) = happyShift action_58
action_93 (57) = happyShift action_59
action_93 (58) = happyShift action_60
action_93 (59) = happyShift action_61
action_93 _ = happyFail (happyExpListPerState 93)

action_94 _ = happyReduce_20

action_95 (22) = happyShift action_99
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (29) = happyShift action_44
action_96 (30) = happyShift action_45
action_96 (31) = happyShift action_46
action_96 (32) = happyShift action_47
action_96 (33) = happyShift action_48
action_96 (37) = happyShift action_49
action_96 (48) = happyShift action_51
action_96 (49) = happyShift action_52
action_96 (50) = happyShift action_53
action_96 (51) = happyShift action_54
action_96 (52) = happyShift action_55
action_96 (53) = happyShift action_56
action_96 (54) = happyShift action_57
action_96 (56) = happyShift action_58
action_96 (57) = happyShift action_59
action_96 (58) = happyShift action_60
action_96 (59) = happyShift action_61
action_96 _ = happyReduce_18

action_97 (19) = happyShift action_98
action_97 (29) = happyShift action_44
action_97 (30) = happyShift action_45
action_97 (31) = happyShift action_46
action_97 (32) = happyShift action_47
action_97 (33) = happyShift action_48
action_97 (37) = happyShift action_49
action_97 (48) = happyShift action_51
action_97 (49) = happyShift action_52
action_97 (50) = happyShift action_53
action_97 (51) = happyShift action_54
action_97 (52) = happyShift action_55
action_97 (53) = happyShift action_56
action_97 (54) = happyShift action_57
action_97 (56) = happyShift action_58
action_97 (57) = happyShift action_59
action_97 (58) = happyShift action_60
action_97 (59) = happyShift action_61
action_97 _ = happyFail (happyExpListPerState 97)

action_98 (18) = happyShift action_16
action_98 (20) = happyShift action_17
action_98 (23) = happyShift action_18
action_98 (24) = happyShift action_19
action_98 (25) = happyShift action_20
action_98 (27) = happyShift action_21
action_98 (28) = happyShift action_22
action_98 (29) = happyShift action_23
action_98 (36) = happyShift action_24
action_98 (38) = happyShift action_25
action_98 (39) = happyShift action_26
action_98 (40) = happyShift action_27
action_98 (41) = happyShift action_28
action_98 (42) = happyShift action_29
action_98 (43) = happyShift action_30
action_98 (44) = happyShift action_31
action_98 (6) = happyGoto action_6
action_98 (7) = happyGoto action_7
action_98 (8) = happyGoto action_8
action_98 (10) = happyGoto action_107
action_98 (11) = happyGoto action_11
action_98 (14) = happyGoto action_12
action_98 (15) = happyGoto action_13
action_98 (16) = happyGoto action_14
action_98 (17) = happyGoto action_15
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (18) = happyShift action_35
action_99 (23) = happyShift action_18
action_99 (24) = happyShift action_19
action_99 (25) = happyShift action_36
action_99 (29) = happyShift action_23
action_99 (38) = happyShift action_25
action_99 (39) = happyShift action_26
action_99 (41) = happyShift action_28
action_99 (42) = happyShift action_29
action_99 (15) = happyGoto action_106
action_99 (16) = happyGoto action_14
action_99 (17) = happyGoto action_15
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (18) = happyShift action_16
action_100 (20) = happyShift action_17
action_100 (23) = happyShift action_18
action_100 (24) = happyShift action_19
action_100 (25) = happyShift action_20
action_100 (27) = happyShift action_21
action_100 (28) = happyShift action_22
action_100 (29) = happyShift action_23
action_100 (36) = happyShift action_24
action_100 (38) = happyShift action_25
action_100 (39) = happyShift action_26
action_100 (40) = happyShift action_27
action_100 (41) = happyShift action_28
action_100 (42) = happyShift action_29
action_100 (43) = happyShift action_30
action_100 (44) = happyShift action_31
action_100 (6) = happyGoto action_6
action_100 (7) = happyGoto action_7
action_100 (8) = happyGoto action_8
action_100 (10) = happyGoto action_105
action_100 (11) = happyGoto action_11
action_100 (14) = happyGoto action_12
action_100 (15) = happyGoto action_13
action_100 (16) = happyGoto action_14
action_100 (17) = happyGoto action_15
action_100 _ = happyFail (happyExpListPerState 100)

action_101 (45) = happyShift action_104
action_101 (13) = happyGoto action_103
action_101 _ = happyFail (happyExpListPerState 101)

action_102 (29) = happyShift action_44
action_102 (30) = happyShift action_45
action_102 (31) = happyShift action_46
action_102 (32) = happyShift action_47
action_102 (33) = happyShift action_48
action_102 (37) = happyShift action_49
action_102 (48) = happyShift action_51
action_102 (49) = happyShift action_52
action_102 (50) = happyShift action_53
action_102 (51) = happyShift action_54
action_102 (52) = happyShift action_55
action_102 (53) = happyShift action_56
action_102 (54) = happyShift action_57
action_102 (56) = happyShift action_58
action_102 (57) = happyShift action_59
action_102 (58) = happyShift action_60
action_102 (59) = happyShift action_61
action_102 _ = happyReduce_7

action_103 _ = happyReduce_24

action_104 (18) = happyShift action_16
action_104 (20) = happyShift action_17
action_104 (23) = happyShift action_18
action_104 (24) = happyShift action_19
action_104 (25) = happyShift action_20
action_104 (27) = happyShift action_21
action_104 (28) = happyShift action_22
action_104 (29) = happyShift action_23
action_104 (36) = happyShift action_24
action_104 (38) = happyShift action_25
action_104 (39) = happyShift action_26
action_104 (40) = happyShift action_27
action_104 (41) = happyShift action_28
action_104 (42) = happyShift action_29
action_104 (43) = happyShift action_30
action_104 (44) = happyShift action_31
action_104 (6) = happyGoto action_6
action_104 (7) = happyGoto action_7
action_104 (8) = happyGoto action_8
action_104 (10) = happyGoto action_110
action_104 (11) = happyGoto action_11
action_104 (14) = happyGoto action_12
action_104 (15) = happyGoto action_13
action_104 (16) = happyGoto action_14
action_104 (17) = happyGoto action_15
action_104 _ = happyFail (happyExpListPerState 104)

action_105 _ = happyReduce_26

action_106 (22) = happyShift action_109
action_106 (29) = happyShift action_44
action_106 (30) = happyShift action_45
action_106 (31) = happyShift action_46
action_106 (32) = happyShift action_47
action_106 (33) = happyShift action_48
action_106 (37) = happyShift action_49
action_106 (48) = happyShift action_51
action_106 (49) = happyShift action_52
action_106 (50) = happyShift action_53
action_106 (51) = happyShift action_54
action_106 (52) = happyShift action_55
action_106 (53) = happyShift action_56
action_106 (54) = happyShift action_57
action_106 (56) = happyShift action_58
action_106 (57) = happyShift action_59
action_106 (58) = happyShift action_60
action_106 (59) = happyShift action_61
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (45) = happyShift action_104
action_107 (13) = happyGoto action_108
action_107 _ = happyReduce_23

action_108 _ = happyReduce_22

action_109 (18) = happyShift action_16
action_109 (23) = happyShift action_18
action_109 (24) = happyShift action_19
action_109 (25) = happyShift action_20
action_109 (28) = happyShift action_22
action_109 (29) = happyShift action_23
action_109 (38) = happyShift action_25
action_109 (39) = happyShift action_26
action_109 (41) = happyShift action_28
action_109 (42) = happyShift action_29
action_109 (43) = happyShift action_30
action_109 (6) = happyGoto action_6
action_109 (7) = happyGoto action_7
action_109 (8) = happyGoto action_8
action_109 (11) = happyGoto action_94
action_109 (12) = happyGoto action_111
action_109 (15) = happyGoto action_96
action_109 (16) = happyGoto action_14
action_109 (17) = happyGoto action_15
action_109 _ = happyReduce_19

action_110 _ = happyReduce_21

action_111 (19) = happyShift action_112
action_111 _ = happyFail (happyExpListPerState 111)

action_112 (18) = happyShift action_16
action_112 (20) = happyShift action_17
action_112 (23) = happyShift action_18
action_112 (24) = happyShift action_19
action_112 (25) = happyShift action_20
action_112 (27) = happyShift action_21
action_112 (28) = happyShift action_22
action_112 (29) = happyShift action_23
action_112 (36) = happyShift action_24
action_112 (38) = happyShift action_25
action_112 (39) = happyShift action_26
action_112 (40) = happyShift action_27
action_112 (41) = happyShift action_28
action_112 (42) = happyShift action_29
action_112 (43) = happyShift action_30
action_112 (44) = happyShift action_31
action_112 (6) = happyGoto action_6
action_112 (7) = happyGoto action_7
action_112 (8) = happyGoto action_8
action_112 (10) = happyGoto action_113
action_112 (11) = happyGoto action_11
action_112 (14) = happyGoto action_12
action_112 (15) = happyGoto action_13
action_112 (16) = happyGoto action_14
action_112 (17) = happyGoto action_15
action_112 _ = happyFail (happyExpListPerState 112)

action_113 _ = happyReduce_27

happyReduce_1 = happySpecReduce_2  4 happyReduction_1
happyReduction_1 (HappyAbsSyn5  happy_var_2)
	_
	 =  HappyAbsSyn4
		 (Block happy_var_2
	)
happyReduction_1 _ _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_3  5 happyReduction_2
happyReduction_2 _
	(HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn5
		 (happy_var_2
	)
happyReduction_2 _ _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1  6 happyReduction_3
happyReduction_3 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_3 _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_3  6 happyReduction_4
happyReduction_4 _
	(HappyAbsSyn6  happy_var_2)
	_
	 =  HappyAbsSyn6
		 (happy_var_2
	)
happyReduction_4 _ _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_1  7 happyReduction_5
happyReduction_5 _
	 =  HappyAbsSyn7
		 (INTEGER
	)

happyReduce_6 = happySpecReduce_1  7 happyReduction_6
happyReduction_6 _
	 =  HappyAbsSyn7
		 (BOOLEAN
	)

happyReduce_7 = happyReduce 4 8 happyReduction_7
happyReduction_7 ((HappyAbsSyn15  happy_var_4) `HappyStk`
	(HappyTerminal (TokAsgnop happy_var_3)) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn7  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn8
		 (checkDeclAsgn happy_var_2 happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_8 = happySpecReduce_2  8 happyReduction_8
happyReduction_8 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn8
		 (JustDecl happy_var_2 happy_var_1
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_0  9 happyReduction_9
happyReduction_9  =  HappyAbsSyn9
		 ([]
	)

happyReduce_10 = happySpecReduce_2  9 happyReduction_10
happyReduction_10 (HappyAbsSyn9  happy_var_2)
	(HappyAbsSyn10  happy_var_1)
	 =  HappyAbsSyn9
		 (happy_var_1 : happy_var_2
	)
happyReduction_10 _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_1  10 happyReduction_11
happyReduction_11 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn10
		 (ControlStmt happy_var_1
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_2  10 happyReduction_12
happyReduction_12 _
	(HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (Simp happy_var_1
	)
happyReduction_12 _ _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  10 happyReduction_13
happyReduction_13 _
	(HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn10
		 (Stmts happy_var_2
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_3  11 happyReduction_14
happyReduction_14 (HappyAbsSyn15  happy_var_3)
	(HappyTerminal (TokAsgnop happy_var_2))
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn11
		 (Asgn happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_14 _ _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_2  11 happyReduction_15
happyReduction_15 _
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn11
		 (AsgnP happy_var_1 Incr
	)
happyReduction_15 _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_2  11 happyReduction_16
happyReduction_16 _
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn11
		 (AsgnP happy_var_1 Decr
	)
happyReduction_16 _ _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  11 happyReduction_17
happyReduction_17 (HappyAbsSyn8  happy_var_1)
	 =  HappyAbsSyn11
		 (Decl happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_1  11 happyReduction_18
happyReduction_18 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn11
		 (Exp happy_var_1
	)
happyReduction_18 _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_0  12 happyReduction_19
happyReduction_19  =  HappyAbsSyn12
		 (SimpNop
	)

happyReduce_20 = happySpecReduce_1  12 happyReduction_20
happyReduction_20 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn12
		 (Opt happy_var_1
	)
happyReduction_20 _  = notHappyAtAll 

happyReduce_21 = happySpecReduce_2  13 happyReduction_21
happyReduction_21 (HappyAbsSyn10  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (Else happy_var_2
	)
happyReduction_21 _ _  = notHappyAtAll 

happyReduce_22 = happyReduce 6 14 happyReduction_22
happyReduction_22 ((HappyAbsSyn13  happy_var_6) `HappyStk`
	(HappyAbsSyn10  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (Condition happy_var_3 happy_var_5 happy_var_6
	) `HappyStk` happyRest

happyReduce_23 = happyReduce 5 14 happyReduction_23
happyReduction_23 ((HappyAbsSyn10  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (Condition happy_var_3 happy_var_5 (ElseNop)
	) `HappyStk` happyRest

happyReduce_24 = happyReduce 5 14 happyReduction_24
happyReduction_24 ((HappyAbsSyn13  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (Condition happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_25 = happySpecReduce_3  14 happyReduction_25
happyReduction_25 (HappyAbsSyn10  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (Condition happy_var_1 happy_var_3 {ElseNop}
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happyReduce 5 14 happyReduction_26
happyReduction_26 ((HappyAbsSyn10  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (While happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_27 = happyReduce 9 14 happyReduction_27
happyReduction_27 ((HappyAbsSyn10  happy_var_9) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn12  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn12  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (For happy_var_3 happy_var_5 happy_var_7 happy_var_9
	) `HappyStk` happyRest

happyReduce_28 = happySpecReduce_3  14 happyReduction_28
happyReduction_28 _
	(HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn14
		 (Retn happy_var_2
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_3  15 happyReduction_29
happyReduction_29 _
	(HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (happy_var_2
	)
happyReduction_29 _ _ _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_1  15 happyReduction_30
happyReduction_30 _
	 =  HappyAbsSyn15
		 (Int 1
	)

happyReduce_31 = happySpecReduce_1  15 happyReduction_31
happyReduction_31 _
	 =  HappyAbsSyn15
		 (Int 0
	)

happyReduce_32 = happySpecReduce_1  15 happyReduction_32
happyReduction_32 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_1  15 happyReduction_33
happyReduction_33 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn15
		 (Ident happy_var_1
	)
happyReduction_33 _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  15 happyReduction_34
happyReduction_34 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_3  16 happyReduction_35
happyReduction_35 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Sub happy_var_1 happy_var_3
	)
happyReduction_35 _ _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_3  16 happyReduction_36
happyReduction_36 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Add happy_var_1 happy_var_3
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  16 happyReduction_37
happyReduction_37 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Mul happy_var_1 happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_3  16 happyReduction_38
happyReduction_38 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Div happy_var_1 happy_var_3
	)
happyReduction_38 _ _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_3  16 happyReduction_39
happyReduction_39 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Mod happy_var_1 happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_3  16 happyReduction_40
happyReduction_40 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Lshift happy_var_1 happy_var_3
	)
happyReduction_40 _ _ _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_3  16 happyReduction_41
happyReduction_41 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Rshift happy_var_1 happy_var_3
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_3  16 happyReduction_42
happyReduction_42 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop And happy_var_1 happy_var_3
	)
happyReduction_42 _ _ _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_3  16 happyReduction_43
happyReduction_43 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Or happy_var_1 happy_var_3
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_3  16 happyReduction_44
happyReduction_44 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Xor happy_var_1 happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  16 happyReduction_45
happyReduction_45 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop BoolAnd happy_var_1 happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_3  16 happyReduction_46
happyReduction_46 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Less happy_var_1 happy_var_3
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_3  16 happyReduction_47
happyReduction_47 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Leq happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_3  16 happyReduction_48
happyReduction_48 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Greater happy_var_1 happy_var_3
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_3  16 happyReduction_49
happyReduction_49 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop Geq happy_var_1 happy_var_3
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_3  16 happyReduction_50
happyReduction_50 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop BoolEq happy_var_1 happy_var_3
	)
happyReduction_50 _ _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_3  16 happyReduction_51
happyReduction_51 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn16
		 (Binop NotEq happy_var_1 happy_var_3
	)
happyReduction_51 _ _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_2  16 happyReduction_52
happyReduction_52 (HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (Unop Not happy_var_2
	)
happyReduction_52 _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_2  16 happyReduction_53
happyReduction_53 (HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (Unop Cmpl happy_var_2
	)
happyReduction_53 _ _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_2  16 happyReduction_54
happyReduction_54 (HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (Unop Neg happy_var_2
	)
happyReduction_54 _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_1  17 happyReduction_55
happyReduction_55 (HappyTerminal (TokDec happy_var_1))
	 =  HappyAbsSyn17
		 (checkDec happy_var_1
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_1  17 happyReduction_56
happyReduction_56 (HappyTerminal (TokHex happy_var_1))
	 =  HappyAbsSyn17
		 (checkHex happy_var_1
	)
happyReduction_56 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 62 62 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TokLParen -> cont 18;
	TokRParen -> cont 19;
	TokLBrace -> cont 20;
	TokRBrace -> cont 21;
	TokSemi -> cont 22;
	TokDec happy_dollar_dollar -> cont 23;
	TokHex happy_dollar_dollar -> cont 24;
	TokIdent happy_dollar_dollar -> cont 25;
	TokMain -> cont 26;
	TokReturn -> cont 27;
	TokInt -> cont 28;
	TokMinus -> cont 29;
	TokPlus -> cont 30;
	TokTimes -> cont 31;
	TokDiv -> cont 32;
	TokMod -> cont 33;
	TokAsgnop happy_dollar_dollar -> cont 34;
	TokReserved -> cont 35;
	TokWhile -> cont 36;
	TokXor -> cont 37;
	TokUnop Not -> cont 38;
	TokUnop Cmpl -> cont 39;
	TokFor -> cont 40;
	TokTrue -> cont 41;
	TokFalse -> cont 42;
	TokBool -> cont 43;
	TokIf -> cont 44;
	TokElse -> cont 45;
	TokIf -> cont 46;
	TokElse -> cont 47;
	TokLess -> cont 48;
	TokGreater -> cont 49;
	TokGeq -> cont 50;
	TokLeq -> cont 51;
	TokBoolEq -> cont 52;
	TokNotEq -> cont 53;
	TokBoolAnd -> cont 54;
	TokBoolOr -> cont 55;
	TokAnd -> cont 56;
	TokOr -> cont 57;
	TokLshift -> cont 58;
	TokRshift -> cont 59;
	TokIncr -> cont 60;
	TokDecr -> cont 61;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 62 tk tks = happyError' (tks, explist)
happyError_ explist _ tk tks = happyError' ((tk:tks), explist)

newtype HappyIdentity a = HappyIdentity a
happyIdentity = HappyIdentity
happyRunIdentity (HappyIdentity a) = a

instance Functor HappyIdentity where
    fmap f (HappyIdentity a) = HappyIdentity (f a)

instance Applicative HappyIdentity where
    pure  = HappyIdentity
    (<*>) = ap
instance Monad HappyIdentity where
    return = pure
    (HappyIdentity p) >>= q = q p

happyThen :: () => HappyIdentity a -> (a -> HappyIdentity b) -> HappyIdentity b
happyThen = (>>=)
happyReturn :: () => a -> HappyIdentity a
happyReturn = (return)
happyThen1 m k tks = (>>=) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> HappyIdentity a
happyReturn1 = \a tks -> (return) a
happyError' :: () => ([(Token)], [String]) -> HappyIdentity a
happyError' = HappyIdentity . (\(tokens, _) -> parseError tokens)
parseTokens tks = happyRunIdentity happySomeParser where
 happySomeParser = happyThen (happyParse action_0 tks) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


parseError :: [Token] -> a
parseError t = error ("Parse Error " ++ (show t))

checkDeclAsgn :: Ident -> Asnop -> Type -> Exp -> Decl
checkDeclAsgn v op tp e =
  case op of
    Equal -> DeclAsgn v tp e
    _ -> error "Invalid assignment operator on a declaration"

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "<built-in>" #-}
{-# LINE 15 "<built-in>" #-}
{-# LINE 1 "/Users/ericyang/.stack/programs/x86_64-osx/ghc-8.6.5/lib/ghc-8.6.5/include/ghcversion.h" #-}
















{-# LINE 16 "<built-in>" #-}
{-# LINE 1 "/var/folders/wx/f248vdq55pxdyqh_sfw617nr0000gn/T/ghc74140_0/ghc_2.h" #-}

































































































































































































{-# LINE 17 "<built-in>" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp 










{-# LINE 43 "templates/GenericTemplate.hs" #-}

data Happy_IntList = HappyCons Int Happy_IntList








{-# LINE 65 "templates/GenericTemplate.hs" #-}


{-# LINE 75 "templates/GenericTemplate.hs" #-}










infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is (1), it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action


{-# LINE 137 "templates/GenericTemplate.hs" #-}


{-# LINE 147 "templates/GenericTemplate.hs" #-}
indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x < y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `div` 16)) (bit `mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Int ->                    -- token number
         Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k - ((1) :: Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n - ((1) :: Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n - ((1)::Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery ((1) is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  (1) tk old_st (((HappyState (action))):(sts)) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        action (1) (1) tk (HappyState (action)) sts ((saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ( (HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.

