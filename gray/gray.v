`timescale 1ns / 1ps

module gray(
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output reg Overflow = 0
    );

    reg [2:0] cnt = 0;

    assign Output = cnt == 3'd0 ? 3'b000 :
                    cnt == 3'd1 ? 3'b001 :
                    cnt == 3'd2 ? 3'b011 :
                    cnt == 3'd3 ? 3'b010 :
                    cnt == 3'd4 ? 3'b110 :
                    cnt == 3'd5 ? 3'b111 :
                    cnt == 3'd6 ? 3'b101 :
                    cnt == 3'd7 ? 3'b100 :
                    3'b0;

    always @(posedge Clk) begin
       if (Reset) begin
            cnt <= 0;
            Overflow <= 0;
       end else if(En) begin
            cnt <= cnt + 1;
            Overflow <= Overflow | (cnt == 7);
       end
    end

endmodule
