module Compile.Backend.LiveVariable where

import qualified Data.Set                      as Set
import qualified Data.Map                      as Map
import qualified Data.Maybe                    as Maybe

import           Compile.Types.Ops
import           Compile.Types

type Graph = Map.Map ALoc (Set.Set ALoc)

--(def set, successor list, use set)
type Pred = Map.Map Int (Set.Set ALoc, [Int], Set.Set ALoc)
--A map maps from the linenumber to the set of possible predecessors to linenumber
type Ancestor = Map.Map Int Set.Set Int
--line num to corresponding live variables
type Livelist = Map.Map Int Set.Set ALoc

--given a list of AVal, we just care about the temps, not the
--constants.
getLoc :: [AVal] -> Set.Set ALoc
getLoc []         = Set.empty
getLoc (x : rest) = case x of
    ALoc a -> Set.insert a (getLoc rest)
    _      -> getLoc rest

--reverse the abstract assembly, so that we can work backwards for live variables
--Stop at first return statment seen

--reverserAAsm accumulate original -> reversed result
reverseAAsm :: [AAsm] -> [AAsm] -> [AAsm]
reverseAAsm = foldl (flip (:))

--compute live list for a straight line of code
--TODO: 
{-for if else statement and loop, do a general tree stucture
    of the code by breaking control into segments, for each segment, 
    we do the single line livelist computes-}
addLineNum :: [AAsm] -> [(Int, AAsm)]
addLineNum = zip [0 ..] 

--find all the label locations of the AASM list into a mapping
findlabels :: [(Int, AAsm)] -> Map.Map ALabel Int -> Map.Map ALabel Int
findlabels [] mapping = mapping
findlabels ((idx, x):xs) mapping = 
    case x of
        AControl ALab l -> 
            let newmap = Map.insert l idx mapping
            in findlabels xs newmap
        _ -> findlabels xs mapping 

findlableIdx :: ALabel -> Map.Map ALabel Int -> Int
findlabelIdx l mapping = 
    case Map.lookup l mapping of 
        Just a -> a
        Nothing -> error "can't find the label index"

--compute the predicate facts needed about liveness, for each line, we need
--the use set, def set, and succ set. 
-- return (def set, succ list, use set)
computePredicate :: [(Int, AAsm)] -> Map.Map ALabel Int -> Pred -> Pred
computePredicate [] mapping pr = pr
computePredicate ((idx, x):xs) mapping pr =
    case x of
        AComment _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx+1], Set.empty) pr)
        ARet val -> case val of 
            ALoc a -> let linemap = Map.insert idx (Set.empty, [], Set.singleton a) pr
                in computePredicate xs mapping linemap
            AImm _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [], Set.empty) pr)
        AAsm assign op args -> 
            let linemap = Map.insert idx (Set.fromList assign, [idx+1], getLoc aArgs) pr
            in computePredicate xs mapping linemap
        ARel assign op args ->
            let linemap = Map.insert idx (Set.fromList assign, [idx+1], getLoc aArgs) pr
            in computePredicate xs mapping linemap
        AControl c -> case c of
            ALab _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx+1], Set.empty) pr)
            AJump l -> let
                labelidx = findlableIdx l mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [labelidx], Set.empty) pr)
            ACJump val l1 l2 -> let
                label1 = findlableIdx l1 mapping
                label2 = findlableIdx l2 mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [label1, label2], getLoc [val]) pr)
            ACJump' _ val1 val2 l1 l2 -> let
                label1 = findlableIdx l1 mapping
                label2 = findlableIdx l2 mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [label1, label2], getLoc [val1, val2]) pr)

createOrUpdate :: Ancestor -> Int -> Int -> Ancestor
createOrUpdate ances key value =
    case Map.lookup key ances of 
        Just s -> Map.insert key (Set.insert value s) ances
        Nothing -> Map.insert key (Set.singleton value) ances

--compute the ancestor list from the succ list
findAncestor :: Pred -> Ancestor
findAncestor = Map.foldlwithkey f Map.empty 
                where 
                    f :: Ancestor -> Int -> (Set.Set ALoc, [Int], Set.Set ALoc)
                         -> Ancestor
                    f ances k (_, [], _) = ances
                    f ances k (_, x:xs, _) = let
                        newances = createOrUpdate ances x k
                        in
                            f newances k (_, xs, _)

linelive :: Livelist -> ALoc -> Int -> Livelist
linelive livel var idx = let 
    curr = livel Map.(!) idx
    in
        if Set.member var curr then livel
        else Map.insert linenum (Set.insert var curr) livel

