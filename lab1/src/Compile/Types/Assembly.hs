module Compile.Types.Assembly where

data Inst
    = Movq Operand Operand
    | Movl Operand Operand
    | Movabsq Int Operand
    | Addq Operand Operand
    | Addl Operand  Operand
    | Subq Operand Operand
    | Subl Operand Operand
    | Imulq Operand
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
    | Ret deriving (Eq, Ord)

data Operand
    = Imm Int
    | Reg Register
    | Mem
        { imm :: Int
        , base :: Register
        , index :: Register
        , width :: Int
        }
    | Mem'
        { imm :: Int
        , base :: Register
        } deriving (Eq, Ord)

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
    | R11   -- Reserve R11 for moves to and from the stack when necessary
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
    | R15D deriving (Eq, Ord)

instance Show Register where
    show RAX = "%rax"
    show RCX = "%rcx"
    show RDX = "%rdx"
    show RBX = "%rbx"
    show RSI = "%rsi"
    show RDI = "%rdi"
    show RSP = "%rsp"
    show RBP = "%rbp"
    show R8 = "%r8"
    show R9 = "%r9"
    show R10 = "%r10"
    show R11 = "%r11"
    show R12 = "%r12"
    show R13 = "%r13"
    show R14 = "%r14"
    show R15 = "%r15"
    show EAX = "%eax"
    show ECX = "%ecx"
    show EDX = "%edx"
    show EBX = "%ebx"
    show ESI = "%esi"
    show EDI = "%edi"
    show ESP = "%esp"
    show EBP = "%ebp"
    show R8D = "%r8d"
    show R9D = "%r9d"
    show R10D = "%r10d"
    show R11D = "%r11d"
    show R12D = "%r12d"
    show R13D = "%r13d"
    show R14D = "%r14d"
    show R15D = "%r15d"

instance Show Operand where
    show (Imm x) = "$" ++ show x
    show (Reg r) = show r
    show (Mem x b i w) = show x ++ "(" ++ show b ++ ", " ++ show i ++ ", " ++ show w ++ ")"
    show (Mem' x b) = show x ++ "(" ++ show b ++ ")"

instance Show Inst where
    show (Movq x1 x2) = "movq " ++ show x1 ++ ", " ++ show x2
    show (Movl x1 x2) = "movl " ++ show x1 ++ ", " ++ show x2
    show (Movabsq x1 x2) = "movabsq " ++ show x1 ++ ", " ++ show x2
    show (Addq x1 x2) = "addq " ++ show x1 ++ ", " ++ show x2
    show (Addl x1 x2) = "addl " ++ show x1 ++ ", " ++ show x2
    show (Subq x1 x2) = "subq " ++ show x1 ++ ", " ++ show x2
    show (Subl x1 x2) = "subl " ++ show x1 ++ ", " ++ show x2
    show (Imulq x) = "imulq " ++ show x
    show (Imull x1 x2) = "imull " ++ show x1 ++ ", " ++ show x2
    show (Idivq x) = "idivq " ++ show x
    show (Idivl x) = "idivl " ++ show x
    show (Salq x1 x2) = "salq " ++ show x1 ++ ", " ++ show x2
    show (Sarq x1 x2) = "sarq " ++ show x1 ++ ", " ++ show x2
    show (Sall x1 x2) = "sall " ++ show x1 ++ ", " ++ show x2
    show (Sarl x1 x2) = "sarl " ++ show x1 ++ ", " ++ show x2
    show (Negq x) = "negq " ++ show x
    show (Negl x) = "negl " ++ show x
    show (Pushq x) = "pushq " ++ show x
    show (Popq x) = "popq " ++ show x
    show Cdq = "cdq"
    show Ret = "retq"

toReg64 :: Register -> Register
toReg64 RAX = RAX
toReg64 RCX = RCX
toReg64 RDX = RDX
toReg64 RBX = RBX
toReg64 RSI = RSI
toReg64 RDI = RDI
toReg64 RSP = RSP
toReg64 RBP = RBP
toReg64 R8 = R8
toReg64 R9 = R9
toReg64 R10 = R10
toReg64 R11 = R11
toReg64 R12 = R12
toReg64 R13 = R13
toReg64 R14 = R14
toReg64 R15 = R15
toReg64 EAX = RAX
toReg64 ECX = RCX
toReg64 EDX = RDX
toReg64 EBX = RBX
toReg64 ESI = RSI
toReg64 EDI = RDI
toReg64 ESP = RSP
toReg64 EBP = RBP
toReg64 R8D = R8
toReg64 R9D = R9
toReg64 R10D = R10
toReg64 R11D = R11
toReg64 R12D = R12
toReg64 R13D = R13
toReg64 R14D = R14
toReg64 R15D = R15