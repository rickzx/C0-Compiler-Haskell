{- Defines the Elaborated AST after the elaboration process
-}

module Compile.Types.EAST where

import Compile.Types

data EAST 
    = ESeq EAST EAST
    | EAssign Ident Exp
    | EIf Exp EAST EAST
    | EWhile Exp EAST
    | ERet Exp
    | ENop
    | EDecl Ident Type EAST