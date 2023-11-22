`include "constants.v"

module mips(
        input clk,                       //! Clock
        input reset,                     //! Reset
        input interrupt,                 //! Interrupt
        output [31: 0] macroscopic_pc,   //! Macroscopic PC

        output [31: 0] i_inst_addr,      //! Instruction Memory Address
        input [31: 0] i_inst_rdata,      //! Instruction Memory Data

        output [31: 0] m_data_addr,      //! Data Memory Address
        input [31: 0] m_data_rdata,      //! Data Memory Data
        output [31: 0] m_data_wdata,     //! Data Memory Write Data
        output [3 : 0] m_data_byteen,    //! Data Memory Byte Enable

        output [31: 0] m_int_addr,       //! Interrupt Memory Address
        output [3 : 0] m_int_byteen,     //! Interrupt Memory Byte Enable

        output [31: 0] m_inst_addr,      //! Instruction Memory Address

        output w_grf_we,                 //! GRF Write Enable
        output [4 : 0] w_grf_addr,       //! GRF Write Address
        output [31: 0] w_grf_wdata,      //! GRF Write Data

        output [31: 0] w_inst_addr       //! Instruction Memory Address
    );

    wire [31: 0] PrAddr, PrRD, PrWD ;
    wire [3: 0] PrByteEn;

    wire [31: 0] PrPC, PrInstr;

    assign IM_error = (PrPC > `IM_EndAddr) || (PrPC < `IM_StartAddr) || (PrPC[1: 0] != 2'b00);
    assign i_inst_addr = IM_error ? 32'h3000 : PrPC;
    assign PrInstr = IM_error ? 32'h00000000 : i_inst_rdata;

    CPU CPU(
            .clk(clk),
            .reset(reset),
            .HWInt(HWInt),

            .i_inst_addr(PrPC),
            .i_inst_rdata(PrInstr),

            .m_data_addr(PrAddr),
            .m_data_rdata(PrRD),
            .m_data_wdata(PrWD),
            .m_data_byteen(PrByteEn),

            .m_inst_addr(m_inst_addr),

            .w_grf_we(w_grf_we),
            .w_grf_addr(w_grf_addr),
            .w_grf_wdata(w_grf_wdata),

            .w_inst_addr(w_inst_addr),

            .macroscopic_pc(macroscopic_pc),

            .DM_error(DM_error),
            .IM_error(IM_error)
        );

    wire [5: 0] HWInt = {3'b0, interrupt, TC2IRQ, TC1IRQ};

    wire [31: 0] TC1Out, TC2Out;
    wire TC1IRQ, TC2IRQ;

    wire count_error_1 = 0;
    wire count_error_2 = 0;
    // wire count_error_1 = ( & PrByteEn) && (PrAddr == 32'h0000_7F08);
    // wire count_error_2 = ( & PrByteEn) && (PrAddr == 32'h0000_7F18);


    wire [31: 0] BridgeSel =
         (PrAddr >= `DM_StartAddr) && (PrAddr <= `DM_EndAddr) ?
         `Bridge_DM :
         (PrAddr >= `TC1_StartAddr) && (PrAddr <= `TC1_EndAddr) &&
         (PrAddr[1 : 0] == 0) && (!count_error_1) ?
         `Bridge_TC1 :
         (PrAddr >= `TC2_StartAddr) && (PrAddr <= `TC2_EndAddr) &&
         (PrAddr[1 : 0] == 0) && (!count_error_2) ?
         `Bridge_TC2 :
         (PrAddr >= `Int_StartAddr) && (PrAddr <= `Int_EndAddr) ? `Bridge_Int :
         `Bridge_error ;

    wire DM_error = (BridgeSel == `Bridge_error);

    assign m_data_byteen = (BridgeSel == `Bridge_DM) ? PrByteEn : 4'b0000;
    assign m_int_byteen = (BridgeSel == `Bridge_Int) ? PrByteEn : 4'b0000;
    wire TC1WE = (BridgeSel == `Bridge_TC1) && ( & PrByteEn);
    wire TC2WE = (BridgeSel == `Bridge_TC2) && ( & PrByteEn);

    assign PrRD =
           (BridgeSel == `Bridge_DM) ? m_data_rdata :
           (BridgeSel == `Bridge_TC1) ? TC1Out :
           (BridgeSel == `Bridge_TC2) ? TC2Out :
           114514;


    assign m_data_addr = PrAddr;
    assign m_data_wdata = PrWD;

    assign m_int_addr = PrAddr;

    TC TC1(
           .clk(clk),
           .reset(reset),
           .Addr(PrAddr[31: 2]),
           .WE(TC1WE),
           .Din(PrWD),
           .Dout(TC1Out),
           .IRQ(TC1IRQ)
       );

    TC TC2(
           .clk(clk),
           .reset(reset),
           .Addr(PrAddr[31: 2]),
           .WE(TC2WE),
           .Din(PrWD),
           .Dout(TC2Out),
           .IRQ(TC2IRQ)
       );

endmodule
