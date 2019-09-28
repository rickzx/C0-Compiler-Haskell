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

data HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16
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

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,534) ([0,256,0,0,0,32,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,7626,4072,0,0,32,0,0,0,0,0,0,2048,0,0,0,56480,65153,0,0,64,0,0,0,0,0,0,0,40832,64768,253,0,0,0,0,0,0,0,0,18184,3456,0,0,3813,2036,0,0,0,0,0,0,0,0,0,0,0,0,0,36368,6912,0,0,0,0,0,16384,568,108,0,2048,0,0,0,57600,45064,1,0,7200,13825,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,18184,3456,0,0,3297,944,0,0,0,0,0,0,0,0,0,28800,55300,0,0,0,0,0,0,61472,40977,1983,0,2,0,0,4096,18368,65152,30,57600,45064,1,0,7200,13825,0,0,9092,1728,0,32768,1136,216,0,4096,142,27,0,49664,24593,3,0,14400,27650,0,0,18184,3456,0,0,2273,432,0,8192,284,54,0,33792,49187,6,0,28800,55300,0,0,36368,6912,0,0,4546,864,0,16384,568,108,0,2048,32839,13,0,57600,45064,1,0,7200,13825,0,0,9092,1728,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,8192,284,54,0,0,992,0,0,0,124,0,0,32768,143,13564,0,61440,32769,1567,0,15872,61442,243,0,1984,7680,24,0,248,960,3,0,31,24576,0,57344,3,3072,0,31744,0,384,0,3968,0,48,0,4592,49120,7,0,62,54256,0,49152,32839,7934,0,0,0,0,0,0,0,0,0,0,0,0,0,112,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,512,2296,57296,3,0,0,0,0,64,0,0,0,31745,59396,495,20480,16622,127,0,49664,24593,3,0,47424,64771,1,0,18184,3456,0,0,63488,53256,991,0,7936,64001,123,0,0,0,0,2048,1148,61416,1,0,32768,0,0,0,0,0,16384,953,509,0,2048,32871,29,0,512,0,0,0,0,0,0,0,15252,8144,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Block","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","Operation","Intconst","'('","')'","'{'","'}'","';'","dec","hex","ident","tokmain","ret","int","'-'","'+'","'*'","'/'","'%'","asgnop","kill","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 61
        bit_end = (st + 1) * 61
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..60]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (25) = happyShift action_2
action_0 (4) = happyGoto action_3
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (25) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (19) = happyShift action_5
action_2 (5) = happyGoto action_4
action_2 _ = happyFail (happyExpListPerState 2)

action_3 (61) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_1

action_5 (17) = happyShift action_15
action_5 (19) = happyShift action_16
action_5 (22) = happyShift action_17
action_5 (23) = happyShift action_18
action_5 (24) = happyShift action_19
action_5 (26) = happyShift action_20
action_5 (27) = happyShift action_21
action_5 (28) = happyShift action_22
action_5 (35) = happyShift action_23
action_5 (37) = happyShift action_24
action_5 (38) = happyShift action_25
action_5 (39) = happyShift action_26
action_5 (40) = happyShift action_27
action_5 (41) = happyShift action_28
action_5 (42) = happyShift action_29
action_5 (43) = happyShift action_30
action_5 (6) = happyGoto action_6
action_5 (7) = happyGoto action_7
action_5 (8) = happyGoto action_8
action_5 (9) = happyGoto action_9
action_5 (10) = happyGoto action_10
action_5 (13) = happyGoto action_11
action_5 (14) = happyGoto action_12
action_5 (15) = happyGoto action_13
action_5 (16) = happyGoto action_14
action_5 _ = happyReduce_7

action_6 (24) = happyShift action_64
action_6 _ = happyFail (happyExpListPerState 6)

action_7 _ = happyReduce_15

action_8 (20) = happyShift action_63
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (17) = happyShift action_15
action_9 (19) = happyShift action_16
action_9 (22) = happyShift action_17
action_9 (23) = happyShift action_18
action_9 (24) = happyShift action_19
action_9 (26) = happyShift action_20
action_9 (27) = happyShift action_21
action_9 (28) = happyShift action_22
action_9 (35) = happyShift action_23
action_9 (37) = happyShift action_24
action_9 (38) = happyShift action_25
action_9 (39) = happyShift action_26
action_9 (40) = happyShift action_27
action_9 (41) = happyShift action_28
action_9 (42) = happyShift action_29
action_9 (43) = happyShift action_30
action_9 (6) = happyGoto action_6
action_9 (7) = happyGoto action_7
action_9 (8) = happyGoto action_62
action_9 (9) = happyGoto action_9
action_9 (10) = happyGoto action_10
action_9 (13) = happyGoto action_11
action_9 (14) = happyGoto action_12
action_9 (15) = happyGoto action_13
action_9 (16) = happyGoto action_14
action_9 _ = happyReduce_7

action_10 (21) = happyShift action_61
action_10 _ = happyFail (happyExpListPerState 10)

action_11 _ = happyReduce_9

action_12 (28) = happyShift action_40
action_12 (29) = happyShift action_41
action_12 (30) = happyShift action_42
action_12 (31) = happyShift action_43
action_12 (32) = happyShift action_44
action_12 (33) = happyShift action_45
action_12 (36) = happyShift action_46
action_12 (45) = happyShift action_47
action_12 (47) = happyShift action_48
action_12 (48) = happyShift action_49
action_12 (49) = happyShift action_50
action_12 (50) = happyShift action_51
action_12 (51) = happyShift action_52
action_12 (52) = happyShift action_53
action_12 (53) = happyShift action_54
action_12 (55) = happyShift action_55
action_12 (56) = happyShift action_56
action_12 (57) = happyShift action_57
action_12 (58) = happyShift action_58
action_12 (59) = happyShift action_59
action_12 (60) = happyShift action_60
action_12 _ = happyReduce_16

action_13 _ = happyReduce_31

action_14 _ = happyReduce_29

action_15 (17) = happyShift action_15
action_15 (22) = happyShift action_17
action_15 (23) = happyShift action_18
action_15 (24) = happyShift action_19
action_15 (28) = happyShift action_22
action_15 (37) = happyShift action_24
action_15 (38) = happyShift action_25
action_15 (40) = happyShift action_27
action_15 (41) = happyShift action_28
action_15 (14) = happyGoto action_39
action_15 (15) = happyGoto action_13
action_15 (16) = happyGoto action_14
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (17) = happyShift action_15
action_16 (19) = happyShift action_16
action_16 (22) = happyShift action_17
action_16 (23) = happyShift action_18
action_16 (24) = happyShift action_19
action_16 (26) = happyShift action_20
action_16 (27) = happyShift action_21
action_16 (28) = happyShift action_22
action_16 (35) = happyShift action_23
action_16 (37) = happyShift action_24
action_16 (38) = happyShift action_25
action_16 (39) = happyShift action_26
action_16 (40) = happyShift action_27
action_16 (41) = happyShift action_28
action_16 (42) = happyShift action_29
action_16 (43) = happyShift action_30
action_16 (6) = happyGoto action_6
action_16 (7) = happyGoto action_7
action_16 (8) = happyGoto action_38
action_16 (9) = happyGoto action_9
action_16 (10) = happyGoto action_10
action_16 (13) = happyGoto action_11
action_16 (14) = happyGoto action_12
action_16 (15) = happyGoto action_13
action_16 (16) = happyGoto action_14
action_16 _ = happyReduce_7

action_17 _ = happyReduce_52

action_18 _ = happyReduce_53

action_19 _ = happyReduce_30

action_20 (17) = happyShift action_15
action_20 (22) = happyShift action_17
action_20 (23) = happyShift action_18
action_20 (24) = happyShift action_19
action_20 (28) = happyShift action_22
action_20 (37) = happyShift action_24
action_20 (38) = happyShift action_25
action_20 (40) = happyShift action_27
action_20 (41) = happyShift action_28
action_20 (14) = happyGoto action_37
action_20 (15) = happyGoto action_13
action_20 (16) = happyGoto action_14
action_20 _ = happyFail (happyExpListPerState 20)

action_21 _ = happyReduce_3

action_22 (17) = happyShift action_15
action_22 (22) = happyShift action_17
action_22 (23) = happyShift action_18
action_22 (24) = happyShift action_19
action_22 (28) = happyShift action_22
action_22 (37) = happyShift action_24
action_22 (38) = happyShift action_25
action_22 (40) = happyShift action_27
action_22 (41) = happyShift action_28
action_22 (14) = happyGoto action_36
action_22 (15) = happyGoto action_13
action_22 (16) = happyGoto action_14
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (17) = happyShift action_35
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (17) = happyShift action_15
action_24 (22) = happyShift action_17
action_24 (23) = happyShift action_18
action_24 (24) = happyShift action_19
action_24 (28) = happyShift action_22
action_24 (37) = happyShift action_24
action_24 (38) = happyShift action_25
action_24 (40) = happyShift action_27
action_24 (41) = happyShift action_28
action_24 (14) = happyGoto action_34
action_24 (15) = happyGoto action_13
action_24 (16) = happyGoto action_14
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (17) = happyShift action_15
action_25 (22) = happyShift action_17
action_25 (23) = happyShift action_18
action_25 (24) = happyShift action_19
action_25 (28) = happyShift action_22
action_25 (37) = happyShift action_24
action_25 (38) = happyShift action_25
action_25 (40) = happyShift action_27
action_25 (41) = happyShift action_28
action_25 (14) = happyGoto action_33
action_25 (15) = happyGoto action_13
action_25 (16) = happyGoto action_14
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (17) = happyShift action_32
action_26 _ = happyFail (happyExpListPerState 26)

action_27 _ = happyReduce_27

action_28 _ = happyReduce_28

action_29 _ = happyReduce_4

action_30 (17) = happyShift action_31
action_30 _ = happyFail (happyExpListPerState 30)

action_31 (17) = happyShift action_15
action_31 (22) = happyShift action_17
action_31 (23) = happyShift action_18
action_31 (24) = happyShift action_19
action_31 (28) = happyShift action_22
action_31 (37) = happyShift action_24
action_31 (38) = happyShift action_25
action_31 (40) = happyShift action_27
action_31 (41) = happyShift action_28
action_31 (14) = happyGoto action_91
action_31 (15) = happyGoto action_13
action_31 (16) = happyGoto action_14
action_31 _ = happyFail (happyExpListPerState 31)

action_32 (17) = happyShift action_15
action_32 (22) = happyShift action_17
action_32 (23) = happyShift action_18
action_32 (24) = happyShift action_19
action_32 (27) = happyShift action_21
action_32 (28) = happyShift action_22
action_32 (37) = happyShift action_24
action_32 (38) = happyShift action_25
action_32 (40) = happyShift action_27
action_32 (41) = happyShift action_28
action_32 (42) = happyShift action_29
action_32 (6) = happyGoto action_6
action_32 (7) = happyGoto action_7
action_32 (10) = happyGoto action_89
action_32 (11) = happyGoto action_90
action_32 (14) = happyGoto action_12
action_32 (15) = happyGoto action_13
action_32 (16) = happyGoto action_14
action_32 _ = happyReduce_17

action_33 _ = happyReduce_50

action_34 _ = happyReduce_49

action_35 (17) = happyShift action_15
action_35 (22) = happyShift action_17
action_35 (23) = happyShift action_18
action_35 (24) = happyShift action_19
action_35 (28) = happyShift action_22
action_35 (37) = happyShift action_24
action_35 (38) = happyShift action_25
action_35 (40) = happyShift action_27
action_35 (41) = happyShift action_28
action_35 (14) = happyGoto action_88
action_35 (15) = happyGoto action_13
action_35 (16) = happyGoto action_14
action_35 _ = happyFail (happyExpListPerState 35)

action_36 _ = happyReduce_51

action_37 (21) = happyShift action_87
action_37 (28) = happyShift action_40
action_37 (29) = happyShift action_41
action_37 (30) = happyShift action_42
action_37 (31) = happyShift action_43
action_37 (32) = happyShift action_44
action_37 (36) = happyShift action_46
action_37 (45) = happyShift action_47
action_37 (47) = happyShift action_48
action_37 (48) = happyShift action_49
action_37 (49) = happyShift action_50
action_37 (50) = happyShift action_51
action_37 (51) = happyShift action_52
action_37 (52) = happyShift action_53
action_37 (53) = happyShift action_54
action_37 (55) = happyShift action_55
action_37 (56) = happyShift action_56
action_37 (57) = happyShift action_57
action_37 (58) = happyShift action_58
action_37 _ = happyFail (happyExpListPerState 37)

action_38 (20) = happyShift action_86
action_38 _ = happyFail (happyExpListPerState 38)

action_39 (18) = happyShift action_85
action_39 (28) = happyShift action_40
action_39 (29) = happyShift action_41
action_39 (30) = happyShift action_42
action_39 (31) = happyShift action_43
action_39 (32) = happyShift action_44
action_39 (36) = happyShift action_46
action_39 (45) = happyShift action_47
action_39 (47) = happyShift action_48
action_39 (48) = happyShift action_49
action_39 (49) = happyShift action_50
action_39 (50) = happyShift action_51
action_39 (51) = happyShift action_52
action_39 (52) = happyShift action_53
action_39 (53) = happyShift action_54
action_39 (55) = happyShift action_55
action_39 (56) = happyShift action_56
action_39 (57) = happyShift action_57
action_39 (58) = happyShift action_58
action_39 _ = happyFail (happyExpListPerState 39)

action_40 (17) = happyShift action_15
action_40 (22) = happyShift action_17
action_40 (23) = happyShift action_18
action_40 (24) = happyShift action_19
action_40 (28) = happyShift action_22
action_40 (37) = happyShift action_24
action_40 (38) = happyShift action_25
action_40 (40) = happyShift action_27
action_40 (41) = happyShift action_28
action_40 (14) = happyGoto action_84
action_40 (15) = happyGoto action_13
action_40 (16) = happyGoto action_14
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (17) = happyShift action_15
action_41 (22) = happyShift action_17
action_41 (23) = happyShift action_18
action_41 (24) = happyShift action_19
action_41 (28) = happyShift action_22
action_41 (37) = happyShift action_24
action_41 (38) = happyShift action_25
action_41 (40) = happyShift action_27
action_41 (41) = happyShift action_28
action_41 (14) = happyGoto action_83
action_41 (15) = happyGoto action_13
action_41 (16) = happyGoto action_14
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (17) = happyShift action_15
action_42 (22) = happyShift action_17
action_42 (23) = happyShift action_18
action_42 (24) = happyShift action_19
action_42 (28) = happyShift action_22
action_42 (37) = happyShift action_24
action_42 (38) = happyShift action_25
action_42 (40) = happyShift action_27
action_42 (41) = happyShift action_28
action_42 (14) = happyGoto action_82
action_42 (15) = happyGoto action_13
action_42 (16) = happyGoto action_14
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (17) = happyShift action_15
action_43 (22) = happyShift action_17
action_43 (23) = happyShift action_18
action_43 (24) = happyShift action_19
action_43 (28) = happyShift action_22
action_43 (37) = happyShift action_24
action_43 (38) = happyShift action_25
action_43 (40) = happyShift action_27
action_43 (41) = happyShift action_28
action_43 (14) = happyGoto action_81
action_43 (15) = happyGoto action_13
action_43 (16) = happyGoto action_14
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (17) = happyShift action_15
action_44 (22) = happyShift action_17
action_44 (23) = happyShift action_18
action_44 (24) = happyShift action_19
action_44 (28) = happyShift action_22
action_44 (37) = happyShift action_24
action_44 (38) = happyShift action_25
action_44 (40) = happyShift action_27
action_44 (41) = happyShift action_28
action_44 (14) = happyGoto action_80
action_44 (15) = happyGoto action_13
action_44 (16) = happyGoto action_14
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (17) = happyShift action_15
action_45 (22) = happyShift action_17
action_45 (23) = happyShift action_18
action_45 (24) = happyShift action_19
action_45 (28) = happyShift action_22
action_45 (37) = happyShift action_24
action_45 (38) = happyShift action_25
action_45 (40) = happyShift action_27
action_45 (41) = happyShift action_28
action_45 (14) = happyGoto action_79
action_45 (15) = happyGoto action_13
action_45 (16) = happyGoto action_14
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (17) = happyShift action_15
action_46 (22) = happyShift action_17
action_46 (23) = happyShift action_18
action_46 (24) = happyShift action_19
action_46 (28) = happyShift action_22
action_46 (37) = happyShift action_24
action_46 (38) = happyShift action_25
action_46 (40) = happyShift action_27
action_46 (41) = happyShift action_28
action_46 (14) = happyGoto action_78
action_46 (15) = happyGoto action_13
action_46 (16) = happyGoto action_14
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (17) = happyShift action_15
action_47 (22) = happyShift action_17
action_47 (23) = happyShift action_18
action_47 (24) = happyShift action_19
action_47 (28) = happyShift action_22
action_47 (37) = happyShift action_24
action_47 (38) = happyShift action_25
action_47 (40) = happyShift action_27
action_47 (41) = happyShift action_28
action_47 (14) = happyGoto action_77
action_47 (15) = happyGoto action_13
action_47 (16) = happyGoto action_14
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (17) = happyShift action_15
action_48 (22) = happyShift action_17
action_48 (23) = happyShift action_18
action_48 (24) = happyShift action_19
action_48 (28) = happyShift action_22
action_48 (37) = happyShift action_24
action_48 (38) = happyShift action_25
action_48 (40) = happyShift action_27
action_48 (41) = happyShift action_28
action_48 (14) = happyGoto action_76
action_48 (15) = happyGoto action_13
action_48 (16) = happyGoto action_14
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (17) = happyShift action_15
action_49 (22) = happyShift action_17
action_49 (23) = happyShift action_18
action_49 (24) = happyShift action_19
action_49 (28) = happyShift action_22
action_49 (37) = happyShift action_24
action_49 (38) = happyShift action_25
action_49 (40) = happyShift action_27
action_49 (41) = happyShift action_28
action_49 (14) = happyGoto action_75
action_49 (15) = happyGoto action_13
action_49 (16) = happyGoto action_14
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (17) = happyShift action_15
action_50 (22) = happyShift action_17
action_50 (23) = happyShift action_18
action_50 (24) = happyShift action_19
action_50 (28) = happyShift action_22
action_50 (37) = happyShift action_24
action_50 (38) = happyShift action_25
action_50 (40) = happyShift action_27
action_50 (41) = happyShift action_28
action_50 (14) = happyGoto action_74
action_50 (15) = happyGoto action_13
action_50 (16) = happyGoto action_14
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (17) = happyShift action_15
action_51 (22) = happyShift action_17
action_51 (23) = happyShift action_18
action_51 (24) = happyShift action_19
action_51 (28) = happyShift action_22
action_51 (37) = happyShift action_24
action_51 (38) = happyShift action_25
action_51 (40) = happyShift action_27
action_51 (41) = happyShift action_28
action_51 (14) = happyGoto action_73
action_51 (15) = happyGoto action_13
action_51 (16) = happyGoto action_14
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (17) = happyShift action_15
action_52 (22) = happyShift action_17
action_52 (23) = happyShift action_18
action_52 (24) = happyShift action_19
action_52 (28) = happyShift action_22
action_52 (37) = happyShift action_24
action_52 (38) = happyShift action_25
action_52 (40) = happyShift action_27
action_52 (41) = happyShift action_28
action_52 (14) = happyGoto action_72
action_52 (15) = happyGoto action_13
action_52 (16) = happyGoto action_14
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (17) = happyShift action_15
action_53 (22) = happyShift action_17
action_53 (23) = happyShift action_18
action_53 (24) = happyShift action_19
action_53 (28) = happyShift action_22
action_53 (37) = happyShift action_24
action_53 (38) = happyShift action_25
action_53 (40) = happyShift action_27
action_53 (41) = happyShift action_28
action_53 (14) = happyGoto action_71
action_53 (15) = happyGoto action_13
action_53 (16) = happyGoto action_14
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (17) = happyShift action_15
action_54 (22) = happyShift action_17
action_54 (23) = happyShift action_18
action_54 (24) = happyShift action_19
action_54 (28) = happyShift action_22
action_54 (37) = happyShift action_24
action_54 (38) = happyShift action_25
action_54 (40) = happyShift action_27
action_54 (41) = happyShift action_28
action_54 (14) = happyGoto action_70
action_54 (15) = happyGoto action_13
action_54 (16) = happyGoto action_14
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (17) = happyShift action_15
action_55 (22) = happyShift action_17
action_55 (23) = happyShift action_18
action_55 (24) = happyShift action_19
action_55 (28) = happyShift action_22
action_55 (37) = happyShift action_24
action_55 (38) = happyShift action_25
action_55 (40) = happyShift action_27
action_55 (41) = happyShift action_28
action_55 (14) = happyGoto action_69
action_55 (15) = happyGoto action_13
action_55 (16) = happyGoto action_14
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (17) = happyShift action_15
action_56 (22) = happyShift action_17
action_56 (23) = happyShift action_18
action_56 (24) = happyShift action_19
action_56 (28) = happyShift action_22
action_56 (37) = happyShift action_24
action_56 (38) = happyShift action_25
action_56 (40) = happyShift action_27
action_56 (41) = happyShift action_28
action_56 (14) = happyGoto action_68
action_56 (15) = happyGoto action_13
action_56 (16) = happyGoto action_14
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (17) = happyShift action_15
action_57 (22) = happyShift action_17
action_57 (23) = happyShift action_18
action_57 (24) = happyShift action_19
action_57 (28) = happyShift action_22
action_57 (37) = happyShift action_24
action_57 (38) = happyShift action_25
action_57 (40) = happyShift action_27
action_57 (41) = happyShift action_28
action_57 (14) = happyGoto action_67
action_57 (15) = happyGoto action_13
action_57 (16) = happyGoto action_14
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (17) = happyShift action_15
action_58 (22) = happyShift action_17
action_58 (23) = happyShift action_18
action_58 (24) = happyShift action_19
action_58 (28) = happyShift action_22
action_58 (37) = happyShift action_24
action_58 (38) = happyShift action_25
action_58 (40) = happyShift action_27
action_58 (41) = happyShift action_28
action_58 (14) = happyGoto action_66
action_58 (15) = happyGoto action_13
action_58 (16) = happyGoto action_14
action_58 _ = happyFail (happyExpListPerState 58)

action_59 _ = happyReduce_13

action_60 _ = happyReduce_14

action_61 _ = happyReduce_10

action_62 _ = happyReduce_8

action_63 _ = happyReduce_2

action_64 (33) = happyShift action_65
action_64 _ = happyReduce_6

action_65 (17) = happyShift action_15
action_65 (22) = happyShift action_17
action_65 (23) = happyShift action_18
action_65 (24) = happyShift action_19
action_65 (28) = happyShift action_22
action_65 (37) = happyShift action_24
action_65 (38) = happyShift action_25
action_65 (40) = happyShift action_27
action_65 (41) = happyShift action_28
action_65 (14) = happyGoto action_96
action_65 (15) = happyGoto action_13
action_65 (16) = happyGoto action_14
action_65 _ = happyFail (happyExpListPerState 65)

action_66 (28) = happyShift action_40
action_66 (29) = happyShift action_41
action_66 (30) = happyShift action_42
action_66 (31) = happyShift action_43
action_66 (32) = happyShift action_44
action_66 _ = happyReduce_38

action_67 (28) = happyShift action_40
action_67 (29) = happyShift action_41
action_67 (30) = happyShift action_42
action_67 (31) = happyShift action_43
action_67 (32) = happyShift action_44
action_67 _ = happyReduce_37

action_68 (28) = happyShift action_40
action_68 (29) = happyShift action_41
action_68 (30) = happyShift action_42
action_68 (31) = happyShift action_43
action_68 (32) = happyShift action_44
action_68 (36) = happyShift action_46
action_68 (47) = happyShift action_48
action_68 (48) = happyShift action_49
action_68 (49) = happyShift action_50
action_68 (50) = happyShift action_51
action_68 (51) = happyShift action_52
action_68 (52) = happyShift action_53
action_68 (55) = happyShift action_55
action_68 (57) = happyShift action_57
action_68 (58) = happyShift action_58
action_68 _ = happyReduce_40

action_69 (28) = happyShift action_40
action_69 (29) = happyShift action_41
action_69 (30) = happyShift action_42
action_69 (31) = happyShift action_43
action_69 (32) = happyShift action_44
action_69 (47) = happyShift action_48
action_69 (48) = happyShift action_49
action_69 (49) = happyShift action_50
action_69 (50) = happyShift action_51
action_69 (51) = happyShift action_52
action_69 (52) = happyShift action_53
action_69 (57) = happyShift action_57
action_69 (58) = happyShift action_58
action_69 _ = happyReduce_39

action_70 (28) = happyShift action_40
action_70 (29) = happyShift action_41
action_70 (30) = happyShift action_42
action_70 (31) = happyShift action_43
action_70 (32) = happyShift action_44
action_70 (36) = happyShift action_46
action_70 (47) = happyShift action_48
action_70 (48) = happyShift action_49
action_70 (49) = happyShift action_50
action_70 (50) = happyShift action_51
action_70 (51) = happyShift action_52
action_70 (52) = happyShift action_53
action_70 (55) = happyShift action_55
action_70 (56) = happyShift action_56
action_70 (57) = happyShift action_57
action_70 (58) = happyShift action_58
action_70 _ = happyReduce_42

action_71 (28) = happyShift action_40
action_71 (29) = happyShift action_41
action_71 (30) = happyShift action_42
action_71 (31) = happyShift action_43
action_71 (32) = happyShift action_44
action_71 (47) = happyShift action_48
action_71 (48) = happyShift action_49
action_71 (49) = happyShift action_50
action_71 (50) = happyShift action_51
action_71 (57) = happyShift action_57
action_71 (58) = happyShift action_58
action_71 _ = happyReduce_48

action_72 (28) = happyShift action_40
action_72 (29) = happyShift action_41
action_72 (30) = happyShift action_42
action_72 (31) = happyShift action_43
action_72 (32) = happyShift action_44
action_72 (47) = happyShift action_48
action_72 (48) = happyShift action_49
action_72 (49) = happyShift action_50
action_72 (50) = happyShift action_51
action_72 (57) = happyShift action_57
action_72 (58) = happyShift action_58
action_72 _ = happyReduce_47

action_73 (28) = happyShift action_40
action_73 (29) = happyShift action_41
action_73 (30) = happyShift action_42
action_73 (31) = happyShift action_43
action_73 (32) = happyShift action_44
action_73 (57) = happyShift action_57
action_73 (58) = happyShift action_58
action_73 _ = happyReduce_44

action_74 (28) = happyShift action_40
action_74 (29) = happyShift action_41
action_74 (30) = happyShift action_42
action_74 (31) = happyShift action_43
action_74 (32) = happyShift action_44
action_74 (57) = happyShift action_57
action_74 (58) = happyShift action_58
action_74 _ = happyReduce_46

action_75 (28) = happyShift action_40
action_75 (29) = happyShift action_41
action_75 (30) = happyShift action_42
action_75 (31) = happyShift action_43
action_75 (32) = happyShift action_44
action_75 (57) = happyShift action_57
action_75 (58) = happyShift action_58
action_75 _ = happyReduce_45

action_76 (28) = happyShift action_40
action_76 (29) = happyShift action_41
action_76 (30) = happyShift action_42
action_76 (31) = happyShift action_43
action_76 (32) = happyShift action_44
action_76 (57) = happyShift action_57
action_76 (58) = happyShift action_58
action_76 _ = happyReduce_43

action_77 (28) = happyShift action_40
action_77 (29) = happyShift action_41
action_77 (30) = happyShift action_42
action_77 (31) = happyShift action_43
action_77 (32) = happyShift action_44
action_77 (36) = happyShift action_46
action_77 (45) = happyShift action_47
action_77 (46) = happyShift action_95
action_77 (47) = happyShift action_48
action_77 (48) = happyShift action_49
action_77 (49) = happyShift action_50
action_77 (50) = happyShift action_51
action_77 (51) = happyShift action_52
action_77 (52) = happyShift action_53
action_77 (53) = happyShift action_54
action_77 (55) = happyShift action_55
action_77 (56) = happyShift action_56
action_77 (57) = happyShift action_57
action_77 (58) = happyShift action_58
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (28) = happyShift action_40
action_78 (29) = happyShift action_41
action_78 (30) = happyShift action_42
action_78 (31) = happyShift action_43
action_78 (32) = happyShift action_44
action_78 (47) = happyShift action_48
action_78 (48) = happyShift action_49
action_78 (49) = happyShift action_50
action_78 (50) = happyShift action_51
action_78 (51) = happyShift action_52
action_78 (52) = happyShift action_53
action_78 (55) = happyShift action_55
action_78 (57) = happyShift action_57
action_78 (58) = happyShift action_58
action_78 _ = happyReduce_41

action_79 (28) = happyShift action_40
action_79 (29) = happyShift action_41
action_79 (30) = happyShift action_42
action_79 (31) = happyShift action_43
action_79 (32) = happyShift action_44
action_79 (36) = happyShift action_46
action_79 (45) = happyShift action_47
action_79 (47) = happyShift action_48
action_79 (48) = happyShift action_49
action_79 (49) = happyShift action_50
action_79 (50) = happyShift action_51
action_79 (51) = happyShift action_52
action_79 (52) = happyShift action_53
action_79 (53) = happyShift action_54
action_79 (55) = happyShift action_55
action_79 (56) = happyShift action_56
action_79 (57) = happyShift action_57
action_79 (58) = happyShift action_58
action_79 _ = happyReduce_12

action_80 _ = happyReduce_36

action_81 _ = happyReduce_35

action_82 _ = happyReduce_34

action_83 (30) = happyShift action_42
action_83 (31) = happyShift action_43
action_83 (32) = happyShift action_44
action_83 _ = happyReduce_33

action_84 (30) = happyShift action_42
action_84 (31) = happyShift action_43
action_84 (32) = happyShift action_44
action_84 _ = happyReduce_32

action_85 _ = happyReduce_25

action_86 _ = happyReduce_11

action_87 _ = happyReduce_24

action_88 (18) = happyShift action_94
action_88 (28) = happyShift action_40
action_88 (29) = happyShift action_41
action_88 (30) = happyShift action_42
action_88 (31) = happyShift action_43
action_88 (32) = happyShift action_44
action_88 (36) = happyShift action_46
action_88 (45) = happyShift action_47
action_88 (47) = happyShift action_48
action_88 (48) = happyShift action_49
action_88 (49) = happyShift action_50
action_88 (50) = happyShift action_51
action_88 (51) = happyShift action_52
action_88 (52) = happyShift action_53
action_88 (53) = happyShift action_54
action_88 (55) = happyShift action_55
action_88 (56) = happyShift action_56
action_88 (57) = happyShift action_57
action_88 (58) = happyShift action_58
action_88 _ = happyFail (happyExpListPerState 88)

action_89 _ = happyReduce_18

action_90 (21) = happyShift action_93
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (18) = happyShift action_92
action_91 (28) = happyShift action_40
action_91 (29) = happyShift action_41
action_91 (30) = happyShift action_42
action_91 (31) = happyShift action_43
action_91 (32) = happyShift action_44
action_91 (36) = happyShift action_46
action_91 (45) = happyShift action_47
action_91 (47) = happyShift action_48
action_91 (48) = happyShift action_49
action_91 (49) = happyShift action_50
action_91 (50) = happyShift action_51
action_91 (51) = happyShift action_52
action_91 (52) = happyShift action_53
action_91 (53) = happyShift action_54
action_91 (55) = happyShift action_55
action_91 (56) = happyShift action_56
action_91 (57) = happyShift action_57
action_91 (58) = happyShift action_58
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (17) = happyShift action_15
action_92 (19) = happyShift action_16
action_92 (22) = happyShift action_17
action_92 (23) = happyShift action_18
action_92 (24) = happyShift action_19
action_92 (26) = happyShift action_20
action_92 (27) = happyShift action_21
action_92 (28) = happyShift action_22
action_92 (35) = happyShift action_23
action_92 (37) = happyShift action_24
action_92 (38) = happyShift action_25
action_92 (39) = happyShift action_26
action_92 (40) = happyShift action_27
action_92 (41) = happyShift action_28
action_92 (42) = happyShift action_29
action_92 (43) = happyShift action_30
action_92 (6) = happyGoto action_6
action_92 (7) = happyGoto action_7
action_92 (9) = happyGoto action_100
action_92 (10) = happyGoto action_10
action_92 (13) = happyGoto action_11
action_92 (14) = happyGoto action_12
action_92 (15) = happyGoto action_13
action_92 (16) = happyGoto action_14
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (17) = happyShift action_15
action_93 (22) = happyShift action_17
action_93 (23) = happyShift action_18
action_93 (24) = happyShift action_19
action_93 (28) = happyShift action_22
action_93 (37) = happyShift action_24
action_93 (38) = happyShift action_25
action_93 (40) = happyShift action_27
action_93 (41) = happyShift action_28
action_93 (14) = happyGoto action_99
action_93 (15) = happyGoto action_13
action_93 (16) = happyGoto action_14
action_93 _ = happyFail (happyExpListPerState 93)

action_94 (17) = happyShift action_15
action_94 (19) = happyShift action_16
action_94 (22) = happyShift action_17
action_94 (23) = happyShift action_18
action_94 (24) = happyShift action_19
action_94 (26) = happyShift action_20
action_94 (27) = happyShift action_21
action_94 (28) = happyShift action_22
action_94 (35) = happyShift action_23
action_94 (37) = happyShift action_24
action_94 (38) = happyShift action_25
action_94 (39) = happyShift action_26
action_94 (40) = happyShift action_27
action_94 (41) = happyShift action_28
action_94 (42) = happyShift action_29
action_94 (43) = happyShift action_30
action_94 (6) = happyGoto action_6
action_94 (7) = happyGoto action_7
action_94 (9) = happyGoto action_98
action_94 (10) = happyGoto action_10
action_94 (13) = happyGoto action_11
action_94 (14) = happyGoto action_12
action_94 (15) = happyGoto action_13
action_94 (16) = happyGoto action_14
action_94 _ = happyFail (happyExpListPerState 94)

action_95 (17) = happyShift action_15
action_95 (22) = happyShift action_17
action_95 (23) = happyShift action_18
action_95 (24) = happyShift action_19
action_95 (28) = happyShift action_22
action_95 (37) = happyShift action_24
action_95 (38) = happyShift action_25
action_95 (40) = happyShift action_27
action_95 (41) = happyShift action_28
action_95 (14) = happyGoto action_97
action_95 (15) = happyGoto action_13
action_95 (16) = happyGoto action_14
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (28) = happyShift action_40
action_96 (29) = happyShift action_41
action_96 (30) = happyShift action_42
action_96 (31) = happyShift action_43
action_96 (32) = happyShift action_44
action_96 (36) = happyShift action_46
action_96 (45) = happyShift action_47
action_96 (47) = happyShift action_48
action_96 (48) = happyShift action_49
action_96 (49) = happyShift action_50
action_96 (50) = happyShift action_51
action_96 (51) = happyShift action_52
action_96 (52) = happyShift action_53
action_96 (53) = happyShift action_54
action_96 (55) = happyShift action_55
action_96 (56) = happyShift action_56
action_96 (57) = happyShift action_57
action_96 (58) = happyShift action_58
action_96 _ = happyReduce_5

action_97 (28) = happyShift action_40
action_97 (29) = happyShift action_41
action_97 (30) = happyShift action_42
action_97 (31) = happyShift action_43
action_97 (32) = happyShift action_44
action_97 (36) = happyShift action_46
action_97 (45) = happyShift action_47
action_97 (47) = happyShift action_48
action_97 (48) = happyShift action_49
action_97 (49) = happyShift action_50
action_97 (50) = happyShift action_51
action_97 (51) = happyShift action_52
action_97 (52) = happyShift action_53
action_97 (53) = happyShift action_54
action_97 (55) = happyShift action_55
action_97 (56) = happyShift action_56
action_97 (57) = happyShift action_57
action_97 (58) = happyShift action_58
action_97 _ = happyReduce_26

action_98 _ = happyReduce_22

action_99 (21) = happyShift action_103
action_99 (28) = happyShift action_40
action_99 (29) = happyShift action_41
action_99 (30) = happyShift action_42
action_99 (31) = happyShift action_43
action_99 (32) = happyShift action_44
action_99 (36) = happyShift action_46
action_99 (45) = happyShift action_47
action_99 (47) = happyShift action_48
action_99 (48) = happyShift action_49
action_99 (49) = happyShift action_50
action_99 (50) = happyShift action_51
action_99 (51) = happyShift action_52
action_99 (52) = happyShift action_53
action_99 (53) = happyShift action_54
action_99 (55) = happyShift action_55
action_99 (56) = happyShift action_56
action_99 (57) = happyShift action_57
action_99 (58) = happyShift action_58
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (44) = happyShift action_102
action_100 (12) = happyGoto action_101
action_100 _ = happyReduce_21

action_101 _ = happyReduce_20

action_102 (17) = happyShift action_15
action_102 (19) = happyShift action_16
action_102 (22) = happyShift action_17
action_102 (23) = happyShift action_18
action_102 (24) = happyShift action_19
action_102 (26) = happyShift action_20
action_102 (27) = happyShift action_21
action_102 (28) = happyShift action_22
action_102 (35) = happyShift action_23
action_102 (37) = happyShift action_24
action_102 (38) = happyShift action_25
action_102 (39) = happyShift action_26
action_102 (40) = happyShift action_27
action_102 (41) = happyShift action_28
action_102 (42) = happyShift action_29
action_102 (43) = happyShift action_30
action_102 (6) = happyGoto action_6
action_102 (7) = happyGoto action_7
action_102 (9) = happyGoto action_105
action_102 (10) = happyGoto action_10
action_102 (13) = happyGoto action_11
action_102 (14) = happyGoto action_12
action_102 (15) = happyGoto action_13
action_102 (16) = happyGoto action_14
action_102 _ = happyFail (happyExpListPerState 102)

action_103 (17) = happyShift action_15
action_103 (22) = happyShift action_17
action_103 (23) = happyShift action_18
action_103 (24) = happyShift action_19
action_103 (27) = happyShift action_21
action_103 (28) = happyShift action_22
action_103 (37) = happyShift action_24
action_103 (38) = happyShift action_25
action_103 (40) = happyShift action_27
action_103 (41) = happyShift action_28
action_103 (42) = happyShift action_29
action_103 (6) = happyGoto action_6
action_103 (7) = happyGoto action_7
action_103 (10) = happyGoto action_89
action_103 (11) = happyGoto action_104
action_103 (14) = happyGoto action_12
action_103 (15) = happyGoto action_13
action_103 (16) = happyGoto action_14
action_103 _ = happyReduce_17

action_104 (18) = happyShift action_106
action_104 _ = happyFail (happyExpListPerState 104)

action_105 _ = happyReduce_19

action_106 (17) = happyShift action_15
action_106 (19) = happyShift action_16
action_106 (22) = happyShift action_17
action_106 (23) = happyShift action_18
action_106 (24) = happyShift action_19
action_106 (26) = happyShift action_20
action_106 (27) = happyShift action_21
action_106 (28) = happyShift action_22
action_106 (35) = happyShift action_23
action_106 (37) = happyShift action_24
action_106 (38) = happyShift action_25
action_106 (39) = happyShift action_26
action_106 (40) = happyShift action_27
action_106 (41) = happyShift action_28
action_106 (42) = happyShift action_29
action_106 (43) = happyShift action_30
action_106 (6) = happyGoto action_6
action_106 (7) = happyGoto action_7
action_106 (9) = happyGoto action_107
action_106 (10) = happyGoto action_10
action_106 (13) = happyGoto action_11
action_106 (14) = happyGoto action_12
action_106 (15) = happyGoto action_13
action_106 (16) = happyGoto action_14
action_106 _ = happyFail (happyExpListPerState 106)

action_107 _ = happyReduce_23

happyReduce_1 = happySpecReduce_2  4 happyReduction_1
happyReduction_1 (HappyAbsSyn5  happy_var_2)
	_
	 =  HappyAbsSyn4
		 (Block happy_var_2
	)
happyReduction_1 _ _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_3  5 happyReduction_2
happyReduction_2 _
	(HappyAbsSyn8  happy_var_2)
	_
	 =  HappyAbsSyn5
		 (happy_var_2
	)
happyReduction_2 _ _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1  6 happyReduction_3
happyReduction_3 _
	 =  HappyAbsSyn6
		 (INTEGER
	)

happyReduce_4 = happySpecReduce_1  6 happyReduction_4
happyReduction_4 _
	 =  HappyAbsSyn6
		 (BOOLEAN
	)

happyReduce_5 = happyReduce 4 7 happyReduction_5
happyReduction_5 ((HappyAbsSyn14  happy_var_4) `HappyStk`
	(HappyTerminal (TokAsgnop happy_var_3)) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn6  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (checkDeclAsgn happy_var_2 happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_6 = happySpecReduce_2  7 happyReduction_6
happyReduction_6 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn7
		 (JustDecl happy_var_2 happy_var_1
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_0  8 happyReduction_7
happyReduction_7  =  HappyAbsSyn8
		 ([]
	)

happyReduce_8 = happySpecReduce_2  8 happyReduction_8
happyReduction_8 (HappyAbsSyn8  happy_var_2)
	(HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 (happy_var_1 : happy_var_2
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_1  9 happyReduction_9
happyReduction_9 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn9
		 (ControlStmt happy_var_1
	)
happyReduction_9 _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_2  9 happyReduction_10
happyReduction_10 _
	(HappyAbsSyn10  happy_var_1)
	 =  HappyAbsSyn9
		 (Simp happy_var_1
	)
happyReduction_10 _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_3  9 happyReduction_11
happyReduction_11 _
	(HappyAbsSyn8  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Stmts happy_var_2
	)
happyReduction_11 _ _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_3  10 happyReduction_12
happyReduction_12 (HappyAbsSyn14  happy_var_3)
	(HappyTerminal (TokAsgnop happy_var_2))
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn10
		 (checkSimpAsgn happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_12 _ _ _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_2  10 happyReduction_13
happyReduction_13 _
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn10
		 (checkSimpAsgnP happy_var_1 Incr
	)
happyReduction_13 _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_2  10 happyReduction_14
happyReduction_14 _
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn10
		 (checkSimpAsgnP happy_var_1 Decr
	)
happyReduction_14 _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_1  10 happyReduction_15
happyReduction_15 (HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn10
		 (Decl happy_var_1
	)
happyReduction_15 _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_1  10 happyReduction_16
happyReduction_16 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn10
		 (Exp happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_0  11 happyReduction_17
happyReduction_17  =  HappyAbsSyn11
		 (SimpNop
	)

happyReduce_18 = happySpecReduce_1  11 happyReduction_18
happyReduction_18 (HappyAbsSyn10  happy_var_1)
	 =  HappyAbsSyn11
		 (Opt happy_var_1
	)
happyReduction_18 _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_2  12 happyReduction_19
happyReduction_19 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn12
		 (Else happy_var_2
	)
happyReduction_19 _ _  = notHappyAtAll 

happyReduce_20 = happyReduce 6 13 happyReduction_20
happyReduction_20 ((HappyAbsSyn12  happy_var_6) `HappyStk`
	(HappyAbsSyn9  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (Condition happy_var_3 happy_var_5 happy_var_6
	) `HappyStk` happyRest

happyReduce_21 = happyReduce 5 13 happyReduction_21
happyReduction_21 ((HappyAbsSyn9  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (Condition happy_var_3 happy_var_5 (ElseNop)
	) `HappyStk` happyRest

happyReduce_22 = happyReduce 5 13 happyReduction_22
happyReduction_22 ((HappyAbsSyn9  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (While happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_23 = happyReduce 9 13 happyReduction_23
happyReduction_23 ((HappyAbsSyn9  happy_var_9) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn11  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn11  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (For happy_var_3 happy_var_5 happy_var_7 happy_var_9
	) `HappyStk` happyRest

happyReduce_24 = happySpecReduce_3  13 happyReduction_24
happyReduction_24 _
	(HappyAbsSyn14  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (Retn happy_var_2
	)
happyReduction_24 _ _ _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  14 happyReduction_25
happyReduction_25 _
	(HappyAbsSyn14  happy_var_2)
	_
	 =  HappyAbsSyn14
		 (happy_var_2
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happyReduce 5 14 happyReduction_26
happyReduction_26 ((HappyAbsSyn14  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (Ternop happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_27 = happySpecReduce_1  14 happyReduction_27
happyReduction_27 _
	 =  HappyAbsSyn14
		 (T
	)

happyReduce_28 = happySpecReduce_1  14 happyReduction_28
happyReduction_28 _
	 =  HappyAbsSyn14
		 (F
	)

happyReduce_29 = happySpecReduce_1  14 happyReduction_29
happyReduction_29 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1
	)
happyReduction_29 _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_1  14 happyReduction_30
happyReduction_30 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn14
		 (Ident happy_var_1
	)
happyReduction_30 _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_1  14 happyReduction_31
happyReduction_31 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1
	)
happyReduction_31 _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_3  15 happyReduction_32
happyReduction_32 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Sub happy_var_1 happy_var_3
	)
happyReduction_32 _ _ _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_3  15 happyReduction_33
happyReduction_33 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Add happy_var_1 happy_var_3
	)
happyReduction_33 _ _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_3  15 happyReduction_34
happyReduction_34 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Mul happy_var_1 happy_var_3
	)
happyReduction_34 _ _ _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_3  15 happyReduction_35
happyReduction_35 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Div happy_var_1 happy_var_3
	)
happyReduction_35 _ _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_3  15 happyReduction_36
happyReduction_36 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Mod happy_var_1 happy_var_3
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  15 happyReduction_37
happyReduction_37 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Sal happy_var_1 happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_3  15 happyReduction_38
happyReduction_38 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Sar happy_var_1 happy_var_3
	)
happyReduction_38 _ _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_3  15 happyReduction_39
happyReduction_39 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop BAnd happy_var_1 happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_3  15 happyReduction_40
happyReduction_40 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop LOr happy_var_1 happy_var_3
	)
happyReduction_40 _ _ _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_3  15 happyReduction_41
happyReduction_41 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Xor happy_var_1 happy_var_3
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_3  15 happyReduction_42
happyReduction_42 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop LAnd happy_var_1 happy_var_3
	)
happyReduction_42 _ _ _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_3  15 happyReduction_43
happyReduction_43 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Lt happy_var_1 happy_var_3
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_3  15 happyReduction_44
happyReduction_44 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Le happy_var_1 happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  15 happyReduction_45
happyReduction_45 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Gt happy_var_1 happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_3  15 happyReduction_46
happyReduction_46 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Ge happy_var_1 happy_var_3
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_3  15 happyReduction_47
happyReduction_47 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Eql happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_3  15 happyReduction_48
happyReduction_48 (HappyAbsSyn14  happy_var_3)
	_
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (Binop Neq happy_var_1 happy_var_3
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_2  15 happyReduction_49
happyReduction_49 (HappyAbsSyn14  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (Unop LNot happy_var_2
	)
happyReduction_49 _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_2  15 happyReduction_50
happyReduction_50 (HappyAbsSyn14  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (Unop BNot happy_var_2
	)
happyReduction_50 _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_2  15 happyReduction_51
happyReduction_51 (HappyAbsSyn14  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (Unop Neg happy_var_2
	)
happyReduction_51 _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_1  16 happyReduction_52
happyReduction_52 (HappyTerminal (TokDec happy_var_1))
	 =  HappyAbsSyn16
		 (checkDec happy_var_1
	)
happyReduction_52 _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_1  16 happyReduction_53
happyReduction_53 (HappyTerminal (TokHex happy_var_1))
	 =  HappyAbsSyn16
		 (checkHex happy_var_1
	)
happyReduction_53 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 61 61 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TokLParen -> cont 17;
	TokRParen -> cont 18;
	TokLBrace -> cont 19;
	TokRBrace -> cont 20;
	TokSemi -> cont 21;
	TokDec happy_dollar_dollar -> cont 22;
	TokHex happy_dollar_dollar -> cont 23;
	TokIdent happy_dollar_dollar -> cont 24;
	TokMain -> cont 25;
	TokReturn -> cont 26;
	TokInt -> cont 27;
	TokMinus -> cont 28;
	TokPlus -> cont 29;
	TokTimes -> cont 30;
	TokDiv -> cont 31;
	TokMod -> cont 32;
	TokAsgnop happy_dollar_dollar -> cont 33;
	TokReserved -> cont 34;
	TokWhile -> cont 35;
	TokXor -> cont 36;
	TokUnop LNot -> cont 37;
	TokUnop BNot -> cont 38;
	TokFor -> cont 39;
	TokTrue -> cont 40;
	TokFalse -> cont 41;
	TokBool -> cont 42;
	TokIf -> cont 43;
	TokElse -> cont 44;
	TokIf -> cont 45;
	TokElse -> cont 46;
	TokLess -> cont 47;
	TokGreater -> cont 48;
	TokGeq -> cont 49;
	TokLeq -> cont 50;
	TokBoolEq -> cont 51;
	TokNotEq -> cont 52;
	TokBoolAnd -> cont 53;
	TokBoolOr -> cont 54;
	TokAnd -> cont 55;
	TokOr -> cont 56;
	TokLshift -> cont 57;
	TokRshift -> cont 58;
	TokIncr -> cont 59;
	TokDecr -> cont 60;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 61 tk tks = happyError' (tks, explist)
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

checkSimpAsgn :: Exp -> Asnop -> Exp -> Simp
checkSimpAsgn id op e =
    case id of
        Ident a -> Asgn a op e
        _ -> error "Invalid assignment to non variables"

checkSimpAsgnP :: Exp -> Postop -> Simp
checkSimpAsgnP id op =
    case id of  
        Ident a -> AsgnP a op
        _ -> error "Invalid postop assignment to non variables"

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

