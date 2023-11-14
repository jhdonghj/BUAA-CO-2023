`timescale 1ns / 1ps
`include "defines.v"

module dm(
    input clk,
    input rst,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    input [2:0] DMOp,
    input [31:0] pc,
    output [31:0] RD
    );

    reg [31:0] ram [`DM_CAP - 1:0];
    integer i;
    wire [11:0] addr;
    wire [31:0] din; // data in

    assign addr = DMOp == `DM_LW_SW ? A[13:2] : 12'b0;
    assign din  = DMOp == `DM_LW_SW ? WD : 32'b0;
    assign RD   = DMOp == `DM_LW_SW ? ram[addr] : 32'b0;

    initial begin
        for (i = 0; i < `DM_CAP; i = i + 1) begin
            ram[i] <= 32'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `DM_CAP; i = i + 1) begin
                ram[i] <= 32'b0;
            end
        end else if(WE) begin
            ram[addr] <= din;
            $display("@%h: *%h <= %h", pc, A, din);
        end
    end

endmodule
