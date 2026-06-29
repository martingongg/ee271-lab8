module victoryDisplay(clk, reset, upCount, hex);
	input logic clk, reset;
	input logic upCount;
	output logic [6:0] hex;
	
	enum {zero, one, two, three, four, five, six, seven, eight, nine} ps, ns;
	
	// State transition logic
	always_comb begin
		case(ps)
			zero:   ns = upCount ? one   : zero;
			one:    ns = upCount ? two   : one;
			two:    ns = upCount ? three : two;
			three:  ns = upCount ? four  : three;
			four:   ns = upCount ? five  : four;
			five:   ns = upCount ? six   : five;
			six:    ns = upCount ? seven : six;
			seven:  ns = upCount ? eight : seven;
			eight:  ns = upCount ? nine  : eight;
			nine:   ns = upCount ? zero  : nine;
			default: ns = zero;
		endcase
	end
	
	// Output decoding (always assigned based on current state)
	always_comb begin
		case(ps)
			zero:    hex = 7'b1000000; // 0
			one:     hex = 7'b1111001; // 1
			two:     hex = 7'b0100100; // 2
			three:   hex = 7'b0110000; // 3
			four:    hex = 7'b0011001; // 4
			five:    hex = 7'b0010010; // 5
			six:     hex = 7'b0000010; // 6
			seven:   hex = 7'b1111000; // 7
			eight:   hex = 7'b0000000; // 8
			nine:    hex = 7'b0010000; // 9
			default: hex = 7'b1111111; // Blank
		endcase
	end
	
	// State register
	always_ff @(posedge clk) begin
		if (reset)
			ps <= zero;
		else
			ps <= ns;
	end
endmodule

module victoryDisplay_testbench();
	logic clk, reset;
	logic upCount;
	logic [6:0] hex;
	
	victoryDisplay dut(.*);  // Fixed: changed from pointDisplay
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; upCount <= 0; @(posedge clk);
		reset <= 0; @(posedge clk);
		
		// Pulse upCount to increment
		repeat(12) begin
			upCount <= 1; @(posedge clk);
			upCount <= 0; @(posedge clk);  // Added: turn off between pulses
		end
		$stop;
	end
endmodule