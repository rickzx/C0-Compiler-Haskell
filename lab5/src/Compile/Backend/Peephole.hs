module Compile.Backend.Peephole where

import Compile.Types
import Control.Monad.State
import Data.Int
import Debug.Trace
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set

{-
    Optimize our compiler against specific, useless patterns to improve performance
-}

optTAST :: TAST -> TAST
optTAST tast = case tast of
    TSeq et1 et2 -> TSeq (optTAST et1) (optTAST et2)
    TAssign x e b -> TAssign x e b
    TPtrAssign x a e -> TPtrAssign x a e
    TIf e et1 et2 -> TIf e (optTAST et1) (optTAST et2)
    TWhile e et -> optLoop tast
    TRet e -> TRet e
    TNop -> tast
    TDecl x t et -> TDecl x t (optTAST et)
    TLeaf e -> TLeaf e
    TAssert e -> TAssert e
    TDef idd tp et -> TDef idd tp (optTAST et)
    TSDef idd l et -> TSDef idd l (optTAST et)

checksideEffect :: TExp ->  Bool
checksideEffect expr =
    case expr of 
        TInt _ -> True
        TT -> True
        TF -> True
        TNULL -> True
        TIdent nme _ -> True
        TBinop b exp1 exp2 -> b /= Div && b /= Mod && b /= Sal && b /= Sar
             && checksideEffect exp1 && checksideEffect exp2
        _ -> False

checkNormal :: Ident -> TExp -> Bool
checkNormal id expr = 
    case expr of 
        TInt _ -> True
        TT -> True
        TF -> True 
        TNULL -> True
        TIdent nme _ -> nme == id
        TBinop b exp1 exp2 -> checkNormal id exp1 && checkNormal id exp2
        TTernop exp1 exp2 exp3 -> checkNormal id exp1 && checkNormal id exp2 && checkNormal id exp3
        TUnop b exp1 -> checkNormal id exp1
        _ -> False

optLoop ::TAST -> TAST
optLoop t@(TWhile e et) = let
        (useless, tast', flag) = checkUseless (t, TNop, True)
    in
        if not flag then t else tast'
        where 
            checkUseless :: (TAST, TAST, Bool) -> (TAST, TAST,  Bool)
            checkUseless (t, accum, False) = (t, accum, False)
            checkUseless (t, accum, b) = case t of 
                TSeq t1 t2 -> let 
                    (_, accum1, u1) = checkUseless (t1, accum, b)
                    in
                        if not u1 then (t, accum, False) else let
                            (_, accum2, u2) = checkUseless (t2, accum, u1)
                            accum' = TSeq accum1 accum2
                        in
                            (t, accum', u2)
                TAssign ident exp b ->
                    if checksideEffect exp then 
                        case (b, checkNormal ident exp) of 
                            (True, _) -> TNop
                            (_, True) -> (t, accum, b)
                            _ -> (t, accum, False)
                    else (t, accum, False)
                _ -> (t, accum, False)
                
                        

    