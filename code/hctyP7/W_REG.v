`include "constants.v"

module W_REG (
        input clk,
        input reset,
        input WE,
        input Req,
        input [31: 0] PC_in,
        input [31: 0] Instr_in,
        input [31: 0] EXT_in,
        input [31: 0] ALU_in,
        input [31: 0] MDU_in,
        input [31: 0] DM_in,
        input [31: 0] CP0_in,
        output reg [31: 0] PC_out,
        output reg [31: 0] Instr_out,
        output reg [31: 0] EXT_out,
        output reg [31: 0] ALU_out,
        output reg [31: 0] MDU_out,
        output reg [31: 0] DM_out,
        output reg [31: 0] CP0_out,

        input [31: 0] check_in,
        input [31: 0] set_in,
        output reg [31: 0] check_out,
        output reg [31: 0] set_out
    );

    always @(posedge clk) begin
        if (reset || Req) begin
            PC_out <= 32'h3000;
            Instr_out <= 0;
            EXT_out <= 0;
            ALU_out <= 0;
            MDU_out <= 0;
            DM_out <= 0;
            check_out <= 0;
            set_out <= 0;
            CP0_out <= 0;
        end
        else if (WE) begin
            PC_out <= PC_in;
            Instr_out <= Instr_in;
            EXT_out <= EXT_in;
            ALU_out <= ALU_in;
            MDU_out <= MDU_in;
            DM_out <= DM_in;
            check_out <= check_in;
            set_out <= set_in;
            CP0_out <= CP0_in;
        end
    end

endmodule
