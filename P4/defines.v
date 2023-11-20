// `default_nettype none

// ALU
`define ALU_ADD 5'b00000
`define ALU_SUB 5'b00001
`define ALU_AND 5'b00010
`define ALU_OR  5'b00011
`define ALU_LUI 5'b00100

// DM
`define DM_CAP 3072
`define DM_LW_SW 3'b000

// Ext
`define EXT_ZEXT 3'b000
`define EXT_SEXT 3'b001
`define EXT_LTOU 3'b010

// IM
`define IM_CAP 4096
`define IM_BIAS 32'h3000

// NPC
`define NPC_ADD4 4'b0000
`define NPC_BRCH 4'b0001
`define NPC_JAL  4'b0010
`define NPC_JR   4'b0011

// Ctrl
`define CTR_OP_SPE 6'b000000
`define CTR_OP_ORI 6'b001101
`define CTR_OP_LW  6'b100011
`define CTR_OP_SW  6'b101011
`define CTR_OP_BEQ 6'b000100
`define CTR_OP_LUI 6'b001111
`define CTR_OP_JAL 6'b000011

`define CTR_FN_ADD 6'b100000
`define CTR_FN_SUB 6'b100010
`define CTR_FN_ADDU 6'b100001
`define CTR_FN_SUBU 6'b100011
`define CTR_FN_JR   6'b001000

// MIPS
`define A3Sel_rt 3'b000
`define A3Sel_rd 3'b001
`define A3Sel_ra 3'b010

`define WD3Sel_ALUout 3'b000
`define WD3Sel_DMout  3'b001
`define WD3Sel_PC4    3'b010
