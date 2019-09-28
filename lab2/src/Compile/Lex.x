{
module Compile.Lexer where

import Compile.Types.Ops
}
%wrapper "basic"

$decdigit = [0-9]
$decstart = [1-9]
$hexdigit = [0-9A-Fa-f]
$identstart = [A-Za-z_]
$identletter = [A-Za-z0-9_]


tokens :-

  continue {\_ -> TokReserved}
  struct {\_ -> TokReserved}
  typedef {\_ -> TokReserved}
  break {\_ -> TokReserved}
  assert {\_ -> TokReserved}
  NULL {\_ -> TokReserved}
  alloc {\_ -> TokReserved}
  alloc_array {\_ -> TokReserved}
  void {\_ -> TokReserved}
  char {\_ -> TokReserved}
  string {\_ -> TokReserved}

  if {\_ -> TokIf}
  else {\_ -> TokElse}
  while {\_ -> TokWhile}
  for {\_ -> TokFor}
  true {\_ -> TokTrue}
  false {\_ -> TokFalse}

  "-"   {\_ -> TokMinus}
  "+"   {\_ -> TokPlus}
  "*"   {\_ -> TokTimes}
  "/"   {\_ -> TokDiv}
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
  "?"   {\_ -> TokIf}
  ":"   {\_ -> TokElse}
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
  int $white+ main $white* [\(]$white*[\)] {\_ -> TokMain}

  return {\_ -> TokReturn}
  int {\_ -> TokInt}
  bool {\_ -> TokBool}

  $identstart $identletter* {\s -> TokIdent s}
  [\(] {\_ -> TokLParen}
  [\)] {\_ -> TokRParen}
  [\{] {\_ -> TokLBrace}
  [\}] {\_ -> TokRBrace}
  [\;] {\_ -> TokSemi}

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
  TokMain |
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
  TokReserved
  deriving (Eq,Show)

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
  else removeLineComment xs

lexProgram s = alexScanTokens $ removeComments s
}