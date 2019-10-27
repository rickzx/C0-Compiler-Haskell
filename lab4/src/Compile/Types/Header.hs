{- Defines the type of the header file
-}

module Compile.Types.Header where

import Compile.Types.AST
import Compile.Types.EAST
import qualified Data.Map as Map

data Header =
    Header
        { fnDecl :: Map.Map Ident Type
        , typDef :: Map.Map Ident Type
        , structDef :: Map.Map Ident (Map.Map Ident Type)
        , hEast :: EAST
        } deriving Show

mockHeader :: Header
mockHeader = Header Map.empty Map.empty Map.empty ENop