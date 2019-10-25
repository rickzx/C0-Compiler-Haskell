{
module Compile.Parser where

import Compile.Lexer
import Compile.Types.Ops
import Compile.Types.AST
import Control.Monad.State
import qualified Data.Set as Set
import Debug.Trace

}

%name parseTokens
%tokentype { Token }
%error { parseError }
%monad { P }
%lexer { lexer } { TokEOF }

%token
  '.'     {TokField}
  '->'    {TokAccess}
  '('     {TokLParen}
  ')'     {TokRParen}
  '['     {TokLBracket}
  ']'     {TokRBracket}
  '{'     {TokLBrace}
  '}'     {TokRBrace}
  ';'     {TokSemi}
  ','     {TokComma}
  dec     {TokDec $$}
  hex     {TokHex $$}
  typeIdent {TokTypeDefIdent $$}
  ident   {TokIdent $$}
  ret     {TokReturn}
  int     {TokInt}
  void    {TokVoid}
  '-'     {TokMinus}
  '+'     {TokPlus}
  '*'     {TokTimes}
  '/'     {TokDiv}
  '%'     {TokMod}
  asgnop  {TokAsgnop $$}
  kill    {TokReserved}
  NULL    {TokNULL}
  alloc   {TokAlloc}
  alloc_array {TokArrayAlloc}

  struct  {TokStruct}
  typedef {TokTypeDef}
  assert  {TokAssert}
  while   {TokWhile}
  '^'     {TokXor}
  '!'     {TokUnop LNot}
  '~'     {TokUnop BNot}
  for     {TokFor}
  true    {TokTrue}
  false   {TokFalse}
  bool    {TokBool}
  if      {TokIf}
  else    {TokElse}
  '?'     {TokTIf}
  ':'     {TokTElse}
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
%right THEN else
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
%right NEG '~' '!' PTR '++' '--'
%nonassoc '[' ']' '.' '->'
%%

Program : Funs {Program $1}

Funs : {- Empty -} {[]}
      | Gdecl Funs {$1 : $2}

Gdecl : Fdecl {$1}
      | Fdefn {$1}
      | Sdecl {$1}
      | Sdef {$1}
      | Typedef ';'{$1}

Fdecl : Type ident Paramlist ';' {Fdecl $1 $2 $3}
Fdefn : Type ident Paramlist Block {Fdefn $1 $2 $3 $4}
Param : Type ident {($1,$2)}

ParamlistFollow : {- Empty -} {[]}
      | ',' Param ParamlistFollow {$2 : $3}

Paramlist : '(' ')' {[]}
      | '(' Param ParamlistFollow ')' {$2 : $3}

Sdecl : struct ident ';' {Sdecl $2}

Sdef : struct ident '{' Fieldlist '}' ';' {Sdef $2 $4}
Field : Type ident ';' {($1, $2)}
Fieldlist : {- Empty -} {[]}
      | Field Fieldlist {$1 : $2}

Typedef : typedef Type ident {% wrapTypeDef (Typedef $2 $3) $3}

Block : '{' Stmts '}' {$2}

Type  : int {INTEGER}
      | bool {BOOLEAN}
      | typeIdent {DEF $1}
      | void {VOID}
      | Type '[' ']'{ARRAY $1}
      | Type '*'{POINTER $1}
      | struct ident {STRUCT $2}

Decl  : Type ident asgnop Exp {checkDeclAsgn $2 $3 $1 $4}
      | Type ident {JustDecl $2 $1}

Stmts : {- Empty -} {[]}
      | Stmt Stmts  {$1 : $2}

Stmt  : Control {ControlStmt $1}
      | Simp ';' {Simp $1}
      | '{' Stmts '}' {Stmts $2}

Simp  : Exp asgnop Exp {checkSimpAsgn $1 $2 $3}
      | Exp '++' {checkSimpAsgnP $1 Incr}
      | Exp '--' {checkSimpAsgnP $1 Decr}
      | Decl {Decl $1}
      | Exp {Exp $1}

