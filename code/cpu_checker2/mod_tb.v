`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:36:47 08/29/2023
// Design Name:   mod
// Module Name:   /home/co-eda/Desktop/Verilog/ISE_projects/cpu_checker2/mod_tb.v
// Project Name:  cpu_checker2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mod
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mod_tb;

	// Inputs
	reg [63:0] a;
	reg [15:0] m;

	// Outputs
	wire [15:0] result;

	// Instantiate the Unit Under Test (UUT)
	mod uut (
		.a(a), 
		.m(m), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		a = 0;
		m = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        $monitor("a = %d | m = %d | result = %d", a, m, result);
        a = 94; m = 89; #10; // 5
        a = 59; m = 11; #10; // 4
        a = 75; m = 46; #10; // 29
        a = 66; m = 36; #10; // 30
        a = 52; m = 58; #10; // 52
        a = 76; m = 5; #10; // 1
        a = 33; m = 48; #10; // 33
        a = 33; m = 30; #10; // 3
        a = 79; m = 96; #10; // 79
        a = 10; m = 37; #10; // 10
        a = 64'd11840462074477813509; m = 59676; #10; // 19113
        a = 64'd1870310282140481950; m = 25637; #10; // 13134
        a = 64'd15156998188708966964; m = 50314; #10; // 836
        a = 64'd4124083416844204666; m = 35698; #10; // 21224
        a = 64'd17489115135062474315; m = 15708; #10; // 2183
        a = 64'd5664942396749289757; m = 46629; #10; // 15250
        a = 64'd16037403495322314329; m = 31158; #10; // 6155
        a = 64'd14527664857945641006; m = 8653; #10; // 8288
        a = 64'd136354516062599864; m = 48423; #10; // 20075
        a = 64'd9630541272125196104; m = 6018; #10; // 1922
	end
      
endmodule

