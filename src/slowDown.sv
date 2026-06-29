module slowDown (clk, reset, speed, slow_clk);
	input logic clk, reset;
	input logic [3:0] speed;     // Changed from [26:0] to match DE1_SoC
	output logic slow_clk;
	logic [3:0] counter;         // Changed from [25:0] to match speed
	
	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 4'b0;
			slow_clk <= 1'b0;
		end else if (counter == speed) begin
			counter <= 4'b0;
			slow_clk <= 1'b1;
		end else begin
			counter <= counter + 1'b1;
			slow_clk <= 1'b0;
		end
	end
endmodule