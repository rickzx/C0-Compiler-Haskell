module Compile.Backend.LiveVariable where

import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set
import qualified Data.List as List
import Debug.Trace

import Compile.Types

type Graph = Map.Map ALoc (Set.Set ALoc)

--(def set, successor list, use set)
type Pred = Map.Map Int (Set.Set ALoc, [Int], Set.Set ALoc)

--A map maps from the linenumber to the set of possible predecessors to linenumber
type Ancestor = Map.Map Int (Set.Set Int)

--line num to corresponding live variables
type LiveList = Map.Map Int (Set.Set ALoc)

--given a list of AVal, we just care about the temps, not the
--constants.
getLoc :: [AVal] -> Set.Set ALoc
getLoc [] = Set.empty
getLoc (x:rest) =
    case x of
        ALoc a@(AReg _) -> Set.insert a (getLoc rest)
        ALoc a@(ATemp _) -> Set.insert a (getLoc rest)
        ALoc (APtr p) -> Set.insert p (getLoc rest)
        ALoc (APtrq p) -> Set.insert p (getLoc rest)
        _ -> getLoc rest

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

findlabelIdx :: ALabel -> Map.Map ALabel Int -> Int
findlabelIdx l mapping = Maybe.fromMaybe (-1) (Map.lookup l mapping)

--compute the predicate facts needed about liveness, for each line, we need
--the use set, def set, and succ set.
-- return (def set, succ list, use set)
computePredicate :: [(Int, AAsm)] -> Map.Map ALabel Int -> Pred -> Pred
computePredicate [] _ pr = pr
computePredicate ((idx, x):xs) mapping pr =
    case x of
        AComment _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx + 1], Set.empty) pr)
        ARet val ->
            let linemap = Map.insert idx (Set.empty, [], getLoc [val]) pr
             in computePredicate xs mapping linemap
        AAsm [assign] _ args ->
            let linemap = case assign of
                    AReg _ -> Map.insert idx (Set.singleton assign, [idx + 1], getLoc args) pr
                    ATemp _ -> Map.insert idx (Set.singleton assign, [idx + 1], getLoc args) pr
                    APtr p -> Map.insert idx (Set.singleton p, [idx + 1], Set.insert p $ getLoc args) pr
                    APtrq p -> Map.insert idx (Set.singleton p, [idx + 1], Set.insert p $ getLoc args) pr
                    APtrNull -> Map.insert idx (Set.empty, [idx + 1], getLoc args) pr
             in computePredicate xs mapping linemap
        ARel [assign] _ args ->
            let linemap = case assign of
                    AReg _ -> Map.insert idx (Set.singleton assign, [idx + 1], getLoc args) pr
                    ATemp _ -> Map.insert idx (Set.singleton assign, [idx + 1], getLoc args) pr
                    APtr p -> Map.insert idx (Set.singleton p, [idx + 1], Set.insert p $ getLoc args) pr
                    APtrq p -> Map.insert idx (Set.singleton p, [idx + 1], Set.insert p $ getLoc args) pr
                    APtrNull -> Map.insert idx (Set.empty, [idx + 1], getLoc args) pr
             in computePredicate xs mapping linemap
        AFun l extraargs -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx + 1], Set.empty) pr)
        ACall l extraargs number ->
            let definedregs = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6, AReg 0, AReg 7, AReg 8]
                usedregs = take number definedregs
                extra = getLoc extraargs
                linemap = Map.insert idx (Set.fromList definedregs, [idx + 1], Set.union extra (Set.fromList usedregs)) pr
             in computePredicate xs mapping linemap
        AControl c ->
            case c of
                ALab _ -> computePredicate xs mapping (Map.insert idx (Set.empty, [idx + 1], Set.empty) pr)
                AJump l 
                    | "_ret" `List.isSuffixOf` l ->
                        let labelidx = findlabelIdx l mapping
                         in computePredicate xs mapping (Map.insert idx (Set.empty, [labelidx], Set.singleton (AReg 0)) pr)                        
                    | otherwise -> 
                        let labelidx = findlabelIdx l mapping
                         in computePredicate xs mapping (Map.insert idx (Set.empty, [labelidx], Set.empty) pr)
                ACJump val l1 l2 ->
                    let label1 = findlabelIdx l1 mapping
                        label2 = findlabelIdx l2 mapping
                     in computePredicate xs mapping (Map.insert idx (Set.empty, [label1, label2], getLoc [val]) pr)
                ACJump' _ val1 val2 l1 l2 ->
                    let label1 = findlabelIdx l1 mapping
                        label2 = findlabelIdx l2 mapping
                     in computePredicate
                            xs
                            mapping
                            (Map.insert idx (Set.empty, [label1, label2], getLoc [val1, val2]) pr)

