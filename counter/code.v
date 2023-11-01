`timescale 1ns / 1ps

module code(
    input Clk,
    input Reset,
    input Slt,
    input En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
    );
    reg [1:0] ti;
    wire [63:0] new_Output0, new_Output1, is_carry;
    wire [1:0] new_ti;

    assign new_Output0 = Output0 + 1'b1;
    assign is_carry = ti == 2'b11;
    assign new_Output1 = Output1 + is_carry;
    assign new_ti = ti == 2'b11 ? 2'b0 : ti + 1;

    always @(posedge Clk) begin
        if (Reset == 1'b1) begin
            ti <= 2'b0;
            Output0 <= 64'b0;
            Output1 <= 64'b0;
        end else begin
            if (En == 1'b1) begin
                if (Slt == 1'b0) begin
                    Output0 <= new_Output0;
                end else begin
                    Output1 <= new_Output1;
                    ti <= new_ti;
                end
            end else begin
                Output0 <= Output0;
                Output1 <= Output1;
                ti <= ti;
            end
        end 
    end

endmodule
