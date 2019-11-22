module Compile.Backend.SSARegAlloc where

import Compile.Backend.AAsm2Asm
import Compile.Backend.RegisterAlloc
import Compile.Backend.SSA
import Compile.Types
import Control.Monad.State
import qualified Data.List as List
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

import Debug.Trace

type PhiA = (Operand, [Operand])

type ColorBlock = ([PhiA], [Inst])

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
insertLive x y m =
    case Map.lookup x m of
        Just s -> Map.insert x (Set.insert y s) m
        Nothing -> Map.insert x (Set.singleton y) m

getBlkName :: StmtS -> Ident
getBlkName s =
    case s of
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

defUse :: StmtS -> Bool -> (Set.Set ALoc, Set.Set ALoc)
defUse (PhiS _ _ (dest, srcs)) isTL = (Set.singleton dest, locsSet srcs)
defUse (AAsmS _ _ aasm) isTL =
    case aasm of
        ARet val -> (Set.empty, locsSet [val])
        AAsm [assign] _ args ->
            case assign of
                AReg _ -> (Set.singleton assign, locsSet args)
                ATemp _ -> (Set.singleton assign, locsSet args)
                APtr p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrq p -> (Set.singleton p, locsSet $ ALoc assign : args)
                APtrNull -> (Set.empty, locsSet $ ALoc assign : args)
        ARel [assign] _ args ->
            case assign of
                AReg _ -> (Set.singleton assign, locsSet args)
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
                    | "_ret" `List.isSuffixOf` l ->
                        if isTL
                            then (Set.empty, Set.fromList [AReg 0, AReg 9])
                            else (Set.empty, Set.singleton (AReg 0))
                    | otherwise -> (Set.empty, Set.empty)
                ACJump val _ _ -> (Set.empty, locsSet [val])
                ACJump' _ val1 val2 _ _ -> (Set.empty, locsSet [val1, val2])
                _ -> (Set.empty, Set.empty)

enumBlks ::
       Map.Map Ident Block -> Bool
    -> (Map.Map Ident [StmtS], Map.Map ALoc StmtS, Map.Map ALoc [StmtS], Set.Set StmtS, Map.Map Int StmtS, Int)
enumBlks blk isTL =
    Map.foldrWithKey'
        (\lab (phis, aasms) (m, def, use, sset, smap, next) ->
             let (phists, phidef, phiuse, phisset, phismap, phinext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') (a, a') ->
                              let st = PhiS next' lab (a, a')
                                  (dfnst, usest) = defUse st isTL
                                  ndef = foldr (\x dm -> Map.insert x st dm) def' dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], def, use, sset, smap, next)
                         phis
                 (aasmsts, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext) =
                     foldl
                         (\(sts, def', use', sset', smap', next') aasm ->
                              let st = AAsmS next' lab aasm
                                  (dfnst, usest) = defUse st isTL
                                  ndef = foldr (\x dm -> Map.insert x st dm) def' dfnst
                                  nuse = foldr (\u usemap -> insertHelper u st usemap) use' usest
                               in (st : sts, ndef, nuse, Set.insert st sset', Map.insert next' st smap', next' + 1))
                         ([], phidef, phiuse, phisset, phismap, phinext)
                         aasms
              in (Map.insert lab (reverse phists ++ reverse aasmsts) m, aasmdef, aasmuse, aasmsset, assmsmap, aasmnext))
        (Map.empty, Map.empty, Map.empty, Set.empty, Map.empty, 0) blk

livenessAnalysis :: Map.Map Ident Block -> Map.Map Ident (Map.Map Ident Int) -> Bool -> Graph
livenessAnalysis blk pre isTL =
    let (blks, defs, uses, _, smap, _) = enumBlks blk isTL
        runLiveness = do
            livenessAnalysisM blks smap pre defs uses isTL
            gets interference
        initState =
            LivenessState
                { blkM = Set.empty
                , interference = Map.empty
                , liveoutblk = Map.empty
                , liveinblk = Map.empty
                , liveoutstmt = Map.empty
                , liveinstmt = Map.empty
                }
     in evalState runLiveness initState

