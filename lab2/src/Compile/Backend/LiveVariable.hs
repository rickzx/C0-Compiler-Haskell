module Compile.Backend.LiveVariable where

import qualified Data.Set                      as Set
import qualified Data.Map                      as Map
import qualified Data.Maybe                    as Maybe
import Debug.Trace

import           Compile.Types.Ops
import           Compile.Types

type Graph = Map.Map ALoc (Set.Set ALoc)

--(def set, successor list, use set)
type Pred = Map.Map Int (Set.Set ALoc, [Int], Set.Set ALoc)
--A map maps from the linenumber to the set of possible predecessors to linenumber
type Ancestor = Map.Map Int (Set.Set Int)
--line num to corresponding live variables
type Livelist = Map.Map Int (Set.Set ALoc)

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
reverseAAsm :: [(Int, AAsm)] -> [(Int, AAsm)] -> [(Int, AAsm)]
reverseAAsm = foldl (flip (:))

--compute live list for a straight line of code

addLineNum :: [AAsm] -> [(Int, AAsm)]
addLineNum = zip [0 ..] 

--find all the label locations of the AASM list into a mapping
findlabels :: [(Int, AAsm)] -> Map.Map ALabel Int -> Map.Map ALabel Int
findlabels [] mapping = mapping
findlabels ((idx, x):xs) mapping = 
    case x of
        AControl (ALab l) -> 
            let newmap = Map.insert l idx mapping
            in findlabels xs newmap
        _ -> findlabels xs mapping 

--TODO: make this an useful error message instead of just -1
findlabelIdx :: ALabel -> Map.Map ALabel Int -> Int
findlabelIdx l mapping = Maybe.fromMaybe (-1) (Map.lookup l mapping)


--compute the predicate facts needed about liveness, for each line, we need
--the use set, def set, and succ set. 
-- return (def set, succ list, use set)
computePredicate :: [(Int, AAsm)] -> Map.Map ALabel Int -> Pred -> Pred
computePredicate [] _ pr = pr
computePredicate ((idx, x):xs) mapping pr =
    case x of
        AComment _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx+1], Set.empty) pr)
        ARet val -> case val of 
            ALoc a -> let linemap = Map.insert idx (Set.empty, [], Set.singleton a) pr
                in computePredicate xs mapping linemap
            AImm _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [], Set.empty) pr)
        AAsm assign _ args -> 
            let linemap = Map.insert idx (Set.fromList assign, [idx+1], getLoc args) pr
            in computePredicate xs mapping linemap
        ARel assign _ args ->
            let linemap = Map.insert idx (Set.fromList assign, [idx+1], getLoc args) pr
            in computePredicate xs mapping linemap
        AControl c -> case c of
            ALab _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx+1], Set.empty) pr)
            AJump l -> let
                labelidx = findlabelIdx l mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [labelidx], Set.empty) pr)
            ACJump val l1 l2 -> let
                label1 = findlabelIdx l1 mapping
                label2 = findlabelIdx l2 mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [label1, label2], getLoc [val]) pr)
            ACJump' _ val1 val2 l1 l2 -> let
                label1 = findlabelIdx l1 mapping
                label2 = findlabelIdx l2 mapping
                in computePredicate xs mapping (Map.insert idx (Set.empty, [label1, label2], getLoc [val1, val2]) pr)

createOrUpdate :: Ancestor -> Int -> Int -> Ancestor
createOrUpdate ances key value =
    case Map.lookup key ances of 
        Just s -> Map.insert key (Set.insert value s) ances
        Nothing -> Map.insert key (Set.singleton value) ances

--compute the ancestor list from the succ list
findAncestor :: Pred -> Ancestor
findAncestor = Map.foldlWithKey f Map.empty 
                where 
                    f :: Ancestor -> Int -> (Set.Set ALoc, [Int], Set.Set ALoc)
                         -> Ancestor
                    f ances _ (s1, [], s2) = ances
                    f ances k (s1, x:xs, s2) = let
                        newances = createOrUpdate ances x k
                        in
                            f newances k (s1, xs, s2)

