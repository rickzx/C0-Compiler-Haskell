module Compile.Backend.RegisterAlloc where

import qualified Data.Map                      as Map
import qualified Data.Set                      as Set
import qualified Data.PQueue.Max               as PQ
import qualified Data.Maybe                    as Maybe

import           Compile.Types.AbstractAssembly
import           Compile.Types.Assembly

type Graph = Map.Map ALoc (Set.Set ALoc)
type Coloring = Map.Map ALoc Int

-- Maximal Cardinality Search
-- Takes in a graph, output a simplicial elimination ordering of the vertices
mcs :: Graph -> Coloring -> [ALoc]
mcs graph preColor =
    let
        initWeight vertex =
            foldl (\x v -> if Map.member v preColor then x + 1 else x) 0
                $     graph
                Map.! vertex
        pq = PQ.fromList
            (map (\v -> (initWeight v :: Integer, v)) $ Map.keys graph)
        incrPQ pq' neighbors = PQ.mapMaybe
            (\(w, v) -> if Set.member v neighbors
                then Just (w + 1, v)
                else Just (w, v)
            )
            pq'
        mcs' pq' = case PQ.maxView pq' of
            Just ((_w, v), rest) -> v : mcs' (incrPQ rest $ graph Map.! v)
            Nothing              -> []
    in
        mcs' pq

-- Color the inteference graph using simplicial elimination ordering
color :: Graph -> [ALoc] -> Coloring -> (Coloring, Int, [Register])
color graph seo preColor = (coloring, max (maxColor - length regOrder + 3) 0, calleeSaved)
    where
    lowestColor c =
        let colors = Set.fromList $ Map.elems c
            findLow n = if Set.member n colors then findLow (n + 1) else n
        in  findLow 0
    (coloring, maxColor) = foldl
        (\(c, maxC) v -> if Map.member v preColor
            then (c, max maxC $ preColor Map.! v)
            else
                let
                    colorToUse = lowestColor $ Map.restrictKeys c $ graph Map.! v
                in
                    (Map.insert v colorToUse c, max maxC colorToUse)
        )
        (preColor, 0)
        seo
    calleeSaved = if maxColor <= 6 then [] else drop 7 (take (maxColor + 1) regOrder)

allStackColor :: Set.Set Int -> (Coloring, Int, [Register])
allStackColor allVars =
    let
        precolor =
             Map.fromList
             [ (AReg 0, 0)
             , (AReg 1, 3)
             , (AReg 2, 4)
             , (AReg 3, 1)
             , (AReg 4, 2)
             , (AReg 5, 5)
             , (AReg 6, 6)
             , (AReg 9, 7)
             ]
        (l, _) = foldr (\n (m, idx) -> (Map.insert (ATemp n) idx m, idx + 1)) (Map.empty, length regOrder) allVars
    in
        (Map.union precolor l, length allVars + 3, [])

regOrder :: [Register]
regOrder =
    [EAX, EDI, ESI, EDX, ECX, R8D, R9D, R12D, R13D, R14D, R15D, EBX]   -- Reserve R11 for moves to and from the stack when necessary

