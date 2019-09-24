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
  if {\_ -> TokReserved}
  else {\_ -> TokReserved}
  while {\_ -> TokReserved}
  for {\_ -> TokReserved}
  true {\_ -> TokReserved}
  false {\_ -> TokReserved}
  bool {\_ -> TokReserved}
  "--"  {\_ -> TokReserved}
  "++"  {\_ -> TokReserved}


  "-"   {\_ -> TokMinus}
  "+"   {\_ -> TokPlus}
  "*"   {\_ -> TokTimes}
  "/"   {\_ -> TokDiv}
  "%"   {\_ -> TokMod}
  "="   {\_ -> TokAsgnop Equal}
  "+="  {\_ -> TokAsgnop (AsnOp Add)}
  "-="  {\_ -> TokAsgnop (AsnOp Sub)}
  "*="  {\_ -> TokAsgnop (AsnOp Mul)}
  "/="  {\_ -> TokAsgnop (AsnOp Div)}
  "%="  {\_ -> TokAsgnop (AsnOp Mod)}


  $white+ ;
  0 {\_ -> TokDec 0}
  $decstart $decdigit* {\s -> TokDec (read s)}
  0 [xX] $hexdigit+ {\s -> TokHex (read s)}
  int $white+ main $white* [\(]$white*[\)] {\_ -> TokMain}

  return {\_ -> TokReturn}
  int {\_ -> TokInt}

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
  TokPlus |
  TokTimes |
  TokDiv |
  TokMod |
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
