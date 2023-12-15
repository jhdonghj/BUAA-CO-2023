`include "definations.v"

module EXT (
        input [15: 0] imm16, //! Immediate 16 bits
        input EXTOp, //! Extend Operation
        output [31: 0] imm32 //! Immediate 32 bits
    );

    assign imm32 =
           (EXTOp == `EXT_signed) ? {{16{imm16[15]}}, imm16} :
           {{16{1'b0}}, imm16};

endmodule
