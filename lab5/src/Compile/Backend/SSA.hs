module Compile.Backend.SSA where

import Compile.Types
import Control.Monad.State
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

import Debug.Trace

type DiGraph a = Map.Map a [a]

type Phi = (ALoc, [AVal])

type Block = ([Phi], [AAsm])

data StmtS = PhiS Int Ident Phi | AAsmS Int Ident AAsm deriving (Show)

instance Eq StmtS where
    (==) (PhiS l1 _ _) (PhiS l2 _ _) = l1 == l2
    (==) (AAsmS l1 _ _) (AAsmS l2 _ _) = l1 == l2
    (==) _ _ = False
    
instance Ord StmtS where
    compare (PhiS l1 _ _) (PhiS l2 _ _) = compare l1 l2
    compare (AAsmS l1 _ _) (AAsmS l2 _ _) = compare l1 l2
    compare (PhiS l1 _ _) (AAsmS l2 _ _) = compare l1 l2
    compare (AAsmS l1 _ _) (PhiS l2 _ _) = compare l1 l2

data BlockState =
    BlockState
        { currAAsm :: [AAsm]
        , currLabel :: Ident
        , blocks :: DiGraph Ident
        , predBlocks :: DiGraph Ident
        , blockList :: [(Ident, Block)]
        , origin :: Map.Map Ident [ALoc]
        , defsites :: Map.Map ALoc (Set.Set Ident)
        , globals :: Set.Set ALoc
        , seenGoto :: Bool
        }
    deriving (Show)

data RenameState =
    RenameState
        { varMap :: Map.Map Int [Int]
        , nextInt :: Int
        , renamedBlocks :: Map.Map Ident Block
        }

data DomState a =
    DomState
        { graph :: DiGraph a
        , predecessors :: DiGraph a
        , visited :: Set.Set a
        , postorder :: [a]
        , idom :: Map.Map a a
        , newidom :: a
        , change :: Bool
        , finger1 :: a
        , finger2 :: a
        , domfrontier :: Map.Map a (Set.Set a)
        , var :: a
        }

initHelper :: Ord k => k -> Map.Map k [v] -> Map.Map k [v]
initHelper k m =
    case Map.lookup k m of
        Just _ -> m
        Nothing -> Map.insert k [] m

ssa :: [AAsm]
    -> Ident
    -> (Map.Map Ident Block, [(Ident, Block)], DiGraph Ident, Map.Map Ident (Map.Map Ident Int), [Ident])
ssa aasms fn =
    let runToBlock = do
            toBlockM aasms fn
            g <- gets blocks
            p <- gets predBlocks
            b <- gets blockList
            glbs <- gets globals
            dsite <- gets defsites
            orig <- gets origin
            let fullg = foldr (\(n, _) gr -> initHelper n gr) g b
                fullp = foldr (\(n, _) gr -> initHelper n gr) p b
                pOrd = Map.foldrWithKey' (\n ps m -> Map.insert n (Map.fromList $ zip ps [0 ..]) m) Map.empty fullp
                (df, i) = domFrontiers fullg fullp fn
                origm = Map.foldrWithKey' (\n vs m -> Map.insert n (Set.fromList vs) m) Map.empty orig
                phis = insertPhis glbs dsite df origm fullp (Map.fromList b)
                domGraph =
                    Map.foldrWithKey' (\child par domg -> insertHelper par child domg) Map.empty (Map.delete fn i)
                fullDomG = foldr (\(n, _) gr -> initHelper n gr) domGraph b
                (initStack, maxTmp) = foldr (\aloc (m, maxtmp) -> case aloc of
                    ATemp n -> (Map.insert n [n] m, max n maxtmp)
                    _ -> error "SSA temps should be primitive") (Map.empty, 0) (Map.keys dsite)
                renamed = rename fn fullg fullDomG pOrd orig phis initStack maxTmp
                (finalG, finalP) = edgeSplit fullg pOrd
                addjmp = completeJump finalG renamed
                serialize = bfs finalG [] Set.empty [fn]
                finalblk =
                    map
                        (\nme -> (nme, fromMaybe (error $ "Elem not found1: " ++ nme) (Map.lookup nme addjmp)))
                        serialize
            return (addjmp, finalblk, finalG, Map.insert fn Map.empty finalP, serialize)
        blockInitState =
            BlockState
                { currAAsm = []
                , currLabel = fn
                , blocks = Map.empty
                , predBlocks = Map.empty
                , blockList = []
                , origin = Map.empty
                , defsites = Map.empty
                , globals = Set.empty
                , seenGoto = False
                }
     in evalState runToBlock blockInitState

