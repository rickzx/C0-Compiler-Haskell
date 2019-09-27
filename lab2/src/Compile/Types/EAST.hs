{- Defines the Elaborated AST after the elaboration process
-}

module Compile.Types.EAST where

import Compile.Types.AST
import Compile.Types.Ops

data Type
    = Integer
    | Boolean deriving (Eq, Show)

data EAST 
    = ESeq EAST EAST
    | EAssign Ident EExp
    | EIf EExp EAST EAST
    | EWhile EExp EAST
    | ERet EExp
    | ENop
    | EDecl Ident Type EAST
    | ELeaf EExp

data EExp
    = EInt Int
    | EIdent Ident
    | EBinop Binop EExp EExp
    | ETernop EExp EExp EExp
    | EUnop Unop EExp
    deriving Eq

--generate our intermediate ast structure
eGen :: AST -> EAST
eGen (Block stmts) = eBlock stmts

eBlock :: [Stmt] -> EAST
eBlock [] = error "Block should not be empty"
eBlock [x] = eStmt x
--give declare precedence
eBlock (x:l) = case x of 
    ControlStmt (Retn r) -> ERet (ELeaf r)
    Simp (Decl d) -> case d of 
        JustDecl var tp -> EDecl var tp (eBlock l)
        DeclAsgn var tp expr -> EDecl var tp (ESeq (EAssign var (ELeaf expr)) (eBlock l))
    _ -> ESeq (eStmt x) (eBlock l)

eStmt :: Stmt -> EAST
eStmt x = case x of 
    Simp s -> eSimp s
    Stmts b -> eBlock b
    ControlStmt c -> case c of 
        Condition b t el -> EIf (ELeaf b) (eStmt t) (eElse el)
        --declaration still need to be prioritized
        For initr condi stepi bodyi -> case initr of
            Opt (Decl (JustDecl var tp)) -> error "cant just declare in a loop"
            Opt (Decl (DeclAsgn var tp expr)) -> EDecl var tp (ESeq (EAssign var (ELeaf expr))
                (EWhile (ELeaf condi) (ESeq (eStmt bodyi) (eSimpopt stepi))))
            _ -> ESeq (eSimpopt initr) (EWhile (ELeaf condi) (ESeq (eStmt bodyi) 
                (eSimpopt stepi)))
        While condi bodyi -> EWhile (ELeaf condi) (eStmt bodyi)
        Retn ret -> ERet (ELeaf ret)

eSimp :: Simp -> EAST
eSimp simp = case simp of
    Asgn i asop expr -> let
        expression = case asop of 
            Equal -> ELeaf expr
            AsnOp b -> ELeaf (Binop b (Ident i) expr)
        in EAssign i expression
    AsgnP i pos -> if pos == Incr then EAssign i (ELeaf(Binop Add (Ident i) (Int 1)))
        else EAssign i (ELeaf(Binop Sub(Ident i) (Int 1)))
    Decl d -> case d of 
        JustDecl var tp -> EDecl var tp ENop
        DeclAsgn var tp expr -> EDecl var tp (EAssign var (ELeaf expr))
    Exp expr -> ELeaf expr

eSimpopt :: Simpopt -> EAST
eSimpopt sopt = case sopt of
    SimpNop -> ENop
    Opt s -> eSimp s

eElse :: Elseopt -> EAST
eElse eopt = case eopt of
    ElseNop -> ENop
    Else stmt -> eStmt stmt

instance Show EAST where
    show (ESeq e1 e2) = show "ESeq" ++ "(" ++ show e1 ++ " , "  ++ show e2 ++ ")"
    show (EAssign ident leaf) = show "EAssign" ++ "(" ++ ident ++ " , " ++ show leaf ++ ")"
    show (EIf leaf e1 e2) = show "Eif" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ " , " ++ show e2 ++ ")"
    show (EWhile leaf e1) = show "EWhile" ++ "(" ++ show leaf ++ " , " ++ show e1 ++ ")"
    show (ERet leaf) = show "ERet" ++ "(" ++ show leaf ++ ")"
    show (ENop) = show "NOP"
    show (EDecl ident stype e1) = show "EDecl" ++ "(" ++ ident ++ "  ,  " ++ show stype ++ " , " ++ show e1 ++ ")"
    show (ELeaf e) = show e

--example from hw 1 with while loop and for loop
exAST :: AST
exAST = Block
    [   Simp (Decl $ DeclAsgn ("x") INTEGER (Int 7)),
        ControlStmt (While (Binop NotEq (Ident "x") (Int 5)) 
            (Stmts[
                Simp (Decl $ DeclAsgn ("z") INTEGER (Binop Mul (Ident "x") (Ident "x"))),
                Simp (Asgn ("y") (AsnOp Add) (Ident "z")),
                Simp (AsgnP ("x") (Decr))
                ])),
        ControlStmt (For {initial = (Opt (Decl $ DeclAsgn "w" INTEGER (Int 1))),
                cond = (Binop NotEq (Ident "w") (Int 5)), step = (Opt $ AsgnP ("w") (Incr)),
                body = (Simp (AsgnP ("y") (Incr)))}),
        ControlStmt (Retn (Ident "y"))
    ]

testEAST :: IO ()
testEAST = print $ eGen exAST
