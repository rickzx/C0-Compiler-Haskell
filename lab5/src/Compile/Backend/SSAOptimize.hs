{-# LANGUAGE BangPatterns, Strict #-}

module Compile.Backend.SSAOptimize where

import Compile.Backend.SSA
import Compile.Types
import Control.Monad.State
import Data.Int
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

import Data.Bits
import Debug.Trace

ssaOptimize ::
       Map.Map Ident Block
    -> DiGraph Ident
    -> Map.Map Ident (Map.Map Ident Int)
    -> Ident
    -> (Map.Map Ident Block, Set.Set Int, DiGraph Ident, Map.Map Ident (Map.Map Ident Int))
ssaOptimize blks g pre fn =
    let (eblk, defs, uses, sset, _, _) = enumBlks blks
        (nuses, toDelete) = deadCodeElim defs uses (Set.fromList (Map.keys defs)) Set.empty
        (removeDead, _) = removeStmts eblk (toDelete, Map.empty, Map.empty)
        (toDelete', toModify', edgeToRemove) = copyProp nuses sset (Set.empty, Map.empty, Map.empty)
        (propConst, edgeToRemove') = removeStmts removeDead (toDelete', toModify', edgeToRemove)
        (edgeRemovedBlk, newg, newpre) = elimUnreachable propConst edgeToRemove' g pre fn
        (bblk, allVars) = backToBlk edgeRemovedBlk
     in
--        (trace $
--         "RemoveDead: \n" ++ show eblk ++
--         "\n\nToDelete: \n" ++ show toDelete' ++
--         "\n\nToModify: \n" ++ show toModify' ++
--         "\n\nedgeToRemove: \n" ++ show edgeToRemove' ++
--         "\n\nFinalRemoved: \n" ++ show bblk ++
--         "\n\nNewGraph: \n" ++ show newg ++
--         "\n\nNewPre: \n" ++ show newpre)
            (bblk, allVars, newg, newpre)

--        (trace $ "RemoveDead: \n" ++ show removeDead ++ "\n\nToDelete: \n" ++ show toDelete' ++ "\n\nToModify: \n" ++ show toModify' ++ "\n\nFinal\n" ++ show bblk)
getLineNum :: StmtS -> Int
getLineNum (PhiS lno _ _) = lno
getLineNum (AAsmS lno _ _) = lno

getLocs :: [AVal] -> Set.Set ALoc
getLocs [] = Set.empty
getLocs (x:rest) =
    case x of
        ALoc (AReg _) -> getLocs rest
        ALoc a@(ATemp _) -> Set.insert a (getLocs rest)
        ALoc (APtr p) -> Set.insert p (getLocs rest)
        ALoc (APtrq p) -> Set.insert p (getLocs rest)
        _ -> getLocs rest

getLocs' :: [ALoc] -> Set.Set ALoc
getLocs' [] = Set.empty
getLocs' (x:rest) =
    case x of
        AReg _ -> getLocs' rest
        a@(ATemp _) -> Set.insert a (getLocs' rest)
        APtr p -> Set.insert p (getLocs' rest)
        APtrq p -> Set.insert p (getLocs' rest)

--gets the temps defined and used at each line
getDefUse :: StmtS -> (Maybe ALoc, Set.Set ALoc)
getDefUse (PhiS _ _ (dest, srcs)) = (Just dest, getLocs srcs)
getDefUse (AAsmS _ _ aasm) =
    case aasm of
        ARet val -> (Nothing, getLocs [val])
        AAsm [assign] _ args ->
            case assign of
                AReg _ -> (Nothing, getLocs args)
                ATemp _ -> (Just assign, getLocs args)
                APtr _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrq _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrNull -> (Nothing, getLocs $ ALoc assign : args)
        ARel [assign] _ args ->
            case assign of
                AReg _ -> (Nothing, getLocs args)
                ATemp _ -> (Just assign, getLocs args)
                APtr _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrq _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrNull -> (Nothing, getLocs $ ALoc assign : args)
        AFun l extraargs -> (Nothing, Set.empty)
        ACall l extraargs number ->
            let extra = getLocs extraargs
             in (Nothing, extra)
        AControl c ->
            case c of
                ACJump val _ _ -> (Nothing, getLocs [val])
                ACJump' _ val1 val2 _ _ -> (Nothing, getLocs [val1, val2])
                _ -> (Nothing, Set.empty)

--enumerate the statemrnts within each block and get the def/use locations for each line
enumBlks :: Map.Map Ident Block -> (Map.Map Ident [StmtS], Map.Map ALoc StmtS, Map.Map ALoc [StmtS], Set.Set StmtS, Map.Map Int StmtS, Int)
enumBlks =
    Map.foldrWithKey'
        (\lab (phis, aasms) (m, def, use, sset, smap, next) ->
             --(stmts after enum, Map variable to line defined, Map variable to lines used, Set of statements, linenum cnt)
             let (phists, phidef, phiuse, phisset, phismap, phinext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') (a, a') ->
                              let st = PhiS next' lab (a, a')
                                  (dfnst, usest) = getDefUse st
                                  ndef = maybe def' (\x -> Map.insert x st def') dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], def, use, sset, smap, next)
                         phis
                 (aasmsts, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') aasm ->
                              let st = AAsmS next' lab aasm
                                  (dfnst, usest) = getDefUse st
                                  ndef = maybe def' (\x -> Map.insert x st def') dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], phidef, phiuse, phisset, phismap, phinext)
                         aasms
              in (Map.insert lab (reverse phists ++ reverse aasmsts) m, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext))
        (Map.empty, Map.empty, Map.empty, Set.empty, Map.empty, 0)

