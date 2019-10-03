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
  , jobOptimization :: Integer
  , jobOutUnsafe    :: Bool
  , jobOutFormat    :: OF
  }

data OF
  = TC
  | Abs
  | Asm
  deriving Eq

defaultJob :: Job
defaultJob = Job
  { jobOut          = ""
  , jobSource       = ""
  , jobOptimization = 0
  , jobOutUnsafe    = False
  , jobOutFormat    = Abs
  }
