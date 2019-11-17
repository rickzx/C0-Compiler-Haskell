module Compile.Backend.SSAOptimize where

import Compile.Backend.SSA
import Compile.Types
import Control.Monad.State
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import Data.Int
import qualified Data.Set as Set

import Data.Bits
import Debug.Trace

ssaOptimize :: Map.Map Ident Block -> Map.Map Ident Block
ssaOptimize blks =
    let (eblk, defs, uses, sset, _) = enumBlks blks
        toDelete = deadCodeElim defs uses (Set.fromList (Map.keys defs)) Set.empty
        removeDead = removeStmts eblk (toDelete, Map.empty)
        (toDelete', toModify') = constantProp uses sset (Set.empty, Map.empty)
        propConst = removeStmts removeDead (toDelete', toModify')
        bblk = backToBlk propConst
     in 
--        (trace $ "RemoveDead: \n" ++ show removeDead ++ "\n\nToDelete: \n" ++ show toDelete' ++ "\n\nToModify: \n" ++ show toModify' ++ "\n\nFinal\n" ++ show bblk) 
        bblk

getLineNum :: StmtS -> Int
getLineNum (PhiS lno _) = lno
getLineNum (AAsmS lno _) = lno

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

getDefUse :: StmtS -> (Maybe ALoc, Set.Set ALoc)
getDefUse (PhiS _ (dest, srcs)) = (Just dest, getLocs srcs)
getDefUse (AAsmS _ aasm) =
    case aasm of
        ARet val -> (Nothing, getLocs [val])
        AAsm [assign] _ args ->
            case assign of
                AReg _ -> (Nothing, getLocs args)
                ATemp _ -> (Just assign, getLocs args)
                APtr _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrq _ -> (Nothing, getLocs $ ALoc assign : args)
        ARel [assign] _ args ->
            case assign of
                AReg _ -> (Nothing, getLocs args)
                ATemp _ -> (Just assign, getLocs args)
                APtr _ -> (Nothing, getLocs $ ALoc assign : args)
                APtrq _ -> (Nothing, getLocs $ ALoc assign : args)
        AFun l extraargs -> (Nothing, Set.empty)
        ACall l extraargs number ->
            let extra = getLocs extraargs
             in (Nothing, extra)
        AControl c ->
            case c of
                ACJump val _ _ -> (Nothing, getLocs [val])
                ACJump' _ val1 val2 _ _ -> (Nothing, getLocs [val1, val2])
                _ -> (Nothing, Set.empty)

enumBlks :: Map.Map Ident Block -> (Map.Map Ident [StmtS], Map.Map ALoc StmtS, Map.Map ALoc [StmtS], Set.Set StmtS, Int)
enumBlks =
    Map.foldrWithKey'
        (\lab (phis, aasms) (m, def, use, sset, next) ->
             let (phists, phidef, phiuse, phisset, phinext) =
                     foldr
                         (\(a, a') (sts, def', use', sset', next') ->
                              let st = PhiS next' (a, a')
                                  (dfnst, usest) = getDefUse st
                                  ndef = maybe def' (\x -> Map.insert x st def') dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', next' + 1))
                         ([], def, use, sset, next)
                         phis
                 (aasmsts, aasmdef, aasmuse, aasmsset, aasmnext) =
                     foldr
                         (\aasm (sts, def', use', sset', next') ->
                              let st = AAsmS next' aasm
                                  (dfnst, usest) = getDefUse st
                                  ndef = maybe def' (\x -> Map.insert x st def') dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', next' + 1))
                         ([], phidef, phiuse, phisset, phinext)
                         aasms
              in (Map.insert lab (phists ++ aasmsts) m, aasmdef, aasmuse, aasmsset, aasmnext))
        (Map.empty, Map.empty, Map.empty, Set.empty, 0)

