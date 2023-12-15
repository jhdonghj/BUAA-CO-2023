`timescale 1ns / 1ps
`include "defines.v"

module E_REG (
    input clk,
    input rst,
    input WE,
    input stall,
    input Req,
    input [31:0] D_instr,
    input [31:0] D_pc,
    input [31:0] D_EXTout,
    input [31:0] D_RD1,
    input [31:0] D_RD2,
    input D_BD,
    input [4:0] D_ExcCode,
    output reg [31:0] E_instr,
    output reg [31:0] E_pc,
    output reg [31:0] E_EXTout,
    output reg [31:0] E_RD1,
    output reg [31:0] E_RD2,
    output reg E_BD,
    output reg [4:0] E_ExcCode
    );

    always @(posedge clk) begin
        if(rst || Req) begin
            E_instr <= 0;
            E_pc <= stall && !Req ? D_pc : 32'h3000;
            E_EXTout <= 0;
            E_RD1 <= 0;
            E_RD2 <= 0;
            E_BD <= stall ? D_BD : 1'b0;
            E_ExcCode <= 5'b0;
        end else if(WE) begin
            E_instr <= D_instr;
            E_pc <= D_pc;
            E_EXTout <= D_EXTout;
            E_RD1 <= D_RD1;
            E_RD2 <= D_RD2;
            E_BD <= D_BD;
            E_ExcCode <= D_ExcCode;
        end
    end
    
endmodule