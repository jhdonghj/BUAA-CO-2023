`timescale 1ns / 1ps
`include "defines.v"

module mips(
        input clk,
        input reset
    );
    wire rst;
    assign rst = reset;
    // wire declearation
    wire [31:0] F_pc, D_pc, E_pc, M_pc, W_pc;
    wire [31:0] F_instr, D_instr, E_instr, M_instr, W_instr;
    wire [31:0] D_EXTout, E_EXTout, M_EXTout, W_EXTout;
    wire [31:0] D_RD1, D_RD2, E_RD1, E_RD2, E_RD1_REG, E_RD2_REG, M_RD2;
    wire [31:0] E_ALUout, M_ALUout, W_ALUout;
    wire [31:0] M_DMout, W_DMout, M_RD2_REG, D_RD1_GRF, D_RD2_GRF;
    wire [31:0] npc, E_Val, M_Val, W_Val;
    wire [4:0] E_Dst, M_Dst, W_Dst, D_rs, D_rt, E_rs, E_rt, M_rt;

    wire D_isBrch, E_ALUSrc, M_MemWrite, E_RegWrite, M_RegWrite, W_RegWrite;
    wire [2:0] D_CMPOp, D_EXTOp, E_RD1_FOR, E_RD2_FOR, M_DMop;
    wire [2:0] E_WD3Sel, M_WD3Sel, W_A3Sel, W_WD3Sel, E_Tnew, M_Tnew, W_Tnew;
    wire [3:0] D_NPCOp;
    wire [4:0] E_ALUOp;
    assign W_Tnew = 3'd0;
    
    wire D_REG_WE, E_REG_WE, M_REG_WE, W_REG_WE, stall;
    wire D_REG_RST, E_REG_RST, M_REG_RST, W_REG_RST;
    assign D_REG_WE = !stall, E_REG_WE = 1'b1, M_REG_WE = 1'b1, W_REG_WE = 1'b1;
    assign D_REG_RST = 1'b0, E_REG_RST = stall, M_REG_RST = 1'b0, W_REG_RST = 1'b0;

    CONF conf(
        .D_instr(D_instr),
        .E_instr(E_instr),
        .M_instr(M_instr),
        .stall(stall)
    );
    // F-stage
    F_IFU F_ifu(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .npc(npc),
        .instr(F_instr),
        .pc(F_pc)
    );
    // D-stage
    D_REG D_reg(
        .clk(clk),
        .rst(rst | D_REG_RST),
        .WE(D_REG_WE),
        .F_instr(F_instr),
        .F_pc(F_pc),
        .D_instr(D_instr),
        .D_pc(D_pc)
    );
    D_GRF D_grf(
        .clk(clk),
        .rst(rst),
        .WE3(W_RegWrite),
        .A1(D_instr[25:21]),
        .A2(D_instr[20:16]),
        .A3(W_Dst),
        .WD3(W_Val),
        .pc(W_pc),
        .RD1(D_RD1_GRF),
        .RD2(D_RD2_GRF)
    );
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
        .rt(D_rt)
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
    // E-stage
    E_REG E_reg(
        .clk(clk),
        .rst(rst | E_REG_RST),
        .WE(E_REG_WE),
        .D_instr(D_instr),
        .D_pc(D_pc),
        .D_EXTout(D_EXTout),
        .D_RD1(D_RD1),
        .D_RD2(D_RD2),
        .E_instr(E_instr),
        .E_pc(E_pc),
        .E_EXTout(E_EXTout),
        .E_RD1(E_RD1_REG),
        .E_RD2(E_RD2_REG)
    );
    E_ALU E_alu(
        .A(E_RD1),
        .B(E_ALUSrc ? E_EXTout : E_RD2),
        .ALUOp(E_ALUOp),
        .C(E_ALUout)
    );
    CTRL E_ctrl(
        .instr(E_instr),
        .ALUOp(E_ALUOp),
        .ALUSrc(E_ALUSrc),
        .WD3Sel(E_WD3Sel),
        .RegWrite(E_RegWrite),
        .Dst(E_Dst),
        .rs(E_rs),
        .rt(E_rt),
        .E_Tnew(E_Tnew)
    );
    assign E_Val = E_WD3Sel == `WD3Sel_ALUout ? E_ALUout :
                    // E_WD3Sel == `WD3Sel_DMout ? E_DMout :
                    E_WD3Sel == `WD3Sel_PC8 ? E_pc + 8 : 32'd0;
    wire FOR_M2E_RS = (M_Tnew == 3'b0 && M_RegWrite && M_Dst == E_rs && E_rs);
    wire FOR_M2E_RT = (M_Tnew == 3'b0 && M_RegWrite && M_Dst == E_rt && E_rt);
    wire FOR_W2E_RS = (W_Tnew == 3'b0 && W_RegWrite && W_Dst == E_rs && E_rs);
    wire FOR_W2E_RT = (W_Tnew == 3'b0 && W_RegWrite && W_Dst == E_rt && E_rt);
    assign E_RD1 = FOR_M2E_RS ? M_Val :
                    FOR_W2E_RS ? W_Val :
                    E_RD1_REG;
    assign E_RD2 = FOR_M2E_RT ? M_Val :
                    FOR_W2E_RT ? W_Val :
                    E_RD2_REG;
    // M-stage
    M_REG M_reg(
        .clk(clk),
        .rst(rst | M_REG_RST),
        .WE(M_REG_WE),
        .E_instr(E_instr),
        .E_pc(E_pc),
        .E_EXTout(E_EXTout),
        .E_ALUout(E_ALUout),
        .E_RD2(E_RD2),
        .M_instr(M_instr),
        .M_pc(M_pc),
        .M_EXTout(M_EXTout),
        .M_ALUout(M_ALUout),
        .M_RD2(M_RD2_REG)
    );
    M_DM M_dm(
        .clk(clk),
        .rst(rst),
        .WE(M_MemWrite),
        .A(M_ALUout),
        .WD(M_RD2),
        .DMOp(M_DMop),
        .pc(M_pc),
        .RD(M_DMout)
    );
    CTRL M_ctrl(
        .instr(M_instr),
        .MemWrite(M_MemWrite),
        .WD3Sel(M_WD3Sel),
        .RegWrite(M_RegWrite),
        .DMOp(M_DMop),
        .Dst(M_Dst),
        .M_Tnew(M_Tnew),
        .rt(M_rt)
    );
    assign M_Val = M_WD3Sel == `WD3Sel_ALUout ? M_ALUout :
                    M_WD3Sel == `WD3Sel_DMout ? M_DMout :
                    M_WD3Sel == `WD3Sel_PC8 ? M_pc + 8 : 32'd0;
    wire FOR_W2M_RT = (W_Tnew == 3'b0 && W_RegWrite && W_Dst == M_rt && M_rt);
    assign M_RD2 = FOR_W2M_RT ? W_Val :
                    M_RD2_REG;
    // W-stage
    W_REG W_reg(
        .clk(clk),
        .rst(rst | W_REG_RST),
        .WE(W_REG_WE),
        .M_instr(M_instr),
        .M_pc(M_pc),
        .M_EXTout(M_EXTout),
        .M_ALUout(M_ALUout),
        .M_DMout(M_DMout),
        .W_instr(W_instr),
        .W_pc(W_pc),
        .W_EXTout(W_EXTout),
        .W_ALUout(W_ALUout),
        .W_DMout(W_DMout)
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
                    W_WD3Sel == `WD3Sel_PC8 ? W_pc + 8 : 32'd0;

endmodule