removeStmts :: Map.Map Ident [StmtS] -> (Set.Set Int, Map.Map Int StmtS) -> Map.Map Ident [StmtS]
removeStmts stmtMap (toDelete, toModify) =
    Map.foldrWithKey'
        (\nme stmts nmap ->
             let nstmts =
                     foldr
                         (\stmt acc ->
                              let lno = getLineNum stmt
                               in if Set.member lno toDelete
                                      then acc
                                      else if Map.member lno toModify
                                               then (toModify Map.! lno) : acc
                                               else stmt : acc)
                         []
                         stmts
              in Map.insert nme nstmts nmap)
        Map.empty
        stmtMap

hasSideEffect :: StmtS -> Bool
hasSideEffect (PhiS _ _) = False
hasSideEffect (AAsmS _ aasm) =
    case aasm of
        AAsm _ ADiv _ -> True
        AAsm _ AMod _ -> True
        ACall {} -> True
        _ -> False

deadCodeElim :: Map.Map ALoc StmtS -> Map.Map ALoc [StmtS] -> Set.Set ALoc -> Set.Set Int -> Set.Set Int
deadCodeElim def use work toDelete =
    if null work
        then toDelete
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

constantProp ::
       Map.Map ALoc [StmtS] -> Set.Set StmtS -> (Set.Set Int, Map.Map Int StmtS) -> (Set.Set Int, Map.Map Int StmtS)
