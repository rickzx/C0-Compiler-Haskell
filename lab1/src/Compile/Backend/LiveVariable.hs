module Compile.Backend.LiveVariable where 

    import qualified Data.Set as Set
    import qualified Data.Map as Map

    import Compile.Types.Ops

    
    import Compile.Types
    
    type Graph = Map.Map ALoc (Set.Set ALoc)
    --given a list of AVal, we just care about the temps, not the
    --constants.
    getLoc :: [AVal] -> Set.Set ALoc
    getLoc [] = Set.empty
    getLoc (x:rest) = case x of
        ALoc a -> Set.insert a (getLoc rest)
        _ -> getLoc rest
    
    --reverse the abstract assembly, so that we can work backwards for live variables
    --Stop at first return statment seen
    reverseAAsm :: [AAsm] -> [AAsm] -> [AAsm]
    reverseAAsm _ [] = error "the AAsm has no return statement"
    reverseAAsm acc (x:rest) = case x of
        ARet _ -> x:acc
        _ -> reverseAAsm (x:acc) rest
    
    --compute live list for a straight line of code
    --TODO: 
    {-for if else statement and loop, do a general tree stucture
        of the code by breaking control into segments, for each segment, 
        we do the single line livelist computes-}
    computeLive :: ([Set.Set ALoc], [AAsm], Bool) -> ([Set.Set ALoc], [AAsm], Bool)
    computeLive (accset, [], _) = (accset, [], False)
    computeLive (accset, x:ast, prevDiv) = 
        case x of 
            ARet retval -> case retval of
                ALoc a -> computeLive([Set.singleton a], ast, False)
                AImm _ -> computeLive([Set.empty], ast, False)
            AComment _ -> computeLive(accset, ast, False)
            AAsm {aAssign = assign, aOp = op, aArgs = args} ->
                case accset of 
                    [] -> error "The last statement of AAsm is not return"
                    y:rest -> let
                        relev = getLoc args
                        assigned = Set.fromList assign
                        current = (Set.union y relev) Set.\\ (assigned)
                        --if var is defined in this line, it must be live immediately
                        --after the line to avoid register allocate conflicts.
                        --if div, we also need to reserve rax and rdx for storing quotient and remainder
                        updatedNext = if prevDiv then 
                            Set.union y (Set.union assigned (Set.fromList [AReg 0, AReg 1]))
                            else Set.union y assigned
                        in
                        if op == ADiv then computeLive(current:updatedNext:rest, ast, True)
                        else computeLive(current:updatedNext:rest, ast, False)

    --for each set we have, all the elements in the set interferes with each other,
    --thus, we separate the set into key value paring of each key and values interferes with it
    --requires Set != Empty
    findAllElem :: Set.Set ALoc -> ALoc -> (ALoc, Set.Set ALoc)
    findAllElem liveset a = if Set.member a liveset then (a, Set.delete a liveset)
        else let
            _ = error "interference graph input shouldnt be empty" in (a, liveset)
            
    findInterfere :: Set.Set ALoc -> Graph -> Graph
    findInterfere liveset g = let
        --(livevar, intefer group) for each element
        intef_set = Set.map (findAllElem liveset) liveset
        graph = Set.foldr fold_fn g intef_set where 
            fold_fn :: (ALoc, Set.Set ALoc) -> Graph -> Graph
            fold_fn (a, intset) g' = 
                case Map.lookup a g' of
                    Just sset -> let newset = Set.union sset intset in
                        Map.insert a newset g'      
                    Nothing -> Map.insert a intset g'
        in
            graph

    computeInterfere :: [Set.Set ALoc] -> Graph -> Graph
    computeInterfere [] g = g
    --change to computeInterfere xs (findInterfere x g) if error occur
    computeInterfere (x:xs) g = foldl (flip findInterfere) g xs

    --example from Written 1
    exAASM :: [AAsm]
    exAASM = [AAsm{aAssign = [ATemp 0], aOp = ANop, aArgs = [AImm (-9)]}, 
        AAsm{aAssign = [ATemp 1], aOp = ANop, aArgs = [AImm 1]},
        AAsm{aAssign = [ATemp 2], aOp = ANop, aArgs = [AImm 2]},
        AAsm{aAssign = [ATemp 3], aOp = ANop, aArgs = [AImm 3]},
        AAsm{aAssign = [ATemp 4], aOp = AMul, aArgs = [ALoc (ATemp 2), ALoc(ATemp 3)]},
        AAsm{aAssign = [ATemp 5], aOp = AAdd, aArgs = [ALoc (ATemp 1), ALoc(ATemp 4)]},
        AAsm{aAssign = [ATemp 6], aOp = AAdd, aArgs = [ALoc (ATemp 0), ALoc(ATemp 5)]},
        AAsm{aAssign = [ATemp 7], aOp = ANop, aArgs = [AImm 2]},
        --T11 should interfere with everything Immediately after this line even if its not used
        AAsm{aAssign = [ATemp 11], aOp = ANop, aArgs = [AImm 5]},
        AAsm{aAssign = [ATemp 8], aOp = AAdd, aArgs = [ALoc (ATemp 6), ALoc(ATemp 7)]},
        AAsm{aAssign = [ATemp 9], aOp = ANop, aArgs = [AImm 4]},
        AAsm{aAssign = [ATemp 10], aOp = ADiv, aArgs = [ALoc (ATemp 8), ALoc(ATemp 9)]},
        AAsm{aAssign = [AReg 0], aOp = AMod, aArgs = [ALoc (ATemp 6), ALoc(ATemp 10)]},
        AComment "This should do nothing",
        ARet (ALoc (AReg 0))]

    
    testLive :: IO ()
    testLive = do{
       print exAASM;
       print (computeLive([], reverseAAsm [] exAASM, False))
    }

    testInterfere :: IO ()
    testInterfere = let 
        (livelist, _, _) = computeLive([], reverseAAsm [] exAASM, False)
        in print(computeInterfere livelist Map.empty)