Simpopt : {- Empty -} {SimpNop}
      | Simp {Opt $1}

Elseopt : else Stmt {Else $2}

Control : if '(' Exp ')' Stmt Elseopt {Condition $3 $5 $6}
      | if '(' Exp ')' Stmt %prec THEN {Condition $3 $5 (ElseNop)}
      | while '(' Exp ')' Stmt {While $3 $5}
      | for '(' Simpopt ';' Exp ';' Simpopt ')' Stmt {For $3 $5 $7 $9}
      | ret Exp ';' {Retn $2}
      | ret ';' {Void}
      | assert '(' Exp ')' ';' {Assert $3}

Exp : '(' Exp ')' {$2}
    | Exp '?' Exp ':' Exp {Ternop $1 $3 $5}
    | true {T}
    | false {F}
    | NULL {NULL}
    | Intconst {$1}
    | ident {Ident $1}
    | Operation {$1}
    | ident Arglist {Function $1 $2}
    | alloc '(' Type ')' {Alloc $3}
    | alloc_array '(' Type ',' Exp ')' {ArrayAlloc $3 $5}
    | Exp '[' Exp ']' {ArrayAccess $1 $3}
    | Exp '.' ident {Field $1 $3}
    | Exp '->' ident {Access $1 $3}
    | '*' Exp %prec PTR {Ptrderef $2}

ArglistFollow : {- Empty -} {[]}
    | ',' Exp ArglistFollow {$2 : $3}

Arglist : '(' ')' {[]}
    |'(' Exp ArglistFollow ')' {$2 : $3}

Operation : Exp '-' Exp {Binop Sub $1 $3}
          | Exp '+' Exp {Binop Add $1 $3}
          | Exp '*' Exp {Binop Mul $1 $3}
          | Exp '/' Exp {Binop Div $1 $3}
          | Exp '%' Exp {Binop Mod $1 $3}
          | Exp '<<' Exp {Binop Sal $1 $3}
          | Exp '>>' Exp {Binop Sar $1 $3}
          | Exp '&' Exp {Binop BAnd $1 $3}
          | Exp '|' Exp {Binop BOr $1 $3}
          | Exp '^' Exp {Binop Xor $1 $3}
          | Exp '&&' Exp {Binop LAnd $1 $3}
          | Exp '||' Exp {Binop LOr $1 $3}
          | Exp '<' Exp {Binop Lt $1 $3}
          | Exp '<=' Exp {Binop Le $1 $3}
          | Exp '>' Exp {Binop Gt $1 $3}
          | Exp '>=' Exp {Binop Ge $1 $3}
          | Exp '==' Exp {Binop Eql $1 $3}
          | Exp '!=' Exp {Binop Neq $1 $3}
          | '!' Exp {Unop LNot $2}
          | '~' Exp {Unop BNot $2}
          | '-' Exp %prec NEG {Unop Neg $2}

Intconst  : dec {checkDec $1}
          | hex {checkHex $1}

{
parseError :: Token -> P a
parseError t = error ("Parse Error " ++ (show t))

checkSimpAsgn :: Exp -> Asnop -> Exp -> Simp
checkSimpAsgn id op e =
    case id of
        Ident a -> Asgn id op e
        _ -> error "Invalid assignment to non variables"

checkSimpAsgnP :: Exp -> Postop -> Simp
checkSimpAsgnP id op =
    case id of
        Ident a -> AsgnP id op
        _ -> error "Invalid postop assignment to non variables"

checkDeclAsgn :: Ident -> Asnop -> Type -> Exp -> Decl
checkDeclAsgn v op tp e =
  case op of
    Equal -> DeclAsgn v tp e
    _ -> error "Invalid assignment operator on a declaration"

checkDec n = if (n > 2^31) then error "Decimal too big" else Int (fromIntegral n)
checkHex n = if (n >= 2^32) then error "Hex too big" else Int (fromIntegral n)

wrapTypeDef td name = do
    (str, typedefs) <- get
    put (str, Set.insert name typedefs)
    return td
}