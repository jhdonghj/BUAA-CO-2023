`timescale 1ns / 1ps
`include "defines.v"

module W_REG (
    input clk,
    input rst,
    input WE,
    input [31:0] M_instr,
    input [31:0] M_pc,
    input [31:0] M_EXTout,
    input [31:0] M_ALUout,
    input [31:0] M_DMout,
    output reg [31:0] W_instr,
    output reg [31:0] W_pc,
    output reg [31:0] W_EXTout,
    output reg [31:0] W_ALUout,
    output reg [31:0] W_DMout
    );

    always @(posedge clk) begin
        if(rst) begin
            W_instr <= 0;
            W_pc <= 0;
            W_EXTout <= 0;
            W_ALUout <= 0;
            W_DMout <= 0;
        end else if(WE) begin
            W_instr <= M_instr;
            W_pc <= M_pc;
            W_EXTout <= M_EXTout;
            W_ALUout <= M_ALUout;
            W_DMout <= M_DMout;
        end
    end
    
endmodule