createOrUpdate :: Ancestor -> Int -> Int -> Ancestor
createOrUpdate ances key value =
    case Map.lookup key ances of
        Just s -> Map.insert key (Set.insert value s) ances
        Nothing -> Map.insert key (Set.singleton value) ances

--compute the ancestor list from the succ list
findAncestor :: Pred -> Ancestor
findAncestor = Map.foldlWithKey f Map.empty
  where
    f :: Ancestor -> Int -> (Set.Set ALoc, [Int], Set.Set ALoc) -> Ancestor
    f ances _ (_s1, [], _s2) = ances
    f ances k (s1, x:xs, s2) =
        let newances = createOrUpdate ances x k
         in f newances k (s1, xs, s2)

--check whether the variable is already in the livelist of the line, if it is
--then it must also be in all of its predecessors so we dont have to compute again
linelive :: LiveList -> ALoc -> Int -> (LiveList, Bool)
linelive livel var idx =
    let curr = Maybe.fromMaybe Set.empty (Map.lookup idx livel)
     in if Set.member var curr
            then (livel, False)
            else (Map.insert idx (Set.insert var curr) livel, True)

singleVarLive :: ALoc -> Set.Set Int -> Pred -> Ancestor -> LiveList -> LiveList
--ALoc -> ancestor list -> predicate -> livelist
singleVarLive a ancesset pr ancest livel =
    if ancesset == Set.empty
        then livel
        else Set.foldr g livel ancesset
  where
    g :: Int -> LiveList -> LiveList
    g line liveset =
        let (defset, _, _) = pr Map.! line
            currlive = Maybe.fromMaybe Set.empty (Map.lookup line liveset)
         in if Set.member a defset || Set.member a currlive
                then liveset
                else let newances = Maybe.fromMaybe Set.empty (Map.lookup line ancest)
                         somelivel = Maybe.fromMaybe Set.empty (Map.lookup line liveset)
                         newlivel = Map.insert line (Set.insert a somelivel) liveset
                      in singleVarLive a newances pr ancest newlivel

--compute liveness based on each individual variable from lecture notes
--l is initialized as a list of empty sets
--numvar is the index of variable we should look at this round
--i is the line we start looking at, initialized as the length of AASM, when i = 0 we done,
--we only increment i if there is no more used variable to look at at the line i
--ances is the list of predessors we use to look upwards
computeLive :: Int -> Int -> Pred -> Ancestor -> LiveList -> LiveList
computeLive 0 _ _ _ livel = livel
computeLive linenum varidx pr ances livel =
    let (_, _, useset) = pr Map.! linenum
        size = Set.size useset
    --precondition: varidx < size useset
    --this shouldnt be empty, since only line 0 would have zero ancestors
        ancesset = Maybe.fromMaybe Set.empty (Map.lookup linenum ances)
     in if varidx > size - 1
            then computeLive (linenum - 1) 0 pr ances livel
            else let var = Set.elemAt varidx useset
                     (newlivl, keepgoing) = linelive livel var linenum
                  in if not keepgoing
                         then computeLive linenum (varidx + 1) pr ances newlivl
                         else let livelist = singleVarLive var ancesset pr ances newlivl
                               in if varidx == size - 1
                                      then computeLive (linenum - 1) 0 pr ances livelist
                                      else computeLive linenum (varidx + 1) pr ances livelist

addEdge :: (ALoc, ALoc) -> Graph -> Graph
addEdge (u, v) g =
    case Map.lookup u g of
        Just _sset -> Map.adjust (Set.insert v) u g
        Nothing -> Map.insert u (Set.singleton v) g

isSameLoc :: AVal -> ALoc -> Bool
isSameLoc x y =
    case x of
        ALoc x' -> x' == y
        _ -> False

combinelive :: [Int] -> LiveList -> Set.Set ALoc
combinelive l live = foldl h (Set.empty) l
  where
    h :: Set.Set ALoc -> Int -> Set.Set ALoc
    h set1 idx =
        let unioned = Maybe.fromMaybe Set.empty (Map.lookup idx live)
         in Set.union set1 unioned

