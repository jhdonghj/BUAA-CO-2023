`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:40:24 08/29/2023
// Design Name:   id_fsm
// Module Name:   /home/co-eda/Desktop/Verilog/ISE_projects/id_fsm/id_fsm_tb.v
// Project Name:  id_fsm
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: id_fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module id_fsm_tb;

	// Inputs
	reg [7:0] char = 0;
	reg clk = 0;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	id_fsm uut (
		.char(char), 
		.clk(clk), 
		.out(out)
	);

    reg [8 * 9 - 1 : 0] str = "abcd1234/";
    integer i;

	initial begin
		// Initialize Inputs
		char = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        for (i = 8; i >= 0; i = i - 1) begin
            char = str[8 * i +: 8];
            $display("%s", char);
            #10;
        end
        char = "#";
	end
    always #5 clk = ~clk;
      
endmodule

