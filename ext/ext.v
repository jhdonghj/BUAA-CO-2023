`timescale 1ns / 1ps

module ext(
    input [15:0] imm,
    input [1:0] EOp,
    output [31:0] ext
    );

    wire [31:0] sext, uext, tohi, ssht;

    assign sext = {{16{imm[15]}}, imm[15:0]};
    assign uext = {16'b0, imm[15:0]};
    assign tohi = {imm[15:0], 16'b0};
    assign ssht = sext << 2;

    assign ext = EOp == 2'b00 ? sext :
                 EOp == 2'b01 ? uext :
                 EOp == 2'b10 ? tohi :
                 EOp == 2'b11 ? ssht :
                 0;

endmodule
