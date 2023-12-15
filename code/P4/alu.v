`timescale 1ns / 1ps
`include "defines.v"

module alu(
    input [31:0] A,
    input [31:0] B,
    input [4:0]  ALUOp,
    output [31:0] C,
    output zero
    );
    
    assign C = ALUOp == `ALU_ADD ? A + B :
                ALUOp == `ALU_SUB ? A - B :
                ALUOp == `ALU_AND ? A & B :
                ALUOp == `ALU_OR  ? A | B :
                ALUOp == `ALU_LUI ? (B << 16) :
                32'b0;
    assign zero = C == 32'b0;

endmodule
