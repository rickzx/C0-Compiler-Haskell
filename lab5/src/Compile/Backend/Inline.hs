module Compile.Backend.Inline where

import Compile.Types
import Control.Monad.State
import Data.Int
import Debug.Trace
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set

{-
    We do a separate pass to add in function inlining to the AASM for simple functions
-}
findAAsmMap :: [(Ident, ([AAsm], Int))] -> Map.Map Ident [AAsm]
findAAsmMap = foldr (\(id, (aasm, _)) fnmap -> Map.insert id aasm fnmap) Map.empty

-- inline :: ([(Ident, ([AAsm], Int))], Map.Map String String) -> 
--     Map.Map Ident [AAsm] -> 
--     ([(Ident, ([AAsm], Int))], Map.Map String String)
-- inline (l, trrec) fnmap = let
--         indexed = List.zip l [0..]
--     in
--         (map (\((id, (aasm, a)), index) -> (id, (mapinline aasm fnmap trrec index, a))) indexed,
--         trrec)

inline :: ([((Ident, ([AAsm], Int)), Int)], Map.Map String String, Map.Map Ident [AAsm])-> [((Ident, ([AAsm], Int)), Int)] -> 
    ([((Ident, ([AAsm], Int)), Int)], Map.Map String String, Map.Map Ident [AAsm])
inline ([], trec, fnmap) accum = (accum, trec, fnmap)
inline (((id, (aasm, a)), index):xs, trec, fnmap) accum = 
    if length aasm > 150 then inline (xs, trec, fnmap) (((id, (aasm, a)), index):accum) else
        let 
            processed = mapinline (id, aasm) fnmap trec index 1
            fnmap' = Map.insert id processed fnmap
            added = ((id, (processed, a)), index)
        in
            inline (xs, trec, fnmap') (added:accum)

--flag = we seen return in the basic block already
removeUseless :: Ident -> Int -> [AAsm] -> Bool -> [AAsm]
removeUseless fn idx [] _ = 
    let
        fname = if fn == "a bort" then "_c0_abort_local411" else "_c0_" ++ fn
        retlabel = fname ++ "_ret"
        newlabel = show idx ++ retlabel
    in
        [AControl(AJump newlabel)]
removeUseless fn idx (x:xs) flag= 
    let 
        fname = if fn == "a bort" then "_c0_abort_local411" else "_c0_" ++ fn
        startlabel = fname ++ "_start"
        retlabel = fname ++ "_ret"
    in
        case x of
            AFun _ _ -> removeUseless fn idx xs flag
            AControl (AJump s)
                | s == startlabel -> removeUseless fn idx xs flag
                | s == retlabel -> let
                        newlabel = show idx ++ retlabel
                    in
                        AControl(AJump newlabel):removeUseless fn idx xs True
                | s == "memerror" -> x:removeUseless fn idx xs True
                | otherwise -> let
                        newlabel = show idx ++ s
                    in
                        AControl(AJump newlabel):removeUseless fn idx xs False
            AControl (ALab s) -> 
                if s == startlabel then removeUseless fn idx xs flag
                else let
                        newlabel = show idx ++ s
                    in
                        AControl(ALab newlabel):removeUseless fn idx xs False
            AControl (ACJump a l1 l2) -> let
                    newlabel1 = if l1 == "memerror" then l1 else show idx ++ l1
                    newlabel2 = if l2 == "memerror" then l2 else show idx ++ l2
                in if flag then removeUseless fn idx xs flag else
                    AControl(ACJump a newlabel1 newlabel2):removeUseless fn idx xs flag
            AControl (ACJump' r a1 a2 l1 l2) -> let
                    newlabel1 = if l1 == "memerror" then l1 else show idx ++ l1
                    newlabel2 = if l2 == "memerror" then l2 else show idx ++ l2
                in if flag then removeUseless fn idx xs flag else
                    AControl(ACJump' r a1 a2 newlabel1 newlabel2):removeUseless fn idx xs flag
            _ -> if flag then removeUseless fn idx xs flag else x:removeUseless fn idx xs flag

--(AAsm before, map fn -> translated, Map fn-> recursive or not, Count for generating label) 
mapinline :: (Ident, [AAsm]) -> Map.Map Ident [AAsm] -> Map.Map String String -> Int -> Int -> [AAsm]
mapinline (_,[]) _fnmap _trrec _idx _cnt = []
mapinline (id, x:xs) fnmap trrec idx cnt = case x of
    ACall nme l _ ->
        let 
            fungen = Maybe.fromMaybe [] (Map.lookup nme fnmap)
            len = length fungen
        in
            if len == 0 || not(null l) then x : mapinline (id, xs) fnmap trrec idx cnt else
                case (len > 35, Map.lookup nme trrec) of
                    (_, Just a) 
                        | a == "MUL" || a == "ADD" || a == "REG" || a == id 
                            -> x : mapinline (id, xs) fnmap trrec idx cnt --recursions are too complicated for fn inline
                        | otherwise -> let
                            fname = if nme == "a bort" then "_c0_abort_local411" else "_c0_" ++ nme
                            retlabel = show idx ++ fname ++ "_ret"
                            in
                            removeUseless nme idx fungen False ++ 
                                [AControl $ ALab retlabel] ++ mapinline (id, xs) fnmap trrec (idx + cnt*99) (cnt+1)
                    (True, Nothing) -> x: mapinline (id, xs) fnmap trrec idx cnt-- Way too long
                    (False, Nothing) -> let
                            fname = if nme == "a bort" then "_c0_abort_local411" else "_c0_" ++ nme
                            retlabel = show idx ++ fname ++ "_ret"
                            in
                            removeUseless nme idx fungen False ++ 
                                [AControl $ ALab retlabel] ++ mapinline (id, xs) fnmap trrec (idx + cnt*99) (cnt+1) --replace fn call with fn body
    _ -> x : mapinline (id, xs) fnmap trrec idx cnt

inlineOpt :: ([(Ident, ([AAsm], Int))], Map.Map String String) -> ([(Ident, ([AAsm], Int))], Map.Map String String)
inlineOpt (fnlist, trmap) = if length fnlist > 99 then (fnlist, trmap) else let
            indexed = List.zip fnlist [0..]
            funmap = findAAsmMap fnlist
            (optimised, trlist, funmap') = inline (indexed, trmap, funmap) []
            useful = List.map(\(id, (aasm, c)) -> (id, 
                (Maybe.fromMaybe(error "this hsould not happen")(Map.lookup id funmap'), c))) fnlist
        in
            (useful, trlist)
        --We can now delete the aasm tree for those small functions as they will never be called
    --     useful = List.filter filter_fn optimised
    --         where 
    --             filter_fn (id, (aasm, _var)) = (id == "main") ||
    --                 case (Map.lookup id trmap, length aasm > 35) of
    --                     (Just _, _) -> True
    --                     (Nothing, True) -> True
    --                     _ -> False
    -- in
    --     (backtonorm, tr)

