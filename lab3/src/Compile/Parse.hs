{-# OPTIONS_GHC -w #-}
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
import Debug.Trace
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.11

data HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18
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
	| HappyAbsSyn18 t18

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,462) ([0,1024,0,0,0,512,0,0,0,4,0,0,0,0,0,0,0,0,0,0,40960,33244,254,0,0,8,0,0,0,0,0,0,8192,0,0,0,51712,59421,15,0,4096,0,0,0,0,0,0,0,0,64,0,3,0,287,32762,0,0,0,0,0,0,0,0,0,9092,1728,0,0,7626,4072,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,284,54,0,0,0,0,0,2048,32839,13,0,1024,0,0,0,49664,24593,3,0,57600,45064,1,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,9092,1728,0,0,6594,1888,0,0,0,0,0,0,0,0,0,16384,568,108,0,0,0,0,0,0,1,0,0,16384,0,0,0,2048,9184,65280,15,0,0,0,0,57600,45064,1,0,28800,55300,0,0,14400,27650,0,0,7200,13825,0,0,36368,6912,0,0,18184,3456,0,0,9092,1728,0,0,4546,864,0,0,2273,432,0,32768,1136,216,0,16384,568,108,0,8192,284,54,0,4096,142,27,0,2048,32839,13,0,33792,49187,6,0,49664,24593,3,0,57600,45064,1,0,28800,55300,0,0,14400,27650,0,0,7200,13825,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,16384,568,108,0,0,0,0,0,0,3968,0,0,0,1984,0,0,0,9184,16128,13,0,496,8064,6,0,2296,57280,3,0,1148,59360,1,0,62,49392,0,0,31,24696,0,32768,15,12288,0,49152,7,6144,0,57344,3,3072,0,61440,1,1536,0,0,8192,0,0,31744,57344,423,0,0,0,0,0,0,0,0,0,0,0,0,0,1792,0,0,0,896,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,256,0,0,0,16,0,0,0,15252,8144,0,0,4546,864,0,0,3813,2036,0,32768,1136,216,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,32,0,0,0,0,0,58624,62478,7,0,28800,55302,1,0,128,0,0,0,0,0,0,0,61008,32576,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Block","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","Tern","Exps","Operation","Intconst","'('","')'","'{'","'}'","';'","dec","hex","ident","tokmain","ret","int","'-'","'+'","'*'","'/'","'%'","asgnop","kill","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 63
        bit_end = (st + 1) * 63
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..62]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (27) = happyShift action_2
action_0 (4) = happyGoto action_3
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (27) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (21) = happyShift action_5
action_2 (5) = happyGoto action_4
action_2 _ = happyFail (happyExpListPerState 2)

action_3 (63) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_1

action_5 (19) = happyShift action_16
action_5 (21) = happyShift action_17
action_5 (24) = happyShift action_18
action_5 (25) = happyShift action_19
action_5 (26) = happyShift action_20
action_5 (28) = happyShift action_21
action_5 (29) = happyShift action_22
action_5 (30) = happyShift action_23
action_5 (37) = happyShift action_24
action_5 (39) = happyShift action_25
action_5 (40) = happyShift action_26
action_5 (41) = happyShift action_27
action_5 (42) = happyShift action_28
action_5 (43) = happyShift action_29
action_5 (44) = happyShift action_30
action_5 (45) = happyShift action_31
action_5 (6) = happyGoto action_6
action_5 (7) = happyGoto action_7
action_5 (8) = happyGoto action_8
action_5 (9) = happyGoto action_9
action_5 (10) = happyGoto action_10
action_5 (13) = happyGoto action_11
action_5 (14) = happyGoto action_12
action_5 (16) = happyGoto action_13
action_5 (17) = happyGoto action_14
action_5 (18) = happyGoto action_15
action_5 _ = happyReduce_7

action_6 (26) = happyShift action_67
action_6 _ = happyFail (happyExpListPerState 6)

action_7 _ = happyReduce_15

action_8 (22) = happyShift action_66
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (19) = happyShift action_16
action_9 (21) = happyShift action_17
action_9 (24) = happyShift action_18
action_9 (25) = happyShift action_19
action_9 (26) = happyShift action_20
action_9 (28) = happyShift action_21
action_9 (29) = happyShift action_22
action_9 (30) = happyShift action_23
action_9 (37) = happyShift action_24
action_9 (39) = happyShift action_25
action_9 (40) = happyShift action_26
action_9 (41) = happyShift action_27
action_9 (42) = happyShift action_28
action_9 (43) = happyShift action_29
action_9 (44) = happyShift action_30
action_9 (45) = happyShift action_31
action_9 (6) = happyGoto action_6
action_9 (7) = happyGoto action_7
action_9 (8) = happyGoto action_65
action_9 (9) = happyGoto action_9
action_9 (10) = happyGoto action_10
action_9 (13) = happyGoto action_11
action_9 (14) = happyGoto action_12
action_9 (16) = happyGoto action_13
action_9 (17) = happyGoto action_14
action_9 (18) = happyGoto action_15
action_9 _ = happyReduce_7

action_10 (23) = happyShift action_64
action_10 _ = happyFail (happyExpListPerState 10)

action_11 _ = happyReduce_9

action_12 (35) = happyShift action_61
action_12 (61) = happyShift action_62
action_12 (62) = happyShift action_63
action_12 _ = happyReduce_16

action_13 (30) = happyShift action_42
action_13 (31) = happyShift action_43
action_13 (32) = happyShift action_44
action_13 (33) = happyShift action_45
action_13 (34) = happyShift action_46
action_13 (38) = happyShift action_47
action_13 (47) = happyShift action_48
action_13 (49) = happyShift action_49
action_13 (50) = happyShift action_50
action_13 (51) = happyShift action_51
action_13 (52) = happyShift action_52
action_13 (53) = happyShift action_53
action_13 (54) = happyShift action_54
action_13 (55) = happyShift action_55
action_13 (56) = happyShift action_56
action_13 (57) = happyShift action_57
action_13 (58) = happyShift action_58
action_13 (59) = happyShift action_59
action_13 (60) = happyShift action_60
action_13 (15) = happyGoto action_41
action_13 _ = happyReduce_27

action_14 _ = happyReduce_33

action_15 _ = happyReduce_31

action_16 (19) = happyShift action_16
action_16 (24) = happyShift action_18
action_16 (25) = happyShift action_19
action_16 (26) = happyShift action_20
action_16 (30) = happyShift action_23
action_16 (39) = happyShift action_25
action_16 (40) = happyShift action_26
action_16 (42) = happyShift action_28
action_16 (43) = happyShift action_29
action_16 (16) = happyGoto action_40
action_16 (17) = happyGoto action_14
action_16 (18) = happyGoto action_15
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (19) = happyShift action_16
action_17 (21) = happyShift action_17
action_17 (24) = happyShift action_18
action_17 (25) = happyShift action_19
action_17 (26) = happyShift action_20
action_17 (28) = happyShift action_21
action_17 (29) = happyShift action_22
action_17 (30) = happyShift action_23
action_17 (37) = happyShift action_24
action_17 (39) = happyShift action_25
action_17 (40) = happyShift action_26
action_17 (41) = happyShift action_27
action_17 (42) = happyShift action_28
action_17 (43) = happyShift action_29
action_17 (44) = happyShift action_30
action_17 (45) = happyShift action_31
action_17 (6) = happyGoto action_6
action_17 (7) = happyGoto action_7
action_17 (8) = happyGoto action_39
action_17 (9) = happyGoto action_9
action_17 (10) = happyGoto action_10
action_17 (13) = happyGoto action_11
action_17 (14) = happyGoto action_12
action_17 (16) = happyGoto action_13
action_17 (17) = happyGoto action_14
action_17 (18) = happyGoto action_15
action_17 _ = happyReduce_7

action_18 _ = happyReduce_55

action_19 _ = happyReduce_56

action_20 _ = happyReduce_32

action_21 (19) = happyShift action_16
action_21 (24) = happyShift action_18
action_21 (25) = happyShift action_19
action_21 (26) = happyShift action_20
action_21 (30) = happyShift action_23
action_21 (39) = happyShift action_25
action_21 (40) = happyShift action_26
action_21 (42) = happyShift action_28
action_21 (43) = happyShift action_29
action_21 (14) = happyGoto action_38
action_21 (16) = happyGoto action_13
action_21 (17) = happyGoto action_14
action_21 (18) = happyGoto action_15
action_21 _ = happyFail (happyExpListPerState 21)

action_22 _ = happyReduce_3

action_23 (19) = happyShift action_16
action_23 (24) = happyShift action_18
action_23 (25) = happyShift action_19
action_23 (26) = happyShift action_20
action_23 (30) = happyShift action_23
action_23 (39) = happyShift action_25
action_23 (40) = happyShift action_26
action_23 (42) = happyShift action_28
action_23 (43) = happyShift action_29
action_23 (16) = happyGoto action_37
action_23 (17) = happyGoto action_14
action_23 (18) = happyGoto action_15
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (19) = happyShift action_36
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (19) = happyShift action_16
action_25 (24) = happyShift action_18
action_25 (25) = happyShift action_19
action_25 (26) = happyShift action_20
action_25 (30) = happyShift action_23
action_25 (39) = happyShift action_25
action_25 (40) = happyShift action_26
action_25 (42) = happyShift action_28
action_25 (43) = happyShift action_29
action_25 (16) = happyGoto action_35
action_25 (17) = happyGoto action_14
action_25 (18) = happyGoto action_15
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (19) = happyShift action_16
action_26 (24) = happyShift action_18
action_26 (25) = happyShift action_19
action_26 (26) = happyShift action_20
action_26 (30) = happyShift action_23
action_26 (39) = happyShift action_25
action_26 (40) = happyShift action_26
action_26 (42) = happyShift action_28
action_26 (43) = happyShift action_29
action_26 (16) = happyGoto action_34
action_26 (17) = happyGoto action_14
action_26 (18) = happyGoto action_15
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (19) = happyShift action_33
action_27 _ = happyFail (happyExpListPerState 27)

action_28 _ = happyReduce_29

action_29 _ = happyReduce_30

action_30 _ = happyReduce_4

action_31 (19) = happyShift action_32
action_31 _ = happyFail (happyExpListPerState 31)

action_32 (19) = happyShift action_16
action_32 (24) = happyShift action_18
action_32 (25) = happyShift action_19
action_32 (26) = happyShift action_20
action_32 (30) = happyShift action_23
action_32 (39) = happyShift action_25
action_32 (40) = happyShift action_26
action_32 (42) = happyShift action_28
action_32 (43) = happyShift action_29
action_32 (14) = happyGoto action_95
action_32 (16) = happyGoto action_13
action_32 (17) = happyGoto action_14
action_32 (18) = happyGoto action_15
action_32 _ = happyFail (happyExpListPerState 32)

action_33 (19) = happyShift action_16
action_33 (24) = happyShift action_18
action_33 (25) = happyShift action_19
action_33 (26) = happyShift action_20
action_33 (29) = happyShift action_22
action_33 (30) = happyShift action_23
action_33 (39) = happyShift action_25
action_33 (40) = happyShift action_26
action_33 (42) = happyShift action_28
action_33 (43) = happyShift action_29
action_33 (44) = happyShift action_30
action_33 (6) = happyGoto action_6
action_33 (7) = happyGoto action_7
action_33 (10) = happyGoto action_93
action_33 (11) = happyGoto action_94
action_33 (14) = happyGoto action_12
action_33 (16) = happyGoto action_13
action_33 (17) = happyGoto action_14
action_33 (18) = happyGoto action_15
action_33 _ = happyReduce_17

action_34 _ = happyReduce_53

action_35 _ = happyReduce_52

action_36 (19) = happyShift action_16
action_36 (24) = happyShift action_18
action_36 (25) = happyShift action_19
action_36 (26) = happyShift action_20
action_36 (30) = happyShift action_23
action_36 (39) = happyShift action_25
action_36 (40) = happyShift action_26
action_36 (42) = happyShift action_28
action_36 (43) = happyShift action_29
action_36 (14) = happyGoto action_92
action_36 (16) = happyGoto action_13
action_36 (17) = happyGoto action_14
action_36 (18) = happyGoto action_15
action_36 _ = happyFail (happyExpListPerState 36)

action_37 _ = happyReduce_54

action_38 (23) = happyShift action_91
action_38 _ = happyFail (happyExpListPerState 38)

action_39 (22) = happyShift action_90
action_39 _ = happyFail (happyExpListPerState 39)

action_40 (20) = happyShift action_89
action_40 (30) = happyShift action_42
action_40 (31) = happyShift action_43
action_40 (32) = happyShift action_44
action_40 (33) = happyShift action_45
action_40 (34) = happyShift action_46
action_40 (38) = happyShift action_47
action_40 (49) = happyShift action_49
action_40 (50) = happyShift action_50
action_40 (51) = happyShift action_51
action_40 (52) = happyShift action_52
action_40 (53) = happyShift action_53
action_40 (54) = happyShift action_54
action_40 (55) = happyShift action_55
action_40 (56) = happyShift action_56
action_40 (57) = happyShift action_57
action_40 (58) = happyShift action_58
action_40 (59) = happyShift action_59
action_40 (60) = happyShift action_60
action_40 _ = happyFail (happyExpListPerState 40)

action_41 _ = happyReduce_25

action_42 (19) = happyShift action_16
action_42 (24) = happyShift action_18
action_42 (25) = happyShift action_19
action_42 (26) = happyShift action_20
action_42 (30) = happyShift action_23
action_42 (39) = happyShift action_25
action_42 (40) = happyShift action_26
action_42 (42) = happyShift action_28
action_42 (43) = happyShift action_29
action_42 (16) = happyGoto action_88
action_42 (17) = happyGoto action_14
action_42 (18) = happyGoto action_15
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (19) = happyShift action_16
action_43 (24) = happyShift action_18
action_43 (25) = happyShift action_19
action_43 (26) = happyShift action_20
action_43 (30) = happyShift action_23
action_43 (39) = happyShift action_25
action_43 (40) = happyShift action_26
action_43 (42) = happyShift action_28
action_43 (43) = happyShift action_29
action_43 (16) = happyGoto action_87
action_43 (17) = happyGoto action_14
action_43 (18) = happyGoto action_15
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (19) = happyShift action_16
action_44 (24) = happyShift action_18
action_44 (25) = happyShift action_19
action_44 (26) = happyShift action_20
action_44 (30) = happyShift action_23
action_44 (39) = happyShift action_25
action_44 (40) = happyShift action_26
action_44 (42) = happyShift action_28
action_44 (43) = happyShift action_29
action_44 (16) = happyGoto action_86
action_44 (17) = happyGoto action_14
action_44 (18) = happyGoto action_15
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (19) = happyShift action_16
action_45 (24) = happyShift action_18
action_45 (25) = happyShift action_19
action_45 (26) = happyShift action_20
action_45 (30) = happyShift action_23
action_45 (39) = happyShift action_25
action_45 (40) = happyShift action_26
action_45 (42) = happyShift action_28
action_45 (43) = happyShift action_29
action_45 (16) = happyGoto action_85
action_45 (17) = happyGoto action_14
action_45 (18) = happyGoto action_15
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (19) = happyShift action_16
action_46 (24) = happyShift action_18
action_46 (25) = happyShift action_19
action_46 (26) = happyShift action_20
action_46 (30) = happyShift action_23
action_46 (39) = happyShift action_25
action_46 (40) = happyShift action_26
action_46 (42) = happyShift action_28
action_46 (43) = happyShift action_29
action_46 (16) = happyGoto action_84
action_46 (17) = happyGoto action_14
action_46 (18) = happyGoto action_15
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (19) = happyShift action_16
action_47 (24) = happyShift action_18
action_47 (25) = happyShift action_19
action_47 (26) = happyShift action_20
action_47 (30) = happyShift action_23
action_47 (39) = happyShift action_25
action_47 (40) = happyShift action_26
action_47 (42) = happyShift action_28
action_47 (43) = happyShift action_29
action_47 (16) = happyGoto action_83
action_47 (17) = happyGoto action_14
action_47 (18) = happyGoto action_15
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (19) = happyShift action_16
action_48 (24) = happyShift action_18
action_48 (25) = happyShift action_19
action_48 (26) = happyShift action_20
action_48 (30) = happyShift action_23
action_48 (39) = happyShift action_25
action_48 (40) = happyShift action_26
action_48 (42) = happyShift action_28
action_48 (43) = happyShift action_29
action_48 (14) = happyGoto action_82
action_48 (16) = happyGoto action_13
action_48 (17) = happyGoto action_14
action_48 (18) = happyGoto action_15
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (19) = happyShift action_16
action_49 (24) = happyShift action_18
action_49 (25) = happyShift action_19
action_49 (26) = happyShift action_20
action_49 (30) = happyShift action_23
action_49 (39) = happyShift action_25
action_49 (40) = happyShift action_26
action_49 (42) = happyShift action_28
action_49 (43) = happyShift action_29
action_49 (16) = happyGoto action_81
action_49 (17) = happyGoto action_14
action_49 (18) = happyGoto action_15
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (19) = happyShift action_16
action_50 (24) = happyShift action_18
action_50 (25) = happyShift action_19
action_50 (26) = happyShift action_20
action_50 (30) = happyShift action_23
action_50 (39) = happyShift action_25
action_50 (40) = happyShift action_26
action_50 (42) = happyShift action_28
action_50 (43) = happyShift action_29
action_50 (16) = happyGoto action_80
action_50 (17) = happyGoto action_14
action_50 (18) = happyGoto action_15
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (19) = happyShift action_16
action_51 (24) = happyShift action_18
action_51 (25) = happyShift action_19
action_51 (26) = happyShift action_20
action_51 (30) = happyShift action_23
action_51 (39) = happyShift action_25
action_51 (40) = happyShift action_26
action_51 (42) = happyShift action_28
action_51 (43) = happyShift action_29
action_51 (16) = happyGoto action_79
action_51 (17) = happyGoto action_14
action_51 (18) = happyGoto action_15
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (19) = happyShift action_16
action_52 (24) = happyShift action_18
action_52 (25) = happyShift action_19
action_52 (26) = happyShift action_20
action_52 (30) = happyShift action_23
action_52 (39) = happyShift action_25
action_52 (40) = happyShift action_26
action_52 (42) = happyShift action_28
action_52 (43) = happyShift action_29
action_52 (16) = happyGoto action_78
action_52 (17) = happyGoto action_14
action_52 (18) = happyGoto action_15
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (19) = happyShift action_16
action_53 (24) = happyShift action_18
action_53 (25) = happyShift action_19
action_53 (26) = happyShift action_20
action_53 (30) = happyShift action_23
action_53 (39) = happyShift action_25
action_53 (40) = happyShift action_26
action_53 (42) = happyShift action_28
action_53 (43) = happyShift action_29
action_53 (16) = happyGoto action_77
action_53 (17) = happyGoto action_14
action_53 (18) = happyGoto action_15
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (19) = happyShift action_16
action_54 (24) = happyShift action_18
action_54 (25) = happyShift action_19
action_54 (26) = happyShift action_20
action_54 (30) = happyShift action_23
action_54 (39) = happyShift action_25
action_54 (40) = happyShift action_26
action_54 (42) = happyShift action_28
action_54 (43) = happyShift action_29
action_54 (16) = happyGoto action_76
action_54 (17) = happyGoto action_14
action_54 (18) = happyGoto action_15
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (19) = happyShift action_16
action_55 (24) = happyShift action_18
action_55 (25) = happyShift action_19
action_55 (26) = happyShift action_20
action_55 (30) = happyShift action_23
action_55 (39) = happyShift action_25
action_55 (40) = happyShift action_26
action_55 (42) = happyShift action_28
action_55 (43) = happyShift action_29
action_55 (16) = happyGoto action_75
action_55 (17) = happyGoto action_14
action_55 (18) = happyGoto action_15
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (19) = happyShift action_16
action_56 (24) = happyShift action_18
action_56 (25) = happyShift action_19
action_56 (26) = happyShift action_20
action_56 (30) = happyShift action_23
action_56 (39) = happyShift action_25
action_56 (40) = happyShift action_26
action_56 (42) = happyShift action_28
action_56 (43) = happyShift action_29
action_56 (16) = happyGoto action_74
action_56 (17) = happyGoto action_14
action_56 (18) = happyGoto action_15
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (19) = happyShift action_16
action_57 (24) = happyShift action_18
action_57 (25) = happyShift action_19
action_57 (26) = happyShift action_20
action_57 (30) = happyShift action_23
action_57 (39) = happyShift action_25
action_57 (40) = happyShift action_26
action_57 (42) = happyShift action_28
action_57 (43) = happyShift action_29
action_57 (16) = happyGoto action_73
action_57 (17) = happyGoto action_14
action_57 (18) = happyGoto action_15
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (19) = happyShift action_16
action_58 (24) = happyShift action_18
action_58 (25) = happyShift action_19
action_58 (26) = happyShift action_20
action_58 (30) = happyShift action_23
action_58 (39) = happyShift action_25
action_58 (40) = happyShift action_26
action_58 (42) = happyShift action_28
action_58 (43) = happyShift action_29
action_58 (16) = happyGoto action_72
action_58 (17) = happyGoto action_14
action_58 (18) = happyGoto action_15
action_58 _ = happyFail (happyExpListPerState 58)

action_59 (19) = happyShift action_16
action_59 (24) = happyShift action_18
action_59 (25) = happyShift action_19
action_59 (26) = happyShift action_20
action_59 (30) = happyShift action_23
action_59 (39) = happyShift action_25
action_59 (40) = happyShift action_26
action_59 (42) = happyShift action_28
action_59 (43) = happyShift action_29
action_59 (16) = happyGoto action_71
action_59 (17) = happyGoto action_14
action_59 (18) = happyGoto action_15
action_59 _ = happyFail (happyExpListPerState 59)

action_60 (19) = happyShift action_16
action_60 (24) = happyShift action_18
action_60 (25) = happyShift action_19
action_60 (26) = happyShift action_20
action_60 (30) = happyShift action_23
action_60 (39) = happyShift action_25
action_60 (40) = happyShift action_26
action_60 (42) = happyShift action_28
action_60 (43) = happyShift action_29
action_60 (16) = happyGoto action_70
action_60 (17) = happyGoto action_14
action_60 (18) = happyGoto action_15
action_60 _ = happyFail (happyExpListPerState 60)

action_61 (19) = happyShift action_16
action_61 (24) = happyShift action_18
action_61 (25) = happyShift action_19
action_61 (26) = happyShift action_20
action_61 (30) = happyShift action_23
action_61 (39) = happyShift action_25
action_61 (40) = happyShift action_26
action_61 (42) = happyShift action_28
action_61 (43) = happyShift action_29
action_61 (14) = happyGoto action_69
action_61 (16) = happyGoto action_13
action_61 (17) = happyGoto action_14
action_61 (18) = happyGoto action_15
action_61 _ = happyFail (happyExpListPerState 61)

action_62 _ = happyReduce_13

action_63 _ = happyReduce_14

action_64 _ = happyReduce_10

action_65 _ = happyReduce_8

action_66 _ = happyReduce_2

action_67 (35) = happyShift action_68
action_67 _ = happyReduce_6

action_68 (19) = happyShift action_16
action_68 (24) = happyShift action_18
action_68 (25) = happyShift action_19
action_68 (26) = happyShift action_20
action_68 (30) = happyShift action_23
action_68 (39) = happyShift action_25
action_68 (40) = happyShift action_26
action_68 (42) = happyShift action_28
action_68 (43) = happyShift action_29
action_68 (14) = happyGoto action_100
action_68 (16) = happyGoto action_13
action_68 (17) = happyGoto action_14
action_68 (18) = happyGoto action_15
action_68 _ = happyFail (happyExpListPerState 68)

action_69 _ = happyReduce_12

action_70 (30) = happyShift action_42
action_70 (31) = happyShift action_43
action_70 (32) = happyShift action_44
action_70 (33) = happyShift action_45
action_70 (34) = happyShift action_46
action_70 _ = happyReduce_40

action_71 (30) = happyShift action_42
action_71 (31) = happyShift action_43
action_71 (32) = happyShift action_44
action_71 (33) = happyShift action_45
action_71 (34) = happyShift action_46
action_71 _ = happyReduce_39

action_72 (30) = happyShift action_42
action_72 (31) = happyShift action_43
action_72 (32) = happyShift action_44
action_72 (33) = happyShift action_45
action_72 (34) = happyShift action_46
action_72 (38) = happyShift action_47
action_72 (49) = happyShift action_49
action_72 (50) = happyShift action_50
action_72 (51) = happyShift action_51
action_72 (52) = happyShift action_52
action_72 (53) = happyShift action_53
action_72 (54) = happyShift action_54
action_72 (57) = happyShift action_57
action_72 (59) = happyShift action_59
action_72 (60) = happyShift action_60
action_72 _ = happyReduce_42

action_73 (30) = happyShift action_42
action_73 (31) = happyShift action_43
action_73 (32) = happyShift action_44
action_73 (33) = happyShift action_45
action_73 (34) = happyShift action_46
action_73 (49) = happyShift action_49
action_73 (50) = happyShift action_50
action_73 (51) = happyShift action_51
action_73 (52) = happyShift action_52
action_73 (53) = happyShift action_53
action_73 (54) = happyShift action_54
action_73 (59) = happyShift action_59
action_73 (60) = happyShift action_60
action_73 _ = happyReduce_41

action_74 (30) = happyShift action_42
action_74 (31) = happyShift action_43
action_74 (32) = happyShift action_44
action_74 (33) = happyShift action_45
action_74 (34) = happyShift action_46
action_74 (38) = happyShift action_47
action_74 (49) = happyShift action_49
action_74 (50) = happyShift action_50
action_74 (51) = happyShift action_51
action_74 (52) = happyShift action_52
action_74 (53) = happyShift action_53
action_74 (54) = happyShift action_54
action_74 (55) = happyShift action_55
action_74 (57) = happyShift action_57
action_74 (58) = happyShift action_58
action_74 (59) = happyShift action_59
action_74 (60) = happyShift action_60
action_74 _ = happyReduce_45

action_75 (30) = happyShift action_42
action_75 (31) = happyShift action_43
action_75 (32) = happyShift action_44
action_75 (33) = happyShift action_45
action_75 (34) = happyShift action_46
action_75 (38) = happyShift action_47
action_75 (49) = happyShift action_49
action_75 (50) = happyShift action_50
action_75 (51) = happyShift action_51
action_75 (52) = happyShift action_52
action_75 (53) = happyShift action_53
action_75 (54) = happyShift action_54
action_75 (57) = happyShift action_57
action_75 (58) = happyShift action_58
action_75 (59) = happyShift action_59
action_75 (60) = happyShift action_60
action_75 _ = happyReduce_44

action_76 (30) = happyShift action_42
action_76 (31) = happyShift action_43
action_76 (32) = happyShift action_44
action_76 (33) = happyShift action_45
action_76 (34) = happyShift action_46
action_76 (49) = happyShift action_49
action_76 (50) = happyShift action_50
action_76 (51) = happyShift action_51
action_76 (52) = happyShift action_52
action_76 (59) = happyShift action_59
action_76 (60) = happyShift action_60
action_76 _ = happyReduce_51

action_77 (30) = happyShift action_42
action_77 (31) = happyShift action_43
action_77 (32) = happyShift action_44
action_77 (33) = happyShift action_45
action_77 (34) = happyShift action_46
action_77 (49) = happyShift action_49
action_77 (50) = happyShift action_50
action_77 (51) = happyShift action_51
action_77 (52) = happyShift action_52
action_77 (59) = happyShift action_59
action_77 (60) = happyShift action_60
action_77 _ = happyReduce_50

action_78 (30) = happyShift action_42
action_78 (31) = happyShift action_43
action_78 (32) = happyShift action_44
action_78 (33) = happyShift action_45
action_78 (34) = happyShift action_46
action_78 (59) = happyShift action_59
action_78 (60) = happyShift action_60
action_78 _ = happyReduce_47

action_79 (30) = happyShift action_42
action_79 (31) = happyShift action_43
action_79 (32) = happyShift action_44
action_79 (33) = happyShift action_45
action_79 (34) = happyShift action_46
action_79 (59) = happyShift action_59
action_79 (60) = happyShift action_60
action_79 _ = happyReduce_49

action_80 (30) = happyShift action_42
action_80 (31) = happyShift action_43
action_80 (32) = happyShift action_44
action_80 (33) = happyShift action_45
action_80 (34) = happyShift action_46
action_80 (59) = happyShift action_59
action_80 (60) = happyShift action_60
action_80 _ = happyReduce_48

action_81 (30) = happyShift action_42
action_81 (31) = happyShift action_43
action_81 (32) = happyShift action_44
action_81 (33) = happyShift action_45
action_81 (34) = happyShift action_46
action_81 (59) = happyShift action_59
action_81 (60) = happyShift action_60
action_81 _ = happyReduce_46

action_82 (48) = happyShift action_99
action_82 _ = happyFail (happyExpListPerState 82)

action_83 (30) = happyShift action_42
action_83 (31) = happyShift action_43
action_83 (32) = happyShift action_44
action_83 (33) = happyShift action_45
action_83 (34) = happyShift action_46
action_83 (49) = happyShift action_49
action_83 (50) = happyShift action_50
action_83 (51) = happyShift action_51
action_83 (52) = happyShift action_52
action_83 (53) = happyShift action_53
action_83 (54) = happyShift action_54
action_83 (57) = happyShift action_57
action_83 (59) = happyShift action_59
action_83 (60) = happyShift action_60
action_83 _ = happyReduce_43

action_84 _ = happyReduce_38

action_85 _ = happyReduce_37

action_86 _ = happyReduce_36

action_87 (32) = happyShift action_44
action_87 (33) = happyShift action_45
action_87 (34) = happyShift action_46
action_87 _ = happyReduce_35

action_88 (32) = happyShift action_44
action_88 (33) = happyShift action_45
action_88 (34) = happyShift action_46
action_88 _ = happyReduce_34

action_89 _ = happyReduce_28

action_90 _ = happyReduce_11

action_91 _ = happyReduce_24

action_92 (20) = happyShift action_98
action_92 _ = happyFail (happyExpListPerState 92)

action_93 _ = happyReduce_18

action_94 (23) = happyShift action_97
action_94 _ = happyFail (happyExpListPerState 94)

action_95 (20) = happyShift action_96
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (19) = happyShift action_16
action_96 (21) = happyShift action_17
action_96 (24) = happyShift action_18
action_96 (25) = happyShift action_19
action_96 (26) = happyShift action_20
action_96 (28) = happyShift action_21
action_96 (29) = happyShift action_22
action_96 (30) = happyShift action_23
action_96 (37) = happyShift action_24
action_96 (39) = happyShift action_25
action_96 (40) = happyShift action_26
action_96 (41) = happyShift action_27
action_96 (42) = happyShift action_28
action_96 (43) = happyShift action_29
action_96 (44) = happyShift action_30
action_96 (45) = happyShift action_31
action_96 (6) = happyGoto action_6
action_96 (7) = happyGoto action_7
action_96 (9) = happyGoto action_104
action_96 (10) = happyGoto action_10
action_96 (13) = happyGoto action_11
action_96 (14) = happyGoto action_12
action_96 (16) = happyGoto action_13
action_96 (17) = happyGoto action_14
action_96 (18) = happyGoto action_15
action_96 _ = happyFail (happyExpListPerState 96)

action_97 (19) = happyShift action_16
action_97 (24) = happyShift action_18
action_97 (25) = happyShift action_19
action_97 (26) = happyShift action_20
action_97 (30) = happyShift action_23
action_97 (39) = happyShift action_25
action_97 (40) = happyShift action_26
action_97 (42) = happyShift action_28
action_97 (43) = happyShift action_29
action_97 (14) = happyGoto action_103
action_97 (16) = happyGoto action_13
action_97 (17) = happyGoto action_14
action_97 (18) = happyGoto action_15
action_97 _ = happyFail (happyExpListPerState 97)

action_98 (19) = happyShift action_16
action_98 (21) = happyShift action_17
action_98 (24) = happyShift action_18
action_98 (25) = happyShift action_19
action_98 (26) = happyShift action_20
action_98 (28) = happyShift action_21
action_98 (29) = happyShift action_22
action_98 (30) = happyShift action_23
action_98 (37) = happyShift action_24
action_98 (39) = happyShift action_25
action_98 (40) = happyShift action_26
action_98 (41) = happyShift action_27
action_98 (42) = happyShift action_28
action_98 (43) = happyShift action_29
action_98 (44) = happyShift action_30
action_98 (45) = happyShift action_31
action_98 (6) = happyGoto action_6
action_98 (7) = happyGoto action_7
action_98 (9) = happyGoto action_102
action_98 (10) = happyGoto action_10
action_98 (13) = happyGoto action_11
action_98 (14) = happyGoto action_12
action_98 (16) = happyGoto action_13
action_98 (17) = happyGoto action_14
action_98 (18) = happyGoto action_15
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (19) = happyShift action_16
action_99 (24) = happyShift action_18
action_99 (25) = happyShift action_19
action_99 (26) = happyShift action_20
action_99 (30) = happyShift action_23
action_99 (39) = happyShift action_25
action_99 (40) = happyShift action_26
action_99 (42) = happyShift action_28
action_99 (43) = happyShift action_29
action_99 (14) = happyGoto action_101
action_99 (16) = happyGoto action_13
action_99 (17) = happyGoto action_14
action_99 (18) = happyGoto action_15
action_99 _ = happyFail (happyExpListPerState 99)

action_100 _ = happyReduce_5

action_101 _ = happyReduce_26

action_102 _ = happyReduce_22

action_103 (23) = happyShift action_107
action_103 _ = happyFail (happyExpListPerState 103)

action_104 (46) = happyShift action_106
action_104 (12) = happyGoto action_105
action_104 _ = happyReduce_21

action_105 _ = happyReduce_20

action_106 (19) = happyShift action_16
action_106 (21) = happyShift action_17
action_106 (24) = happyShift action_18
action_106 (25) = happyShift action_19
action_106 (26) = happyShift action_20
action_106 (28) = happyShift action_21
action_106 (29) = happyShift action_22
action_106 (30) = happyShift action_23
action_106 (37) = happyShift action_24
action_106 (39) = happyShift action_25
action_106 (40) = happyShift action_26
action_106 (41) = happyShift action_27
action_106 (42) = happyShift action_28
action_106 (43) = happyShift action_29
action_106 (44) = happyShift action_30
action_106 (45) = happyShift action_31
action_106 (6) = happyGoto action_6
action_106 (7) = happyGoto action_7
action_106 (9) = happyGoto action_109
action_106 (10) = happyGoto action_10
action_106 (13) = happyGoto action_11
action_106 (14) = happyGoto action_12
action_106 (16) = happyGoto action_13
action_106 (17) = happyGoto action_14
action_106 (18) = happyGoto action_15
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (19) = happyShift action_16
action_107 (24) = happyShift action_18
action_107 (25) = happyShift action_19
action_107 (26) = happyShift action_20
action_107 (29) = happyShift action_22
action_107 (30) = happyShift action_23
action_107 (39) = happyShift action_25
action_107 (40) = happyShift action_26
action_107 (42) = happyShift action_28
action_107 (43) = happyShift action_29
action_107 (44) = happyShift action_30
action_107 (6) = happyGoto action_6
action_107 (7) = happyGoto action_7
action_107 (10) = happyGoto action_93
action_107 (11) = happyGoto action_108
action_107 (14) = happyGoto action_12
action_107 (16) = happyGoto action_13
action_107 (17) = happyGoto action_14
action_107 (18) = happyGoto action_15
action_107 _ = happyReduce_17

action_108 (20) = happyShift action_110
action_108 _ = happyFail (happyExpListPerState 108)

action_109 _ = happyReduce_19

action_110 (19) = happyShift action_16
action_110 (21) = happyShift action_17
action_110 (24) = happyShift action_18
action_110 (25) = happyShift action_19
action_110 (26) = happyShift action_20
action_110 (28) = happyShift action_21
action_110 (29) = happyShift action_22
action_110 (30) = happyShift action_23
action_110 (37) = happyShift action_24
action_110 (39) = happyShift action_25
action_110 (40) = happyShift action_26
action_110 (41) = happyShift action_27
action_110 (42) = happyShift action_28
action_110 (43) = happyShift action_29
action_110 (44) = happyShift action_30
action_110 (45) = happyShift action_31
action_110 (6) = happyGoto action_6
action_110 (7) = happyGoto action_7
action_110 (9) = happyGoto action_111
action_110 (10) = happyGoto action_10
action_110 (13) = happyGoto action_11
action_110 (14) = happyGoto action_12
action_110 (16) = happyGoto action_13
action_110 (17) = happyGoto action_14
action_110 (18) = happyGoto action_15
action_110 _ = happyFail (happyExpListPerState 110)

action_111 _ = happyReduce_23

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

happyReduce_25 = happySpecReduce_2  14 happyReduction_25
happyReduction_25 (HappyAbsSyn15  happy_var_2)
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn14
		 (checkEmpty happy_var_1 happy_var_2
	)
happyReduction_25 _ _  = notHappyAtAll 

happyReduce_26 = happyReduce 4 15 happyReduction_26
happyReduction_26 ((HappyAbsSyn14  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 ([happy_var_2, happy_var_4]
	) `HappyStk` happyRest

happyReduce_27 = happySpecReduce_0  15 happyReduction_27
happyReduction_27  =  HappyAbsSyn15
		 ([]
	)

happyReduce_28 = happySpecReduce_3  16 happyReduction_28
happyReduction_28 _
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (happy_var_2
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_1  16 happyReduction_29
happyReduction_29 _
	 =  HappyAbsSyn16
		 (T
	)

happyReduce_30 = happySpecReduce_1  16 happyReduction_30
happyReduction_30 _
	 =  HappyAbsSyn16
		 (F
	)

happyReduce_31 = happySpecReduce_1  16 happyReduction_31
happyReduction_31 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1
	)
happyReduction_31 _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_1  16 happyReduction_32
happyReduction_32 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn16
		 (Ident happy_var_1
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_1  16 happyReduction_33
happyReduction_33 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1
	)
happyReduction_33 _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_3  17 happyReduction_34
happyReduction_34 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Sub happy_var_1 happy_var_3
	)
happyReduction_34 _ _ _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_3  17 happyReduction_35
happyReduction_35 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Add happy_var_1 happy_var_3
	)
happyReduction_35 _ _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_3  17 happyReduction_36
happyReduction_36 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Mul happy_var_1 happy_var_3
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  17 happyReduction_37
happyReduction_37 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Div happy_var_1 happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_3  17 happyReduction_38
happyReduction_38 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Mod happy_var_1 happy_var_3
	)
