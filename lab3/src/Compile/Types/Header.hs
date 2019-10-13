module Compile.Types.Header where

import Compile.Types.AST
import Compile.Types.EAST
import qualified Data.Map as Map

data Header =
    Header
        { fnDecl :: Map.Map Ident Type
        , typDef :: Map.Map Ident Type
        } deriving Show