--check whether the variable is already in the livelist of the line, if it is
--then it must also be in all of its predecessors so we dont have to compute again
linelive :: Livelist -> ALoc -> Int -> (Livelist, Bool)
linelive livel var idx = let 
    curr = Maybe.fromMaybe Set.empty (Map.lookup idx livel)
    in
        if Set.member var curr then (livel , False)
        else (Map.insert idx (Set.insert var curr) livel , True)

singleVarLive :: ALoc -> Set.Set Int -> Pred -> Ancestor -> Livelist -> Livelist
--ALoc -> ancestor list -> predicate -> livelist
singleVarLive a ancesset pr ancest livel = if ancesset == Set.empty then livel
        else Set.foldr g livel ancesset
         where 
            g :: Int -> Livelist -> Livelist
            g line liveset = let
                (defset, _, _) = pr Map.! line
                currlive = Maybe.fromMaybe Set.empty (Map.lookup line livel)
                in if Set.member a defset || Set.member a currlive then liveset
                   else let
                        newances = Maybe.fromMaybe Set.empty (Map.lookup line ancest) 
                        somelivel = Maybe.fromMaybe Set.empty (Map.lookup line liveset)
                        newlivel = Map.insert line (Set.insert a somelivel) liveset
                        in 
                                singleVarLive a newances pr ancest newlivel 

--compute liveness based on each individual variable from lecture notes
--l is initialized as a list of empty sets
--numvar is the index of variable we should look at this round
--i is the line we start looking at, initialized as the length of AASM, when i = 0 we done,
--we only increment i if there is no more used variable to look at at the line i
--ances is the list of predessors we use to look upwards
computeLive :: Int -> Int -> Pred -> Ancestor -> Livelist -> Livelist
computeLive 0 _ _ _ livel = livel
computeLive linenum varidx pr ances livel = let
    (_, _, useset) = pr Map.! linenum 
    size = Set.size useset
    --precondition: varidx < size useset
    --this shouldnt be empty, since only line 0 would have zero ancestors
    ancesset = Maybe.fromMaybe Set.empty (Map.lookup linenum ances)
    in
        if ancesset == Set.empty then livel
        --find liveness to the one above
        else if varidx > size - 1 then computeLive (linenum-1) 0 pr ances livel
        else let 
                var = Set.elemAt varidx useset
                (newlivl, keepgoing) = linelive livel var linenum
             in
                if not keepgoing then computeLive linenum (varidx+1) pr ances livel 
                else
                    let
                        livelist = singleVarLive var ancesset pr ances newlivl 
                    in
                        if varidx == size - 1 then  computeLive (linenum - 1) 0 pr ances livelist
                        else computeLive linenum (varidx+1) pr ances livelist

addEdge :: (ALoc, ALoc) -> Graph -> Graph
addEdge (u, v) g = case Map.lookup u g of
    Just sset -> Map.adjust (Set.insert v) u g
    Nothing   -> Map.insert u (Set.singleton v) g

isSameLoc :: AVal -> ALoc -> Bool
isSameLoc x y = case x of
    ALoc x' -> x' == y
    _       -> False

combinelive :: [Int] -> Livelist -> Set.Set ALoc
combinelive l live = foldl h (Set.empty) l
    where
        h :: Set.Set ALoc -> Int -> Set.Set ALoc
        h set1 idx = let
            unioned = Maybe.fromMaybe Set.empty (Map.lookup idx live) in
            Set.union set1 unioned

