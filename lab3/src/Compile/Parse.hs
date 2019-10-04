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

data HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25
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

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,684) ([0,0,8242,64,0,0,0,0,0,0,0,0,0,0,0,32768,2060,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,12,16,0,0,0,0,0,0,0,8,0,0,0,32,0,0,0,0,0,0,0,0,2048,0,0,0,0,51216,0,1,0,0,2,0,0,0,0,0,0,0,0,64,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,35328,32891,254,0,0,2048,0,0,0,0,0,0,0,0,1024,0,0,0,0,31626,65152,0,0,32768,0,0,0,0,0,0,0,0,0,61440,32835,32766,0,0,0,0,0,0,0,0,0,0,8192,1080,864,0,0,57984,40990,63,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,32768,4328,3456,0,0,33280,67,54,0,0,8,0,0,0,8192,1080,864,0,0,57472,32784,13,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,16,0,0,0,0,800,1024,0,0,4096,0,0,0,0,0,0,0,0,2048,270,216,0,0,14368,24583,7,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,8192,1080,864,0,0,0,0,0,0,0,49184,263,32762,0,0,0,0,0,0,0,0,0,0,32768,4321,3456,0,0,4096,0,0,0,0,16,1055,65512,1,8192,1080,864,0,0,57472,32784,13,0,0,17282,13824,0,0,2048,270,216,0,0,14368,24580,3,0,32768,4320,3456,0,0,33280,67,54,0,0,3592,55297,0,0,8192,1080,864,0,0,57472,32784,13,0,0,17282,13824,0,0,2048,270,216,0,0,14368,24580,3,0,32768,4320,3456,0,0,33280,67,54,0,0,3592,55297,0,0,8192,1080,864,0,0,57472,32784,13,0,0,17282,13824,0,0,2048,270,216,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,17282,13824,0,0,0,7936,0,0,0,0,124,0,0,0,61440,65,6782,0,0,1984,63488,97,0,0,1055,61408,1,0,31744,32784,1951,0,0,496,7680,24,0,49152,7,24696,0,0,7936,0,384,0,0,124,0,6,0,61440,1,6144,0,0,1984,0,96,0,0,1055,65528,1,0,31744,32768,1695,0,0,16880,65152,31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,1,0,0,0,1792,0,0,0,0,0,0,0,0,0,0,0,0,4096,16880,65152,31,0,0,0,0,0,0,0,0,0,0,64,4220,65440,7,0,0,0,0,0,8192,0,0,0,0,16,1055,65512,1,0,0,0,0,0,57984,40990,63,0,0,17282,13824,0,0,10240,494,1018,0,0,64,0,0,0,32768,4320,3456,0,0,33280,67,54,0,0,0,1055,65512,1,0,31744,40976,2047,0,4096,16880,65152,31,0,0,0,0,0,0,0,0,0,0,512,4220,65440,7,0,0,16384,0,0,0,0,0,0,0,60968,64001,3,0,8192,1848,1888,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,47264,59399,15,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Gdecl","Fdecl","Fdefn","Param","ParamlistFollow","Paramlist","Typedef","Block","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","ArglistFollow","Arglist","Operation","Intconst","'('","')'","'{'","'}'","';'","','","dec","hex","ident","tokmain","ret","int","void","'-'","'+'","'*'","'/'","'%'","asgnop","kill","typedef","assert","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 74
        bit_end = (st + 1) * 74
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..73]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (34) = happyShift action_8
action_0 (37) = happyShift action_9
action_0 (38) = happyShift action_10
action_0 (46) = happyShift action_11
action_0 (55) = happyShift action_12
action_0 (4) = happyGoto action_2
action_0 (5) = happyGoto action_3
action_0 (6) = happyGoto action_4
action_0 (7) = happyGoto action_5
action_0 (11) = happyGoto action_6
action_0 (13) = happyGoto action_7
action_0 _ = happyReduce_1

action_1 _ = happyFail (happyExpListPerState 1)

action_2 (74) = happyAccept
action_2 _ = happyFail (happyExpListPerState 2)

action_3 (34) = happyShift action_8
action_3 (37) = happyShift action_9
action_3 (38) = happyShift action_10
action_3 (46) = happyShift action_11
action_3 (55) = happyShift action_12
action_3 (4) = happyGoto action_15
action_3 (5) = happyGoto action_3
action_3 (6) = happyGoto action_4
action_3 (7) = happyGoto action_5
action_3 (11) = happyGoto action_6
action_3 (13) = happyGoto action_7
action_3 _ = happyReduce_1

action_4 _ = happyReduce_3

action_5 _ = happyReduce_4

action_6 _ = happyReduce_5

action_7 (34) = happyShift action_14
action_7 _ = happyFail (happyExpListPerState 7)

action_8 _ = happyReduce_17

action_9 _ = happyReduce_15

action_10 _ = happyReduce_18

action_11 (34) = happyShift action_8
action_11 (37) = happyShift action_9
action_11 (38) = happyShift action_10
action_11 (55) = happyShift action_12
action_11 (13) = happyGoto action_13
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_16

action_13 (34) = happyShift action_18
action_13 _ = happyFail (happyExpListPerState 13)

action_14 (26) = happyShift action_17
action_14 (10) = happyGoto action_16
action_14 _ = happyFail (happyExpListPerState 14)

action_15 _ = happyReduce_2

action_16 (28) = happyShift action_24
action_16 (12) = happyGoto action_23
action_16 _ = happyReduce_6

action_17 (27) = happyShift action_22
action_17 (34) = happyShift action_8
action_17 (37) = happyShift action_9
action_17 (38) = happyShift action_10
action_17 (55) = happyShift action_12
action_17 (8) = happyGoto action_20
action_17 (13) = happyGoto action_21
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (30) = happyShift action_19
action_18 _ = happyFail (happyExpListPerState 18)

action_19 _ = happyReduce_13

action_20 (31) = happyShift action_50
action_20 (9) = happyGoto action_49
action_20 _ = happyReduce_9

action_21 (34) = happyShift action_48
action_21 _ = happyFail (happyExpListPerState 21)

action_22 _ = happyReduce_11

action_23 _ = happyReduce_7

action_24 (26) = happyShift action_34
action_24 (28) = happyShift action_35
action_24 (32) = happyShift action_36
action_24 (33) = happyShift action_37
action_24 (34) = happyShift action_38
action_24 (36) = happyShift action_39
action_24 (37) = happyShift action_9
action_24 (38) = happyShift action_10
action_24 (39) = happyShift action_40
action_24 (48) = happyShift action_41
action_24 (50) = happyShift action_42
action_24 (51) = happyShift action_43
action_24 (52) = happyShift action_44
action_24 (53) = happyShift action_45
action_24 (54) = happyShift action_46
action_24 (55) = happyShift action_12
action_24 (56) = happyShift action_47
action_24 (13) = happyGoto action_25
action_24 (14) = happyGoto action_26
action_24 (15) = happyGoto action_27
action_24 (16) = happyGoto action_28
action_24 (17) = happyGoto action_29
action_24 (20) = happyGoto action_30
action_24 (21) = happyGoto action_31
action_24 (24) = happyGoto action_32
action_24 (25) = happyGoto action_33
action_24 _ = happyReduce_21

action_25 (34) = happyShift action_91
action_25 _ = happyFail (happyExpListPerState 25)

action_26 _ = happyReduce_29

action_27 (29) = happyShift action_90
action_27 _ = happyFail (happyExpListPerState 27)

action_28 (26) = happyShift action_34
action_28 (28) = happyShift action_35
action_28 (32) = happyShift action_36
action_28 (33) = happyShift action_37
action_28 (34) = happyShift action_38
action_28 (36) = happyShift action_39
action_28 (37) = happyShift action_9
action_28 (38) = happyShift action_10
action_28 (39) = happyShift action_40
action_28 (48) = happyShift action_41
action_28 (50) = happyShift action_42
action_28 (51) = happyShift action_43
action_28 (52) = happyShift action_44
action_28 (53) = happyShift action_45
action_28 (54) = happyShift action_46
action_28 (55) = happyShift action_12
action_28 (56) = happyShift action_47
action_28 (13) = happyGoto action_25
action_28 (14) = happyGoto action_26
action_28 (15) = happyGoto action_89
action_28 (16) = happyGoto action_28
action_28 (17) = happyGoto action_29
action_28 (20) = happyGoto action_30
action_28 (21) = happyGoto action_31
action_28 (24) = happyGoto action_32
action_28 (25) = happyGoto action_33
action_28 _ = happyReduce_21

action_29 (30) = happyShift action_88
action_29 _ = happyFail (happyExpListPerState 29)

action_30 _ = happyReduce_23

action_31 (39) = happyShift action_66
action_31 (40) = happyShift action_67
action_31 (41) = happyShift action_68
action_31 (42) = happyShift action_69
action_31 (43) = happyShift action_70
action_31 (44) = happyShift action_71
action_31 (49) = happyShift action_72
action_31 (58) = happyShift action_73
action_31 (60) = happyShift action_74
action_31 (61) = happyShift action_75
action_31 (62) = happyShift action_76
action_31 (63) = happyShift action_77
action_31 (64) = happyShift action_78
action_31 (65) = happyShift action_79
action_31 (66) = happyShift action_80
action_31 (67) = happyShift action_81
action_31 (68) = happyShift action_82
action_31 (69) = happyShift action_83
action_31 (70) = happyShift action_84
action_31 (71) = happyShift action_85
action_31 (72) = happyShift action_86
action_31 (73) = happyShift action_87
action_31 _ = happyReduce_30

action_32 _ = happyReduce_46

action_33 _ = happyReduce_44

action_34 (26) = happyShift action_34
action_34 (32) = happyShift action_36
action_34 (33) = happyShift action_37
action_34 (34) = happyShift action_56
action_34 (39) = happyShift action_40
action_34 (50) = happyShift action_42
action_34 (51) = happyShift action_43
action_34 (53) = happyShift action_45
action_34 (54) = happyShift action_46
action_34 (21) = happyGoto action_65
action_34 (24) = happyGoto action_32
action_34 (25) = happyGoto action_33
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (26) = happyShift action_34
action_35 (28) = happyShift action_35
action_35 (32) = happyShift action_36
action_35 (33) = happyShift action_37
action_35 (34) = happyShift action_38
action_35 (36) = happyShift action_39
action_35 (37) = happyShift action_9
action_35 (38) = happyShift action_10
action_35 (39) = happyShift action_40
action_35 (48) = happyShift action_41
action_35 (50) = happyShift action_42
action_35 (51) = happyShift action_43
action_35 (52) = happyShift action_44
action_35 (53) = happyShift action_45
action_35 (54) = happyShift action_46
action_35 (55) = happyShift action_12
action_35 (56) = happyShift action_47
action_35 (13) = happyGoto action_25
action_35 (14) = happyGoto action_26
action_35 (15) = happyGoto action_64
action_35 (16) = happyGoto action_28
action_35 (17) = happyGoto action_29
action_35 (20) = happyGoto action_30
action_35 (21) = happyGoto action_31
action_35 (24) = happyGoto action_32
action_35 (25) = happyGoto action_33
action_35 _ = happyReduce_21

action_36 _ = happyReduce_73

action_37 _ = happyReduce_74

action_38 (26) = happyShift action_63
action_38 (34) = happyReduce_17
action_38 (23) = happyGoto action_62
action_38 _ = happyReduce_45

action_39 (26) = happyShift action_34
action_39 (30) = happyShift action_61
action_39 (32) = happyShift action_36
action_39 (33) = happyShift action_37
action_39 (34) = happyShift action_56
action_39 (39) = happyShift action_40
action_39 (50) = happyShift action_42
action_39 (51) = happyShift action_43
action_39 (53) = happyShift action_45
action_39 (54) = happyShift action_46
action_39 (21) = happyGoto action_60
action_39 (24) = happyGoto action_32
action_39 (25) = happyGoto action_33
action_39 _ = happyFail (happyExpListPerState 39)

action_40 (26) = happyShift action_34
action_40 (32) = happyShift action_36
action_40 (33) = happyShift action_37
action_40 (34) = happyShift action_56
action_40 (39) = happyShift action_40
action_40 (50) = happyShift action_42
action_40 (51) = happyShift action_43
action_40 (53) = happyShift action_45
action_40 (54) = happyShift action_46
action_40 (21) = happyGoto action_59
action_40 (24) = happyGoto action_32
action_40 (25) = happyGoto action_33
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (26) = happyShift action_58
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (26) = happyShift action_34
action_42 (32) = happyShift action_36
action_42 (33) = happyShift action_37
action_42 (34) = happyShift action_56
action_42 (39) = happyShift action_40
action_42 (50) = happyShift action_42
action_42 (51) = happyShift action_43
action_42 (53) = happyShift action_45
action_42 (54) = happyShift action_46
action_42 (21) = happyGoto action_57
action_42 (24) = happyGoto action_32
action_42 (25) = happyGoto action_33
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (26) = happyShift action_34
action_43 (32) = happyShift action_36
action_43 (33) = happyShift action_37
action_43 (34) = happyShift action_56
action_43 (39) = happyShift action_40
action_43 (50) = happyShift action_42
action_43 (51) = happyShift action_43
action_43 (53) = happyShift action_45
action_43 (54) = happyShift action_46
action_43 (21) = happyGoto action_55
action_43 (24) = happyGoto action_32
action_43 (25) = happyGoto action_33
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (26) = happyShift action_54
action_44 _ = happyFail (happyExpListPerState 44)

action_45 _ = happyReduce_42

action_46 _ = happyReduce_43

action_47 (26) = happyShift action_53
action_47 _ = happyFail (happyExpListPerState 47)

action_48 _ = happyReduce_8

action_49 (27) = happyShift action_52
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (34) = happyShift action_8
action_50 (37) = happyShift action_9
action_50 (38) = happyShift action_10
action_50 (55) = happyShift action_12
action_50 (8) = happyGoto action_51
action_50 (13) = happyGoto action_21
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (31) = happyShift action_50
action_51 (9) = happyGoto action_122
action_51 _ = happyReduce_9

action_52 _ = happyReduce_12

action_53 (26) = happyShift action_34
action_53 (32) = happyShift action_36
action_53 (33) = happyShift action_37
action_53 (34) = happyShift action_56
action_53 (39) = happyShift action_40
action_53 (50) = happyShift action_42
action_53 (51) = happyShift action_43
action_53 (53) = happyShift action_45
action_53 (54) = happyShift action_46
action_53 (21) = happyGoto action_121
action_53 (24) = happyGoto action_32
action_53 (25) = happyGoto action_33
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (26) = happyShift action_34
action_54 (32) = happyShift action_36
action_54 (33) = happyShift action_37
action_54 (34) = happyShift action_38
action_54 (37) = happyShift action_9
action_54 (38) = happyShift action_10
action_54 (39) = happyShift action_40
action_54 (50) = happyShift action_42
action_54 (51) = happyShift action_43
action_54 (53) = happyShift action_45
action_54 (54) = happyShift action_46
action_54 (55) = happyShift action_12
action_54 (13) = happyGoto action_25
action_54 (14) = happyGoto action_26
action_54 (17) = happyGoto action_119
action_54 (18) = happyGoto action_120
action_54 (21) = happyGoto action_31
action_54 (24) = happyGoto action_32
action_54 (25) = happyGoto action_33
action_54 _ = happyReduce_31

action_55 _ = happyReduce_71

action_56 (26) = happyShift action_63
action_56 (23) = happyGoto action_62
action_56 _ = happyReduce_45

action_57 _ = happyReduce_70

action_58 (26) = happyShift action_34
action_58 (32) = happyShift action_36
action_58 (33) = happyShift action_37
action_58 (34) = happyShift action_56
action_58 (39) = happyShift action_40
action_58 (50) = happyShift action_42
action_58 (51) = happyShift action_43
action_58 (53) = happyShift action_45
action_58 (54) = happyShift action_46
action_58 (21) = happyGoto action_118
action_58 (24) = happyGoto action_32
action_58 (25) = happyGoto action_33
action_58 _ = happyFail (happyExpListPerState 58)

action_59 _ = happyReduce_72

action_60 (30) = happyShift action_117
action_60 (39) = happyShift action_66
action_60 (40) = happyShift action_67
action_60 (41) = happyShift action_68
action_60 (42) = happyShift action_69
action_60 (43) = happyShift action_70
action_60 (49) = happyShift action_72
action_60 (58) = happyShift action_73
action_60 (60) = happyShift action_74
action_60 (61) = happyShift action_75
action_60 (62) = happyShift action_76
action_60 (63) = happyShift action_77
action_60 (64) = happyShift action_78
action_60 (65) = happyShift action_79
action_60 (66) = happyShift action_80
action_60 (67) = happyShift action_81
action_60 (68) = happyShift action_82
action_60 (69) = happyShift action_83
action_60 (70) = happyShift action_84
action_60 (71) = happyShift action_85
action_60 _ = happyFail (happyExpListPerState 60)

action_61 _ = happyReduce_39

action_62 _ = happyReduce_47

action_63 (26) = happyShift action_34
action_63 (27) = happyShift action_116
action_63 (32) = happyShift action_36
action_63 (33) = happyShift action_37
action_63 (34) = happyShift action_56
action_63 (39) = happyShift action_40
action_63 (50) = happyShift action_42
action_63 (51) = happyShift action_43
action_63 (53) = happyShift action_45
action_63 (54) = happyShift action_46
action_63 (21) = happyGoto action_115
action_63 (24) = happyGoto action_32
action_63 (25) = happyGoto action_33
action_63 _ = happyFail (happyExpListPerState 63)

action_64 (29) = happyShift action_114
action_64 _ = happyFail (happyExpListPerState 64)

action_65 (27) = happyShift action_113
action_65 (39) = happyShift action_66
action_65 (40) = happyShift action_67
action_65 (41) = happyShift action_68
action_65 (42) = happyShift action_69
action_65 (43) = happyShift action_70
action_65 (49) = happyShift action_72
action_65 (58) = happyShift action_73
action_65 (60) = happyShift action_74
action_65 (61) = happyShift action_75
action_65 (62) = happyShift action_76
action_65 (63) = happyShift action_77
action_65 (64) = happyShift action_78
action_65 (65) = happyShift action_79
action_65 (66) = happyShift action_80
action_65 (67) = happyShift action_81
action_65 (68) = happyShift action_82
action_65 (69) = happyShift action_83
action_65 (70) = happyShift action_84
action_65 (71) = happyShift action_85
action_65 _ = happyFail (happyExpListPerState 65)

action_66 (26) = happyShift action_34
action_66 (32) = happyShift action_36
action_66 (33) = happyShift action_37
action_66 (34) = happyShift action_56
action_66 (39) = happyShift action_40
action_66 (50) = happyShift action_42
action_66 (51) = happyShift action_43
action_66 (53) = happyShift action_45
action_66 (54) = happyShift action_46
action_66 (21) = happyGoto action_112
action_66 (24) = happyGoto action_32
action_66 (25) = happyGoto action_33
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (26) = happyShift action_34
action_67 (32) = happyShift action_36
action_67 (33) = happyShift action_37
action_67 (34) = happyShift action_56
action_67 (39) = happyShift action_40
action_67 (50) = happyShift action_42
action_67 (51) = happyShift action_43
action_67 (53) = happyShift action_45
action_67 (54) = happyShift action_46
action_67 (21) = happyGoto action_111
action_67 (24) = happyGoto action_32
action_67 (25) = happyGoto action_33
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (26) = happyShift action_34
action_68 (32) = happyShift action_36
action_68 (33) = happyShift action_37
action_68 (34) = happyShift action_56
action_68 (39) = happyShift action_40
action_68 (50) = happyShift action_42
action_68 (51) = happyShift action_43
action_68 (53) = happyShift action_45
action_68 (54) = happyShift action_46
action_68 (21) = happyGoto action_110
action_68 (24) = happyGoto action_32
action_68 (25) = happyGoto action_33
action_68 _ = happyFail (happyExpListPerState 68)

action_69 (26) = happyShift action_34
action_69 (32) = happyShift action_36
action_69 (33) = happyShift action_37
action_69 (34) = happyShift action_56
action_69 (39) = happyShift action_40
action_69 (50) = happyShift action_42
action_69 (51) = happyShift action_43
action_69 (53) = happyShift action_45
action_69 (54) = happyShift action_46
action_69 (21) = happyGoto action_109
action_69 (24) = happyGoto action_32
action_69 (25) = happyGoto action_33
action_69 _ = happyFail (happyExpListPerState 69)

action_70 (26) = happyShift action_34
action_70 (32) = happyShift action_36
action_70 (33) = happyShift action_37
action_70 (34) = happyShift action_56
action_70 (39) = happyShift action_40
action_70 (50) = happyShift action_42
action_70 (51) = happyShift action_43
action_70 (53) = happyShift action_45
action_70 (54) = happyShift action_46
action_70 (21) = happyGoto action_108
action_70 (24) = happyGoto action_32
action_70 (25) = happyGoto action_33
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (26) = happyShift action_34
action_71 (32) = happyShift action_36
action_71 (33) = happyShift action_37
action_71 (34) = happyShift action_56
action_71 (39) = happyShift action_40
action_71 (50) = happyShift action_42
action_71 (51) = happyShift action_43
action_71 (53) = happyShift action_45
action_71 (54) = happyShift action_46
action_71 (21) = happyGoto action_107
action_71 (24) = happyGoto action_32
action_71 (25) = happyGoto action_33
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (26) = happyShift action_34
action_72 (32) = happyShift action_36
action_72 (33) = happyShift action_37
action_72 (34) = happyShift action_56
action_72 (39) = happyShift action_40
action_72 (50) = happyShift action_42
action_72 (51) = happyShift action_43
action_72 (53) = happyShift action_45
action_72 (54) = happyShift action_46
action_72 (21) = happyGoto action_106
action_72 (24) = happyGoto action_32
action_72 (25) = happyGoto action_33
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (26) = happyShift action_34
action_73 (32) = happyShift action_36
action_73 (33) = happyShift action_37
action_73 (34) = happyShift action_56
action_73 (39) = happyShift action_40
action_73 (50) = happyShift action_42
action_73 (51) = happyShift action_43
action_73 (53) = happyShift action_45
action_73 (54) = happyShift action_46
action_73 (21) = happyGoto action_105
action_73 (24) = happyGoto action_32
action_73 (25) = happyGoto action_33
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (26) = happyShift action_34
action_74 (32) = happyShift action_36
action_74 (33) = happyShift action_37
action_74 (34) = happyShift action_56
action_74 (39) = happyShift action_40
action_74 (50) = happyShift action_42
action_74 (51) = happyShift action_43
action_74 (53) = happyShift action_45
action_74 (54) = happyShift action_46
action_74 (21) = happyGoto action_104
action_74 (24) = happyGoto action_32
action_74 (25) = happyGoto action_33
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (26) = happyShift action_34
action_75 (32) = happyShift action_36
action_75 (33) = happyShift action_37
action_75 (34) = happyShift action_56
action_75 (39) = happyShift action_40
action_75 (50) = happyShift action_42
action_75 (51) = happyShift action_43
action_75 (53) = happyShift action_45
action_75 (54) = happyShift action_46
action_75 (21) = happyGoto action_103
action_75 (24) = happyGoto action_32
action_75 (25) = happyGoto action_33
action_75 _ = happyFail (happyExpListPerState 75)

action_76 (26) = happyShift action_34
action_76 (32) = happyShift action_36
action_76 (33) = happyShift action_37
action_76 (34) = happyShift action_56
action_76 (39) = happyShift action_40
action_76 (50) = happyShift action_42
action_76 (51) = happyShift action_43
action_76 (53) = happyShift action_45
action_76 (54) = happyShift action_46
action_76 (21) = happyGoto action_102
action_76 (24) = happyGoto action_32
action_76 (25) = happyGoto action_33
action_76 _ = happyFail (happyExpListPerState 76)

action_77 (26) = happyShift action_34
action_77 (32) = happyShift action_36
action_77 (33) = happyShift action_37
action_77 (34) = happyShift action_56
action_77 (39) = happyShift action_40
action_77 (50) = happyShift action_42
action_77 (51) = happyShift action_43
action_77 (53) = happyShift action_45
action_77 (54) = happyShift action_46
action_77 (21) = happyGoto action_101
action_77 (24) = happyGoto action_32
action_77 (25) = happyGoto action_33
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (26) = happyShift action_34
action_78 (32) = happyShift action_36
action_78 (33) = happyShift action_37
action_78 (34) = happyShift action_56
action_78 (39) = happyShift action_40
action_78 (50) = happyShift action_42
action_78 (51) = happyShift action_43
action_78 (53) = happyShift action_45
action_78 (54) = happyShift action_46
action_78 (21) = happyGoto action_100
action_78 (24) = happyGoto action_32
action_78 (25) = happyGoto action_33
action_78 _ = happyFail (happyExpListPerState 78)

action_79 (26) = happyShift action_34
action_79 (32) = happyShift action_36
action_79 (33) = happyShift action_37
action_79 (34) = happyShift action_56
action_79 (39) = happyShift action_40
action_79 (50) = happyShift action_42
action_79 (51) = happyShift action_43
action_79 (53) = happyShift action_45
action_79 (54) = happyShift action_46
action_79 (21) = happyGoto action_99
action_79 (24) = happyGoto action_32
action_79 (25) = happyGoto action_33
action_79 _ = happyFail (happyExpListPerState 79)

action_80 (26) = happyShift action_34
action_80 (32) = happyShift action_36
action_80 (33) = happyShift action_37
action_80 (34) = happyShift action_56
action_80 (39) = happyShift action_40
action_80 (50) = happyShift action_42
action_80 (51) = happyShift action_43
action_80 (53) = happyShift action_45
action_80 (54) = happyShift action_46
action_80 (21) = happyGoto action_98
action_80 (24) = happyGoto action_32
action_80 (25) = happyGoto action_33
action_80 _ = happyFail (happyExpListPerState 80)

action_81 (26) = happyShift action_34
action_81 (32) = happyShift action_36
action_81 (33) = happyShift action_37
action_81 (34) = happyShift action_56
action_81 (39) = happyShift action_40
action_81 (50) = happyShift action_42
action_81 (51) = happyShift action_43
action_81 (53) = happyShift action_45
action_81 (54) = happyShift action_46
action_81 (21) = happyGoto action_97
action_81 (24) = happyGoto action_32
action_81 (25) = happyGoto action_33
action_81 _ = happyFail (happyExpListPerState 81)

action_82 (26) = happyShift action_34
action_82 (32) = happyShift action_36
action_82 (33) = happyShift action_37
action_82 (34) = happyShift action_56
action_82 (39) = happyShift action_40
action_82 (50) = happyShift action_42
action_82 (51) = happyShift action_43
action_82 (53) = happyShift action_45
action_82 (54) = happyShift action_46
action_82 (21) = happyGoto action_96
action_82 (24) = happyGoto action_32
action_82 (25) = happyGoto action_33
action_82 _ = happyFail (happyExpListPerState 82)

action_83 (26) = happyShift action_34
action_83 (32) = happyShift action_36
action_83 (33) = happyShift action_37
action_83 (34) = happyShift action_56
action_83 (39) = happyShift action_40
action_83 (50) = happyShift action_42
action_83 (51) = happyShift action_43
action_83 (53) = happyShift action_45
action_83 (54) = happyShift action_46
action_83 (21) = happyGoto action_95
action_83 (24) = happyGoto action_32
action_83 (25) = happyGoto action_33
action_83 _ = happyFail (happyExpListPerState 83)

action_84 (26) = happyShift action_34
action_84 (32) = happyShift action_36
action_84 (33) = happyShift action_37
action_84 (34) = happyShift action_56
action_84 (39) = happyShift action_40
action_84 (50) = happyShift action_42
action_84 (51) = happyShift action_43
action_84 (53) = happyShift action_45
action_84 (54) = happyShift action_46
action_84 (21) = happyGoto action_94
action_84 (24) = happyGoto action_32
action_84 (25) = happyGoto action_33
action_84 _ = happyFail (happyExpListPerState 84)

action_85 (26) = happyShift action_34
action_85 (32) = happyShift action_36
action_85 (33) = happyShift action_37
action_85 (34) = happyShift action_56
action_85 (39) = happyShift action_40
action_85 (50) = happyShift action_42
action_85 (51) = happyShift action_43
action_85 (53) = happyShift action_45
action_85 (54) = happyShift action_46
action_85 (21) = happyGoto action_93
action_85 (24) = happyGoto action_32
action_85 (25) = happyGoto action_33
action_85 _ = happyFail (happyExpListPerState 85)

action_86 _ = happyReduce_27

action_87 _ = happyReduce_28

action_88 _ = happyReduce_24

action_89 _ = happyReduce_22

action_90 _ = happyReduce_14

action_91 (44) = happyShift action_92
action_91 _ = happyReduce_20

action_92 (26) = happyShift action_34
action_92 (32) = happyShift action_36
action_92 (33) = happyShift action_37
action_92 (34) = happyShift action_56
action_92 (39) = happyShift action_40
action_92 (50) = happyShift action_42
action_92 (51) = happyShift action_43
action_92 (53) = happyShift action_45
action_92 (54) = happyShift action_46
action_92 (21) = happyGoto action_129
action_92 (24) = happyGoto action_32
action_92 (25) = happyGoto action_33
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (39) = happyShift action_66
action_93 (40) = happyShift action_67
action_93 (41) = happyShift action_68
action_93 (42) = happyShift action_69
action_93 (43) = happyShift action_70
action_93 _ = happyReduce_58

action_94 (39) = happyShift action_66
action_94 (40) = happyShift action_67
action_94 (41) = happyShift action_68
action_94 (42) = happyShift action_69
action_94 (43) = happyShift action_70
action_94 _ = happyReduce_57

action_95 (39) = happyShift action_66
action_95 (40) = happyShift action_67
action_95 (41) = happyShift action_68
action_95 (42) = happyShift action_69
action_95 (43) = happyShift action_70
action_95 (49) = happyShift action_72
action_95 (60) = happyShift action_74
action_95 (61) = happyShift action_75
action_95 (62) = happyShift action_76
action_95 (63) = happyShift action_77
action_95 (64) = happyShift action_78
action_95 (65) = happyShift action_79
action_95 (68) = happyShift action_82
action_95 (70) = happyShift action_84
action_95 (71) = happyShift action_85
action_95 _ = happyReduce_60

action_96 (39) = happyShift action_66
action_96 (40) = happyShift action_67
action_96 (41) = happyShift action_68
action_96 (42) = happyShift action_69
action_96 (43) = happyShift action_70
action_96 (60) = happyShift action_74
action_96 (61) = happyShift action_75
action_96 (62) = happyShift action_76
action_96 (63) = happyShift action_77
action_96 (64) = happyShift action_78
action_96 (65) = happyShift action_79
action_96 (70) = happyShift action_84
action_96 (71) = happyShift action_85
action_96 _ = happyReduce_59

action_97 (39) = happyShift action_66
action_97 (40) = happyShift action_67
action_97 (41) = happyShift action_68
action_97 (42) = happyShift action_69
action_97 (43) = happyShift action_70
action_97 (49) = happyShift action_72
action_97 (60) = happyShift action_74
action_97 (61) = happyShift action_75
action_97 (62) = happyShift action_76
action_97 (63) = happyShift action_77
action_97 (64) = happyShift action_78
action_97 (65) = happyShift action_79
action_97 (66) = happyShift action_80
action_97 (68) = happyShift action_82
action_97 (69) = happyShift action_83
action_97 (70) = happyShift action_84
action_97 (71) = happyShift action_85
action_97 _ = happyReduce_63

action_98 (39) = happyShift action_66
action_98 (40) = happyShift action_67
action_98 (41) = happyShift action_68
action_98 (42) = happyShift action_69
action_98 (43) = happyShift action_70
action_98 (49) = happyShift action_72
action_98 (60) = happyShift action_74
action_98 (61) = happyShift action_75
action_98 (62) = happyShift action_76
action_98 (63) = happyShift action_77
action_98 (64) = happyShift action_78
action_98 (65) = happyShift action_79
action_98 (68) = happyShift action_82
action_98 (69) = happyShift action_83
action_98 (70) = happyShift action_84
action_98 (71) = happyShift action_85
action_98 _ = happyReduce_62

action_99 (39) = happyShift action_66
action_99 (40) = happyShift action_67
action_99 (41) = happyShift action_68
action_99 (42) = happyShift action_69
action_99 (43) = happyShift action_70
action_99 (60) = happyShift action_74
action_99 (61) = happyShift action_75
action_99 (62) = happyShift action_76
action_99 (63) = happyShift action_77
action_99 (70) = happyShift action_84
action_99 (71) = happyShift action_85
action_99 _ = happyReduce_69

action_100 (39) = happyShift action_66
action_100 (40) = happyShift action_67
action_100 (41) = happyShift action_68
action_100 (42) = happyShift action_69
action_100 (43) = happyShift action_70
action_100 (60) = happyShift action_74
action_100 (61) = happyShift action_75
action_100 (62) = happyShift action_76
action_100 (63) = happyShift action_77
action_100 (70) = happyShift action_84
action_100 (71) = happyShift action_85
action_100 _ = happyReduce_68

action_101 (39) = happyShift action_66
action_101 (40) = happyShift action_67
action_101 (41) = happyShift action_68
action_101 (42) = happyShift action_69
action_101 (43) = happyShift action_70
action_101 (70) = happyShift action_84
action_101 (71) = happyShift action_85
action_101 _ = happyReduce_65

action_102 (39) = happyShift action_66
action_102 (40) = happyShift action_67
action_102 (41) = happyShift action_68
action_102 (42) = happyShift action_69
action_102 (43) = happyShift action_70
action_102 (70) = happyShift action_84
action_102 (71) = happyShift action_85
action_102 _ = happyReduce_67

action_103 (39) = happyShift action_66
action_103 (40) = happyShift action_67
action_103 (41) = happyShift action_68
action_103 (42) = happyShift action_69
action_103 (43) = happyShift action_70
action_103 (70) = happyShift action_84
action_103 (71) = happyShift action_85
action_103 _ = happyReduce_66

action_104 (39) = happyShift action_66
action_104 (40) = happyShift action_67
action_104 (41) = happyShift action_68
action_104 (42) = happyShift action_69
action_104 (43) = happyShift action_70
action_104 (70) = happyShift action_84
action_104 (71) = happyShift action_85
action_104 _ = happyReduce_64

action_105 (39) = happyShift action_66
action_105 (40) = happyShift action_67
action_105 (41) = happyShift action_68
action_105 (42) = happyShift action_69
action_105 (43) = happyShift action_70
action_105 (49) = happyShift action_72
action_105 (58) = happyShift action_73
action_105 (59) = happyShift action_128
action_105 (60) = happyShift action_74
action_105 (61) = happyShift action_75
action_105 (62) = happyShift action_76
action_105 (63) = happyShift action_77
action_105 (64) = happyShift action_78
action_105 (65) = happyShift action_79
action_105 (66) = happyShift action_80
action_105 (67) = happyShift action_81
action_105 (68) = happyShift action_82
action_105 (69) = happyShift action_83
action_105 (70) = happyShift action_84
action_105 (71) = happyShift action_85
action_105 _ = happyFail (happyExpListPerState 105)

action_106 (39) = happyShift action_66
action_106 (40) = happyShift action_67
action_106 (41) = happyShift action_68
action_106 (42) = happyShift action_69
action_106 (43) = happyShift action_70
action_106 (60) = happyShift action_74
action_106 (61) = happyShift action_75
action_106 (62) = happyShift action_76
action_106 (63) = happyShift action_77
action_106 (64) = happyShift action_78
action_106 (65) = happyShift action_79
action_106 (68) = happyShift action_82
action_106 (70) = happyShift action_84
action_106 (71) = happyShift action_85
action_106 _ = happyReduce_61

action_107 (39) = happyShift action_66
action_107 (40) = happyShift action_67
action_107 (41) = happyShift action_68
action_107 (42) = happyShift action_69
action_107 (43) = happyShift action_70
action_107 (49) = happyShift action_72
action_107 (58) = happyShift action_73
action_107 (60) = happyShift action_74
action_107 (61) = happyShift action_75
action_107 (62) = happyShift action_76
action_107 (63) = happyShift action_77
action_107 (64) = happyShift action_78
action_107 (65) = happyShift action_79
action_107 (66) = happyShift action_80
action_107 (67) = happyShift action_81
action_107 (68) = happyShift action_82
action_107 (69) = happyShift action_83
action_107 (70) = happyShift action_84
action_107 (71) = happyShift action_85
action_107 _ = happyReduce_26

action_108 _ = happyReduce_56

action_109 _ = happyReduce_55

action_110 _ = happyReduce_54

action_111 (41) = happyShift action_68
action_111 (42) = happyShift action_69
action_111 (43) = happyShift action_70
action_111 _ = happyReduce_53

action_112 (41) = happyShift action_68
action_112 (42) = happyShift action_69
action_112 (43) = happyShift action_70
action_112 _ = happyReduce_52

action_113 _ = happyReduce_40

action_114 _ = happyReduce_25

action_115 (31) = happyShift action_127
action_115 (39) = happyShift action_66
action_115 (40) = happyShift action_67
action_115 (41) = happyShift action_68
action_115 (42) = happyShift action_69
action_115 (43) = happyShift action_70
action_115 (49) = happyShift action_72
action_115 (58) = happyShift action_73
action_115 (60) = happyShift action_74
action_115 (61) = happyShift action_75
action_115 (62) = happyShift action_76
action_115 (63) = happyShift action_77
action_115 (64) = happyShift action_78
action_115 (65) = happyShift action_79
action_115 (66) = happyShift action_80
action_115 (67) = happyShift action_81
action_115 (68) = happyShift action_82
action_115 (69) = happyShift action_83
action_115 (70) = happyShift action_84
action_115 (71) = happyShift action_85
action_115 (22) = happyGoto action_126
action_115 _ = happyReduce_48

action_116 _ = happyReduce_50

action_117 _ = happyReduce_38

action_118 (27) = happyShift action_125
action_118 (39) = happyShift action_66
action_118 (40) = happyShift action_67
action_118 (41) = happyShift action_68
action_118 (42) = happyShift action_69
action_118 (43) = happyShift action_70
action_118 (49) = happyShift action_72
action_118 (58) = happyShift action_73
action_118 (60) = happyShift action_74
action_118 (61) = happyShift action_75
action_118 (62) = happyShift action_76
action_118 (63) = happyShift action_77
action_118 (64) = happyShift action_78
action_118 (65) = happyShift action_79
action_118 (66) = happyShift action_80
action_118 (67) = happyShift action_81
action_118 (68) = happyShift action_82
action_118 (69) = happyShift action_83
action_118 (70) = happyShift action_84
action_118 (71) = happyShift action_85
action_118 _ = happyFail (happyExpListPerState 118)

action_119 _ = happyReduce_32

action_120 (30) = happyShift action_124
action_120 _ = happyFail (happyExpListPerState 120)

action_121 (27) = happyShift action_123
action_121 (39) = happyShift action_66
action_121 (40) = happyShift action_67
action_121 (41) = happyShift action_68
action_121 (42) = happyShift action_69
action_121 (43) = happyShift action_70
action_121 (49) = happyShift action_72
action_121 (58) = happyShift action_73
action_121 (60) = happyShift action_74
action_121 (61) = happyShift action_75
action_121 (62) = happyShift action_76
action_121 (63) = happyShift action_77
action_121 (64) = happyShift action_78
action_121 (65) = happyShift action_79
action_121 (66) = happyShift action_80
action_121 (67) = happyShift action_81
action_121 (68) = happyShift action_82
action_121 (69) = happyShift action_83
action_121 (70) = happyShift action_84
action_121 (71) = happyShift action_85
action_121 _ = happyFail (happyExpListPerState 121)

action_122 _ = happyReduce_10

action_123 (26) = happyShift action_34
action_123 (28) = happyShift action_35
action_123 (32) = happyShift action_36
action_123 (33) = happyShift action_37
action_123 (34) = happyShift action_38
action_123 (36) = happyShift action_39
action_123 (37) = happyShift action_9
action_123 (38) = happyShift action_10
action_123 (39) = happyShift action_40
action_123 (48) = happyShift action_41
action_123 (50) = happyShift action_42
action_123 (51) = happyShift action_43
action_123 (52) = happyShift action_44
action_123 (53) = happyShift action_45
action_123 (54) = happyShift action_46
action_123 (55) = happyShift action_12
action_123 (56) = happyShift action_47
action_123 (13) = happyGoto action_25
action_123 (14) = happyGoto action_26
action_123 (16) = happyGoto action_135
action_123 (17) = happyGoto action_29
action_123 (20) = happyGoto action_30
action_123 (21) = happyGoto action_31
action_123 (24) = happyGoto action_32
action_123 (25) = happyGoto action_33
action_123 _ = happyFail (happyExpListPerState 123)

action_124 (26) = happyShift action_34
action_124 (32) = happyShift action_36
action_124 (33) = happyShift action_37
action_124 (34) = happyShift action_56
action_124 (39) = happyShift action_40
action_124 (50) = happyShift action_42
action_124 (51) = happyShift action_43
action_124 (53) = happyShift action_45
action_124 (54) = happyShift action_46
action_124 (21) = happyGoto action_134
action_124 (24) = happyGoto action_32
action_124 (25) = happyGoto action_33
action_124 _ = happyFail (happyExpListPerState 124)

action_125 (26) = happyShift action_34
action_125 (28) = happyShift action_35
action_125 (32) = happyShift action_36
action_125 (33) = happyShift action_37
action_125 (34) = happyShift action_38
action_125 (36) = happyShift action_39
action_125 (37) = happyShift action_9
action_125 (38) = happyShift action_10
action_125 (39) = happyShift action_40
action_125 (48) = happyShift action_41
action_125 (50) = happyShift action_42
action_125 (51) = happyShift action_43
action_125 (52) = happyShift action_44
action_125 (53) = happyShift action_45
action_125 (54) = happyShift action_46
action_125 (55) = happyShift action_12
action_125 (56) = happyShift action_47
action_125 (13) = happyGoto action_25
action_125 (14) = happyGoto action_26
action_125 (16) = happyGoto action_133
action_125 (17) = happyGoto action_29
action_125 (20) = happyGoto action_30
action_125 (21) = happyGoto action_31
action_125 (24) = happyGoto action_32
action_125 (25) = happyGoto action_33
action_125 _ = happyFail (happyExpListPerState 125)

action_126 (27) = happyShift action_132
action_126 _ = happyFail (happyExpListPerState 126)

action_127 (26) = happyShift action_34
action_127 (32) = happyShift action_36
action_127 (33) = happyShift action_37
action_127 (34) = happyShift action_56
action_127 (39) = happyShift action_40
action_127 (50) = happyShift action_42
action_127 (51) = happyShift action_43
action_127 (53) = happyShift action_45
action_127 (54) = happyShift action_46
action_127 (21) = happyGoto action_131
action_127 (24) = happyGoto action_32
action_127 (25) = happyGoto action_33
action_127 _ = happyFail (happyExpListPerState 127)

action_128 (26) = happyShift action_34
action_128 (32) = happyShift action_36
action_128 (33) = happyShift action_37
action_128 (34) = happyShift action_56
action_128 (39) = happyShift action_40
action_128 (50) = happyShift action_42
action_128 (51) = happyShift action_43
action_128 (53) = happyShift action_45
action_128 (54) = happyShift action_46
action_128 (21) = happyGoto action_130
action_128 (24) = happyGoto action_32
action_128 (25) = happyGoto action_33
action_128 _ = happyFail (happyExpListPerState 128)

action_129 (39) = happyShift action_66
action_129 (40) = happyShift action_67
action_129 (41) = happyShift action_68
action_129 (42) = happyShift action_69
action_129 (43) = happyShift action_70
action_129 (49) = happyShift action_72
action_129 (58) = happyShift action_73
action_129 (60) = happyShift action_74
action_129 (61) = happyShift action_75
action_129 (62) = happyShift action_76
action_129 (63) = happyShift action_77
action_129 (64) = happyShift action_78
action_129 (65) = happyShift action_79
action_129 (66) = happyShift action_80
action_129 (67) = happyShift action_81
action_129 (68) = happyShift action_82
action_129 (69) = happyShift action_83
action_129 (70) = happyShift action_84
action_129 (71) = happyShift action_85
action_129 _ = happyReduce_19

action_130 (39) = happyShift action_66
action_130 (40) = happyShift action_67
action_130 (41) = happyShift action_68
action_130 (42) = happyShift action_69
action_130 (43) = happyShift action_70
action_130 (49) = happyShift action_72
action_130 (58) = happyShift action_73
action_130 (60) = happyShift action_74
action_130 (61) = happyShift action_75
action_130 (62) = happyShift action_76
action_130 (63) = happyShift action_77
action_130 (64) = happyShift action_78
action_130 (65) = happyShift action_79
action_130 (66) = happyShift action_80
action_130 (67) = happyShift action_81
action_130 (68) = happyShift action_82
action_130 (69) = happyShift action_83
action_130 (70) = happyShift action_84
action_130 (71) = happyShift action_85
action_130 _ = happyReduce_41

action_131 (31) = happyShift action_127
action_131 (39) = happyShift action_66
action_131 (40) = happyShift action_67
action_131 (41) = happyShift action_68
action_131 (42) = happyShift action_69
action_131 (43) = happyShift action_70
action_131 (49) = happyShift action_72
action_131 (58) = happyShift action_73
action_131 (60) = happyShift action_74
action_131 (61) = happyShift action_75
action_131 (62) = happyShift action_76
action_131 (63) = happyShift action_77
action_131 (64) = happyShift action_78
action_131 (65) = happyShift action_79
action_131 (66) = happyShift action_80
action_131 (67) = happyShift action_81
action_131 (68) = happyShift action_82
action_131 (69) = happyShift action_83
action_131 (70) = happyShift action_84
action_131 (71) = happyShift action_85
action_131 (22) = happyGoto action_139
action_131 _ = happyReduce_48

action_132 _ = happyReduce_51

action_133 _ = happyReduce_36

action_134 (30) = happyShift action_138
action_134 (39) = happyShift action_66
action_134 (40) = happyShift action_67
action_134 (41) = happyShift action_68
action_134 (42) = happyShift action_69
action_134 (43) = happyShift action_70
action_134 (49) = happyShift action_72
action_134 (58) = happyShift action_73
action_134 (60) = happyShift action_74
action_134 (61) = happyShift action_75
action_134 (62) = happyShift action_76
action_134 (63) = happyShift action_77
action_134 (64) = happyShift action_78
action_134 (65) = happyShift action_79
action_134 (66) = happyShift action_80
action_134 (67) = happyShift action_81
action_134 (68) = happyShift action_82
action_134 (69) = happyShift action_83
action_134 (70) = happyShift action_84
action_134 (71) = happyShift action_85
action_134 _ = happyFail (happyExpListPerState 134)

action_135 (57) = happyShift action_137
action_135 (19) = happyGoto action_136
action_135 _ = happyReduce_35

action_136 _ = happyReduce_34

action_137 (26) = happyShift action_34
action_137 (28) = happyShift action_35
action_137 (32) = happyShift action_36
action_137 (33) = happyShift action_37
action_137 (34) = happyShift action_38
action_137 (36) = happyShift action_39
action_137 (37) = happyShift action_9
action_137 (38) = happyShift action_10
action_137 (39) = happyShift action_40
action_137 (48) = happyShift action_41
action_137 (50) = happyShift action_42
action_137 (51) = happyShift action_43
action_137 (52) = happyShift action_44
action_137 (53) = happyShift action_45
action_137 (54) = happyShift action_46
action_137 (55) = happyShift action_12
action_137 (56) = happyShift action_47
action_137 (13) = happyGoto action_25
action_137 (14) = happyGoto action_26
action_137 (16) = happyGoto action_141
action_137 (17) = happyGoto action_29
action_137 (20) = happyGoto action_30
action_137 (21) = happyGoto action_31
action_137 (24) = happyGoto action_32
action_137 (25) = happyGoto action_33
action_137 _ = happyFail (happyExpListPerState 137)

action_138 (26) = happyShift action_34
action_138 (32) = happyShift action_36
action_138 (33) = happyShift action_37
action_138 (34) = happyShift action_38
action_138 (37) = happyShift action_9
action_138 (38) = happyShift action_10
action_138 (39) = happyShift action_40
action_138 (50) = happyShift action_42
action_138 (51) = happyShift action_43
action_138 (53) = happyShift action_45
action_138 (54) = happyShift action_46
action_138 (55) = happyShift action_12
action_138 (13) = happyGoto action_25
action_138 (14) = happyGoto action_26
action_138 (17) = happyGoto action_119
action_138 (18) = happyGoto action_140
action_138 (21) = happyGoto action_31
action_138 (24) = happyGoto action_32
action_138 (25) = happyGoto action_33
action_138 _ = happyReduce_31

action_139 _ = happyReduce_49

action_140 (27) = happyShift action_142
action_140 _ = happyFail (happyExpListPerState 140)

action_141 _ = happyReduce_33

action_142 (26) = happyShift action_34
action_142 (28) = happyShift action_35
action_142 (32) = happyShift action_36
action_142 (33) = happyShift action_37
action_142 (34) = happyShift action_38
action_142 (36) = happyShift action_39
action_142 (37) = happyShift action_9
action_142 (38) = happyShift action_10
action_142 (39) = happyShift action_40
action_142 (48) = happyShift action_41
action_142 (50) = happyShift action_42
action_142 (51) = happyShift action_43
action_142 (52) = happyShift action_44
action_142 (53) = happyShift action_45
action_142 (54) = happyShift action_46
action_142 (55) = happyShift action_12
action_142 (56) = happyShift action_47
action_142 (13) = happyGoto action_25
action_142 (14) = happyGoto action_26
action_142 (16) = happyGoto action_143
action_142 (17) = happyGoto action_29
action_142 (20) = happyGoto action_30
action_142 (21) = happyGoto action_31
action_142 (24) = happyGoto action_32
action_142 (25) = happyGoto action_33
action_142 _ = happyFail (happyExpListPerState 142)

action_143 _ = happyReduce_37

happyReduce_1 = happySpecReduce_0  4 happyReduction_1
happyReduction_1  =  HappyAbsSyn4
		 ([]
	)

happyReduce_2 = happySpecReduce_2  4 happyReduction_2
happyReduction_2 (HappyAbsSyn4  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (happy_var_1 : happy_var_2
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1  5 happyReduction_3
happyReduction_3 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn5
		 (Fdecl happy_var_1
	)
happyReduction_3 _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_1  5 happyReduction_4
happyReduction_4 (HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn5
		 (Fdefn happy_var_1
	)
happyReduction_4 _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_1  5 happyReduction_5
happyReduction_5 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn5
		 (Typedef happy_var_1
	)
happyReduction_5 _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_3  6 happyReduction_6
happyReduction_6 (HappyAbsSyn10  happy_var_3)
	(HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_6 _ _ _  = notHappyAtAll 

happyReduce_7 = happyReduce 4 7 happyReduction_7
happyReduction_7 ((HappyAbsSyn12  happy_var_4) `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn13  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (happy_var_1 happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_8 = happySpecReduce_2  8 happyReduction_8
happyReduction_8 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn8
		 (happy_var_1 happy_var_2
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_0  9 happyReduction_9
happyReduction_9  =  HappyAbsSyn9
		 ([]
	)

happyReduce_10 = happySpecReduce_3  9 happyReduction_10
happyReduction_10 (HappyAbsSyn9  happy_var_3)
	(HappyAbsSyn8  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2 : happy_var_3
	)
happyReduction_10 _ _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_2  10 happyReduction_11
happyReduction_11 _
	_
	 =  HappyAbsSyn10
		 ([]
	)

happyReduce_12 = happyReduce 4 10 happyReduction_12
happyReduction_12 (_ `HappyStk`
	(HappyAbsSyn9  happy_var_3) `HappyStk`
	(HappyAbsSyn8  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn10
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest

happyReduce_13 = happyReduce 4 11 happyReduction_13
happyReduction_13 (_ `HappyStk`
	(HappyTerminal (TokIdent happy_var_3)) `HappyStk`
	(HappyAbsSyn13  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn11
		 (happy_var_2 happy_var_3
	) `HappyStk` happyRest

happyReduce_14 = happySpecReduce_3  12 happyReduction_14
happyReduction_14 _
	(HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn12
		 (happy_var_2
	)
happyReduction_14 _ _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_1  13 happyReduction_15
happyReduction_15 _
	 =  HappyAbsSyn13
		 (INTEGER
	)

happyReduce_16 = happySpecReduce_1  13 happyReduction_16
happyReduction_16 _
	 =  HappyAbsSyn13
		 (BOOLEAN
	)

happyReduce_17 = happySpecReduce_1  13 happyReduction_17
happyReduction_17 _
	 =  HappyAbsSyn13
		 (Ident ident
	)

happyReduce_18 = happySpecReduce_1  13 happyReduction_18
happyReduction_18 _
	 =  HappyAbsSyn13
		 (VOID
	)

happyReduce_19 = happyReduce 4 14 happyReduction_19
happyReduction_19 ((HappyAbsSyn21  happy_var_4) `HappyStk`
	(HappyTerminal (TokAsgnop happy_var_3)) `HappyStk`
	(HappyTerminal (TokIdent happy_var_2)) `HappyStk`
	(HappyAbsSyn13  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (checkDeclAsgn happy_var_2 happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_20 = happySpecReduce_2  14 happyReduction_20
happyReduction_20 (HappyTerminal (TokIdent happy_var_2))
	(HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn14
		 (JustDecl happy_var_2 happy_var_1
	)
happyReduction_20 _ _  = notHappyAtAll 

happyReduce_21 = happySpecReduce_0  15 happyReduction_21
happyReduction_21  =  HappyAbsSyn15
		 ([]
	)

happyReduce_22 = happySpecReduce_2  15 happyReduction_22
happyReduction_22 (HappyAbsSyn15  happy_var_2)
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1 : happy_var_2
	)
happyReduction_22 _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_1  16 happyReduction_23
happyReduction_23 (HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn16
		 (ControlStmt happy_var_1
	)
happyReduction_23 _  = notHappyAtAll 

happyReduce_24 = happySpecReduce_2  16 happyReduction_24
happyReduction_24 _
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn16
		 (Simp happy_var_1
	)
happyReduction_24 _ _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  16 happyReduction_25
happyReduction_25 _
	(HappyAbsSyn15  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (Stmts happy_var_2
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_3  17 happyReduction_26
happyReduction_26 (HappyAbsSyn21  happy_var_3)
	(HappyTerminal (TokAsgnop happy_var_2))
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn17
		 (checkSimpAsgn happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_26 _ _ _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_2  17 happyReduction_27
happyReduction_27 _
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn17
		 (checkSimpAsgnP happy_var_1 Incr
	)
happyReduction_27 _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_2  17 happyReduction_28
happyReduction_28 _
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn17
		 (checkSimpAsgnP happy_var_1 Decr
	)
happyReduction_28 _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_1  17 happyReduction_29
happyReduction_29 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn17
		 (Decl happy_var_1
	)
happyReduction_29 _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_1  17 happyReduction_30
happyReduction_30 (HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn17
		 (Exp happy_var_1
	)
happyReduction_30 _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_0  18 happyReduction_31
happyReduction_31  =  HappyAbsSyn18
		 (SimpNop
	)

happyReduce_32 = happySpecReduce_1  18 happyReduction_32
happyReduction_32 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn18
		 (Opt happy_var_1
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_2  19 happyReduction_33
happyReduction_33 (HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn19
		 (Else happy_var_2
	)
happyReduction_33 _ _  = notHappyAtAll 

happyReduce_34 = happyReduce 6 20 happyReduction_34
happyReduction_34 ((HappyAbsSyn19  happy_var_6) `HappyStk`
	(HappyAbsSyn16  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (Condition happy_var_3 happy_var_5 happy_var_6
	) `HappyStk` happyRest

happyReduce_35 = happyReduce 5 20 happyReduction_35
happyReduction_35 ((HappyAbsSyn16  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (Condition happy_var_3 happy_var_5 (ElseNop)
	) `HappyStk` happyRest

happyReduce_36 = happyReduce 5 20 happyReduction_36
happyReduction_36 ((HappyAbsSyn16  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (While happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_37 = happyReduce 9 20 happyReduction_37
happyReduction_37 ((HappyAbsSyn16  happy_var_9) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (For happy_var_3 happy_var_5 happy_var_7 happy_var_9
	) `HappyStk` happyRest

happyReduce_38 = happySpecReduce_3  20 happyReduction_38
happyReduction_38 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn20
		 (Retn happy_var_2
	)
happyReduction_38 _ _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_2  20 happyReduction_39
happyReduction_39 _
	_
	 =  HappyAbsSyn20
		 (Void
	)

happyReduce_40 = happySpecReduce_3  21 happyReduction_40
happyReduction_40 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn21
		 (happy_var_2
	)
happyReduction_40 _ _ _  = notHappyAtAll 

happyReduce_41 = happyReduce 5 21 happyReduction_41
happyReduction_41 ((HappyAbsSyn21  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn21
		 (Ternop happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_42 = happySpecReduce_1  21 happyReduction_42
happyReduction_42 _
	 =  HappyAbsSyn21
		 (T
	)

happyReduce_43 = happySpecReduce_1  21 happyReduction_43
happyReduction_43 _
	 =  HappyAbsSyn21
		 (F
	)

happyReduce_44 = happySpecReduce_1  21 happyReduction_44
happyReduction_44 (HappyAbsSyn25  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1
	)
happyReduction_44 _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_1  21 happyReduction_45
happyReduction_45 (HappyTerminal (TokIdent happy_var_1))
	 =  HappyAbsSyn21
		 (Ident happy_var_1
	)
happyReduction_45 _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_1  21 happyReduction_46
happyReduction_46 (HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1
	)
happyReduction_46 _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_2  21 happyReduction_47
happyReduction_47 _
	_
	 =  HappyAbsSyn21
		 (Function Arglist
	)

happyReduce_48 = happySpecReduce_0  22 happyReduction_48
happyReduction_48  =  HappyAbsSyn22
		 ([]
	)

happyReduce_49 = happySpecReduce_3  22 happyReduction_49
happyReduction_49 (HappyAbsSyn22  happy_var_3)
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2 : happy_var_3
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_2  23 happyReduction_50
happyReduction_50 _
	_
	 =  HappyAbsSyn23
		 ([]
	)

happyReduce_51 = happyReduce 4 23 happyReduction_51
happyReduction_51 (_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn21  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn23
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest

happyReduce_52 = happySpecReduce_3  24 happyReduction_52
happyReduction_52 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Sub happy_var_1 happy_var_3
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_3  24 happyReduction_53
happyReduction_53 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Add happy_var_1 happy_var_3
	)
happyReduction_53 _ _ _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_3  24 happyReduction_54
happyReduction_54 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Mul happy_var_1 happy_var_3
	)
happyReduction_54 _ _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_3  24 happyReduction_55
happyReduction_55 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Div happy_var_1 happy_var_3
	)
happyReduction_55 _ _ _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_3  24 happyReduction_56
happyReduction_56 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Mod happy_var_1 happy_var_3
	)
happyReduction_56 _ _ _  = notHappyAtAll 

happyReduce_57 = happySpecReduce_3  24 happyReduction_57
happyReduction_57 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Sal happy_var_1 happy_var_3
	)
happyReduction_57 _ _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_3  24 happyReduction_58
happyReduction_58 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Sar happy_var_1 happy_var_3
	)
happyReduction_58 _ _ _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_3  24 happyReduction_59
happyReduction_59 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop BAnd happy_var_1 happy_var_3
	)
happyReduction_59 _ _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_3  24 happyReduction_60
happyReduction_60 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop BOr happy_var_1 happy_var_3
	)
happyReduction_60 _ _ _  = notHappyAtAll 

happyReduce_61 = happySpecReduce_3  24 happyReduction_61
happyReduction_61 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Xor happy_var_1 happy_var_3
	)
happyReduction_61 _ _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_3  24 happyReduction_62
happyReduction_62 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop LAnd happy_var_1 happy_var_3
	)
happyReduction_62 _ _ _  = notHappyAtAll 

happyReduce_63 = happySpecReduce_3  24 happyReduction_63
happyReduction_63 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop LOr happy_var_1 happy_var_3
	)
happyReduction_63 _ _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_3  24 happyReduction_64
happyReduction_64 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Lt happy_var_1 happy_var_3
	)
happyReduction_64 _ _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_3  24 happyReduction_65
happyReduction_65 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Le happy_var_1 happy_var_3
	)
happyReduction_65 _ _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_3  24 happyReduction_66
happyReduction_66 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Gt happy_var_1 happy_var_3
	)
happyReduction_66 _ _ _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_3  24 happyReduction_67
happyReduction_67 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Ge happy_var_1 happy_var_3
	)
happyReduction_67 _ _ _  = notHappyAtAll 

happyReduce_68 = happySpecReduce_3  24 happyReduction_68
happyReduction_68 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Eql happy_var_1 happy_var_3
	)
happyReduction_68 _ _ _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_3  24 happyReduction_69
happyReduction_69 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn24
		 (Binop Neq happy_var_1 happy_var_3
	)
happyReduction_69 _ _ _  = notHappyAtAll 

happyReduce_70 = happySpecReduce_2  24 happyReduction_70
happyReduction_70 (HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn24
		 (Unop LNot happy_var_2
	)
happyReduction_70 _ _  = notHappyAtAll 

happyReduce_71 = happySpecReduce_2  24 happyReduction_71
happyReduction_71 (HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn24
		 (Unop BNot happy_var_2
	)
happyReduction_71 _ _  = notHappyAtAll 

happyReduce_72 = happySpecReduce_2  24 happyReduction_72
happyReduction_72 (HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn24
		 (Unop Neg happy_var_2
	)
happyReduction_72 _ _  = notHappyAtAll 

happyReduce_73 = happySpecReduce_1  25 happyReduction_73
happyReduction_73 (HappyTerminal (TokDec happy_var_1))
	 =  HappyAbsSyn25
		 (checkDec happy_var_1
	)
happyReduction_73 _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_1  25 happyReduction_74
happyReduction_74 (HappyTerminal (TokHex happy_var_1))
	 =  HappyAbsSyn25
		 (checkHex happy_var_1
	)
happyReduction_74 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 74 74 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TokLParen -> cont 26;
	TokRParen -> cont 27;
	TokLBrace -> cont 28;
	TokRBrace -> cont 29;
	TokSemi -> cont 30;
	TokComma -> cont 31;
	TokDec happy_dollar_dollar -> cont 32;
	TokHex happy_dollar_dollar -> cont 33;
	TokIdent happy_dollar_dollar -> cont 34;
	TokMain -> cont 35;
	TokReturn -> cont 36;
	TokInt -> cont 37;
	TokVoid -> cont 38;
	TokMinus -> cont 39;
	TokPlus -> cont 40;
	TokTimes -> cont 41;
	TokDiv -> cont 42;
	TokMod -> cont 43;
	TokAsgnop happy_dollar_dollar -> cont 44;
	TokReserved -> cont 45;
	TokTypeDef -> cont 46;
	TokAssert -> cont 47;
	TokWhile -> cont 48;
	TokXor -> cont 49;
	TokUnop LNot -> cont 50;
	TokUnop BNot -> cont 51;
	TokFor -> cont 52;
	TokTrue -> cont 53;
	TokFalse -> cont 54;
	TokBool -> cont 55;
	TokIf -> cont 56;
	TokElse -> cont 57;
	TokTIf -> cont 58;
	TokTElse -> cont 59;
	TokLess -> cont 60;
	TokGreater -> cont 61;
	TokGeq -> cont 62;
	TokLeq -> cont 63;
	TokBoolEq -> cont 64;
	TokNotEq -> cont 65;
	TokBoolAnd -> cont 66;
	TokBoolOr -> cont 67;
	TokAnd -> cont 68;
	TokOr -> cont 69;
	TokLshift -> cont 70;
	TokRshift -> cont 71;
	TokIncr -> cont 72;
	TokDecr -> cont 73;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 74 tk tks = happyError' (tks, explist)
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

