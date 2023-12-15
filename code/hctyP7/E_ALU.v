`include "constants.v"

module E_ALU (
        input [31: 0] ALUOp,
        input [31: 0] A,
        input [31: 0] B,
        input [5: 0] shamt,
        output [31: 0] ALUOut,
        output Ov
    );

    assign ALUOut =
           (ALUOp == `ALU_add) ? A + B :
           (ALUOp == `ALU_sub) ? A - B :
           (ALUOp == `ALU_and) ? A & B :
           (ALUOp == `ALU_or) ? A | B :
           (ALUOp == `ALU_slt) ? $signed($signed(A) < $signed(B)) :
           (ALUOp == `ALU_sltu) ? A < B :
           32'b0;

    wire [32: 0] exAdd = {A[31], A} + {B[31], B}, exSub = {A[31], A} - {B[31], B};
    assign Ov = ((ALUOp == `ALU_add) && (exAdd[32] != exAdd[31])) ||
           ((ALUOp == `ALU_sub) && (exSub[32] != exSub[31]));
endmodule
