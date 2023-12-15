`timescale 1ns / 1ps

module ext_tb;

	// Inputs
	reg [15:0] imm;
	reg [1:0] EOp;

	// Outputs
	wire [31:0] ext;

	// Instantiate the Unit Under Test (UUT)
	ext uut (
		.imm(imm), 
		.EOp(EOp), 
		.ext(ext)
	);

	initial begin
		// Initialize Inputs
		imm = 0;
		EOp = 0;

		// Wait 100 ns for global reset to finish
		#100;
        imm = 16'hffff;
        EOp = 2'b01;
        #5;
        EOp = 2'b00;
        #5;
        imm = 16'h7fff;
        #5;
        EOp = 2'b10;
        #5;
        EOp = 2'b11;
        #5;
        imm = 16'hffff;
		// Add stimulus here

	end
      
endmodule

