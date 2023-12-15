`include "definations.v"

module GRF(
        input [31: 0] PC,  //! Program Counter

        input clk,  //! Clock
        input reset,  //! Reset
        input WE,  //! Write Enable
        input [4: 0] A1,  //! Register A1
        input [4: 0] A2,  //! Register A2
        input [4: 0] A3,  //! Register A3
        input [31: 0] WD,  //! Write Data
        output [31: 0] RD1,  //! Read Data 1
        output [31: 0] RD2 //! Read Data 2
    );

    reg [31: 0] RF[31: 0]; //! Register File
    integer i; //! Loop Variable

    initial begin
        for (i = 0; i < 32; i = i + 1)
            RF[i] <= 0;
    end

    assign RD1 = RF[A1];
    assign RD2 = RF[A2];

    always@(posedge clk) begin : RegWrite
        if (reset == 1) begin
            for (i = 0; i < 32; i = i + 1)
                RF[i] <= 0;
        end
        else if (WE == 1) begin
            RF[A3] <= A3 ? WD : 0;
            $display("@%h: $%d <= %h", PC, A3, WD); //write a number to $0 maybe undefined
        end
    end

endmodule
