`timescale 1ns / 1ps

module expr_tb;

	// Inputs
	reg clk;
	reg clr;
	reg [7:0] in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	expr uut (
		.clk(clk), 
		.clr(clr), 
		.in(in), 
		.out(out)
	);

    always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 0;
		in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        in = "1";
        #10;
        in = "+";
        #10;
        in = "2";
        #10;
        in = "*";
        #10;
        in = "3";
        #10;
        clr = 1;
        #10;
        clr = 0;
        in = "1";
        #10;
        in = "+";
        #10;
        in = "2";
        #10;
        in = "*";
        #10;
        in = "3";
        #10;
		// Add stimulus here

	end
      
endmodule

