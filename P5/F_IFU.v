`timescale 1ns / 1ps
`include "defines.v"

module F_IFU (
    input clk,
    input rst,
    input stall,
    input [31:0] npc,
    output [31:0] instr,
    output reg [31:0] pc
    );

    reg [31:0] im_reg [0:`IFU_CAP - 1];
    wire [31:0] pcB;    

    assign pcB = pc - `IFU_BIAS;
    assign instr = im_reg[pcB[13:2]];

    initial begin
        pc <= `IFU_BIAS;
        $readmemh("code.txt", im_reg);
    end

    always @(posedge clk) begin
        if(rst) begin
            pc <= `IFU_BIAS;
        end else if(stall) begin
            pc <= pc;
        end else begin
            pc <= npc;
        end
    end
    
endmodule