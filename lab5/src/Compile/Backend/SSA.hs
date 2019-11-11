{-# LANGUAGE LambdaCase #-}

module Compile.Backend.SSA where

import Compile.Backend.LiveVariable
import Compile.Types
import Control.Monad.State
import qualified Data.Map as Map
import Data.Maybe
import qualified Data.Set as Set

import Debug.Trace

data BlockState =
    BlockState
        { currAAsm :: [AAsm]
        , currBlock :: Block
        , labelMap :: Map.Map Ident [ALoc]
        , currLine :: Int
        }
    deriving (Show)

data SSAState =
    SSAState
        { varMap :: Map.Map Int Int
        , nextInt :: Int
        , targetParam :: Map.Map Ident [ALoc]
        }

type Block = [(Ident, [ALoc], [AAsm])]

ssa :: [AAsm] -> (LiveList, Pred) -> Ident -> (Block, Map.Map Ident [ALoc], Int)
ssa aasms ll fn =
    let runToBlock = do
            toBlockM (reverse aasms) ll fn
            b <- gets currBlock
            m <- gets labelMap
            return (b, m)
        (blk, labMap) = evalState runToBlock (BlockState [] [] Map.empty (length aasms - 1))
        paramBlock = paramLabel blk labMap fn
        runToSSA = do
            b <- toSSA paramBlock []
            m <- gets targetParam
            c <- gets nextInt
            return (b, m, c)
        ssaBlock = evalState runToSSA (SSAState Map.empty 0 Map.empty)
     in ssaBlock

toBlockM :: [AAsm] -> (LiveList, Pred) -> Ident -> State BlockState ()
toBlockM [] _ fn = modify' $ \(BlockState aasm blk lm line) -> BlockState [] ((fn, [], aasm) : blk) lm (line - 1)
toBlockM (x:xs) ll@(live, pred) fn = do
    line <- gets currLine
    case x of
        AControl (ALab l) -> do
            let (_, succlist, _) = pred Map.! line
                lives = Set.toList $ combinelive succlist live
            modify' $ \(BlockState aasm blk lm _) ->
                BlockState [] ((l, lives, aasm) : blk) (Map.insert l lives lm) (line - 1)
            toBlockM xs ll fn
        _ -> do
            modify' $ \(BlockState aasm blk lm _) -> BlockState (x : aasm) blk lm (line - 1)
            toBlockM xs ll fn

paramLabel :: Block -> Map.Map Ident [ALoc] -> Ident -> Block
paramLabel blk labMap fn =
    map (\(lab, lives, aasms) ->
             let aasmP =
                     map
                         (\case
                              AControl (AJump l) -> AControl (AJumpP (l, findParam l))
                              AControl (ACJump x l1 l2) -> AControl (ACJumpP x (l1, findParam l1) (l2, findParam l2))
                              AControl (ACJump' op a b l1 l2) ->
                                  AControl (ACJumpP' op a b (l1, findParam l1) (l2, findParam l2))
                              s -> s)
                         aasms
              in (lab, lives, aasmP))
        blk
  where
    findParam l =
        if l == fn ++ "_ret" || l == "memerror"
            then []
            else fromMaybe (error $ "Label not found: " ++ l ++ " in function " ++ fn) (Map.lookup l labMap)

isTemp :: ALoc -> Bool
isTemp (ATemp _) = True
isTemp _ = False

nextVersion :: ALoc -> State SSAState ALoc
nextVersion (ATemp x) = do
    n <- gets nextInt
    modify' $ \(SSAState vm c tm) -> SSAState (Map.insert x n vm) (c + 1) tm
    return $ ATemp n
nextVersion p@(APtr (ATemp _)) = currentVersion p
nextVersion p@(APtrq (ATemp _)) = currentVersion p
nextVersion aloc = return aloc

currentVersion :: ALoc -> State SSAState ALoc
currentVersion (ATemp x) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ ATemp n
        Nothing -> nextVersion (ATemp x)
currentVersion (APtr (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ APtr (ATemp n)
        Nothing -> error "Undefined Ptr"
currentVersion (APtrq (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ APtrq (ATemp n)
        Nothing -> error "Undefined Ptrq"
currentVersion aloc = return aloc

currentVersion' :: AVal -> State SSAState AVal
currentVersion' (ALoc (ATemp x)) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ ALoc (ATemp n)
        Nothing -> do
            aloc <- nextVersion (ATemp x)
            return $ ALoc aloc
currentVersion' (ALoc (APtr (ATemp x))) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ ALoc (APtr (ATemp n))
        Nothing -> do
            aloc <- nextVersion (APtr (ATemp x))
            return $ ALoc aloc
currentVersion' (ALoc (APtrq (ATemp x))) = do
    vMap <- gets varMap
    case Map.lookup x vMap of
        Just n -> return $ ALoc (APtrq (ATemp n))
        Nothing -> do
            aloc <- nextVersion (APtrq (ATemp x))
            return $ ALoc aloc
currentVersion' aval = return aval

blockSSA :: [AAsm] -> [AAsm] -> State SSAState [AAsm]
blockSSA [] ssa = return (reverse ssa)
blockSSA (x:xs) ssa =
    case x of
        AFun fn args -> do
            nargs <- mapM currentVersion args
            blockSSA xs (AFun fn nargs : ssa)
        AAsm assigns op args -> do
            nargs <- mapM currentVersion' args
            nassigns <- mapM nextVersion assigns
            blockSSA xs (AAsm nassigns op nargs : ssa)
        ARel assigns op args -> do
            nargs <- mapM currentVersion' args
            nassigns <- mapM nextVersion assigns
            blockSSA xs (ARel nassigns op nargs : ssa)
        ACall fn args num -> do
            nargs <- mapM currentVersion args
            blockSSA xs (ACall fn nargs num : ssa)
        ARet e -> do
            ne <- currentVersion' e
            blockSSA xs (ARet ne : ssa)
        AControl (AJumpP (l, params)) -> do
            nparams <- mapM currentVersion params
            blockSSA xs (AControl (AJumpP (l, nparams)) : ssa)
        AControl (ACJumpP e (l1, p1) (l2, p2)) -> do
            ne <- currentVersion' e
            np1 <- mapM currentVersion p1
            np2 <- mapM currentVersion p2
            blockSSA xs (AControl (ACJumpP ne (l1, np1) (l2, np2)) : ssa)
        AControl (ACJumpP' op a b (l1, p1) (l2, p2)) -> do
            na <- currentVersion' a
            nb <- currentVersion' b
            np1 <- mapM currentVersion p1
            np2 <- mapM currentVersion p2
            blockSSA xs (AControl (ACJumpP' op na nb (l1, np1) (l2, np2)) : ssa)
        _ -> blockSSA xs (x : ssa)

toSSA :: Block -> Block -> State SSAState Block
toSSA [] ssa = return (reverse ssa)
toSSA ((lab, lives, aasms):xs) ssa = do
    nlives <- mapM nextVersion lives
    naasms <- blockSSA aasms []
    modify' $ \(SSAState vm c tm) -> SSAState vm c (Map.insert lab nlives tm)
    toSSA xs ((lab, nlives, naasms) : ssa)

deBlock :: [AAsm] -> Map.Map Ident [ALoc] -> Int -> Ident -> [[AAsm]] -> [[AAsm]]
deBlock [] _ _ _ aasm = reverse aasm
deBlock (x:xs) lMap newLab suffix aasm =
    case x of
        AControl (AJumpP (l, params)) ->
            let target = fromMaybe (error $ "Cannot find target label: " ++ l) (Map.lookup l lMap)
                movs = map (\(s, t) -> AAsm [t] ANopq [ALoc s]) (zip params target) ++ [AControl (AJump l)]
             in deBlock xs lMap newLab suffix (movs : aasm)
        AControl (ACJumpP e (l1, p1) (l2, p2)) ->
            let t1 = fromMaybe (error $ "Cannot find target label: " ++ l1) (Map.lookup l1 lMap)
                t2 = fromMaybe (error $ "Cannot find target label: " ++ l2) (Map.lookup l2 lMap)
                s1 = "L" ++ show newLab ++ suffix
                s2 = "L" ++ show (newLab + 1) ++ suffix
                mov1 =
                    [AControl (ALab s1)] ++
                    map
                        (\(s, t) ->
                             case s of
                                 APtrq _ -> AAsm [t] ANopq [ALoc s]
                                 _ -> AAsm [t] ANop [ALoc s])
                        (zip p1 t1) ++
                    [AControl (AJump l1)]
                mov2 =
                    [AControl (ALab s2)] ++
                    map
                        (\(s, t) ->
                             case s of
                                 APtrq _ -> AAsm [t] ANopq [ALoc s]
                                 _ -> AAsm [t] ANop [ALoc s])
                        (zip p2 t2) ++
                    [AControl (AJump l2)]
                deblk = [AControl (ACJump e s1 s2)] ++ mov1 ++ mov2
             in deBlock xs lMap (newLab + 2) suffix (deblk : aasm)
        AControl (ACJumpP' op a b (l1, p1) (l2, p2)) ->
            let t1 = fromMaybe (error $ "Cannot find target label: " ++ l1) (Map.lookup l1 lMap)
                t2 = fromMaybe (error $ "Cannot find target label: " ++ l2) (Map.lookup l2 lMap)
                s1 = "L" ++ show newLab ++ suffix
                s2 = "L" ++ show (newLab + 1) ++ suffix
                mov1 =
                    [AControl (ALab s1)] ++
                    map
                        (\(s, t) ->
                             case s of
                                 APtr _ -> AAsm [t] ANop [ALoc s]
                                 _ -> AAsm [t] ANopq [ALoc s])
                        (zip p1 t1) ++
                    [AControl (AJump l1)]
                mov2 =
                    [AControl (ALab s2)] ++
                    map
                        (\(s, t) ->
                             case s of
                                 APtr _ -> AAsm [t] ANop [ALoc s]
                                 _ -> AAsm [t] ANopq [ALoc s])
                        (zip p2 t2) ++
                    [AControl (AJump l2)]
                deblk = [AControl (ACJump' op a b s1 s2)] ++ mov1 ++ mov2
             in deBlock xs lMap (newLab + 2) suffix (deblk : aasm)
        _ -> deBlock xs lMap newLab suffix ([x] : aasm)

deSSA :: Block -> Map.Map Ident [ALoc] -> [AAsm]
deSSA blk lMap =
    tail $ concatMap (\(lab, _, aasms) -> (AControl $ ALab lab) : concat (deBlock aasms lMap 0 ("_" ++ lab) [])) blk