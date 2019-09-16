module Compile.Backend.LiveVariable where

import qualified Data.Set                      as Set
import qualified Data.Map                      as Map

import           Compile.Types.Ops
import           Compile.Types

type Graph = Map.Map ALoc (Set.Set ALoc)
--given a list of AVal, we just care about the temps, not the
--constants.
getLoc :: [AVal] -> Set.Set ALoc
getLoc []         = Set.empty
getLoc (x : rest) = case x of
    ALoc a -> Set.insert a (getLoc rest)
    _      -> getLoc rest

--reverse the abstract assembly, so that we can work backwards for live variables
--Stop at first return statment seen
reverseAAsm :: [AAsm] -> [AAsm] -> [AAsm]
reverseAAsm _   []         = error "the AAsm has no return statement"
reverseAAsm acc (x : rest) = case x of
    ARet _ -> x : acc
    _      -> reverseAAsm (x : acc) rest

--compute live list for a straight line of code
--TODO: 
{-for if else statement and loop, do a general tree stucture
    of the code by breaking control into segments, for each segment, 
    we do the single line livelist computes-}
computeLive :: ([Set.Set ALoc], [AAsm]) -> ([Set.Set ALoc], [AAsm])
computeLive (accset, []     ) = (accset, [])
computeLive (accset, x : ast) = case x of
    ARet retval -> case retval of
        ALoc a -> computeLive ([Set.singleton a], ast)
        AImm _ -> computeLive ([Set.empty], ast)
    AComment _ -> computeLive (accset, ast)
    AAsm { aAssign = assign, aOp = op, aArgs = args } -> case accset of
        [] -> error "The last statement of AAsm is not return"
        y : rest ->
            let
                relev       = getLoc args
                assigned    = Set.fromList assign
                current     = (Set.union y relev) Set.\\ (assigned)
                --if var is defined in this line, it must be live immediately
                --after the line to avoid register allocate conflicts.
                --if div, we also need to reserve rax and rdx for storing quotient and remainder
                updatedNext = Set.union y assigned
            in
                computeLive (current : updatedNext : rest, ast)

addEdge :: (ALoc, ALoc) -> Graph -> Graph
addEdge (u, v) g = case Map.lookup u g of
    Just sset -> Map.adjust (Set.insert v) u g
    Nothing   -> Map.insert u (Set.singleton v) g

isSameLoc :: AVal -> ALoc -> Bool
isSameLoc x y = case x of
    ALoc x' -> x' == y
    _       -> False

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