--        (trace $ "Blks\n" ++ show blks ++
--        "\n\nDefs\n" ++ show defs ++
--        "\n\nUses\n" ++ show uses)
livenessAnalysisM ::
       Map.Map Ident [StmtS]
    -> Map.Map Int StmtS
    -> Map.Map Ident (Map.Map Ident Int)
    -> Map.Map ALoc StmtS
    -> Map.Map ALoc [StmtS]
    -> Bool
    -> State LivenessState ()
livenessAnalysisM blk smap pre defs uses isTL =
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
                                                  (fromMaybe (error "1") (Map.lookup pb pre))
                                      case pblk of
                                          Just pblk' -> liveOutAtBlock blk smap pre pblk' v isTL
                                          Nothing -> error "SSA Liveness Error 2"
                                  Nothing -> error "SSA Liveness Error 1"
                          _ -> liveInAtStatement blk smap pre s v isTL)
                 ()
                 vuse)
        ()
        (Map.keys defs ++ map AReg [0 .. 10])

liveOutAtBlock ::
       Map.Map Ident [StmtS]
    -> Map.Map Int StmtS
    -> Map.Map Ident (Map.Map Ident Int)
    -> Ident
    -> ALoc
    -> Bool
    -> State LivenessState ()
liveOutAtBlock blk smap pre n v isTL = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf (insertLive n v ob) ib os is
    bigm <- gets blkM
    unless (Set.member n bigm) $ do
        modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState (Set.insert n bm) intf ob ib os is
        case Map.lookup n blk of
            Just stmts -> liveOutAtStatement blk smap pre (last stmts) v isTL
            Nothing -> return ()

liveInAtStatement ::
       Map.Map Ident [StmtS]
    -> Map.Map Int StmtS
    -> Map.Map Ident (Map.Map Ident Int)
    -> StmtS
    -> ALoc
    -> Bool
    -> State LivenessState ()
liveInAtStatement blk smap pre s v isTL = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob ib os (insertLive s v is)
    let n = getBlkName s
        stmt = fromMaybe (error "SSA Liveness Error 3") (Map.lookup n blk)
    if s == head stmt
        then do
            modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob (insertLive n v ib) os is
            let preds = fromMaybe Map.empty (Map.lookup n pre)
            foldM_ (\_ p -> liveOutAtBlock blk smap pre p v isTL) () (Map.keys preds)
        else let lno = getLineNum s
                 prevStmt = fromMaybe (error "SSA Liveness Error 4") (Map.lookup (lno - 1) smap)
              in liveOutAtStatement blk smap pre prevStmt v isTL

liveOutAtStatement ::
       Map.Map Ident [StmtS]
    -> Map.Map Int StmtS
    -> Map.Map Ident (Map.Map Ident Int)
    -> StmtS
    -> ALoc
    -> Bool
    -> State LivenessState ()
liveOutAtStatement blk smap pre s v isTL = do
    modify' $ \(LivenessState bm intf ob ib os is) -> LivenessState bm intf ob ib (insertLive s v os) is
    let (w, _) = defUse s isTL
        nw =
            case s of
                AAsmS _ _ (AAsm _ asnop _)
                    | asnop == ADiv || asnop == ADivq || asnop == AMod || asnop == AModq ->
                        Set.insert (AReg 0) (Set.insert (AReg 1) w)
                    | asnop == ASal || asnop == ASar -> Set.insert (AReg 2) w
                    | otherwise -> w
                _ -> w
    foldM_
        (\() w' ->
             modify' $ \(LivenessState bm intf ob ib os is) ->
                 LivenessState bm (addEdge (w', v) (addEdge (v, w') intf)) ob ib os is)
        ()
        (Set.delete v nw)
    unless (Set.member v nw) $ liveInAtStatement blk smap pre s v isTL

phiColor :: Map.Map ALoc Int -> (ALoc, [AVal]) -> (Operand, [Operand])
phiColor coloring (a, ps) =
    let a' = mapToReg64 a coloring
        ps' = getRegAlloc ps coloring True
     in (a', ps')

colorSSA ::
       String
    -> Map.Map Ident Block
    -> Map.Map Ident (Map.Map Ident Int)
    -> Set.Set Int
    -> Header
    -> [Ident]
    -> Map.Map String String
    -> String
