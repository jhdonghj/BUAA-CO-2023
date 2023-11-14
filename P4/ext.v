`timescale 1ns / 1ps
`include "defines.v"

module ext(
    input [15:0] Input,
    input [2:0]  ExtOp,
    output [31:0] Output
    );

    assign Output = ExtOp == `EXT_ZEXT ? {16'b0, Input} :
                      ExtOp == `EXT_SEXT ? {{16{Input[15]}}, Input} :
                      ExtOp == `EXT_LTOU ? {Input, 16'b0} :
                      0;

endmodule
