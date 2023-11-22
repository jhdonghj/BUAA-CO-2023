`include "constants.v"

module E_REG (
        input clk,         //! Clock
        input reset,         //! Reset
        input stall,         //! Stall
        input Req,         //! Request
        input WE,         //! Write Enable
        input [4: 0] ExcCode_in,         //! D_Stage Exception Code
        input [31: 0] PC_in,         //! D_Stage PC
        input [31: 0] Instr_in,         //! D_Stage Instruction
        input BD_in,         //! D_Stage Branch Delay
        input [31: 0] rs_fwd_in,         //! D_Stage rs value
        input [31: 0] rt_fwd_in,         //! D_Stage rt value
        input [31: 0] EXT_in,         //! D_Stage EXT result
        output reg [4: 0] ExcCode_out,         //! E_Stage Exception Code
        output reg [31: 0] PC_out,         //! E_Stage PC
        output reg [31: 0] Instr_out,         //! E_Stage Instruction
        output reg BD_out,         //! E_Stage Branch Delay
        output reg [31: 0] rs_val_out,         //! E_Stage rs value
        output reg [31: 0] rt_val_out,         //! E_Stage rt value
        output reg [31: 0] EXT_out,        //! E_Stage EXT result

        input [31: 0] check_in,
        input [31: 0] set_in,
        output reg [31: 0] check_out,
        output reg [31: 0] set_out
    );

    always @(posedge clk) begin
        if (reset || Req) begin
            ExcCode_out <= 0;
            PC_out <= stall && !Req ? PC_in : 32'h3000;
            Instr_out <= 0;
            BD_out <= stall ? BD_in : 0;
            rs_val_out <= 0;
            rt_val_out <= 0;
            EXT_out <= 0;
            check_out <= 0;
            set_out <= 0;
        end
        else if (WE) begin
            ExcCode_out <= ExcCode_in;
            PC_out <= PC_in;
            Instr_out <= Instr_in;
            BD_out <= BD_in;
            rs_val_out <= rs_fwd_in;
            rt_val_out <= rt_fwd_in;
            EXT_out <= EXT_in;
            check_out <= check_in;
            set_out <= set_in;
        end
    end

endmodule
