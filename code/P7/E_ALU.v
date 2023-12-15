`timescale 1ns / 1ps
`include "defines.v"

module E_ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0]  ALUOp,
    output [31:0] C,
    output Ov
    );
    
    assign C = ALUOp == `ALU_ADD || ALUOp == `ALU_ADDU ? A + B :
                ALUOp == `ALU_SUB || ALUOp == `ALU_SUBU ? A - B :
                ALUOp == `ALU_AND ? A & B :
                ALUOp == `ALU_OR  ? A | B :
                ALUOp == `ALU_LUI ? (B << 16) :
                ALUOp == `ALU_SLT ? ($signed(A) < $signed(B) ? 32'b1 : 32'b0) :
                ALUOp == `ALU_SLTU ? A < B :
                32'b0;

    wire [32:0] exAdd = {A[31], A} + {B[31], B}, exSub = {A[31], A} - {B[31], B};
    assign Ov = ((ALUOp == `ALU_ADD) && (exAdd[32] != exAdd[31])) ||
                ((ALUOp == `ALU_SUB) && (exSub[32] != exSub[31]));
endmodule