--remove and modify statements as needed
removeStmts ::
       Map.Map Ident [StmtS]
    -> (Set.Set Int, Map.Map Int StmtS, Map.Map Int Ident)
    -> (Map.Map Ident [StmtS], Map.Map Ident Ident)
removeStmts stmtMap (toDelete, toModify, edgeToRemove) =
    Map.foldrWithKey'
        (\nme stmts (nmap, nlabs) ->
             let (nstmts, nedge) =
                     foldr
                         (\stmt (acc, acc') ->
                              let lno = getLineNum stmt
                                  r =
                                      case Map.lookup lno edgeToRemove of
                                          Just l -> Map.insert nme l acc'
                                          Nothing -> acc'
                               in if Set.member lno toDelete
                                      then (acc, r)
                                      else if Map.member lno toModify
                                               then ((toModify Map.! lno) : acc, r)
                                               else (stmt : acc, r))
                         ([], nlabs)
                         stmts
              in (Map.insert nme nstmts nmap, nedge))
        (Map.empty, Map.empty)
        stmtMap

hasSideEffect :: StmtS -> Bool
hasSideEffect (PhiS _ _ _) = False
hasSideEffect (AAsmS _ _ aasm) =
    case aasm of
        AAsm _ ADiv _ -> True
        AAsm _ AMod _ -> True
        AAsm _ ASal _ -> True
        AAsm _ ASar _ -> True
        ACall {} -> True
        _ -> False

deadCodeElim ::
       Map.Map ALoc StmtS -> Map.Map ALoc [StmtS] -> Set.Set ALoc -> Set.Set Int -> (Map.Map ALoc [StmtS], Set.Set Int)
deadCodeElim def use work toDelete =
    if null work
        then (use, toDelete)
        else let v = Set.elemAt 0 work
                 nwork = Set.deleteAt 0 work
              in if not (Map.member v def)
                     then deadCodeElim def use nwork toDelete
                     else let st = def Map.! v
                           in if (not (Map.member v use) || null (use Map.! v)) && not (hasSideEffect st)
                                  then let (_, suse) = getDefUse st
                                           (nuse, nwork') =
                                               foldr
                                                   (\xi (m, nw) ->
                                                        let xiuse = m Map.! xi
                                                         in (Map.insert xi (List.delete st xiuse) m, Set.insert xi nw))
                                                   (use, nwork)
                                                   suse
                                        in deadCodeElim def nuse nwork' (Set.insert (getLineNum st) toDelete)
                                  else deadCodeElim def use nwork toDelete

isTmpOrConst :: AVal -> Bool
isTmpOrConst (AImm _) = True
isTmpOrConst (ALoc (ATemp _)) = True
isTmpOrConst _ = False

copyProp ::
       Map.Map ALoc [StmtS]
    -> Set.Set StmtS
    -> (Set.Set Int, Map.Map Int StmtS, Map.Map Int Ident)
    -> (Set.Set Int, Map.Map Int StmtS, Map.Map Int Ident)
copyProp use work (toDelete, toModify, edgeToRemove) =
    if null work
        then (toDelete, toModify, edgeToRemove)
        else let st = Set.elemAt 0 work
                 nwork = Set.deleteAt 0 work
                 cstphi =
                     case st of
                         PhiS idx pb (a, ps) ->
                             case allConst ps of
                                 Just c -> AAsmS idx pb (AAsm [a] ANopq [AImm c])
                                 Nothing -> st
                         _ -> st
              in case cstphi of
                     PhiS _ _ (x, [y])
                         | isTemp' y ->
                             let (cansub, ts) =
                                     foldr
                                         (\t (canSubst, acc) ->
                                              case t of
                                                  PhiS _ _ _ -> (False, [])--can't copy progagate in Phi functions
                                                  _
                                                      | not canSubst -> (False, [])-- the use line can not substitute
                                                      | Set.member (getLineNum t) toDelete -> (True, acc)
                                                      | Map.member (getLineNum t) toModify ->
                                                          (True, toModify Map.! getLineNum t : acc) --add in the modified version of the line instead
                                                      | otherwise -> (True, t : acc))
                                         (True, [])
                                         (fromMaybe [] (Map.lookup x use))
                              in if cansub 
                                     then let substT = map (substitute y (ALoc x)) ts --substitute y with x for all the statements used 
                                              nwork' = foldr Set.insert nwork substT
                                              nuse =
                                                  foldr
                                                      (\t m ->
                                                           case y of
                                                               AImm _ -> m
                                                               ALoc p@(ATemp _) -> insertHelper p t m
                                                               ALoc (AReg _) -> m
                                                               ALoc (APtr p) -> insertHelper p t m
                                                               ALoc (APtrq p) -> insertHelper p t m)
                                                      use
                                                      substT --update y to the used lists
                                                      --update all the needed to modified lines after substitution
                                              nmodify = foldr (\t m -> Map.insert (getLineNum t) t m) toModify substT
                                           in copyProp
                                                  nuse
                                                  nwork'
                                                  (Set.insert (getLineNum st) toDelete, nmodify, edgeToRemove)
                                     else copyProp use nwork (toDelete, toModify, edgeToRemove)
                     --same idea for phi function w/ copy propagation applies to ANop and ANopq
                     AAsmS _ _ (AAsm [v] ANop [c])
                         | isTemp v && isTemp' c ->
                             let (cansub, ts) =
                                     foldr
                                         (\t (canSubst, acc) ->
                                              case t of
                                                  PhiS _ _ _ -> (False, [])
                                                  _
                                                      | not canSubst -> (False, [])
                                                      | Set.member (getLineNum t) toDelete -> (True, acc)
                                                      | Map.member (getLineNum t) toModify ->
                                                          (True, toModify Map.! getLineNum t : acc)
                                                      | otherwise -> (True, t : acc))
                                         (True, [])
                                         (fromMaybe [] (Map.lookup v use))
                              in if cansub
                                     then let substT = map (substitute c (ALoc v)) ts
                                              nwork' = foldr Set.insert nwork substT
                                              nuse =
                                                  foldr
                                                      (\t m ->
                                                           case c of
                                                               AImm _ -> m
                                                               ALoc p@(ATemp _) -> insertHelper p t m
                                                               ALoc (AReg _) -> m
                                                               ALoc (APtr p) -> insertHelper p t m
                                                               ALoc (APtrq p) -> insertHelper p t m)
                                                      use
                                                      substT
                                              nmodify = foldr (\t m -> Map.insert (getLineNum t) t m) toModify substT
                                           in copyProp
                                                  nuse
                                                  nwork'
                                                  (Set.insert (getLineNum st) toDelete, nmodify, edgeToRemove)
                                     else copyProp use nwork (toDelete, toModify, edgeToRemove)
                     AAsmS _ _ (AAsm [v] ANopq [c])
                         | isTemp v && isTemp' c ->
                             let (cansub, ts) =
                                     foldr
                                         (\t (canSubst, acc) ->
                                              case t of
                                                  PhiS _ _ _ -> (False, [])
                                                  _
                                                      | not canSubst -> (False, [])
                                                      | Set.member (getLineNum t) toDelete -> (True, acc)
                                                      | Map.member (getLineNum t) toModify ->
                                                          (True, toModify Map.! getLineNum t : acc)
                                                      | otherwise -> (True, t : acc))
                                         (True, [])
                                         (fromMaybe [] (Map.lookup v use))
                              in if cansub
                                     then let substT = map (substitute c (ALoc v)) ts
                                              nwork' = foldr Set.insert nwork substT
                                              nuse =
                                                  foldr
                                                      (\t m ->
                                                           case c of
                                                               AImm _ -> m
                                                               ALoc p@(ATemp _) -> insertHelper p t m
                                                               ALoc (AReg _) -> m
                                                               ALoc (APtr p) -> insertHelper p t m
                                                               ALoc (APtrq p) -> insertHelper p t m)
                                                      use
                                                      substT
                                              nmodify = foldr (\t m -> Map.insert (getLineNum t) t m) toModify substT
                                           in copyProp
                                                  nuse
                                                  nwork'
                                                  (Set.insert (getLineNum st) toDelete, nmodify, edgeToRemove)
                                     else copyProp use nwork (toDelete, toModify, edgeToRemove)
                     _ -> copyProp use nwork (toDelete, toModify, edgeToRemove)
  where
    allConst ps =
        if null ps
            then Nothing
            else case head ps of
                     AImm n ->
                         foldr
                             (\x c ->
                                  case c of
                                      Nothing -> Nothing
                                      Just con ->
                                          case x of
                                              AImm con' ->
                                                  if con == con'
                                                      then Just con
                                                      else Nothing
                                              _ -> Nothing)
                             (Just n)
                             ps
                     _ -> Nothing
    pointerize (ALoc ptr) True = APtrq ptr
    pointerize (ALoc ptr) False = APtr ptr
    pointerize (AImm _) _ = APtrNull
    substArgs c v [] = []
    substArgs c v (x:xs) =
        case x of
            ALoc (APtr ptr) ->
                if ALoc ptr == v
                    then ALoc (pointerize c False) : substArgs c v xs
                    else x : substArgs c v xs
            ALoc (APtrq ptr) ->
                if ALoc ptr == v
                    then ALoc (pointerize c True) : substArgs c v xs
                    else x : substArgs c v xs
            _ ->
                if x == v
                    then c : substArgs c v xs
                    else x : substArgs c v xs
    substitute c v (PhiS idx pb (a, ps)) = PhiS idx pb (a, substArgs c v ps)
    substitute c v (AAsmS idx pb aasm) =
        case aasm of
            ARet val ->
                if val == v
                    then AAsmS idx pb (ARet c)
                    else AAsmS idx pb aasm
            AAsm [dest] op args ->
                case dest of
                    APtr ptr ->
                        if ALoc ptr == v
                            then AAsmS idx pb (AAsm [pointerize c False] op (substArgs c v args))
                            else AAsmS idx pb (AAsm [dest] op (substArgs c v args))
                    APtrq ptr ->
                        if ALoc ptr == v
                            then AAsmS idx pb (AAsm [pointerize c True] op (substArgs c v args))
                            else AAsmS idx pb (AAsm [dest] op (substArgs c v args))
                    _ -> AAsmS idx pb (AAsm [dest] op (substArgs c v args))
            ARel [dest] op args ->
                case dest of
                    APtr ptr ->
                        if ALoc ptr == v
                            then AAsmS idx pb (ARel [pointerize c False] op (substArgs c v args))
                            else AAsmS idx pb (ARel [dest] op (substArgs c v args))
                    APtrq ptr ->
                        if ALoc ptr == v
                            then AAsmS idx pb (ARel [pointerize c True] op (substArgs c v args))
                            else AAsmS idx pb (ARel [dest] op (substArgs c v args))
                    _ -> AAsmS idx pb (ARel [dest] op (substArgs c v args))
            AControl (ACJump val l1 l2) ->
                if val == v
                    then AAsmS idx pb (AControl (ACJump c l1 l2))
                    else AAsmS idx pb aasm
            AControl (ACJump' op val1 val2 l1 l2) ->
                let val1' =
                        if val1 == v
                            then c
                            else val1
                    val2' =
                        if val2 == v
                            then c
                            else val2
                 in AAsmS idx pb (AControl (ACJump' op val1' val2' l1 l2))
            ACall fn args narg -> AAsmS idx pb (ACall fn (substArgs c v args) narg)
            _ -> AAsmS idx pb aasm

data ElimState =
    ElimState
        { elimTodo :: [Ident]
        , elimBlk :: Map.Map Ident [StmtS]
        , elimG :: DiGraph Ident
        , elimPre :: Map.Map Ident (Map.Map Ident Int)
        }

removeEdge :: Ident -> Ident -> DiGraph Ident -> DiGraph Ident
removeEdge u v g =
    case Map.lookup u g of
        Just vs -> Map.insert u (List.delete v vs) g
        Nothing -> g

removeEdgeP :: Ident -> Ident -> Map.Map Ident (Map.Map Ident Int) -> Map.Map Ident (Map.Map Ident Int)
removeEdgeP u v g =
    case Map.lookup u g of
        Just vs -> case Map.lookup v vs of
            Just i -> Map.insert u (Map.map (\vi -> if vi > i then vi - 1 else vi) (Map.delete v vs)) g
            Nothing -> g
        Nothing -> g

elimUnreachable ::
       Map.Map Ident [StmtS]
    -> Map.Map Ident Ident
    -> DiGraph Ident
    -> Map.Map Ident (Map.Map Ident Int)
    -> Ident
    -> (Map.Map Ident [StmtS], DiGraph Ident, Map.Map Ident (Map.Map Ident Int))
elimUnreachable blks edgeToRemove g pre fn =
    let runElimUnreach = do
            elimUnreachableM edgeToRemove fn
            elimblk <- gets elimBlk
            elimg <- gets elimG
            elimpre <- gets elimPre
            return (elimblk, elimg, elimpre)
        initState = ElimState {elimTodo = Map.keys blks, elimBlk = blks, elimG = g, elimPre = pre}
     in evalState runElimUnreach initState

deleteN :: Int -> [a] -> [a]
deleteN _ []     = []
deleteN i (a:as)
   | i == 0    = as
   | otherwise = a : deleteN (i-1) as
   
deletePhiBlk :: Ord k => Map.Map k [StmtS] -> k -> Int -> Map.Map k [StmtS]
deletePhiBlk blk n jth =
    case Map.lookup n blk of
        Just stmts -> Map.insert n (map (\st -> case st of
            PhiS idx pb (a, ps) -> PhiS idx pb (a, deleteN jth ps)
            _ -> st) stmts) blk
        _ -> blk

elimUnreachableM :: Map.Map Ident Ident -> Ident -> State ElimState ()
elimUnreachableM edgeToRemove fn = do
    let loop = do
            todos <- gets elimTodo
            let nme = head todos
            modify' $ \(ElimState t b g p) -> ElimState (tail t) b g p
            unless (nme == fn) $ do
                gra <- gets elimG
                pre <- gets elimPre
                blk <- gets elimBlk
                let prenme = fromMaybe Map.empty (Map.lookup nme pre)
                    succnme = fromMaybe [] (Map.lookup nme gra)
                    (npre', ng', allrem, newblk) =
                        Map.foldrWithKey'
                            (\p jth (np, ng, flag, blk') ->
                                 if Map.member p edgeToRemove && edgeToRemove Map.! p == nme
                                     then (removeEdgeP nme p np, removeEdge p nme ng, flag, deletePhiBlk blk' nme jth)
                                     else (np, ng, False, blk))
                            (pre, gra, True, blk)
                            prenme
                if allrem
                    then let
                             remblk = foldr (\s blk' ->
                                let
                                    jth = (pre Map.! s) Map.! nme
                                in
                                    deletePhiBlk blk' s jth) newblk succnme
                             rempre = foldr (\s p -> removeEdgeP s nme p) npre' succnme
                             remg = Map.delete nme ng'
                          in modify' $ \(ElimState t b g p) -> ElimState (t ++ succnme) (Map.delete nme remblk) remg rempre
                    else modify' $ \(ElimState t b g p) -> ElimState t newblk ng' npre'
            todos' <- gets elimTodo
            unless (null todos') loop
    todos <- gets elimTodo
    unless (null todos) loop

--convert our IR back to our regular blocks, remove the line number, 
 --also we insert all the temps used in allVars so we can know when to spill
backToBlk :: Map.Map Ident [StmtS] -> (Map.Map Ident Block, Set.Set Int)
backToBlk =
    Map.foldrWithKey'
        (\nme stmts (m, allVars) ->
             let (phis, aasms, allv) =
                     foldr
                         (\stmt (p, a, allVars') ->
                              case stmt of
                                  PhiS _ _ phi@(ATemp x, pi) ->
                                      ( phi : p
                                      , a
                                      , foldr
                                            (\v s ->
                                                 case v of
                                                     ALoc (ATemp n) -> Set.insert n s
                                                     _ -> s)
                                            (Set.insert x allVars')
                                            pi)
                                  AAsmS _ _ aasm ->
                                      let (def, use) = getDefUse stmt
                                          uses =
                                              foldr
                                                  (\v s ->
                                                       case v of
                                                           ATemp n -> Set.insert n s
                                                           _ -> s)
                                                  allVars'
                                                  use
                                       in case def of
                                              Just (ATemp n) -> (p, aasm : a, Set.insert n uses)
                                              _ -> (p, aasm : a, uses))
                         ([], [], allVars)
                         stmts
              in (Map.insert nme (phis, aasms) m, allv))
        (Map.empty, Set.empty)