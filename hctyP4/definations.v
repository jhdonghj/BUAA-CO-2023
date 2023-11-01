`default_nettype none

//opcode
`define OP_Rtype 6'b000000
`define OP_ori  6'b001101
`define OP_sw 6'b101011
`define OP_lw 6'b100011
`define OP_beq  6'b000100
`define OP_lui  6'b001111
`define OP_j  6'b000010
`define OP_jal  6'b000011

//FUNC
`define FUNC_add 6'b100000
`define FUNC_sub 6'b100010
`define FUNC_jr 6'b001000

//RegDst
`define A3_rt 0
`define A3_rd 1
`define A3_ra 2

//WDSel
`define WD_alu 0
`define WD_mem 1
`define WD_pc4 2

//EXTOp
`define EXT_unsigned 0
`define EXT_signed 1

//ALUOp
`define ALU_add 0
`define ALU_sub 1
`define ALU_and 2
`define ALU_or 3
`define ALU_lui 4
`define ALU_5 5
`define ALU_6 6
`define ALU_7 7

//ALUSrc
`define ALU_RD2 0
`define ALU_imm 1

//Br
`define Br_default 0
`define Br_beq 1
`define Br_j 2
`define Br_jr 3
