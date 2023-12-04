`timescale 1ns / 1ps
`include "defines.v"

module M_REG (
    input clk,
    input rst,
    input WE,
    input Req,
    input [31:0] E_instr,
    input [31:0] E_pc,
    input [31:0] E_EXTout,
    input [31:0] E_ALUout,
    input [31:0] E_RD2,
    input [31:0] E_HILOout,
    input E_BD,
    input [4:0] E_ExcCode,
    output reg [31:0] M_instr,
    output reg [31:0] M_pc,
    output reg [31:0] M_EXTout,
    output reg [31:0] M_ALUout,
    output reg [31:0] M_RD2,
    output reg [31:0] M_HILOout,
    output reg M_BD,
    output reg [4:0] M_ExcCode
    );

    always @(posedge clk) begin
        if(rst || Req) begin
            M_instr <= 0;
            M_pc <= 32'h3000;
            M_EXTout <= 0;
            M_ALUout <= 0;
            M_RD2 <= 0;
            M_HILOout <= 0;
            M_BD <= 0;
            M_ExcCode <= 0;
        end else if(WE) begin
            M_instr <= E_instr;
            M_pc <= E_pc;
            M_EXTout <= E_EXTout;
            M_ALUout <= E_ALUout;
            M_RD2 <= E_RD2;
            M_HILOout <= E_HILOout;
            M_BD <= E_BD;
            M_ExcCode <= E_ExcCode;
        end
    end
    
endmodule