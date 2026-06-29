module newPipe (clk, reset, gameOver, slow_clk, pattern);
	// generates a pseudo-random pattern for the pipes 
	input logic clk, reset;
	input logic gameOver, slow_clk;
	
	output logic [14:0] pattern; // Pattern corresponds to the columns of the LEDs that are on
	
	logic [2:0] numbr, numUse;
	logic [2:0] counter;
	logic [4:0] counter2;
	logic next_pipe;
	
	lfsr3 rand1(.clk, .reset, .out(numUse));
	
	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 3'b0;  // Fixed: was 1'b0, should match 3-bit width
		end else begin
			counter <= counter + 3'd1;
		end
	end
	
	assign numbr = numUse + counter + counter;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			counter2 <= 5'd3;  // Fixed: clearer 5-bit value instead of 2'b11
			next_pipe <= 1'b0;
		end else if (counter2 == 5'd4) begin  // Fixed: added bit width
			counter2 <= 5'b0;  // Fixed: added bit width
			next_pipe <= 1'b1;
		end else begin
			counter2 <= counter2 + 5'd1;
			next_pipe <= 1'b0;
		end
	end
	
	always_comb begin
		if (next_pipe && ~gameOver) begin
			case (numbr)
				3'b000: pattern = 15'b110000011111111;
				3'b001: pattern = 15'b111000001111111;
				3'b010: pattern = 15'b111100000111111;
				3'b011: pattern = 15'b111110000011111;
				3'b100: pattern = 15'b111111000001111;
				3'b101: pattern = 15'b111111100000111;
				3'b110: pattern = 15'b111111110000011;
				3'b111: pattern = 15'b111111111000001;
				default: pattern = 15'b000000000000000;
			endcase
		end else begin
			pattern = 15'b000000000000000;
		end
	end
	
endmodule

module lfsr3(clk, reset, out);
	input  logic clk, reset;
	output logic [2:0] out;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			out <= 3'b001;  // Non-zero seed value
		end else begin
			// LFSR feedback polynomial for 3-bit: x^3 + x^2 + 1
			out <= {out[1:0], out[2] ^ out[1]};
		end
	end
	
endmodule