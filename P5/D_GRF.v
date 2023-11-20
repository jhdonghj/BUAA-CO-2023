`timescale 1ns / 1ps
`include "defines.v"

module D_GRF(
    input clk,
    input rst,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    input [31:0] pc,
    output [31:0] RD1,
    output [31:0] RD2
    );

    reg [31:0] regs [31:0];
    integer i;

    assign RD1 = (WE3 && A3 && A3 == A1) ? WD3 : regs[A1];
    assign RD2 = (WE3 && A3 && A3 == A2) ? WD3 : regs[A2];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] <= 0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 0;
            end
        end else if (WE3) begin
            if (A3 != 5'b0) begin
                regs[A3] <= WD3;
            end else begin
                regs[0] <= 32'b0;
            end
            $display("%d@%h: $%d <= %h", $time, pc, A3, WD3);
        end
    end

endmodule