colorSSA fn blk pre livevars header serial trdict =
    let fname
            | Map.member fn (fnDecl header) = fn
            | fn == "a bort" = "_c0_abort_local411"
            | otherwise = "_c0_" ++ fn
        isTL = Map.member fn trdict
        nblk =
            if isTL
                then Map.insert
                         (fname ++ "_ret")
                         ( []
                         , [ AControl $ ALab (fname ++ "_ret")
                           , AAsm [AReg 9] ANop [ALoc $ AReg 9]
                           , AControl $ AJump fname
                           ])
                         blk
                else blk
        npre =
            if isTL
                then Map.insert fname (Map.singleton (fname ++ "_ret") 0) pre
                else pre
        intf = livenessAnalysis nblk npre isTL
        (coloring, stackVar, calleeSaved) =
            if length livevars >= 2000
                then allStackColor livevars
                else let precolor =
                             Map.fromList
                                 [ (AReg 0, 0)
                                 , (AReg 1, 3)
                                 , (AReg 2, 4)
                                 , (AReg 3, 1)
                                 , (AReg 4, 2)
                                 , (AReg 5, 5)
                                 , (AReg 6, 6)
                                 , (AReg 9, 7)
                                 ]
                         seo = mcs intf precolor
                      in color intf seo precolor
        nonTrivial asm =
            case asm of
                Movl op1 op2 -> op1 /= op2
                Movq op1 op2 -> op1 /= op2
                _ -> True
        colorblk =
            Map.foldrWithKey'
                (\nme (phis, aasms) newb ->
                     let colorPhis = map (phiColor coloring) phis
                         colorAAsms = concatMap (\x -> toAsm x coloring header) aasms
                      in Map.insert nme (colorPhis, colorAAsms) newb)
                Map.empty
                blk
        stackVarAligned
            | (length calleeSaved + 1) `mod` 2 == 0 =
                (if stackVar `mod` 2 == 0
                     then stackVar + 1
                     else stackVar)
            | stackVar `mod` 2 == 0 = stackVar
            | otherwise = stackVar + 1
        prolog =
            if stackVarAligned > 0
                then [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] -- Save rbp of parent, update rbp using rsp
                      ++
                     map (Pushq . Reg . toReg64) calleeSaved -- Save callee-saved registers used in the function
                      ++
                     [Subq (Imm (stackVarAligned * 8)) (Reg RSP)] -- Allocate stack space
                else [Fun fname, Pushq (Reg RBP), Movq (Reg RSP) (Reg RBP)] ++ map (Pushq . Reg . toReg64) calleeSaved
        epilog =
            case Map.lookup fn trdict of
                Just "ADD" ->
                    if stackVarAligned > 0
                        then [ Label $ fname ++ "_ret"
                             , Addl (Reg R12D) (Reg EAX)
                             , Addq (Imm (stackVarAligned * 8)) (Reg RSP)
                             ] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                        else [Label $ fname ++ "_ret", Addl (Reg R12D) (Reg EAX)] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                Just "MUL" ->
                    if stackVarAligned > 0
                        then [ Label $ fname ++ "_ret"
                             , Imull (Reg R12D) (Reg EAX)
                             , Addq (Imm (stackVarAligned * 8)) (Reg RSP)
                             ] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                        else [Label $ fname ++ "_ret", Imull (Reg R12D) (Reg EAX)] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                _ ->
                    if stackVarAligned > 0
                        then [Label $ fname ++ "_ret", Addq (Imm (stackVarAligned * 8)) (Reg RSP)] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
                        else [Label $ fname ++ "_ret"] ++
                             map (Popq . Reg . toReg64) (reverse calleeSaved) ++ [Popq (Reg RBP), Ret]
        insts = filter nonTrivial (deSSA pre colorblk serial)
        optinsts = remove_move insts
          where
            remove_move :: [Inst] -> [Inst]
            remove_move [] = []
            remove_move [x] = [x]
            remove_move (x:y:xs) =
                case (x, y) of
                    (Movl op1 op2, Movl op3 op4) ->
                        if op1 == op4 && op2 == op3
                            then remove_move (x : xs)
                            else x : remove_move (y : xs)
                    (Movq op1 op2, Movq op3 op4) ->
                        if op1 == op4 && op2 == op3
                            then remove_move (x : xs)
                            else x : remove_move (y : xs)
                    (Jmp l1, Label l2) ->
                        if l1 == l2
                            then remove_move (y : xs)
                            else x : remove_move (y : xs) --delete redundant jumps
                    _ -> x : remove_move (y : xs)
        fun = prolog ++ optinsts ++ epilog
     in concatMap (\line -> show line ++ "\n") fun

