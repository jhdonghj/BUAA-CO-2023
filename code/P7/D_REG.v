`timescale 1ns / 1ps
`include "defines.v"

module D_REG (
    input clk,
    input rst,
    input WE,                   // WE = !stall
    input Req,
    input [31:0] F_instr,
    input [31:0] F_pc,
    input F_BD,
    input [4:0] F_ExcCode,
    output reg [31:0] D_instr,
    output reg [31:0] D_pc,
    output reg D_BD,
    output reg [4:0] D_ExcCode
    );

    always @(posedge clk) begin
        if(rst) begin
            D_instr <= 0;
            D_pc <= 32'h3000;
            D_BD <= 0;
            D_ExcCode <= 0;
        end else if(WE || Req) begin
            D_instr <= F_instr;
            D_pc <= F_pc;
            D_BD <= F_BD;
            D_ExcCode <= F_ExcCode;
        end
    end
    
endmodule