singleVarLive :: ALoc -> Set.Set Int -> Pred -> Ancestor -> Livelist -> Livelist
--ALoc -> line num -> ancestor list -> predicate -> livelist
singleVarLive a ancesset pr ancest livel = if ancessset == Set.empty then livel
    else let
        (defset, succlist, useset) = pr Map.(!) linenum
        in
            --if the ancestor has the variable in the liveset, we know we have looked 
            --everything before its ancestor, we just need to return livelist
            if Set.member a useset then livel
            else
                Set.foldr g livel ancesset 
                where 
                    g :: Int -> Livelist -> Livelist
                    g line liveset = let
                        newances = Maybe.fromMaybe Set.empty (Map.lookup line ancest) 
                        somelivel = Maybe.fromMaybe Set.empty (Map.lookup a livel)
                        newlivel = Map.insert line (Set.insert a somelivel)
                        in
                            singleVarLive line newances pr ancest newlivel 
    

--compute liveness based on each individual variable from lecture notes
--l is initialized as a list of empty sets
--numvar is the index of variable we should look at this round
--i is the line we start looking at, initialized as the length of AASM, when i = 0 we done,
--we only increment i if there is no more used variable to look at at the line i
--ances is the list of predessors we use to look upwards
computeLive :: Int -> Int -> Pred -> Ancestor -> Livelist -> Livelist
computeLive 0 varidx pr ances livel = livel
computeLive linenum varidx pr ances livel = let
    (defset, succlist, useset) = pr Map.(!) linenum 
    size = Set.size useset
    --precondition: varidx < size useset
    --this shouldnt be empty, since only line 0 would have zero ancestors
    ancesset = Maybe.fromMaybe Set.empty (Map.lookup livenum ances)
    in
        if ancesset == Set.empty then livel
        --find liveness to the one above
        else if varidx > size - 1 then computeLive (linenum-1) 0 pr ances livel
        else let 
                var = Set.elemAt varidx useset
                newlivl = linelive var

                livelist = singleVarLive var ancesset pr ances newlivl 
                in
                    if varidx == size - 1 then computeLive (linenum - 1) 0 pr livelist
                    else computeLive linenum (varidx+1) pr ances livelist
--TODO: after computed liveness, we need to also check the condition where variable gets declared but never used, so do another iteration to check just this


addEdge :: (ALoc, ALoc) -> Graph -> Graph
addEdge (u, v) g = case Map.lookup u g of
    Just sset -> Map.adjust (Set.insert v) u g
    Nothing   -> Map.insert u (Set.singleton v) g

isSameLoc :: AVal -> ALoc -> Bool
isSameLoc x y = case x of
    ALoc x' -> x' == y
    _       -> False

combinelive :: [Int] -> Livelist -> Set.Set ALoc
combinelive l live = List.foldl h (Set.empty) l
    where
        h :: Set.Set ALoc -> Int -> Set.Set ALoc
        h set1 idx = Set.union set1 (live Map.(!) idx)