happyReduction_38 _ _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_3  17 happyReduction_39
happyReduction_39 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Sal happy_var_1 happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_3  17 happyReduction_40
happyReduction_40 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Sar happy_var_1 happy_var_3
	)
happyReduction_40 _ _ _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_3  17 happyReduction_41
happyReduction_41 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop BAnd happy_var_1 happy_var_3
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_3  17 happyReduction_42
happyReduction_42 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop BOr happy_var_1 happy_var_3
	)
happyReduction_42 _ _ _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_3  17 happyReduction_43
happyReduction_43 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Xor happy_var_1 happy_var_3
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_3  17 happyReduction_44
happyReduction_44 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop LAnd happy_var_1 happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  17 happyReduction_45
happyReduction_45 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop LOr happy_var_1 happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_3  17 happyReduction_46
happyReduction_46 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Lt happy_var_1 happy_var_3
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_3  17 happyReduction_47
happyReduction_47 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Le happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_3  17 happyReduction_48
happyReduction_48 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Gt happy_var_1 happy_var_3
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_3  17 happyReduction_49
happyReduction_49 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Ge happy_var_1 happy_var_3
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_3  17 happyReduction_50
happyReduction_50 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Eql happy_var_1 happy_var_3
	)
happyReduction_50 _ _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_3  17 happyReduction_51
happyReduction_51 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn17
		 (Binop Neq happy_var_1 happy_var_3
	)
