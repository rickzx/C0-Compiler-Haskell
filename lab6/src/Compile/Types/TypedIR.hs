{- Defines the Elaborated AST with typing information after passing the type-checker.
   It tags each variable and lvalue with a concrete type, so the code generator don't need to
   infer the types again after the type-checking process.
-}

module Compile.Types.TypedIR where

import Compile.Types.AST
import Compile.Types.Ops
import qualified Data.Maybe as Maybe

--EX: add : int * int -> int.
data TAST 
    = TSeq TAST TAST
    | TAssign TLValue TExp Bool -- single variable assign -- last parameter bool indicates if the assignment is in a declaration
    | TPtrAssign TLValue Asnop TExp
    | TDef Ident Type TAST -- Arg type list -> return type
    | TGDef [Type] Ident Type TAST
    | TSDef Ident [(Ident, Type)] TAST  -- define struct
    | TGSDef [Type] Ident [(Ident, Type)] TAST
    | TIf TExp TAST TAST
    | TWhile TExp TAST
    | TAssert TExp
    | TRet (Maybe.Maybe TExp) -- must be function return type
    | TNop
    | TDecl Ident Type TAST --last item of type is the return type, if only 1 item, its variable decl
    | TGDecl [Type] Ident Type TAST
    | TLeaf TExp
    
data TLValue
    = TVIdent Ident Type        -- x : tau
    | TVField TLValue Ident Type        -- struct.fld : tau
    | TVDeref TLValue Type          -- *ptr : tau
    | TVArrAccess TLValue TExp Type     -- a[idx] : tau

data TExp
    = TInt Int
    | TT
    | TF
    | TChar Int
    | TString Ident
    | TNULL
    | TIdent Ident Type
    | TBinop Binop TExp TExp
    | TTernop TExp TExp TExp
    | TUnop Unop TExp
    | TFunc Ident [TExp] Type
    | TAlloc Type
    | TArrAlloc Type TExp
    | TArrAccess TExp TExp Type
    | TField TExp Ident Type
    | TDeref TExp Type
    | TRefFun Ident
    | TRefFunAp Ident [TExp] Type
    deriving Eq

instance Show TAST where
    show (TSeq e1 e2) = "ESeq" ++ "(" ++ show e1 ++ " , "  ++ show e2 ++ ")"
    show (TAssign lval leaf _b) = "EAssign" ++ "(" ++ show lval ++ " , " ++ show leaf ++ ")"
    show (TPtrAssign lval asop expr1) = "EPtrAssign" ++ "(" ++ show lval ++ "," ++ show asop ++ "=" ++ "," ++ show expr1 ++ ")"
    show (TIf leaf e1 e2) = "Eif" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ " , " ++ show e2 ++ ")"
    show (TWhile leaf e1) = "EWhile" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ ")"
    show (TRet leaf) = "ERet" ++ "(" ++ show leaf ++ ")"
    show TNop = "NOP"
    show (TDecl ident stype e1) = "EDecl" ++ "(" ++ ident ++ "  ,  " ++ show stype ++ " , " ++ show e1 ++ ")"
    show (TLeaf e) = "ELeaf" ++ "(" ++ show e ++ ")"
    show (TDef ident types tast) = "EDef" ++ "(" ++ ident ++ "  :  " ++ show types ++ " , " ++ show tast ++ ")"
    show (TAssert e) = "EAssert" ++ "(" ++ show e ++ ")"
    show (TSDef s fields tast) = "ESDef" ++ "(" ++ s ++ ", " ++ show fields ++ ", " ++ show tast ++ ")"
    show (TGDef ptyp ident types east) = "EGDef" ++ "(" ++ show ptyp ++ ", " ++  ident ++ "  :  " ++ show types ++ " , " ++ show east ++ ")"
    show (TGSDef ptyp s fields east) = "EGSDef" ++ "(" ++ show ptyp ++ ", " ++ s ++ ", " ++ show fields ++ ", " ++ show east ++ ")"
    show (TGDecl ptyp ident stype e1) = "EGDecl" ++ "(" ++ show ptyp ++ ident ++ "  ,  " ++ show stype ++ " , " ++ show e1 ++ ")"

instance Show TLValue where
    show (TVIdent x _) = x
    show (TVField lval field _) = show lval ++ "." ++ field
    show (TVDeref lval _) = "*" ++ show lval
    show (TVArrAccess lval expr _) = show lval ++ "[" ++ show expr ++ "]"

instance Show TExp where
    show (TInt a) = show a
    show (TIdent x t) = "(" ++ x ++ ":" ++ show t ++ ")"
    show TT = "True"
    show TF = "False"
    show (TChar x) = "\'" ++ show x ++ "\'"
    show (TString str) = str
    show TNULL = "NULL"
    show (TBinop b expr1 expr2) = show expr1 ++ " " ++ show b ++ " " ++ show expr2
    show (TTernop expr1 expr2 expr3) = show expr1 ++ " ? " ++ show expr2 ++ " : " ++ show expr3
    show (TUnop u expr1) = show u ++ show expr1
    show (TFunc iden exprlist _) =
        iden ++ "(" ++ foldr redu_fn "" exprlist ++ ")"
        where
            redu_fn :: TExp -> String -> String
            redu_fn e stri = show e ++ "," ++ stri
    show (TAlloc t) = "alloc(" ++ show t ++ ")"
    show (TArrAlloc t expr) = "arrAlloc(" ++ show t ++ ", " ++ show expr ++ ")"
    show (TArrAccess expr1 expr2 t) = "(" ++ show expr1 ++ "[" ++ show expr2 ++ "] : " ++ show t ++ ")"
    show (TField expr nme t) = "(" ++ show expr ++ "." ++ nme ++ " : " ++ show t ++ ")"
    show (TDeref expr t) = "(*" ++ show expr ++ " : " ++ show t ++ ")"
    show (TRefFun fn) = "&" ++ fn
    show (TRefFunAp iden exprlist _) = 
        "*" ++ iden ++ "(" ++ foldr redu_fn "" exprlist ++ ")"
        where
            redu_fn :: TExp -> String -> String
            redu_fn e stri = show e ++ "," ++ stri