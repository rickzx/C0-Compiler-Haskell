module Compile.Backend.SSARegAlloc where

import Compile.Backend.SSA
import Compile.Types
import Control.Monad.State
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

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

livenessAnalysis :: Map.Map Ident [StmtS] -> Map.Map Ident (Map.Map Ident Int) -> Map.Map ALoc StmtS -> Map.Map ALoc [StmtS] -> State LivenessState ()
livenessAnalysis blk pre defs uses =
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
                                          Just pblk' -> liveOutAtBlock blk pblk' v
                                          Nothing -> error "SSA Liveness Error 2"
                                  Nothing -> error "SSA Liveness Error 1"
                          _ -> liveInAtStatement blk pre s v)
                 ()
                 vuse)
        ()
        (Map.keys defs)

liveOutAtBlock :: Map.Map Ident [StmtS] -> Ident -> ALoc -> State LivenessState ()
liveOutAtBlock blk n v = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf (insertLive n v ob) ib os is
    bigm <- gets blkM
    unless (Set.member n bigm) $ do
        modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState (Set.insert n bm) intf ob ib os is
        case Map.lookup n blk of
            Just stmts -> liveOutAtStatement (last stmts) v
            Nothing -> return ()

liveInAtStatement blk pre s v = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob ib os (insertLive s v is)
    

liveOutAtStatement s v = undefined