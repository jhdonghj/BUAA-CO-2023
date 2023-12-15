// `default_nettype none

// ALU
`define ALU_ADD  5'b00000
`define ALU_SUB  5'b00001
`define ALU_AND  5'b00010
`define ALU_OR   5'b00011
`define ALU_LUI  5'b00100
`define ALU_SLT  5'b00101
`define ALU_SLTU 5'b00110

// HILO
`define HILO_NONE  5'd0
`define HILO_MULT  5'd1
`define HILO_MULTU 5'd2
`define HILO_DIV   5'd3
`define HILO_DIVU  5'd4
`define HILO_MFHI  5'd5
`define HILO_MFLO  5'd6
`define HILO_MTHI  5'd7
`define HILO_MTLO  5'd8

// CMP
`define CMP_EQ 3'b000
`define CMP_NE 3'b001

// DM
`define DM_LOAD 3'b000
`define DM_SW   3'b001
`define DM_SH   3'b010
`define DM_SB   3'b011

// BE
`define BE_NO 3'b000
`define BE_BU 3'b001
`define BE_BS 3'b010
`define BE_HU 3'b011
`define BE_HS 3'b100

// Ext
`define EXT_ZEXT 3'b000
`define EXT_SEXT 3'b001
`define EXT_LTOU 3'b010

// PC
`define PC_BIAS 32'h3000

// NPC
`define NPC_ADD4 4'b0000
`define NPC_BRCH 4'b0001
`define NPC_JAL  4'b0010
`define NPC_JR   4'b0011

// MIPS
`define A3Sel_rt 3'b000
`define A3Sel_rd 3'b001
`define A3Sel_ra 3'b010

`define WD3Sel_ALUout 3'b000
`define WD3Sel_DMout  3'b001
`define WD3Sel_PC8    3'b010
`define WD3Sel_HILO   3'b011

`define FOR_REG 3'b000
`define FOR_M2E 3'b001
`define FOR_W2E 3'b010
`define FOR_W2M 3'b011

// Ctrl
`define CTR_OP_SPE  6'b000000
`define CTR_OP_LUI  6'b001111
`define CTR_OP_ADDI 6'b001000
`define CTR_OP_ANDI 6'b001100
`define CTR_OP_ORI  6'b001101
`define CTR_OP_LB   6'b100000
`define CTR_OP_LH   6'b100001
`define CTR_OP_LW   6'b100011
`define CTR_OP_SB   6'b101000
`define CTR_OP_SH   6'b101001
`define CTR_OP_SW   6'b101011
`define CTR_OP_BEQ  6'b000100
`define CTR_OP_BNE  6'b000101
`define CTR_OP_JAL  6'b000011
`define CTR_OP_JR   6'b000010

`define CTR_FN_ADD   6'b100000
`define CTR_FN_SUB   6'b100010
`define CTR_FN_ADDU  6'b100001
`define CTR_FN_SUBU  6'b100011
`define CTR_FN_AND   6'b100100
`define CTR_FN_OR    6'b100101
`define CTR_FN_SLT   6'b101010
`define CTR_FN_SLTU  6'b101011
`define CTR_FN_MULT  6'b011000
`define CTR_FN_MULTU 6'b011001
`define CTR_FN_DIV   6'b011010
`define CTR_FN_DIVU  6'b011011
`define CTR_FN_MFHI  6'b010000
`define CTR_FN_MFLO  6'b010010
`define CTR_FN_MTHI  6'b010001
`define CTR_FN_MTLO  6'b010011
`define CTR_FN_JR    6'b001000
