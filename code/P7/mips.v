`timescale 1ns / 1ps
`include "defines.v"

module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
    );

    wire [31:0] PrAddr, PrRD, PrWD;
    wire [3:0] PrByteEn;

    wire [31:0] TC1_wdata, TC2_wdata, TC1_rdata, TC2_rdata;
    wire [31:2] TC1_addr, TC2_addr;
    wire TC1_we, TC2_we, TC1_IRQ, TC2_IRQ;

    wire [5:0] HWInt = {3'b0, interrupt, TC2_IRQ, TC1_IRQ};

    CPU cpu(
        .clk(clk),
        .reset(reset),
        .i_inst_addr(i_inst_addr),
        .i_inst_rdata(i_inst_rdata),
        .m_data_addr(PrAddr),
        .m_data_rdata(PrRD),
        .m_data_wdata(PrWD),
        .m_data_byteen(PrByteEn),
        .m_inst_addr(m_inst_addr),
        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr),
        .HWInt(HWInt),
        .macroscopic_pc(macroscopic_pc)
    );

    BRIDGE birdge(
        .PrAddr(PrAddr),
        .PrRD(PrRD),
        .PrWD(PrWD),
        .PrByteEn(PrByteEn),
        .m_data_addr(m_data_addr),
        .m_data_rdata(m_data_rdata),
        .m_data_wdata(m_data_wdata),
        .m_data_byteen(m_data_byteen),
        .m_int_addr(m_int_addr),
        .m_int_byteen(m_int_byteen),
        .TC1_addr(TC1_addr),
        .TC1_we(TC1_we),
        .TC1_wdata(TC1_wdata),
        .TC1_rdata(TC1_rdata),
        .TC2_addr(TC2_addr),
        .TC2_we(TC2_we),
        .TC2_wdata(TC2_wdata),
        .TC2_rdata(TC2_rdata)
    );

    TC TC1(
        .clk(clk),
        .reset(reset),
        .Addr(TC1_addr),
        .WE(TC1_we),
        .Din(TC1_wdata),
        .Dout(TC1_rdata),
        .IRQ(TC1_IRQ)
    );

    TC TC2(
        .clk(clk),
        .reset(reset),
        .Addr(TC2_addr),
        .WE(TC2_we),
        .Din(TC2_wdata),
        .Dout(TC2_rdata),
        .IRQ(TC2_IRQ)
    );

endmodule