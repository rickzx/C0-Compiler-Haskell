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
    | Idivq Operand
    | Idivl Operand
    | Salq Operand Operand
    | Sall Operand Operand
    | Sarq Operand Operand
    | Sarl Operand Operand
    | Negq Operand
    | Negl Operand
    | Pushq Operand
    | Popq Operand
    | Cdq
    | Cqto
    | Andl Operand Operand
    | Orl Operand Operand
    | Xorl Operand Operand
    | Notl Operand
    | Fun String
    | Call String
    | Label String
    | Cmp Operand Operand
    | Cmpq Operand Operand
    | Test Operand Operand
    | Sete Operand
    | Setne Operand
    | Setg Operand
    | Setge Operand
    | Setl Operand
    | Setle Operand
    | Jmp String
    | Je String
    | Jne String
    | Jl String
    | Jle String
    | Jg String
    | Jge String
    | Movzbl Operand Operand
    | Global String
    | Ret deriving (Eq, Ord)

data Operand
    = Imm Int
    | Reg Register
    | Mem Operand
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
    | R15D 
    | AL
    | BL
    | CL
    | DL
    | SIL
    | DIL
    | SPL
    | BPL
    | R8B
    | R9B
    | R10B
    | R11B
    | R12B
    | R13B
    | R14B
    | R15B deriving (Eq, Ord)

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
    show AL = "%al"
    show BL = "%bl"
    show CL = "%cl"
    show DL = "%dl"
    show SIL = "%sil"
    show DIL = "%dil"
    show SPL = "%spl"
    show BPL = "%bpl"
    show R8B = "%r8b"
    show R9B = "%r9b"
    show R10B = "%r10b"
    show R11B = "%r11b"
    show R12B = "%r12b"
    show R13B = "%r13b"
    show R14B = "%r14b"
    show R15B  = "%r15b"

instance Show Operand where
    show (Imm x) = "$" ++ show x
    show (Reg r) = show r
    show (Mem o) = "(" ++ show o ++ ")"
    show (Mem' x b) = show x ++ "(" ++ show b ++ ")"

instance Show Inst where
    show (Movq x1 x2) = "\tmovq " ++ show x1 ++ ", " ++ show x2
    show (Movl x1 x2) = "\tmovl " ++ show x1 ++ ", " ++ show x2
    show (Movabsq x1 x2) = "\tmovabsq " ++ show x1 ++ ", " ++ show x2
    show (Addq x1 x2) = "\taddq " ++ show x1 ++ ", " ++ show x2
    show (Addl x1 x2) = "\taddl " ++ show x1 ++ ", " ++ show x2
    show (Subq x1 x2) = "\tsubq " ++ show x1 ++ ", " ++ show x2
    show (Subl x1 x2) = "\tsubl " ++ show x1 ++ ", " ++ show x2
    show (Imulq x1 x2) = "\timulq " ++ show x1 ++ ", " ++ show x2 
    show (Imull x1 x2) = "\timull " ++ show x1 ++ ", " ++ show x2
    show (Idivq x) = "\tidivq " ++ show x
    show (Idivl x) = "\tidivl " ++ show x
    show (Salq x1 x2) = "\tsalq " ++ show x1 ++ ", " ++ show x2
    show (Sarq x1 x2) = "\tsarq " ++ show x1 ++ ", " ++ show x2
    show (Sall x1 x2) = "\tsall " ++ show x1 ++ ", " ++ show x2
    show (Sarl x1 x2) = "\tsarl " ++ show x1 ++ ", " ++ show x2
    show (Negq x) = "\tnegq " ++ show x
    show (Negl x) = "\tnegl " ++ show x
    show (Pushq x) = "\tpushq " ++ show x
    show (Popq x) = "\tpopq " ++ show x
    show Cdq = "\tcdq"
    show Cqto = "\tcqto"
    show Ret = "\tretq"
    show (Andl x1 x2) = "\tandl " ++ show x1 ++ ", " ++ show x2 
    show (Orl x1 x2) = "\torl " ++ show x1 ++ ", " ++ show x2 
    show (Xorl x1 x2) = "\txorl " ++ show x1 ++ ", " ++ show x2 
    show (Notl x) = "\tnotl " ++ show x
    show (Label s) = "." ++ s ++ ":"
    show (Cmp x1 x2) = "\tcmpl " ++ show x1 ++ ", " ++ show x2
    show (Cmpq x1 x2) = "\tcmpq " ++ show x1 ++ ", " ++ show x2 
    show (Test x1 x2) = "\ttestl " ++ show x1 ++ ", " ++ show x2 
    show (Sete x) = "\tsete " ++ show x
    show (Setne x) = "\tsetne " ++ show x
    show (Setg x) = "\tsetg " ++ show x
    show (Setge x) = "\tsetge " ++ show x
    show (Setl x) = "\tsetl " ++ show x
    show (Setle x) = "\tsetle " ++ show x
    show (Jmp label) = "\tjmp ." ++ label
    show (Je label) = "\tje ." ++ label
    show (Jne label) = "\tjne ." ++ label
    show (Jl label) = "\tjl ." ++ label
    show (Jle label) = "\tjle ." ++ label
    show (Jg label) = "\tjg ." ++ label
    show (Jge label) = "\tjge ." ++ label
    show (Movzbl x1 x2) = "\tmovzbl " ++ show x1 ++ ", " ++ show x2
    show (Call f) = "\tcall " ++ f
    show (Fun f) = f ++ ":"
    show (Global f) = "\t.globl " ++ f


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
toReg64 AL = RAX
toReg64 BL = RBX
toReg64 CL = RCX
toReg64 DL = RDX
toReg64 SIL = RSI
toReg64 DIL = RDI
toReg64 SPL = RSP
toReg64 BPL = RBP
toReg64 R8B = R8
toReg64 R9B = R9
toReg64 R10B = R10
toReg64 R11B = R11
toReg64 R12B = R12
toReg64 R13B = R13
toReg64 R14B = R14
toReg64 R15B  = R15

toReg8 :: Register -> Register
toReg8 RAX = AL
toReg8 RCX = CL
toReg8 RDX = DL
toReg8 RBX = BL
toReg8 RSI = SIL
toReg8 RDI = DIL
toReg8 RSP = SPL
toReg8 RBP = BPL
toReg8 R8 = R8B
toReg8 R9 = R9B
toReg8 R10 = R10B
toReg8 R11 = R11B
toReg8 R12 = R12B
toReg8 R13 = R13B
toReg8 R14 = R14B
toReg8 R15 = R15B
toReg8 EAX = AL
toReg8 ECX = CL
toReg8 EDX = DL
toReg8 EBX = BL
toReg8 ESI = SIL
toReg8 EDI = DIL
toReg8 ESP = SPL
toReg8 EBP = BPL
toReg8 R8D = R8B
toReg8 R9D = R9B
toReg8 R10D = R10B
toReg8 R11D = R11B
toReg8 R12D = R12B
toReg8 R13D = R13B
toReg8 R14D = R14B
toReg8 R15D = R15B
toReg8 AL = AL
toReg8 BL = BL
toReg8 CL = CL
toReg8 DL = DL
toReg8 SIL = SIL
toReg8 DIL = DIL
toReg8 SPL = SPL
toReg8 BPL = BPL
toReg8 R8B = R8B
toReg8 R9B = R9B
toReg8 R10B = R10B
toReg8 R11B = R11B
toReg8 R12B = R12B
toReg8 R13B = R13B
toReg8 R14B = R14B
toReg8 R15B  = R15B