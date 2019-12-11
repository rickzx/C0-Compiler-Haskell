# L6 overview

In L6, we modified our L4 compiler to support string libraray and functions, polymorphic struct and polymorphic functions. Furthermore, we implemented function pointers so that our functions are 
able to take in functions as parameters. Check `./tests/l6-tests` for example test programs related to L6.

## Overall Workflow

**C0 Code** ---Lexer/Parser---> **AST** ---Elaboration---> **EAST** 
---TypeChecking & Optimization--> **EAST** ---Translation---> **Abstract Assembly**
---Live Analysis & Register Allocation---> **Assembly** ---CodeGen---> **x86-64**

## Overall Code Structure

```
.
├── Args.hs     Parse arguments (Add in -l option for l3)
├── Compile
│   ├── Backend
│   │   ├── AAsm2Asm.hs     Convert abstract assembly to x86-64 assembly
│   │   ├── EAST2AAsm.hs    Convert elaborated AST to abstract assembly
│   │   ├── LiveVariable.hs     Conduct live analysis
│   │   └── RegisterAlloc.hs    Register allocation
│   ├── CodeGen.hs      Entry point for abstract assembly/x86-64 code generation
│   ├── Frontend
│   │   ├── CheckEAST.hs        Type-checker
│   │   ├── EASTOptimize.hs     Optimizations on elaborated AST
│   │   └── Elaborate.hs        Elaboration
│   ├── Lex.hs
│   ├── Lex.x       Lexer
│   ├── Parse.hs
│   ├── Parse.y     Parser
│   ├── Types
│   │   ├── AST.hs
│   │   ├── AbstractAssembly.hs
│   │   ├── Assembly.hs
│   │   ├── EAST.hs         Elaborated AST Type
│   │   ├── Header.hs       Type for the header file
│   │   ├── Job.hs
│   │   └── Ops.hs
│   └── Types.hs
├── Compile.hs      Compile code with various options
├── LiftIOE.hs
├── Util.hs
└── c0c.hs      Entry point of the compiler
```

## Lexing and Parsing

For Lexing, we added the regular expressions to pattern match strings and characters, 
furthermore, we lexed the generic type by single letters preceeded by a ', to distinguish 
them from regular idents.

For Parsing, we added the Char and String type, and we introduced the generic type functions 
and structs as follows:

```
    < GenericTypelist > struct ident block;
    < GenericTypelist > retType ident (paramlist) block;
```

We added type POLY for generic types and GENSTRUCT for generic structs.
Finally, we added function pointer types, which is represented and called as follows:

```
    (paramlist -> return_type)* f, paramlist = () if no args for function.
    <*f>(arguments) -- call function represented by pointer f
```

Example Polymorphic Struct:

```
<'k, 'v> struct node {
    'k key;
    'v value;
}
```

Example Polymorphic Function:

```
<'a, 'b> 'a fst('a x, 'b y) {
    return x;
}
```

Example Function Pointer:

```
<'a, 'b> bool eq('a x, 'b y, ('a, 'b -> int)* cmp) {
    if (<*cmp>(x, y) == 0) {
        return true;
    }
    return false;
}

int int_cmp(int x, int y) {
    return x - y;
}

// return 0
int main() {
    if (eq(0, 1, &int_cmp)) {
        return 1;
    }
    return 0;
}
```

## Elaboraton

We modified our IR structure EAST by adding following nodes:

```
EAST:
    | EGDef [Type] Ident Type EAST -- define generic fucntion
    | EGSDef [Type] Ident [(Ident, Type)] EAST -- define generic struct
    | EGDecl [Type] Ident Type EAST -- Generic function declare
EExp:
    | EChar Int
    | EString Ident
    | ERefFun Ident
    | ERefFunAp Ident [EExp]
```
Character is represented by the corresponding ascii integer, 1 byte, String is 
represented by itself. The extra list of types after EGDef, EGSDef, and EGSDecl
are for the generic types used in the function/struct.



## Typechecking
During the typechecking phase, we collect the parameter types for all run-time calls to polymorphic functions, and substitute the poly types with concrete types.

However, after substituting in the concrete types, the new concrete function might induce more calls to polymoprhic functions. Therefore, we 
repeat this process until no fresh concrete functions are created.

## EAST -> Abstract Assembly

Translating to 3 address form, we added in char and string types and their corresponding
sizes (1 and 8) when calculating memory. We also saved a map of constant strings to
an index during translate for assembly generation.

We added the following types:
```
    AAsm -> ACallRef ALoc [ALoc] Int -- for calling functions from function pointers
    AVal -> AFunPtr String
            AStr String
    ALoc -> APtrb ALoc -- for characters
```


## Liveness and interference graph

We added the corresponding liveness and interference calculation for ACallRef nodes

## Abstract Assembly -> Assembly

### Define Assembly

For L6 compiler, we added the following instances and operands:

```
data  Inst
= Movb Operand Operand
  Cmpb Operand Operand

data Operand
    = Str Int
      FPtr String
```

Where the int in Str is the constant string index that maps to the string, which we get 
from the map when doing 3 address form.

For Strings, we added in a .DATA section to store all the constant strings 
similar to cc0:

```
    .DATA
	    str0: .string "aa"
```
And Movq $str0 Operand move the costant string to the operand.

Function pointers are created using the following template

```
    leaq fun_name(%rip), %rax       // now %rax holds the function address
    call *%rax                      // call function fun_name
```