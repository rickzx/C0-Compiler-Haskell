module Compile.Frontend.Elaborate where

import Compile.Types

--generate our intermediate ast structure
eGen :: AST -> EAST
eGen (Block stmts) = eBlock stmts

eBlock :: [Stmt] -> EAST
eBlock [] = ENop
eBlock [x] = eStmt x
--give declare precedence
eBlock (x:l) = case x of
    Simp (Decl d) -> case d of
        JustDecl var tp -> EDecl var tp (eBlock l)
        DeclAsgn var tp expr -> EDecl var tp (ESeq (EAssign var (pExp expr)) (eBlock l))
    _ -> ESeq (eStmt x) (eBlock l)

pExp :: Exp -> EExp
pExp (Int a) = EInt a
pExp T = ET
pExp F = EF
pExp (Ident id) = EIdent id
pExp (Binop b expr1 expr2) = EBinop b (pExp expr1) (pExp expr2)
pExp (Ternop expr1 expr2 expr3) = ETernop (pExp expr1) (pExp expr2) (pExp expr3)
pExp (Unop u expr1) = EUnop u (pExp expr1)

eStmt :: Stmt -> EAST
eStmt x = case x of
    Simp s -> eSimp s
    Stmts b -> eBlock b
    ControlStmt c -> case c of
        Condition b t el -> EIf (pExp b) (eStmt t) (eElse el)
        --declaration still need to be prioritized
        For _initr _condi (Opt (Decl _)) _bodyi -> error "Declaration not meaningful as step of for-loop"
        For initr condi stepi bodyi -> case initr of
            Opt (Decl (JustDecl var tp)) -> EDecl var tp (EWhile (pExp condi) (ESeq (eStmt bodyi) (eSimpopt stepi)))
            Opt (Decl (DeclAsgn var tp expr)) -> EDecl var tp (ESeq (EAssign var (pExp expr))
                (EWhile (pExp condi) (ESeq (eStmt bodyi) (eSimpopt stepi))))
            _ -> ESeq (eSimpopt initr) (EWhile (pExp condi) (ESeq (eStmt bodyi)
                (eSimpopt stepi)))
        While condi bodyi -> EWhile (pExp condi) (eStmt bodyi)
        Retn ret -> ERet (pExp ret)

eSimp :: Simp -> EAST
eSimp simp = case simp of
    Asgn i asop expr -> let
        expression = case asop of
            Equal -> pExp expr
            AsnOp b -> pExp (Binop b (Ident i) expr)
        in EAssign i expression
    AsgnP i pos -> if pos == Incr then EAssign i (pExp (Binop Add (Ident i) (Int 1)))
        else EAssign i (pExp (Binop Sub(Ident i) (Int 1)))
    Decl d -> case d of
        JustDecl var tp -> EDecl var tp ENop
        DeclAsgn var tp expr -> EDecl var tp (EAssign var (pExp expr))
    Exp expr -> ELeaf (pExp expr)

eSimpopt :: Simpopt -> EAST
eSimpopt sopt = case sopt of
    SimpNop -> ENop
    Opt s -> eSimp s

eElse :: Elseopt -> EAST
eElse eopt = case eopt of
    ElseNop -> ENop
    Else stmt -> eStmt stmt

--example from hw 1 with while loop and for loop
exAST :: AST
exAST =
  Block
    [ Simp (Decl $ DeclAsgn ("x") INTEGER (Int 7))
    , ControlStmt
        (While
           (Binop Neq (Ident "x") (Int 5))
           (Stmts
              [ Simp (Decl $ DeclAsgn ("z") INTEGER (Binop Mul (Ident "x") (Ident "x")))
              , Simp (Asgn ("y") (AsnOp Add) (Ident "z"))
              , Simp (AsgnP ("x") (Decr))
              ]))
    , ControlStmt
        (For
           { initial = Opt (Decl $ DeclAsgn "w" INTEGER (Int 1))
           , cond = Binop Neq (Ident "w") (Int 5)
           , step = Opt $ AsgnP ("w") (Incr)
           , body = Simp (AsgnP ("y") (Incr))
           })
    , ControlStmt (Retn (Ident "y"))
    ]
testEAST :: IO ()
testEAST = print $ eGen exAST