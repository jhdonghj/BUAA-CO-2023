`timescale 1ns / 1ps
`include "defines.v"

module mips(
        input clk,
        input reset
    );
    wire rst;
    assign rst = reset;
    wire [31:0] pc, npc, DMout, SrcA, SrcB, ALUout;
    wire [31:0] instr, EXTout, RD1, RD2, WD3;
    wire [25:0] imm26;
    wire [15:0] imm16;
    wire [5:0] opcode, funct;
    wire [4:0] ALUOp, A1, A2, A3, rs, rt, rd, shamt;
    wire [3:0] NPCOp;
    wire [2:0] ExtOp, DMOp, WD3Sel, A3Sel;
    wire ALUZero, MemWrite, ALUSrc, RegWrite;

    // instrument 
    assign opcode = instr[31:26];
    assign imm26 = instr[25:0];
    assign imm16 = instr[15:0];
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign shamt = instr[10:6];
    assign funct = instr[5:0];

    assign A1 = rs;
    assign A2 = rt;
    assign A3 = A3Sel == `A3Sel_rt ? rt :
                A3Sel == `A3Sel_rd ? rd :
                A3Sel == `A3Sel_ra ? 5'd31 :
                5'd0;
    assign WD3 = WD3Sel == `WD3Sel_ALUout ? ALUout :
                 WD3Sel == `WD3Sel_DMout ? DMout :
                 WD3Sel == `WD3Sel_PC4 ? pc + 4 :
                 32'd0;
    assign SrcA = RD1;
    assign SrcB = ALUSrc ? EXTout : RD2;
    // NPC
    npc npc1(
        .pc(pc),
        .imm16(imm16),
        .imm26(imm26),
        .NPCOp(NPCOp),
        .RD1(RD1),
        .zero(ALUZero),
        .npc(npc)
    );
    // PC
    pc pc1(
        .clk(clk),
        .rst(rst),
        .npc(npc),
        .pc(pc)
    );
    // IM
    im im1(
        .pc(pc),
        .instr(instr)
    );
    // CTRL
    ctrl ctrl1(
        .opcode(opcode),
        .funct(funct),
        .ExtOp(ExtOp),
        .WD3Sel(WD3Sel),
        .MemWrite(MemWrite),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .A3Sel(A3Sel),
        .RegWrite(RegWrite),
        .DMOp(DMOp),
        .NPCOp(NPCOp)
    );
    // GRF
    grf grf1(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .pc(pc),
        .RD1(RD1),
        .RD2(RD2)
    );
    // EXT
    ext ext1(
        .Input(imm16),
        .ExtOp(ExtOp),
        .Output(EXTout)
    );
    // ALU
    alu alu1(
        .A(SrcA),
        .B(SrcB),
        .ALUOp(ALUOp),
        .C(ALUout),
        .zero(ALUZero)
    );
    // DM
    dm dm1(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .A(ALUout),
        .WD(RD2),
        .DMOp(DMOp),
        .pc(pc),
        .RD(DMout)
    );
    
endmodule
