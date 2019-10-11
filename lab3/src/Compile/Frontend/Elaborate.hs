module Compile.Frontend.Elaborate where

import Compile.Types
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe

--map each function to (Arg type, return type).
type Fnmap = Map.Map Ident Type

--generate our intermediate ast structure
--(EAST, declared function map, defined function map)
eGen :: AST -> (EAST, Fnmap, Fnmap)
eGen (Program l) = let
    (_, funcdecl, funcdef, tpemap) = findFunc (l, Map.empty, Map.empty, Map.empty)
    in
    (eGdeclist l tpemap,  funcdecl, funcdef)

findFunc :: ([Gdecl], Fnmap, Fnmap, Fnmap) -> ([Gdecl], Fnmap, Fnmap, Fnmap)
findFunc ([], dec, def, tmap) = ([], dec, def, tmap)
findFunc (x:xs, dec, def, tmap) = case x of 
    Fdecl rtp nme param -> let types = extractParam param tmap in
            findFunc(xs, Map.insert nme (ARROW types (findtp tmap rtp)) dec, def, tmap)
    Fdefn rtp nme param blk -> let types = extractParam param tmap in
            findFunc(xs, Map.insert nme (ARROW types (findtp tmap rtp)) dec, Map.insert nme (ARROW types (findtp tmap rtp)) def, tmap)
    Typedef rtp nme -> findFunc(xs, dec, def, Map.insert nme rtp tmap)

--different case of decl, its function decl, we extract the
--types of parameters to make Fdecl to generate the function type
--else, if its typedef we just map the new type to its new name
--else, we use decl, and does the assign op to assign decl to the block
--TODO: change this to throw error instead of NONE
findtp :: Fnmap -> Type -> Type
findtp tmap (DEF str) = Maybe.fromMaybe NONE (Map.lookup str tmap)
findtp tmap tp = tp

--extract the parameter of the function
extractParam :: [(Type, Ident)] -> Fnmap -> [(Ident, Type)]
extractParam [] tmap = [("", VOID)]
extractParam l tmap = foldr f [] l
    where 
        f :: (Type, Ident) -> [(Ident, Type)] -> [(Ident, Type)]
        f (ty, name) curr = (name, findtp tmap ty): curr

eGdeclist :: [Gdecl] -> Fnmap -> EAST
eGdeclist [] _ = ENop --end of the file
eGdeclist (x:xs) tmap =
    case x of
        Fdecl rtp nme param -> EDecl nme (ARROW (extractParam param tmap) (findtp tmap rtp)) (eGdeclist xs tmap)
        Fdefn rtp nme param blk -> let
            typ =  ARROW (extractParam param tmap) (findtp tmap rtp) 
            in 
            EDecl nme typ (ESeq (EDef nme typ (eBlock blk tmap)) (eGdeclist xs tmap))
        Typedef rtp nme -> eGdeclist xs tmap --we handled typedef in findFunc already


eBlock :: [Stmt] -> Fnmap -> EAST
eBlock [] _ = ENop
eBlock [x] tmap = eStmt x tmap
--give declare precedence
eBlock (x:l) tmap = case x of
    Simp (Decl d) -> case d of
        JustDecl var tp -> EDecl var (findtp tmap tp) (eBlock l tmap)
        DeclAsgn var tp expr -> EDecl var (findtp tmap tp) (ESeq (EAssign var (pExp expr)) (eBlock l tmap))
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

eStmt :: Stmt -> Fnmap -> EAST
eStmt x tmap = case x of
    Simp s -> eSimp s tmap
    Stmts b -> eBlock b tmap
    ControlStmt c -> case c of
        Condition b t el -> EIf (pExp b) (eStmt t tmap) (eElse el tmap)
        --declaration still need to be prioritized
        For _initr _condi (Opt (Decl _)) _bodyi -> error "Declaration not meaningful as step of for-loop"
        For initr condi stepi bodyi -> case initr of
            Opt (Decl (JustDecl var tp)) -> EDecl var (findtp tmap tp) (EWhile (pExp condi) (ESeq (eStmt bodyi tmap) (eSimpopt stepi tmap)))
            Opt (Decl (DeclAsgn var tp expr)) -> EDecl var (findtp tmap tp) (ESeq (EAssign var (pExp expr))
                (EWhile (pExp condi) (ESeq (eStmt bodyi tmap) (eSimpopt stepi tmap))))
            _ -> ESeq (eSimpopt initr tmap) (EWhile (pExp condi) (ESeq (eStmt bodyi tmap)
                (eSimpopt stepi tmap)))
        While condi bodyi -> EWhile (pExp condi) (eStmt bodyi tmap)
        Assert condi -> EAssert (pExp condi)
        Retn ret -> ERet (Maybe.Just (pExp ret))
        Void -> ERet Maybe.Nothing

eSimp :: Simp -> Fnmap -> EAST
eSimp simp tmap = case simp of
    Asgn i asop expr -> let
        expression = case asop of
            Equal -> pExp expr
            AsnOp b -> pExp (Binop b (Ident i) expr)
        in EAssign i expression
    AsgnP i pos -> if pos == Incr then EAssign i (pExp (Binop Add (Ident i) (Int 1)))
        else EAssign i (pExp (Binop Sub(Ident i) (Int 1)))
    Decl d -> case d of
        JustDecl var tp -> EDecl var (findtp tmap tp) ENop
        DeclAsgn var tp expr -> EDecl var (findtp tmap tp) (EAssign var (pExp expr))
    Exp expr -> ELeaf (pExp expr)

eSimpopt :: Simpopt -> Fnmap -> EAST
eSimpopt sopt tmap = case sopt of
    SimpNop -> ENop
    Opt s -> eSimp s tmap

eElse :: Elseopt -> Fnmap -> EAST
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