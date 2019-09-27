{- Defines the Elaborated AST after the elaboration process
-}

module Compile.Types.EAST where

import Compile.Types.AST
import Compile.Types.Ops

data Type
    = Integer
    | Boolean deriving (Eq, Show)

data EAST 
    = ESeq EAST EAST
    | EAssign Ident EExp
    | EIf EExp EAST EAST
    | EWhile EExp EAST
    | ERet EExp
    | ENop
    | EDecl Ident Type EAST

data EExp
    = EInt Int
    | EIdent Ident
    | EBinop Binop EExp EExp
    | EUnop Unop EExp
    deriving Eq