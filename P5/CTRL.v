`timescale 1ns / 1ps
`include "defines.v"

module CTRL(
    input [31:0] instr,
    // control signal
    output [2:0] EXTOp,
    output [2:0] WD3Sel,
    output MemWrite,
    output [4:0] ALUOp,
    output ALUSrc,
    output [2:0] A3Sel,
    output RegWrite,
    output [2:0] DMOp,
    output [3:0] NPCOp,
    output [2:0] CMPOp,
    // T values
    output [2:0] D_Tuse_RS,
    output [2:0] D_Tuse_RT,
    output [2:0] D_Tnew,
    output [2:0] E_Tnew,
    output [2:0] M_Tnew,
    output [4:0] Dst,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd
    );
    wire [5:0] opcode = instr[31:26], funct = instr[5:0];
    assign rs = instr[25:21], rt = instr[20:16], rd = instr[15:11];
    wire [4:0] ra = 5'd31;
    
    wire add, sub, addu, subu, ori, lw, sw, beq, lui, jal, jr;

    assign  add = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADD;
    assign  sub = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUB;
    assign addu = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADDU;
    assign subu = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUBU;
    assign  ori = opcode == `CTR_OP_ORI;
    assign   lw = opcode == `CTR_OP_LW ;
    assign   sw = opcode == `CTR_OP_SW ;
    assign  beq = opcode == `CTR_OP_BEQ;
    assign  lui = opcode == `CTR_OP_LUI;
    assign  jal = opcode == `CTR_OP_JAL;
    assign   jr = opcode == `CTR_OP_SPE && funct == `CTR_FN_JR;
    
    assign EXTOp = {{1'b0},
                    {1'b0},
                    {1'b0 | lw | sw | beq}};
    assign WD3Sel = {{1'b0},
                     {1'b0 | jal},
                     {1'b0 | lw}};
    assign MemWrite = 1'b0 | sw;
    assign ALUOp = {{1'b0},
                    {1'b0},
                    {1'b0 | lui},
                    {1'b0 | ori},
                    {1'b0 | sub | subu | ori}};
    assign ALUSrc = 1'b0 | ori | lw | sw | lui;
    assign A3Sel = {{1'b0},
                    {1'b0 | jal},
                    {1'b0 | add | sub | addu | subu}};
    assign RegWrite = 1'b0 | add | sub | addu | subu | ori | lw | lui | jal;
    assign DMOp = {{1'b0},
                    {1'b0}};
    assign NPCOp = {{1'b0},
                    {1'b0},
                    {1'b0 | jal | jr},
                    {1'b0 | beq | jr}};
    assign CMPOp = {{1'b0},
                    {1'b0},
                    {1'b0}};

    assign D_Tuse_RS = {{1'b0 | lui | jal},
                        {1'b0},
                        {1'b0 | add | sub | addu | subu | ori | lw | sw}};
    assign D_Tuse_RT = {{1'b0 | ori | lw | lui | jal | jr},
                        {1'b0 | sw},
                        {1'b0 | add | sub | addu | subu}};
    assign D_Tnew = {{1'b0},
                        {1'b0 | add | sub | addu | subu | ori | lui | lw},
                        {1'b0 | lw}};
    assign E_Tnew = D_Tnew == 3'b0 ? 3'b0 : D_Tnew - 3'd1;
    assign M_Tnew = E_Tnew == 3'b0 ? 3'b0 : E_Tnew - 3'd1;
    assign Dst = A3Sel == `A3Sel_rt ? rt :
                    A3Sel == `A3Sel_rd ? rd :
                    A3Sel == `A3Sel_ra ? ra :
                    5'b0;

endmodule
