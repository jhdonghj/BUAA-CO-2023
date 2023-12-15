`timescale 1ns / 1ps
`include "defines.v"

module F_PC (
    input clk,
    input rst,
    input WE,
    input [31:0] npc,
    output reg [31:0] pc
    );

    initial begin
        pc <= `PC_BIAS;
    end

    always @(posedge clk) begin
        if(rst) begin
            pc <= `PC_BIAS;
        end else if(WE) begin
            pc <= npc;
        end
    end
    
endmodule