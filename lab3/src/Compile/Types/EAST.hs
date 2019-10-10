{- Defines the Elaborated AST after the elaboration process
-}

module Compile.Types.EAST where

import Compile.Types.AST
import Compile.Types.Ops
import qualified Data.Maybe as Maybe

--EX: add : int * int -> int.
data EAST 
    = ESeq EAST EAST
    | EAssign Ident EAST -- single variable assign
    | EDef Ident [(Type, Ident)] Type EAST -- Arg type list -> return type
    | EIf EExp EAST EAST
    | EWhile EExp EAST
    | EAssert EExp
    | ERet (Maybe.Maybe EExp) -- must be function return type
    | ENop
    | EDecl Ident Type EAST --for variable decl
    | ELeaf EExp

data EExp
    = EInt Int
    | ET
    | EF 
    | EIdent Ident
    | EBinop Binop EExp EExp
    | ETernop EExp EExp EExp
    | EUnop Unop EExp
    | EFunc Ident [EExp]
    deriving Eq

instance Show EAST where
    show (ESeq e1 e2) = show "ESeq" ++ "(" ++ show e1 ++ " , "  ++ show e2 ++ ")"
    show (EAssign ident leaf) = show "EAssign" ++ "(" ++ ident ++ " , " ++ show leaf ++ ")"
    show (EIf leaf e1 e2) = show "Eif" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ " , " ++ show e2 ++ ")"
    show (EWhile leaf e1) = show "EWhile" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ ")"
    show (ERet leaf) = show "ERet" ++ "(" ++ show leaf ++ ")"
    show ENop = show "NOP"
    show (EDecl ident stype e1) = show "EDecl" ++ "(" ++ ident ++ "  ,  " ++ show stype ++ " , " ++ show e1 ++ ")"
    show (ELeaf e) = show e
    show (EDef ident types rtype east) = show "EDef" ++ "(" ++ ident ++ "  ,  " ++ show types ++ " -> " ++ show rtype ++ " , " ++ show east ++ ")"
    show (EAssert e) = show "EAssert" ++ "(" ++ show e ++ ")"

instance Show EExp where
    show (EInt a) = show a
    show (EIdent x) = x
    show ET = "True"
    show EF = "False"
    show (EBinop b expr1 expr2) = show expr1 ++ " " ++ show b ++ " " ++ show expr2
    show (ETernop expr1 expr2 expr3) = show expr1 ++ " ? " ++ show expr2 ++ " : " ++ show expr3
    show (EUnop u expr1) = show u ++ show expr1
    show (EFunc iden exprlist) = 
        iden ++ "(" ++ (foldr redu_fn "" exprlist) ++ ")"
        where 
            redu_fn :: EExp -> String -> String
            redu_fn e stri = show e ++ "," ++ stri