`timescale 1ns/1ps
`include "definations.v"

module mips(
        input clk,
        input reset
    );

    wire [31: 0] PC, PC4, Instr;
    wire [31: 0] RD1, RD2, ALUout, DMout, imm32;
    wire [25: 0] imm26;
    wire [15: 0] imm16;
    wire [5: 0] op, func;
    wire [4: 0] rs, rt, rd, shamt;
    wire [3: 0] ALUOp;
    wire [2: 0] Br;
    wire [1: 0] RegDst, WDsel;
    wire RegWrite, MemWrite, ALUSrc, EXTOp, eq;
 
    assign eq = !ALUout;

    IFU IFU(
            .PC(PC),
            .clk(clk),
            .reset(reset),
            .Br(Br),
            .Instr(Instr),
            .PC4(PC4),
            .eq(eq),
            .imm26(imm26),
            .ra(RD1)
        );
    SPLT SPLT(
             .Instr(Instr),
             .op(op),
             .rs(rs),
             .rt(rt),
             .rd(rd),
             .shamt(shamt),
             .func(func),
             .imm16(imm16),
             .imm26(imm26)
         );
    CTRL CTRL(
             .op(op),
             .func(func),
             .RegWrite(RegWrite),
             .RegDst(RegDst),
             .WDsel(WDsel),
             .MemWrite(MemWrite),
             .ALUOp(ALUOp),
             .ALUSrc(ALUSrc),
             .EXTOp(EXTOp),
             .Br(Br)
         );
    GRF GRF(
            .PC(PC),
            .clk(clk),
            .reset(reset),
            .WE(RegWrite),
            .A1(rs),
            .A2(rt),
            .A3(
                (RegDst == `A3_rd) ? rd :
                (RegDst == `A3_rt) ? rt :
                (RegDst == `A3_ra) ? 5'h1f :
                5'b0
            ),
            .WD(
                (WDsel == `WD_alu) ? ALUout :
                (WDsel == `WD_mem) ? DMout :
                (WDsel == `WD_pc4) ? PC4 :
                32'b0
            ),
            .RD1(RD1),
            .RD2(RD2)
        );
    EXT EXT(
            .imm16(imm16),
            .imm32(imm32),
            .EXTOp(EXTOp)
        );
    ALU ALU(
            .A(RD1),
            .B(
                (ALUSrc == `ALU_imm) ? imm32 :
                (ALUSrc == `ALU_RD2) ? RD2 :
                32'b0
            ),
            .ALUOp(ALUOp),
            .ALUout(ALUout)
        );
    DM DM(
           .PC(PC),
           .clk(clk),
           .reset(reset),
           .WE(MemWrite),
           .Addr(ALUout),
           .WD(RD2),
           .RD(DMout)
       );

endmodule
