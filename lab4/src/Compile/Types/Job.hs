{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>
                Shyam Raghavan <shyamsur@andrew.cmu.edu>

   Defines a compiler phase or job
-}
module Compile.Types.Job where

data Job = Job
  { jobOut          :: FilePath
  , jobSource       :: FilePath
  , jobHeader       :: FilePath
  , jobOptimization :: Integer
  , jobOutUnsafe    :: Bool
  , jobOutFormat    :: OF
  } deriving Show

data OF
  = TC
  | Abs
  | Asm
  deriving (Eq, Show)

defaultJob :: Job
defaultJob = Job
  { jobOut          = ""
  , jobSource       = ""
  , jobHeader       = "../runtime/15411-l3.h0"
  , jobOptimization = 0
  , jobOutUnsafe    = False
  , jobOutFormat    = Abs
  }
