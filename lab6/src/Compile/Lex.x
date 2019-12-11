{
module Compile.Lexer where

import Compile.Types.Ops
import Control.Monad.State
import qualified Data.Set as Set
import Data.Word
import Debug.Trace

}
%wrapper "basic"

$decdigit = [0-9]
$decstart = [1-9]
$hexdigit = [0-9A-Fa-f]
$identstart = [A-Za-z_]
$identletter = [A-Za-z0-9_]
$escape = [\a\b\'\" $white]
@charesc = \ ($escape | \0)
@stringesc = \ ($escape)
$gra = $printable # [\\]
$graphic = $printable # $escape

@charhc = \\t | \\a | \\b | \\v | \\n | \\f | \\r | \\0 | \\' | \\\"
@stringhc = \\t | \\a | \\b | \\v | \\n | \\f | \\r | \\' | \\\" | \ 
tokens :-

  continue {\_ -> TokReserved}
  struct {\_ -> TokStruct}
  typedef {\_ -> TokTypeDef}
  break {\_ -> TokReserved}
  assert {\_ -> TokAssert}
  NULL {\_ -> TokNULL}
  alloc {\_ -> TokAlloc}
  alloc_array {\_ -> TokArrayAlloc}
  void {\_ -> TokVoid}
  char {\_ -> TokCharType}
  string {\_ -> TokStringType}

  if {\_ -> TokIf}
  else {\_ -> TokElse}
  while {\_ -> TokWhile}
  for {\_ -> TokFor}
  true {\_ -> TokTrue}
  false {\_ -> TokFalse}

  "->"  {\_ -> TokAccess}
  "-"   {\_ -> TokMinus}
  "+"   {\_ -> TokPlus}
  "*"   {\_ -> TokTimes}
  "/"   {\_ -> TokDiv}
  "%"   {\_ -> TokMod}
  "<"   {\_ -> TokLess}
  ">"   {\_ -> TokGreater}
  ">="   {\_ -> TokGeq}
  "<="   {\_ -> TokLeq}
  "=="   {\_ -> TokBoolEq}
  "!="   {\_ -> TokNotEq}
  "&&"   {\_ -> TokBoolAnd}
  "||"   {\_ -> TokBoolOr}
  "&"   {\_ -> TokAnd}
  "|"   {\_ -> TokOr}
  "<<"   {\_ -> TokLshift}
  ">>"   {\_ -> TokRshift}
  "++"   {\_ -> TokIncr}
  "--"   {\_ -> TokDecr}
  "?"   {\_ -> TokTIf}
  ":"   {\_ -> TokTElse}
  "^"   {\_ -> TokXor}

  "!"   {\_ -> TokUnop (LNot)}
  "~"   {\_ -> TokUnop (BNot)}

  "="   {\_ -> TokAsgnop Equal}
  "+="  {\_ -> TokAsgnop (AsnOp Add)}
  "-="  {\_ -> TokAsgnop (AsnOp Sub)}
  "*="  {\_ -> TokAsgnop (AsnOp Mul)}
  "/="  {\_ -> TokAsgnop (AsnOp Div)}
  "%="  {\_ -> TokAsgnop (AsnOp Mod)}
  "^="  {\_ -> TokAsgnop (AsnOp Xor)}
  "|="  {\_ -> TokAsgnop (AsnOp BOr)}
  "&="  {\_ -> TokAsgnop (AsnOp BAnd)}
  "<<="  {\_ -> TokAsgnop (AsnOp Sal)}
  ">>="  {\_ -> TokAsgnop (AsnOp Sar)}

  $white+ ;
  0 {\_ -> TokDec 0}
  $decstart $decdigit* {\s -> TokDec (read s)}
  0 [xX] $hexdigit+ {\s -> TokHex (read s)}
  \' ($graphic | @charesc | @charhc | \ ) \' {\s -> TokChar (process $ tail $ init s)}
  \" ($graphic | (\\ $escape # [\"\']) | (\\ [\"\']) | @stringhc)* \" {\s -> TokString (processString $ tail $ init s)}

  return {\_ -> TokReturn}
  int {\_ -> TokInt}
  bool {\_ -> TokBool}

  $identstart $identletter* {\s -> TokIdent s}
  \' $identstart {\s -> TokGenType (tail s)}

  [\[] {\_ -> TokLBracket}
  [\]] {\_ -> TokRBracket}
  [\(] {\_ -> TokLParen}
  [\)] {\_ -> TokRParen}
  [\{] {\_ -> TokLBrace}
  [\}] {\_ -> TokRBrace}
  [\;] {\_ -> TokSemi}
  [\,] {\_ -> TokComma}
  [\.] {\_ -> TokField}

  -- comments
  \/\/.*\n ;


{
-- Each action has type :: String -> Token
-- The token type:
data Token =
  TokLParen |
  TokRParen |
  TokLBrace |
  TokRBrace |
  TokSemi |
  TokDec Integer |
  TokHex Integer |
  TokIdent String |
  TokReturn |
  TokInt |
  TokMinus |
  TokAsgnop Asnop |
  TokUnop Unop |
  TokPlus |
  TokTimes |
  TokDiv |
  TokMod |
  TokIf |
  TokWhile |
  TokFor |
  TokTrue |
  TokFalse |
  TokBool |
  TokElse |
  TokTIf |
  TokTElse |
  TokLess |
  TokGreater |
  TokGeq |
  TokLeq |
  TokBoolEq |
  TokNotEq |
  TokBoolAnd |
  TokBoolOr |
  TokAnd |
  TokOr |
  TokLshift |
  TokRshift |
  TokIncr |
  TokDecr |
  TokXor |
  TokComma |
  TokTypeDef |
  TokAssert |
  TokVoid |
  TokStruct |
  TokAccess |
  TokLBracket |
  TokRBracket |
  TokNULL |
  TokAlloc |
  TokEOF |
  TokArrayAlloc |
  TokField |
  TokTypeDefIdent String |
  TokCharType|
  TokStringType|
  TokChar Char |
  TokString String |
  TokGenType String |
  TokReserved
  deriving (Eq,Show)

process :: String -> Char
process [] = '\0'
process [x] = x
process (x:xs)
  |xs == "r" = '\r'
  |xs == "f" = '\f'
  |xs == "t" = '\t'
  |xs == "a" = '\a'
  |xs == "b" = '\b'
  |xs == "n" = '\n'
  |xs == "v" = '\v'
  |xs == "'" = '\''
  |xs == "\"" = '\"'
  |otherwise = '\0'
process _ = error "invalid char"

processString :: String -> String
processString [] = []
processString [x] = [x]
processString (x:y:xs) 
  | x == '\\' = case y of 
      '\\' -> x:y:(processString xs)
      'a' -> x:("007") ++ processString xs
      'v' -> x:("013") ++ processString xs
      '0' -> error "string can't contain NUL in middle"
      _ -> x:processString (y:xs)
  | otherwise = x:processString (y:xs)

-- Our Parser monad
type P a = State (AlexInput, Set.Set String) a

evalP::P a -> (AlexInput, Set.Set String) -> a
evalP = evalState

-- Action to read a token
readToken :: P Token
readToken = do
    (s@(_, _, str), typedefs) <- get
    case alexScan s 0 of
        AlexEOF -> return TokEOF
        AlexError _ -> error $ show s ++ "Lexical Error"
        AlexSkip inp' _ -> do
            put (inp', typedefs)
            readToken
        AlexToken inp' len act -> do
            put (inp', typedefs)
            let tk = act (take len str)
            case tk of
                TokIdent x -> if (Set.member x typedefs) then return (TokTypeDefIdent x) else return tk
                _ -> return tk

-- The lexer function to be passed to Happy
lexer :: (Token -> P a)->P a
lexer cont = readToken >>= cont

removeComments :: String -> String
removeComments s = removeCommentsHelp 0 s

removeCommentsHelp :: Int -> String -> String
removeCommentsHelp n [] =
  if (n > 0) then error "Unclosed block comment"
  else []
removeCommentsHelp n (x:[]) =
  if (n > 0) then error "Unclosed block comment"
  else x:[]
removeCommentsHelp n (x:y:xs) =
  case [x, y] of
    "/*" -> removeCommentsHelp (n+1) xs
    "*/" ->
      if (n > 0)
      then (' ':(removeCommentsHelp (n-1) xs))
      else error "Unmatched block comment closer"
    "//" ->
      if (n > 0)
      then removeCommentsHelp n (y:xs)
      else removeComments $ removeLineComment xs
    _ ->
      if (n > 0)
      then removeCommentsHelp n (y:xs)
      else x : (removeCommentsHelp n (y:xs))

removeLineComment :: String -> String
removeLineComment [] = []
removeLineComment (x:xs) =
  if (x == '\n')
  then (x:xs)
  else removeLineComment xs}
