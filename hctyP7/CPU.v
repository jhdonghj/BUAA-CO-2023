`include "constants.v"

module CPU (
        input clk,
        input reset,
        input [5: 0] HWInt,

        output [31: 0] i_inst_addr,
        input [31: 0] i_inst_rdata,

        output [31: 0] m_data_addr,
        input [31: 0] m_data_rdata,
        output [31: 0] m_data_wdata,
        output [3: 0] m_data_byteen,

        output [31: 0] m_inst_addr,

        output w_grf_we,
        output [4: 0] w_grf_addr,
        output [31: 0] w_grf_wdata,

        output [31: 0] w_inst_addr,

        output [31: 0] macroscopic_pc,

        input DM_error,
        input IM_error
    );

    wire Req;
    wire [4: 0] F_ExcCode;
    wire [4: 0] D_ExcCode_in, D_ExcCode_out;
    wire [4: 0] E_ExcCode_in, E_ExcCode_out;
    wire [4: 0] M_ExcCode_in, M_ExcCode_out;
    wire D_BD, E_BD, M_BD;
    wire [31: 0] EPC;

    wire [31: 0] F_check, F_set;
    wire [31: 0] D_check_in, D_check_out, D_set_in, D_set_out;
    wire [31: 0] E_check_in, E_check_out, E_set_in, E_set_out;
    wire [31: 0] M_check_in, M_check_out, M_set_in, M_set_out;
    wire [31: 0] W_check, W_set;

    wire D_reg_reset, E_reg_reset, M_reg_reset, W_reg_reset;
    wire D_reg_en, E_reg_en, M_reg_en, W_reg_en;
    wire F_PC_en;
    wire stall;

    /*----------------Instruction Fetch----------------*/
    wire [31: 0] F_Instr, F_PrePC, F_PC, D_nPC;

    F_IFU F_IFU(
              .clk(clk),
              .reset(reset),
              .Req(Req),
              .WE(F_PC_en || Req),
              .nPC(D_nPC),

              .PC(F_PrePC)
          );

    assign F_PC =
           Req ? 32'h0000_4180 :
           (D_Br == `Br_eret) ? EPC :
           F_PrePC;
    assign i_inst_addr = F_PC;
    assign F_Instr = i_inst_rdata;

    assign F_ExcCode = IM_error ? `ExcCode_AdEL : 0;

    assign F_check = 0, F_set = 0;
    /*----------------Instruction Decode----------------*/
    wire [31: 0] D_Instr, D_PC, W_PC;
    wire [5: 0] D_op, D_func;

    wire [25: 0] D_imm26;
    wire [15: 0] D_imm16;
    wire [4: 0] D_rs, D_rt, D_rd;

    wire [31: 0] D_rs_val, D_rt_val, D_EXTOut;

    wire [31: 0] D_EXTOp, D_Br, D_CMPType;
    wire D_isTrue;

    wire D_syscall, D_unknow;

    wire W_RegWrite;
    wire [31: 0] W_RegData;
    wire [4: 0] W_RegAddr;

    D_REG D_REG(
              .clk(clk),
              .reset(reset || D_reg_reset),
              .WE(D_reg_en),
              .Req(Req),

              .BD_in(D_Br != `Br_default && D_Br != `Br_eret),
              .ExcCode_in(F_ExcCode),
              .BD_out(D_BD),
              .ExcCode_out(D_ExcCode_in),

              .Instr_in(F_Instr),
              .PC_in(F_PC),

              .Instr_out(D_Instr),
              .PC_out(D_PC),

              .check_in(F_check),
              .set_in(F_set),
              .check_out(D_check_in),
              .set_out(D_set_in)
          );

    SPLT D_SPLT(
             .Instr(D_Instr),

             .op(D_op),
             .func(D_func),
             .rs(D_rs),
             .rt(D_rt),
             .rd(D_rd),
             .imm16(D_imm16),
             .imm26(D_imm26)
         );
    CU D_CU(
           .check(D_check_in),
           .set(D_set_in),
           .Instr(D_Instr),
           .op(D_op),
           .func(D_func),

           .EXTOp(D_EXTOp),
           .Br(D_Br),
           .CMPType(D_CMPType),
           .syscall(D_syscall),
           .unknow(D_unknow)
       );

    D_GRF D_GRF(
              .PC(W_PC),

              .clk(clk),
              .reset(reset),

              .A1(D_rs),
              .A2(D_rt),

              .WE(W_RegWrite),
              .A3(W_RegAddr),
              .WD(W_RegData),

              .RD1(D_rs_val),
              .RD2(D_rt_val)
          );
    assign w_grf_we = W_RegWrite;
    assign w_grf_addr = W_RegAddr;
    assign w_grf_wdata = W_RegData;
    assign w_inst_addr = W_PC;

    D_EXT D_EXT(
              .EXTOp(D_EXTOp),
              .imm16(D_imm16),
              .EXTOut(D_EXTOut)
          );

    wire [31: 0] D_rs_fwd, D_rt_fwd;

    D_CMP D_CMP(
              .CMPType(D_CMPType),
              .rs(D_rs_fwd),
              .rt(D_rt_fwd),
              .isTrue(D_isTrue)
          );
    D_NPC D_NPC(
              .Req(Req),
              .EPC(EPC),
              .D_PC(D_PC),
              .F_PC(F_PC),
              .imm26(D_imm26),
              .ra(D_rs_fwd),
              .Br(D_Br),
              .isTrue(D_isTrue),
              .nPC(D_nPC)
          );

    assign D_ExcCode_out =
           D_syscall ? `ExcCode_Sys :
           D_unknow ? `ExcCode_RI :
           D_ExcCode_in;

    assign D_check_out = D_check_in;
    assign D_set_out = D_set_in;

    /*----------------Excute----------------*/
    wire [31: 0] E_Instr, E_PC;
    wire [5: 0] E_op, E_func;

    wire [31: 0] E_rs_val, E_rt_val, E_EXTOut;

    wire [31: 0] E_ALUOp, E_MDUOp, E_WDSel;
    wire E_ALUSrc, E_Ov;
    wire [31: 0] E_Busy;

    wire [31: 0] E_ALU_A, E_ALU_B;

    wire [31: 0] E_ALUOut, E_MDUOut;

    E_REG E_REG(
              .clk(clk),
              .reset(reset || E_reg_reset),
              .WE(E_reg_en),
              .stall(stall),
              .Req(Req),

              .BD_in(D_BD),
              .ExcCode_in(D_ExcCode_out),
              .BD_out(E_BD),
              .ExcCode_out(E_ExcCode_in),

              .PC_in(D_PC),
              .Instr_in(D_Instr),
              .rs_fwd_in(D_rs_fwd),
              .rt_fwd_in(D_rt_fwd),
              .EXT_in(D_EXTOut),

              .PC_out(E_PC),
              .Instr_out(E_Instr),
              .rs_val_out(E_rs_val),
              .rt_val_out(E_rt_val),
              .EXT_out(E_EXTOut),

              .check_in(D_check_out),
              .set_in(D_set_out),
              .check_out(E_check_in),
              .set_out(E_set_in)
          );

    SPLT E_SPLT(
             .Instr(E_Instr),

             .op(E_op),
             .func(E_func)
         );
    CU E_CU(
           .check(E_check_in),
           .set(E_set_in),
           .Instr(E_Instr),
           .op(E_op),
           .func(E_func),

           .ALUOp(E_ALUOp),
           .ALUSrc(E_ALUSrc),
           .MDUOp(E_MDUOp),
           .WDSel(E_WDSel)
       );

    wire [31: 0] E_rs_fwd, E_rt_fwd;

    assign E_ALU_A = E_rs_fwd;
    assign E_ALU_B =
           (E_ALUSrc == `ALU_RD2) ? E_rt_fwd :
           (E_ALUSrc == `ALU_imm) ? E_EXTOut :
           E_rt_fwd;

    E_ALU E_ALU(
              .ALUOp(E_ALUOp),
              .A(E_ALU_A),
              .B(E_ALU_B),
              .ALUOut(E_ALUOut),
              .Ov(E_Ov)
          );

    E_MDU E_MDU(
              .Req(Req),

              .clk(clk),
              .reset(reset),

              .MDUOp(E_MDUOp),
              .rs(E_rs_fwd),
              .rt(E_rt_fwd),
              .Busy(E_Busy),
              .MDUOut(E_MDUOut)
          );

    assign E_ExcCode_out =
           E_Ov ? `ExcCode_Ov :
           E_ExcCode_in;


    assign E_check_out = E_check_in;
    assign E_set_out = E_set_in;

    /*----------------Memory----------------*/
    wire [31: 0] M_Instr, M_PC;
    wire [5: 0] M_op, M_func;
    wire [4: 0] M_rd;

    wire [31: 0] M_DMType, M_WDSel;
    wire M_MemWrite, M_CP0Write, M_eret;
    wire M_store, M_load;
    wire [31: 0] M_rt_val, M_EXTOut, M_ALUOut, M_MDUOut, M_CP0Out;

    wire [31: 0] M_DMOut;

    M_REG M_REG(
              .clk(clk),
              .reset(reset || M_reg_reset),
              .WE(M_reg_en),
              .Req(Req),

              .BD_in(E_BD),
              .ExcCode_in(E_ExcCode_out),
              .BD_out(M_BD),
              .ExcCode_out(M_ExcCode_in),

              .PC_in(E_PC),
              .Instr_in(E_Instr),
              .rt_fwd_in(E_rt_fwd),
              .EXT_in(E_EXTOut),
              .ALU_in(E_ALUOut),
              .MDU_in(E_MDUOut),

              .PC_out(M_PC),
              .Instr_out(M_Instr),
              .rt_val_out(M_rt_val),
              .EXT_out(M_EXTOut),
              .ALU_out(M_ALUOut),
              .MDU_out(M_MDUOut),

              .check_in(E_check_out),
              .set_in(E_set_out),
              .check_out(M_check_in),
              .set_out(M_set_in)
          );

    SPLT M_SPLT(
             .Instr(M_Instr),

             .op(M_op),
             .func(M_func),
             .rd(M_rd)
         );
    CU M_CU(
           .check(M_check_in),
           .set(M_set_in),

           .Instr(M_Instr),
           .op(M_op),
           .func(M_func),

           .DMType(M_DMType),
           .WDSel(M_WDSel),
           .CP0Write(M_CP0Write),
           .eret(M_eret),
           .store(M_store),
           .load(M_load)
       );

    wire [31: 0] M_rt_fwd;


    assign m_inst_addr = M_PC;
    assign m_data_addr = M_ALUOut;
    assign m_data_wdata = M_rt_fwd << (8 * m_data_addr[1 : 0]);
    assign m_data_byteen =
           Req ? 0 :
           (M_DMType == `DM_sb) ? 1 << m_data_addr[1 : 0] :
           (M_DMType == `DM_sh) ? 3 << m_data_addr[1 : 0] :
           (M_DMType == `DM_sw) ? 15 :
           0;
    wire [31: 0] M_fixed_rdata = m_data_rdata >> (8 * m_data_addr[1 : 0]);
    assign M_DMOut =
           (M_DMType == `DM_lb) ? {{24{M_fixed_rdata[7]}}, M_fixed_rdata[7 : 0]} :
           (M_DMType == `DM_lh) ? {{16{M_fixed_rdata[15]}}, M_fixed_rdata[15 : 0]} :
           (M_DMType == `DM_lw) ? M_fixed_rdata :
           32'h0;

    wire half_error = (M_DMType == `DM_sh || M_DMType == `DM_lh)
         && (m_data_addr[0] != 1'b0);
    wire word_error = (M_DMType == `DM_sw || M_DMType == `DM_lw)
         && (m_data_addr[1 : 0] != 2'b00);
    wire timer_error = (M_DMType != `DM_sw && M_DMType != `DM_lw)
         && ((m_data_addr >= `TC1_StartAddr) && (m_data_addr <= `TC1_EndAddr)
             || (m_data_addr >= `TC2_StartAddr) && (m_data_addr <= `TC2_EndAddr));
    wire counter_error = (M_DMType == `DM_sw)
         && (m_data_addr == 32'h0000_7F08 || m_data_addr == 32'h0000_7F18);

    assign M_ExcCode_out =
           (M_ExcCode_in == `ExcCode_Ov || DM_error || half_error || word_error || timer_error || counter_error) ?
           (M_store ? `ExcCode_AdES :
           M_load ? `ExcCode_AdEL :
       M_ExcCode_in) :
           M_ExcCode_in;

    M_CP0 M_CP0(
              .clk(clk),
              .reset(reset),
              .WE(M_CP0Write),
              .CP0Addr(M_rd),
              .CP0In(M_rt_fwd),
              .CP0Out(M_CP0Out),
              .VPC(M_PC),
              .BDIn(M_BD),
              .ExcCodeIn(M_ExcCode_out),
              .HWInt(HWInt),
              .EXLClr(M_eret),
              .EPCOut(EPC),
              .Req(Req)
          );


    assign M_check_out = M_check_in;
    assign M_set_out = M_set_in;


    assign macroscopic_pc = M_PC;


    /*----------------Write Back----------------*/
    wire [31: 0] W_Instr;
    wire [5: 0] W_op, W_func;

    wire [31: 0] W_EXTOut, W_ALUOut, W_MDUOut, W_DMOut, W_CP0Out;

    wire [31: 0] W_RegDst, W_WDSel;

    wire [4: 0] W_rt, W_rd;

    W_REG W_REG(
              .clk(clk),
              .reset(reset || W_reg_reset),
              .WE(W_reg_en),
              .Req(Req),

              .PC_in(M_PC),
              .Instr_in(M_Instr),
              .EXT_in(M_EXTOut),
              .ALU_in(M_ALUOut),
              .MDU_in(M_MDUOut),
              .DM_in(M_DMOut),
              .CP0_in(M_CP0Out),

              .PC_out(W_PC),
              .Instr_out(W_Instr),
              .EXT_out(W_EXTOut),
              .ALU_out(W_ALUOut),
              .MDU_out(W_MDUOut),
              .DM_out(W_DMOut),
              .CP0_out(W_CP0Out),

              .check_in(M_check_out),
              .set_in(M_set_out),
              .check_out(W_check),
              .set_out(W_set)
          );

    SPLT W_SPLT(
             .Instr(W_Instr),

             .op(W_op),
             .func(W_func),
             .rt(W_rt),
             .rd(W_rd)
         );
    CU W_CU(
           .check(W_check),
           .set(W_set),
           .Instr(W_Instr),
           .op(W_op),
           .func(W_func),

           .RegWrite(W_RegWrite),
           .RegDst(W_RegDst),
           .WDSel(W_WDSel)
       );

    assign W_RegAddr =
           (W_RegDst == `A3_rd) ? W_rd :
           (W_RegDst == `A3_rt) ? W_rt :
           (W_RegDst == `A3_ra) ? 31 :
           0;
    assign W_RegData =
           (W_WDSel == `WD_ext) ? W_EXTOut :
           (W_WDSel == `WD_alu) ? W_ALUOut :
           (W_WDSel == `WD_mdu) ? W_MDUOut :
           (W_WDSel == `WD_mem) ? W_DMOut :
           (W_WDSel == `WD_cp0) ? W_CP0Out :
           (W_WDSel == `WD_pc8) ? W_PC + 8 :
           0;

    /*----------------Hazard Detection----------------*/
    wire [31: 0] D_rs_sel, D_rt_sel, E_rs_sel, E_rt_sel, M_rt_sel;
    wire Pre_stall;

    HU HU(
           .D_check(D_check_in),
           .D_set(D_set_in),
           .E_check(E_check_in),
           .E_set(E_set_in),
           .M_check(M_check_in),
           .M_set(M_set_in),

           .D_Instr(D_Instr),
           .E_Instr(E_Instr),
           .M_Instr(M_Instr),
           .W_RegAddr(W_RegAddr),
           .W_RegWrite(W_RegWrite),
           .E_Busy(E_Busy),

           .stall(Pre_stall),
           .D_rs_sel(D_rs_sel),
           .D_rt_sel(D_rt_sel),
           .E_rs_sel(E_rs_sel),
           .E_rt_sel(E_rt_sel),
           .M_rt_sel(M_rt_sel)
       );


    assign stall = Pre_stall;
    assign F_PC_en = !stall;
    assign D_reg_en = !stall;
    assign E_reg_reset = stall;
    assign E_reg_en = 1'b1, M_reg_en = 1'b1, W_reg_en = 1'b1;
    assign D_reg_reset = 1'b0, M_reg_reset = 1'b0, W_reg_reset = 1'b0;

    /*----------------Forward----------------*/

    wire [31: 0] M_RegData =
         (M_WDSel == `WD_ext) ? M_EXTOut :
         (M_WDSel == `WD_alu) ? M_ALUOut :
         (M_WDSel == `WD_mdu) ? M_MDUOut :
         //  (M_WDSel == `WD_mem) ? M_DMOut :
         (M_WDSel == `WD_pc8) ? M_PC + 8 :
         0;
    wire [31: 0] E_RegData =
         (E_WDSel == `WD_ext) ? E_EXTOut :
         //  (E_WDSel == `WD_alu) ? E_ALUOut :
         // (E_WDSel == `WD_mdu) ? E_MDUOut :
         (E_WDSel == `WD_pc8) ? E_PC + 8 :
         0;
    assign D_rs_fwd =
           (D_rs_sel == `FWD_E) ? E_RegData :
           (D_rs_sel == `FWD_M) ? M_RegData :
           (D_rs_sel == `FWD_W) ? W_RegData :
           D_rs_val;
    assign D_rt_fwd =
           (D_rt_sel == `FWD_E) ? E_RegData :
           (D_rt_sel == `FWD_M) ? M_RegData :
           (D_rt_sel == `FWD_W) ? W_RegData :
           D_rt_val;
    assign E_rs_fwd =
           (E_rs_sel == `FWD_E) ? E_RegData :
           (E_rs_sel == `FWD_M) ? M_RegData :
           (E_rs_sel == `FWD_W) ? W_RegData :
           E_rs_val;
    assign E_rt_fwd =
           (E_rt_sel == `FWD_E) ? E_RegData :
           (E_rt_sel == `FWD_M) ? M_RegData :
           (E_rt_sel == `FWD_W) ? W_RegData :
           E_rt_val;
    assign M_rt_fwd =
           (M_rt_sel == `FWD_E) ? E_RegData :
           (M_rt_sel == `FWD_M) ? M_RegData :
           (M_rt_sel == `FWD_W) ? W_RegData :
           M_rt_val;

endmodule
