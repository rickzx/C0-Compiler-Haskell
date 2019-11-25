module Compile.Backend.Peephole where

import Compile.Types
import Control.Monad.State
import Data.Int
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set
import Debug.Trace
import Debug.Trace
    {-
        Optimize our compiler against specific, useless patterns to improve performance
    -}

checksideEffect :: TExp -> Bool
checksideEffect expr =
    case expr of
        TInt _ -> True
        TT -> True
        TF -> True
        TNULL -> True
        TIdent nme _ -> True
        TBinop b exp1 exp2 ->
            b /= Div && b /= Mod && b /= Sal && b /= Sar && checksideEffect exp1 && checksideEffect exp2
        TUnop u expr1 -> checksideEffect expr1
        _ -> False

checkNormal :: Ident -> TLValue -> TExp -> Bool
checkNormal cntnme id expr =
    case id of
        TVIdent vname _ ->
            case expr of
                TInt _ -> True
                TT -> True
                TF -> True
                TNULL -> True
                TIdent nme _ -> vname == cntnme && nme == cntnme
                TBinop b exp1 exp2 -> checkNormal cntnme id exp1 && checkNormal cntnme id exp2
                TTernop exp1 exp2 exp3 ->
                    checkNormal cntnme id exp1 && checkNormal cntnme id exp2 && checkNormal cntnme id exp3
                TUnop b exp1 -> checkNormal cntnme id exp1
                _ -> False
        _ -> False

obtainCounterVar :: TExp -> Ident
obtainCounterVar exp =
    case exp of
        TIdent nme _ -> nme
        TBinop b exp1 exp2
            | b == Lt || b == Le || b == Ge || b == Gt ->
                case exp1 of
                    TIdent nme _ -> nme
                    _ -> "404" --Not found
            | otherwise -> "404"
        _ -> "404"

optLoop :: TAST -> TAST
optLoop tast =
    case tast of
        TSeq et1 et2 -> TSeq (optLoop et1) (optLoop et2)
        TAssign x e b -> TAssign x e b
        TPtrAssign x a e -> TPtrAssign x a e
        TIf e et1 et2 -> TIf e (optLoop et1) (optLoop et2)
        TRet e -> TRet e
        TNop -> tast
        TDecl x t et -> TDecl x t (optLoop et)
        TLeaf e -> TLeaf e
        TAssert e -> TAssert e
        TDef idd tp et -> TDef idd tp (optLoop et)
        TSDef idd l et -> TSDef idd l (optLoop et)
        TWhile e et ->
            let countervar = obtainCounterVar e
                (useless, tast', flag) =
                    if countervar /= "404"
                        then checkUseless countervar (et, TNop, True)
                        else (tast, TNop, False)
             in if not (checksideEffect e) || not flag
                    then TWhile e (optLoop et)
                    else tast'
            where checkUseless :: Ident -> (TAST, TAST, Bool) -> (TAST, TAST, Bool)
                  checkUseless nme (t, accum, False) = (t, accum, False)
                  checkUseless nme (t, accum, b) =
                      case t of
                          TSeq t1 t2 ->
                              let (_, accum1, u1) = checkUseless nme (t1, accum, b)
                               in if not u1
                                      then (t, accum, False)
                                      else let (_, accum2, u2) = checkUseless nme (t2, accum, u1)
                                               accum' = TSeq accum1 accum2
                                            in (t, accum', u2)
                          TAssign ident exp sflag ->
                              if checksideEffect exp
                                  then case (sflag, checkNormal nme ident exp) of
                                           (True, _) -> (t, TNop, True)
                                           (_, True) ->
                                               case ident of
                                                   TVIdent vn _ ->
                                                       if vn == nme
                                                           then (t, TNop, True)
                                                           else (t, t, True)
                                                   _ -> (t, t, True)
                                           _ -> (t, accum, False)
                                  else (t, accum, False)
                          TWhile exp t1 ->
                              if checksideEffect exp
                                  then let newnme = obtainCounterVar exp
                                           (_, accum1, u2) = checkUseless newnme (t1, accum, b)
                                        in (t, accum1, u2)
                                  else (t, accum, False)
                          TDecl id tp t1 ->
                              let (_, accum1, u1) = checkUseless nme (t1, accum, b)
                               in if not u1
                                      then (t, accum, False)
                                      else let accum' = TDecl id tp accum1
                                            in (t1, accum', u1)
                          TNop -> (t, TNop, True)
                          TLeaf exp1 ->
                              if checksideEffect exp1
                                  then (t, t, b)
                                  else (t, t, False)
                          _ -> (t, accum, False)

ex :: TAST
ex =
    TWhile
        (TBinop Le (TIdent "f3" INTEGER) (TInt 291))
        (TSeq
             (TAssign (TVIdent "b0" BOOLEAN) TT False)
             (TAssign (TVIdent "f3" INTEGER) (TBinop Add (TIdent "f3" INTEGER) (TInt 1)) False))

testLoop :: IO ()
testLoop = do
    let tast = optLoop ex
    print tast