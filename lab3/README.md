# Design Decisions for L3

In L3, we modified our L2 compiler so that it will handle codes involving function calls, codes with typedefs, as well as typecheck codes that include a header file to our new language as specified in the steps below.

## Overall Workflow

**C0 Code** ---Lexer/Parser---> **AST** ---Elaboration---> **EAST** ---TypeChecking & Optimization--> **EAST** ---Translation---> **Abstract Assembly** ---Live Analysis & Register Allocation---> **Assembly** ---CodeGen---> **x86-64**

## Overall Code Structure

```
.
├── Args.hs     Parse arguments (Add in -l option for l3)
├── Compile
│   ├── Backend
│   │   ├── AAsm2Asm.hs     Convert abstract assembly to x86-64 assembly
│   │   ├── EAST2AAsm.hs    Convert elaborated AST to abstract assembly
│   │   ├── LiveVariable.hs     Conduct live analysis
│   │   └── RegisterAlloc.hs    Register allocation
│   ├── CodeGen.hs      Entry point for abstract assembly/x86-64 code generation
│   ├── Frontend
│   │   ├── CheckEAST.hs        Type-checker
│   │   ├── EASTOptimize.hs     Optimizations on elaborated AST
│   │   └── Elaborate.hs        Elaboration
│   ├── Lex.hs
│   ├── Lex.x       Lexer
│   ├── Parse.hs
│   ├── Parse.y     Parser
│   ├── Types
│   │   ├── AST.hs
│   │   ├── AbstractAssembly.hs
│   │   ├── Assembly.hs
│   │   ├── EAST.hs         Elaborated AST Type
│   │   ├── Header.hs       Type for the header file
│   │   ├── Job.hs
│   │   └── Ops.hs
│   └── Types.hs
├── Compile.hs      Compile code with various options
├── LiftIOE.hs
├── Util.hs
└── c0c.hs      Entry point of the compiler
```

## Lexing and Parsing

For Lexing, we added the tokens used in our new language that represents typdefs and assert. We also added the void type for for functions returning void.

For Parsing, we have changed our language to the specification for L3 as specified in lab handout. We parsed each file into a list of function definintions, declarations, and typedefs, and included corresponding types in our AST. We also included return nothing type and assert in our old parser for control flow.

## Elaboraton

We modified our IR structure EAST by first adding node type that represents function call as specified below:

```
data EAST 
    = ESeq EAST EAST
    | EAssign Ident EExp Bool
    | EDef Ident Type EAST
    | EIf EExp EAST EAST
    | EWhile EExp EAST
    | EAssert EExp
    | ERet (Maybe.Maybe EExp)
    | ENop
    | EDecl Ident Type EAST
    | ELeaf EExp
```
We modified EAssign to have a Bool flag behind it to distinguish Justdecl and DeclAsgn in our EAST, which has True as flag if it is a part of the DeclAsgn flag. Also, we changed ERet to have a Maybe type, since it can have nothing for void returns.

We added EAssert Node accordingly, and an EDef node to distinguish function declaration. In our EDef, we modified the function type into:
```
ARROW [(ParamName, ParamType)] Return Type
```
For expressions, we also included function call as listed below:
```
data EExp
    = EInt Int
    | ET
    | EF
    | EIdent Ident
    | EBinop Binop EExp EExp
    | ETernop EExp EExp EExp
    | EUnop Unop EExp
    | EFunc Ident [EExp]
    deriving Eq
```
Where for EFunc, we have it followed by the function name and the variables for parameter.

When performing elaboration, we first elaborated on the AST generated on the headerfiles, putting all the function definitions and typedefs in Maps in a state monad. Then, we performed a similar elaboration for the main file. During our elaboration, we changed the types from typedefs accordingly, so that each type we get from a typedef are all converted to the primitive types it is corresponding to from the typedef map in each state. 

With the Maps generated in the mutable state for both header and main file, we are also able to conduct part of typechecking in elaboration, such as multiple declarations of the same function needs have the same type. We will discuss more
of typechecking in the section below.

## Typechecking

Typechecking consists of three parts:

**Static Type Checking**: Check that the static semantics of statements and expressions are satisfied. This is done by maintaining a typing context, and recursively check that the static semantics are met. If typing violations are found, the compiler will raise `Tycon mismatch`.

**Proper Return Checking**: Check that all finite control flow paths through the program starting at the beginning of each function, end with an explicit `return` statement. If violations are found, the compiler will raise `Main does not return`.

**Checking Variable Initialization**: Check that along all control flow paths, any variable is defined before use. This is done by maintaing a set of declared variables and a set of defined variables of a scope.  If violations are found, the compiler will raise `Variable used before initialization`.

**Function Call Checking**: Check that the arguments of function calls match with the type of function declaration, and that the return type is correct.

**Shadowing**: If a string is first used as a function name, then declared as a variable name. We need to make sure that the variable shadows the function declaration. For example:
```
int f() {
    int f = 5;
    return f;
}
```
is valid, and should return 5.
## Constant Folding Optimizations
After Typechecking, we went through another iteration of our EAST to simplify statements that only contains constants. Specifically, when a binop expression having only constants, we simplify the binop expression by evaluating it directly. Also, when generating abstract assemblies, instead of assigning temps to all constants in each operation, we use AImm instead to reduce the number for temps for our file.