dfsPost :: (Ord a, Show a) => a -> State (DomState a) ()
dfsPost node = do
    modify' $ \(DomState g p v o i n c f1 f2 d va) -> DomState g p (Set.insert node v) o i n c f1 f2 d va
    gr <- gets graph
    visit <- gets visited
    let neighbors = gr Map.! node
    foldM_
        (\_ v ->
             if Set.member v visit
                 then return ()
                 else dfsPost v)
        ()
        neighbors
    modify' $ \(DomState g p v o i n c f1 f2 d va) -> DomState g p v (node : o) i n c f1 f2 d va

genNewIdom :: (Ord a, Show a) => [a] -> State (DomState a) ()
genNewIdom ord = do
    let dfn = Map.fromList (zip (reverse ord) [0 ..])
        tord = tail ord
    modify' $ \(DomState g p vi o i n _ f1 f2 d va) -> DomState g p vi o i n False f1 f2 d va
    pre <- gets predecessors
    foldM_
        (\_ u -> do
             immd <- gets idom
             let proc = filter (`Map.member` immd) (pre Map.! u)
             modify' $ \(DomState g p vi o i _ c f1 f2 d va) -> DomState g p vi o i (head proc) c f1 f2 d va
             foldM_
                 (\_ v -> do
                      nido <- gets newidom
                      newimm <- intersect v nido dfn
                      modify' $ \(DomState g p vi o i _ c f1 f2 d va) -> DomState g p vi o i newimm c f1 f2 d va)
                 ()
                 (tail proc)
             nido <- gets newidom
             when (not (Map.member u immd) || (immd Map.! u /= nido)) $
                 modify' $ \(DomState g p vi o i n _ f1 f2 d va) ->
                     DomState g p vi o (Map.insert u nido i) n True f1 f2 d va)
        ()
        tord
  where
    intersect :: (Ord a, Show a) => a -> a -> Map.Map a Int -> State (DomState a) a
    intersect u v dfn = do
        modify' $ \(DomState g p vi o i n c _ _ d va) -> DomState g p vi o i n c u v d va
        let loop1 = do
                choose
                f1 <- gets finger1
                f2 <- gets finger2
                when (f1 /= f2) loop1
            loop2 = do
                modify' $ \(DomState g p vi o i n c f1 f2 d va) ->
                    DomState g p vi o i n c (fromMaybe (error "SSA1") (Map.lookup f1 i)) f2 d va
                f1 <- gets finger1
                f2 <- gets finger2
                when (dfn Map.! f1 < dfn Map.! f2) loop2
            loop3 = do
                modify' $ \(DomState g p vi o i n c f1 f2 d va) ->
                    DomState g p vi o i n c f1 (fromMaybe (error "SSA2") (Map.lookup f2 i)) d va
                f1 <- gets finger1
                f2 <- gets finger2
                when (dfn Map.! f1 > dfn Map.! f2) loop3
            choose = do
                f1 <- gets finger1
                f2 <- gets finger2
                when (dfn Map.! f1 < dfn Map.! f2) loop2
                f3 <- gets finger1
                f4 <- gets finger2
                when (dfn Map.! f3 > dfn Map.! f4) loop3
        when (u /= v) loop1
        gets finger1

genDomFrontier :: (Ord a, Show a) => State (DomState a) ()
genDomFrontier = do
    immd <- gets idom
    pre <- gets predecessors
    let initdf = Map.mapWithKey (\_ _ -> Set.empty) immd
    modify' $ \(DomState gr p vi o i n c f1 f2 _ va) -> DomState gr p vi o i n c f1 f2 initdf va
    foldM_
        (\_ u ->
             when (length (pre Map.! u) >= 2) $
             foldM_
                 (\_ v -> do
                      let loop = do
                              val <- gets var
                              df <- gets domfrontier
                              let newdf = Map.insert val (Set.insert u (df Map.! val)) df
                              modify' $ \(DomState gr p vi o i n c f1 f2 _ va) ->
                                  DomState gr p vi o i n c f1 f2 newdf (i Map.! va)
                              nval <- gets var
                              when (nval /= (immd Map.! u)) loop
                      modify' $ \(DomState gr p vi o i n c f1 f2 d _) -> DomState gr p vi o i n c f1 f2 d v
                      when (v /= (immd Map.! u)) loop)
                 ()
                 (filter (`Map.member` immd) (pre Map.! u)))
        ()
        (Map.keys immd)

domFrontiers :: (Ord a, Show a) => DiGraph a -> DiGraph a -> a -> (Map.Map a (Set.Set a), Map.Map a a)
domFrontiers g predecessor start =
    let runDom = do
            dfsPost start
            pord <- gets postorder
            let loop = do
                    genNewIdom pord
                    c <- gets change
                    when c loop
            loop
            genDomFrontier
            i <- gets idom
            df <- gets domfrontier
            return (df, i)
        initialState =
            DomState
                { graph = g
                , predecessors = predecessor
                , visited = Set.empty
                , postorder = []
                , idom = Map.singleton start start
                , newidom = start
                , change = True
                , finger1 = start
                , finger2 = start
                , domfrontier = Map.empty
                , var = start
                }
     in evalState runDom initialState

isTemp :: ALoc -> Bool
isTemp (ATemp _) = True
isTemp _ = False

isTemp' :: AVal -> Bool
isTemp' (ALoc (ATemp _)) = True
isTemp' _ = False

unroll :: AVal -> ALoc
unroll (ALoc (ATemp x)) = ATemp x
unroll (ALoc (AReg x)) = AReg x
unroll _ = error "Error in unroll"

genLocs :: [AVal] -> Set.Set ALoc
genLocs [] = Set.empty
genLocs (x:rest) =
    case x of
        ALoc (AReg _) -> genLocs rest
        ALoc a@(ATemp _) -> Set.insert a (genLocs rest)
        ALoc (APtr p) -> Set.insert p (genLocs rest)
        ALoc (APtrq p) -> Set.insert p (genLocs rest)
        _ -> genLocs rest

blockDefined :: [AAsm] -> ([ALoc], Set.Set ALoc, Set.Set ALoc)
blockDefined =
    foldr
        (\aasm (s, varkill, global) ->
             case aasm of
                 AAsm [assign] _op args
                     | isTemp assign ->
                         let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs args)
                          in (assign : s, Set.insert assign varkill, Set.union glbs global)
                     | otherwise ->
                         let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs (ALoc assign : args))
                          in (s, varkill, Set.union glbs global)
                 ARel [assign] _op args
                     | isTemp assign ->
                         let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs args)
                          in (assign : s, Set.insert assign varkill, Set.union glbs global)
                     | otherwise ->
                         let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs (ALoc assign : args))
                          in (s, varkill, Set.union glbs global)
                 AFun _ args -> (args ++ s, foldr Set.insert varkill args, global)
                 ACall _ args _ ->
                    let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs args)
                    in  (s, varkill, Set.union glbs global)
                 AControl c ->
                    case c of
                        ACJump val _ _ ->
                            let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs [val])
                            in (s, varkill, Set.union glbs global)
                        ACJump' _ v1 v2 _ _ ->
                             let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs [v1, v2])
                             in (s, varkill, Set.union glbs global)
                        _ -> (s, varkill, global)
                 ARet val ->
                    let glbs = Set.filter (\x -> not (Set.member x varkill)) (genLocs [val])
                    in (s, varkill, Set.union glbs global)
                 _ -> (s, varkill, global))
        ([], Set.empty, Set.empty)
        
