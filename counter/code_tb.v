`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:35:16 08/28/2023
// Design Name:   code
// Module Name:   /home/co-eda/Desktop/Verilog/counter/code_tb.v
// Project Name:  counter
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: code
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module code_tb;

	// Inputs
	reg Clk;
	reg Reset;
	reg Slt;
	reg En;

	// Outputs
	wire [63:0] Output0;
	wire [63:0] Output1;

	// Instantiate the Unit Under Test (UUT)
	code uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.Slt(Slt), 
		.En(En), 
		.Output0(Output0), 
		.Output1(Output1)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 0;
		Slt = 0;
		En = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        
        // $monitor("Clk = %b  Reset = %b  Slt = %b  En = %b  Output0 = %d  Output1 = %d",
        //         Clk, Reset, Slt, En, Output0, Output1);
        // En = 1;
        // #50; // 5 routes  Output0: 0 -> 5
        // Slt = 1;
        // #50; // 5 routes  Output1: 0 -> 1
        // #30; // 3 routes  Output1: 1 -> 2

        En = 1;
        Slt = 1;
        #80;
        Slt = 0;
        #80;
        Reset = 1;
        #80;
        Reset = 0;
        En = 0;
        #80;
        En = 1;
        Slt = 0;
        #80;
        En = 0;
	end

    always #5 Clk = ~Clk;
    
endmodule

