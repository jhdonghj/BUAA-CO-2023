`timescale 1ns / 1ps
`include "defines.v"

module M_DM(
    input MemWrite,
    input [2:0] DMOp,
    input [31:0] A,
    input [31:0] WD,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen
    );

    wire [3:0] Half, Byte;

    assign Half = 4'b0011 << A[1:0];
    assign Byte = 4'b0001 << A[1:0];

    assign m_data_addr = A;
    assign m_data_wdata = WD << (8 * A[1:0]);
    assign m_data_byteen = !MemWrite ? 4'b0000 :
                            DMOp == `DM_LOAD ? 4'b0000 :
                            DMOp == `DM_SW ? 4'b1111 :
                            DMOp == `DM_SH ? Half :
                            DMOp == `DM_SB ? Byte :
                            4'b0;

endmodule
