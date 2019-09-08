{-# LANGUAGE TupleSections #-}
module Compile.Backend.RegisterAlloc where

import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.Maybe
import qualified Data.PQueue.Max as PQ
import Compile.Types.AbstractAssembly

type Graph = Map.Map AVal (Set.Set AVal)
type Coloring = Map.Map AVal Int

-- Maximal Cardinality Search
-- Takes in a graph, output a simplicial elimination ordering of the vertices
mcs :: Graph -> [AVal]
mcs graph = 
    let
        pq = PQ.fromList (map (0 :: Integer,) $ Map.keys graph)
        incrPQ pq' neighbors = PQ.mapMaybe (\(w, v) -> if Set.member v neighbors then Just (w + 1, v) else Just (w, v)) pq'
        mcs' pq' = 
            case PQ.maxView pq' of
                Just ((_w, v), rest) -> v : mcs' (incrPQ rest $ fromJust $ Map.lookup v graph)
                Nothing -> []
    in
        mcs' pq

-- Color the inteference graph using simplicial elimination ordering
color :: Graph -> [AVal] -> Coloring -> Coloring
color graph seo coloring =
    foldl (\c v -> Map.insert v (lowestColor $ Map.restrictKeys c $ fromJust $ Map.lookup v graph) c) coloring seo
    where
        lowestColor c = let 
                            colors = Set.fromList $ Map.elems c
                            findLow n = if Set.member n colors then findLow (n + 1) else n
                        in
                            findLow 0

testGraph :: Graph
testGraph = Map.fromList [(AImm 0, Set.fromList [AImm 1, AImm 2, AImm 3, AImm 4]),
                            (AImm 1, Set.fromList [AImm 0, AImm 3, AImm 4]),
                            (AImm 2, Set.fromList [AImm 0, AImm 3, AImm 4]),
                            (AImm 3, Set.fromList [AImm 1, AImm 2, AImm 4, AImm 0]),
                            (AImm 4, Set.fromList [AImm 1, AImm 2, AImm 3, AImm 0])]

test1 :: IO ()
test1 = print (mcs testGraph)

test2 :: IO ()
test2 = print (color testGraph (mcs testGraph) Map.empty)

