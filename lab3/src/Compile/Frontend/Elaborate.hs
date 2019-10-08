module Compile.Frontend.Elaborate where

import Compile.Types
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe

type Typemap = Map.Map Ident Type

--map each function to its corresponding type, last type of the array is return type.
type Fnmap = Map.Map Ident [(Type, Ident)]

--generate our intermediate ast structure
--(EAST, declared function map, defined function map)
eGen :: AST -> (EAST, Fnmap, Fnmap)
eGen (Program l) = let
    (_, funcdecl, funcdef, tpemap) = findFunc (l, Map.empty, Map.empty, Map.empty)
    in
    (eGdeclist l tpemap,  funcdecl, funcdef)

findFunc :: ([Gdecl], Fnmap, Fnmap, Typemap) -> ([Gdecl], Fnmap, Fnmap, Typemap)
findFunc ([], dec, def, tmap) = ([], dec, def, tmap)
findFunc (x:xs, dec, def, tmap) = case x of
    Fdecl rtp nme param -> let types = extractParam param (rtp,nme) tmap in
            findFunc(xs, Map.insert nme types dec, def, tmap)
    Fdefn rtp nme param blk -> let types = extractParam param (rtp,nme) tmap in
            findFunc(xs, Map.insert nme types dec, Map.insert nme types def, tmap)
    Typedef rtp nme -> findFunc(xs, dec, def, Map.insert nme rtp tmap)

--different case of decl, its function decl, we extract the
--types of parameters to make Fdecl to generate the function type
--else, if its typedef we just map the new type to its new name
--else, we use decl, and does the assign op to assign decl to the block
--TODO: change this to throw error instead of NONE
findtp :: Typemap -> Type -> Type
findtp tmap (DEF str) = Maybe.fromMaybe NONE (Map.lookup str tmap)
findtp tmap tp = tp

extractParam :: [(Type, Ident)] -> (Type, Ident) -> Typemap -> [(Type, Ident)]
extractParam [] (t,n) tmap = [(VOID, ""), (findtp tmap t, n)]
extractParam l (t,n) tmap = foldr f [(findtp tmap t, n)] l
    where 
        f :: (Type, Ident) -> [(Type, Ident)] -> [(Type, Ident)]
        f (ty, name) curr = (findtp tmap ty, name): curr

eGdeclist :: [Gdecl] -> Typemap -> EAST
eGdeclist [] _ = ENop --end of the file
eGdeclist (x:xs) tmap = case x of
    Fdecl rtp nme param -> EDef nme (extractParam param (rtp,nme) tmap) (eGdeclist xs tmap)
    Fdefn rtp nme param blk -> EDef nme (extractParam param (rtp,nme) tmap)
        (ESeq (EAssign nme (eBlock blk tmap)) (eGdeclist xs tmap))
    Typedef rtp nme -> eGdeclist xs tmap --we handled typedef in findFunc already


eBlock :: [Stmt] -> Typemap -> EAST
eBlock [] _ = ENop
eBlock [x] tmap = eStmt x tmap
--give declare precedence
eBlock (x:l) tmap = case x of
    Simp (Decl d) -> case d of
        JustDecl var tp -> EDecl var (findtp tmap tp) (eBlock l tmap)
        DeclAsgn var tp expr -> EDecl var (findtp tmap tp) (ESeq (EAssign var (ELeaf $ pExp expr)) (eBlock l tmap))
    _ -> ESeq (eStmt x tmap) (eBlock l tmap)

pExp :: Exp -> EExp
pExp (Int a) = EInt a
pExp T = ET
pExp F = EF
pExp (Ident x) = EIdent x
pExp (Binop b expr1 expr2) = EBinop b (pExp expr1) (pExp expr2)
pExp (Ternop expr1 expr2 expr3) = ETernop (pExp expr1) (pExp expr2) (pExp expr3)
pExp (Unop u expr1) = EUnop u (pExp expr1)
pExp (Function id exprlist) = EFunc id (fmap pExp exprlist)

