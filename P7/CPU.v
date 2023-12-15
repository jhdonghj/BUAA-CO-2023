`timescale 1ns / 1ps
`include "defines.v"

module CPU(
    input clk,
    input reset,
    
    output [31:0] i_inst_addr,
    input [31:0] i_inst_rdata,
    
    output [31:0] m_data_addr,
    input [31:0] m_data_rdata,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,

    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr,

    input [5:0] HWInt,
    output [31:0] macroscopic_pc
);
    wire rst;
    assign rst = reset;
    // wire declearation
    wire [31:0] F_pc, D_pc, E_pc, M_pc, W_pc;
    wire [31:0] F_instr, D_instr, E_instr, M_instr, W_instr;
    wire [31:0] D_EXTout, E_EXTout, M_EXTout, W_EXTout;
    wire [31:0] D_RD1, D_RD2, E_RD1, E_RD2, E_RD1_REG, E_RD2_REG, M_RD2;
    wire [31:0] E_ALUout, M_ALUout, W_ALUout, E_HILOout, M_HILOout, W_HILOout;
    wire [31:0] M_DMout, W_DMout, M_RD2_REG, D_RD1_GRF, D_RD2_GRF;
    wire [31:0] npc, E_Val, M_Val, W_Val;
    wire [4:0] E_Dst, M_Dst, W_Dst, D_rs, D_rt, E_rs, E_rt, M_rt, M_rd;

    wire D_isBrch, E_ALUSrc, M_MemWrite, E_RegWrite, M_RegWrite, W_RegWrite;
    wire [2:0] D_CMPOp, D_EXTOp, E_RD1_FOR, E_RD2_FOR, M_DMOp, M_BEOp;
    wire [2:0] E_WD3Sel, M_WD3Sel, W_A3Sel, W_WD3Sel, E_Tnew, M_Tnew, W_Tnew;
    wire [3:0] D_NPCOp;
    wire [4:0] E_ALUOp, E_HILOOp;
    assign W_Tnew = 3'd0;
    
    wire D_REG_WE, E_REG_WE, M_REG_WE, W_REG_WE, stall;
    wire D_REG_RST, E_REG_RST, M_REG_RST, W_REG_RST, E_HILObusy;
    assign D_REG_WE = !stall, E_REG_WE = 1'b1, M_REG_WE = 1'b1, W_REG_WE = 1'b1;
    assign D_REG_RST = 1'b0, E_REG_RST = stall, M_REG_RST = 1'b0, W_REG_RST = 1'b0;

    wire [31:0] F_pc_tmp, EPC, M_CP0out, W_CP0out;
    wire [4:0] F_ExcCode, D_ExcCode_REG, D_ExcCode, E_ExcCode_REG;
    wire [4:0] E_ExcCode, M_ExcCode_REG, M_ExcCode;
    wire Req, IM_Err, E_Ov, F_BD, D_BD, E_BD, M_BD;
    wire D_syscall, D_unknow, M_store, M_load, M_eret;
    wire DM_addr, timer_addr, int_addr, count_addr, M_AdEL, M_AdEs;

    CONF conf(
        .D_instr(D_instr),
        .E_instr(E_instr),
        .M_instr(M_instr),
        .E_HILObusy(E_HILObusy),
        .stall(stall)
    );
    // F-stage
    F_PC F_pc1(
        .clk(clk),
        .rst(rst),
        .WE(!stall || Req),
        .npc(npc),
        .pc(F_pc_tmp)
    );
    assign F_pc = Req ? 32'h4180 :
                    D_NPCOp == `NPC_ERET ? EPC :
                    F_pc_tmp;
    assign i_inst_addr = IM_err ? 32'h3000 : F_pc;
    assign F_instr = IM_err ? 32'h0 : i_inst_rdata;

    assign IM_err = F_pc[1:0] != 2'b00 || F_pc > `IM_EndAddr || F_pc < `IM_Addr;
    assign F_ExcCode = IM_err ? `ExcCode_AdEL : 5'b0;
    assign F_BD = D_NPCOp != `NPC_ADD4 && D_NPCOp != `NPC_ERET;
    // D-stage
    D_REG D_reg(
        .clk(clk),
        .rst(rst | D_REG_RST),
        .WE(D_REG_WE),
        .Req(Req),
        .F_instr(F_instr),
        .F_pc(F_pc),
        .F_ExcCode(F_ExcCode),
        .F_BD(F_BD),
        .D_instr(D_instr),
        .D_pc(D_pc),
        .D_ExcCode(D_ExcCode_REG),
        .D_BD(D_BD)
    );
    D_GRF D_grf(
        .clk(clk),
        .rst(rst),
        .WE3(W_RegWrite),
        .A1(D_instr[25:21]),
        .A2(D_instr[20:16]),
        .A3(W_Dst),
        .WD3(W_Val),
        .RD1(D_RD1_GRF),
        .RD2(D_RD2_GRF)
    );
    assign w_grf_we = W_RegWrite;
    assign w_grf_addr = W_Dst;
    assign w_grf_wdata = W_Val;
    assign w_inst_addr = W_pc;
    D_EXT D_ext(
        .Input(D_instr[15:0]),
        .EXTOp(D_EXTOp),
        .Output(D_EXTout)
    );
    D_CMP D_cmp( // stall
        .A(D_RD1),
        .B(D_RD2),
        .CMPOp(D_CMPOp),
        .isBrch(D_isBrch)
    );
    D_NPC D_npc(
        .Req(Req),
        .EPC(EPC),
        .F_pc(F_pc),
        .D_pc(D_pc),
        .imm16(D_instr[15:0]),
        .imm26(D_instr[25:0]),
        .NPCOp(D_NPCOp),
        .RD1(D_RD1),
        .isBrch(D_isBrch),
        .npc(npc)
    );
    CTRL D_ctrl(
        .instr(D_instr),
        .EXTOp(D_EXTOp),
        .CMPOp(D_CMPOp),
        .NPCOp(D_NPCOp),
        .rs(D_rs),
        .rt(D_rt),
        .syscall(D_syscall),
        .unknow(D_unknow)
    );
    wire FOR_E2D_RS = E_Tnew == 3'b0 && E_RegWrite && E_Dst == D_rs && D_rs;
    wire FOR_E2D_RT = E_Tnew == 3'b0 && E_RegWrite && E_Dst == D_rt && D_rt;
    wire FOR_M2D_RS = M_Tnew == 3'b0 && M_RegWrite && M_Dst == D_rs && D_rs;
    wire FOR_M2D_RT = M_Tnew == 3'b0 && M_RegWrite && M_Dst == D_rt && D_rt;
    assign D_RD1 = FOR_E2D_RS ? E_Val :
                    FOR_M2D_RS ? M_Val :
                    D_RD1_GRF;
    assign D_RD2 = FOR_E2D_RT ? E_Val :
                    FOR_M2D_RT ? M_Val :
                    D_RD2_GRF;
    assign D_ExcCode = D_ExcCode_REG ? D_ExcCode_REG :
                        D_syscall ? `ExcCode_Sys :
                        D_unknow ? `ExcCode_RI :
                        5'b0;
    wire [31:0] D_instr_out = D_unknow ? 32'h0 : D_instr;
    // E-stage
    E_REG E_reg(
        .clk(clk),
        .rst(rst | E_REG_RST),
        .WE(E_REG_WE),
        .stall(stall),
        .Req(Req),
        .D_instr(D_instr_out),
        .D_pc(D_pc),
        .D_EXTout(D_EXTout),
        .D_RD1(D_RD1),
        .D_RD2(D_RD2),
        .D_BD(D_BD),
        .D_ExcCode(D_ExcCode),
        .E_instr(E_instr),
        .E_pc(E_pc),
        .E_EXTout(E_EXTout),
        .E_RD1(E_RD1_REG),
        .E_RD2(E_RD2_REG),
        .E_BD(E_BD),
        .E_ExcCode(E_ExcCode_REG)
    );
    E_ALU E_alu(
        .A(E_RD1),
        .B(E_ALUSrc ? E_EXTout : E_RD2),
        .ALUOp(E_ALUOp),
        .C(E_ALUout),
        .Ov(E_Ov)
    );
    E_HILO E_hilo(
        .Req(Req),
        .clk(clk),
        .rst(rst),
        .A(E_RD1),
        .B(E_RD2),
        .HILOOp(E_HILOOp),
        .HILOout(E_HILOout),
        .HILObusy(E_HILObusy)
    );
    CTRL E_ctrl(
        .instr(E_instr),
        .ALUOp(E_ALUOp),
        .ALUSrc(E_ALUSrc),
        .WD3Sel(E_WD3Sel),
        .RegWrite(E_RegWrite),
        .HILOOp(E_HILOOp),
        .Dst(E_Dst),
        .rs(E_rs),
        .rt(E_rt),
        .E_Tnew(E_Tnew)
    );
    assign E_Val = E_WD3Sel == `WD3Sel_ALUout ? E_ALUout :
                    // E_WD3Sel == `WD3Sel_DMout ? E_DMout :
                    E_WD3Sel == `WD3Sel_PC8 ? E_pc + 8 :
                    E_WD3Sel == `WD3Sel_HILO ? E_HILOout : 32'd0;
    wire FOR_M2E_RS = M_Tnew == 3'b0 && M_RegWrite && M_Dst == E_rs && E_rs;
    wire FOR_M2E_RT = M_Tnew == 3'b0 && M_RegWrite && M_Dst == E_rt && E_rt;
    wire FOR_W2E_RS = W_Tnew == 3'b0 && W_RegWrite && W_Dst == E_rs && E_rs;
    wire FOR_W2E_RT = W_Tnew == 3'b0 && W_RegWrite && W_Dst == E_rt && E_rt;
    assign E_RD1 = FOR_M2E_RS ? M_Val :
                    FOR_W2E_RS ? W_Val :
                    E_RD1_REG;
    assign E_RD2 = FOR_M2E_RT ? M_Val :
                    FOR_W2E_RT ? W_Val :
                    E_RD2_REG;

    assign E_ExcCode = E_ExcCode_REG ? E_ExcCode_REG :
                        E_Ov ? `ExcCode_Ov :
                        5'b0;
    // M-stage
    M_REG M_reg(
        .clk(clk),
        .rst(rst | M_REG_RST),
        .WE(M_REG_WE),
        .Req(Req),
        .E_instr(E_instr),
        .E_pc(E_pc),
        .E_EXTout(E_EXTout),
        .E_ALUout(E_ALUout),
        .E_RD2(E_RD2),
        .E_HILOout(E_HILOout),
        .E_BD(E_BD),
        .E_ExcCode(E_ExcCode),
        .M_instr(M_instr),
        .M_pc(M_pc),
        .M_EXTout(M_EXTout),
        .M_ALUout(M_ALUout),
        .M_RD2(M_RD2_REG),
        .M_HILOout(M_HILOout),
        .M_BD(M_BD),
        .M_ExcCode(M_ExcCode_REG)
    );
    wire [31:0] M_dm_addr = M_ALUout;
    M_DM M_dm(
        .MemWrite(M_MemWrite & !Req),
        .DMOp(M_DMOp),
        .A(M_dm_addr),
        .WD(M_RD2),
        .m_data_addr(m_data_addr),
        .m_data_wdata(m_data_wdata),
        .m_data_byteen(m_data_byteen)
    );
    M_BE M_be(
        .A(M_ALUout[1:0]),
        .Din(m_data_rdata),
        .BEOp(M_BEOp),
        .Dout(M_DMout)
    );
    assign m_inst_addr = M_pc;
    CTRL M_ctrl(
        .instr(M_instr),
        .MemWrite(M_MemWrite),
        .WD3Sel(M_WD3Sel),
        .RegWrite(M_RegWrite),
        .DMOp(M_DMOp),
        .BEOp(M_BEOp),
        .CP0Write(M_CP0Write),
        .Dst(M_Dst),
        .M_Tnew(M_Tnew),
        .rt(M_rt),
        .rd(M_rd),
        .store(M_store),
        .load(M_load),
        .eret(M_eret)
    );
    assign M_Val = M_WD3Sel == `WD3Sel_ALUout ? M_ALUout :
                    M_WD3Sel == `WD3Sel_DMout ? M_DMout :
                    M_WD3Sel == `WD3Sel_PC8 ? M_pc + 8 :
                    M_WD3Sel == `WD3Sel_HILO ? M_HILOout :
                    M_WD3Sel == `WD3Sel_CP0 ? M_CP0out :
                    32'd0;
    wire FOR_W2M_RT = W_Tnew == 3'b0 && W_RegWrite && W_Dst == M_rt && M_rt;
    assign M_RD2 = FOR_W2M_RT ? W_Val :
                    M_RD2_REG;

    CP0 M_cp0(
        .clk(clk),
        .rst(rst),
        .WE(M_CP0Write),
        .A(M_rd),
        .Din(M_RD2),
        .Dout(M_CP0out),
        .VPC(M_pc),
        .BDIn(M_BD),
        .ExcCodeIn(M_ExcCode),
        .HWInt(HWInt),
        .EXLClr(M_eret),
        .EPCout(EPC),
        .Req(Req)
    );
    assign DM_addr = `DM_Addr <= M_dm_addr && M_dm_addr <= `DM_EndAddr;
    assign timer_addr = (`TC1_Addr <= M_dm_addr && M_dm_addr <= `TC1_EndAddr) ||
                        (`TC2_Addr <= M_dm_addr && M_dm_addr <= `TC2_EndAddr);
    assign int_addr = `INT_Addr <= M_dm_addr && M_dm_addr <= `INT_EndAddr;
    assign count_addr = M_dm_addr == `TC1_Count_Addr || M_dm_addr == `TC2_Count_Addr;
    assign M_AdEL = (M_DMOp == `DM_LW && M_dm_addr[1:0] != 2'b00) ||
                    (M_DMOp == `DM_LH && M_dm_addr[0] != 1'b0) ||
                    ((M_DMOp == `DM_LH || M_DMOp == `DM_LB) && timer_addr) ||
                    (M_load && !DM_addr && !timer_addr && !int_addr);
    assign M_AdEs = (M_DMOp == `DM_SW && M_dm_addr[1:0] != 2'b00) ||
                    (M_DMOp == `DM_SH && M_dm_addr[0] != 1'b0) ||
                    ((M_DMOp == `DM_SH || M_DMOp == `DM_SB) && timer_addr) ||
                    (M_store && count_addr) ||
                    (M_store && !DM_addr && !timer_addr && !int_addr);
    assign M_ExcCode = M_ExcCode_REG == `ExcCode_Ov ?
                           (M_store ? `ExcCode_AdES :
                            M_load ? `ExcCode_AdEL :
                            M_ExcCode_REG) :
                        M_ExcCode_REG ? M_ExcCode_REG :
                        M_AdEL ? `ExcCode_AdEL :
                        M_AdEs ? `ExcCode_AdES :
                        5'b0;

    assign macroscopic_pc = M_pc;
    // W-stage
    W_REG W_reg(
        .clk(clk),
        .rst(rst | W_REG_RST),
        .WE(W_REG_WE),
        .Req(Req),
        .M_instr(M_instr),
        .M_pc(M_pc),
        .M_EXTout(M_EXTout),
        .M_ALUout(M_ALUout),
        .M_DMout(M_DMout),
        .M_HILOout(M_HILOout),
        .M_CP0out(M_CP0out),
        .W_instr(W_instr),
        .W_pc(W_pc),
        .W_EXTout(W_EXTout),
        .W_ALUout(W_ALUout),
        .W_DMout(W_DMout),
        .W_HILOout(W_HILOout),
        .W_CP0out(W_CP0out)
    );
    CTRL W_ctrl(
        .instr(W_instr),
        .WD3Sel(W_WD3Sel),
        .A3Sel(W_A3Sel),
        .RegWrite(W_RegWrite),
        .Dst(W_Dst)
    );
    assign W_Val = W_WD3Sel == `WD3Sel_ALUout ? W_ALUout :
                    W_WD3Sel == `WD3Sel_DMout ? W_DMout :
                    W_WD3Sel == `WD3Sel_PC8 ? W_pc + 8 :
                    W_WD3Sel == `WD3Sel_HILO ? W_HILOout :
                    W_WD3Sel == `WD3Sel_CP0 ? W_CP0out :
                    32'd0;

endmodule
