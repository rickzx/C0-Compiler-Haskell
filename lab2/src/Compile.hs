{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Rokhini Prabhu <rokhinip@andrew.cmu.edu>
                Anshu Bansal <anshumab@andrew.cmu.edu>
                Shyam Raghavan <shyamsur@andrew.cmu.edu>

   Main compiler module; takes a job and compiles it
-}
module Compile
  ( compile
  , Job(..)
  , defaultJob
  , OF(..)
  ) where

import System.IO

import Control.Monad.Trans.Except

import Compile.Types
import Compile.Lexer
import Compile.Parser
import Compile.Frontend.Elaborate
import Compile.Frontend.CheckEAST
import Compile.CodeGen
import Data.Maybe (fromMaybe)
import System.Environment
import Compile.Frontend.EASTOptimize

import LiftIOE

writeString :: FilePath -> String -> ExceptT String IO ()
writeString file s = liftIOE $ writeFile file s

writeIOString :: FilePath -> IO String -> ExceptT String IO ()
writeIOString file s = liftIOE $ s >>= writeFile file

compile :: Job -> IO ()
compile job = do
  inputHandle <- openFile (jobSource job) ReadMode
  hSetEncoding inputHandle utf8
  s <- hGetContents inputHandle
  res <- runExceptT $ do
    let 
      ast = parseTokens $ lexProgram s
      east = eGen ast
    liftEIO $ checkEAST east
    let
        optEast = optEAST east
    case jobOutFormat job of
      TC -> liftEIO (Right ()) -- By now, we should have thrown any typechecking errors
      Asm -> writeIOString (jobOut job) $ addHeader (asmGen optEast)
      Abs -> writeString (jobOut job) $ testPrintAAsm (fst $ codeGen optEast) (jobOut job)
  case res of
    Left msg -> error msg
    Right () -> return ()

addHeader :: String -> IO String
addHeader pgm = do
  os <- fromMaybe "Darwin" <$> lookupEnv "UNAME"
  let entry = if os == "Darwin" then "\t.globl  __c0_main\n__c0_main:\n" else "\t.globl  _c0_main\n_c0_main:\n"
  return (entry ++ pgm)