-- Map a variable in abstract assembly to a register / memory location
mapToRegWithCoalescing :: ALoc -> Coloring -> Map.Map ALoc ALoc -> Operand
mapToRegWithCoalescing (APtr aloc) coloring coalesce = 
    let
        aloc' = Maybe.fromMaybe aloc (Map.lookup aloc coalesce)
    in
        Mem (mapToReg64 aloc' coloring)
mapToRegWithCoalescing (APtrq aloc) coloring coalesce =
    let
        aloc' = Maybe.fromMaybe aloc (Map.lookup aloc coalesce)
    in
        Mem (mapToReg64 aloc' coloring)
mapToRegWithCoalescing APtrNull coloring coalesce = Mem (Imm 0)
mapToRegWithCoalescing (AReg 7) coloring coalesce = Reg R10D
mapToRegWithCoalescing aloc coloring coalesce = 
    let
        aloc' = Maybe.fromMaybe aloc (Map.lookup aloc coalesce)
        coloringIdx = Maybe.fromMaybe 0 (Map.lookup aloc' coloring)
    in
        if coloringIdx < length regOrder
            then Reg $ regOrder !! coloringIdx
            else Mem' ((coloringIdx - length regOrder + 1) * 8) RSP

-- 64 bit version of mapToReg
mapToRegWithCoalescing64 :: ALoc -> Coloring -> Map.Map ALoc ALoc -> Operand
mapToRegWithCoalescing64 (APtrq aloc) coloring coalesce = Mem (mapToRegWithCoalescing64 aloc coloring coalesce)
mapToRegWithCoalescing64 APtrNull coloring coalesce = Mem (Imm 0)
mapToRegWithCoalescing64 (AReg 7) coloring coalesce = Reg R10
mapToRegWithCoalescing64 aloc coloring coalesce = case mappedReg of
    Reg r -> Reg $ toReg64 r
    _     -> mappedReg
    where 
        aloc' = Maybe.fromMaybe aloc (Map.lookup aloc coalesce)
        mappedReg = mapToReg aloc' coloring

-- Map a variable in abstract assembly to a register / memory location
mapToReg :: ALoc -> Coloring -> Operand
mapToReg (APtr aloc) coloring = Mem (mapToReg64 aloc coloring)
mapToReg (APtrq aloc) coloring = Mem (mapToReg64 aloc coloring)
mapToReg APtrNull coloring = Mem (Imm 0)
mapToReg (AReg 7) coloring = Reg R10D
mapToReg reg coloring = if coloringIdx < length regOrder
    then Reg $ regOrder !! coloringIdx
    else Mem' ((coloringIdx - length regOrder + 1) * 8) RSP
    where coloringIdx = Maybe.fromMaybe 0 (Map.lookup reg coloring)

-- 64 bit version of mapToReg
mapToReg64 :: ALoc -> Coloring -> Operand
mapToReg64 (APtrq aloc) coloring = Mem (mapToReg64 aloc coloring)
mapToReg64 APtrNull coloring = Mem (Imm 0)
mapToReg64 (AReg 7) coloring = Reg R10
mapToReg64 reg coloring = case mappedReg of
    Reg r -> Reg $ toReg64 r
    _     -> mappedReg
    where mappedReg = mapToReg reg coloring

testGraph :: Graph
testGraph = Map.fromList
    [ (ATemp 0, Set.fromList [ATemp 1, ATemp 2, ATemp 3, ATemp 4])
    , (ATemp 1, Set.fromList [ATemp 0, ATemp 3, ATemp 4])
    , (ATemp 2, Set.fromList [ATemp 0, ATemp 3, ATemp 4])
    , (ATemp 3, Set.fromList [ATemp 1, ATemp 2, ATemp 4, ATemp 0])
    , (ATemp 4, Set.fromList [ATemp 1, ATemp 2, ATemp 3, ATemp 0])
    ]

testGraph2 :: Graph
testGraph2 = Map.fromList
    [ (ATemp 0, Set.singleton $ ATemp 1)
    , (ATemp 1, Set.singleton $ ATemp 0)
    , (ATemp 2, Set.singleton $ ATemp 3)
    , (ATemp 3, Set.singleton $ ATemp 2)
    , (ATemp 4, Set.fromList [ATemp 5, ATemp 6, ATemp 7])
    , (ATemp 5, Set.fromList [ATemp 4, ATemp 6, ATemp 7])
    , (ATemp 6, Set.fromList [ATemp 4, ATemp 5, ATemp 7])
    , (ATemp 7, Set.fromList [ATemp 4, ATemp 5, ATemp 6])
    ]

test :: IO ()
test = do
    let preColor = Map.fromList [(ATemp 0, 0), (ATemp 2, 1)]
    let seo      = mcs testGraph2 preColor
    let (coloring, _, _) = color testGraph2 seo preColor
    print seo
    print coloring
    print (mapToReg (ATemp 0) coloring)
    print (mapToReg (ATemp 3) coloring)