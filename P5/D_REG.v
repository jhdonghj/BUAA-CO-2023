`timescale 1ns / 1ps
`include "defines.v"

module D_REG (
    input clk,
    input rst,
    input WE,
    input [31:0] F_instr,
    input [31:0] F_pc,
    output reg [31:0] D_instr,
    output reg [31:0] D_pc
    );

    always @(posedge clk) begin
        if(rst) begin
            D_instr <= 0;
            D_pc <= 0;
        end else if(WE) begin
            D_instr <= F_instr;
            D_pc <= F_pc;
        end
    end
    
endmodule