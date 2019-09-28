module Try where 

import Data.List

test :: IO ()
test = let 
    a = zip [0..] [1,2,3,4,5] in
    print a