--        (trace $ "Blk\n" ++ show nblk ++ "\nIntf\n" ++ show intf ++ "\nColorBlk\n" ++ show colorblk)
insertAt :: [a] -> Int -> [a] -> [a]
insertAt newElement 0 as = newElement ++ as
insertAt newElement i (a:as) = a : insertAt newElement (i - 1) as

deBlocks :: Map.Map Ident (Map.Map Ident Int) -> Map.Map Ident ColorBlock -> Map.Map Ident [Inst]
deBlocks pre blks =
    Map.foldrWithKey'
        (\nme (phis, _) m ->
             if not (null phis)
                 then let numphi = length $ snd (head phis)
                          getcolumn ps i = map (\p -> snd p !! i) ps
                          dest = map fst phis
                          srcs = map (getcolumn phis) [0 .. (numphi - 1)]
                       in Map.foldrWithKey'
                              (\prdc idx m' ->
                                   let copies = parallelCopy (srcs !! idx) dest (Reg R10)
                                       movs = concatMap (uncurry genMovq) copies
                                       paasms = fromMaybe (error "2") (Map.lookup prdc m')
                                       newpaasms = insertAt movs (length paasms - 1) paasms
                                    in Map.insert prdc newpaasms m')
                              m
                              (fromMaybe (error "3") (Map.lookup nme pre))
                 else m)
        (Map.map snd blks)
        blks

deSSA :: Map.Map Ident (Map.Map Ident Int) -> Map.Map Ident ColorBlock -> [Ident] -> [Inst]
deSSA pre blks serial =
    let deblks = deBlocks pre blks
     in concatMap (\nme -> fromMaybe [] (Map.lookup nme deblks)) serial

data CopyStatus
    = ToMove
    | BeingMoved
    | Moved
    deriving (Eq)

data ParCopyState =
    ParCopyState
        { copyStat :: Map.Map Int CopyStatus
        , emit :: [(Operand, Operand)]
        , loc :: [Operand]
        }

parallelCopy :: [Operand] -> [Operand] -> Operand -> [(Operand, Operand)]
parallelCopy src dst tmp =
    let runParCopy = do
            parallelCopyM src dst tmp
            emits <- gets emit
            return $ reverse emits
        initState = ParCopyState Map.empty [] []
     in evalState runParCopy initState

parallelCopyM :: [Operand] -> [Operand] -> Operand -> State ParCopyState ()
parallelCopyM src dst tmp = do
    let n = length src
        cstat = foldr (\i m -> Map.insert i ToMove m) Map.empty [0 .. n - 1]
    modify' $ \(ParCopyState _ e _) -> ParCopyState cstat e src
    let moveone i = do
            locs <- gets loc
            when (locs !! i /= dst !! i) $ do
                modify' $ \(ParCopyState c e l) -> ParCopyState (Map.insert i BeingMoved c) e l
                foldM_
                    (\_ j -> do
                         locs' <- gets loc
                         when (locs' !! j == dst !! i) $ do
                             stat <- gets copyStat
                             case fromMaybe (error "4") (Map.lookup j stat) of
                                 ToMove -> moveone j
                                 BeingMoved ->
                                     modify' $ \(ParCopyState c e l) ->
                                         ParCopyState c ((locs' !! j, tmp) : e) (replaceNth j tmp l)
                                 Moved -> return ())
                    ()
                    [0 .. n - 1]
                locs'' <- gets loc
                modify' $ \(ParCopyState c e l) -> ParCopyState (Map.insert i Moved c) ((locs'' !! i, dst !! i) : e) l
    foldM_
        (\_ i -> do
             stat <- gets copyStat
             when (fromMaybe (error "5") (Map.lookup i stat) == ToMove) $ moveone i)
        ()
        [0 .. n - 1]