--build interference graph, we can just care about the succlist relationship for each line, but
--we do need to case on div, mod (rax, rdx) and shift (rcx) for special register allocation.
buildInterfere :: [(Int, AAsm)] -> LiveList -> Pred -> Graph -> Graph
buildInterfere [] _ _ g = g
buildInterfere ((idx, x):xs) live pr g =
    let (_, succlist, _) = pr Map.! idx
        liveVars = combinelive succlist live
        --liveVars = Maybe.fromMaybe Set.empty (Map.lookup (idx+1) live)
     in case x of
            AAsm [dest] ANop [src] ->
                let ginit =
                        case Map.lookup dest g of
                            Just _ -> g
                            Nothing -> Map.insert dest Set.empty g
                    newg =
                        foldl
                            (\g' v ->
                                 if not (isSameLoc src v) && dest /= v
                                     then addEdge (v, dest) (addEdge (dest, v) g')
                                     else g')
                            ginit
                            liveVars
                 in buildInterfere xs live pr newg
            AAsm [dest] asnop _srcs
                | asnop == ADiv || asnop == ADivq || asnop == AMod || asnop == AModq ->
                    let ginit =
                            case Map.lookup dest g of
                                Just _ -> g
                                Nothing -> Map.insert dest Set.empty g
                        newg =
                            foldl
                                (\g' v ->
                                     if dest /= v
                                         then addEdge (v, dest) (addEdge (dest, v) g')
                                         else g')
                                ginit
                                liveVars
                        newg' =
                            foldl
                                (\g' v ->
                                     addEdge
                                         (v, AReg 1)
                                         (addEdge (AReg 1, v) (addEdge (v, AReg 0) (addEdge (AReg 0, v) g'))))
                                newg
                                liveVars
                     in buildInterfere xs live pr newg'
                | asnop == ASal || asnop == ASar ->
                    let ginit =
                            case Map.lookup dest g of
                                Just _ -> g
                                Nothing -> Map.insert dest Set.empty g
                        newg =
                            foldl
                                (\g' v ->
                                     if dest /= v
                                         then addEdge (v, dest) (addEdge (dest, v) g')
                                         else g')
                                ginit
                                liveVars
                        newg' = foldl (\g' v -> addEdge (v, AReg 2) (addEdge (AReg 2, v) g')) newg liveVars
                     in buildInterfere xs live pr newg'
                | otherwise ->
                    let ginit =
                            case Map.lookup dest g of
                                Just _ -> g
                                Nothing -> Map.insert dest Set.empty g
                        newg =
                            foldl
                                (\g' v ->
                                     if dest /= v
                                         then addEdge (v, dest) (addEdge (dest, v) g')
                                         else g')
                                ginit
                                liveVars
                     in buildInterfere xs live pr newg
            ARel [dest] _ _srcs ->
                let ginit =
                        case Map.lookup dest g of
                            Just _ -> g
                            Nothing -> Map.insert dest Set.empty g
                    newg =
                        foldl
                            (\g' v ->
                                 if dest /= v
                                     then addEdge (v, dest) (addEdge (dest, v) g')
                                     else g')
                            ginit
                            liveVars
                 in buildInterfere xs live pr newg
            ACall _ _ _ ->
                let regused = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6, AReg 0, AReg 7, AReg 8]
                    res = foldl f_fn g regused
                      where
                        f_fn :: Graph -> ALoc -> Graph
                        f_fn gra a =
                            let ginit =
                                    case Map.lookup a gra of
                                        Just _ -> gra
                                        Nothing -> Map.insert a Set.empty gra
                                newg =
                                    foldl
                                        (\g' v ->
                                             if a /= v
                                                 then addEdge (v, a) (addEdge (a, v) g')
                                                 else g')
                                        ginit
                                        liveVars
                             in newg
                 in buildInterfere xs live pr res
            AFun _ extraArgs ->
                let 
                    res = foldl f_fn g extraArgs
                      where
                        f_fn :: Graph -> ALoc -> Graph
                        f_fn gra a =
                            let ginit =
                                    case Map.lookup a gra of
                                        Just _ -> gra
                                        Nothing -> Map.insert a Set.empty gra
                                newg =
                                    foldl
                                        (\g' v ->
                                             if a /= v
                                                 then addEdge (v, a) (addEdge (a, v) g')
                                                 else g')
                                        ginit
                                        liveVars
                             in newg
                 in buildInterfere xs live pr res
            _ -> buildInterfere xs live pr g

--(function name, (AASM generated, # of var)
computerInterfere :: [AAsm] -> Graph
computerInterfere aasm =
    let processed = reverse (addLineNum aasm)
        labels = findlabels processed Map.empty
        predec = computePredicate processed labels Map.empty
        ancestors = findAncestor predec
        size =
            case processed of
                [] -> 0
                (idx, _):_xs -> idx
        liveness = computeLive size 0 predec ancestors Map.empty
        -- (trace $ "Predicate: " ++ show predec ++ "\n\n" ++ "Ancestors :" ++ show ancestors ++ "\n\n" ++ "Liveness: " ++ show liveness ++ "\n")
     in buildInterfere processed liveness predec Map.empty
     
ssaLive :: [AAsm] -> (LiveList, Pred)
ssaLive aasm =
    let processed = reverse (addLineNum aasm)
        labels = findlabels processed Map.empty
        predec = computePredicate processed labels Map.empty
        ancestors = findAncestor predec
        size =
            case processed of
                [] -> 0
                (idx, _):_xs -> idx
        ll = computeLive size 0 predec ancestors Map.empty
    in (ll, predec)