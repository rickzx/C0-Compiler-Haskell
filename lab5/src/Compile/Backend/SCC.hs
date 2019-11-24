module Compile.Backend.SCC where

import Compile.Backend.SSA
import Compile.Backend.SSAOptimize
import Compile.Types
import Control.Monad.State
import Data.Int
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set
    
import Data.Bits
import Debug.Trace

--never executed, is a constant, or can have multiple value/side effects
data Value = N | Const Int | P deriving Eq
{- 
    conduct sparse conditinoal constant propagation to SSA
-}

runSCC :: 
    Map.Map Ident Block
    -> DiGraph Ident
    -> Map.Map Ident (Map.Map Ident Int)
    -> Ident
    -> (Map.Map Ident Block, Set.Set Int, DiGraph Ident, Map.Map Ident (Map.Map Ident Int))
runSCC blks g pre fn =
    let
        (eblk, _, blockmap) = enumBlock blks
        --we need to reach our entry block for functions to start 
        blockmap' = Map.insert fn True blockmap 
        (nvarmap, nblkmap, defmap, usemap) = 
            scc eblk (Set.empty) (Set.singleton fn) (Map.empty) (Map.empty) (Map.empty, blockmap')
        (toDelete, toModify) = modifyStmts (nvarmap, defmap, usemap) (Set.empty, Map.empty)
        toRemove = modifyBlocks nblkmap pre 
        (propConst, _) = removeStmts eblk (toDelete, toModify, Map.empty)
        (edgeRemovedBlk, newg, newpre) = elimUnreachable propConst toRemove g pre fn
        (bblk, allVars) = backToBlk edgeRemovedBlk
    in
        --(trace $
        --        "regular blk: \n" ++ show eblk ++
        --         "\n varmap: \n" ++ show nvarmap ++ 
        --         "\n blockmap: \n" ++ show nblkmap ++ 
        --         -- "\n\n  defmap :\n" ++ show defmap ++
        --         -- "\n\n usemap :\n" ++ show usemap ++
        --         "ToDelete: \n" ++ show toDelete ++
        --      "\n\nToModify: \n" ++ show toModify ++ 
            -- "Predecessor graph \n" ++ show pre ++
            --  "\n\nBlockToRemove \n" ++ show toRemove ++ 
            --  "\n\nedgeToRemove: \n" ++ show toRemove ++ 
        --    "\n\nFinalRemoved: \n" ++ show bblk)
        --     "\n\nNewGraph: \n" ++ show newg ++
        --    "\n\nNewPre: \n" ++ show newpre)
        (bblk, allVars, newg, newpre)
        
--enumerate the lines of AASM with in  blocks + initialize all the block list
enumBlock :: Map.Map Ident Block -> 
    (Map.Map Ident [StmtS], Int, Map.Map Ident Bool)
