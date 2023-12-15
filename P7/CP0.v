`timescale 1ns / 1ps
`include "defines.v"
`define IM SR[15:10]        // interrupt mask
`define EXL SR[1]           // exception level
`define IE SR[0]            // global interrupt enable
`define BD Cause[31]        // branch delay
`define IP Cause[15:10]     // interrupt pending
`define ExcCode Cause[6:2]  // exception code
// 12 -> SR    13 -> Cause    14 -> EPC

module CP0 (
    input clk,
    input rst,
    input WE,               // write enable (mtc0)
    input [4:0] A,          // register address (mfc0, mtc0 shared)
    input [31:0] Din,       // write data (mtc0 from GPR)
    output [31:0] Dout,     // read data (mfc0 to GPR)
    input [31:0] VPC,       // affected PC
    input BDIn,             // branch delay
    input [4:0] ExcCodeIn,  // exception code
    input [5:0] HWInt,      // hardware interrupt
    input EXLClr,           // clear EXL (eret)
    output [31:0] EPCout,   // exception PC
    output Req              // request interrupt
    );

    reg [31:0] SR, Cause, EPC, PrID;

    wire IntReq, ExcReq;
    assign IntReq = (|(HWInt & `IM)) & `IE & !`EXL;
    // has interupt request, interrupt enabled, not in exception level
    assign ExcReq = (|ExcCodeIn) & !`EXL;
    // has exception request, not in exception level
    // ExcCode of interupt is 0, so it will not be considered as exception
    assign Req = IntReq | ExcReq;

    wire [31:0] tmp_EPC = Req ? (BDIn ? VPC - 4 : VPC) : EPC;
    assign EPCout = EPC;
    
    assign Dout = A == 5'd12 ? SR :
                    A == 5'd13 ? Cause :
                    A == 5'd14 ? EPC :
                    A == 5'd15 ? PrID :
                    0;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            SR <= 0;
            Cause <= 0;
            EPC <= 0;
            PrID <= 32'h4441_7A9F;
        end else begin
            if(EXLClr) `EXL <= 1'b0;
            if(Req) begin
                `EXL <= 1'b1;
                `BD <= BDIn;
                `ExcCode <= IntReq ? 5'b0 : ExcCodeIn;
                EPC <= tmp_EPC;
            end else if(WE) begin
                case(A)
                    5'd12: SR <= Din & 32'b1111_1100_0000_0011;
                    5'd14: EPC <= Din;
                endcase
            end
            `IP <= HWInt;
        end
    end
/*
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]

*/
endmodule