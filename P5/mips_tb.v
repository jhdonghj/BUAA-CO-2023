`timescale 1ns / 1ps

module mips_tb;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk),
		.reset(reset)
	);

    always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#10;
        reset = 0;
        
		// Add stimulus here
		#10000;
		$finish;
	end
      
endmodule