happyReduction_51 _ _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_2  17 happyReduction_52
happyReduction_52 (HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Unop LNot happy_var_2
	)
happyReduction_52 _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_2  17 happyReduction_53
happyReduction_53 (HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Unop BNot happy_var_2
	)
happyReduction_53 _ _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_2  17 happyReduction_54
happyReduction_54 (HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Unop Neg happy_var_2
	)
happyReduction_54 _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_1  18 happyReduction_55
happyReduction_55 (HappyTerminal (TokDec happy_var_1))
	 =  HappyAbsSyn18
		 (checkDec happy_var_1
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_1  18 happyReduction_56
happyReduction_56 (HappyTerminal (TokHex happy_var_1))
	 =  HappyAbsSyn18
		 (checkHex happy_var_1
	)
happyReduction_56 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 63 63 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TokLParen -> cont 19;
	TokRParen -> cont 20;
	TokLBrace -> cont 21;
	TokRBrace -> cont 22;
	TokSemi -> cont 23;
	TokDec happy_dollar_dollar -> cont 24;
	TokHex happy_dollar_dollar -> cont 25;
	TokIdent happy_dollar_dollar -> cont 26;
	TokMain -> cont 27;
	TokReturn -> cont 28;
	TokInt -> cont 29;
	TokMinus -> cont 30;
	TokPlus -> cont 31;
	TokTimes -> cont 32;
	TokDiv -> cont 33;
	TokMod -> cont 34;
	TokAsgnop happy_dollar_dollar -> cont 35;
	TokReserved -> cont 36;
	TokWhile -> cont 37;
	TokXor -> cont 38;
	TokUnop LNot -> cont 39;
	TokUnop BNot -> cont 40;
	TokFor -> cont 41;
	TokTrue -> cont 42;
	TokFalse -> cont 43;
	TokBool -> cont 44;
	TokIf -> cont 45;
	TokElse -> cont 46;
	TokIf -> cont 47;
	TokElse -> cont 48;
	TokLess -> cont 49;
	TokGreater -> cont 50;
	TokGeq -> cont 51;
	TokLeq -> cont 52;
	TokBoolEq -> cont 53;
	TokNotEq -> cont 54;
	TokBoolAnd -> cont 55;
	TokBoolOr -> cont 56;
	TokAnd -> cont 57;
	TokOr -> cont 58;
	TokLshift -> cont 59;
	TokRshift -> cont 60;
	TokIncr -> cont 61;
	TokDecr -> cont 62;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 63 tk tks = happyError' (tks, explist)
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

checkEmpty :: Exp -> [Exp] -> Exp
checkEmpty x y | trace ("checkEmpty " ++ show x ++ " " ++ show y ++ "\n") False = undefined
checkEmpty e1 es = case es of
    [] -> e1
    [e2, e3] -> Ternop e1 e2 e3
    _ -> error "Invalid ternop"

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
{-# LINE 1 "/Users/rick/.stack/programs/x86_64-osx/ghc-8.6.5/lib/ghc-8.6.5/include/ghcversion.h" #-}
















{-# LINE 16 "<built-in>" #-}
{-# LINE 1 "/var/folders/r6/c7hn6nts1j7gqfp7plqpv1q40000gn/T/ghc47840_0/ghc_2.h" #-}

































































































































































































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