constantProp use work (toDelete, toModify) =
    if null work
        then (toDelete, toModify)
        else let st = Set.elemAt 0 work
                 nwork = Set.deleteAt 0 work
                 cstphi =
                     case st of
                         PhiS idx (a, ps) ->
                             case allConst ps of
                                 Just c -> AAsmS idx (AAsm [a] ANopq [AImm c])
                                 Nothing -> st
                         _ -> st
              in case cstphi of
                     AAsmS _ (AAsm [v] ANop [AImm c])
                         | isTemp v ->
                             let ts =
                                     map
                                         (\t ->
                                              if Map.member (getLineNum t) toModify
                                                  then toModify Map.! getLineNum t
                                                  else t)
                                         (fromMaybe [] (Map.lookup v use))
                                 substT = map (substitute c (ALoc v)) ts
                                 nwork' = foldr Set.insert nwork substT
                                 nmodify = foldr (\t m -> Map.insert (getLineNum t) t m) toModify substT
                              in constantProp use nwork' (Set.insert (getLineNum st) toDelete, nmodify)
                     AAsmS _ (AAsm [v] ANopq [AImm c])
                         | isTemp v ->
                             let ts =
                                     map
                                         (\t ->
                                              if Map.member (getLineNum t) toModify
                                                  then toModify Map.! getLineNum t
                                                  else t)
                                         (fromMaybe [] (Map.lookup v use))
                                 substT = map (substitute c (ALoc v)) ts
                                 nwork' = foldr Set.insert nwork substT
                                 nmodify = foldr (\t m -> Map.insert (getLineNum t) t m) toModify substT
                              in constantProp use nwork' (Set.insert (getLineNum st) toDelete, nmodify)
                     AAsmS idx (AControl (ACJump (AImm c) l1 l2)) ->
                         let ninst =
                                 if c /= 0
                                     then AAsmS idx (AControl (AJump l1))
                                     else AAsmS idx (AControl (AJump l2))
                          in constantProp use nwork (toDelete, Map.insert idx ninst toModify)
                     AAsmS idx (AControl (ACJump' op (AImm c1) (AImm c2) l1 l2)) ->
                         let foldcmp =
                                 case op of
                                     AEq -> c1 == c2
                                     AEqq -> c1 == c2
                                     ANe -> c1 /= c2
                                     ANeq -> c1 /= c2
                                     ALt -> c1 < c2
                                     ALe -> c1 <= c2
                                     AGt -> c1 > c2
                                     AGe -> c1 >= c2
                             ninst =
                                 if foldcmp
                                     then AAsmS idx (AControl (AJump l1))
                                     else AAsmS idx (AControl (AJump l2))
                          in constantProp use nwork (toDelete, Map.insert idx ninst toModify)
                     AAsmS idx (AAsm [dest] op [AImm c1, AImm c2])
                         | isTemp dest &&
                               (op == AAdd ||
                                op == AAddq ||
                                op == ASub ||
                                op == ASubq ||
                                op == AMul || op == ABAnd || op == ALAnd || op == ABOr || op == ALOr || op == AXor) ->
                             let 
                                 c1' = fromIntegral c1 :: Int32
                                 c2' = fromIntegral c2 :: Int32
                                 foldop =
                                     case op of
                                         AAdd -> c1' + c2'
                                         AAddq -> c1' + c2'
                                         ASub -> c1' - c2'
                                         ASubq -> c1' - c2'
                                         AMul -> c1' * c2'
                                         ABAnd -> (.&.) c1' c2'
                                         ALAnd ->
                                             if c1' /= 0 && c2' /= 0
                                                 then 1
                                                 else 0
                                         ABOr -> (.|.) c1' c2'
                                         ALOr ->
                                             if c1' /= 0 || c2' /= 0
                                                 then 1
                                                 else 0
                                         AXor -> c1' `xor` c2'
                                 ninst = AAsmS idx (AAsm [dest] ANop [AImm (fromIntegral foldop :: Int)])
                              in constantProp use (Set.insert ninst nwork) (toDelete, Map.insert idx ninst toModify)
                     AAsmS idx (ARel [dest] op [AImm c1, AImm c2]) | isTemp dest ->
                         let foldcmp =
                                 case op of
                                     AEq -> c1 == c2
                                     AEqq -> c1 == c2
                                     ANe -> c1 /= c2
                                     ANeq -> c1 /= c2
                                     ALt -> c1 < c2
                                     ALe -> c1 <= c2
                                     AGt -> c1 > c2
                                     AGe -> c1 >= c2
                             toint =
                                 if foldcmp
                                     then 1
                                     else 0
                             ninst = AAsmS idx (AAsm [dest] ANop [AImm toint])
                          in constantProp use (Set.insert ninst nwork) (toDelete, Map.insert idx ninst toModify)
                     _ -> constantProp use nwork (toDelete, toModify)
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
    substArgs c v [] = []
    substArgs c v (x:xs) =
        if x == v
            then AImm c : substArgs c v xs
            else x : substArgs c v xs
    substitute c v (PhiS idx (a, ps)) = PhiS idx (a, substArgs c v ps)
    substitute c v (AAsmS idx aasm) =
        case aasm of
            ARet val ->
                if val == v
                    then AAsmS idx (ARet (AImm c))
                    else AAsmS idx aasm
            AAsm [dest] op args -> AAsmS idx (AAsm [dest] op (substArgs c v args))
            ARel [dest] op args -> AAsmS idx (ARel [dest] op (substArgs c v args))
            AControl (ACJump val l1 l2) ->
                if val == v
                    then AAsmS idx (AControl (ACJump (AImm c) l1 l2))
                    else AAsmS idx aasm
            AControl (ACJump' op val1 val2 l1 l2) ->
                let val1' =
                        if val1 == v
                            then AImm c
                            else val1
                    val2' =
                        if val2 == v
                            then AImm c
                            else val2
                 in AAsmS idx (AControl (ACJump' op val1' val2' l1 l2))
            ACall fn args narg -> AAsmS idx (ACall fn (substArgs c v args) narg)
            _ -> AAsmS idx aasm

backToBlk :: Map.Map Ident [StmtS] -> Map.Map Ident Block
backToBlk =
    Map.foldrWithKey'
        (\nme stmts m ->
             let (phis, aasms) =
                     foldr
                         (\stmt (p, a) ->
                              case stmt of
                                  PhiS _ phi -> (phi : p, a)
                                  AAsmS _ aasm -> (p, aasm : a))
                         ([], [])
                         stmts
              in Map.insert nme (phis, aasms) m)
        Map.empty