{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>

   Lift IO into Error
-}
module LiftIOE where

import Control.Monad.Trans.Except
import Control.Monad.IO.Class

--TODO make this actually properly catch errors like spoon
liftIOE :: IO a -> ExceptT String IO a
liftIOE = liftIO

liftEIO :: Either String a -> ExceptT String IO a
liftEIO (Left s)  = throwE s
liftEIO (Right x) = return x
