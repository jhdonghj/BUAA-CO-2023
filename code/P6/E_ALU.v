`timescale 1ns / 1ps
`include "defines.v"

module E_ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0]  ALUOp,
    output [31:0] C
    );
    
    assign C = ALUOp == `ALU_ADD ? A + B :
                ALUOp == `ALU_SUB ? A - B :
                ALUOp == `ALU_AND ? A & B :
                ALUOp == `ALU_OR  ? A | B :
                ALUOp == `ALU_LUI ? (B << 16) :
                ALUOp == `ALU_SLT ? ($signed(A) < $signed(B) ? 32'b1 : 32'b0) :
                ALUOp == `ALU_SLTU ? A < B :
                32'b0;

endmodule
