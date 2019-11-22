module Compile.Backend.SSARegAlloc where

import Compile.Backend.SSA
import Compile.Types
import Control.Monad.State
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

import Debug.Trace

type Graph = Map.Map ALoc (Set.Set ALoc)

data LivenessState =
    LivenessState
        { blkM :: Set.Set Ident
        , interference :: Graph
        , liveoutblk :: Map.Map Ident (Set.Set ALoc)
        , liveinblk :: Map.Map Ident (Set.Set ALoc)
        , liveoutstmt :: Map.Map StmtS (Set.Set ALoc)
        , liveinstmt :: Map.Map StmtS (Set.Set ALoc)
        }
        
insertLive :: (Ord a, Ord b) => a -> b -> Map.Map a (Set.Set b) -> Map.Map a (Set.Set b)
insertLive x y m = case Map.lookup x m of
    Just s -> Map.insert x (Set.insert y s) m
    Nothing -> Map.insert x (Set.singleton y) m
    
getBlkName :: StmtS -> Ident
getBlkName s = case s of
    PhiS _ nme _ -> nme
    AAsmS _ nme _ -> nme
    
getLineNum :: StmtS -> Int
getLineNum (PhiS lno _ _) = lno
getLineNum (AAsmS lno _ _) = lno
    
addEdge :: (ALoc, ALoc) -> Graph -> Graph
addEdge (u, v) g =
    case Map.lookup u g of
        Just _sset -> Map.adjust (Set.insert v) u g
        Nothing -> Map.insert u (Set.singleton v) g

locsSet :: [AVal] -> Set.Set ALoc
locsSet [] = Set.empty
locsSet (x:rest) =
    case x of
        ALoc a@(AReg _) -> Set.insert a (locsSet rest)
        ALoc a@(ATemp _) -> Set.insert a (locsSet rest)
        ALoc (APtr p) -> Set.insert p (locsSet rest)
        ALoc (APtrq p) -> Set.insert p (locsSet rest)
        _ -> locsSet rest

defUse :: StmtS -> (Set.Set ALoc, Set.Set ALoc)
defUse (PhiS _ _ (dest, srcs)) = (Set.singleton dest, locsSet srcs)
defUse (AAsmS _ _ aasm) =
    case aasm of
        ARet val -> (Set.empty, locsSet [val])
        AAsm [assign] _ args ->
            case assign of
                AReg _ -> (Set.empty, locsSet args)
                ATemp _ -> (Set.singleton assign, locsSet args)
                APtr p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrq p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrNull -> (Set.empty, locsSet $ ALoc assign : args)
        ARel [assign] _ args ->
            case assign of
                AReg _ -> (Set.empty, locsSet args)
                ATemp _ -> (Set.singleton assign, locsSet args)
                APtr p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrq p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrNull -> (Set.empty, locsSet $ ALoc assign : args)
        AFun l extraargs -> (Set.fromList extraargs, Set.empty)
        ACall l extraargs number ->
            let definedregs = [AReg 3, AReg 4, AReg 1, AReg 2, AReg 5, AReg 6, AReg 0, AReg 7, AReg 8]
                usedregs = take number definedregs
                extra = locsSet extraargs
             in (Set.fromList definedregs, Set.union extra (Set.fromList usedregs))
        AControl c ->
            case c of
                AJump l
                    | "_ret" `List.isSuffixOf` l -> (Set.empty, Set.singleton (AReg 0))
                    | otherwise -> (Set.empty, Set.empty)
                ACJump val _ _ -> (Set.empty, locsSet [val])
                ACJump' _ val1 val2 _ _ -> (Set.empty, locsSet [val1, val2])
                _ -> (Set.empty, Set.empty)
                
enumBlks :: Map.Map Ident Block -> (Map.Map Ident [StmtS], Map.Map ALoc StmtS, Map.Map ALoc [StmtS], Set.Set StmtS, Map.Map Int StmtS, Int)
enumBlks =
    Map.foldrWithKey'
        (\lab (phis, aasms) (m, def, use, sset, smap, next) ->
             let (phists, phidef, phiuse, phisset, phismap, phinext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') (a, a') ->
                              let st = PhiS next' lab (a, a')
                                  (dfnst, usest) = defUse st
                                  ndef = foldr (\x dm -> Map.insert x st dm) def' dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], def, use, sset, smap, next)
                         phis
                 (aasmsts, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') aasm ->
                              let st = AAsmS next' lab aasm
                                  (dfnst, usest) = defUse st
                                  ndef = foldr (\x dm -> Map.insert x st dm) def' dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], phidef, phiuse, phisset, phismap, phinext)
                         aasms
              in (Map.insert lab (reverse phists ++ reverse aasmsts) m, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext))
        (Map.empty, Map.empty, Map.empty, Set.empty, Map.empty, 0)
        
