`include "definations.v"

module ALU (
        input [3: 0] ALUOp,     //! ALU Operation
        input [31: 0] A,     //! Input A
        input [31: 0] B,     //! Input B
        input [5: 0] shamt,     //! Shift Amount
        output [31: 0] ALUout //! ALU Output
    );

    assign ALUout =
           (ALUOp == `ALU_add) ? A + B :
           (ALUOp == `ALU_sub) ? A - B :
           (ALUOp == `ALU_and) ? A & B :
           (ALUOp == `ALU_or) ? A | B :
           (ALUOp == `ALU_lui) ? B << 16 :
           32'b0;

endmodule