toBlockM :: [AAsm] -> Ident -> State BlockState ()
toBlockM [] fn = do
    flagGoto <- gets seenGoto
    aasms <- gets currAAsm
    dsite <- gets defsites
    lab <- gets currLabel
    let (defned, _, glbs) = blockDefined aasms
        newdsite = foldr (\d m -> Map.insertWith Set.union d (Set.singleton lab) m) dsite defned
    if flagGoto
        then modify' $ \(BlockState aasm l blk pre blst ori _ glb goto) ->
                 BlockState
                     []
                     l
                     blk
                     pre
                     (reverse ((lab, ([], reverse aasm)) : blst))
                     (Map.insert lab defned ori)
                     newdsite
                     (Set.union glbs glb)
                     goto
        else modify' $ \(BlockState aasm l blk pre blst ori _ glb goto) ->
                 BlockState
                     []
                     l
                     blk
                     pre
                     (reverse ((lab, ([], reverse $ (AControl $ AJump $ fn ++ "_ret") : aasm)) : blst))
                     (Map.insert lab defned ori)
                     newdsite
                     (Set.union glbs glb)
                     goto
toBlockM (x:xs) fn =
    case x of
        AControl (ALab l) -> do
            flagGoto <- gets seenGoto
            aasms <- gets currAAsm
            dsite <- gets defsites
            lab <- gets currLabel
            let (defned, _, glbs) = blockDefined aasms
                newdsite = foldr (\d m -> Map.insertWith Set.union d (Set.singleton lab) m) dsite defned
            if flagGoto
                then modify' $ \(BlockState aasm _ blk pre blst ori _ glb _) ->
                         BlockState
                             [x]
                             l
                             blk
                             pre
                             ((lab, ([], reverse aasm)) : blst)
                             (Map.insert lab defned ori)
                             newdsite
                             (Set.union glbs glb)
                             False
                else modify' $ \(BlockState aasm _ blk pre blst ori _  glb _) ->
                         BlockState
                             [x]
                             l
                             blk
                             pre
                             ((lab, ([], reverse $ (AControl $ AJump $ fn ++ "_ret") : aasm)) : blst)
                             (Map.insert lab defned ori)
                             newdsite
                             (Set.union glbs glb)
                             False
            toBlockM xs fn
        AControl (AJump l)
            | l /= fn ++ "_ret" && l /= "memerror" -> do
                flagGoto <- gets seenGoto
                unless flagGoto $
                    modify' $ \(BlockState aasm lab blk pre blst ori ds glb _) ->
                        BlockState (x : aasm) lab (insertHelper lab l blk) (insertHelper l lab pre) blst ori ds glb True
                toBlockM xs fn
            | otherwise -> do
                modify' $ \(BlockState aasm lab blk pre blst ori ds glb _) ->
                                BlockState (x : aasm) lab blk pre blst ori ds glb True
                toBlockM xs fn
        AControl (ACJump _ l1 l2) -> do
            flagGoto <- gets seenGoto
            unless flagGoto $ do
                modify' $ \(BlockState aasm lab blk pre blst ori ds glb _) ->
                    BlockState (x : aasm) lab blk pre blst ori ds glb True
                when (l1 /= fn ++ "_ret" && l1 /= "memerror") $
                    modify' $ \(BlockState aasm lab blk pre blst ori ds glb goto) ->
                        BlockState aasm lab (insertHelper lab l1 blk) (insertHelper l1 lab pre) blst ori ds glb goto
                when (l2 /= fn ++ "_ret" && l2 /= "memerror") $
                    modify' $ \(BlockState aasm lab blk pre blst ori ds glb goto) ->
                        BlockState aasm lab (insertHelper lab l2 blk) (insertHelper l2 lab pre) blst ori ds glb goto
            toBlockM xs fn
        AControl (ACJump' _ _ _ l1 l2) -> do
            flagGoto <- gets seenGoto
            unless flagGoto $ do
                modify' $ \(BlockState aasm lab blk pre blst ori ds glb _) ->
                    BlockState (x : aasm) lab blk pre blst ori ds glb True
                when (l1 /= fn ++ "_ret" && l1 /= "memerror") $
                    modify' $ \(BlockState aasm lab blk pre blst ori ds glb goto) ->
                        BlockState aasm lab (insertHelper lab l1 blk) (insertHelper l1 lab pre) blst ori ds glb goto
                when (l2 /= fn ++ "_ret" && l2 /= "memerror") $
                    modify' $ \(BlockState aasm lab blk pre blst ori ds glb goto) ->
                        BlockState aasm lab (insertHelper lab l2 blk) (insertHelper l2 lab pre) blst ori ds glb goto
            toBlockM xs fn
        _ -> do
            flagGoto <- gets seenGoto
            unless flagGoto $
                modify' $ \(BlockState aasm lab blk pre blst ori ds glb goto) ->
                    BlockState (x : aasm) lab blk pre blst ori ds glb goto
            toBlockM xs fn

data PhiState =
    PhiState
        { wPhi :: Set.Set Ident
        , aPhi :: Map.Map ALoc (Set.Set Ident)
        , phiBlk :: Map.Map Ident Block
        }

insertPhisM ::
       Set.Set ALoc
    -> Map.Map ALoc (Set.Set Ident)
    -> Map.Map Ident (Set.Set Ident)
    -> Map.Map Ident (Set.Set ALoc)
    -> DiGraph Ident
    -> State PhiState ()
insertPhisM glbs dsite df orig pre =
    foldM_
        (\_ a -> do
             modify' $ \(PhiState _ api pblk) -> PhiState (fromMaybe Set.empty (Map.lookup a dsite)) api pblk
             let loop = do
                     wp <- gets wPhi
                     let n = Set.elemAt 0 wp
                     modify' $ \(PhiState _ api pblk) -> PhiState (Set.deleteAt 0 wp) api pblk
                     foldM_
                         (\_ y -> do
                              aphi <- gets aPhi
                              unless (Set.member y (fromMaybe Set.empty (Map.lookup a aphi))) $ do
                                  pb <- gets phiBlk
                                  let nap = replicate (length (fromMaybe (error "2") (Map.lookup y pre))) (ALoc a)
                                      (aps, aasms) = fromMaybe (error "3") (Map.lookup y pb)
                                  modify' $ \(PhiState w api pblk) ->
                                      PhiState
                                          w
                                          (Map.insertWith Set.union a (Set.singleton y) api)
                                          (Map.insert y ((a, nap) : aps, aasms) pblk)
                                  unless (Set.member a (fromMaybe Set.empty (Map.lookup y orig))) $
                                      modify' $ \(PhiState w api pblk) -> PhiState (Set.insert y w) api pblk)
                         ()
                         (fromMaybe Set.empty (Map.lookup n df))
                     nw <- gets wPhi
                     unless (null nw) loop
             w <- gets wPhi
             unless (null w) loop)
        ()
        glbs

insertPhis ::
       Set.Set ALoc
    -> Map.Map ALoc (Set.Set Ident)
    -> Map.Map Ident (Set.Set Ident)
    -> Map.Map Ident (Set.Set ALoc)
    -> DiGraph Ident
    -> Map.Map Ident Block
    -> Map.Map Ident Block
insertPhis glbs dsite df orig pre blk =
    let runInsertPhis = do
            insertPhisM glbs dsite df orig pre
            gets phiBlk
     in evalState runInsertPhis (PhiState Set.empty Map.empty blk)

testAAsm :: [AAsm]
testAAsm =
    [ AAsm [ATemp 0] ANop [AImm 1]
    , AAsm [ATemp 1] ANop [AImm 1]
    , AAsm [ATemp 2] ANop [AImm 0]
    , AControl $ AJump "L0"
    , AControl $ ALab "L0"
    , AControl $ ACJump' ALt (ALoc $ ATemp 2) (AImm 100) "L1" "L2"
    , AControl $ ALab "L1"
    , AControl $ ACJump' ALt (ALoc $ ATemp 1) (AImm 20) "L3" "L4"
    , AControl $ ALab "L3"
    , AAsm [ATemp 2] AAdd [ALoc $ ATemp 2, AImm 1]
    , AControl $ AJump "L5"
    , AControl $ ALab "L4"
    , AAsm [ATemp 1] ANop [ALoc $ ATemp 2]
    , AAsm [ATemp 1] ANop [AImm 3]
    , AAsm [ATemp 2] AAdd [ALoc $ ATemp 2, AImm 2]
    , AControl $ AJump "L5"
    , AControl $ ALab "L5"
    , AControl $ AJump "L0"
    , AControl $ ALab "L2"
    , AAsm [AReg 0] ANop [ALoc $ ATemp 1]
    ]

insertHelper :: Ord k => k -> v -> Map.Map k [v] -> Map.Map k [v]
insertHelper k v m =
    case Map.lookup k m of
        Just vs -> Map.insert k (v : vs) m
        Nothing -> Map.insert k [v] m

nextVersion :: ALoc -> State RenameState ALoc
nextVersion (ATemp x) = do
    n <- gets nextInt
    modify' $ \(RenameState vm c blk) -> RenameState (insertHelper x n vm) (c + 1) blk
    return $ ATemp n
nextVersion p@(APtr (ATemp _)) = currentVersion p
nextVersion p@(APtrq (ATemp _)) = currentVersion p
nextVersion aloc = return aloc

currentVersion :: ALoc -> State RenameState ALoc
currentVersion (ATemp x) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ ATemp n
        _ -> error $ "SSA version stack is empty: " ++ show x
currentVersion (APtr (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ APtr (ATemp n)
        _ -> error "Undefined Ptr"
currentVersion (APtrq (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ APtrq (ATemp n)
        _ -> error "Undefined Ptrq"
currentVersion aloc = return aloc

currentVersion' :: AVal -> State RenameState AVal
currentVersion' (ALoc (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ ALoc (ATemp n)
        _ -> error $ "SSA version stack is empty: " ++ show x
currentVersion' (ALoc (APtr (ATemp x))) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ ALoc (APtr (ATemp n))
        _ -> error "Undefined Ptr"
currentVersion' (ALoc (APtrq (ATemp x))) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just (n:_) -> return $ ALoc (APtrq (ATemp n))
        _ -> error "Undefined Ptr"
currentVersion' aval = return aval

blockSSA :: [AAsm] -> [AAsm] -> State RenameState [AAsm]
blockSSA [] ssas = return (reverse ssas)
blockSSA (x:xs) ssas =
    case x of
        AFun fn args -> do
            nargs <- mapM currentVersion args
            blockSSA xs (AFun fn nargs : ssas)
        AAsm assigns op args -> do
            nargs <- mapM currentVersion' args
            nassigns <- mapM nextVersion assigns
            blockSSA xs (AAsm nassigns op nargs : ssas)
        ARel assigns op args -> do
            nargs <- mapM currentVersion' args
            nassigns <- mapM nextVersion assigns
            blockSSA xs (ARel nassigns op nargs : ssas)
        ACall fn args num -> do
            nargs <- mapM currentVersion' args
            blockSSA xs (ACall fn nargs num : ssas)
        ARet e -> do
            ne <- currentVersion' e
            blockSSA xs (ARet ne : ssas)
        AControl (ACJump e l1 l2) -> do
            ne <- currentVersion' e
            blockSSA xs (AControl (ACJump ne l1 l2) : ssas)
        AControl (ACJump' op a b l1 l2) -> do
            na <- currentVersion' a
            nb <- currentVersion' b
            blockSSA xs (AControl (ACJump' op na nb l1 l2) : ssas)
        _ -> blockSSA xs (x : ssas)

replaceNth :: Int -> a -> [a] -> [a]
replaceNth _ _ [] = []
replaceNth n newVal (x:xs)
    | n == 0 = newVal : xs
    | otherwise = x : replaceNth (n - 1) newVal xs

renameM ::
       Ident
    -> DiGraph Ident
    -> DiGraph Ident
    -> Map.Map Ident (Map.Map Ident Int)
    -> Map.Map Ident [ALoc]
    -> State RenameState ()
renameM n blkGraph domGraph pre orig = do
    blkMap <- gets renamedBlocks
    let (phis, aasms) = blkMap Map.! n
    (nphin, phiorig) <-
        foldM
            (\(acc1, acc2) (a, p) -> do
                 na <- nextVersion a
                 return ((na, p) : acc1, a : acc2))
            ([], [])
            phis
    renamedaasm <- blockSSA aasms []
    modify' $ \(RenameState vm c blk) -> RenameState vm c (Map.insert n (nphin, renamedaasm) blk)
    foldM_
        (\_ y -> do
             let jth = fromMaybe (error "n not found") (Map.lookup n (pre Map.! y))
             blkMap' <- gets renamedBlocks
             let (phiy, aasmsy) = blkMap' Map.! y
             nphiy <-
                 foldM
                     (\acc (a, p) -> do
                          let oper = p !! jth
                          noper <- currentVersion' oper
                          let nphi = replaceNth jth noper p
                          return ((a, nphi) : acc))
                     []
                     phiy
             modify' $ \(RenameState vm c blk) -> RenameState vm c (Map.insert y (nphiy, aasmsy) blk))
        ()
        (blkGraph Map.! n)
    foldM_ (\_ x -> renameM x blkGraph domGraph pre orig) () (domGraph Map.! n)
    foldM_ (\_ a -> modify' $ \(RenameState vm c blk) -> RenameState (pop a vm) c blk) () phiorig
    foldM_ (\_ a -> modify' $ \(RenameState vm c blk) -> RenameState (pop a vm) c blk) () (orig Map.! n)
  where
    pop a m =
        case a of
            ATemp x ->
                case Map.lookup x m of
                    Just (_:ns) -> Map.insert x ns m
                    _ -> m
            _ -> m

rename ::
       String
    -> Map.Map Ident [Ident]
    -> Map.Map Ident [Ident]
    -> Map.Map Ident (Map.Map Ident Int)
    -> Map.Map Ident [ALoc]
    -> Map.Map Ident Block
    -> Map.Map Int [Int]
    -> Int
    -> Map.Map Ident Block
rename n blkGraph domGraph pre orig blkMap initStack maxTmp =
    let runRename = do
            renameM n blkGraph domGraph pre orig
            gets renamedBlocks
     in evalState runRename (RenameState initStack (maxTmp + 1) blkMap)

insertHelper' :: (Ord k, Ord v) => k -> v -> w -> Map.Map k (Map.Map v w) -> Map.Map k (Map.Map v w)
insertHelper' k v w m =
    case Map.lookup k m of
        Nothing -> Map.insert k (Map.singleton v w) m
        Just m' -> Map.insert k (Map.insert v w m') m

edgeSplit :: DiGraph Ident -> Map.Map Ident (Map.Map Ident Int) -> (DiGraph Ident, Map.Map Ident (Map.Map Ident Int))
edgeSplit g pre =
    let (newg, newpre, _) =
            Map.foldrWithKey'
                (\p cs (ng, npre, i) ->
                     if null cs
                         then (Map.insert p [] ng, npre, i)
                         else if length cs > 1
                                  then foldr
                                           (\c (ng', npre', i') ->
                                                let ps = pre Map.! c
                                                    jth = ps Map.! p
                                                 in if length ps > 1
                                                        then let lab = "E" ++ show i' ++ "_" ++ p
                                                              in ( insertHelper lab c (insertHelper p lab ng')
                                                                 , insertHelper' c lab jth (insertHelper' lab p 0 npre')
                                                                 , i' + 1)
                                                        else (insertHelper p c ng', insertHelper' c p jth npre', i'))
                                           (ng, npre, i)
                                           cs
                                  else foldr
                                           (\c (ng', npre', i') ->
                                                let ps = pre Map.! c
                                                    jth = ps Map.! p
                                                 in (insertHelper p c ng', insertHelper' c p jth npre', i'))
                                           (ng, npre, i)
                                           cs)
                (Map.empty, Map.empty, 0 :: Integer)
                g
     in (newg, newpre)

completeJump :: DiGraph Ident -> Map.Map Ident Block -> Map.Map Ident Block
completeJump g blks =
    Map.foldrWithKey'
        (\p cs blks' ->
             foldr
                 (\c blks'' ->
                      if "E" `List.isPrefixOf` c
                          then let (phi, aasms) = blks'' Map.! p
                                   paasms = reverse aasms
                                   next = head (g Map.! c)
                                   lastInst = head paasms
                                   newLastInst =
                                       case lastInst of
                                           AControl (ACJump e l1 l2) ->
                                               if l1 == next
                                                   then AControl $ ACJump e c l2
                                                   else AControl $ ACJump e l1 c
                                           AControl (ACJump' op a b l1 l2) ->
                                               if l1 == next
                                                   then AControl $ ACJump' op a b c l2
                                                   else AControl $ ACJump' op a b l1 c
                                           _ -> error $ "Cannot have multiple successors: " ++ show p
                                   newaasms = reverse (newLastInst : tail paasms)
                                in Map.insert
                                       c
                                       ([], [AControl $ ALab c, AControl $ AJump next])
                                       (Map.insert p (phi, newaasms) blks'')
                          else blks'')
                 blks'
                 cs)
        blks
        g

bfs :: (Ord a, Show a) => Map.Map a [a] -> [a] -> Set.Set a -> [a] -> [a]
bfs _g seen _ [] = reverse seen
bfs g seen seenm (x:xs)
    | Set.member x seenm = bfs g seen seenm xs
    | otherwise =
        bfs
            g
            (x : seen)
            (Set.insert x seenm)
            (xs ++ reverse (fromMaybe (error $ "Elem not found2: " ++ show x) (Map.lookup x g)))