--build interference graph, we can just care about the succlist relationship for each line, but
--we do need to case on div, mod (rax, rdx) and shift (rcx) for special register allocation.
buildInterfere :: [(Int, AAsm)] -> Livelist -> Pred -> Graph -> Graph
buildInterfere [] _ _ g = g
buildInterfere ((idx, x) : xs) live pr g =
    let 
        (_, succlist, _) = pr Map.! idx
        liveVars = combinelive succlist live
        --liveVars = Maybe.fromMaybe Set.empty (Map.lookup (idx+1) live)
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
                        newg' = (trace $ show liveVars) foldl (\g' v -> addEdge (v, AReg 1) (addEdge (AReg 1, v) (addEdge (v, AReg 0) (addEdge (AReg 0, v) g')))) newg liveVars
                   in  buildInterfere xs live pr newg'
                | asnop == ASal
                || asnop == ASar
                -> let
                    ginit = case Map.lookup dest g of
                        Just _ -> g
                        Nothing -> Map.insert dest Set.empty g
                    newg = foldl (\g' v -> if dest /= v then addEdge (v, dest) (addEdge (dest, v) g') else g') ginit liveVars
                    newg' = foldl (\g' v -> addEdge (v, AReg 2) (addEdge (AReg 2, v) g')) newg liveVars
                    in buildInterfere xs live pr newg'
                | otherwise -> let
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
            ARel [dest] _ [_src1, _src2] ->
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
            _ -> buildInterfere xs live pr g

computerInterfere :: [AAsm] -> Graph
computerInterfere aasm = 
    let
        processed = reverseAAsm [] (addLineNum aasm)
        labels = findlabels processed (Map.empty)
        pred = computePredicate processed labels (Map.empty)
        ancestors = findAncestor pred
        size = case processed of 
            [] -> 0
            (idx, x):xs -> idx
        liveness = computeLive size 0 pred ancestors (Map.empty)  
    in
        buildInterfere (processed) liveness pred Map.empty

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
           , aOp     = AAdd
           , aArgs   = [ALoc (ATemp 6), ALoc (ATemp 10)]
           }
    , ARet (ALoc (AReg 0))
    ]

loopAASM :: [AAsm]
loopAASM = 
    [
        AAsm [ATemp 0] ANop [AImm 0],
        AAsm [ATemp 1] ANop [AImm 2],
        AAsm [ATemp 2] ANop [AImm 3],
        AControl (ALab "L0"),
        AControl (ACJump' ANe (ALoc $ ATemp 0) (AImm 0) "L1" "L2"),
        AControl (ALab "L1"),
        AControl (ACJump' ALe (ALoc $ ATemp 1) (ALoc $ ATemp 0) "L3" "L4"),
        AControl (ALab "L3"),
        AAsm [ATemp 5] AAdd [ALoc (ATemp 0), AImm 2],
        AAsm [ATemp 4] AAdd [ALoc (ATemp 1), AImm 2],
        AControl (AJump "L0"),
        AControl (ALab "L4"),
        AAsm [ATemp 6] AAdd [ALoc (ATemp 0), AImm 1],
        AAsm [ATemp 3] AAdd [ALoc (ATemp 2), AImm 1],
        AControl (AJump "L0"),
        AControl (ALab "L2"),
        AAsm [AReg 0] AAdd [ALoc (ATemp 2), ALoc (ATemp 1)],
        ARet (ALoc (AReg 0))
    ]

smallAAsm :: [AAsm]
smallAAsm = 
    [
        AAsm [ATemp 0] ANop [AImm 1],
        AAsm [AReg 0] ANop [AImm 1],
        ARet (ALoc (AReg 0))
    ]

testLive :: IO ()
testLive = let
    processed = reverseAAsm [] (addLineNum smallAAsm)
    labels = findlabels processed (Map.empty)
    pred = computePredicate processed labels (Map.empty)
    ancestors = findAncestor pred
    size = case processed of 
        [] -> 0
        (idx, x):xs -> idx
    liveness = computeLive size 0 pred ancestors (Map.empty)
    in
    do{
        print ancestors;
        print "__________________________";
        print pred;
        print "__________________________";
        print liveness
    }
testInterfereNew :: IO ()
testInterfereNew = 
    let
        processed = reverseAAsm [] (addLineNum smallAAsm)
        labels = findlabels processed (Map.empty)
        pred = computePredicate processed labels (Map.empty)
        ancestors = findAncestor pred
        size = case processed of 
            [] -> 0
            (idx, x):xs -> idx
        liveness = computeLive size 0 pred ancestors (Map.empty)
    in
        do{
            print exAASM;
            print "______________________________";
            print liveness;
            print "______________________________";
            print pred;
            print"______________________________";
            print (buildInterfere (processed) liveness pred Map.empty)
        }