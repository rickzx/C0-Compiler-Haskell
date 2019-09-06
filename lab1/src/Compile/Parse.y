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

%left '+' '-'
%left '*' '/' '%'
%right NEG

%%

Program : tokmain Block {Block $2}

Block : '{' Stmts '}' {$2}

Lval  : ident {$1}
      | '(' Lval ')' {$2}

Decl  : int ident asgnop Exp {checkDeclAsgn $2 $3 $4}
      | int ident {JustDecl $2}

Stmts : {- Empty -} {[]}
      | '{' Stmts '}' {$2}
      | Stmt Stmts  {$1 : $2}

Stmt  : Decl ';' {Decl $1}
      | Simp ';' {Simp $1}
      | ret Exp ';' {Ret $2}

Simp  : Lval asgnop Exp {Asgn $1 $2 $3}

Exp : '(' Exp ')' {$2}
    | Intconst {$1}
    | ident {Ident $1}
    | Operation {$1}

Operation : Exp '-' Exp {Binop Sub $1 $3}
          | Exp '+' Exp {Binop Add $1 $3}
          | Exp '*' Exp {Binop Mul $1 $3}
          | Exp '/' Exp {Binop Div $1 $3}
          | Exp '%' Exp {Binop Mod $1 $3}
          | '-' Exp %prec NEG {Unop Neg $2}

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

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)

}
