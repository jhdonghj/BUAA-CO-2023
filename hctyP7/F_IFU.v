`include "constants.v"

module F_IFU (
        input clk,  //! Clock
        input reset,  //! Reset
        input Req,  //! Request
        input WE,  //! Write Enable
        input [31: 0] nPC,  //! Next PC
        // output [31: 0] Instr, //! Instruction
        output reg [31: 0] PC //! Program Counter
    );

    // F_IM IM(
    //        .PC(PC),
    //        .Instr(Instr)
    //    );

    initial begin
        PC <= 32'h3000;
    end

    always @(posedge clk) begin
        if (reset)
            PC <= 32'h3000;
        else if (WE)
            PC <= nPC;
    end

endmodule