--build interference graph, we can just care about the predicate relationship for each line, but
--we do need to case on div, mod (rax, rdx) and shift (rcx) for special register allocation.
buildInterfere :: [(Int, AAsm)] -> Livelist -> Pred -> Graph -> Graph
buildInterfere [] _ _ g _ = g
buildInterfere ((idx, x) : xs) live pr g =
    let 
        (defset, succlist, useset) = pr Map.(!) idx
        liveVars = combinelive succlist live
    in
        case x of
            AAsm [dest] ANop [src] ->
                let 
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl
                        (\g' v -> if not (isSameLoc src v) && dest /= v
                            then addEdge (v, dest) (addEdge (dest, v) g')
                            else g'
                        )
                        ginit
                        liveVars
                in  buildInterfere xs live pr newg
            AAsm [dest] asnop [_src1, _src2]
                | asnop == ADiv
                || asnop == ADivq
                || asnop == AMod
                || asnop == AModq
                -> let
                        ginit = case Map.lookup dest g of
                            Just _ -> g
                            Nothing -> Map.insert dest Set.empty g
                        newg = foldl (\g' v -> if dest /= v then addEdge (v, dest) (addEdge (dest, v) g') else g') ginit liveVars
                        newg' = foldl (\g' v -> addEdge (v, AReg 1) (addEdge (AReg 1, v) (addEdge (v, AReg 0) (addEdge (AReg 0, v) g')))) newg liveVars
                   in  buildInterfere xs live pr newg'
            AAsm [dest] asnop [_src1, _src2]
                | asnop == ASal
                || asnop == ASar
                -> let
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl (\g' v -> if dest /= v then addEdge (v, dest) (addEdge (dest, v) g') else g') ginit liveVars
                    newg' = foldl (\g' v -> addEdge (v, AReg 2) (addEdge (AReg 2, v) g')) newg liveVars
                    in buildInterfere xs live pr newg'
            AAsm [dest] _ [_src1, _src2] ->
                let
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl
                        (\g' v -> if dest /= v
                            then addEdge (v, dest) (addEdge (dest, v) g')
                            else g'
                        )
                        ginit
                        liveVars
                in  buildInterfere xs live pr newg
            ARet _ -> g
            _ -> buildInterfere xs live pr g

{-
buildInterfere :: [AAsm] -> [Set.Set ALoc] -> Graph -> Int -> Graph
buildInterfere [] _ g _ = g
buildInterfere (x : xs) live g i =
    let liveVars = live !! (i + 1)
    in
        case x of
            AAsm [dest] ANop [src] ->
                let 
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl
                        (\g' v -> if not (isSameLoc src v) && dest /= v
                            then addEdge (v, dest) (addEdge (dest, v) g')
                            else g'
                        )
                        ginit
                        liveVars
                in  buildInterfere xs live newg (i + 1)
            AAsm [dest] asnop [_src1, _src2]
                | asnop == ADiv
                || asnop == ADivq
                || asnop == AMod
                || asnop == AModq
                -> let
                        ginit = case Map.lookup dest g of
                            Just _ -> g
                            Nothing -> Map.insert dest Set.empty g
                        newg = foldl (\g' v -> if dest /= v then addEdge (v, dest) (addEdge (dest, v) g') else g') ginit liveVars
                        newg' = foldl (\g' v -> addEdge (v, AReg 1) (addEdge (AReg 1, v) (addEdge (v, AReg 0) (addEdge (AReg 0, v) g')))) newg liveVars
                   in  buildInterfere xs live newg' (i + 1)
            AAsm [dest] _ [_src1, _src2] ->
                let
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl
                        (\g' v -> if dest /= v
                            then addEdge (v, dest) (addEdge (dest, v) g')
                            else g'
                        )
                        ginit
                        liveVars
                in  buildInterfere xs live newg (i + 1)
            ARet _ -> g
            _ -> buildInterfere xs live g (i + 1)
-}

--example from Written 1
exAASM :: [AAsm]
exAASM =
    [ AAsm { aAssign = [ATemp 0], aOp = ANop, aArgs = [AImm (-9)] }
    , AAsm { aAssign = [ATemp 1], aOp = ANop, aArgs = [AImm 1] }
    , AAsm { aAssign = [ATemp 2], aOp = ANop, aArgs = [AImm 2] }
    , AAsm { aAssign = [ATemp 3], aOp = ANop, aArgs = [AImm 3] }
    , AAsm { aAssign = [ATemp 4]
           , aOp     = AMul
           , aArgs   = [ALoc (ATemp 2), ALoc (ATemp 3)]
           }
    , AAsm { aAssign = [ATemp 5]
           , aOp     = AAdd
           , aArgs   = [ALoc (ATemp 1), ALoc (ATemp 4)]
           }
    , AAsm { aAssign = [ATemp 6]
           , aOp     = AAdd
           , aArgs   = [ALoc (ATemp 0), ALoc (ATemp 5)]
           }
    , AAsm { aAssign = [ATemp 7], aOp = ANop, aArgs = [AImm 2] }
    ,
    --T11 should interfere with everything Immediately after this line even if its not used
      AAsm { aAssign = [ATemp 11], aOp = ANop, aArgs = [AImm 5] }
    , AAsm { aAssign = [ATemp 8]
           , aOp     = AAdd
           , aArgs   = [ALoc (ATemp 6), ALoc (ATemp 7)]
           }
    , AAsm { aAssign = [ATemp 9], aOp = ANop, aArgs = [AImm 4] }
    , AAsm { aAssign = [ATemp 10]
           , aOp     = ADiv
           , aArgs   = [ALoc (ATemp 8), ALoc (ATemp 9)]
           }
    , AAsm { aAssign = [AReg 0]
           , aOp     = AMod
           , aArgs   = [ALoc (ATemp 6), ALoc (ATemp 10)]
           }
    , ARet (ALoc (AReg 0))
    ]


testLive :: IO ()
testLive = do
    print exAASM
    print (computeLive ([], reverseAAsm [] exAASM))

testInterfereNew :: IO ()
testInterfereNew = do
    let (livelist, _) = computeLive ([], reverseAAsm [] exAASM)
    print exAASM
    print livelist
    print (buildInterfere exAASM livelist Map.empty 0)