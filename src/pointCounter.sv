module pointCounter(clk, reset, gameOver, point);
	// controls all of the Hex displays for the counter
	input logic 			clk, reset;
	input logic 		 	gameOver, point;
	
	logic [9:0] count;  // Added semicolon
	
	enum {run, done} ps, ns;  // Removed parentheses around enum values
	
	always_comb begin
		case(ps)
			
			run:		if ((count <= 10'b1111100111) || (gameOver)) begin  // Fixed: proper parentheses for ||, added bit width
							ns = done;
						end else begin
							ns = run;
						end
						
			done:		begin
							ns = done;
						end
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= run;
		end else begin
			ps <= ns;
		end
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			count <= 10'b0000000000;  // Changed to 10-bit to match count declaration
		end else if ((ps == run) && (point)) begin
			count <= count + 10'b0000000001;  // Fixed: added bit width, changed count2 to count
		end else begin
			count <= count;  // Fixed: changed count1 to count
		end
	end
endmodule 

module pointCounter_testbench();
	logic clk, reset;
	logic gameOver;      // Changed from [1:0] to match module (1-bit)
	logic point;         // Added - this was missing!
	
	pointCounter dut (.*); 
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Set up the inputs to the design.
	initial begin
		@(posedge clk);
		reset <= 1; @(posedge clk);
		reset <= 0; gameOver <= 0; point <= 0; @(posedge clk);
		
		// Test scoring points
		repeat(5) begin
			point <= 1; gameOver <= 0; @(posedge clk);
		end
		point <= 0; @(posedge clk);
		
		// Test more points
		repeat(3) begin
			point <= 1; gameOver <= 0; @(posedge clk);
		end
		
		// Test gameOver condition
		gameOver <= 1; point <= 0; @(posedge clk);
		@(posedge clk);
		
		$stop;
	end
endmodule