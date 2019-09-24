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
  '<<='   {TokAsgnop (AsnOp Lshift)}
  '>>='   {TokAsgnop (AsnOp Rshift)}
  asgnop  {TokAsgnop $$}
  kill    {TokReserved}

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

Decl  : Type ident asgnop Exp {checkDeclAsgn $2 $3 $4}
      | Type ident {JustDecl $2}

Stmts : {- Empty -} {[]}
      | '{' Stmts '}' {$2}
      | Stmt Stmts  {$1 : $2}

Stmt  : Decl ';' {Decl $1}
      | Simp ';' {Simp $1}
      | '{' Stmts '}' {Block $2}
      | Control {Control $1}
      | ret Exp ';' {Retn $2}

Simp  : Lval '<<=' Exp {checkShiftAsgn $1 (AsnOp Lshift) $3}
      | Lval '>>=' Exp {checkShiftAsgn $1 (AsnOp Rshift) $3}
      | Lval asgnop Exp {Asgn $1 $2 $3}
      | Lval '++' {Asgn $1 (AsnOp Add) (Intconst 1)}
      | Lval '--' {Asgn $1 (AsnOp Sub) (Intconst 1)}
      | Decl {Decl $1}
      | Exp {Exp $1}

Simpopt : {- Empty -} {Nop}
        | Simp {Simp $1}

Elseopt : {- Empty -} {Nop}
        | else Stmt {Else $2}

Control : if '(' Exp ')' Stmt Elseopt {Condition $3 $5 $6}
        | while '(' Exp ')' Stmt {Loop Nop $3 Nop $5}
        | for '(' Simpopt ';' Exp ';' Simpopt ')' Stmt {Loop $3 $5 $7 $9}
        | ret Exp ';' {Retn $2}

Exp : '(' Exp ')' {$2}
    | Intconst {$1}
    | true {Intconst 1}
    | false {Intconst 0}
    | ident {Ident $1}
    | Operation {$1}
    | Exp '?' Exp ':' Exp {Control (Condition $1 $3 $5)}

Operation : Exp '-' Exp {Binop Sub $1 $3}
          | Exp '+' Exp {Binop Add $1 $3}
          | Exp '*' Exp {Binop Mul $1 $3}
          | Exp '/' Exp {Binop Div $1 $3}
          | Exp '%' Exp {Binop Mod $1 $3}
          | Exp '<<' Exp {checkShiftError $1 Lshift $3}
          | Exp '>>' Exp {checkShiftError $1 Rshift $3}
          | Exp '&' Exp {Binop And $1 $3}
          | Exp '|' Exp {Binop Or $1 $3}
          | Exp '^' Exp {Binop Xor $1 $3}
<<<<<<< HEAD
=======
--dont elaborate to conditions yet.
>>>>>>> cad5147ba4e2b0bd6e02ef80f22e0ed1e193386d
          | Exp '&&' Exp {Control (Condition $1 $3 $1)}
          | Exp '||' Exp {Control (Condition $1 $1 $3)}
          | '-' Exp %prec NEG {Unop Neg $2}
          | '!' Exp {Unop Not $2}
          | '~' Exp {Unop Cmpl $2}

Intconst  : dec {checkDec $1}
          | hex {checkHex $1}

{
parseError :: [Token] -> a
parseError t = error ("Parse Error " ++ (show t))

checkDeclAsgn :: Ident -> Asnop -> Exp -> Decl
checkDeclAsgn v op e =
  case op of
    Equal -> DeclAsgn v e
    _ -> error "Invalid assignment operator on a declaration"

<<<<<<< HEAD
=======
(--TODO: this shift doestn avoid register)

>>>>>>> cad5147ba4e2b0bd6e02ef80f22e0ed1e193386d
checkShiftAsgn :: Lval -> Asnop -> Exp -> Exp
checkShiftAsgn l1 op e1 =
  if(e1 > 31) then error "Shifting out of bounds" else Asgn l1 op e1

checkShiftError :: Exp -> Binop -> Exp -> Exp
checkShiftError e1 op e2 =
  if (e2 > 31) then error "Shifting out of bounds" else Binop op e1 e2

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)

}
