module pointDisplay(clk, reset, upCount, hex, nextHex);
	input  logic clk, reset;
	input  logic upCount;      // Pulse to increment this digit
	output logic [6:0] hex;    // 7-segment display output
	output logic nextHex;      // Carry out to next digit
	
	logic [3:0] count;         // Current digit value (0-9)
	
	// Counter logic
	always_ff @(posedge clk) begin
		if (reset) begin
			count <= 4'b0;
		end else if (upCount) begin
			if (count == 4'd9) begin
				count <= 4'b0;  // Roll over to 0
			end else begin
				count <= count + 4'b1;
			end
		end
	end
	
	// Generate carry signal when rolling over from 9 to 0
	assign nextHex = (upCount && (count == 4'd9));
	
	// 7-segment decoder (active low for DE1-SoC)
	always_comb begin
		case (count)
			4'd0: hex = 7'b1000000; // 0
			4'd1: hex = 7'b1111001; // 1
			4'd2: hex = 7'b0100100; // 2
			4'd3: hex = 7'b0110000; // 3
			4'd4: hex = 7'b0011001; // 4
			4'd5: hex = 7'b0010010; // 5
			4'd6: hex = 7'b0000010; // 6
			4'd7: hex = 7'b1111000; // 7
			4'd8: hex = 7'b0000000; // 8
			4'd9: hex = 7'b0010000; // 9
			default: hex = 7'b1111111; // Blank
		endcase
	end
	
endmodule

module pointDisplay_testbench();
	logic clk, reset;
	logic upCount;
	logic [6:0] hex;
	logic nextHex;
	
	pointDisplay dut (.*);
	
	// Clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Test stimulus
	initial begin
		reset <= 1; upCount <= 0; @(posedge clk);
		reset <= 0; @(posedge clk);
		
		// Count from 0 to 9 and observe rollover
		repeat(12) begin
			upCount <= 1; @(posedge clk);
			upCount <= 0; @(posedge clk);
		end
		
		$stop;
	end
endmodule