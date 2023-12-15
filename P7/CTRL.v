`timescale 1ns / 1ps
`include "defines.v"

module CTRL(
    input [31:0] instr,
    // control signal
    output RegWrite,
    output [2:0] A3Sel,
    output [2:0] WD3Sel,
    output MemWrite,
    output [2:0] DMOp,
    output [2:0] BEOp,

    output ALUSrc,
    output [4:0] ALUOp,
    output [3:0] NPCOp,
    output [2:0] CMPOp,
    output [2:0] EXTOp,
    output [4:0] HILOOp,
    output CP0Write,
    // T values
    output [2:0] D_Tuse_RS,
    output [2:0] D_Tuse_RT,
    output [2:0] D_Tnew,
    output [2:0] E_Tnew,
    output [2:0] M_Tnew,
    output [4:0] Dst,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    // identify
    output isHILO,
    output store,
    output load,
    output eret,
    output mtc0,
    output syscall,
    output unknow
    );
    wire [5:0] opcode = instr[31:26], funct = instr[5:0];
    assign rs = instr[25:21], rt = instr[20:16], rd = instr[15:11];
    wire [4:0] ra = 5'd31;
    // identify instruction
    wire add, sub, addu, subu, and_, or_, slt, sltu, lui, addi, addiu, andi, ori;
    wire lb, lh, lhu, lw, sb, sh, sw, mult, multu, div, divu, mfhi, mflo, mthi, mtlo;
    wire beq, bne, jal, jr, mfc0, nop;

    assign add   = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADD;
    assign sub   = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUB;
    assign addu  = opcode == `CTR_OP_SPE && funct == `CTR_FN_ADDU;
    assign subu  = opcode == `CTR_OP_SPE && funct == `CTR_FN_SUBU;
    assign and_  = opcode == `CTR_OP_SPE && funct == `CTR_FN_AND;
    assign or_   = opcode == `CTR_OP_SPE && funct == `CTR_FN_OR;
    assign slt   = opcode == `CTR_OP_SPE && funct == `CTR_FN_SLT;
    assign sltu  = opcode == `CTR_OP_SPE && funct == `CTR_FN_SLTU;
    assign lui   = opcode == `CTR_OP_LUI;
    assign addi  = opcode == `CTR_OP_ADDI;
    assign addiu = opcode == `CTR_OP_ADDIU;
    assign andi  = opcode == `CTR_OP_ANDI;
    assign ori   = opcode == `CTR_OP_ORI;
    assign lb    = opcode == `CTR_OP_LB;
    assign lh    = opcode == `CTR_OP_LH;
    assign lhu   = opcode == `CTR_OP_LHU;
    assign lw    = opcode == `CTR_OP_LW;
    assign sb    = opcode == `CTR_OP_SB;
    assign sh    = opcode == `CTR_OP_SH;
    assign sw    = opcode == `CTR_OP_SW;
    assign mult  = opcode == `CTR_OP_SPE && funct == `CTR_FN_MULT;
    assign multu = opcode == `CTR_OP_SPE && funct == `CTR_FN_MULTU;
    assign div   = opcode == `CTR_OP_SPE && funct == `CTR_FN_DIV;
    assign divu  = opcode == `CTR_OP_SPE && funct == `CTR_FN_DIVU;
    assign mfhi  = opcode == `CTR_OP_SPE && funct == `CTR_FN_MFHI;
    assign mflo  = opcode == `CTR_OP_SPE && funct == `CTR_FN_MFLO;
    assign mthi  = opcode == `CTR_OP_SPE && funct == `CTR_FN_MTHI;
    assign mtlo  = opcode == `CTR_OP_SPE && funct == `CTR_FN_MTLO;
    assign beq   = opcode == `CTR_OP_BEQ;
    assign bne   = opcode == `CTR_OP_BNE;
    assign jal   = opcode == `CTR_OP_JAL;
    assign jr    = opcode == `CTR_OP_SPE && funct == `CTR_FN_JR;
    assign eret  = opcode == `CTR_OP_CP0 && funct == `CTR_FN_ERET;
    assign mfc0  = opcode == `CTR_OP_CP0 && instr[25:21] == `CTR_FN_MFC0;
    assign mtc0  = opcode == `CTR_OP_CP0 && instr[25:21] == `CTR_FN_MTC0;
    assign syscall = opcode == `CTR_OP_SPE && funct == `CTR_FN_SYSC;
    assign nop   = instr == 32'h0000_0000;
    // classify instruction
    wire calc_r, calc_i, muldiv, mf, mt;

    assign calc_r = add | sub | addu | subu | and_ | or_ | slt | sltu;
    assign calc_i = addi | addiu | andi | ori;
    assign load = lb | lh | lhu | lw;
    assign store = sb | sh | sw;
    assign muldiv = mult | multu | div | divu;
    assign mf = mfhi | mflo;
    assign mt = mthi | mtlo;
    assign branch = beq | bne;
    
    assign unknow = !(calc_r | calc_i | load | store | muldiv
                        | mf | mt | branch | lui | jal | jr | eret
                        | mfc0 | mtc0 | syscall | nop);
    // control signal
    assign RegWrite = 1'b0 | calc_r | calc_i | load | mf | lui | jal | mfc0;
    assign A3Sel = {{1'b0},
                    {1'b0 | jal},
                    {1'b0 | calc_r | mf}};
    assign WD3Sel = {{1'b0 | mfc0},
                     {1'b0 | mf | jal},
                     {1'b0 | load | mf}};
    assign MemWrite = 1'b0 | store;
    assign DMOp = {{1'b0 | lw | lh | lb | lhu},
                   {1'b0 | sb | sh | lb},
                   {1'b0 | sb | sw | lh | lhu}};
    assign BEOp = {{1'b0 | lh},
                    {1'b0 | lb | lhu},
                    {1'b0 | lhu}};
    assign ALUSrc = 1'b0 | calc_i | load | store | lui;
    assign ALUOp = {{1'b0},
                    {1'b0},
                    {1'b0 | lui | slt | sltu | add | subu | addi | load | store},
                    {1'b0 | ori | and_ | or_ | sltu | andi | add | addi | load | store},
                    {1'b0 | sub | ori | or_ | slt | add | addi | load | store}};
    assign NPCOp = {{1'b0},
                    {1'b0 | eret},
                    {1'b0 | jal | jr},
                    {1'b0 | branch | jr}};
    assign CMPOp = {{1'b0},
                    {1'b0},
                    {1'b0 | bne}};
    assign EXTOp = {{1'b0},
                    {1'b0},
                    {1'b0 | load | store | addi | addiu}};
    assign HILOOp = {{1'b0},
                     {1'b0 | mtlo},
                     {1'b0 | divu | mfhi | mflo | mthi},
                     {1'b0 | multu | div | mflo | mthi},
                     {1'b0 | mult | div | mfhi | mthi}};
    assign CP0Write = 1'b0 | mtc0;
    // T values
    assign D_Tuse_RS = {{1'b0 | lui | jal},
                        {1'b0},
                        {1'b0 | calc_r | calc_i | load | store | muldiv | mt}};
    assign D_Tuse_RT = {{1'b0 | calc_i | load | mf | mt | lui | jal | jr},
                        {1'b0 | store | mtc0},
                        {1'b0 | calc_r | muldiv}};
    assign D_Tnew = {{1'b0},
                        {1'b0 | calc_r | calc_i | load | lui | mf | mfc0},
                        {1'b0 | load | mfc0}};
    assign E_Tnew = D_Tnew == 3'b0 ? 3'b0 : D_Tnew - 3'd1;
    assign M_Tnew = E_Tnew == 3'b0 ? 3'b0 : E_Tnew - 3'd1;
    assign Dst = A3Sel == `A3Sel_rt ? rt :
                    A3Sel == `A3Sel_rd ? rd :
                    A3Sel == `A3Sel_ra ? ra :
                    5'b0;
    assign isHILO = muldiv | mf | mt;

endmodule
