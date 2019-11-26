module Compile.Frontend.EASTOptimize where

import Compile.Types
import Data.Bits

optTAST :: TAST -> TAST
optTAST east = case east of
    TSeq et1 et2 -> TSeq (optTAST et1) (optTAST et2)
    TAssign x e b -> TAssign x (constantFold e) b
    TPtrAssign x a e -> TPtrAssign x a (constantFold e)
    TIf e et1 et2 -> TIf (constantFold e) (optTAST et1) (optTAST et2)
    TWhile e et -> TWhile (constantFold e) (optTAST et)
    TRet e -> TRet (fmap constantFold e)
    TNop -> east
    TDecl x t et -> TDecl x t (optTAST et)
    TLeaf e -> TLeaf (constantFold e)
    TAssert e -> TAssert (constantFold e)
    TDef idd tp et -> TDef idd tp (optTAST et)
    TSDef idd l et -> TSDef idd l (optTAST et)

--Eliminate simple operations with constants only on our IR tree.
constantFold :: TExp -> TExp
constantFold (TBinop Add e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (x + y)
            _ -> TBinop Add fold1 fold2
constantFold (TBinop Sub e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (x - y)
            _ -> TBinop Sub fold1 fold2
constantFold (TBinop Mul e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (x * y)
            _ -> TBinop Mul fold1 fold2
constantFold (TBinop BAnd e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (x .&. y)
            _ -> TBinop BAnd fold1 fold2
constantFold (TBinop BOr e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (x .|. y)
            _ -> TBinop BOr fold1 fold2
constantFold (TBinop Xor e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> TInt (xor x y)
            _ -> TBinop Xor fold1 fold2
constantFold (TBinop LAnd e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TF, _) -> TF
            (TT, _) -> fold2
            (_, TT) -> fold1
            _ -> TBinop LAnd fold1 fold2
constantFold (TBinop LOr e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TT, _) -> TT
            (TF, _) -> fold2
            (_, TF) -> fold1
            _ -> TBinop LOr fold1 fold2
constantFold (TBinop Lt e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x < y then TT else TF
            _ -> TBinop Lt fold1 fold2
constantFold (TBinop Le e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x <= y then TT else TF
            _ -> TBinop Le fold1 fold2
constantFold (TBinop Gt e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x > y then TT else TF
            _ -> TBinop Gt fold1 fold2
constantFold (TBinop Ge e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x >= y then TT else TF
            _ -> TBinop Ge fold1 fold2
constantFold (TBinop Eql e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x == y then TT else TF
            _ -> TBinop Eql fold1 fold2
constantFold (TBinop Neq e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (TInt x, TInt y) -> if x /= y then TT else TF
            _ -> TBinop Neq fold1 fold2
constantFold expr = expr