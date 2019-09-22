## Abstract Assembly -> Assembly

### Define Assembly

For L1 compiler, we define the following data type for x86-64 assembly, which is sufficient for generating result for straight-line code.

```
data  Inst
= Movq Operand Operand
| Movl Operand Operand
| Movabsq Int Operand
| Addq Operand Operand
| Addl Operand Operand
| Subq Operand Operand
| Subl Operand Operand
| Imulq Operand Operand
| Imull Operand Operand
| Idivq Operand
| Idivl Operand
| Salq Int Operand
| Sall Int Operand
| Sarq Int Operand
| Sarl Int Operand
| Negq Operand
| Negl Operand
| Pushq Operand
| Popq Operand
| Cdq
| Cqto
| Ret

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

To make the generated x86 assembly more compact, the compiler will

- Remove trivial instructions, e.g. `Movq %RAX %RAX`
- Remove unreachable code blocks, e.g. everything after `Ret`
