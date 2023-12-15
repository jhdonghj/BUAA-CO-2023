`include "constants.v"

module E_MDU (
        input Req,

        input clk,
        input reset,
        input [31: 0] MDUOp,
        input [31: 0] rs,
        input [31: 0] rt,
        output [31: 0] Busy,
        output [31: 0] MDUOut
    );

    integer state = 0;
    wire start =
         (MDUOp == `MDU_mult) ||
         (MDUOp == `MDU_multu) ||
         (MDUOp == `MDU_div) ||
         (MDUOp == `MDU_divu);

    reg [31: 0] hi, lo;

    assign Busy = (start << 1) | state;

    assign MDUOut =
           (MDUOp == `MDU_mflo) ? lo :
           (MDUOp == `MDU_mfhi) ? hi :
           0;

    initial begin
        state <= 0;
        hi <= 0;
        lo <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            hi <= 0;
            lo <= 0;
        end
        else begin
            if (state == 0) begin
                if (Req)
                    state <= 0;
                if (MDUOp == `MDU_mthi)
                    hi <= rs;
                else if (MDUOp == `MDU_mtlo)
                    lo <= rs;
                else if (MDUOp == `MDU_mult) begin
                    {hi, lo} <= $signed(rs) * $signed(rt);
                    state <= 5;
                end
                else if (MDUOp == `MDU_multu) begin
                    {hi, lo} <= rs * rt;
                    state <= 5;
                end
                else if (MDUOp == `MDU_div) begin
                    lo <= $signed(rs) / $signed(rt);
                    hi <= $signed(rs) % $signed(rt);
                    state <= 10;
                end
                else if (MDUOp == `MDU_divu) begin
                    lo <= rs / rt;
                    hi <= rs % rt;
                    state <= 10;
                end
            end
            else
                state <= state - 1;
        end
    end
endmodule
