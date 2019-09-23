{
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
}

%name parseTokens
%tokentype { Token }
%error { parseError }

%token
  '('     {TokLParen}
  ')'     {TokRParen}
  '{'     {TokLBrace}
  '}'     {TokRBrace}
  ';'     {TokSemi}
  dec     {TokDec $$}
  hex     {TokHex $$}
  ident   {TokIdent $$}
  tokmain    {TokMain}
  ret     {TokReturn}
  int     {TokInt}
  '-'     {TokMinus}
  '+'     {TokPlus}
  '*'     {TokTimes}
  '/'     {TokDiv}
  '%'     {TokMod}
  asgnop  {TokAsgnop $$}
  kill    {TokReserved}

  while   {TokWhile}
  for     {TokFor}
  true    {TokTrue}
  false   {TokFalse}
  bool    {TokBool}
  if      {TokIf}
  else    {TokElse}
  '?'     {TokIf}
  ':'     {TokElse}
  unop    {TokUnop $$}
  '<'     {TokLess}
  '>'     {TokGreater}
  '>='    {TokGeq}
  '<='    {TokLeq}
  '=='    {TokBoolEq}
  '!='    {TokNotEq}
  '&&'    {TokBoolAnd}
  '||'    {TokBoolOr}
  '&'     {TokAnd}
  '|'     {TokOr}
  '<<'    {TokLshift}
  '>>'    {TokRshift}
  '++'    {TokIncr}
  '--'    {TokDecr}
 
%right '=' '+=' '-=' '*=' '/=' '%=' '&=' '^=' '|=' '<<=' '>>='
%right '?' ':'
%left '||'
%left '&&'
%left '|'
%left '^'
%left '&'
%left '==' '!='
%left '<' '<=' '>' '>='
%left '<<' '>>'
%left '+' '-'
%left '*' '/' '%'
%right NEG '~' '!' '++' '--'
%%

Program : tokmain Block {Block $2}

Block : '{' Stmts '}' {$2}

Lval  : ident {$1}
      | '(' Lval ')' {$2}

Type  : int {$1}
      | bool {$1}

Decl  : Type ident asgnop Exp {checkDeclAsgn $2 $3 $1 $4}
      | Type ident {JustDecl $2 $1}

Stmts : {- Empty -} {[]}
      | Stmt Stmts  {$1 : $2}

Stmt  : Control {Control $1}
      | Simp ';' {Simp $1}
      | '{' Stmts '}' {$2}

Simp  : Lval asgnop Exp {Asgn $1 $2 $3}
      | Lval '++' {Asgn $1 (AsnOp Add) (Intconst 1)}
      | Lval '--' {Asgn $1 (AsnOp Sub) (Intconst 1)}
      | Decl {Decl $1}
      | Exp {Exp $1}

Simpopt : {- Empty -} {Nop}
      | Simp {Simp $1}

Elseopt : {- Empty -} {Nop}
      | else Stmt {Else $2}

Control : if '(' Exp ')' Stmt Elseopt {Condition $3 $5 $6}
      | while '(' Exp ')' Stmt {While $3 $5}
      | for '(' Simpopt ';' Exp ';' Simpopt ')' Stmt {For $3 $5 $7 $9}
      | ret Exp ';' {Retn $2}

Exp : '(' Exp ')' {$2}
    | true {Int 1}
    | false {Int 0}
    | Intconst {$1}
    | ident {Ident $1}
    | Operation {$1}

Operation : Exp '-' Exp {Binop Sub $1 $3}
          | Exp '+' Exp {Binop Add $1 $3}
          | Exp '*' Exp {Binop Mul $1 $3}
          | Exp '/' Exp {Binop Div $1 $3}
          | Exp '%' Exp {Binop Mod $1 $3}
          | Exp '<<' Exp {Binop Lshift $1 $3}
          | Exp '>>' Exp {Binop Rshift $1 $3}
          | Exp '&' Exp {Binop And $1 $3}
          | Exp '|' Exp {Binop Or $1 $3}
          | Exp '^' Exp {Binop Xor $1 $3}
          | Exp '&&' Exp {Binop BoolAnd $1 $3}
          | Exp '<' Exp {Binop Less $1 $3}
          | Exp '<=' Exp {Binop Leq $1 $3}
          | Exp '>' Exp {Binop Greater $1 $3}
          | Exp '>=' Exp {Binop Geq $1 $3}
          | Exp '==' Exp {Binop BoolEq $1 $3}
          | Exp '!=' Exp {Binop NotEq $1 $3}
          | '!' Exp {Unop Not $2}
          | '~' Exp {Unop Cmpl $2}
          | '-' Exp %prec NEG {Unop Neg $2}

Intconst  : dec {checkDec $1}
          | hex {checkHex $1}

{
parseError :: [Token] -> a
parseError t = error ("Parse Error " ++ (show t))

checkDeclAsgn :: Ident -> Asnop -> Type -> Exp -> Decl
checkDeclAsgn v op tp e =
  case op of
    Equal -> DeclAsgn v tp e
    _ -> error "Invalid assignment operator on a declaration"

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)

}
