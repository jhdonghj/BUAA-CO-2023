`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:29:17 08/29/2023 
// Design Name: 
// Module Name:    id_fsm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module id_fsm(
    input [7:0] char,
    input clk,
    output out
    );
    reg [1:0] st;
    wire letter, number, other;
    wire [1:0] new_st, st0, st1, st2;

    assign letter = ("a" <= char && char <= "z") || ("A" <= char && char <= "Z");
    assign number = ("0" <= char && char <= "9");
    assign other = !letter && !number;
    assign st0 = letter == 1'b1 ? 2'b01 : 2'b00;
    assign st1 = letter == 1'b1 ? 2'b01 :
                 number == 1'b1 ? 2'b10 : 2'b00;
    assign st2 = letter == 1'b1 ? 2'b01 :
                 number == 1'b1 ? 2'b10 : 2'b00;
    assign new_st = st == 2'b00 ? st0 :
                    st == 2'b01 ? st1 : st2;

    initial begin
        st = 2'b00;
    end
    always @(posedge clk) begin
        st <= new_st;
    end
    assign out = st == 2'b10;
endmodule
