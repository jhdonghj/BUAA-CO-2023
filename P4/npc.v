`timescale 1ns / 1ps
`include "defines.v"

module npc(
    input [31:0] pc,
    input [15:0] imm16,
    input [25:0] imm26,
    input [3:0] NPCOp,
    input [31:0] RD1,
    input zero,
    output [31:0] npc
    );

    wire [31:0] pc4;
    assign pc4 = pc + 4;
    assign npc = NPCOp == `NPC_ADD4 ? pc4 :
                 NPCOp == `NPC_BRCH ? (zero ? pc4 + {{14{imm16[15]}}, imm16, 2'b0} : pc4) :
                 NPCOp == `NPC_JAL  ? {{pc[31:28]}, imm26, 2'b0} :
                 NPCOp == `NPC_JR   ? RD1 :
                 32'd0;

endmodule