enumBlock = 
    Map.foldrWithKey'
            (\lab (phis, aasms) (m, next, blks) ->
                 let (phists, phinext) =
                         foldr
                             (\(a, a') (sts, next') ->
                                  let st = PhiS next' lab (a, a')
                                   in (st : sts, next' + 1))
                             ([], next)
                             phis
                     (aasmsts, aasmnext) =
                         foldr
                             (\aasm (sts, next') ->
                                  let st = AAsmS next' lab aasm
                                   in (st : sts, next' + 1))
                             ([], phinext)
                             aasms
                  in (Map.insert lab (phists ++ aasmsts) m, aasmnext, Map.insert lab False blks))
            (Map.empty, 0, Map.empty)
--wtf did i just wrote..
scc :: Map.Map Ident [StmtS] -- Set of all stmts 
    -> Set.Set ALoc -- temp worklist
    -> Set.Set Ident -- block worklist
    -> Map.Map ALoc StmtS -- where all the temps are defined, initialize to be empty
    -> Map.Map ALoc [StmtS] -- where all the temps are used, initialize to be empty 
    -> (Map.Map ALoc Value, Map.Map Ident Bool) --(values for temps, blocks whether executable)
    -> (Map.Map ALoc Value, Map.Map Ident Bool, Map.Map ALoc StmtS, Map.Map ALoc [StmtS])
scc stmts varwork blockwork vmap usemap (varmap, blockmap) 
    | null varwork && null blockwork = (varmap, blockmap, vmap, usemap) 
    | not(null blockwork) =
        --worklist for blocks non empty, we can keep going
        let
            blk = Set.elemAt 0 blockwork
            nvb = Set.deleteAt 0 blockwork
            st = fromMaybe [] (Map.lookup blk stmts)
            --update execuable list of statements
            (varmap', blockmap', defmap', usemap', varwork', blockwork') = 
                traverseBlock st False (varmap, blockmap) (vmap, usemap) (varwork, nvb)
        in
            scc stmts varwork' blockwork' defmap' usemap' (varmap', blockmap')
    --we can't traverse more blocks, 
    --for each var in the var worklist, we update all the lines of its use that is in execu to see if it changes the program
    | otherwise = 
        let
            fstvar = Set.elemAt 0 varwork
            nvr = Set.deleteAt 0 varwork
            st = fromMaybe [] (Map.lookup fstvar usemap)
            --traverse through the use statements of the variable, update accordingly
            (varmap', blockmap', defmap', usemap', varwork', blockwork') =
                traverseBlock st True (varmap, blockmap) (vmap, usemap) (nvr, blockwork) 
        in
            scc stmts varwork' blockwork' defmap' usemap' (varmap', blockmap')
    where 
        insertUse st usemap l = foldr (\u usemap -> insertHelper u st usemap) usemap (getLocs l)
        varlookup v varmap = case v of 
            AImm c1 -> Const c1
            ALoc v' -> if isTemp v' then fromMaybe N (Map.lookup v' varmap) else P
            
        foldphiargs varmap = foldr (\x acc -> 
            let xval = varlookup x varmap
            in
                if 
                xval == N || acc == P || acc == xval then
                acc else xval) N 

        changeInVal dest value (varmap, varwork) = let
            currVal = fromMaybe N (Map.lookup dest varmap) 
            in
                if currVal /= value then (Map.insert dest value varmap, Set.insert dest varwork) else (varmap, varwork)
           
        --traverse through the block and update everything we need, if Bool = False, we are looking at 
        -- a new block, so we update each variable's use, otherwise we do not care
        traverseBlock :: [StmtS] -> Bool ->
            (Map.Map ALoc Value, Map.Map Ident Bool) -> 
            (Map.Map ALoc StmtS, Map.Map ALoc [StmtS]) -> 
            (Set.Set ALoc, Set.Set Ident) -> 
            (Map.Map ALoc Value, Map.Map Ident Bool, Map.Map ALoc StmtS, Map.Map ALoc [StmtS], Set.Set ALoc ,Set.Set Ident)
        traverseBlock [] flag (varmap, blockmap) (defmap, usemap) (varwork, blockwork) = (varmap, blockmap, defmap, usemap, varwork, blockwork)
        traverseBlock (x:xs) flag (varmap, blockmap) (defmap, usemap) (varwork, blockwork) =
            case x of 
                PhiS _ _ (dest, args) -> let
                    usemap' = if flag then usemap else insertUse x usemap args
                    defmap' = if flag then defmap else Map.insert dest x defmap
                    res = foldphiargs varmap args 
                    in
                        case res of 
                            Const c1 -> let 
                                    (nvarmap, nvarwork) = changeInVal dest (Const c1) (varmap,varwork)
                                in
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                            other -> let 
                                (nvarmap, nvarwork) = changeInVal dest other (varmap,varwork)
                                in
                                    traverseBlock xs flag (varmap, blockmap) (defmap', usemap') (varwork, blockwork)
                AAsmS _ _ (AAsm [dest] ANop [c]) 
                    | isTemp dest -> let
                        usemap' = if flag then usemap else insertUse x usemap [c]
                        defmap' = if flag then defmap else Map.insert dest x defmap
                        in
                        case c of 
                            ALoc (AReg _) -> let 
                                (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)                          
                                in
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                            AImm i -> let 
                                (nvarmap, nvarwork) = changeInVal dest (Const i) (varmap,varwork)
                                in
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                            ALoc l -> if isTemp l then let 
                                (nvarmap, nvarwork) = changeInVal dest (fromMaybe N (Map.lookup l varmap)) (varmap,varwork)
                                in 
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                                else 
                                    let (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                AAsmS _ _ (AAsm [dest] ANopq [c])
                    | isTemp dest -> 
                        let
                            usemap' = if flag then usemap else insertUse x usemap [c]
                            defmap' = if flag then defmap else Map.insert dest x defmap
                        in 
                            case c of 
                                ALoc (AReg _) -> let 
                                    (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) 
                                        (defmap', usemap') (nvarwork, blockwork)
                                AImm i -> let 
                                    (nvarmap, nvarwork) = changeInVal dest (Const i) (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                                ALoc l -> if isTemp l then let 
                                    (nvarmap, nvarwork) = changeInVal dest (fromMaybe N (Map.lookup l varmap)) (varmap,varwork)
                                    in 
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                                    else 
                                        let (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                        in
                                            traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                AAsmS _ _ (AAsm [dest] op [arg1])
                    | isTemp dest ->
                        let 
                            usemap' = if flag then usemap else insertUse x usemap [arg1]
                            defmap' = if flag then defmap else Map.insert dest x defmap
                            l = varlookup arg1 varmap
                        in
                            case l of 
                                Const c1 -> 
                                    let c1' = fromIntegral c1 :: Int32
                                        res = case op of 
                                            ASub -> -c1'
                                            ABNot -> (-c1')-1
                                            ALNot -> (if c1' == 0 then 1 else 0)
                                        (nvarmap, nvarwork) = changeInVal dest (Const (fromIntegral res :: Int)) (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                                _ -> let
                                        (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                AAsmS _ _ (AAsm [dest] op [arg1, arg2])
                    | isTemp dest &&
                                   (op == AAdd ||
                                    op == AAddq ||
                                    op == ASub ||
                                    op == ASubq ||
                                    op == AMul || op == ABAnd || op == ALAnd || op == ABOr || op == ALOr || op == AXor) ->
                    let 
                        usemap' = if flag then usemap else insertUse x usemap [arg1, arg2]
                        defmap' = if flag then defmap else Map.insert dest x defmap
                        l = varlookup arg1 varmap
                        r = varlookup arg2 varmap
                    in
                        case (l, r) of 
                            (Const c1, Const c2) -> let
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
                                    (nvarmap, nvarwork) = changeInVal dest (Const (fromIntegral foldop :: Int)) (varmap,varwork)
                                in
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                            _-> let
                                (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                in
                                    traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                AAsmS _ _ (AControl (ACJump v l1 l2)) ->
                    let 
                        usemap' = if flag then usemap else insertUse x usemap [v]
                        l = varlookup v varmap 
                        (visited1, visited2) = (fromMaybe False (Map.lookup l1 blockmap), fromMaybe False (Map.lookup l2 blockmap)) 
                    in
                        case l of 
                            Const 1 -> if not visited1 then let 
                                    nblockmap = Map.insert l1 True blockmap
                                    nblockwork = Set.insert l1 blockwork
                                in 
                                    traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                else traverseBlock xs flag (varmap, blockmap) (defmap, usemap') (varwork, blockwork)
                            Const 0 -> if not visited2 then let 
                                    nblockmap = Map.insert l2 True blockmap
                                    nblockwork = Set.insert l2 blockwork
                                in 
                                    traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                else traverseBlock xs flag (varmap, blockmap) (defmap, usemap') (varwork, blockwork)
                            _ -> case (visited1, visited2) of 
                                (False, False) -> let 
                                        nblockmap = Map.insert l1 True (Map.insert l2 True blockmap)
                                        nblockwork = Set.insert l1 (Set.insert l2 blockwork)
                                    in 
                                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                (True, False) -> let 
                                        nblockmap = Map.insert l2 True blockmap
                                        nblockwork = Set.insert l2 blockwork
                                    in 
                                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                (False, True) -> let 
                                        nblockmap = Map.insert l1 True blockmap
                                        nblockwork = Set.insert l1 blockwork
                                    in 
                                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                _ -> traverseBlock xs flag (varmap, blockmap) (defmap, usemap') (varwork, blockwork)
                AAsmS _ _ (AControl (AJump l1)) -> 
                    if not (fromMaybe False (Map.lookup l1 blockmap)) then let 
                        nblockmap = Map.insert l1 True blockmap
                        nblockwork = Set.insert l1 blockwork
                    in 
                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap) (varwork, nblockwork)
                    else 
                        traverseBlock xs flag (varmap, blockmap) (defmap, usemap) (varwork, blockwork)
                AAsmS _ _ (AControl (ACJump' op arg1 arg2 l1 l2)) -> let          
                        usemap' = if flag then usemap else insertUse x usemap [arg1, arg2]
                        l = varlookup arg1 varmap
                        r = varlookup arg2 varmap
                        (visited1, visited2) = (fromMaybe False (Map.lookup l1 blockmap), fromMaybe False (Map.lookup l2 blockmap))
                    in
                        case (l, r) of 
                            (Const c1, Const c2) -> let 
                                foldcmp = case op of
                                    AEq -> c1 == c2
                                    AEqq -> c1 == c2
                                    ANe -> c1 /= c2
                                    ANeq -> c1 /= c2
                                    ALt -> c1 < c2
                                    ALe -> c1 <= c2
                                    AGt -> c1 > c2
                                    AGe -> c1 >= c2
                                toint = if foldcmp then 1 else 0
                                in
                                    if toint /= 0 && not visited1 then let 
                                        nblockmap = Map.insert l1 True blockmap
                                        nblockwork = Set.insert l1 blockwork
                                    in 
                                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                    else if toint == 0 && not visited2 then let 
                                        nblockmap = Map.insert l2 True blockmap
                                        nblockwork = Set.insert l2 blockwork
                                    in 
                                        traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                    else traverseBlock xs flag (varmap, blockmap) (defmap, usemap') (varwork, blockwork)
                            _ -> case (visited1, visited2) of 
                                    (False, False) -> let 
                                            nblockmap = Map.insert l1 True (Map.insert l2 True blockmap)
                                            nblockwork = Set.insert l1 (Set.insert l2 blockwork)
                                        in 
                                            traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                    (True, False) -> let 
                                            nblockmap = Map.insert l2 True blockmap
                                            nblockwork = Set.insert l2 blockwork
                                        in 
                                            traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                    (False, True) -> let 
                                            nblockmap = Map.insert l1 True blockmap
                                            nblockwork = Set.insert l1 blockwork
                                        in 
                                            traverseBlock xs flag (varmap, nblockmap) (defmap, usemap') (varwork, nblockwork)
                                    _ -> traverseBlock xs flag (varmap, blockmap) (defmap, usemap') (varwork, blockwork)
                AAsmS _ _ (ARel [dest] binop [arg1, arg2])
                    | isTemp dest -> 
                        let 
                            usemap' = if flag then usemap else insertUse x usemap [arg1, arg2]
                            defmap' = if flag then defmap else Map.insert dest x defmap
                            l = varlookup arg1 varmap
                            r = varlookup arg2 varmap
                        in
                            case (l, r) of 
                                (Const c1, Const c2) ->
                                    let foldcmp = case binop of
                                            AEq -> c1 == c2
                                            AEqq -> c1 == c2
                                            ANe -> c1 /= c2
                                            ANeq -> c1 /= c2
                                            ALt -> c1 < c2
                                            ALe -> c1 <= c2
                                            AGt -> c1 > c2
                                            AGe -> c1 >= c2
                                        toint = if foldcmp then 1 else 0
                                        (nvarmap, nvarwork) = changeInVal dest (Const toint) (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                                _ -> 
                                    let
                                        (nvarmap, nvarwork) = changeInVal dest P (varmap,varwork)
                                    in
                                        traverseBlock xs flag (nvarmap, blockmap) (defmap', usemap') (nvarwork, blockwork)
                _ -> if flag then traverseBlock xs flag (varmap, blockmap) (defmap, usemap) (varwork, blockwork) else let 
                        (dfnst, usest) = getDefUse x
                        defmap' = maybe defmap (\y -> Map.insert y x defmap) dfnst
                        usemap' = foldr(\u map -> insertHelper u x map) usemap usest
                    in
                        traverseBlock xs flag (varmap, blockmap) (defmap', usemap') (varwork, blockwork)

changeStmt :: StmtS -> ALoc -> Int -> Map.Map Int StmtS -> Map.Map Int StmtS
changeStmt stmt loc c modset = 
    let
        stmt' = fromMaybe stmt (Map.lookup (getLineNum stmt) modset)
    in
        case stmt' of 
            PhiS lno l (dest, args) ->  Map.insert lno (PhiS lno l (dest, map(\x -> if x == ALoc(loc) then (AImm c) else x) args)) modset
            AAsmS lno l (AAsm [dest] op args) ->
                Map.insert lno (AAsmS lno l (AAsm [dest] op (map(\x -> if x == ALoc(loc) then (AImm c) else x) args))) modset
            AAsmS lno l (ARel [dest] op args) ->
                 Map.insert lno (AAsmS lno l (ARel [dest] op (map(\x -> if x == ALoc(loc) then (AImm c) else x) args))) modset
            AAsmS lno l (ARet arg) -> 
                Map.insert lno (AAsmS lno l (ARet $ AImm c)) modset
            AAsmS lno l (ACall lab args i) -> 
                Map.insert lno (AAsmS lno l (ACall lab (map(\x -> if x == ALoc(loc) then (AImm c) else x) args) i)) modset
            AAsmS lno l (AControl (ACJump arg l1 l2)) -> 
                if c /= 0 then Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset 
                else Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
            AAsmS lno l (AControl (ACJump' op arg1 arg2 l1 l2)) -> let
                    foldop op c1 c2 = case op of
                        AEq -> c1 == c2
                        AEqq -> c1 == c2
                        ANe -> c1 /= c2
                        ANeq -> c1 /= c2
                        ALt -> c1 < c2
                        ALe -> c1 <= c2
                        AGt -> c1 > c2
                        AGe -> c1 >= c2 
                in  
                    case Map.lookup lno modset of 
                        Just sth@(AAsmS lno l (AControl(ACJump' op (AImm c1) arg2 l1 l2))) -> if 
                            foldop op c1 c then Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset
                            else Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                        Just sth@(AAsmS lno l (AControl(ACJump' op arg1 (AImm c2) l1 l2))) -> if 
                            foldop op c c2 then Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset
                            else Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                        Nothing 
                            | arg1 == arg2 ->
                                if foldop op c c then                               
                                Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset else
                                    
                                Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                            | arg1 == ALoc loc -> 
                                Map.insert lno
                                (AAsmS lno l (AControl (ACJump' op (AImm c) arg2 l1 l2)))
                                modset
                            | otherwise ->
                                Map.insert lno
                                (AAsmS lno l (AControl (ACJump' op arg1 (AImm c) l1 l2)))
                                modset
                        _ -> modset
            _ -> modset

changeStmtDebug :: StmtS -> ALoc -> Int -> Map.Map Int StmtS -> Map.Map Int StmtS
changeStmtDebug stmt loc c modset = 
    let
        stmt' = fromMaybe stmt (Map.lookup (getLineNum stmt) modset)
    in
        case stmt' of 
            PhiS lno l (dest, args) -> (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt) Map.insert lno (PhiS lno l (dest, map(\x -> if x == ALoc(loc) then (AImm c) else x) args)) modset
            AAsmS lno l (AAsm [dest] op args) ->(trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)
                Map.insert lno (AAsmS lno l (AAsm [dest] op (map(\x -> if x == ALoc(loc) then (AImm c) else x) args))) modset
            AAsmS lno l (ARel [dest] op args) ->
                (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt) Map.insert lno (AAsmS lno l (ARel [dest] op (map(\x -> if x == ALoc(loc) then (AImm c) else x) args))) modset
            AAsmS lno l (ARet arg) -> 
                (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)Map.insert lno (AAsmS lno l (ARet $ AImm c)) modset
            AAsmS lno l (ACall lab args i) -> 
                (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)Map.insert lno (AAsmS lno l (ACall lab (map(\x -> if x == ALoc(loc) then (AImm c) else x) args) i)) modset
            AAsmS lno l (AControl (ACJump arg l1 l2)) -> 
                if c /= 0 then (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset 
                else (trace $
                "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
            AAsmS lno l (AControl (ACJump' op arg1 arg2 l1 l2)) -> let
                    foldop op c1 c2 = case op of
                        AEq -> c1 == c2
                        AEqq -> c1 == c2
                        ANe -> c1 /= c2
                        ANeq -> c1 /= c2
                        ALt -> c1 < c2
                        ALe -> c1 <= c2
                        AGt -> c1 > c2
                        AGe -> c1 >= c2 
                in  
                    case Map.lookup lno modset of 
                        Just sth@(AAsmS lno l (AControl(ACJump' op (AImm c1) arg2 l1 l2))) -> if 
                            foldop op c1 c then (trace $
                            "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show sth)Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset
                            else (trace $
                            "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show sth)Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                        Just sth@(AAsmS lno l (AControl(ACJump' op arg1 (AImm c2) l1 l2))) -> if 
                            foldop op c c2 then (trace $
                            "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show sth)Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset
                            else Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                        Nothing 
                            | arg1 == arg2 ->
                                if foldop op c c then(trace $ "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)                                  
                                Map.insert lno (AAsmS lno l (AControl $ AJump l1)) modset else
                                    (trace $ "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)
                                Map.insert lno (AAsmS lno l (AControl $ AJump l2)) modset
                            | arg1 == ALoc loc -> (trace $ "change stmt: " ++ show loc ++ " to " ++ show c ++ "\n" ++ show stmt)
                                Map.insert lno
                                (AAsmS lno l (AControl (ACJump' op (AImm c) arg2 l1 l2)))
                                modset
                            | otherwise -> (trace $ "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt)
                                Map.insert lno
                                (AAsmS lno l (AControl (ACJump' op arg1 (AImm c) l1 l2)))
                                modset
                        _ -> (trace $ "change stmt:" ++ show loc ++ "to" ++ show c ++ "\n" ++ show stmt) modset
            _ -> modset

--remove useless variables after our constant propagation
--(varmap, location to be defined, location used)
-- -> (toDelete, toModify)
modifyStmts :: 
    (Map.Map ALoc Value, Map.Map ALoc StmtS, Map.Map ALoc [StmtS])
    -> (Set.Set Int, Map.Map Int StmtS)
    -> (Set.Set Int, Map.Map Int StmtS)
modifyStmts (varmap, defmap, usemap) (toDelete, toModify) = 
    Map.foldrWithKey'(\var val (del, mod) ->
        case val of 
            --we remove these statements
            Const c1 -> let 
                usest = fromMaybe [] (Map.lookup var usemap)
                defsite = fromMaybe (error "we did somthing wrong") (Map.lookup var defmap)
                del' = Set.insert (getLineNum defsite) del
                modified = foldr (\x modify -> if Set.member (getLineNum x) del' then modify else 
                    changeStmt x var c1 modify) mod usest
                in
                    (del', modified)
            ) (Set.empty, Map.empty) varmap

--info of whether block is used -> predecessor graph -> Edge to remove block
modifyBlocks :: 
    Map.Map Ident Bool -> Map.Map Ident (Map.Map Ident Int) -> Map.Map Ident Ident
modifyBlocks blockmap pred =
    Map.foldrWithKey' (\blk use toRemove ->
        if not use then let
            --predecessors = fromMaybe (error "the block has no pred") (Map.lookup blk pred)
                predecessors = fromMaybe Map.empty (Map.lookup blk pred)
            in
                -- (trace $ "The block" ++ show blk ++ "Predecessors to delete" ++ show predecessors ) 
                Map.foldrWithKey' (\blks _ rem -> Map.insert blks blk rem) toRemove predecessors
        else 
            toRemove
        ) Map.empty blockmap

instance Show Value where
    show N = "N"
    show P = "P"
    show (Const c) = show c 





