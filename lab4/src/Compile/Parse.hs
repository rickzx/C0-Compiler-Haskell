{-# OPTIONS_GHC -w #-}
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
import qualified Data.Set as Set
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.11

data HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30
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
	| HappyAbsSyn19 t19
	| HappyAbsSyn20 t20
	| HappyAbsSyn21 t21
	| HappyAbsSyn22 t22
	| HappyAbsSyn23 t23
	| HappyAbsSyn24 t24
	| HappyAbsSyn25 t25
	| HappyAbsSyn26 t26
	| HappyAbsSyn27 t27
	| HappyAbsSyn28 t28
	| HappyAbsSyn29 t29
	| HappyAbsSyn30 t30

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,1055) ([0,0,25600,1536,8,0,0,0,50,1027,0,0,0,0,0,0,0,0,32768,49164,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,256,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,36864,2049,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,512,0,0,0,0,2560,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,20480,0,0,0,0,0,12801,256,4,0,0,0,0,0,0,0,0,3200,64,1,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,25600,512,8,0,0,4096,0,0,0,0,0,512,0,0,0,0,4096,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,65058,46981,63,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,61712,48175,509,0,0,0,2,0,0,0,0,0,0,0,0,0,2432,16128,32832,32766,0,0,0,0,0,0,0,0,0,0,0,0,16384,41664,45168,1,0,0,57888,30815,1019,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,5762,33669,13,0,0,256,49803,1729,0,0,32768,17792,24801,3,0,0,0,0,0,0,0,8192,0,0,0,0,0,16,0,0,0,0,2048,0,0,0,0,0,4,0,0,0,0,512,34070,3459,0,0,0,35585,49602,6,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,51200,1024,16,0,0,16384,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,512,34070,3459,0,0,0,61185,50114,14,0,0,608,0,0,0,0,12288,1,0,0,0,0,24608,14417,216,0,0,4096,10416,27676,0,0,0,8192,4099,64,0,0,0,400,8200,0,0,32768,9,0,0,0,0,1216,0,0,0,0,24576,49186,4103,65440,7,0,0,0,0,0,0,0,0,0,0,0,0,45104,7208,108,0,0,0,1,0,0,0,0,27,32830,64768,63,0,0,16,0,0,0,0,2048,0,0,0,0,32896,57669,864,0,0,16384,41664,45168,1,0,0,24608,14417,216,0,0,4096,10416,27676,0,0,0,22536,3604,54,0,0,1024,2604,6919,0,0,0,5634,33669,13,0,0,256,49803,1729,0,0,32768,17792,24801,3,0,0,49216,28834,432,0,0,8192,20832,55352,0,0,0,45072,7208,108,0,0,2048,5208,13838,0,0,0,11268,1802,27,0,0,512,34070,3459,0,0,0,35585,49602,6,0,0,32896,57669,864,0,0,16384,41664,45168,1,0,0,24608,14417,216,0,0,4096,10416,27676,0,0,0,22536,3604,54,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,45072,7208,108,0,0,9728,31744,0,0,0,0,19,62,0,0,0,2432,7936,64,6782,0,49152,32772,15,16128,12,0,608,1984,32784,1983,0,12288,57345,2051,53184,3,0,152,496,57344,385,0,19456,63488,0,49392,0,0,38,124,0,96,0,4864,15872,0,12288,0,32768,9,31,0,24,0,1216,3968,0,3072,0,24576,49154,4103,65504,7,0,304,992,49152,847,0,38912,61440,1025,65512,1,0,76,0,0,0,0,9728,0,0,0,0,0,19,0,0,0,0,2432,7168,0,0,0,49152,4,14,0,0,0,1632,1984,40976,2047,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4864,15874,128,16381,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,8192,0,0,0,0,55296,61440,1025,65512,1,0,108,248,62466,255,0,0,0,0,0,0,0,256,0,0,0,0,3456,7936,32832,8190,0,0,0,0,0,0,0,34944,57727,4077,0,0,16384,41664,45168,1,0,0,57888,30815,1019,0,0,0,4,0,0,0,0,22536,3604,54,0,0,0,0,0,0,0,0,4,0,0,0,0,256,49803,1729,0,0,0,0,0,0,0,0,49216,28834,432,0,0,38912,61440,1025,65512,1,0,76,248,62466,255,0,9728,31748,256,32762,0,0,0,0,0,0,0,3456,7936,32832,8190,0,0,0,0,0,0,0,0,0,0,0,0,12288,57361,2051,65488,3,0,0,0,1024,0,0,0,0,0,0,0,0,63624,56855,254,0,0,1024,3004,15119,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,8192,24546,64376,3,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Funs","Gdecl","Fdecl","Fdefn","Param","ParamlistFollow","Paramlist","Sdecl","Sdef","Field","Fieldlist","Typedef","Block","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","ArglistFollow","Arglist","Operation","Intconst","'.'","'->'","'('","')'","'['","']'","'{'","'}'","';'","','","dec","hex","typeIdent","ident","ret","int","void","'-'","'+'","'*'","'/'","'%'","asgnop","kill","NULL","alloc","alloc_array","struct","typedef","assert","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 87
        bit_end = (st + 1) * 87
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..86]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (43) = happyShift action_10
action_0 (46) = happyShift action_11
action_0 (47) = happyShift action_12
action_0 (58) = happyShift action_13
action_0 (59) = happyShift action_14
action_0 (68) = happyShift action_15
action_0 (4) = happyGoto action_16
action_0 (5) = happyGoto action_2
action_0 (6) = happyGoto action_3
action_0 (7) = happyGoto action_4
action_0 (8) = happyGoto action_5
action_0 (12) = happyGoto action_6
action_0 (13) = happyGoto action_7
action_0 (16) = happyGoto action_8
action_0 (18) = happyGoto action_9
action_0 _ = happyReduce_2

action_1 (43) = happyShift action_10
action_1 (46) = happyShift action_11
action_1 (47) = happyShift action_12
action_1 (58) = happyShift action_13
action_1 (59) = happyShift action_14
action_1 (68) = happyShift action_15
action_1 (5) = happyGoto action_2
action_1 (6) = happyGoto action_3
action_1 (7) = happyGoto action_4
action_1 (8) = happyGoto action_5
action_1 (12) = happyGoto action_6
action_1 (13) = happyGoto action_7
action_1 (16) = happyGoto action_8
action_1 (18) = happyGoto action_9
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 (43) = happyShift action_10
action_3 (46) = happyShift action_11
action_3 (47) = happyShift action_12
action_3 (58) = happyShift action_13
action_3 (59) = happyShift action_14
action_3 (68) = happyShift action_15
action_3 (5) = happyGoto action_23
action_3 (6) = happyGoto action_3
action_3 (7) = happyGoto action_4
action_3 (8) = happyGoto action_5
action_3 (12) = happyGoto action_6
action_3 (13) = happyGoto action_7
action_3 (16) = happyGoto action_8
action_3 (18) = happyGoto action_9
action_3 _ = happyReduce_2

action_4 _ = happyReduce_4

action_5 _ = happyReduce_5

action_6 _ = happyReduce_6

action_7 _ = happyReduce_7

action_8 _ = happyReduce_8

action_9 (44) = happyShift action_22
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (35) = happyShift action_20
action_10 (50) = happyShift action_21
action_10 _ = happyReduce_25

action_11 _ = happyReduce_23

action_12 _ = happyReduce_26

action_13 (44) = happyShift action_19
action_13 _ = happyFail (happyExpListPerState 13)

action_14 (43) = happyShift action_10
action_14 (46) = happyShift action_11
action_14 (47) = happyShift action_12
action_14 (58) = happyShift action_18
action_14 (68) = happyShift action_15
action_14 (18) = happyGoto action_17
action_14 _ = happyFail (happyExpListPerState 14)

action_15 _ = happyReduce_24

action_16 (87) = happyAccept
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (44) = happyShift action_30
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (44) = happyShift action_29
action_18 _ = happyFail (happyExpListPerState 18)

action_19 (37) = happyShift action_27
action_19 (39) = happyShift action_28
action_19 _ = happyReduce_29

action_20 (36) = happyShift action_26
action_20 _ = happyFail (happyExpListPerState 20)

action_21 _ = happyReduce_28

action_22 (33) = happyShift action_25
action_22 (11) = happyGoto action_24
action_22 _ = happyFail (happyExpListPerState 22)

action_23 _ = happyReduce_3

action_24 (37) = happyShift action_39
action_24 (39) = happyShift action_40
action_24 (17) = happyGoto action_38
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (34) = happyShift action_37
action_25 (43) = happyShift action_10
action_25 (46) = happyShift action_11
action_25 (47) = happyShift action_12
action_25 (58) = happyShift action_18
action_25 (68) = happyShift action_15
action_25 (9) = happyGoto action_35
action_25 (18) = happyGoto action_36
action_25 _ = happyFail (happyExpListPerState 25)

action_26 _ = happyReduce_27

action_27 (43) = happyShift action_10
action_27 (46) = happyShift action_11
action_27 (47) = happyShift action_12
action_27 (58) = happyShift action_18
action_27 (68) = happyShift action_15
action_27 (14) = happyGoto action_32
action_27 (15) = happyGoto action_33
action_27 (18) = happyGoto action_34
action_27 _ = happyReduce_19

action_28 _ = happyReduce_16

action_29 _ = happyReduce_29

action_30 (39) = happyShift action_31
action_30 _ = happyFail (happyExpListPerState 30)

action_31 _ = happyReduce_21

action_32 (43) = happyShift action_10
action_32 (46) = happyShift action_11
action_32 (47) = happyShift action_12
action_32 (58) = happyShift action_18
action_32 (68) = happyShift action_15
action_32 (14) = happyGoto action_32
action_32 (15) = happyGoto action_74
action_32 (18) = happyGoto action_34
action_32 _ = happyReduce_19

action_33 (38) = happyShift action_73
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (44) = happyShift action_72
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (40) = happyShift action_71
action_35 (10) = happyGoto action_70
action_35 _ = happyReduce_12

action_36 (44) = happyShift action_69
action_36 _ = happyFail (happyExpListPerState 36)

action_37 _ = happyReduce_14

action_38 _ = happyReduce_10

action_39 (33) = happyShift action_50
action_39 (37) = happyShift action_51
action_39 (41) = happyShift action_52
action_39 (42) = happyShift action_53
action_39 (43) = happyShift action_10
action_39 (44) = happyShift action_54
action_39 (45) = happyShift action_55
action_39 (46) = happyShift action_11
action_39 (47) = happyShift action_12
action_39 (48) = happyShift action_56
action_39 (50) = happyShift action_57
action_39 (55) = happyShift action_58
action_39 (56) = happyShift action_59
action_39 (57) = happyShift action_60
action_39 (58) = happyShift action_18
action_39 (60) = happyShift action_61
action_39 (61) = happyShift action_62
action_39 (63) = happyShift action_63
action_39 (64) = happyShift action_64
action_39 (65) = happyShift action_65
action_39 (66) = happyShift action_66
action_39 (67) = happyShift action_67
action_39 (68) = happyShift action_15
action_39 (69) = happyShift action_68
action_39 (18) = happyGoto action_41
action_39 (19) = happyGoto action_42
action_39 (20) = happyGoto action_43
action_39 (21) = happyGoto action_44
action_39 (22) = happyGoto action_45
action_39 (25) = happyGoto action_46
action_39 (26) = happyGoto action_47
action_39 (29) = happyGoto action_48
action_39 (30) = happyGoto action_49
action_39 _ = happyReduce_32

action_40 _ = happyReduce_9

action_41 (44) = happyShift action_123
action_41 _ = happyFail (happyExpListPerState 41)

action_42 _ = happyReduce_40

action_43 (38) = happyShift action_122
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (33) = happyShift action_50
action_44 (37) = happyShift action_51
action_44 (41) = happyShift action_52
action_44 (42) = happyShift action_53
action_44 (43) = happyShift action_10
action_44 (44) = happyShift action_54
action_44 (45) = happyShift action_55
action_44 (46) = happyShift action_11
action_44 (47) = happyShift action_12
action_44 (48) = happyShift action_56
action_44 (50) = happyShift action_57
action_44 (55) = happyShift action_58
action_44 (56) = happyShift action_59
action_44 (57) = happyShift action_60
action_44 (58) = happyShift action_18
action_44 (60) = happyShift action_61
action_44 (61) = happyShift action_62
action_44 (63) = happyShift action_63
action_44 (64) = happyShift action_64
action_44 (65) = happyShift action_65
action_44 (66) = happyShift action_66
action_44 (67) = happyShift action_67
action_44 (68) = happyShift action_15
action_44 (69) = happyShift action_68
action_44 (18) = happyGoto action_41
action_44 (19) = happyGoto action_42
action_44 (20) = happyGoto action_121
action_44 (21) = happyGoto action_44
action_44 (22) = happyGoto action_45
action_44 (25) = happyGoto action_46
action_44 (26) = happyGoto action_47
action_44 (29) = happyGoto action_48
action_44 (30) = happyGoto action_49
action_44 _ = happyReduce_32

action_45 (39) = happyShift action_120
action_45 _ = happyFail (happyExpListPerState 45)

action_46 _ = happyReduce_34

action_47 (31) = happyShift action_95
action_47 (32) = happyShift action_96
action_47 (35) = happyShift action_97
action_47 (48) = happyShift action_98
action_47 (49) = happyShift action_99
action_47 (50) = happyShift action_100
action_47 (51) = happyShift action_101
action_47 (52) = happyShift action_102
action_47 (53) = happyShift action_103
action_47 (62) = happyShift action_104
action_47 (71) = happyShift action_105
action_47 (73) = happyShift action_106
action_47 (74) = happyShift action_107
action_47 (75) = happyShift action_108
action_47 (76) = happyShift action_109
action_47 (77) = happyShift action_110
action_47 (78) = happyShift action_111
action_47 (79) = happyShift action_112
action_47 (80) = happyShift action_113
action_47 (81) = happyShift action_114
action_47 (82) = happyShift action_115
action_47 (83) = happyShift action_116
action_47 (84) = happyShift action_117
action_47 (85) = happyShift action_118
action_47 (86) = happyShift action_119
action_47 _ = happyReduce_41

action_48 _ = happyReduce_59

action_49 _ = happyReduce_57

action_50 (33) = happyShift action_50
action_50 (41) = happyShift action_52
action_50 (42) = happyShift action_53
action_50 (44) = happyShift action_54
action_50 (48) = happyShift action_56
action_50 (50) = happyShift action_57
action_50 (55) = happyShift action_58
action_50 (56) = happyShift action_59
action_50 (57) = happyShift action_60
action_50 (63) = happyShift action_63
action_50 (64) = happyShift action_64
action_50 (66) = happyShift action_66
action_50 (67) = happyShift action_67
action_50 (26) = happyGoto action_94
action_50 (29) = happyGoto action_48
action_50 (30) = happyGoto action_49
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (33) = happyShift action_50
action_51 (37) = happyShift action_51
action_51 (41) = happyShift action_52
action_51 (42) = happyShift action_53
action_51 (43) = happyShift action_10
action_51 (44) = happyShift action_54
action_51 (45) = happyShift action_55
action_51 (46) = happyShift action_11
action_51 (47) = happyShift action_12
action_51 (48) = happyShift action_56
action_51 (50) = happyShift action_57
action_51 (55) = happyShift action_58
action_51 (56) = happyShift action_59
action_51 (57) = happyShift action_60
action_51 (58) = happyShift action_18
action_51 (60) = happyShift action_61
action_51 (61) = happyShift action_62
action_51 (63) = happyShift action_63
action_51 (64) = happyShift action_64
action_51 (65) = happyShift action_65
action_51 (66) = happyShift action_66
action_51 (67) = happyShift action_67
action_51 (68) = happyShift action_15
action_51 (69) = happyShift action_68
action_51 (18) = happyGoto action_41
action_51 (19) = happyGoto action_42
action_51 (20) = happyGoto action_93
action_51 (21) = happyGoto action_44
action_51 (22) = happyGoto action_45
action_51 (25) = happyGoto action_46
action_51 (26) = happyGoto action_47
action_51 (29) = happyGoto action_48
action_51 (30) = happyGoto action_49
action_51 _ = happyReduce_32

action_52 _ = happyReduce_92

action_53 _ = happyReduce_93

action_54 (33) = happyShift action_92
action_54 (28) = happyGoto action_91
action_54 _ = happyReduce_58

action_55 (33) = happyShift action_50
action_55 (39) = happyShift action_90
action_55 (41) = happyShift action_52
action_55 (42) = happyShift action_53
action_55 (44) = happyShift action_54
action_55 (48) = happyShift action_56
action_55 (50) = happyShift action_57
action_55 (55) = happyShift action_58
action_55 (56) = happyShift action_59
action_55 (57) = happyShift action_60
action_55 (63) = happyShift action_63
action_55 (64) = happyShift action_64
action_55 (66) = happyShift action_66
action_55 (67) = happyShift action_67
action_55 (26) = happyGoto action_89
action_55 (29) = happyGoto action_48
action_55 (30) = happyGoto action_49
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (33) = happyShift action_50
action_56 (41) = happyShift action_52
action_56 (42) = happyShift action_53
action_56 (44) = happyShift action_54
action_56 (48) = happyShift action_56
action_56 (50) = happyShift action_57
action_56 (55) = happyShift action_58
action_56 (56) = happyShift action_59
action_56 (57) = happyShift action_60
action_56 (63) = happyShift action_63
action_56 (64) = happyShift action_64
action_56 (66) = happyShift action_66
action_56 (67) = happyShift action_67
action_56 (26) = happyGoto action_88
action_56 (29) = happyGoto action_48
action_56 (30) = happyGoto action_49
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (33) = happyShift action_50
action_57 (41) = happyShift action_52
action_57 (42) = happyShift action_53
action_57 (44) = happyShift action_54
action_57 (48) = happyShift action_56
action_57 (50) = happyShift action_57
action_57 (55) = happyShift action_58
action_57 (56) = happyShift action_59
action_57 (57) = happyShift action_60
action_57 (63) = happyShift action_63
action_57 (64) = happyShift action_64
action_57 (66) = happyShift action_66
action_57 (67) = happyShift action_67
action_57 (26) = happyGoto action_87
action_57 (29) = happyGoto action_48
action_57 (30) = happyGoto action_49
action_57 _ = happyFail (happyExpListPerState 57)

action_58 _ = happyReduce_56

action_59 (33) = happyShift action_86
action_59 _ = happyFail (happyExpListPerState 59)

action_60 (33) = happyShift action_85
action_60 _ = happyFail (happyExpListPerState 60)

action_61 (33) = happyShift action_84
action_61 _ = happyFail (happyExpListPerState 61)

action_62 (33) = happyShift action_83
action_62 _ = happyFail (happyExpListPerState 62)

action_63 (33) = happyShift action_50
action_63 (41) = happyShift action_52
action_63 (42) = happyShift action_53
action_63 (44) = happyShift action_54
action_63 (48) = happyShift action_56
action_63 (50) = happyShift action_57
action_63 (55) = happyShift action_58
action_63 (56) = happyShift action_59
action_63 (57) = happyShift action_60
action_63 (63) = happyShift action_63
action_63 (64) = happyShift action_64
action_63 (66) = happyShift action_66
action_63 (67) = happyShift action_67
action_63 (26) = happyGoto action_82
action_63 (29) = happyGoto action_48
action_63 (30) = happyGoto action_49
action_63 _ = happyFail (happyExpListPerState 63)

action_64 (33) = happyShift action_50
action_64 (41) = happyShift action_52
action_64 (42) = happyShift action_53
action_64 (44) = happyShift action_54
action_64 (48) = happyShift action_56
action_64 (50) = happyShift action_57
action_64 (55) = happyShift action_58
action_64 (56) = happyShift action_59
action_64 (57) = happyShift action_60
action_64 (63) = happyShift action_63
action_64 (64) = happyShift action_64
action_64 (66) = happyShift action_66
action_64 (67) = happyShift action_67
action_64 (26) = happyGoto action_81
action_64 (29) = happyGoto action_48
action_64 (30) = happyGoto action_49
action_64 _ = happyFail (happyExpListPerState 64)

action_65 (33) = happyShift action_80
action_65 _ = happyFail (happyExpListPerState 65)

action_66 _ = happyReduce_54

action_67 _ = happyReduce_55

action_68 (33) = happyShift action_79
action_68 _ = happyFail (happyExpListPerState 68)

action_69 _ = happyReduce_11

action_70 (34) = happyShift action_78
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (43) = happyShift action_10
action_71 (46) = happyShift action_11
action_71 (47) = happyShift action_12
action_71 (58) = happyShift action_18
action_71 (68) = happyShift action_15
action_71 (9) = happyGoto action_77
action_71 (18) = happyGoto action_36
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (39) = happyShift action_76
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (39) = happyShift action_75
action_73 _ = happyFail (happyExpListPerState 73)

action_74 _ = happyReduce_20

action_75 _ = happyReduce_17

action_76 _ = happyReduce_18

action_77 (40) = happyShift action_71
action_77 (10) = happyGoto action_160
action_77 _ = happyReduce_12

action_78 _ = happyReduce_15

action_79 (33) = happyShift action_50
action_79 (41) = happyShift action_52
action_79 (42) = happyShift action_53
action_79 (44) = happyShift action_54
action_79 (48) = happyShift action_56
action_79 (50) = happyShift action_57
action_79 (55) = happyShift action_58
action_79 (56) = happyShift action_59
action_79 (57) = happyShift action_60
action_79 (63) = happyShift action_63
action_79 (64) = happyShift action_64
action_79 (66) = happyShift action_66
action_79 (67) = happyShift action_67
action_79 (26) = happyGoto action_159
action_79 (29) = happyGoto action_48
action_79 (30) = happyGoto action_49
action_79 _ = happyFail (happyExpListPerState 79)

action_80 (33) = happyShift action_50
action_80 (41) = happyShift action_52
action_80 (42) = happyShift action_53
action_80 (43) = happyShift action_10
action_80 (44) = happyShift action_54
action_80 (46) = happyShift action_11
action_80 (47) = happyShift action_12
action_80 (48) = happyShift action_56
action_80 (50) = happyShift action_57
action_80 (55) = happyShift action_58
action_80 (56) = happyShift action_59
action_80 (57) = happyShift action_60
action_80 (58) = happyShift action_18
action_80 (63) = happyShift action_63
action_80 (64) = happyShift action_64
action_80 (66) = happyShift action_66
action_80 (67) = happyShift action_67
action_80 (68) = happyShift action_15
action_80 (18) = happyGoto action_41
action_80 (19) = happyGoto action_42
action_80 (22) = happyGoto action_157
action_80 (23) = happyGoto action_158
action_80 (26) = happyGoto action_47
action_80 (29) = happyGoto action_48
action_80 (30) = happyGoto action_49
action_80 _ = happyReduce_42

action_81 (31) = happyShift action_95
action_81 (32) = happyShift action_96
action_81 (35) = happyShift action_97
action_81 _ = happyReduce_90

action_82 (31) = happyShift action_95
action_82 (32) = happyShift action_96
action_82 (35) = happyShift action_97
action_82 _ = happyReduce_89

action_83 (33) = happyShift action_50
action_83 (41) = happyShift action_52
action_83 (42) = happyShift action_53
action_83 (44) = happyShift action_54
action_83 (48) = happyShift action_56
action_83 (50) = happyShift action_57
action_83 (55) = happyShift action_58
action_83 (56) = happyShift action_59
action_83 (57) = happyShift action_60
action_83 (63) = happyShift action_63
action_83 (64) = happyShift action_64
action_83 (66) = happyShift action_66
action_83 (67) = happyShift action_67
action_83 (26) = happyGoto action_156
action_83 (29) = happyGoto action_48
action_83 (30) = happyGoto action_49
action_83 _ = happyFail (happyExpListPerState 83)

action_84 (33) = happyShift action_50
action_84 (41) = happyShift action_52
action_84 (42) = happyShift action_53
action_84 (44) = happyShift action_54
action_84 (48) = happyShift action_56
action_84 (50) = happyShift action_57
action_84 (55) = happyShift action_58
action_84 (56) = happyShift action_59
action_84 (57) = happyShift action_60
action_84 (63) = happyShift action_63
action_84 (64) = happyShift action_64
action_84 (66) = happyShift action_66
action_84 (67) = happyShift action_67
action_84 (26) = happyGoto action_155
action_84 (29) = happyGoto action_48
action_84 (30) = happyGoto action_49
action_84 _ = happyFail (happyExpListPerState 84)

action_85 (43) = happyShift action_10
action_85 (46) = happyShift action_11
action_85 (47) = happyShift action_12
action_85 (58) = happyShift action_18
action_85 (68) = happyShift action_15
action_85 (18) = happyGoto action_154
action_85 _ = happyFail (happyExpListPerState 85)

action_86 (43) = happyShift action_10
action_86 (46) = happyShift action_11
action_86 (47) = happyShift action_12
action_86 (58) = happyShift action_18
action_86 (68) = happyShift action_15
action_86 (18) = happyGoto action_153
action_86 _ = happyFail (happyExpListPerState 86)

action_87 (31) = happyShift action_95
action_87 (32) = happyShift action_96
action_87 (35) = happyShift action_97
action_87 _ = happyReduce_66

action_88 (31) = happyShift action_95
action_88 (32) = happyShift action_96
action_88 (35) = happyShift action_97
action_88 _ = happyReduce_91

action_89 (31) = happyShift action_95
action_89 (32) = happyShift action_96
action_89 (35) = happyShift action_97
action_89 (39) = happyShift action_152
action_89 (48) = happyShift action_98
action_89 (49) = happyShift action_99
action_89 (50) = happyShift action_100
action_89 (51) = happyShift action_101
action_89 (52) = happyShift action_102
action_89 (62) = happyShift action_104
action_89 (71) = happyShift action_105
action_89 (73) = happyShift action_106
action_89 (74) = happyShift action_107
action_89 (75) = happyShift action_108
action_89 (76) = happyShift action_109
action_89 (77) = happyShift action_110
action_89 (78) = happyShift action_111
action_89 (79) = happyShift action_112
action_89 (80) = happyShift action_113
action_89 (81) = happyShift action_114
action_89 (82) = happyShift action_115
action_89 (83) = happyShift action_116
action_89 (84) = happyShift action_117
action_89 _ = happyFail (happyExpListPerState 89)

action_90 _ = happyReduce_50

action_91 _ = happyReduce_60

action_92 (33) = happyShift action_50
action_92 (34) = happyShift action_151
action_92 (41) = happyShift action_52
action_92 (42) = happyShift action_53
action_92 (44) = happyShift action_54
action_92 (48) = happyShift action_56
action_92 (50) = happyShift action_57
action_92 (55) = happyShift action_58
action_92 (56) = happyShift action_59
action_92 (57) = happyShift action_60
action_92 (63) = happyShift action_63
action_92 (64) = happyShift action_64
action_92 (66) = happyShift action_66
action_92 (67) = happyShift action_67
action_92 (26) = happyGoto action_150
action_92 (29) = happyGoto action_48
action_92 (30) = happyGoto action_49
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (38) = happyShift action_149
action_93 _ = happyFail (happyExpListPerState 93)

action_94 (31) = happyShift action_95
action_94 (32) = happyShift action_96
action_94 (34) = happyShift action_148
action_94 (35) = happyShift action_97
action_94 (48) = happyShift action_98
action_94 (49) = happyShift action_99
action_94 (50) = happyShift action_100
action_94 (51) = happyShift action_101
action_94 (52) = happyShift action_102
action_94 (62) = happyShift action_104
action_94 (71) = happyShift action_105
action_94 (73) = happyShift action_106
action_94 (74) = happyShift action_107
action_94 (75) = happyShift action_108
action_94 (76) = happyShift action_109
action_94 (77) = happyShift action_110
action_94 (78) = happyShift action_111
action_94 (79) = happyShift action_112
action_94 (80) = happyShift action_113
action_94 (81) = happyShift action_114
action_94 (82) = happyShift action_115
action_94 (83) = happyShift action_116
action_94 (84) = happyShift action_117
action_94 _ = happyFail (happyExpListPerState 94)

action_95 (44) = happyShift action_147
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (44) = happyShift action_146
action_96 _ = happyFail (happyExpListPerState 96)

action_97 (33) = happyShift action_50
action_97 (41) = happyShift action_52
action_97 (42) = happyShift action_53
action_97 (44) = happyShift action_54
action_97 (48) = happyShift action_56
action_97 (50) = happyShift action_57
action_97 (55) = happyShift action_58
action_97 (56) = happyShift action_59
action_97 (57) = happyShift action_60
action_97 (63) = happyShift action_63
action_97 (64) = happyShift action_64
action_97 (66) = happyShift action_66
action_97 (67) = happyShift action_67
action_97 (26) = happyGoto action_145
action_97 (29) = happyGoto action_48
action_97 (30) = happyGoto action_49
action_97 _ = happyFail (happyExpListPerState 97)

action_98 (33) = happyShift action_50
action_98 (41) = happyShift action_52
action_98 (42) = happyShift action_53
action_98 (44) = happyShift action_54
action_98 (48) = happyShift action_56
action_98 (50) = happyShift action_57
action_98 (55) = happyShift action_58
action_98 (56) = happyShift action_59
action_98 (57) = happyShift action_60
action_98 (63) = happyShift action_63
action_98 (64) = happyShift action_64
action_98 (66) = happyShift action_66
action_98 (67) = happyShift action_67
action_98 (26) = happyGoto action_144
action_98 (29) = happyGoto action_48
action_98 (30) = happyGoto action_49
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (33) = happyShift action_50
action_99 (41) = happyShift action_52
action_99 (42) = happyShift action_53
action_99 (44) = happyShift action_54
action_99 (48) = happyShift action_56
action_99 (50) = happyShift action_57
action_99 (55) = happyShift action_58
action_99 (56) = happyShift action_59
action_99 (57) = happyShift action_60
action_99 (63) = happyShift action_63
action_99 (64) = happyShift action_64
action_99 (66) = happyShift action_66
action_99 (67) = happyShift action_67
action_99 (26) = happyGoto action_143
action_99 (29) = happyGoto action_48
action_99 (30) = happyGoto action_49
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (33) = happyShift action_50
action_100 (41) = happyShift action_52
action_100 (42) = happyShift action_53
action_100 (44) = happyShift action_54
action_100 (48) = happyShift action_56
action_100 (50) = happyShift action_57
action_100 (55) = happyShift action_58
action_100 (56) = happyShift action_59
action_100 (57) = happyShift action_60
action_100 (63) = happyShift action_63
action_100 (64) = happyShift action_64
action_100 (66) = happyShift action_66
action_100 (67) = happyShift action_67
action_100 (26) = happyGoto action_142
action_100 (29) = happyGoto action_48
action_100 (30) = happyGoto action_49
action_100 _ = happyFail (happyExpListPerState 100)

action_101 (33) = happyShift action_50
action_101 (41) = happyShift action_52
action_101 (42) = happyShift action_53
action_101 (44) = happyShift action_54
action_101 (48) = happyShift action_56
action_101 (50) = happyShift action_57
action_101 (55) = happyShift action_58
action_101 (56) = happyShift action_59
action_101 (57) = happyShift action_60
action_101 (63) = happyShift action_63
action_101 (64) = happyShift action_64
action_101 (66) = happyShift action_66
action_101 (67) = happyShift action_67
action_101 (26) = happyGoto action_141
action_101 (29) = happyGoto action_48
action_101 (30) = happyGoto action_49
action_101 _ = happyFail (happyExpListPerState 101)

action_102 (33) = happyShift action_50
action_102 (41) = happyShift action_52
action_102 (42) = happyShift action_53
action_102 (44) = happyShift action_54
action_102 (48) = happyShift action_56
action_102 (50) = happyShift action_57
action_102 (55) = happyShift action_58
action_102 (56) = happyShift action_59
action_102 (57) = happyShift action_60
action_102 (63) = happyShift action_63
action_102 (64) = happyShift action_64
action_102 (66) = happyShift action_66
action_102 (67) = happyShift action_67
action_102 (26) = happyGoto action_140
action_102 (29) = happyGoto action_48
action_102 (30) = happyGoto action_49
action_102 _ = happyFail (happyExpListPerState 102)

action_103 (33) = happyShift action_50
action_103 (41) = happyShift action_52
action_103 (42) = happyShift action_53
action_103 (44) = happyShift action_54
action_103 (48) = happyShift action_56
action_103 (50) = happyShift action_57
action_103 (55) = happyShift action_58
action_103 (56) = happyShift action_59
action_103 (57) = happyShift action_60
action_103 (63) = happyShift action_63
action_103 (64) = happyShift action_64
action_103 (66) = happyShift action_66
action_103 (67) = happyShift action_67
action_103 (26) = happyGoto action_139
action_103 (29) = happyGoto action_48
action_103 (30) = happyGoto action_49
action_103 _ = happyFail (happyExpListPerState 103)

action_104 (33) = happyShift action_50
action_104 (41) = happyShift action_52
action_104 (42) = happyShift action_53
action_104 (44) = happyShift action_54
action_104 (48) = happyShift action_56
action_104 (50) = happyShift action_57
action_104 (55) = happyShift action_58
action_104 (56) = happyShift action_59
action_104 (57) = happyShift action_60
action_104 (63) = happyShift action_63
action_104 (64) = happyShift action_64
action_104 (66) = happyShift action_66
action_104 (67) = happyShift action_67
action_104 (26) = happyGoto action_138
action_104 (29) = happyGoto action_48
action_104 (30) = happyGoto action_49
action_104 _ = happyFail (happyExpListPerState 104)

action_105 (33) = happyShift action_50
action_105 (41) = happyShift action_52
action_105 (42) = happyShift action_53
action_105 (44) = happyShift action_54
action_105 (48) = happyShift action_56
action_105 (50) = happyShift action_57
action_105 (55) = happyShift action_58
action_105 (56) = happyShift action_59
action_105 (57) = happyShift action_60
action_105 (63) = happyShift action_63
action_105 (64) = happyShift action_64
action_105 (66) = happyShift action_66
action_105 (67) = happyShift action_67
action_105 (26) = happyGoto action_137
action_105 (29) = happyGoto action_48
action_105 (30) = happyGoto action_49
action_105 _ = happyFail (happyExpListPerState 105)

action_106 (33) = happyShift action_50
action_106 (41) = happyShift action_52
action_106 (42) = happyShift action_53
action_106 (44) = happyShift action_54
action_106 (48) = happyShift action_56
action_106 (50) = happyShift action_57
action_106 (55) = happyShift action_58
action_106 (56) = happyShift action_59
action_106 (57) = happyShift action_60
action_106 (63) = happyShift action_63
action_106 (64) = happyShift action_64
action_106 (66) = happyShift action_66
action_106 (67) = happyShift action_67
action_106 (26) = happyGoto action_136
action_106 (29) = happyGoto action_48
action_106 (30) = happyGoto action_49
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (33) = happyShift action_50
action_107 (41) = happyShift action_52
action_107 (42) = happyShift action_53
action_107 (44) = happyShift action_54
action_107 (48) = happyShift action_56
action_107 (50) = happyShift action_57
action_107 (55) = happyShift action_58
action_107 (56) = happyShift action_59
action_107 (57) = happyShift action_60
action_107 (63) = happyShift action_63
action_107 (64) = happyShift action_64
action_107 (66) = happyShift action_66
action_107 (67) = happyShift action_67
action_107 (26) = happyGoto action_135
action_107 (29) = happyGoto action_48
action_107 (30) = happyGoto action_49
action_107 _ = happyFail (happyExpListPerState 107)

action_108 (33) = happyShift action_50
action_108 (41) = happyShift action_52
action_108 (42) = happyShift action_53
action_108 (44) = happyShift action_54
action_108 (48) = happyShift action_56
action_108 (50) = happyShift action_57
action_108 (55) = happyShift action_58
action_108 (56) = happyShift action_59
action_108 (57) = happyShift action_60
action_108 (63) = happyShift action_63
action_108 (64) = happyShift action_64
action_108 (66) = happyShift action_66
action_108 (67) = happyShift action_67
action_108 (26) = happyGoto action_134
action_108 (29) = happyGoto action_48
action_108 (30) = happyGoto action_49
action_108 _ = happyFail (happyExpListPerState 108)

action_109 (33) = happyShift action_50
action_109 (41) = happyShift action_52
action_109 (42) = happyShift action_53
action_109 (44) = happyShift action_54
action_109 (48) = happyShift action_56
action_109 (50) = happyShift action_57
action_109 (55) = happyShift action_58
action_109 (56) = happyShift action_59
action_109 (57) = happyShift action_60
action_109 (63) = happyShift action_63
action_109 (64) = happyShift action_64
action_109 (66) = happyShift action_66
action_109 (67) = happyShift action_67
action_109 (26) = happyGoto action_133
action_109 (29) = happyGoto action_48
action_109 (30) = happyGoto action_49
action_109 _ = happyFail (happyExpListPerState 109)

action_110 (33) = happyShift action_50
action_110 (41) = happyShift action_52
action_110 (42) = happyShift action_53
action_110 (44) = happyShift action_54
action_110 (48) = happyShift action_56
action_110 (50) = happyShift action_57
action_110 (55) = happyShift action_58
action_110 (56) = happyShift action_59
action_110 (57) = happyShift action_60
action_110 (63) = happyShift action_63
action_110 (64) = happyShift action_64
action_110 (66) = happyShift action_66
action_110 (67) = happyShift action_67
action_110 (26) = happyGoto action_132
action_110 (29) = happyGoto action_48
action_110 (30) = happyGoto action_49
action_110 _ = happyFail (happyExpListPerState 110)

action_111 (33) = happyShift action_50
action_111 (41) = happyShift action_52
action_111 (42) = happyShift action_53
action_111 (44) = happyShift action_54
action_111 (48) = happyShift action_56
action_111 (50) = happyShift action_57
action_111 (55) = happyShift action_58
action_111 (56) = happyShift action_59
action_111 (57) = happyShift action_60
action_111 (63) = happyShift action_63
action_111 (64) = happyShift action_64
action_111 (66) = happyShift action_66
action_111 (67) = happyShift action_67
action_111 (26) = happyGoto action_131
action_111 (29) = happyGoto action_48
action_111 (30) = happyGoto action_49
action_111 _ = happyFail (happyExpListPerState 111)

action_112 (33) = happyShift action_50
action_112 (41) = happyShift action_52
action_112 (42) = happyShift action_53
action_112 (44) = happyShift action_54
action_112 (48) = happyShift action_56
action_112 (50) = happyShift action_57
action_112 (55) = happyShift action_58
action_112 (56) = happyShift action_59
action_112 (57) = happyShift action_60
action_112 (63) = happyShift action_63
action_112 (64) = happyShift action_64
action_112 (66) = happyShift action_66
action_112 (67) = happyShift action_67
action_112 (26) = happyGoto action_130
action_112 (29) = happyGoto action_48
action_112 (30) = happyGoto action_49
action_112 _ = happyFail (happyExpListPerState 112)

action_113 (33) = happyShift action_50
action_113 (41) = happyShift action_52
action_113 (42) = happyShift action_53
action_113 (44) = happyShift action_54
action_113 (48) = happyShift action_56
action_113 (50) = happyShift action_57
action_113 (55) = happyShift action_58
action_113 (56) = happyShift action_59
action_113 (57) = happyShift action_60
action_113 (63) = happyShift action_63
action_113 (64) = happyShift action_64
action_113 (66) = happyShift action_66
action_113 (67) = happyShift action_67
action_113 (26) = happyGoto action_129
action_113 (29) = happyGoto action_48
action_113 (30) = happyGoto action_49
action_113 _ = happyFail (happyExpListPerState 113)

action_114 (33) = happyShift action_50
action_114 (41) = happyShift action_52
action_114 (42) = happyShift action_53
action_114 (44) = happyShift action_54
action_114 (48) = happyShift action_56
action_114 (50) = happyShift action_57
action_114 (55) = happyShift action_58
action_114 (56) = happyShift action_59
action_114 (57) = happyShift action_60
action_114 (63) = happyShift action_63
action_114 (64) = happyShift action_64
action_114 (66) = happyShift action_66
action_114 (67) = happyShift action_67
action_114 (26) = happyGoto action_128
action_114 (29) = happyGoto action_48
action_114 (30) = happyGoto action_49
action_114 _ = happyFail (happyExpListPerState 114)

action_115 (33) = happyShift action_50
action_115 (41) = happyShift action_52
action_115 (42) = happyShift action_53
action_115 (44) = happyShift action_54
action_115 (48) = happyShift action_56
action_115 (50) = happyShift action_57
action_115 (55) = happyShift action_58
action_115 (56) = happyShift action_59
action_115 (57) = happyShift action_60
action_115 (63) = happyShift action_63
action_115 (64) = happyShift action_64
action_115 (66) = happyShift action_66
action_115 (67) = happyShift action_67
action_115 (26) = happyGoto action_127
action_115 (29) = happyGoto action_48
action_115 (30) = happyGoto action_49
action_115 _ = happyFail (happyExpListPerState 115)

action_116 (33) = happyShift action_50
action_116 (41) = happyShift action_52
action_116 (42) = happyShift action_53
action_116 (44) = happyShift action_54
action_116 (48) = happyShift action_56
action_116 (50) = happyShift action_57
action_116 (55) = happyShift action_58
action_116 (56) = happyShift action_59
action_116 (57) = happyShift action_60
action_116 (63) = happyShift action_63
action_116 (64) = happyShift action_64
action_116 (66) = happyShift action_66
action_116 (67) = happyShift action_67
action_116 (26) = happyGoto action_126
action_116 (29) = happyGoto action_48
action_116 (30) = happyGoto action_49
action_116 _ = happyFail (happyExpListPerState 116)

action_117 (33) = happyShift action_50
action_117 (41) = happyShift action_52
action_117 (42) = happyShift action_53
action_117 (44) = happyShift action_54
action_117 (48) = happyShift action_56
action_117 (50) = happyShift action_57
action_117 (55) = happyShift action_58
action_117 (56) = happyShift action_59
action_117 (57) = happyShift action_60
action_117 (63) = happyShift action_63
action_117 (64) = happyShift action_64
action_117 (66) = happyShift action_66
action_117 (67) = happyShift action_67
action_117 (26) = happyGoto action_125
action_117 (29) = happyGoto action_48
action_117 (30) = happyGoto action_49
action_117 _ = happyFail (happyExpListPerState 117)

action_118 _ = happyReduce_38

action_119 _ = happyReduce_39

action_120 _ = happyReduce_35

action_121 _ = happyReduce_33

action_122 _ = happyReduce_22

action_123 (53) = happyShift action_124
action_123 _ = happyReduce_31

action_124 (33) = happyShift action_50
action_124 (41) = happyShift action_52
action_124 (42) = happyShift action_53
action_124 (44) = happyShift action_54
action_124 (48) = happyShift action_56
action_124 (50) = happyShift action_57
action_124 (55) = happyShift action_58
action_124 (56) = happyShift action_59
action_124 (57) = happyShift action_60
action_124 (63) = happyShift action_63
action_124 (64) = happyShift action_64
action_124 (66) = happyShift action_66
action_124 (67) = happyShift action_67
action_124 (26) = happyGoto action_171
action_124 (29) = happyGoto action_48
action_124 (30) = happyGoto action_49
action_124 _ = happyFail (happyExpListPerState 124)

action_125 (31) = happyShift action_95
action_125 (32) = happyShift action_96
action_125 (35) = happyShift action_97
action_125 (48) = happyShift action_98
action_125 (49) = happyShift action_99
action_125 (50) = happyShift action_100
action_125 (51) = happyShift action_101
action_125 (52) = happyShift action_102
action_125 _ = happyReduce_77

action_126 (31) = happyShift action_95
action_126 (32) = happyShift action_96
action_126 (35) = happyShift action_97
action_126 (48) = happyShift action_98
action_126 (49) = happyShift action_99
action_126 (50) = happyShift action_100
action_126 (51) = happyShift action_101
action_126 (52) = happyShift action_102
action_126 _ = happyReduce_76

action_127 (31) = happyShift action_95
action_127 (32) = happyShift action_96
action_127 (35) = happyShift action_97
action_127 (48) = happyShift action_98
action_127 (49) = happyShift action_99
action_127 (50) = happyShift action_100
action_127 (51) = happyShift action_101
action_127 (52) = happyShift action_102
action_127 (62) = happyShift action_104
action_127 (73) = happyShift action_106
action_127 (74) = happyShift action_107
action_127 (75) = happyShift action_108
action_127 (76) = happyShift action_109
action_127 (77) = happyShift action_110
action_127 (78) = happyShift action_111
action_127 (81) = happyShift action_114
action_127 (83) = happyShift action_116
action_127 (84) = happyShift action_117
action_127 _ = happyReduce_79

action_128 (31) = happyShift action_95
action_128 (32) = happyShift action_96
action_128 (35) = happyShift action_97
action_128 (48) = happyShift action_98
action_128 (49) = happyShift action_99
action_128 (50) = happyShift action_100
action_128 (51) = happyShift action_101
action_128 (52) = happyShift action_102
action_128 (73) = happyShift action_106
action_128 (74) = happyShift action_107
action_128 (75) = happyShift action_108
action_128 (76) = happyShift action_109
action_128 (77) = happyShift action_110
action_128 (78) = happyShift action_111
action_128 (83) = happyShift action_116
action_128 (84) = happyShift action_117
action_128 _ = happyReduce_78

action_129 (31) = happyShift action_95
action_129 (32) = happyShift action_96
action_129 (35) = happyShift action_97
action_129 (48) = happyShift action_98
action_129 (49) = happyShift action_99
action_129 (50) = happyShift action_100
action_129 (51) = happyShift action_101
action_129 (52) = happyShift action_102
action_129 (62) = happyShift action_104
action_129 (73) = happyShift action_106
action_129 (74) = happyShift action_107
action_129 (75) = happyShift action_108
action_129 (76) = happyShift action_109
action_129 (77) = happyShift action_110
action_129 (78) = happyShift action_111
action_129 (79) = happyShift action_112
action_129 (81) = happyShift action_114
action_129 (82) = happyShift action_115
action_129 (83) = happyShift action_116
action_129 (84) = happyShift action_117
action_129 _ = happyReduce_82

action_130 (31) = happyShift action_95
action_130 (32) = happyShift action_96
action_130 (35) = happyShift action_97
action_130 (48) = happyShift action_98
action_130 (49) = happyShift action_99
action_130 (50) = happyShift action_100
action_130 (51) = happyShift action_101
action_130 (52) = happyShift action_102
action_130 (62) = happyShift action_104
action_130 (73) = happyShift action_106
action_130 (74) = happyShift action_107
action_130 (75) = happyShift action_108
action_130 (76) = happyShift action_109
action_130 (77) = happyShift action_110
action_130 (78) = happyShift action_111
action_130 (81) = happyShift action_114
action_130 (82) = happyShift action_115
action_130 (83) = happyShift action_116
action_130 (84) = happyShift action_117
action_130 _ = happyReduce_81

action_131 (31) = happyShift action_95
action_131 (32) = happyShift action_96
action_131 (35) = happyShift action_97
action_131 (48) = happyShift action_98
action_131 (49) = happyShift action_99
action_131 (50) = happyShift action_100
action_131 (51) = happyShift action_101
action_131 (52) = happyShift action_102
action_131 (73) = happyShift action_106
action_131 (74) = happyShift action_107
action_131 (75) = happyShift action_108
action_131 (76) = happyShift action_109
action_131 (83) = happyShift action_116
action_131 (84) = happyShift action_117
action_131 _ = happyReduce_88

action_132 (31) = happyShift action_95
action_132 (32) = happyShift action_96
action_132 (35) = happyShift action_97
action_132 (48) = happyShift action_98
action_132 (49) = happyShift action_99
action_132 (50) = happyShift action_100
action_132 (51) = happyShift action_101
action_132 (52) = happyShift action_102
action_132 (73) = happyShift action_106
action_132 (74) = happyShift action_107
action_132 (75) = happyShift action_108
action_132 (76) = happyShift action_109
action_132 (83) = happyShift action_116
action_132 (84) = happyShift action_117
action_132 _ = happyReduce_87

action_133 (31) = happyShift action_95
action_133 (32) = happyShift action_96
action_133 (35) = happyShift action_97
action_133 (48) = happyShift action_98
action_133 (49) = happyShift action_99
action_133 (50) = happyShift action_100
action_133 (51) = happyShift action_101
action_133 (52) = happyShift action_102
action_133 (83) = happyShift action_116
action_133 (84) = happyShift action_117
action_133 _ = happyReduce_84

action_134 (31) = happyShift action_95
action_134 (32) = happyShift action_96
action_134 (35) = happyShift action_97
action_134 (48) = happyShift action_98
action_134 (49) = happyShift action_99
action_134 (50) = happyShift action_100
action_134 (51) = happyShift action_101
action_134 (52) = happyShift action_102
action_134 (83) = happyShift action_116
action_134 (84) = happyShift action_117
action_134 _ = happyReduce_86

action_135 (31) = happyShift action_95
action_135 (32) = happyShift action_96
action_135 (35) = happyShift action_97
action_135 (48) = happyShift action_98
action_135 (49) = happyShift action_99
action_135 (50) = happyShift action_100
action_135 (51) = happyShift action_101
action_135 (52) = happyShift action_102
action_135 (83) = happyShift action_116
action_135 (84) = happyShift action_117
action_135 _ = happyReduce_85

action_136 (31) = happyShift action_95
action_136 (32) = happyShift action_96
action_136 (35) = happyShift action_97
action_136 (48) = happyShift action_98
action_136 (49) = happyShift action_99
action_136 (50) = happyShift action_100
action_136 (51) = happyShift action_101
action_136 (52) = happyShift action_102
action_136 (83) = happyShift action_116
action_136 (84) = happyShift action_117
action_136 _ = happyReduce_83

action_137 (31) = happyShift action_95
action_137 (32) = happyShift action_96
action_137 (35) = happyShift action_97
action_137 (48) = happyShift action_98
action_137 (49) = happyShift action_99
action_137 (50) = happyShift action_100
action_137 (51) = happyShift action_101
action_137 (52) = happyShift action_102
action_137 (62) = happyShift action_104
action_137 (71) = happyShift action_105
action_137 (72) = happyShift action_170
action_137 (73) = happyShift action_106
action_137 (74) = happyShift action_107
action_137 (75) = happyShift action_108
action_137 (76) = happyShift action_109
action_137 (77) = happyShift action_110
action_137 (78) = happyShift action_111
action_137 (79) = happyShift action_112
action_137 (80) = happyShift action_113
action_137 (81) = happyShift action_114
action_137 (82) = happyShift action_115
action_137 (83) = happyShift action_116
action_137 (84) = happyShift action_117
action_137 _ = happyFail (happyExpListPerState 137)

action_138 (31) = happyShift action_95
action_138 (32) = happyShift action_96
action_138 (35) = happyShift action_97
action_138 (48) = happyShift action_98
action_138 (49) = happyShift action_99
action_138 (50) = happyShift action_100
action_138 (51) = happyShift action_101
action_138 (52) = happyShift action_102
action_138 (73) = happyShift action_106
action_138 (74) = happyShift action_107
action_138 (75) = happyShift action_108
action_138 (76) = happyShift action_109
action_138 (77) = happyShift action_110
action_138 (78) = happyShift action_111
action_138 (81) = happyShift action_114
action_138 (83) = happyShift action_116
action_138 (84) = happyShift action_117
action_138 _ = happyReduce_80

action_139 (31) = happyShift action_95
action_139 (32) = happyShift action_96
action_139 (35) = happyShift action_97
action_139 (48) = happyShift action_98
action_139 (49) = happyShift action_99
action_139 (50) = happyShift action_100
action_139 (51) = happyShift action_101
action_139 (52) = happyShift action_102
action_139 (62) = happyShift action_104
action_139 (71) = happyShift action_105
action_139 (73) = happyShift action_106
action_139 (74) = happyShift action_107
action_139 (75) = happyShift action_108
action_139 (76) = happyShift action_109
action_139 (77) = happyShift action_110
action_139 (78) = happyShift action_111
action_139 (79) = happyShift action_112
action_139 (80) = happyShift action_113
action_139 (81) = happyShift action_114
action_139 (82) = happyShift action_115
action_139 (83) = happyShift action_116
action_139 (84) = happyShift action_117
action_139 _ = happyReduce_37

action_140 (31) = happyShift action_95
action_140 (32) = happyShift action_96
action_140 (35) = happyShift action_97
action_140 _ = happyReduce_75

action_141 (31) = happyShift action_95
action_141 (32) = happyShift action_96
action_141 (35) = happyShift action_97
action_141 _ = happyReduce_74

action_142 (31) = happyShift action_95
action_142 (32) = happyShift action_96
action_142 (35) = happyShift action_97
action_142 _ = happyReduce_73

action_143 (31) = happyShift action_95
action_143 (32) = happyShift action_96
action_143 (35) = happyShift action_97
action_143 (50) = happyShift action_100
action_143 (51) = happyShift action_101
action_143 (52) = happyShift action_102
action_143 _ = happyReduce_72

action_144 (31) = happyShift action_95
action_144 (32) = happyShift action_96
action_144 (35) = happyShift action_97
action_144 (50) = happyShift action_100
action_144 (51) = happyShift action_101
action_144 (52) = happyShift action_102
action_144 _ = happyReduce_71

action_145 (31) = happyShift action_95
action_145 (32) = happyShift action_96
action_145 (35) = happyShift action_97
action_145 (36) = happyShift action_169
action_145 (48) = happyShift action_98
action_145 (49) = happyShift action_99
action_145 (50) = happyShift action_100
action_145 (51) = happyShift action_101
action_145 (52) = happyShift action_102
action_145 (62) = happyShift action_104
action_145 (71) = happyShift action_105
action_145 (73) = happyShift action_106
action_145 (74) = happyShift action_107
action_145 (75) = happyShift action_108
action_145 (76) = happyShift action_109
action_145 (77) = happyShift action_110
action_145 (78) = happyShift action_111
action_145 (79) = happyShift action_112
action_145 (80) = happyShift action_113
action_145 (81) = happyShift action_114
action_145 (82) = happyShift action_115
action_145 (83) = happyShift action_116
action_145 (84) = happyShift action_117
action_145 _ = happyFail (happyExpListPerState 145)

action_146 _ = happyReduce_65

action_147 _ = happyReduce_64

action_148 _ = happyReduce_52

action_149 _ = happyReduce_36

action_150 (31) = happyShift action_95
action_150 (32) = happyShift action_96
action_150 (35) = happyShift action_97
action_150 (40) = happyShift action_168
action_150 (48) = happyShift action_98
action_150 (49) = happyShift action_99
action_150 (50) = happyShift action_100
action_150 (51) = happyShift action_101
action_150 (52) = happyShift action_102
action_150 (62) = happyShift action_104
action_150 (71) = happyShift action_105
action_150 (73) = happyShift action_106
action_150 (74) = happyShift action_107
action_150 (75) = happyShift action_108
action_150 (76) = happyShift action_109
action_150 (77) = happyShift action_110
action_150 (78) = happyShift action_111
action_150 (79) = happyShift action_112
action_150 (80) = happyShift action_113
action_150 (81) = happyShift action_114
action_150 (82) = happyShift action_115
action_150 (83) = happyShift action_116
action_150 (84) = happyShift action_117
action_150 (27) = happyGoto action_167
action_150 _ = happyReduce_67

action_151 _ = happyReduce_69

action_152 _ = happyReduce_49

action_153 (34) = happyShift action_166
action_153 _ = happyFail (happyExpListPerState 153)

action_154 (40) = happyShift action_165
action_154 _ = happyFail (happyExpListPerState 154)

action_155 (31) = happyShift action_95
action_155 (32) = happyShift action_96
action_155 (34) = happyShift action_164
action_155 (35) = happyShift action_97
action_155 (48) = happyShift action_98
action_155 (49) = happyShift action_99
action_155 (50) = happyShift action_100
action_155 (51) = happyShift action_101
action_155 (52) = happyShift action_102
action_155 (62) = happyShift action_104
action_155 (71) = happyShift action_105
action_155 (73) = happyShift action_106
action_155 (74) = happyShift action_107
action_155 (75) = happyShift action_108
action_155 (76) = happyShift action_109
action_155 (77) = happyShift action_110
action_155 (78) = happyShift action_111
action_155 (79) = happyShift action_112
action_155 (80) = happyShift action_113
action_155 (81) = happyShift action_114
action_155 (82) = happyShift action_115
action_155 (83) = happyShift action_116
action_155 (84) = happyShift action_117
action_155 _ = happyFail (happyExpListPerState 155)

action_156 (31) = happyShift action_95
action_156 (32) = happyShift action_96
action_156 (34) = happyShift action_163
action_156 (35) = happyShift action_97
action_156 (48) = happyShift action_98
action_156 (49) = happyShift action_99
action_156 (50) = happyShift action_100
action_156 (51) = happyShift action_101
action_156 (52) = happyShift action_102
action_156 (62) = happyShift action_104
action_156 (71) = happyShift action_105
action_156 (73) = happyShift action_106
action_156 (74) = happyShift action_107
action_156 (75) = happyShift action_108
action_156 (76) = happyShift action_109
action_156 (77) = happyShift action_110
action_156 (78) = happyShift action_111
action_156 (79) = happyShift action_112
action_156 (80) = happyShift action_113
action_156 (81) = happyShift action_114
action_156 (82) = happyShift action_115
action_156 (83) = happyShift action_116
action_156 (84) = happyShift action_117
action_156 _ = happyFail (happyExpListPerState 156)

action_157 _ = happyReduce_43

action_158 (39) = happyShift action_162
action_158 _ = happyFail (happyExpListPerState 158)

action_159 (31) = happyShift action_95
action_159 (32) = happyShift action_96
action_159 (34) = happyShift action_161
action_159 (35) = happyShift action_97
action_159 (48) = happyShift action_98
action_159 (49) = happyShift action_99
action_159 (50) = happyShift action_100
action_159 (51) = happyShift action_101
action_159 (52) = happyShift action_102
action_159 (62) = happyShift action_104
action_159 (71) = happyShift action_105
action_159 (73) = happyShift action_106
action_159 (74) = happyShift action_107
action_159 (75) = happyShift action_108
action_159 (76) = happyShift action_109
action_159 (77) = happyShift action_110
action_159 (78) = happyShift action_111
action_159 (79) = happyShift action_112
action_159 (80) = happyShift action_113
action_159 (81) = happyShift action_114
action_159 (82) = happyShift action_115
action_159 (83) = happyShift action_116
action_159 (84) = happyShift action_117
action_159 _ = happyFail (happyExpListPerState 159)

action_160 _ = happyReduce_13

action_161 (33) = happyShift action_50
action_161 (37) = happyShift action_51
action_161 (41) = happyShift action_52
action_161 (42) = happyShift action_53
action_161 (43) = happyShift action_10
action_161 (44) = happyShift action_54
action_161 (45) = happyShift action_55
action_161 (46) = happyShift action_11
action_161 (47) = happyShift action_12
action_161 (48) = happyShift action_56
action_161 (50) = happyShift action_57
action_161 (55) = happyShift action_58
action_161 (56) = happyShift action_59
action_161 (57) = happyShift action_60
action_161 (58) = happyShift action_18
action_161 (60) = happyShift action_61
action_161 (61) = happyShift action_62
action_161 (63) = happyShift action_63
action_161 (64) = happyShift action_64
action_161 (65) = happyShift action_65
action_161 (66) = happyShift action_66
action_161 (67) = happyShift action_67
action_161 (68) = happyShift action_15
action_161 (69) = happyShift action_68
action_161 (18) = happyGoto action_41
action_161 (19) = happyGoto action_42
action_161 (21) = happyGoto action_179
action_161 (22) = happyGoto action_45
action_161 (25) = happyGoto action_46
action_161 (26) = happyGoto action_47
action_161 (29) = happyGoto action_48
action_161 (30) = happyGoto action_49
action_161 _ = happyFail (happyExpListPerState 161)

action_162 (33) = happyShift action_50
action_162 (41) = happyShift action_52
action_162 (42) = happyShift action_53
action_162 (44) = happyShift action_54
action_162 (48) = happyShift action_56
action_162 (50) = happyShift action_57
action_162 (55) = happyShift action_58
action_162 (56) = happyShift action_59
action_162 (57) = happyShift action_60
action_162 (63) = happyShift action_63
action_162 (64) = happyShift action_64
action_162 (66) = happyShift action_66
action_162 (67) = happyShift action_67
action_162 (26) = happyGoto action_178
action_162 (29) = happyGoto action_48
action_162 (30) = happyGoto action_49
action_162 _ = happyFail (happyExpListPerState 162)

action_163 (33) = happyShift action_50
action_163 (37) = happyShift action_51
action_163 (41) = happyShift action_52
action_163 (42) = happyShift action_53
action_163 (43) = happyShift action_10
action_163 (44) = happyShift action_54
action_163 (45) = happyShift action_55
action_163 (46) = happyShift action_11
action_163 (47) = happyShift action_12
action_163 (48) = happyShift action_56
action_163 (50) = happyShift action_57
action_163 (55) = happyShift action_58
action_163 (56) = happyShift action_59
action_163 (57) = happyShift action_60
action_163 (58) = happyShift action_18
action_163 (60) = happyShift action_61
action_163 (61) = happyShift action_62
action_163 (63) = happyShift action_63
action_163 (64) = happyShift action_64
action_163 (65) = happyShift action_65
action_163 (66) = happyShift action_66
action_163 (67) = happyShift action_67
action_163 (68) = happyShift action_15
action_163 (69) = happyShift action_68
action_163 (18) = happyGoto action_41
action_163 (19) = happyGoto action_42
action_163 (21) = happyGoto action_177
action_163 (22) = happyGoto action_45
action_163 (25) = happyGoto action_46
action_163 (26) = happyGoto action_47
action_163 (29) = happyGoto action_48
action_163 (30) = happyGoto action_49
action_163 _ = happyFail (happyExpListPerState 163)

action_164 (39) = happyShift action_176
action_164 _ = happyFail (happyExpListPerState 164)

action_165 (33) = happyShift action_50
action_165 (41) = happyShift action_52
action_165 (42) = happyShift action_53
action_165 (44) = happyShift action_54
action_165 (48) = happyShift action_56
action_165 (50) = happyShift action_57
action_165 (55) = happyShift action_58
action_165 (56) = happyShift action_59
action_165 (57) = happyShift action_60
action_165 (63) = happyShift action_63
action_165 (64) = happyShift action_64
action_165 (66) = happyShift action_66
action_165 (67) = happyShift action_67
action_165 (26) = happyGoto action_175
action_165 (29) = happyGoto action_48
action_165 (30) = happyGoto action_49
action_165 _ = happyFail (happyExpListPerState 165)

action_166 _ = happyReduce_61

action_167 (34) = happyShift action_174
action_167 _ = happyFail (happyExpListPerState 167)

action_168 (33) = happyShift action_50
action_168 (41) = happyShift action_52
action_168 (42) = happyShift action_53
action_168 (44) = happyShift action_54
action_168 (48) = happyShift action_56
action_168 (50) = happyShift action_57
action_168 (55) = happyShift action_58
action_168 (56) = happyShift action_59
action_168 (57) = happyShift action_60
action_168 (63) = happyShift action_63
action_168 (64) = happyShift action_64
action_168 (66) = happyShift action_66
action_168 (67) = happyShift action_67
action_168 (26) = happyGoto action_173
action_168 (29) = happyGoto action_48
action_168 (30) = happyGoto action_49
action_168 _ = happyFail (happyExpListPerState 168)

action_169 _ = happyReduce_63

action_170 (33) = happyShift action_50
action_170 (41) = happyShift action_52
action_170 (42) = happyShift action_53
action_170 (44) = happyShift action_54
action_170 (48) = happyShift action_56
action_170 (50) = happyShift action_57
action_170 (55) = happyShift action_58
action_170 (56) = happyShift action_59
action_170 (57) = happyShift action_60
action_170 (63) = happyShift action_63
action_170 (64) = happyShift action_64
action_170 (66) = happyShift action_66
action_170 (67) = happyShift action_67
action_170 (26) = happyGoto action_172
action_170 (29) = happyGoto action_48
action_170 (30) = happyGoto action_49
action_170 _ = happyFail (happyExpListPerState 170)

action_171 (31) = happyShift action_95
action_171 (32) = happyShift action_96
action_171 (35) = happyShift action_97
action_171 (48) = happyShift action_98
action_171 (49) = happyShift action_99
action_171 (50) = happyShift action_100
action_171 (51) = happyShift action_101
action_171 (52) = happyShift action_102
action_171 (62) = happyShift action_104
action_171 (71) = happyShift action_105
action_171 (73) = happyShift action_106
action_171 (74) = happyShift action_107
action_171 (75) = happyShift action_108
action_171 (76) = happyShift action_109
action_171 (77) = happyShift action_110
action_171 (78) = happyShift action_111
action_171 (79) = happyShift action_112
action_171 (80) = happyShift action_113
action_171 (81) = happyShift action_114
action_171 (82) = happyShift action_115
action_171 (83) = happyShift action_116
action_171 (84) = happyShift action_117
action_171 _ = happyReduce_30

action_172 (31) = happyShift action_95
action_172 (32) = happyShift action_96
action_172 (35) = happyShift action_97
action_172 (48) = happyShift action_98
action_172 (49) = happyShift action_99
action_172 (50) = happyShift action_100
action_172 (51) = happyShift action_101
action_172 (52) = happyShift action_102
action_172 (62) = happyShift action_104
action_172 (71) = happyShift action_105
action_172 (73) = happyShift action_106
action_172 (74) = happyShift action_107
action_172 (75) = happyShift action_108
action_172 (76) = happyShift action_109
action_172 (77) = happyShift action_110
action_172 (78) = happyShift action_111
action_172 (79) = happyShift action_112
action_172 (80) = happyShift action_113
action_172 (81) = happyShift action_114
action_172 (82) = happyShift action_115
action_172 (83) = happyShift action_116
action_172 (84) = happyShift action_117
action_172 _ = happyReduce_53

action_173 (31) = happyShift action_95
action_173 (32) = happyShift action_96
action_173 (35) = happyShift action_97
action_173 (40) = happyShift action_168
action_173 (48) = happyShift action_98
action_173 (49) = happyShift action_99
action_173 (50) = happyShift action_100
action_173 (51) = happyShift action_101
action_173 (52) = happyShift action_102
action_173 (62) = happyShift action_104
action_173 (71) = happyShift action_105
action_173 (73) = happyShift action_106
action_173 (74) = happyShift action_107
action_173 (75) = happyShift action_108
action_173 (76) = happyShift action_109
action_173 (77) = happyShift action_110
action_173 (78) = happyShift action_111
action_173 (79) = happyShift action_112
action_173 (80) = happyShift action_113
action_173 (81) = happyShift action_114
action_173 (82) = happyShift action_115
action_173 (83) = happyShift action_116
action_173 (84) = happyShift action_117
action_173 (27) = happyGoto action_184
action_173 _ = happyReduce_67

action_174 _ = happyReduce_70

action_175 (31) = happyShift action_95
action_175 (32) = happyShift action_96
action_175 (34) = happyShift action_183
action_175 (35) = happyShift action_97
action_175 (48) = happyShift action_98
action_175 (49) = happyShift action_99
action_175 (50) = happyShift action_100
action_175 (51) = happyShift action_101
action_175 (52) = happyShift action_102
action_175 (62) = happyShift action_104
action_175 (71) = happyShift action_105
action_175 (73) = happyShift action_106
action_175 (74) = happyShift action_107
action_175 (75) = happyShift action_108
action_175 (76) = happyShift action_109
action_175 (77) = happyShift action_110
action_175 (78) = happyShift action_111
action_175 (79) = happyShift action_112
action_175 (80) = happyShift action_113
action_175 (81) = happyShift action_114
action_175 (82) = happyShift action_115
action_175 (83) = happyShift action_116
action_175 (84) = happyShift action_117
action_175 _ = happyFail (happyExpListPerState 175)

action_176 _ = happyReduce_51

action_177 _ = happyReduce_47

action_178 (31) = happyShift action_95
action_178 (32) = happyShift action_96
action_178 (35) = happyShift action_97
action_178 (39) = happyShift action_182
action_178 (48) = happyShift action_98
action_178 (49) = happyShift action_99
action_178 (50) = happyShift action_100
action_178 (51) = happyShift action_101
action_178 (52) = happyShift action_102
action_178 (62) = happyShift action_104
action_178 (71) = happyShift action_105
action_178 (73) = happyShift action_106
action_178 (74) = happyShift action_107
action_178 (75) = happyShift action_108
action_178 (76) = happyShift action_109
action_178 (77) = happyShift action_110
action_178 (78) = happyShift action_111
action_178 (79) = happyShift action_112
action_178 (80) = happyShift action_113
action_178 (81) = happyShift action_114
action_178 (82) = happyShift action_115
action_178 (83) = happyShift action_116
action_178 (84) = happyShift action_117
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (70) = happyShift action_181
action_179 (24) = happyGoto action_180
action_179 _ = happyReduce_46

action_180 _ = happyReduce_45

action_181 (33) = happyShift action_50
action_181 (37) = happyShift action_51
action_181 (41) = happyShift action_52
action_181 (42) = happyShift action_53
action_181 (43) = happyShift action_10
action_181 (44) = happyShift action_54
action_181 (45) = happyShift action_55
action_181 (46) = happyShift action_11
action_181 (47) = happyShift action_12
action_181 (48) = happyShift action_56
action_181 (50) = happyShift action_57
action_181 (55) = happyShift action_58
action_181 (56) = happyShift action_59
action_181 (57) = happyShift action_60
action_181 (58) = happyShift action_18
action_181 (60) = happyShift action_61
action_181 (61) = happyShift action_62
action_181 (63) = happyShift action_63
action_181 (64) = happyShift action_64
action_181 (65) = happyShift action_65
action_181 (66) = happyShift action_66
action_181 (67) = happyShift action_67
action_181 (68) = happyShift action_15
action_181 (69) = happyShift action_68
action_181 (18) = happyGoto action_41
action_181 (19) = happyGoto action_42
action_181 (21) = happyGoto action_186
action_181 (22) = happyGoto action_45
action_181 (25) = happyGoto action_46
action_181 (26) = happyGoto action_47
action_181 (29) = happyGoto action_48
action_181 (30) = happyGoto action_49
action_181 _ = happyFail (happyExpListPerState 181)

action_182 (33) = happyShift action_50
action_182 (41) = happyShift action_52
action_182 (42) = happyShift action_53
action_182 (43) = happyShift action_10
action_182 (44) = happyShift action_54
action_182 (46) = happyShift action_11
action_182 (47) = happyShift action_12
action_182 (48) = happyShift action_56
action_182 (50) = happyShift action_57
action_182 (55) = happyShift action_58
action_182 (56) = happyShift action_59
action_182 (57) = happyShift action_60
action_182 (58) = happyShift action_18
action_182 (63) = happyShift action_63
action_182 (64) = happyShift action_64
action_182 (66) = happyShift action_66
action_182 (67) = happyShift action_67
action_182 (68) = happyShift action_15
action_182 (18) = happyGoto action_41
action_182 (19) = happyGoto action_42
action_182 (22) = happyGoto action_157
action_182 (23) = happyGoto action_185
action_182 (26) = happyGoto action_47
action_182 (29) = happyGoto action_48
action_182 (30) = happyGoto action_49
action_182 _ = happyReduce_42

action_183 _ = happyReduce_62

action_184 _ = happyReduce_68

action_185 (34) = happyShift action_187
action_185 _ = happyFail (happyExpListPerState 185)

action_186 _ = happyReduce_44

action_187 (33) = happyShift action_50
action_187 (37) = happyShift action_51
action_187 (41) = happyShift action_52
action_187 (42) = happyShift action_53
action_187 (43) = happyShift action_10
action_187 (44) = happyShift action_54
action_187 (45) = happyShift action_55
action_187 (46) = happyShift action_11
action_187 (47) = happyShift action_12
action_187 (48) = happyShift action_56
action_187 (50) = happyShift action_57
action_187 (55) = happyShift action_58
action_187 (56) = happyShift action_59
action_187 (57) = happyShift action_60
action_187 (58) = happyShift action_18
action_187 (60) = happyShift action_61
action_187 (61) = happyShift action_62
action_187 (63) = happyShift action_63
action_187 (64) = happyShift action_64
action_187 (65) = happyShift action_65
action_187 (66) = happyShift action_66
action_187 (67) = happyShift action_67
action_187 (68) = happyShift action_15
action_187 (69) = happyShift action_68
action_187 (18) = happyGoto action_41
action_187 (19) = happyGoto action_42
action_187 (21) = happyGoto action_188
action_187 (22) = happyGoto action_45
action_187 (25) = happyGoto action_46
action_187 (26) = happyGoto action_47
action_187 (29) = happyGoto action_48
action_187 (30) = happyGoto action_49
action_187 _ = happyFail (happyExpListPerState 187)

action_188 _ = happyReduce_48

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (Program happy_var_1
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_0  5 happyReduction_2
happyReduction_2  =  HappyAbsSyn5
		 ([]
	)

happyReduce_3 = happySpecReduce_2  5 happyReduction_3
happyReduction_3 (HappyAbsSyn5  happy_var_2)
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1 : happy_var_2
	)
happyReduction_3 _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_1  6 happyReduction_4
happyReduction_4 (HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_4 _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_1  6 happyReduction_5
happyReduction_5 (HappyAbsSyn8  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_5 _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_1  6 happyReduction_6
happyReduction_6 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_6 _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_1  6 happyReduction_7
happyReduction_7 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_7 _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_1  6 happyReduction_8
happyReduction_8 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_8 _  = notHappyAtAll 

happyReduce_9 = happyReduce 4 7 happyReduction_9
happyReduction_9 (_ `HappyStk`
	(HappyAbsSyn11  happy_var_3) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (Fdecl happy_var_1 happy_var_2 happy_var_3
	) `HappyStk` happyRest

happyReduce_10 = happyReduce 4 8 happyReduction_10
happyReduction_10 ((HappyAbsSyn17  happy_var_4) `HappyStk`
	(HappyAbsSyn11  happy_var_3) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn8
		 (Fdefn happy_var_1 happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_11 = happySpecReduce_2  9 happyReduction_11
happyReduction_11 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn9
		 ((happy_var_1,happy_var_2)
	)
happyReduction_11 _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_0  10 happyReduction_12
happyReduction_12  =  HappyAbsSyn10
		 ([]
	)

happyReduce_13 = happySpecReduce_3  10 happyReduction_13
happyReduction_13 (HappyAbsSyn10  happy_var_3)
	(HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn10
		 (happy_var_2 : happy_var_3
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_2  11 happyReduction_14
happyReduction_14 _
	_
	 =  HappyAbsSyn11
		 ([]
	)

happyReduce_15 = happyReduce 4 11 happyReduction_15
happyReduction_15 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	(HappyAbsSyn9  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn11
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest

happyReduce_16 = happySpecReduce_3  12 happyReduction_16
happyReduction_16 _
	(HappyTerminal (TokIdent happy_var_2))
	_
	 =  HappyAbsSyn12
		 (Sdecl happy_var_2
	)
happyReduction_16 _ _ _  = notHappyAtAll 

happyReduce_17 = happyReduce 6 13 happyReduction_17
happyReduction_17 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn15  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (Sdef happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_18 = happySpecReduce_3  14 happyReduction_18
happyReduction_18 _
	(HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn14
		 ((happy_var_1, happy_var_2)
	)
happyReduction_18 _ _ _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_0  15 happyReduction_19
happyReduction_19  =  HappyAbsSyn15
		 ([]
	)

happyReduce_20 = happySpecReduce_2  15 happyReduction_20
happyReduction_20 (HappyAbsSyn15  happy_var_2)
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1 : happy_var_2
	)
happyReduction_20 _ _  = notHappyAtAll 

happyReduce_21 = happyMonadReduce 4 16 happyReduction_21
happyReduction_21 (_ `HappyStk`
	(HappyTerminal (TokIdent happy_var_3)) `HappyStk`
	(HappyAbsSyn18  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest) tk
	 = happyThen ((( typeDefHandle happy_var_2 happy_var_3))
	) (\r -> happyReturn (HappyAbsSyn16 r))

happyReduce_22 = happySpecReduce_3  17 happyReduction_22
happyReduction_22 _
	(HappyAbsSyn20  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (happy_var_2
	)
happyReduction_22 _ _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_1  18 happyReduction_23
happyReduction_23 _
	 =  HappyAbsSyn18
		 (INTEGER
	)

happyReduce_24 = happySpecReduce_1  18 happyReduction_24
happyReduction_24 _
	 =  HappyAbsSyn18
		 (BOOLEAN
	)

happyReduce_25 = happySpecReduce_1  18 happyReduction_25
happyReduction_25 (HappyTerminal (TokTypeIdent happy_var_1))
	 =  HappyAbsSyn18
		 (DEF happy_var_1
	)
happyReduction_25 _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_1  18 happyReduction_26
happyReduction_26 _
	 =  HappyAbsSyn18
		 (VOID
	)

happyReduce_27 = happySpecReduce_3  18 happyReduction_27
happyReduction_27 _
	_
	(HappyTerminal (TokTypeIdent happy_var_1))
	 =  HappyAbsSyn18
		 (ARRAY happy_var_1
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_2  18 happyReduction_28
happyReduction_28 _
	(HappyTerminal (TokTypeIdent happy_var_1))
	 =  HappyAbsSyn18
		 (POINTER happy_var_1
	)
happyReduction_28 _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_2  18 happyReduction_29
happyReduction_29 (HappyTerminal (TokIdent happy_var_2))
	_
	 =  HappyAbsSyn18
		 (STRUCT happy_var_2
	)
happyReduction_29 _ _  = notHappyAtAll 

happyReduce_30 = happyReduce 4 19 happyReduction_30
happyReduction_30 ((HappyAbsSyn26  happy_var_4) `HappyStk`
	(HappyTerminal (TokAsgnop happy_var_3)) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn19
		 (checkDeclAsgn happy_var_2 happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_31 = happySpecReduce_2  19 happyReduction_31
happyReduction_31 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn19
		 (JustDecl happy_var_2 happy_var_1
	)
happyReduction_31 _ _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_0  20 happyReduction_32
happyReduction_32  =  HappyAbsSyn20
		 ([]
	)

happyReduce_33 = happySpecReduce_2  20 happyReduction_33
happyReduction_33 (HappyAbsSyn20  happy_var_2)
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn20
		 (happy_var_1 : happy_var_2
	)
happyReduction_33 _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  21 happyReduction_34
happyReduction_34 (HappyAbsSyn25  happy_var_1)
	 =  HappyAbsSyn21
		 (ControlStmt happy_var_1
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_2  21 happyReduction_35
happyReduction_35 _
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn21
		 (Simp happy_var_1
	)
happyReduction_35 _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_3  21 happyReduction_36
happyReduction_36 _
	(HappyAbsSyn20  happy_var_2)
	_
	 =  HappyAbsSyn21
		 (Stmts happy_var_2
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  22 happyReduction_37
happyReduction_37 (HappyAbsSyn26  happy_var_3)
	(HappyTerminal (TokAsgnop happy_var_2))
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn22
		 (checkSimpAsgn happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_2  22 happyReduction_38
happyReduction_38 _
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn22
		 (checkSimpAsgnP happy_var_1 Incr
	)
happyReduction_38 _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_2  22 happyReduction_39
happyReduction_39 _
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn22
		 (checkSimpAsgnP happy_var_1 Decr
	)
happyReduction_39 _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  22 happyReduction_40
happyReduction_40 (HappyAbsSyn19  happy_var_1)
	 =  HappyAbsSyn22
		 (Decl happy_var_1
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_1  22 happyReduction_41
happyReduction_41 (HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn22
		 (Exp happy_var_1
	)
happyReduction_41 _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_0  23 happyReduction_42
happyReduction_42  =  HappyAbsSyn23
		 (SimpNop
	)

happyReduce_43 = happySpecReduce_1  23 happyReduction_43
happyReduction_43 (HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn23
		 (Opt happy_var_1
	)
happyReduction_43 _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_2  24 happyReduction_44
happyReduction_44 (HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn24
		 (Else happy_var_2
	)
happyReduction_44 _ _  = notHappyAtAll 

happyReduce_45 = happyReduce 6 25 happyReduction_45
happyReduction_45 ((HappyAbsSyn24  happy_var_6) `HappyStk`
	(HappyAbsSyn21  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn25
		 (Condition happy_var_3 happy_var_5 happy_var_6
	) `HappyStk` happyRest

happyReduce_46 = happyReduce 5 25 happyReduction_46
happyReduction_46 ((HappyAbsSyn21  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn25
		 (Condition happy_var_3 happy_var_5 (ElseNop)
	) `HappyStk` happyRest

happyReduce_47 = happyReduce 5 25 happyReduction_47
happyReduction_47 ((HappyAbsSyn21  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn25
		 (While happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_48 = happyReduce 9 25 happyReduction_48
happyReduction_48 ((HappyAbsSyn21  happy_var_9) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn25
		 (For happy_var_3 happy_var_5 happy_var_7 happy_var_9
	) `HappyStk` happyRest

happyReduce_49 = happySpecReduce_3  25 happyReduction_49
happyReduction_49 _
	(HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn25
		 (Retn happy_var_2
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_2  25 happyReduction_50
happyReduction_50 _
	_
	 =  HappyAbsSyn25
		 (Void
	)

happyReduce_51 = happyReduce 5 25 happyReduction_51
happyReduction_51 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn25
		 (Assert happy_var_3
	) `HappyStk` happyRest

happyReduce_52 = happySpecReduce_3  26 happyReduction_52
happyReduction_52 _
	(HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn26
		 (happy_var_2
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happyReduce 5 26 happyReduction_53
happyReduction_53 ((HappyAbsSyn26  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (Ternop happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_54 = happySpecReduce_1  26 happyReduction_54
happyReduction_54 _
	 =  HappyAbsSyn26
		 (T
	)

happyReduce_55 = happySpecReduce_1  26 happyReduction_55
happyReduction_55 _
	 =  HappyAbsSyn26
		 (F
	)

happyReduce_56 = happySpecReduce_1  26 happyReduction_56
happyReduction_56 _
	 =  HappyAbsSyn26
		 (NULL
	)

happyReduce_57 = happySpecReduce_1  26 happyReduction_57
happyReduction_57 (HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn26
		 (happy_var_1
	)
happyReduction_57 _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_1  26 happyReduction_58
happyReduction_58 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn26
		 (Ident happy_var_1
	)
happyReduction_58 _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_1  26 happyReduction_59
happyReduction_59 (HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn26
		 (happy_var_1
	)
happyReduction_59 _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_2  26 happyReduction_60
happyReduction_60 (HappyAbsSyn28  happy_var_2)
	(HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn26
		 (Function happy_var_1 happy_var_2
	)
happyReduction_60 _ _  = notHappyAtAll 

happyReduce_61 = happyReduce 4 26 happyReduction_61
happyReduction_61 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (Alloc happy_var_3
	) `HappyStk` happyRest

happyReduce_62 = happyReduce 6 26 happyReduction_62
happyReduction_62 (_ `HappyStk`
	(HappyAbsSyn26  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (ArrayAlloc happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_63 = happyReduce 4 26 happyReduction_63
happyReduction_63 (_ `HappyStk`
	(HappyAbsSyn26  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn26  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (ArrayAccess happy_var_1 happy_var_3
	) `HappyStk` happyRest

happyReduce_64 = happySpecReduce_3  26 happyReduction_64
happyReduction_64 (HappyTerminal (TokIdent happy_var_3))
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn26
		 (Field happy_var_1 happy_var_3
	)
happyReduction_64 _ _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_3  26 happyReduction_65
happyReduction_65 (HappyTerminal (TokIdent happy_var_3))
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn26
		 (Access happy_var_1 happy_var_3
	)
happyReduction_65 _ _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_2  26 happyReduction_66
happyReduction_66 (HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn26
		 (Ptrderef happy_var_2
	)
happyReduction_66 _ _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_0  27 happyReduction_67
happyReduction_67  =  HappyAbsSyn27
		 ([]
	)

happyReduce_68 = happySpecReduce_3  27 happyReduction_68
happyReduction_68 (HappyAbsSyn27  happy_var_3)
	(HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn27
		 (happy_var_2 : happy_var_3
	)
happyReduction_68 _ _ _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_2  28 happyReduction_69
happyReduction_69 _
	_
	 =  HappyAbsSyn28
		 ([]
	)

happyReduce_70 = happyReduce 4 28 happyReduction_70
happyReduction_70 (_ `HappyStk`
	(HappyAbsSyn27  happy_var_3) `HappyStk`
	(HappyAbsSyn26  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest

happyReduce_71 = happySpecReduce_3  29 happyReduction_71
happyReduction_71 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Sub happy_var_1 happy_var_3
	)
happyReduction_71 _ _ _  = notHappyAtAll 

happyReduce_72 = happySpecReduce_3  29 happyReduction_72
happyReduction_72 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Add happy_var_1 happy_var_3
	)
happyReduction_72 _ _ _  = notHappyAtAll 

happyReduce_73 = happySpecReduce_3  29 happyReduction_73
happyReduction_73 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Mul happy_var_1 happy_var_3
	)
happyReduction_73 _ _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_3  29 happyReduction_74
happyReduction_74 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Div happy_var_1 happy_var_3
	)
happyReduction_74 _ _ _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_3  29 happyReduction_75
happyReduction_75 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Mod happy_var_1 happy_var_3
	)
happyReduction_75 _ _ _  = notHappyAtAll 

happyReduce_76 = happySpecReduce_3  29 happyReduction_76
happyReduction_76 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Sal happy_var_1 happy_var_3
	)
happyReduction_76 _ _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_3  29 happyReduction_77
happyReduction_77 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Sar happy_var_1 happy_var_3
	)
happyReduction_77 _ _ _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_3  29 happyReduction_78
happyReduction_78 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop BAnd happy_var_1 happy_var_3
	)
happyReduction_78 _ _ _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_3  29 happyReduction_79
happyReduction_79 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop BOr happy_var_1 happy_var_3
	)
happyReduction_79 _ _ _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_3  29 happyReduction_80
happyReduction_80 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Xor happy_var_1 happy_var_3
	)
happyReduction_80 _ _ _  = notHappyAtAll 

happyReduce_81 = happySpecReduce_3  29 happyReduction_81
happyReduction_81 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop LAnd happy_var_1 happy_var_3
	)
happyReduction_81 _ _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_3  29 happyReduction_82
happyReduction_82 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop LOr happy_var_1 happy_var_3
	)
happyReduction_82 _ _ _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_3  29 happyReduction_83
happyReduction_83 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Lt happy_var_1 happy_var_3
	)
happyReduction_83 _ _ _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_3  29 happyReduction_84
happyReduction_84 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Le happy_var_1 happy_var_3
	)
happyReduction_84 _ _ _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_3  29 happyReduction_85
happyReduction_85 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Gt happy_var_1 happy_var_3
	)
happyReduction_85 _ _ _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_3  29 happyReduction_86
happyReduction_86 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Ge happy_var_1 happy_var_3
	)
happyReduction_86 _ _ _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_3  29 happyReduction_87
happyReduction_87 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Eql happy_var_1 happy_var_3
	)
happyReduction_87 _ _ _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_3  29 happyReduction_88
happyReduction_88 (HappyAbsSyn26  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn29
		 (Binop Neq happy_var_1 happy_var_3
	)
happyReduction_88 _ _ _  = notHappyAtAll 

happyReduce_89 = happySpecReduce_2  29 happyReduction_89
happyReduction_89 (HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn29
		 (Unop LNot happy_var_2
	)
happyReduction_89 _ _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_2  29 happyReduction_90
happyReduction_90 (HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn29
		 (Unop BNot happy_var_2
	)
happyReduction_90 _ _  = notHappyAtAll 

happyReduce_91 = happySpecReduce_2  29 happyReduction_91
happyReduction_91 (HappyAbsSyn26  happy_var_2)
	_
	 =  HappyAbsSyn29
		 (Unop Neg happy_var_2
	)
happyReduction_91 _ _  = notHappyAtAll 

happyReduce_92 = happySpecReduce_1  30 happyReduction_92
happyReduction_92 (HappyTerminal (TokDec happy_var_1))
	 =  HappyAbsSyn30
		 (checkDec happy_var_1
	)
happyReduction_92 _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_1  30 happyReduction_93
happyReduction_93 (HappyTerminal (TokHex happy_var_1))
	 =  HappyAbsSyn30
		 (checkHex happy_var_1
	)
happyReduction_93 _  = notHappyAtAll 

happyNewToken action sts stk
	= lexTokens(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	TokEOF -> action 87 87 tk (HappyState action) sts stk;
	TokField -> cont 31;
	TokAccess -> cont 32;
	TokLParen -> cont 33;
	TokRParen -> cont 34;
	TokLBracket -> cont 35;
	TokRBracket -> cont 36;
	TokLBrace -> cont 37;
	TokRBrace -> cont 38;
	TokSemi -> cont 39;
	TokComma -> cont 40;
	TokDec happy_dollar_dollar -> cont 41;
	TokHex happy_dollar_dollar -> cont 42;
	TokTypeIdent happy_dollar_dollar -> cont 43;
	TokIdent happy_dollar_dollar -> cont 44;
	TokReturn -> cont 45;
	TokInt -> cont 46;
	TokVoid -> cont 47;
	TokMinus -> cont 48;
	TokPlus -> cont 49;
	TokTimes -> cont 50;
	TokDiv -> cont 51;
	TokMod -> cont 52;
	TokAsgnop happy_dollar_dollar -> cont 53;
	TokReserved -> cont 54;
	TokNULL -> cont 55;
	TokAlloc -> cont 56;
	TokArrayAlloc -> cont 57;
	TokStruct -> cont 58;
	TokTypeDef -> cont 59;
	TokAssert -> cont 60;
	TokWhile -> cont 61;
	TokXor -> cont 62;
	TokUnop LNot -> cont 63;
	TokUnop BNot -> cont 64;
	TokFor -> cont 65;
	TokTrue -> cont 66;
	TokFalse -> cont 67;
	TokBool -> cont 68;
	TokIf -> cont 69;
	TokElse -> cont 70;
	TokTIf -> cont 71;
	TokTElse -> cont 72;
	TokLess -> cont 73;
	TokGreater -> cont 74;
	TokGeq -> cont 75;
	TokLeq -> cont 76;
	TokBoolEq -> cont 77;
	TokNotEq -> cont 78;
	TokBoolAnd -> cont 79;
	TokBoolOr -> cont 80;
	TokAnd -> cont 81;
	TokOr -> cont 82;
	TokLshift -> cont 83;
	TokRshift -> cont 84;
	TokIncr -> cont 85;
	TokDecr -> cont 86;
	_ -> happyError' (tk, [])
	})

happyError_ explist 87 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen = (>>=)
happyReturn :: () => a -> Alex a
happyReturn = (return)
happyThen1 :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen1 = happyThen
happyReturn1 :: () => a -> Alex a
happyReturn1 = happyReturn
happyError' :: () => ((Token), [String]) -> Alex a
happyError' tk = (\(tokens, _) -> parseError tokens) tk
parseTokens = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


lexTokens :: (Token -> Alex a) -> Alex a
lexTokens cont = do
      token <- alexMonadScan
      case token of
            TokIdent s -> let
                        Alex Right(_, defset) = getDefinedSet
                  in
                        if(Set.member s defset) then cont (TokTypeIdent s)
                        else cont (TokIdent s)
            _ -> cont token

parseError :: [Token] -> Alex a
parseError t = alexError ("Parse Error " ++ (show t))

typeDefHandle :: Type -> Ident -> Gdecl 
typeDefHandle tp name = do
      addDefinedState name 
      return $ TypeDef tp name

checkSimpAsgn :: Exp -> Asnop -> Exp -> Simp
checkSimpAsgn id op e =
    case id of
        Ident _ -> Asgn id op e
        Ptrderef _ -> Asgn id op e
        Access _ _ -> Asgn id op e
        Field _ _ -> Asgn id op e
        ArrayAccess _ _ -> Asgn id op e
        _ -> error "Invalid assignment to non variables"

checkSimpAsgnP :: Exp -> Postop -> Simp
checkSimpAsgnP id op =
    case id of
        Ident _ -> AsgnP id op
        Ptrderef _ -> AsgnP id op
        Access _ _ -> AsgnP id op
        Field _ _ -> AsgnP id op
        ArrayAccess _ _ -> AsgnP id op
        _ -> error "Invalid postop assignment to non variables"

checkDeclAsgn :: Ident -> Asnop -> Type -> Exp -> Decl
checkDeclAsgn v op tp e =
  case op of
    Equal -> DeclAsgn v tp e
    _ -> error "Invalid assignment operator on a declaration"

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)

parseInput input = runAlex input parseTokens
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

