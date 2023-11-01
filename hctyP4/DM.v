`include "definations.v"

module DM(
        input [31: 0] PC,       //! Program Counter

        input clk,       //! Clock
        input reset,       //! Reset
        input WE,       //! Write Enable
        input [31: 0] Addr,       //! Address
        input [31: 0] WD,       //! Write Data
        output [31: 0] RD //! Read Data
    );

    reg [31: 0] DM[0: 3071]; //! Data Memory
    integer i; //! Loop Variable

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            DM[i] <= 0;
    end

    assign RD = DM[Addr[13: 2]];

    always@(posedge clk) begin : MemWrite
        if (reset == 1) begin
            for (i = 0; i < 1024; i = i + 1)
                DM[i] <= 0;
        end
        else if (WE == 1) begin
            DM[Addr[11: 2]] <= WD;
            $display("@%h: *%h <= %h", PC, Addr, WD);
        end
    end

endmodule
