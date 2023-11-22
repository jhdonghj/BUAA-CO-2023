`include "constants.v"

module M_REG (
        input clk,
        input reset,
        input WE,
        input Req,
        input [4: 0] ExcCode_in,
        input [31: 0] PC_in,
        input [31: 0] Instr_in,
        input BD_in,
        input [31: 0] rt_fwd_in,
        input [31: 0] EXT_in,
        input [31: 0] ALU_in,
        input [31: 0] MDU_in,
        output reg [4: 0] ExcCode_out,
        output reg [31: 0] PC_out,
        output reg [31: 0] Instr_out,
        output reg BD_out,
        output reg [31: 0] EXT_out,
        output reg [31: 0] rt_val_out,
        output reg [31: 0] ALU_out,
        output reg [31: 0] MDU_out,

        input [31: 0] check_in,
        input [31: 0] set_in,
        output reg [31: 0] check_out,
        output reg [31: 0] set_out
    );

    always @(posedge clk) begin
        if (reset || Req) begin
            ExcCode_out <= 0;
            PC_out <= 32'h3000;
            Instr_out <= 0;
            BD_out <= 0;
            rt_val_out <= 0;
            EXT_out <= 0;
            ALU_out <= 0;
            MDU_out <= 0;
            check_out <= 0;
            set_out <= 0;
        end
        else if (WE) begin
            ExcCode_out <= ExcCode_in;
            PC_out <= PC_in;
            Instr_out <= Instr_in;
            BD_out <= BD_in;
            rt_val_out <= rt_fwd_in;
            EXT_out <= EXT_in;
            ALU_out <= ALU_in;
            MDU_out <= MDU_in;
            check_out <= check_in;
            set_out <= set_in;
        end
    end

endmodule
