`include "constants.v"

module D_NPC (
        input Req,
        input [31: 0] EPC,

        input [31: 0] D_PC,      //! Decode_Stage Program Counter
        input [31: 0] F_PC,      //! Fetch_Stage Program Counter
        input [25: 0] imm26,      //! Immediate 26 bits
        input [31: 0] ra,      //! Return Address
        input [31: 0] Br,      //! Branch
        input isTrue,      //! Is True
        output [31: 0] nPC //! Next Program Counter
    );
    assign nPC =
           Req ? 32'h0000_4184 :
           (Br == `Br_eret) ? EPC + 4 :
           (Br == `Br_default) ? F_PC + 4 :
           (Br == `Br_br && isTrue) ? D_PC + 4 + {{14{imm26[15]}}, imm26[15 : 0], 2'b0} :
           (Br == `Br_j) ? {D_PC[31 : 28], imm26, 2'b0} :
           (Br == `Br_jr) ? ra :
           F_PC + 4;
endmodule
