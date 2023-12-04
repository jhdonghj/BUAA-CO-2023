`timescale 1ns / 1ps
`include "defines.v"

module D_NPC(
    input Req,
    input [31:0] EPC,
    input [31:0] F_pc,
    input [31:0] D_pc,
    input [15:0] imm16,
    input [25:0] imm26,
    input [3:0] NPCOp,
    input [31:0] RD1,
    input isBrch,
    output [31:0] npc
    );

    assign npc = Req ? `Handler_Addr + 4 :
                    NPCOp == `NPC_ADD4 ? F_pc + 4 :
                    NPCOp == `NPC_BRCH ? (isBrch ? D_pc + 4 + {{14{imm16[15]}}, imm16, 2'b0} : F_pc + 4) :
                    NPCOp == `NPC_JAL  ? {{D_pc[31:28]}, imm26, 2'b0} :
                    NPCOp == `NPC_JR   ? RD1 :
                    NPCOp == `NPC_ERET ? EPC + 4 :
                    32'd0;

endmodule