livenessAnalysis :: Map.Map Ident Block -> Map.Map Ident (Map.Map Ident Int) -> Graph
livenessAnalysis blk pre =
    let (blks, defs, uses, _, smap, _) = enumBlks blk
        runLiveness = do
            livenessAnalysisM blks smap pre defs uses
            gets interference
        initState = LivenessState {blkM = Set.empty, interference = Map.empty, liveoutblk = Map.empty, liveinblk = Map.empty, liveoutstmt = Map.empty, liveinstmt = Map.empty}
    in
        (trace $ "Blks\n" ++ show blks ++ 
        "\n\nDefs\n" ++ show defs ++ 
        "\n\nUses\n" ++ show uses)
        evalState runLiveness initState

livenessAnalysisM :: Map.Map Ident [StmtS] -> Map.Map Int StmtS -> Map.Map Ident (Map.Map Ident Int) -> Map.Map ALoc StmtS -> Map.Map ALoc [StmtS] -> State LivenessState ()
livenessAnalysisM blk smap pre defs uses =
    foldM_
        (\_ v -> do
             modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState Set.empty intf ob ib os is
             let vuse = fromMaybe [] (Map.lookup v uses)
             foldM_
                 (\_ s ->
                      case s of
                          PhiS idx pb (a, ps) ->
                              case List.findIndex (\p -> p == ALoc v) ps of
                                  Just ith -> do
                                      let pblk =
                                              Map.foldrWithKey'
                                                  (\p jth acc ->
                                                       if isJust acc
                                                           then acc
                                                           else if ith == jth
                                                                    then Just p
                                                                    else Nothing)
                                                  Nothing
                                                  (pre Map.! pb)
                                      case pblk of
                                          Just pblk' -> liveOutAtBlock blk smap pre pblk' v
                                          Nothing -> error "SSA Liveness Error 2"
                                  Nothing -> error "SSA Liveness Error 1"
                          _ -> liveInAtStatement blk smap pre s v)
                 ()
                 vuse)
        ()
        (Map.keys defs)

liveOutAtBlock :: Map.Map Ident [StmtS] -> Map.Map Int StmtS -> Map.Map Ident (Map.Map Ident Int) -> Ident -> ALoc -> State LivenessState ()
liveOutAtBlock blk smap pre n v = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf (insertLive n v ob) ib os is
    bigm <- gets blkM
    unless (Set.member n bigm) $ do
        modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState (Set.insert n bm) intf ob ib os is
        case Map.lookup n blk of
            Just stmts -> liveOutAtStatement blk smap pre (last stmts) v
            Nothing -> return ()

liveInAtStatement :: Map.Map Ident [StmtS] -> Map.Map Int StmtS -> Map.Map Ident (Map.Map Ident Int) -> StmtS -> ALoc -> State LivenessState ()
liveInAtStatement blk smap pre s v = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob ib os (insertLive s v is)
    let n = getBlkName s
        stmt = fromMaybe (error "SSA Liveness Error 3") (Map.lookup n blk)
    if s == head stmt then do
        modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob (insertLive n v ib) os is
        let preds = fromMaybe Map.empty (Map.lookup n pre)
        foldM_ (\_ p -> liveOutAtBlock blk smap pre p v) () (Map.keys preds)
    else
        let lno = getLineNum s
            prevStmt = fromMaybe (error "SSA Liveness Error 4") (Map.lookup (lno - 1) smap)
        in
            liveOutAtStatement blk smap pre prevStmt v
    
liveOutAtStatement :: Map.Map Ident [StmtS] -> Map.Map Int StmtS -> Map.Map Ident (Map.Map Ident Int) -> StmtS -> ALoc -> State LivenessState ()
liveOutAtStatement blk smap pre s v = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob ib (insertLive s v os) is
    let (w, _) = defUse s
        nw = case s of
            AAsmS _ _ (AAsm _ asnop _)
                | asnop == ADiv || asnop == ADivq || asnop == AMod || asnop == AModq ->
                    Set.insert (AReg 0) (Set.insert (AReg 1) w)
                | asnop == ASal || asnop == ASar ->
                    Set.insert (AReg 2) w
                | otherwise -> w
            _ -> w
            
    foldM_
        (\() w' ->
             modify' $ \(LivenessState bm intf ob ib os is) ->
              LivenessState bm (addEdge (w', v) (addEdge (v, w') intf)) ob ib os is)
        ()
        (Set.delete v nw)
    unless (Set.member v nw) $ liveInAtStatement blk smap pre s v