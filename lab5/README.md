# Design Decisions for L5

In L5 we modified our L4 compiler so that it will compile codes that will run more efficiently than before. Specifically, we looked into peephole strength reduction, tail recursive function call, function inlining, constant propagation, and SSA based optimizations(sparse conditional constant folding, deadcode removal, register allocation, and coalescing)

Furthermore, we added the flags --unsafe and -O1 to our compiler.

## Unsafe
    With flag --unsafe, we do not consider any safety checks in the program (array access, shift, etc.), this is similarly to C's actual behavior.
    
## -O1
    With -O1, we will aggressively use all the optimizations implemented, this will increase the runtime speed, with the expense of increasing the compile time of programs due to doing more passes at compile time.

## Overall Workflow of Compiler

**C0 Code** ---Lexer/Parser---> **AST** ---Elaboration---> **EAST** ---TypeChecking--> **TAST** ---Translation---> **Abstract Assembly** ---SSA Transform ---> **SSA** ---> Live Analysis & Register Allocation---> **Assembly** ---CodeGen---> **x86-64**

## Optimizations Done:
```
TAST -> Abstract Assembly: 
    1. Constant propagation on TAST
    2. Peephole optimization on Strength Reduction
    3. Tail Recursion
Abstract Assembly -> SSA:
    4. Function Inlining
SSA: 
    5. SCC (Sparse conditional constant folding) with Deadcode removal
    6. Liveness Analysis 
    7. Register Coalescing
SSA -> Assembly:
    8. Redundant Code Removal
```

### 1. Constant Propagation
    On our IR before transforming to Abstract Assembly, we did our first round of constant propagation, simiplifying binop statements that only has integer as operands.

    ex: TAssign x (Binop Add (Int 1) (Int 2)) will instead be shown as 
        TAssign x (Int 3) on our IR

### 2. Peephole optimization on Strength Reduction
    On our Abstract Assembly, we changed the instructions for arithmetic instructions to cheaper ones, such as adding 0, subtracting 0, and multiplying powers of 2(into shifts)

### 3. Tail Recursion
    In our Abstract Assmebly, we mark all the tail recusive functions and functions that can 
    be implemented in a tail recursively with a accumulator 
        Ex: functions f return a * f()  
    Rather than calling these functions upon return, we turn such functions into a loop and we jump back to the beginning of the function. For functions that require an accumulator to store the result, we uses R12 as the accumulator, and add to RAX upon final return.

### 4. Function Inlining
    After finish converting all the abstract assembly, we do another scan, particularily search for small functions that we can pull its body inside the larger functions that calls the function instead to save the calling convention and jumps. 

### 5a. Sparse Conditional Constant Propagation
    On our SSA, we conduct SCC, in the process we mark all the blocks that can be executed in the program, and all the variables with constant values. We then replace these variables with the corresponding constants in their corresponding uses in the statement.

### 5b. Deadcode Removal
    Pairing with SCC, we remove all the statements defining the constant variables, and all the unreachable blocks in our run. 

### 6. Liveness Analysis
### 7. Register Coalescing
### 8. Remove Redundant Code
    In our final Assembly, we do another scan to remove the redundant moves that we are not able to eliminate before. Particularly, instructions in the form
        Mov op1 op1 (We remove it)
    and 
        Jmp l. (We remove the jump)
        Label l.