eStmt :: Stmt -> Typemap -> EAST
eStmt x tmap = case x of
    Simp s -> eSimp s tmap
    Stmts b -> eBlock b tmap
    ControlStmt c -> case c of
        Condition b t el -> EIf (pExp b) (eStmt t tmap) (eElse el tmap)
        --declaration still need to be prioritized
        For _initr _condi (Opt (Decl _)) _bodyi -> error "Declaration not meaningful as step of for-loop"
        For initr condi stepi bodyi -> case initr of
            Opt (Decl (JustDecl var tp)) -> EDecl var (findtp tmap tp) (EWhile (pExp condi) (ESeq (eStmt bodyi tmap) (eSimpopt stepi tmap)))
            Opt (Decl (DeclAsgn var tp expr)) -> EDecl var (findtp tmap tp) (ESeq (EAssign var (ELeaf $ pExp expr))
                (EWhile (pExp condi) (ESeq (eStmt bodyi tmap) (eSimpopt stepi tmap))))
            _ -> ESeq (eSimpopt initr tmap) (EWhile (pExp condi) (ESeq (eStmt bodyi tmap)
                (eSimpopt stepi tmap)))
        While condi bodyi -> EWhile (pExp condi) (eStmt bodyi tmap)
        Assert condi -> EAssert (pExp condi)
        Retn ret -> ERet (Maybe.Just (pExp ret))
        Void -> ERet Maybe.Nothing

eSimp :: Simp -> Typemap -> EAST
eSimp simp tmap = case simp of
    Asgn i asop expr -> let
        expression = case asop of
            Equal -> pExp expr
            AsnOp b -> pExp (Binop b (Ident i) expr)
        in EAssign i (ELeaf expression)
    AsgnP i pos -> if pos == Incr then EAssign i (ELeaf $ pExp (Binop Add (Ident i) (Int 1)))
        else EAssign i (ELeaf $ pExp (Binop Sub(Ident i) (Int 1)))
    Decl d -> case d of
        JustDecl var tp -> EDecl var (findtp tmap tp) ENop
        DeclAsgn var tp expr -> EDecl var (findtp tmap tp) (EAssign var (ELeaf $ pExp expr))
    Exp expr -> ELeaf (pExp expr)

eSimpopt :: Simpopt -> Typemap -> EAST
eSimpopt sopt tmap = case sopt of
    SimpNop -> ENop
    Opt s -> eSimp s tmap

eElse :: Elseopt -> Typemap -> EAST
eElse eopt tmap = case eopt of
    ElseNop -> ENop
    Else stmt -> eStmt stmt tmap

--compute the factorial of a number example.
exAST :: AST
exAST =
  Program
    [ 
        Typedef INTEGER "hh",
        Fdecl VOID "o98k" [(INTEGER, "n"), (DEF "hh", "j")],
        Fdefn (DEF "hh") "fact_spec" [(INTEGER, "n")] [
            ControlStmt (Condition (Binop Eql (Ident "n") (Int 0)) (ControlStmt $ Retn (Int 1))
                (Else $ ControlStmt $ Retn (Binop Mul (Ident "n") (Function "fast_spec" [(Binop Sub (Ident "n") (Int 1))] ))))
        ],
        Fdefn (DEF "hh") "factorial" [(INTEGER, "n")] [
            Simp $ Decl $ DeclAsgn "total" (DEF "hh") (Int 1),
            Simp $ Decl $ DeclAsgn "count" INTEGER (Int 0),
            ControlStmt $ While (Binop Lt (Ident "count" )(Ident "n")) (Stmts
            [
                Simp (AsgnP "count" Incr),
                Simp (Asgn "total" (AsnOp Mul) (Ident "count"))
            ]),
            ControlStmt $ Retn (Ident "total")
        ],
        Fdefn INTEGER "main" [] [
            ControlStmt $ For (Opt $ Decl (DeclAsgn "i" (DEF "hh") (Int 0))) (Binop Lt (Ident "i") (Int 10)) (Opt (AsgnP "i" Incr))
            (Stmts [
                Simp $ Exp $ Function "factorial" [Ident "i"]
            ]),
            ControlStmt $ Retn (Int 0)
        ]
    ]
testEAST :: IO ()
testEAST = 
    let
        (east, declmap, defmap) = eGen exAST
    in
        do{
            print east;
            print "____________________________________";
            print declmap;
            print "____________________________________";
            print defmap;
        }