`timescale 1ns / 1ps
`include "defines.v"

module BRIDGE (
    input [31:0] PrAddr,
    output [31:0] PrRD,
    input [31:0] PrWD,
    input [3:0] PrByteEn,

    output [31:0] m_data_addr,
    input [31:0] m_data_rdata,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,

    output [31:0] m_int_addr,
    output [3:0] m_int_byteen,

    output [31:2] TC1_addr,
    output TC1_we,
    output [31:0] TC1_wdata,
    input [31:0] TC1_rdata,

    output [31:2] TC2_addr,
    output TC2_we,
    output [31:0] TC2_wdata,
    input [31:0] TC2_rdata
    );

    assign m_data_addr = PrAddr;
    assign m_int_addr = PrAddr;
    assign TC1_addr = PrAddr[31:2];
    assign TC2_addr = PrAddr[31:2];

    wire hit_DM, hit_TC1, hit_TC2, hit_int;
    assign hit_DM = (PrAddr >= `DM_Addr) && (PrAddr <= `DM_EndAddr);
    assign hit_TC1 = (PrAddr >= `TC1_Addr) && (PrAddr <= `TC1_EndAddr);
    assign hit_TC2 = (PrAddr >= `TC2_Addr) && (PrAddr <= `TC2_EndAddr);
    assign hit_int = (PrAddr >= `INT_Addr) && (PrAddr <= `INT_EndAddr);

    assign PrRD = hit_DM ? m_data_rdata :
                    hit_TC1 ? TC1_rdata :
                    hit_TC2 ? TC2_rdata :
                    0;

    assign m_data_wdata = PrWD;
    assign TC1_wdata = PrWD;
    assign TC2_wdata = PrWD;

    assign m_data_byteen = hit_DM ? PrByteEn : 4'b0;
    assign m_int_byteen = hit_int ? PrByteEn : 4'b0;
    assign TC1_we = hit_TC1 ? (|PrByteEn) : 1'b0;
    assign TC2_we = hit_TC2 ? (|PrByteEn) : 1'b0;
    
endmodule