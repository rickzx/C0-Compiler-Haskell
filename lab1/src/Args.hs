{- L1 Compiler
   Author: Matthew Maurer <mmaurer@andrew.cmu.edu>
   Modified by: Ryan Pearl <rpearl@andrew.cmu.edu>
                Shyam Raghavan <shyamsur@andrew.cmu.edu>

   Argument and option parsing
-}
module Args (parseArgs, JobParseError(..), usage) where

import Compile.Types.Job
import System.Console.GetOpt
import Data.Maybe
import Data.List
import System.FilePath

data JobParseError
  = NoSources
  | TooManySources
  | GetOptError [String]
  deriving Show

usage :: String -> String
usage p = usageInfo p argTable

parseArgs :: Job -> [String] -> Either JobParseError Job
parseArgs initialJob args =
  let
    (transforms, sources, errors) = getOpt Permute argTable $ map mungeArgs args
  in
    case sources of
      _ | _ : _ <- errors -> Left $ GetOptError errors
      [] -> Left NoSources
      _ : _ : _ -> Left TooManySources
      [source] ->
        Right $ ensureOut $
          (foldr ($) initialJob transforms) { jobSource = source }

mungeArgs :: String -> String
mungeArgs s
  | "-e" `isPrefixOf` s = "--emit=" ++ drop 2 s
  | "-O" `isPrefixOf` s = "--opt=" ++ drop 2 s
  | otherwise = s

argTable :: [OptDescr (Job -> Job)]
argTable =
  [ Option
      ['t']
      ["typecheck-only"]
      (NoArg (setOF "tc"))
      "Only typecheck the program (produce no output file)"
  , Option
      []
      ["emit"]
      (ReqArg setOF "EMIT")
      "Produce a particular type of output (documented in c0c-spec.txt)"
  , Option [] ["opt"] (ReqArg setOpti "OPT") "Optimization level"
  ]

extTable :: [(OF, String)]
extTable = [(Asm, "s"), (Abs, "abs"), (TC, "")]

typeTable :: [(String, OF)]
typeTable = [("x86-64", Asm), ("abs", Abs), ("tc", TC)]

optiTable :: [(String, Integer)]
optiTable = [("0", 0), ("1", 1), ("2", 2)]

setOF :: String -> Job -> Job
setOF outFormat j = j {jobOutFormat = fromJust $ lookup outFormat typeTable}

setOpti :: String -> Job -> Job
setOpti optimizationLevel j =
  j {jobOptimization = fromJust $ lookup optimizationLevel optiTable}

ensureOut :: Job -> Job
ensureOut j = case jobOut j of
  "" -> j {jobOut = addExtension (jobSource j) $ objExt (jobOutFormat j)}
  _  -> j
  where objExt obj = fromJust $ lookup obj extTable
