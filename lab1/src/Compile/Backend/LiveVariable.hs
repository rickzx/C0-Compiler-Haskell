module Compile.Backend.LiveVariable(getLoc, reverseAAsm, computeLivelist) where 

    import Data.List
    
    import Compile.Types
    
    --given a list of AVal, we just care about the temps, not the
    --constants.
    getLoc :: [AVal] -> [ALoc]
    getLoc [] = []
    getLoc (x:rest) = case x of
        ALoc a -> a : getLoc rest
        _ -> getLoc rest
    
    --reverse the abstract assembly, so that we can work backwards for live variables
    --Stop at first return statment seen
    reverseAAsm :: [AAsm] -> [AAsm] -> [AAsm]
    reverseAAsm acc [] = error "the AAsm has no return statement"
    reverseAAsm acc (x:rest) = case x of
        ARet _ -> x:acc
        _ -> reverseAAsm (x:acc) rest
    
    --compute live list for a straight line of code
    --TODO: 
    {-for if else statement and loop, do a general tree stucture
        of the code by breaking control into segments, for each segment, 
        we do the single line livelist computes-}
        
    computeLivelist :: ([[ALoc]], [AAsm]) -> ([[ALoc]], [AAsm])
    computeLivelist (accum, []) = (accum, [])
    computeLivelist (accum, x:ast) = 
    --first line of AAsm should always be a return statement, working backwards
      case x of
        ARet retval -> case retval of
            ALoc a -> computeLivelist([[a]], ast)
            AImm _ -> computeLivelist([[]], ast)
        AComment _ -> computeLivelist(accum, ast)
        AAsm {aAssign = assign, aOp = op, aArgs = args} -> case accum of
            --this should not happen
            [] -> error "The last statement of AAsm is not return"
            y : rest -> let
                relev = getLoc args
                current_live = ((y \\ assign) ++ (relev \\ y)) in
                computeLivelist(current_live:accum, ast)
    
    testAASM :: [AAsm]
    testAASM = [AAsm{aAssign = [AReg 0], aOp = AAdd, aArgs = [AImm 5, AImm 7]}, AAsm{aAssign = [AReg 1], aOp = AAdd, aArgs = [AImm 3, AImm 5]}, AAsm{aAssign = [AReg 2], aOp = AAdd, aArgs = [ALoc (AReg 0), ALoc(AReg 1)]}, ARet (ALoc(AReg 2))]
    
    test1 :: IO ()
    test1 = print (computeLivelist([], reverseAAsm [] testAASM))