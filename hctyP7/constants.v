// `default_nettype none

//opcode
`define OP_Rtype 6'b000000
`define OP_addi 6'b001000
`define OP_andi 6'b001100
`define OP_ori  6'b001101
`define OP_lui  6'b001111
`define OP_sb 6'b101000
`define OP_sh 6'b101001
`define OP_sw 6'b101011
`define OP_lb 6'b100000
`define OP_lh 6'b100001
`define OP_lw 6'b100011
`define OP_beq  6'b000100
`define OP_bne 6'b000101
`define OP_j  6'b000010
`define OP_jal  6'b000011
`define OP_COP0 6'b010000

`define COP0_mfc0 6'b00000
`define COP0_mtc0 6'b00100
`define COP0_eret 6'b10000

`define INSTR_eret 32'h42000018

//FUNC
`define FUNC_add 6'b100000
`define FUNC_sub 6'b100010
`define FUNC_and 6'b100100
`define FUNC_or 6'b100101
`define FUNC_slt 6'b101010
`define FUNC_sltu 6'b101011

`define FUNC_mult 6'b011000
`define FUNC_multu 6'b011001
`define FUNC_div 6'b011010
`define FUNC_divu 6'b011011
`define FUNC_mfhi 6'b010000
`define FUNC_mflo 6'b010010
`define FUNC_mthi 6'b010001
`define FUNC_mtlo 6'b010011

`define FUNC_jr 6'b001000

`define FUNC_syscall 6'b001100

`define FUNC_eret 6'b011000

//RegDst
`define A3_rt 0
`define A3_rd 1
`define A3_ra 2

//WDSel
`define WD_alu 0
`define WD_mem 1
`define WD_pc8 2
`define WD_ext 3
`define WD_mdu 4
`define WD_cp0 5

//EXTOp
`define EXT_unsigned 0
`define EXT_signed 1
`define EXT_lui 2

//ALUOp
`define ALU_add 0
`define ALU_sub 1
`define ALU_and 2
`define ALU_or 3
`define ALU_slt 4
`define ALU_sltu 5
`define ALU_6 6
`define ALU_7 7

//ALUSrc
`define ALU_RD2 0
`define ALU_imm 1

//MDUOp
`define MDU_default 0
`define MDU_mult 1
`define MDU_multu 2
`define MDU_div 3
`define MDU_divu 4
`define MDU_mfhi 5
`define MDU_mflo 6
`define MDU_mthi 7
`define MDU_mtlo 8

//Br
`define Br_default 0
`define Br_br 1
`define Br_j 2
`define Br_jr 3
`define Br_eret 4

//BranchType
`define CMP_beq 0
`define CMP_bne 1
`define CMP_2 2

//DMType
`define DM_lb 0
`define DM_lh 1
`define DM_lw 2
`define DM_sb 3
`define DM_sh 4
`define DM_sw 5

//ForwardSel
`define FWD_D 0
`define FWD_E 1
`define FWD_M 2
`define FWD_W 3

//Addr
`define DM_StartAddr 32'h0000_0000
`define DM_EndAddr   32'h0000_2FFF
`define IM_StartAddr 32'h0000_3000
`define Int_Addr     32'h0000_4180
`define IM_EndAddr   32'h0000_6FFF
`define TC1_StartAddr 32'h0000_7F00
`define TC1_EndAddr   32'h0000_7F0B
`define TC2_StartAddr 32'h0000_7F10
`define TC2_EndAddr   32'h0000_7F1B
`define Int_StartAddr 32'h0000_7F20
`define Int_EndAddr   32'h0000_7F23

//BridgeSel
`define Bridge_error 0
`define Bridge_DM 1
`define Bridge_TC1 2
`define Bridge_TC2 3
`define Bridge_Int 4

//ExcCode
`define ExcCode_Int 0  // 外部中断
`define ExcCode_Mod 1
`define ExcCode_TLBL 2
`define ExcCode_TLBS 3
`define ExcCode_AdEL 4  // 取指异常/取数异常
`define ExcCode_AdES 5  // 存数异常
`define ExcCode_IBE 6
`define ExcCode_DBE 7
`define ExcCode_Sys 8  // 系统调用
`define ExcCode_Bp 9
`define ExcCode_RI 10  // 非法指令
`define ExcCode_CpU 11
`define ExcCode_Ov 12  // 溢出

