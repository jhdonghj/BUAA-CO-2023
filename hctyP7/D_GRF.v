`include "constants.v"

module D_GRF(
        input [31: 0] PC, //! Program Counter

        input clk, //! Clock
        input reset, //! Reset
        input WE, //! Write Enable
        input [4: 0] A1, //! Source Register 1
        input [4: 0] A2, //! Source Register 2
        input [4: 0] A3, //! Write Register
        input [31: 0] WD, //! Write Data
        output [31: 0] RD1, //! Read Data 1
        output [31: 0] RD2  //! Read Data 2
    );

    reg [31: 0] RF[31: 0]; //! Register File
    integer i; //! Loop Variable

    initial begin
        for (i = 0; i < 32; i = i + 1)
            RF[i] <= 0;
    end

    assign RD1 = (A3 == A1 && A3 && WE) ? WD : RF[A1];
    assign RD2 = (A3 == A2 && A3 && WE) ? WD : RF[A2];

    always@(posedge clk) begin : RegWrite
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                RF[i] <= 0;
        end
        else if (WE && A3) begin
            RF[A3] <= WD;
            // $display("%d@%h: $%d <= %h", $time, PC, A3, WD);
        end
    end

endmodule
