module Compile.Frontend.EASTOptimize where

import Compile.Types
import Data.Bits

optEAST :: EAST -> EAST
optEAST east = case east of
    ESeq et1 et2 -> ESeq (optEAST et1) (optEAST et2)
    EAssign x e b -> EAssign x (constantFold e) b
    EIf e et1 et2 -> EIf (constantFold e) (optEAST et1) (optEAST et2)
    EWhile e et -> EWhile (constantFold e) (optEAST et)
    ERet e -> ERet (fmap constantFold e)
    ENop -> east
    EDecl x t et -> EDecl x t (optEAST et)
    ELeaf e -> ELeaf (constantFold e)
    EAssert e -> EAssert (constantFold e)
    EDef id tp et -> EDef id tp (optEAST et)

constantFold :: EExp -> EExp
constantFold (EBinop Add e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (x + y)
            _ -> EBinop Add fold1 fold2
constantFold (EBinop Sub e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (x - y)
            _ -> EBinop Sub fold1 fold2
constantFold (EBinop Mul e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (x * y)
            _ -> EBinop Mul fold1 fold2
constantFold (EBinop BAnd e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (x .&. y)
            _ -> EBinop BAnd fold1 fold2
constantFold (EBinop BOr e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (x .|. y)
            _ -> EBinop BOr fold1 fold2
constantFold (EBinop Xor e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> EInt (xor x y)
            _ -> EBinop Xor fold1 fold2
constantFold (EBinop LAnd e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EF, _) -> EF
            _ -> EBinop LAnd fold1 fold2
constantFold (EBinop LOr e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (ET, _) -> ET
            _ -> EBinop LOr fold1 fold2
constantFold (EBinop Lt e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x < y then ET else EF
            _ -> EBinop Lt fold1 fold2
constantFold (EBinop Le e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x <= y then ET else EF
            _ -> EBinop Le fold1 fold2
constantFold (EBinop Gt e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x > y then ET else EF
            _ -> EBinop Gt fold1 fold2
constantFold (EBinop Ge e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x >= y then ET else EF
            _ -> EBinop Ge fold1 fold2
constantFold (EBinop Eql e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x == y then ET else EF
            _ -> EBinop Eql fold1 fold2
constantFold (EBinop Neq e1 e2) = let
        fold1 = constantFold e1
        fold2 = constantFold e2
    in
        case (fold1, fold2) of
            (EInt x, EInt y) -> if x /= y then ET else EF
            _ -> EBinop Neq fold1 fold2
constantFold expr = expr