## EAST -> Abstract Assembly

We follow the dynamic semantics in (http://www.cs.cmu.edu/afs/cs/academic/class/15411-f19/www/lec/09b-irtrees.pdf).

We use the `State` monad to keep track of the fresh variables, labels, and the current function we are generating's name.

```
data Alloc =
    Alloc
        { variables :: Map.Map String Int
    -- ^ Map from source variable names to unique variable ids.
        , uniqueIDCounter :: Int
    -- ^ Value greater than any id in the map.
        , uniqueLabelCounter :: Int
    -- ^ Next label to generate.
        , genFunctions :: [(Ident, ([AAsm], Int))]
    -- ^ generated AASM for each function (funcname, (AASM, #vars used))
        , currentFunction :: String
    -- ^ current function we are in
        }
```

We define several types of abstract assembly constructors to handle Function Calls:

```
  | AFun ALabel [ALoc]      -- Here, [ALoc] only contains the arguments that should be placed on the stack, if any
  | ACall ALabel [ALoc] Int -- Here, [ALoc] only contains the arguments that should be placed on the stack, if any,
                            -- The Int in the end represents the number of args the function call has.
```
For functions with sideeffects, such as having arguments that is just not a constant or variable, we generate the 
evaluations for such arguments first before the function call. We also concated _c0_ in front of any non external functions. For defined abort functions in the l3 file as a special case, we changed its name to _c0_abort411 since _c0_abort is a function in our run411.c library.

## Liveness and interference graph
For liveness analysis, we considered each function definition and computed interference graph and assigned registers for them separately, since each function will have their own separate stack frame. 

For liveness, when a function is called, we made every argument register(rdi, rsi, ..etc), rax, and the caller saved registers in the defined set to make sure they all interfere with the variables used after the call. We need to do this for recursive calls, so that none of the values needed after the recursive function call is modified in our recursive function call.

We add the actual register and additional temps used as argument parameters into the used set. We consider the function call separately, thus the successor is the line followed by the function call.

When calculating interference, for functions, we perform the similar operations as L2 for all elements in defset, however, we do need to make sure that in a function definition and function call(the first line of the function), all the additional variables in the stack are defined in this line and interfere with the line succeeding the function.

## Abstract Assembly -> Assembly

### Define Assembly

For L3 compiler, we add in `Fun` and `Call` to handle function procedures.

```
data  Inst
= Movl Operand Operand
| Movabsq Int Operand
| Addl Operand Operand
| Subl Operand Operand
| Imull Operand Operand
| Idivl Operand
| Sall Int Operand
| Sarl Int Operand
| Negl Operand
| Pushq Operand
| Popq Operand
| Cdq
| Cqto
| Ret
| Andl Operand Operand
| Orl Operand Operand
| Xorl Operand Operand
| Notl Operand
| Label String
| Cmp Operand Operand
| Jmp String
| Je String
| Call String
| Fun String
...

data  Operand
= Imm Int
| Reg Register
| Mem
    { imm ::  Int
    , base ::  Register
    , index ::  Register
    , width ::  Int
    }
| Mem'
    { imm ::  Int
    , base ::  Register
    } deriving (Eq, Ord)

data  Register -- 16 64-bit registers & 16 32-bit registers
```

From the data type definition, we know that an operand is either an Immediate, a Register, or some data stored in a memory location. We can refer to an address in memory using `Mem{imm, base, idx, w} = $imm(%base, %idx, w)` or using `Mem'{imm, base} = $imm(%base)`.

We decide to include both 64-bit and 32-bit registers, and define a function `toReg64` to convert a 32-bit register to a 64-bit register.

The code generation from abstract assembly to assembly is based on pattern-matching on abstract assembly. There are some special cases to consider:

- We reserve register `%R11 / %R11D` for moves to and from the stack when necessary. For example, the abstract assembly `16(%RSP) <- 8(%RSP) + $5` may be translated to a sequence `[movq 8(%RSP) %R11, addq $5 %R11, movq R11 16(%RSP)]`.

- For `Idiv / Imod`, we need to reserve `%RAX` and `RDX` for this special use case. Since we have already made `%RAX` and `RDX` interfere with the operands, and precolored `%RAX` and `RDX` with the desired registers, we are sure that moving operands into `%RAX` and `RDX` is safe.

- Similarly, for `Sall / Sarl`, we need to reserve `RCX` for the special use case.

To make the generated x86 assembly more compact, the compiler will

- Remove trivial instructions, e.g. `Movq %RAX %RAX`
- Remove unreachable code blocks

For the functions defined in header, we call the function with its name in the declaration. For the functions defined in the main file, we call the function with an additional prefix "_c0\_".

### Calling Convention

#### Stack Diagram

```
arg8
__________
arg7
__________
return address
__________
%RBP        <--- %RBP
__________
Saved Callee 1
__________
Saved Callee 2      Function Frame
__________

Local Vars

__________  <--- %RSP
```
