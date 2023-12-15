`timescale 1ns / 1ps

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

    always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = 0;

		// Wait 100 ns for global reset to finish
        in = "b"; #3;
		reset = 0;#7;
in = "e"; #10;
in = "g"; #10;
in = "i"; #10;
in = "n"; #10;
in = " "; #10;
in = "b"; #10;
in = "e"; #10;
in = "g"; #10;
in = "i"; #10;
in = "n"; #10;
in = " "; #10;
in = "b"; #10;
in = "e"; #10;
in = "g"; #10;
in = "i"; #10;
in = "n"; #10;
in = " "; #10;
in = "e"; #10;
in = "n"; #10;
in = "d"; #10;
in = " "; #10;
in = "e"; #10;
in = "n"; #10;
in = "d"; #10;
in = " "; #10;
in = "e"; #10;
in = "n"; #10;
in = "d"; #10;
in = " "; #10;
in = "b"; #10;
in = "e"; #10;
in = "g"; #10;
in = "i"; #10;
in = "n"; #10;
in = " "; #10;
in = "e"; #10;
in = "n"; #10;
in = "d"; #10;
in = "r"; #10;
in = " "; #10;
in = "e"; #10;
in = "n"; #10;
in = "d"; #10;
in = " "; #10;
in = "b"; #10;
in = "e"; #10;
in = "g"; #10;
in = "i"; #10;
in = "n"; #10;
in = " "; #10;
		// Add stimulus here

	end
      
endmodule

