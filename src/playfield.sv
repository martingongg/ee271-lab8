module playfield(clk, reset, L, R, leds);
	input  logic clk, reset;
	input  logic L, R;
	output logic [14:1] leds;
	
	logic [3:0] position;  // Track LED position (1-14)
	
	// Update position based on L/R inputs
	always_ff @(posedge clk) begin
		if (reset) begin
			position <= 4'd7;  // Start at center (LED 7 or 8)
		end else begin
			if (L && !R && position > 4'd1) begin
				position <= position - 4'd1;  // Move left
			end else if (R && !L && position < 4'd14) begin
				position <= position + 4'd1;  // Move right
			end
			// If both pressed or neither pressed, stay at current position
		end
	end
	
	// Decode position to LED output
	always_comb begin
		leds = 14'b0;  // All LEDs off by default
		case (position)
			4'd1:  leds[1]  = 1'b1;
			4'd2:  leds[2]  = 1'b1;
			4'd3:  leds[3]  = 1'b1;
			4'd4:  leds[4]  = 1'b1;
			4'd5:  leds[5]  = 1'b1;
			4'd6:  leds[6]  = 1'b1;
			4'd7:  leds[7]  = 1'b1;
			4'd8:  leds[8]  = 1'b1;
			4'd9:  leds[9]  = 1'b1;
			4'd10: leds[10] = 1'b1;
			4'd11: leds[11] = 1'b1;
			4'd12: leds[12] = 1'b1;
			4'd13: leds[13] = 1'b1;
			4'd14: leds[14] = 1'b1;
			default: leds = 14'b0;
		endcase
	end
	
endmodule


module playfield_testbench();
	logic clk, reset;
	logic L, R;           // Added - these were missing!
	logic up;             // You declared this but never use it - remove if not needed
	
	logic [14:1] leds;    // Assuming this is an output from playfield
	
	playfield dut(.*);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Set up the inputs to the design.
	initial begin
		reset <= 1; @(posedge clk);           // NEW GAME
		reset <= 0; L <= 0; R <= 0;           // CENTER LED[5]
		@(posedge clk);
		
		repeat(1) begin
			L <= 0; R <= 1; @(posedge clk);
		end
		repeat(2) begin
			L <= 1; R <= 0; @(posedge clk);
		end
		repeat(3) begin
			L <= 0; R <= 1; @(posedge clk);
		end
		repeat(4) begin
			L <= 1; R <= 0; @(posedge clk);
		end
		repeat(5) begin
			L <= 0; R <= 1; @(posedge clk);
		end
		repeat(6) begin
			L <= 1; R <= 0; @(posedge clk);
		end
		repeat(7) begin
			L <= 0; R <= 1; @(posedge clk);
		end
		repeat(8) begin
			L <= 1; R <= 0; @(posedge clk);
		end
		repeat(9) begin
			L <= 0; R <= 1; @(posedge clk);
		end
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end
endmodule
		