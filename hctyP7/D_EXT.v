`include "constants.v"

module D_EXT (
        input [31: 0] EXTOp, //! Extension operation
        input [15: 0] imm16, //! Immediate 16 bits   
        output [31: 0] EXTOut //! Extended output
    );

    assign EXTOut =
           (EXTOp == `EXT_unsigned) ? {16'b0, imm16} :
           (EXTOp == `EXT_signed) ? {{16{imm16[15]}}, imm16} :
           (EXTOp == `EXT_lui) ? {imm16, 16'b0} :
           {16'b0, imm16};

endmodule
