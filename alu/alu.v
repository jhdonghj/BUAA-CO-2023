`timescale 1ns / 1ps

module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output [31:0] C
    );

    wire [31:0] uadd, umin, uand, uor, ulsr, uasr;

    assign uadd = A + B;
    assign umin = A - B;
    assign uand = A & B;
    assign uor  = A | B;
    assign ulsr = A >> B;
    assign uasr = $signed(A) >>> B;

    assign C = ALUOp == 3'b000 ? uadd :
               ALUOp == 3'b001 ? umin : 
               ALUOp == 3'b010 ? uand :
               ALUOp == 3'b011 ? uor  :
               ALUOp == 3'b100 ? ulsr :
               ALUOp == 3'b101 ? uasr :
               0;

endmodule
