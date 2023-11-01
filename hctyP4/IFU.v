`include "definations.v"

module IFU(
        output reg [31: 0] PC,  //! Program Counter

        input clk,  //! Clock
        input reset,  //! Reset
        input [2: 0] Br,  //! Branch Control
        input eq,  //! Equal Flag
        input [25: 0] imm26,  //! Immediate 26 bits or 16 bits
        input [31: 0] ra,  //! Register
        output [31: 0] PC4,  //! Program Counter + 4
        output [31: 0] Instr //! Instruction
    );

    IM IM(
           .PC(PC),
           .Instr(Instr)
       );

    wire [31: 0] nPC; //! Next PC

    assign PC4 = PC + 4;
    assign nPC =
           (Br == `Br_default) ? PC4 :
           (Br == `Br_beq && eq) ? PC + 4 + {{14{imm26[15]}}, imm26[15 : 0], 2'b0} :
           (Br == `Br_j) ? {PC[31 : 28], imm26, 2'b0} :
           (Br == `Br_jr) ? ra :
           PC + 4;

    always@(posedge clk) begin : PC_Update
        if (reset == 1) begin
            PC <= 32'h3000;
        end
        else begin
            PC <= nPC;
        end
    end

endmodule

module IM (
        input [31: 0] PC,    //! Program Counter
        output [31: 0] Instr //! Instruction
    );

    reg [31: 0] IM [0: 4095]; //! Instruction Memory
    wire [31: 0] PC3000; //! PC - 3000

    initial begin
        $readmemh("code.txt", IM);
    end

    assign PC3000 = PC - 32'h3000;
    assign Instr = IM[PC3000[13: 2]];

endmodule
