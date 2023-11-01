`timescale 1ns / 1ps
`include "defines.v"

module ctrl(
    input [5:0] opcode,
    input [5:0] funct,
    output [2:0] ExtOp,
    output [2:0] WD3Sel,
    output MemWrite,
    output [4:0] ALUOp,
    output ALUSrc,
    output [2:0] A3Sel,
    output RegWrite,
    output [2:0] DMOp,
    output [3:0] NPCOp
    );
    
    wire add, sub, addu, subu, ori, lw, sw, beq, lui, jal, jr;

    assign  add = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADD;
    assign  sub = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUB;
    assign addu = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADDU;
    assign subu = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUBU;
    assign  ori = opcode == `CTR_OP_ORI;
    assign   lw = opcode == `CTR_OP_LW ;
    assign   sw = opcode == `CTR_OP_SW ;
    assign  beq = opcode == `CTR_OP_BEQ;
    assign  lui = opcode == `CTR_OP_LUI;
    assign  jal = opcode == `CTR_OP_JAL;
    assign   jr = opcode == `CTR_OP_SPE && funct == `CTR_FN_JR;
    
    assign ExtOp = {{1'b0},
                    {1'b0},
                    {1'b0 | lw | sw | beq}};
    assign WD3Sel = {{1'b0},
                     {1'b0 | jal},
                     {1'b0 | lw}};
    assign MemWrite = 1'b0 | sw;
    assign ALUOp = {{1'b0},
                    {1'b0},
                    {1'b0 | lui},
                    {1'b0 | ori},
                    {1'b0 | sub | subu | ori | beq}};
    assign ALUSrc = 1'b0 | ori | lw | sw | lui;
    assign A3Sel = {{1'b0},
                    {1'b0 | jal},
                    {1'b0 | add | sub | addu | subu}};
    assign RegWrite = 1'b0 | add | sub | addu | subu | ori | lw | lui | jal;
    assign DMOp = {{1'b0},
                    {1'b0}};
    assign NPCOp = {{1'b0},
                    {1'b0},
                    {1'b0 | jal | jr},
                    {1'b0 | beq | jr}};

endmodule
