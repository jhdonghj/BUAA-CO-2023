`timescale 1ns / 1ps
`include "defines.v"

module D_EXT(
    input [15:0] Input,
    input [2:0]  EXTOp,
    output [31:0] Output
    );

    assign Output = EXTOp == `EXT_ZEXT ? {16'b0, Input} :
                      EXTOp == `EXT_SEXT ? {{16{Input[15]}}, Input} :
                      EXTOp == `EXT_LTOU ? {Input, 16'b0} :
                      0;

endmodule
