`timescale 1ns / 1ps
`include "defines.v"

module W_REG (
    input clk,
    input rst,
    input WE,
    input Req,
    input [31:0] M_instr,
    input [31:0] M_pc,
    input [31:0] M_EXTout,
    input [31:0] M_ALUout,
    input [31:0] M_DMout,
    input [31:0] M_HILOout,
    input [31:0] M_CP0out,
    output reg [31:0] W_instr,
    output reg [31:0] W_pc,
    output reg [31:0] W_EXTout,
    output reg [31:0] W_ALUout,
    output reg [31:0] W_DMout,
    output reg [31:0] W_HILOout,
    output reg [31:0] W_CP0out
    );

    always @(posedge clk) begin
        if(rst || Req) begin
            W_instr <= 0;
            W_pc <= 32'h3000;
            W_EXTout <= 0;
            W_ALUout <= 0;
            W_DMout <= 0;
            W_HILOout <= 0;
            W_CP0out <= 0;
        end else if(WE) begin
            W_instr <= M_instr;
            W_pc <= M_pc;
            W_EXTout <= M_EXTout;
            W_ALUout <= M_ALUout;
            W_DMout <= M_DMout;
            W_HILOout <= M_HILOout;
            W_CP0out <= M_CP0out;
        end
    end
    
endmodule