`timescale 1ns / 1ps
`include "defines.v"

module im(
    input [31:0] pc,
    output [31:0] instr
    );

    reg [31:0] im_reg [0:`IM_CAP - 1];
    wire [31:0] pcB;
    wire [11:0] addr;

    assign pcB = pc - `IM_BIAS;
    assign addr = pcB[13:2];
    assign instr = im_reg[addr];

    initial begin
        $readmemh("code.txt", im_reg);
    end

endmodule
