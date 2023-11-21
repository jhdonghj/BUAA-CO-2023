`timescale 1ns / 1ps
`include "defines.v"

module M_BE (
    input [1:0] A,
    input [31:0] Din,
    input [2:0] BEOp,
    output [31:0] Dout
    );

    wire [7:0] Byte = Din[7 + 8 * A -: 8];
    wire [15:0] Half = Din[15 + 16 * A[1] -: 16];

    assign Dout = BEOp == `BE_NO ? Din :
                    BEOp == `BE_BU ? {24'b0, Byte} :
                    BEOp == `BE_BS ? {{24{Byte[7]}}, Byte} :
                    BEOp == `BE_HU ? {16'b0, Half} :
                    BEOp == `BE_HS ? {{16{Half[15]}}, Half} :
                    32'd0;

endmodule