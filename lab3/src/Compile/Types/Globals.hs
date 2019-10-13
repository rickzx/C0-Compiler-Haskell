module Compile.Types.Globals where

import Compile.Types.AST
import qualified Data.Map as Map

data Globals =
    Globals
        { gFun :: Map.Map Ident Type
        , gTyp :: Map.Map Ident Type
        } deriving Show