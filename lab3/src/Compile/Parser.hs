{-# OPTIONS_GHC -w #-}
{-# OPTIONS -XMagicHash -XBangPatterns -XTypeSynonymInstances -XFlexibleInstances -cpp #-}
#if __GLASGOW_HASKELL__ >= 710
{-# OPTIONS_GHC -XPartialTypeSignatures #-}
#endif
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import qualified GHC.Exts as Happy_GHC_Exts
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.11

newtype HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 = HappyAbsSyn HappyAny
#if __GLASGOW_HASKELL__ >= 607
type HappyAny = Happy_GHC_Exts.Any
#else
type HappyAny = forall a . a
#endif
happyIn4 :: t4 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn4 #-}
happyOut4 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t4
happyOut4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut4 #-}
happyIn5 :: t5 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn5 #-}
happyOut5 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t5
happyOut5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut5 #-}
happyIn6 :: t6 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn6 #-}
happyOut6 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t6
happyOut6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut6 #-}
happyIn7 :: t7 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn7 #-}
happyOut7 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t7
happyOut7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut7 #-}
happyIn8 :: t8 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn8 #-}
happyOut8 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t8
happyOut8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut8 #-}
happyIn9 :: t9 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn9 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn9 #-}
happyOut9 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t9
happyOut9 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut9 #-}
happyIn10 :: t10 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn10 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn10 #-}
happyOut10 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t10
happyOut10 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut10 #-}
happyIn11 :: t11 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn11 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn11 #-}
happyOut11 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t11
happyOut11 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut11 #-}
happyIn12 :: t12 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn12 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn12 #-}
happyOut12 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t12
happyOut12 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut12 #-}
happyIn13 :: t13 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn13 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn13 #-}
happyOut13 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t13
happyOut13 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut13 #-}
happyIn14 :: t14 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn14 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn14 #-}
happyOut14 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t14
happyOut14 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut14 #-}
happyIn15 :: t15 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn15 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn15 #-}
happyOut15 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t15
happyOut15 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut15 #-}
happyIn16 :: t16 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn16 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn16 #-}
happyOut16 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t16
happyOut16 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut16 #-}
happyIn17 :: t17 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn17 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn17 #-}
happyOut17 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t17
happyOut17 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut17 #-}
happyIn18 :: t18 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn18 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn18 #-}
happyOut18 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t18
happyOut18 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut18 #-}
happyIn19 :: t19 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn19 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn19 #-}
happyOut19 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t19
happyOut19 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut19 #-}
happyIn20 :: t20 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn20 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn20 #-}
happyOut20 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t20
happyOut20 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut20 #-}
happyIn21 :: t21 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn21 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn21 #-}
happyOut21 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t21
happyOut21 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut21 #-}
happyIn22 :: t22 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn22 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn22 #-}
happyOut22 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t22
happyOut22 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut22 #-}
happyIn23 :: t23 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn23 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn23 #-}
happyOut23 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t23
happyOut23 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut23 #-}
happyIn24 :: t24 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn24 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn24 #-}
happyOut24 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t24
happyOut24 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut24 #-}
happyIn25 :: t25 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn25 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn25 #-}
happyOut25 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t25
happyOut25 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut25 #-}
happyIn26 :: t26 -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyIn26 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn26 #-}
happyOut26 :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> t26
happyOut26 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut26 #-}
happyInTok :: (Token) -> (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26)
happyInTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyInTok #-}
happyOutTok :: (HappyAbsSyn t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26) -> (Token)
happyOutTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOutTok #-}


happyExpList :: HappyAddr
happyExpList = HappyA# "\x00\x00\x00\x00\x34\x20\x40\x00\x00\x00\x00\x00\x00\xd0\x80\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0d\x08\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0d\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x80\x40\x03\x00\x04\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x50\xfc\x01\xfa\x03\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x50\xfc\x01\xfa\x03\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x0f\x01\xfa\xff\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x14\x7f\x80\xfe\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x44\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0d\x00\x10\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\xc1\x1d\x80\x1d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x1f\x04\xe8\xff\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0c\x47\x00\x36\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x80\x00\x7c\x10\xa0\xff\x07\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\xc1\x11\x80\x0d\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\x70\x04\x60\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x00\x00\x7c\x00\x00\x00\x00\x00\x00\x00\x00\xf0\x01\x00\x00\x00\x00\x00\x00\x00\xc0\x07\x01\xf8\x69\x00\x00\x00\x00\x00\x1f\x00\xe0\x87\x01\x00\x00\x00\x00\x7c\x10\x80\xbf\x07\x00\x00\x00\x00\xf0\x41\x00\x7e\x1e\x00\x00\x00\x00\xc0\x07\x00\x78\x60\x00\x00\x00\x00\x00\x1f\x00\xe0\x81\x01\x00\x00\x00\x00\x7c\x00\x00\x00\x06\x00\x00\x00\x00\xf0\x01\x00\x00\x18\x00\x00\x00\x00\xc0\x07\x00\x00\x60\x00\x00\x00\x00\x00\x1f\x00\x00\x80\x01\x00\x00\x00\x00\x7c\x10\xe0\xff\x07\x00\x00\x00\x00\xf0\x01\x00\x7e\x1a\x00\x00\x00\x00\xc0\x07\x01\xfa\x7f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x00\x1c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\xc0\x07\x01\xfa\x7f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\xf0\x41\x80\xfe\x1f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x80\x00\x7c\x10\xa0\xff\x07\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x14\x7f\x80\xfe\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x40\xf1\x07\xe8\x0f\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x04\x47\x00\x36\x00\x00\x00\x00\x00\x10\x1c\x01\xd8\x00\x00\x00\x00\x00\x00\x00\x7c\x10\xa0\xff\x07\x00\x00\x00\x00\xf0\x41\x80\xfe\x1f\x00\x00\x00\x80\xc0\x07\x01\xfa\x7f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\xf0\x41\x80\xfe\x1f\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\xf1\x07\xe8\x0f\x00\x00\x00\x00\x00\xc1\x1d\x80\x1d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc5\x1f\xa0\x3f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"#

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parseTokens","Program","Funs","Gdecl","Fdecl","Fdefn","Param","ParamlistFollow","Paramlist","Typedef","Block","Type","Decl","Stmts","Stmt","Simp","Simpopt","Elseopt","Control","Exp","ArglistFollow","Arglist","Operation","Intconst","'('","')'","'{'","'}'","';'","','","dec","hex","ident","ret","int","void","'-'","'+'","'*'","'/'","'%'","asgnop","kill","typedef","assert","while","'^'","'!'","'~'","for","true","false","bool","if","else","'?'","':'","'<'","'>'","'>='","'<='","'=='","'!='","'&&'","'||'","'&'","'|'","'<<'","'>>'","'++'","'--'","%eof"]
        bit_start = st * 74
        bit_end = (st + 1) * 74
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..73]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

happyActOffsets :: HappyAddr
happyActOffsets = HappyA# "\x2a\x00\x2a\x00\x00\x00\x2a\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\xfa\xff\x00\x00\xd9\xff\x17\x00\x2d\x00\x00\x00\x2c\x00\x3d\x00\x2f\x00\x00\x00\x31\x00\x29\x00\x00\x00\x00\x00\xed\x01\x34\x00\x00\x00\x41\x00\xed\x01\x3c\x00\x00\x00\xf2\x00\x00\x00\x00\x00\x39\x02\xed\x01\x00\x00\x00\x00\x01\x00\x14\x02\x39\x02\x49\x00\x39\x02\x39\x02\x4b\x00\x00\x00\x00\x00\x60\x00\x00\x00\x5e\x00\xfa\xff\x5c\x00\x00\x00\x39\x02\x0b\x02\x00\x00\x62\x00\x00\x00\x39\x02\x00\x00\x80\x00\x00\x00\x00\x00\x30\x02\x72\x00\xff\xff\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x39\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x39\x02\x4e\x00\x4e\x00\x99\x01\xc6\x01\x57\x01\x78\x01\xb7\x00\xb7\x00\x04\x00\x04\x00\x04\x00\x04\x00\x15\x01\xa5\x01\x36\x01\x00\x00\x00\x00\x00\x00\x0b\x00\x0b\x00\x00\x00\x00\x00\xd1\x00\x00\x00\x00\x00\x2b\x00\x00\x00\x82\x00\x57\x00\x00\x00\xed\x01\x39\x02\xed\x01\xae\x00\x39\x02\x39\x02\x36\x01\x36\x01\xd1\x00\x00\x00\x00\x00\xa9\x00\x9c\x00\x00\x00\xed\x01\x0b\x02\x00\x00\xba\x00\x00\x00\xed\x01\x00\x00\x00\x00"#

happyGotoOffsets :: HappyAddr
happyGotoOffsets = HappyA# "\x65\x02\xe8\x00\x00\x00\x04\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x95\x00\x00\x00\x00\x00\x00\x00\x9a\x00\x00\x00\xb4\x00\x13\x00\x00\x00\x00\x00\xb9\x00\x00\x00\x00\x00\x00\x00\x5f\x00\x00\x00\x00\x00\x00\x00\x88\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf2\xff\x1d\x01\x00\x00\x00\x00\xaf\x00\x2e\x00\x5d\x00\x00\x00\x74\x00\x76\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x14\x00\xc4\x00\x00\x00\x86\x00\x4c\x02\x00\x00\xc9\x00\x00\x00\x9d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x9f\x00\x00\x00\x00\x00\xac\x00\xfb\x00\x1b\x01\x3c\x01\x5d\x01\x7e\x01\xc8\x01\xd0\x01\xe9\x01\xeb\x01\xfb\x01\x29\x02\x38\x02\x5c\x02\x5e\x02\x63\x02\x68\x02\x6a\x02\x6f\x02\x71\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x76\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc5\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3e\x01\x78\x02\x5f\x01\x00\x00\x7d\x02\x7f\x02\x00\x00\x00\x00\xd2\x00\x00\x00\x00\x00\x00\x00\xd6\x00\x00\x00\x80\x01\x4e\x02\x00\x00\x00\x00\x00\x00\xce\x01\x00\x00\x00\x00"#

happyAdjustOffset :: Happy_GHC_Exts.Int# -> Happy_GHC_Exts.Int#
happyAdjustOffset off = off

happyDefActions :: HappyAddr
happyDefActions = HappyA# "\xfd\xff\x00\x00\xfe\xff\xfd\xff\xfb\xff\xfa\xff\xf9\xff\x00\x00\xed\xff\xef\xff\xec\xff\x00\x00\xee\xff\x00\x00\x00\x00\x00\x00\xfc\xff\xf8\xff\x00\x00\x00\x00\xf1\xff\xf5\xff\x00\x00\xf3\xff\xf7\xff\xe9\xff\x00\x00\xe1\xff\x00\x00\xe9\xff\x00\x00\xe7\xff\xe0\xff\xd0\xff\xd2\xff\x00\x00\xe9\xff\xb5\xff\xb4\xff\xd1\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xd4\xff\xd3\xff\x00\x00\xf6\xff\x00\x00\x00\x00\xf5\xff\xf2\xff\x00\x00\xdf\xff\xb7\xff\xd1\xff\xb8\xff\x00\x00\xb6\xff\x00\x00\xd7\xff\xcf\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe3\xff\xe2\xff\xe6\xff\xe8\xff\xf0\xff\xea\xff\x00\x00\xc4\xff\xc5\xff\xc2\xff\xc3\xff\xbf\xff\xc0\xff\xb9\xff\xba\xff\xbd\xff\xbb\xff\xbc\xff\xbe\xff\x00\x00\xc1\xff\xe4\xff\xc6\xff\xc7\xff\xc8\xff\xc9\xff\xca\xff\xd6\xff\xe5\xff\xce\xff\xcc\xff\xd8\xff\x00\x00\xde\xff\x00\x00\x00\x00\xf4\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xeb\xff\xd5\xff\xce\xff\xcb\xff\xda\xff\x00\x00\xdb\xff\xdc\xff\x00\x00\xdf\xff\xcd\xff\x00\x00\xdd\xff\x00\x00\xd9\xff"#

happyCheck :: HappyAddr
happyCheck = HappyA# "\xff\xff\x02\x00\x01\x00\x09\x00\x12\x00\x0b\x00\x0c\x00\x15\x00\x16\x00\x30\x00\x09\x00\x09\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x17\x00\x1d\x00\x05\x00\x05\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0a\x00\x20\x00\x09\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x02\x00\x01\x00\x03\x00\x2c\x00\x2d\x00\x09\x00\x09\x00\x05\x00\x0b\x00\x0c\x00\x06\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x09\x00\x14\x00\x02\x00\x12\x00\x05\x00\x17\x00\x15\x00\x16\x00\x04\x00\x09\x00\x1d\x00\x0b\x00\x0c\x00\x01\x00\x20\x00\x01\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x02\x00\x1d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x02\x00\x01\x00\x06\x00\x01\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x04\x00\x20\x00\x12\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x05\x00\x12\x00\x05\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x0a\x00\x20\x00\x07\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x05\x00\x12\x00\x02\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x1f\x00\x02\x00\x09\x00\x12\x00\x06\x00\x17\x00\x15\x00\x16\x00\x14\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x20\x00\x06\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x06\x00\x13\x00\x22\x00\x23\x00\x24\x00\x25\x00\x14\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x2c\x00\x2d\x00\x13\x00\x10\x00\xff\xff\x17\x00\x01\x00\x02\x00\x03\x00\x04\x00\xff\xff\xff\xff\xff\xff\x08\x00\x20\x00\x0a\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x12\x00\x01\x00\x02\x00\x03\x00\x04\x00\x17\x00\xff\xff\xff\xff\x08\x00\x12\x00\x0a\x00\xff\xff\x15\x00\x16\x00\x20\x00\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x2e\x00\x2f\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\x20\x00\x21\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\xff\xff\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\x20\x00\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\xff\xff\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\xff\xff\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x28\x00\xff\xff\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\xff\xff\x0d\x00\x0e\x00\x17\x00\x12\x00\x11\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\xff\xff\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\xff\xff\xff\xff\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x17\x00\xff\xff\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\xff\xff\xff\xff\xff\xff\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\xff\xff\xff\xff\x2a\x00\xff\xff\x2c\x00\x2d\x00\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\xff\xff\xff\xff\x2a\x00\xff\xff\x2c\x00\x2d\x00\x0d\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x0a\x00\x0b\x00\x12\x00\x0d\x00\x0e\x00\x15\x00\x16\x00\x11\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\x22\x00\x23\x00\x24\x00\x25\x00\x26\x00\x27\x00\x01\x00\xff\xff\x03\x00\xff\xff\x2c\x00\x2d\x00\x07\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\x16\x00\xff\xff\x18\x00\x19\x00\x1a\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x01\x00\x12\x00\xff\xff\xff\xff\x15\x00\x16\x00\x07\x00\x08\x00\x09\x00\x01\x00\x0b\x00\x0c\x00\x0d\x00\x05\x00\xff\xff\x07\x00\x08\x00\x09\x00\xff\xff\xff\xff\xff\xff\x0d\x00\xff\xff\x18\x00\x19\x00\xff\xff\x1b\x00\x1c\x00\x1d\x00\xff\xff\xff\xff\xff\xff\x18\x00\x19\x00\xff\xff\x1b\x00\x1c\x00\x01\x00\x02\x00\xff\xff\xff\xff\xff\xff\xff\xff\x07\x00\x08\x00\x09\x00\x01\x00\x12\x00\xff\xff\x0d\x00\x15\x00\x16\x00\x07\x00\x08\x00\x09\x00\xff\xff\xff\xff\xff\xff\x0d\x00\xff\xff\x18\x00\x19\x00\x12\x00\x1b\x00\x1c\x00\x15\x00\x16\x00\xff\xff\xff\xff\x18\x00\x19\x00\xff\xff\x1b\x00\x1c\x00\x0a\x00\x0b\x00\x0a\x00\x0b\x00\x0e\x00\x0f\x00\x0e\x00\x0f\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x00\x00\x01\x00\x02\x00\x03\x00\x04\x00\xff\xff\xff\xff\xff\xff\x08\x00\x12\x00\x0a\x00\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x12\x00\xff\xff\xff\xff\x15\x00\x16\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\x12\x00\xff\xff\x12\x00\x15\x00\x16\x00\x15\x00\x16\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"#

happyTable :: HappyAddr
happyTable = HappyA# "\x00\x00\x73\x00\x41\x00\x09\x00\x42\x00\x0a\x00\x0b\x00\x21\x00\x22\x00\xff\xff\xed\xff\x10\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x4a\x00\x0d\x00\x15\x00\x34\x00\x46\x00\x47\x00\x48\x00\x16\x00\x16\x00\x4b\x00\x14\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x7f\x00\x13\x00\x1a\x00\x56\x00\x57\x00\x32\x00\x09\x00\x15\x00\x0a\x00\x0b\x00\x34\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x5d\x00\x0c\x00\x18\x00\x3d\x00\x5a\x00\x4a\x00\x21\x00\x22\x00\x5c\x00\x09\x00\x0d\x00\x0a\x00\x0b\x00\x3c\x00\x4b\x00\x38\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x7d\x00\x0d\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x36\x00\x37\x00\x34\x00\x41\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x4a\x00\x3c\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x74\x00\x4b\x00\x5e\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x77\x00\x3a\x00\x7e\x00\x38\x00\x21\x00\x22\x00\x21\x00\x22\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x5a\x00\x1d\x00\x1e\x00\x4a\x00\x7a\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x0e\x00\x4b\x00\x11\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x8c\x00\x77\x00\x86\x00\x74\x00\x21\x00\x22\x00\x21\x00\x22\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x8b\x00\x90\x00\x18\x00\x71\x00\x32\x00\x4a\x00\x21\x00\x22\x00\x3f\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x4b\x00\x7b\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x81\x00\x7f\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x3f\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x56\x00\x57\x00\x8c\x00\x89\x00\x00\x00\x4a\x00\x02\x00\x03\x00\x04\x00\x05\x00\x00\x00\x00\x00\x00\x00\x06\x00\x4b\x00\x07\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x49\x00\x10\x00\x03\x00\x04\x00\x05\x00\x4a\x00\x00\x00\x00\x00\x06\x00\x70\x00\x07\x00\x00\x00\x21\x00\x22\x00\x4b\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x58\x00\x59\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x41\x00\x1d\x00\x1e\x00\x4a\x00\x6f\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x4b\x00\x82\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x00\x00\x88\x00\x1e\x00\x4a\x00\x6e\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x4b\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x53\x00\x54\x00\x55\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x00\x00\x86\x00\x1e\x00\x4a\x00\x6d\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x00\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x52\x00\x00\x00\x54\x00\x55\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x00\x00\x8e\x00\x1e\x00\x4a\x00\x6c\x00\x1f\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x00\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x00\x00\x00\x00\x54\x00\x55\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x4a\x00\x00\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x00\x00\x00\x00\x00\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x00\x00\x00\x00\x54\x00\x00\x00\x56\x00\x57\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x00\x00\x00\x00\x54\x00\x00\x00\x56\x00\x57\x00\x44\x00\x45\x00\x46\x00\x47\x00\x48\x00\x1a\x00\x1b\x00\x6b\x00\x90\x00\x1e\x00\x21\x00\x22\x00\x1f\x00\x20\x00\x00\x00\x6a\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x4c\x00\x4d\x00\x4e\x00\x4f\x00\x50\x00\x51\x00\x24\x00\x00\x00\x25\x00\x00\x00\x56\x00\x57\x00\x26\x00\x27\x00\x28\x00\x29\x00\x0a\x00\x0b\x00\x2a\x00\x69\x00\x00\x00\x68\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x2b\x00\x00\x00\x2c\x00\x2d\x00\x2e\x00\x2f\x00\x30\x00\x0d\x00\x31\x00\x24\x00\x67\x00\x00\x00\x00\x00\x21\x00\x22\x00\x26\x00\x27\x00\x28\x00\x24\x00\x0a\x00\x0b\x00\x2a\x00\x3f\x00\x00\x00\x26\x00\x27\x00\x3a\x00\x00\x00\x00\x00\x00\x00\x2a\x00\x00\x00\x2c\x00\x2d\x00\x00\x00\x2f\x00\x30\x00\x0d\x00\x00\x00\x00\x00\x00\x00\x2c\x00\x2d\x00\x00\x00\x2f\x00\x30\x00\x24\x00\x76\x00\x00\x00\x00\x00\x00\x00\x00\x00\x26\x00\x27\x00\x3a\x00\x24\x00\x66\x00\x00\x00\x2a\x00\x21\x00\x22\x00\x26\x00\x27\x00\x3a\x00\x00\x00\x00\x00\x00\x00\x2a\x00\x00\x00\x2c\x00\x2d\x00\x65\x00\x2f\x00\x30\x00\x21\x00\x22\x00\x00\x00\x00\x00\x2c\x00\x2d\x00\x00\x00\x2f\x00\x30\x00\x1a\x00\x1b\x00\x1a\x00\x1b\x00\x78\x00\x79\x00\x78\x00\x8d\x00\x20\x00\x00\x00\x20\x00\x21\x00\x22\x00\x21\x00\x22\x00\x0d\x00\x02\x00\x03\x00\x04\x00\x05\x00\x00\x00\x00\x00\x00\x00\x06\x00\x64\x00\x07\x00\x63\x00\x21\x00\x22\x00\x21\x00\x22\x00\x62\x00\x00\x00\x00\x00\x21\x00\x22\x00\x61\x00\x00\x00\x60\x00\x21\x00\x22\x00\x21\x00\x22\x00\x5f\x00\x00\x00\x5e\x00\x21\x00\x22\x00\x21\x00\x22\x00\x82\x00\x00\x00\x87\x00\x21\x00\x22\x00\x21\x00\x22\x00\x84\x00\x00\x00\x83\x00\x21\x00\x22\x00\x21\x00\x22\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"#

happyReduceArr = Happy_Data_Array.array (1, 75) [
	(1 , happyReduce_1),
	(2 , happyReduce_2),
	(3 , happyReduce_3),
	(4 , happyReduce_4),
	(5 , happyReduce_5),
	(6 , happyReduce_6),
	(7 , happyReduce_7),
	(8 , happyReduce_8),
	(9 , happyReduce_9),
	(10 , happyReduce_10),
	(11 , happyReduce_11),
	(12 , happyReduce_12),
	(13 , happyReduce_13),
	(14 , happyReduce_14),
	(15 , happyReduce_15),
	(16 , happyReduce_16),
	(17 , happyReduce_17),
	(18 , happyReduce_18),
	(19 , happyReduce_19),
	(20 , happyReduce_20),
	(21 , happyReduce_21),
	(22 , happyReduce_22),
	(23 , happyReduce_23),
	(24 , happyReduce_24),
	(25 , happyReduce_25),
	(26 , happyReduce_26),
	(27 , happyReduce_27),
	(28 , happyReduce_28),
	(29 , happyReduce_29),
	(30 , happyReduce_30),
	(31 , happyReduce_31),
	(32 , happyReduce_32),
	(33 , happyReduce_33),
	(34 , happyReduce_34),
	(35 , happyReduce_35),
	(36 , happyReduce_36),
	(37 , happyReduce_37),
	(38 , happyReduce_38),
	(39 , happyReduce_39),
	(40 , happyReduce_40),
	(41 , happyReduce_41),
	(42 , happyReduce_42),
	(43 , happyReduce_43),
	(44 , happyReduce_44),
	(45 , happyReduce_45),
	(46 , happyReduce_46),
	(47 , happyReduce_47),
	(48 , happyReduce_48),
	(49 , happyReduce_49),
	(50 , happyReduce_50),
	(51 , happyReduce_51),
	(52 , happyReduce_52),
	(53 , happyReduce_53),
	(54 , happyReduce_54),
	(55 , happyReduce_55),
	(56 , happyReduce_56),
	(57 , happyReduce_57),
	(58 , happyReduce_58),
	(59 , happyReduce_59),
	(60 , happyReduce_60),
	(61 , happyReduce_61),
	(62 , happyReduce_62),
	(63 , happyReduce_63),
	(64 , happyReduce_64),
	(65 , happyReduce_65),
	(66 , happyReduce_66),
	(67 , happyReduce_67),
	(68 , happyReduce_68),
	(69 , happyReduce_69),
	(70 , happyReduce_70),
	(71 , happyReduce_71),
	(72 , happyReduce_72),
	(73 , happyReduce_73),
	(74 , happyReduce_74),
	(75 , happyReduce_75)
	]

happy_n_terms = 49 :: Int
happy_n_nonterms = 23 :: Int

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_1 = happySpecReduce_1  0# happyReduction_1
happyReduction_1 happy_x_1
	 =  case happyOut5 happy_x_1 of { happy_var_1 -> 
	happyIn4
		 (Program happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_2 = happySpecReduce_0  1# happyReduction_2
happyReduction_2  =  happyIn5
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_3 = happySpecReduce_2  1# happyReduction_3
happyReduction_3 happy_x_2
	happy_x_1
	 =  case happyOut6 happy_x_1 of { happy_var_1 -> 
	case happyOut5 happy_x_2 of { happy_var_2 -> 
	happyIn5
		 (happy_var_1 : happy_var_2
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_4 = happySpecReduce_1  2# happyReduction_4
happyReduction_4 happy_x_1
	 =  case happyOut7 happy_x_1 of { happy_var_1 -> 
	happyIn6
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_5 = happySpecReduce_1  2# happyReduction_5
happyReduction_5 happy_x_1
	 =  case happyOut8 happy_x_1 of { happy_var_1 -> 
	happyIn6
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_6 = happySpecReduce_1  2# happyReduction_6
happyReduction_6 happy_x_1
	 =  case happyOut12 happy_x_1 of { happy_var_1 -> 
	happyIn6
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_7 = happySpecReduce_3  3# happyReduction_7
happyReduction_7 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut14 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokIdent happy_var_2) -> 
	case happyOut11 happy_x_3 of { happy_var_3 -> 
	happyIn7
		 (Fdecl happy_var_1 happy_var_2 happy_var_3
	)}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_8 = happyReduce 4# 4# happyReduction_8
happyReduction_8 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut14 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokIdent happy_var_2) -> 
	case happyOut11 happy_x_3 of { happy_var_3 -> 
	case happyOut13 happy_x_4 of { happy_var_4 -> 
	happyIn8
		 (Fdefn happy_var_1 happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest}}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_9 = happySpecReduce_2  5# happyReduction_9
happyReduction_9 happy_x_2
	happy_x_1
	 =  case happyOut14 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokIdent happy_var_2) -> 
	happyIn9
		 ((happy_var_1,happy_var_2)
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_10 = happySpecReduce_0  6# happyReduction_10
happyReduction_10  =  happyIn10
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_11 = happySpecReduce_3  6# happyReduction_11
happyReduction_11 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut9 happy_x_2 of { happy_var_2 -> 
	case happyOut10 happy_x_3 of { happy_var_3 -> 
	happyIn10
		 (happy_var_2 : happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_12 = happySpecReduce_2  7# happyReduction_12
happyReduction_12 happy_x_2
	happy_x_1
	 =  happyIn11
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_13 = happyReduce 4# 7# happyReduction_13
happyReduction_13 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut9 happy_x_2 of { happy_var_2 -> 
	case happyOut10 happy_x_3 of { happy_var_3 -> 
	happyIn11
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_14 = happyReduce 4# 8# happyReduction_14
happyReduction_14 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut14 happy_x_2 of { happy_var_2 -> 
	case happyOutTok happy_x_3 of { (TokIdent happy_var_3) -> 
	happyIn12
		 (Typedef happy_var_2 happy_var_3
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_15 = happySpecReduce_3  9# happyReduction_15
happyReduction_15 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut16 happy_x_2 of { happy_var_2 -> 
	happyIn13
		 (happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_16 = happySpecReduce_1  10# happyReduction_16
happyReduction_16 happy_x_1
	 =  happyIn14
		 (INTEGER
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_17 = happySpecReduce_1  10# happyReduction_17
happyReduction_17 happy_x_1
	 =  happyIn14
		 (BOOLEAN
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_18 = happySpecReduce_1  10# happyReduction_18
happyReduction_18 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokIdent happy_var_1) -> 
	happyIn14
		 (DEF happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_19 = happySpecReduce_1  10# happyReduction_19
happyReduction_19 happy_x_1
	 =  happyIn14
		 (VOID
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_20 = happyReduce 4# 11# happyReduction_20
happyReduction_20 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut14 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokIdent happy_var_2) -> 
	case happyOutTok happy_x_3 of { (TokAsgnop happy_var_3) -> 
	case happyOut22 happy_x_4 of { happy_var_4 -> 
	happyIn15
		 (checkDeclAsgn happy_var_2 happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest}}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_21 = happySpecReduce_2  11# happyReduction_21
happyReduction_21 happy_x_2
	happy_x_1
	 =  case happyOut14 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokIdent happy_var_2) -> 
	happyIn15
		 (JustDecl happy_var_2 happy_var_1
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_22 = happySpecReduce_0  12# happyReduction_22
happyReduction_22  =  happyIn16
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_23 = happySpecReduce_2  12# happyReduction_23
happyReduction_23 happy_x_2
	happy_x_1
	 =  case happyOut17 happy_x_1 of { happy_var_1 -> 
	case happyOut16 happy_x_2 of { happy_var_2 -> 
	happyIn16
		 (happy_var_1 : happy_var_2
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_24 = happySpecReduce_1  13# happyReduction_24
happyReduction_24 happy_x_1
	 =  case happyOut21 happy_x_1 of { happy_var_1 -> 
	happyIn17
		 (ControlStmt happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_25 = happySpecReduce_2  13# happyReduction_25
happyReduction_25 happy_x_2
	happy_x_1
	 =  case happyOut18 happy_x_1 of { happy_var_1 -> 
	happyIn17
		 (Simp happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_26 = happySpecReduce_3  13# happyReduction_26
happyReduction_26 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut16 happy_x_2 of { happy_var_2 -> 
	happyIn17
		 (Stmts happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_27 = happySpecReduce_3  14# happyReduction_27
happyReduction_27 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOutTok happy_x_2 of { (TokAsgnop happy_var_2) -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn18
		 (checkSimpAsgn happy_var_1 happy_var_2 happy_var_3
	)}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_28 = happySpecReduce_2  14# happyReduction_28
happyReduction_28 happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	happyIn18
		 (checkSimpAsgnP happy_var_1 Incr
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_29 = happySpecReduce_2  14# happyReduction_29
happyReduction_29 happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	happyIn18
		 (checkSimpAsgnP happy_var_1 Decr
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_30 = happySpecReduce_1  14# happyReduction_30
happyReduction_30 happy_x_1
	 =  case happyOut15 happy_x_1 of { happy_var_1 -> 
	happyIn18
		 (Decl happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_31 = happySpecReduce_1  14# happyReduction_31
happyReduction_31 happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	happyIn18
		 (Exp happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_32 = happySpecReduce_0  15# happyReduction_32
happyReduction_32  =  happyIn19
		 (SimpNop
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_33 = happySpecReduce_1  15# happyReduction_33
happyReduction_33 happy_x_1
	 =  case happyOut18 happy_x_1 of { happy_var_1 -> 
	happyIn19
		 (Opt happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_34 = happySpecReduce_2  16# happyReduction_34
happyReduction_34 happy_x_2
	happy_x_1
	 =  case happyOut17 happy_x_2 of { happy_var_2 -> 
	happyIn20
		 (Else happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_35 = happyReduce 6# 17# happyReduction_35
happyReduction_35 (happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut22 happy_x_3 of { happy_var_3 -> 
	case happyOut17 happy_x_5 of { happy_var_5 -> 
	case happyOut20 happy_x_6 of { happy_var_6 -> 
	happyIn21
		 (Condition happy_var_3 happy_var_5 happy_var_6
	) `HappyStk` happyRest}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_36 = happyReduce 5# 17# happyReduction_36
happyReduction_36 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut22 happy_x_3 of { happy_var_3 -> 
	case happyOut17 happy_x_5 of { happy_var_5 -> 
	happyIn21
		 (Condition happy_var_3 happy_var_5 (ElseNop)
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_37 = happyReduce 5# 17# happyReduction_37
happyReduction_37 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut22 happy_x_3 of { happy_var_3 -> 
	case happyOut17 happy_x_5 of { happy_var_5 -> 
	happyIn21
		 (While happy_var_3 happy_var_5
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_38 = happyReduce 9# 17# happyReduction_38
happyReduction_38 (happy_x_9 `HappyStk`
	happy_x_8 `HappyStk`
	happy_x_7 `HappyStk`
	happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut19 happy_x_3 of { happy_var_3 -> 
	case happyOut22 happy_x_5 of { happy_var_5 -> 
	case happyOut19 happy_x_7 of { happy_var_7 -> 
	case happyOut17 happy_x_9 of { happy_var_9 -> 
	happyIn21
		 (For happy_var_3 happy_var_5 happy_var_7 happy_var_9
	) `HappyStk` happyRest}}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_39 = happySpecReduce_3  17# happyReduction_39
happyReduction_39 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	happyIn21
		 (Retn happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_40 = happySpecReduce_2  17# happyReduction_40
happyReduction_40 happy_x_2
	happy_x_1
	 =  happyIn21
		 (Void
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_41 = happySpecReduce_3  18# happyReduction_41
happyReduction_41 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	happyIn22
		 (happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_42 = happyReduce 5# 18# happyReduction_42
happyReduction_42 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	case happyOut22 happy_x_5 of { happy_var_5 -> 
	happyIn22
		 (Ternop happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest}}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_43 = happySpecReduce_1  18# happyReduction_43
happyReduction_43 happy_x_1
	 =  happyIn22
		 (T
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_44 = happySpecReduce_1  18# happyReduction_44
happyReduction_44 happy_x_1
	 =  happyIn22
		 (F
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_45 = happySpecReduce_1  18# happyReduction_45
happyReduction_45 happy_x_1
	 =  case happyOut26 happy_x_1 of { happy_var_1 -> 
	happyIn22
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_46 = happySpecReduce_1  18# happyReduction_46
happyReduction_46 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokIdent happy_var_1) -> 
	happyIn22
		 (Ident happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_47 = happySpecReduce_1  18# happyReduction_47
happyReduction_47 happy_x_1
	 =  case happyOut25 happy_x_1 of { happy_var_1 -> 
	happyIn22
		 (happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_48 = happySpecReduce_2  18# happyReduction_48
happyReduction_48 happy_x_2
	happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokIdent happy_var_1) -> 
	case happyOut24 happy_x_2 of { happy_var_2 -> 
	happyIn22
		 (Function happy_var_1 happy_var_2
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_49 = happySpecReduce_0  19# happyReduction_49
happyReduction_49  =  happyIn23
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_50 = happySpecReduce_3  19# happyReduction_50
happyReduction_50 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	case happyOut23 happy_x_3 of { happy_var_3 -> 
	happyIn23
		 (happy_var_2 : happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_51 = happySpecReduce_2  20# happyReduction_51
happyReduction_51 happy_x_2
	happy_x_1
	 =  happyIn24
		 ([]
	)

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_52 = happyReduce 4# 20# happyReduction_52
happyReduction_52 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut22 happy_x_2 of { happy_var_2 -> 
	case happyOut23 happy_x_3 of { happy_var_3 -> 
	happyIn24
		 (happy_var_2 : happy_var_3
	) `HappyStk` happyRest}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_53 = happySpecReduce_3  21# happyReduction_53
happyReduction_53 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Sub happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_54 = happySpecReduce_3  21# happyReduction_54
happyReduction_54 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Add happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_55 = happySpecReduce_3  21# happyReduction_55
happyReduction_55 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Mul happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_56 = happySpecReduce_3  21# happyReduction_56
happyReduction_56 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Div happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_57 = happySpecReduce_3  21# happyReduction_57
happyReduction_57 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Mod happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_58 = happySpecReduce_3  21# happyReduction_58
happyReduction_58 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Sal happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_59 = happySpecReduce_3  21# happyReduction_59
happyReduction_59 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Sar happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_60 = happySpecReduce_3  21# happyReduction_60
happyReduction_60 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop BAnd happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_61 = happySpecReduce_3  21# happyReduction_61
happyReduction_61 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop BOr happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_62 = happySpecReduce_3  21# happyReduction_62
happyReduction_62 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Xor happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_63 = happySpecReduce_3  21# happyReduction_63
happyReduction_63 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop LAnd happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_64 = happySpecReduce_3  21# happyReduction_64
happyReduction_64 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop LOr happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_65 = happySpecReduce_3  21# happyReduction_65
happyReduction_65 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Lt happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_66 = happySpecReduce_3  21# happyReduction_66
happyReduction_66 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Le happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_67 = happySpecReduce_3  21# happyReduction_67
happyReduction_67 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Gt happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_68 = happySpecReduce_3  21# happyReduction_68
happyReduction_68 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Ge happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_69 = happySpecReduce_3  21# happyReduction_69
happyReduction_69 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Eql happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_70 = happySpecReduce_3  21# happyReduction_70
happyReduction_70 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	case happyOut22 happy_x_3 of { happy_var_3 -> 
	happyIn25
		 (Binop Neq happy_var_1 happy_var_3
	)}}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_71 = happySpecReduce_2  21# happyReduction_71
happyReduction_71 happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	happyIn25
		 (Unop LNot happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_72 = happySpecReduce_2  21# happyReduction_72
happyReduction_72 happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	happyIn25
		 (Unop BNot happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_73 = happySpecReduce_2  21# happyReduction_73
happyReduction_73 happy_x_2
	happy_x_1
	 =  case happyOut22 happy_x_2 of { happy_var_2 -> 
	happyIn25
		 (Unop Neg happy_var_2
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_74 = happySpecReduce_1  22# happyReduction_74
happyReduction_74 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokDec happy_var_1) -> 
	happyIn26
		 (checkDec happy_var_1
	)}

#if __GLASGOW_HASKELL__ >= 710
#endif
happyReduce_75 = happySpecReduce_1  22# happyReduction_75
happyReduction_75 happy_x_1
	 =  case happyOutTok happy_x_1 of { (TokHex happy_var_1) -> 
	happyIn26
		 (checkHex happy_var_1
	)}

happyNewToken action sts stk [] =
	happyDoAction 48# notHappyAtAll action sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = happyDoAction i tk action sts stk tks in
	case tk of {
	TokLParen -> cont 1#;
	TokRParen -> cont 2#;
	TokLBrace -> cont 3#;
	TokRBrace -> cont 4#;
	TokSemi -> cont 5#;
	TokComma -> cont 6#;
	TokDec happy_dollar_dollar -> cont 7#;
	TokHex happy_dollar_dollar -> cont 8#;
	TokIdent happy_dollar_dollar -> cont 9#;
	TokReturn -> cont 10#;
	TokInt -> cont 11#;
	TokVoid -> cont 12#;
	TokMinus -> cont 13#;
	TokPlus -> cont 14#;
	TokTimes -> cont 15#;
	TokDiv -> cont 16#;
	TokMod -> cont 17#;
	TokAsgnop happy_dollar_dollar -> cont 18#;
	TokReserved -> cont 19#;
	TokTypeDef -> cont 20#;
	TokAssert -> cont 21#;
	TokWhile -> cont 22#;
	TokXor -> cont 23#;
	TokUnop LNot -> cont 24#;
	TokUnop BNot -> cont 25#;
	TokFor -> cont 26#;
	TokTrue -> cont 27#;
	TokFalse -> cont 28#;
	TokBool -> cont 29#;
	TokIf -> cont 30#;
	TokElse -> cont 31#;
	TokTIf -> cont 32#;
	TokTElse -> cont 33#;
	TokLess -> cont 34#;
	TokGreater -> cont 35#;
	TokGeq -> cont 36#;
	TokLeq -> cont 37#;
	TokBoolEq -> cont 38#;
	TokNotEq -> cont 39#;
	TokBoolAnd -> cont 40#;
	TokBoolOr -> cont 41#;
	TokAnd -> cont 42#;
	TokOr -> cont 43#;
	TokLshift -> cont 44#;
	TokRshift -> cont 45#;
	TokIncr -> cont 46#;
	TokDecr -> cont 47#;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 48# tk tks = happyError' (tks, explist)
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
 happySomeParser = happyThen (happyParse 0# tks) (\x -> happyReturn (let {x' = happyOut4 x} in x'))

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
{-# LINE 18 "<built-in>" #-}
{-# LINE 1 "/Users/rick/.stack/programs/x86_64-osx/ghc-8.6.5/lib/ghc-8.6.5/include/ghcversion.h" #-}
















{-# LINE 19 "<built-in>" #-}
{-# LINE 1 "/var/folders/r6/c7hn6nts1j7gqfp7plqpv1q40000gn/T/ghc47890_0/ghc_2.h" #-}

































































































































































































{-# LINE 20 "<built-in>" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp 













-- Do not remove this comment. Required to fix CPP parsing when using GCC and a clang-compiled alex.
#if __GLASGOW_HASKELL__ > 706
#define LT(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.<# m)) :: Bool)
#define GTE(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.>=# m)) :: Bool)
#define EQ(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.==# m)) :: Bool)
#else
#define LT(n,m) (n Happy_GHC_Exts.<# m)
#define GTE(n,m) (n Happy_GHC_Exts.>=# m)
#define EQ(n,m) (n Happy_GHC_Exts.==# m)
#endif

{-# LINE 43 "templates/GenericTemplate.hs" #-}

data Happy_IntList = HappyCons Happy_GHC_Exts.Int# Happy_IntList








{-# LINE 65 "templates/GenericTemplate.hs" #-}


{-# LINE 75 "templates/GenericTemplate.hs" #-}










infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is 0#, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept 0# tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
        (happyTcHack j (happyTcHack st)) (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action



happyDoAction i tk st
        = {- nothing -}
          

          case action of
                0#           -> {- nothing -}
                                     happyFail (happyExpListPerState ((Happy_GHC_Exts.I# (st)) :: Int)) i tk st
                -1#          -> {- nothing -}
                                     happyAccept i tk st
                n | LT(n,(0# :: Happy_GHC_Exts.Int#)) -> {- nothing -}
                                                   
                                                   (happyReduceArr Happy_Data_Array.! rule) i tk st
                                                   where rule = (Happy_GHC_Exts.I# ((Happy_GHC_Exts.negateInt# ((n Happy_GHC_Exts.+# (1# :: Happy_GHC_Exts.Int#))))))
                n                 -> {- nothing -}
                                     

                                     happyShift new_state i tk st
                                     where new_state = (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#))
   where off    = happyAdjustOffset (indexShortOffAddr happyActOffsets st)
         off_i  = (off Happy_GHC_Exts.+#  i)
         check  = if GTE(off_i,(0# :: Happy_GHC_Exts.Int#))
                  then EQ(indexShortOffAddr happyCheck off_i, i)
                  else False
         action
          | check     = indexShortOffAddr happyTable off_i
          | otherwise = indexShortOffAddr happyDefActions st




indexShortOffAddr (HappyA# arr) off =
        Happy_GHC_Exts.narrow16Int# i
  where
        i = Happy_GHC_Exts.word2Int# (Happy_GHC_Exts.or# (Happy_GHC_Exts.uncheckedShiftL# high 8#) low)
        high = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr (off' Happy_GHC_Exts.+# 1#)))
        low  = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr off'))
        off' = off Happy_GHC_Exts.*# 2#




{-# INLINE happyLt #-}
happyLt x y = LT(x,y)


readArrayBit arr bit =
    Bits.testBit (Happy_GHC_Exts.I# (indexShortOffAddr arr ((unbox_int bit) `Happy_GHC_Exts.iShiftRA#` 4#))) (bit `mod` 16)
  where unbox_int (Happy_GHC_Exts.I# x) = x






data HappyAddr = HappyA# Happy_GHC_Exts.Addr#


-----------------------------------------------------------------------------
-- HappyState data type (not arrays)


{-# LINE 180 "templates/GenericTemplate.hs" #-}

-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state 0# tk st sts stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--     trace "shifting the error token" $
     happyDoAction i tk new_state (HappyCons (st) (sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state (HappyCons (st) (sts)) ((happyInTok (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_0 nt fn j tk st@((action)) sts stk
     = happyGoto nt j tk st (HappyCons (st) (sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@((HappyCons (st@(action)) (_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_2 nt fn j tk _ (HappyCons (_) (sts@((HappyCons (st@(action)) (_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_3 nt fn j tk _ (HappyCons (_) ((HappyCons (_) (sts@((HappyCons (st@(action)) (_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) sts of
         sts1@((HappyCons (st1@(action)) (_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (happyGoto nt j tk st1 sts1 r)

happyMonadReduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> happyGoto nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
         let drop_stk = happyDropStk k stk

             off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st1)
             off_i = (off Happy_GHC_Exts.+#  nt)
             new_state = indexShortOffAddr happyTable off_i




          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop 0# l = l
happyDrop n (HappyCons (_) (t)) = happyDrop (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) t

happyDropStk 0# l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Happy_GHC_Exts.-# (1#::Happy_GHC_Exts.Int#)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction


happyGoto nt j tk st = 
   {- nothing -}
   happyDoAction j tk new_state
   where off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st)
         off_i = (off Happy_GHC_Exts.+#  nt)
         new_state = indexShortOffAddr happyTable off_i




-----------------------------------------------------------------------------
-- Error recovery (0# is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist 0# tk old_st _ stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  0# tk old_st (HappyCons ((action)) (sts)) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        happyDoAction 0# tk action sts ((saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (action) sts stk =
--      trace "entering error recovery" $
        happyDoAction 0# tk action sts ( (Happy_GHC_Exts.unsafeCoerce# (Happy_GHC_Exts.I# (i))) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions


happyTcHack :: Happy_GHC_Exts.Int# -> a -> a
happyTcHack x y = y
{-# INLINE happyTcHack #-}


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


{-# NOINLINE happyDoAction #-}
{-# NOINLINE happyTable #-}
{-# NOINLINE happyCheck #-}
{-# NOINLINE happyActOffsets #-}
{-# NOINLINE happyGotoOffsets #-}
{-# NOINLINE happyDefActions #-}

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

