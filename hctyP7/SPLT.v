`include "constants.v"

module SPLT (
        input [31: 0] Instr, //! Instruction
        output [31: 26] op, //! Opcode
        output [5: 0] func, //! Function
        output [25: 21] rs, //! Source Register 1
        output [20: 16] rt, //! Source Register 2
        output [15: 11] rd, //! Destination Register
        output [10: 6] shamt, //! Shift Amount
        output [15: 0] imm16, //! Immediate 16 bits
        output [25: 0] imm26 //! Immediate 26 bits
    );

    assign op = Instr[31 : 26];
    assign rs = Instr[25 : 21];
    assign rt = Instr[20 : 16];
    assign rd = Instr[15 : 11];
    assign shamt = Instr[10 : 6];
    assign func = Instr[5 : 0];
    assign imm16 = Instr[15 : 0];
    assign imm26 = Instr[25 : 0];

endmodule
