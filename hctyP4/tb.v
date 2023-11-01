`timescale 1ns/1ps
module testbench();
    reg clk;
    reg reset;
    mips u_mips(
             .clk ( clk ),
             .reset ( reset )
         );

    always #5 clk = ~clk;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);
        reset = 1;
        clk = 0;
        #100 reset = 0;
        #500 $finish;
    end
endmodule
