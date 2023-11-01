`timescale 1ns / 1ps

module expr(
    input clk,
    input clr,
    input [7:0] in,
    output out
    );

    parameter S0 = 2'b00, Sd = 2'b01, Sop = 2'b10, Serr = 2'b11;

    reg [1:0] state = 0;
    wire isdigit, isop;

    assign isdigit = "0" <= in && in <= "9";
    assign isop = in == "+" || in == "*";

    assign out = state == Sd;

    always @(posedge clk, posedge clr) begin
        if (clr) begin
            state <= S0;
        end else begin
            case (state)
                S0:   state <= isdigit ? Sd   : isop ? Serr : Serr;
                Sd:   state <= isdigit ? Serr : isop ? Sop  : Serr;
                Sop:  state <= isdigit ? Sd   : isop ? Serr : Serr;
                Serr: state <= Serr;
                default: state <= Serr;
            endcase
        end
    end

endmodule
