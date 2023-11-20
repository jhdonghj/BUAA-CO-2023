`timescale 1ns / 1ps

module tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] char;
	reg [15:0] freq;
	reg finish;

	// Outputs
	wire [1:0] format_type;
	wire [3:0] error_code;

   always @(posedge clk) begin
      if (!reset && !finish) begin
         $display("%s %d %b", char, format_type, error_code);
        //  $display("%s %d %b | l_freq: %4b | l_ti: %4b | l_pc: %4b | l_addr: %4b | ",
        //         char, format_type, error_code,
        //         uut.lowbit_freq, uut.lowbit_ti, uut.lowbit_pc, uut.lowbit_addr);
      end
   end

	// Instantiate the Unit Under Test (UUT)
	cpu_checker uut (
		.clk(clk), 
		.reset(reset), 
		.char(char), 
		.freq(freq), 
		.format_type(format_type), 
		.error_code(error_code)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		char = 0;
		freq = 2;
		finish = 0;

		#10 reset = 0;
        
		#20
		finish = 1;
	end

    always #1 clk = ~clk;

endmodule

