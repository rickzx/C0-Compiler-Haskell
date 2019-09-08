module Compile.Types.Assembly where

data Inst
    = Movq Operand Operand
    | Movl Operand Operand
    | Movabsq Int Operand
    | Addq Operand Operand
    | Addl Operand  Operand
    | Subq Operand Operand
    | Subl Operand Operand
    | Imulq Operand Operand
    | Imull Operand Operand
    | Salq Int Operand
    | Salr Int Operand
    | Incq Operand
    | Decq Operand
    | Negq Operand
    | Ret

data Operand
    = Imm Int
    | Reg Register
    | Mem Int Register Register Int

data Register
    = RAX
    | RCX
    | RDX
    | RBX
    | RSI
    | RDI
    | RSP   -- The stack pointer
    | RBP   -- The base pointer
    | R8
    | R9
    | R10
    | R11
    | R12
    | R13
    | R14
    | R15
    | EAX
    | ECX
    | EDX
    | EBX
    | ESI
    | EDI
    | ESP
    | EBP
    | R8D
    | R9D
    | R10D
    | R11D
    | R12D
    | R13D
    | R14D
    | R15D