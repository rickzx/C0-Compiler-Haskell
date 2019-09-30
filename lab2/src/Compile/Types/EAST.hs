{- Defines the Elaborated AST after the elaboration process
-}

module Compile.Types.EAST where

import Compile.Types.AST
import Compile.Types.Ops

data EAST 
    = ESeq EAST EAST
    | EAssign Ident EExp
    | EIf EExp EAST EAST
    | EWhile EExp EAST
    | ERet EExp
    | ENop
    | EDecl Ident Type EAST
    | ELeaf EExp
    
data EExp
    = EInt Int
    | ET
    | EF
    | EIdent Ident
    | EBinop Binop EExp EExp
    | ETernop EExp EExp EExp
    | EUnop Unop EExp
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

instance Show EExp where
    show (EInt a) = show a
    show (EIdent id) = id
    show ET = "True"
    show EF = "False"
    show (EBinop b expr1 expr2) = show expr1 ++ " " ++ show b ++ " " ++ show expr2
    show (ETernop expr1 expr2 expr3) = show expr1 ++ " ? " ++ show expr2 ++ " : " ++ show expr3
    show (EUnop u expr1) = show u ++ show expr1