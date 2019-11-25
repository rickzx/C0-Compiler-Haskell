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

import Compile.CodeGen
import Compile.Frontend.CheckEAST
import Compile.Frontend.EASTOptimize
import Compile.Frontend.Elaborate
import Compile.Lexer
import Compile.Parser
import Compile.Backend.Peephole
import Compile.Types
import qualified Data.Map as Map
import Data.Maybe (fromMaybe)
import qualified Data.Set as Set
import Debug.Trace
import System.Environment

import LiftIOE

writeString :: FilePath -> String -> ExceptT String IO ()
writeString file s = liftIOE $ writeFile file s

writeIOString :: FilePath -> IO String -> ExceptT String IO ()
writeIOString file s = liftIOE $ s >>= writeFile file

compile :: Job -> IO ()
--compile j | (trace $ show j) False = undefined
compile job = do
    headerHandle <- openFile (jobHeader job) ReadMode
    hSetEncoding headerHandle utf8
    h0 <- hGetContents headerHandle
    let parserOut = evalP parseTokens (('\n', [], removeComments h0), Set.empty)
        header = eGenHeader parserOut
    inputHandle <- openFile (jobSource job) ReadMode
    hSetEncoding inputHandle utf8
    s <- hGetContents inputHandle
    res <-
        runExceptT $ do
            let ast = evalP parseTokens (('\n', [], removeComments s), Set.fromList $ Map.keys (typDef header))
                (east, sord) = eGen ast header
                allStructs = sord ++ structOrd header
            _ <- liftEIO $ checkEAST (hEast header) mockHeader
            tast <- liftEIO $ checkEAST east header
            let optEast = optLoop $ optTAST tast
            case jobOutFormat job of
                TC -> liftEIO (Right ()) -- By now, we should have thrown any typechecking errors
                Asm ->
                    writeString (jobOut job) $
                    asmGen optEast header allStructs (jobOutUnsafe job) (fromIntegral $ jobOptimization job)
                Abs ->
                    writeString (jobOut job) $
                    testPrintAAsm
                        (codeGen optEast allStructs (jobOutUnsafe job) (fromIntegral $ jobOptimization job))
                        (jobOut job)
    case res of
        Left msg -> error msg
        Right () -> return ()

addHeader :: String -> IO String
addHeader pgm = do
    os <- fromMaybe "Darwin" <$> lookupEnv "UNAME"
    let entry =
            if os == "Darwin"
                then "\t.globl  __c0_main\n__c0_main:\n"
                else "\t.globl  _c0_main\n_c0_main:\n"
    return (entry ++ pgm)