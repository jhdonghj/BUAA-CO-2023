`timescale 1ns / 1ps
`include "defines.v"

module D_CMP (
    input [31:0] A,
    input [31:0] B,
    input [2:0] CMPOp,
    output isBrch
    );

    assign isBrch = CMPOp == `CMP_EQ ? A == B :
                    CMPOp == `CMP_NE ? A != B :
                    1'b0;

endmodule