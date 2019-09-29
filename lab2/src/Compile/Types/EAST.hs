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