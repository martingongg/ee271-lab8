// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

    // Turn off unused HEX displays
    assign HEX1 = '1;
    assign HEX2 = '1;
    
    // System clock setup - 1526 Hz (50 MHz / 2^15)
    logic [31:0] clk;
    logic SYSTEM_CLOCK;
    
    clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
    assign SYSTEM_CLOCK = clk[14];
    
    // LED board arrays
    logic [15:0][15:0] RedPixels;  // Red LEDs (pipes)
    logic [15:0][15:0] GrnPixels;  // Green LEDs (bird)
    logic RESET;
    
    // LED Driver instantiation
LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST(RESET), .EnableCount(1'b1), 
                  .RedPixels(RedPixels), .GrnPixels(GrnPixels), .GPIO_1);

    // Game signals
    logic jump, loser, upCount, gameOver;
    logic genCycle, shiftCycle;
    logic gotTen, gotHund, tooBig;
    logic [14:0] holdFirst;
 
    // Filter metastability from user inputs 
    metaFilter rst (.clk(SYSTEM_CLOCK), .key(~KEY[3]), .out(RESET));
    metaFilter keyPress (.clk(SYSTEM_CLOCK), .key(~KEY[0]), .out(jump));

    // Bird vertical control
    birdLight aFlappyBord (.clk(SYSTEM_CLOCK), .reset(RESET), .gameOver(gameOver), 
                           .up(jump), .arrayOut(GrnPixels));
    
    // Timing control
    slowDown createPipe (.clk(SYSTEM_CLOCK), .reset(RESET), .speed(4'b1111), .slow_clk(genCycle));
    slowDown movePipe (.clk(SYSTEM_CLOCK), .reset(RESET), .speed(4'b0011), .slow_clk(shiftCycle));
    
    // Generate new pipe offscreen
    newPipe offScreen (.clk(SYSTEM_CLOCK), .reset(RESET), .gameOver(gameOver), 
                       .slow_clk(genCycle), .pattern(holdFirst));
    
    // Generate pipe columns using a loop (OPTIMIZATION #1)
    genvar i;
    generate
        for (i = 1; i < 16; i++) begin : pipe_columns
            if (i == 1) begin
                pipeColumn col (.clk(SYSTEM_CLOCK), .reset(RESET), .gameOver(gameOver), 
                               .slow_clk(shiftCycle), .oldPipe(holdFirst), 
                               .currentPipe(RedPixels[i][14:0]));
            end else begin
                pipeColumn col (.clk(SYSTEM_CLOCK), .reset(RESET), .gameOver(gameOver), 
                               .slow_clk(shiftCycle), .oldPipe(RedPixels[i-1][14:0]), 
                               .currentPipe(RedPixels[i][14:0]));
            end
        end
    endgenerate
    
    // Collision detection
    collisionCheck bump (.clk(SYSTEM_CLOCK), .reset(RESET), .birdloc(GrnPixels[12][14:0]), 
                         .column3(RedPixels[12][14:0]), .point(upCount), .loser(loser));    
    
    // Display "L" on HEX0 if player loses
    seg7loser urBad (.lose(loser), .leds(HEX0));
    
    // Score display
    pointDisplay ones (.clk(SYSTEM_CLOCK), .reset(RESET), .upCount(upCount), 
                       .hex(HEX3), .nextHex(gotTen));
    pointDisplay tens (.clk(SYSTEM_CLOCK), .reset(RESET), .upCount(gotTen), 
                       .hex(HEX4), .nextHex(gotHund));
    pointDisplay hundz (.clk(SYSTEM_CLOCK), .reset(RESET), .upCount(gotHund), 
                        .hex(HEX5), .nextHex(tooBig));

    assign gameOver = loser | tooBig;  // OPTIMIZATION #3: Use | instead of ||
	 assign LEDR = 10'b0;
	 assign RedPixels[0] = 16'b0;
    
endmodule


`timescale 1ns/1ps

module DE1_SoC_testbench();
    // I/O signals matching DE1_SoC module
    wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0]  LEDR;
    reg  [3:0]  KEY;
    reg  [9:0]  SW;
    wire [35:0] GPIO_1;
    reg         CLOCK_50;
    
    // Internal test signals
    wire SYSTEM_CLOCK;
    reg [15:0] system_clk_counter;
    reg bird_moved_up, pipe_generated, pipe_moved, collision_detected;
    reg [3:0] score_ones, score_tens, score_hunds;
    reg valid_score;
    
    // Loop counters and temporary variables
    integer i, j;
    integer gen_count, move_count, timeout;
    integer error_count;
    reg [3:0] prev_score;
    
    // Instantiate DUT
    DE1_SoC dut (
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), 
        .HEX4(HEX4), .HEX5(HEX5), .KEY(KEY), .SW(SW), 
        .LEDR(LEDR), .GPIO_1(GPIO_1), .CLOCK_50(CLOCK_50)
    );
    
    // Extract internal SYSTEM_CLOCK via hierarchical reference
    assign SYSTEM_CLOCK = dut.SYSTEM_CLOCK;
    
    // Clock generation (50 MHz)
    parameter CLK_PERIOD = 20; // 50 MHz = 20 ns period
    initial begin
        CLOCK_50 = 0;
        forever #(CLK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
    end
    
    // System clock counter for verification timing
    always @(posedge SYSTEM_CLOCK or negedge KEY[3]) begin
        if (~KEY[3]) begin
            system_clk_counter <= 16'h0;
        end else begin
            system_clk_counter <= system_clk_counter + 1;
        end
    end
    
    // Score extraction logic (decode 7-segment displays)
    always @(*) begin
        decode_hex(HEX3, score_ones, valid_score);
    end
    
    always @(*) begin
        decode_hex(HEX4, score_tens, valid_score);
    end
    
    always @(*) begin
        decode_hex(HEX5, score_hunds, valid_score);
    end
    
    task decode_hex;
        input [6:0] hex;
        output [3:0] digit;
        output valid;
    begin
        valid = 1;
        case (hex)
            7'b1000000: digit = 0;  // 0
            7'b1111001: digit = 1;  // 1
            7'b0100100: digit = 2;  // 2
            7'b0110000: digit = 3;  // 3
            7'b0011001: digit = 4;  // 4
            7'b0010010: digit = 5;  // 5
            7'b0000010: digit = 6;  // 6
            7'b1111000: digit = 7;  // 7
            7'b0000000: digit = 8;  // 8
            7'b0010000: digit = 9;  // 9
            default: begin
                digit = 4'bx;
                valid = 0;
            end
        endcase
    end
    endtask
    
    // Monitor key events and game states
    always @(posedge SYSTEM_CLOCK or negedge KEY[3]) begin
        if (~KEY[3]) begin
            bird_moved_up <= 0;
            pipe_generated <= 0;
            pipe_moved <= 0;
            collision_detected <= 0;
        end else begin
            if (dut.jump) bird_moved_up <= 1;
            if (dut.genCycle) pipe_generated <= 1;
            if (dut.shiftCycle) pipe_moved <= 1;
            if (dut.loser) collision_detected <= 1;
        end
    end
    
    // Reset all test signals
    task reset_test_signals;
    begin
        bird_moved_up = 0;
        pipe_generated = 0;
        pipe_moved = 0;
        collision_detected = 0;
    end
    endtask
    
    // Wait for specific SYSTEM_CLOCK cycles
    task wait_sys_clks;
        input [15:0] num_clks;
        integer count;
    begin
        count = 0;
        while (count < num_clks) begin
            @(posedge SYSTEM_CLOCK);
            count = count + 1;
        end
    end
    endtask
    
    // Test sequence
    initial begin
        // Initialize all variables first
        error_count = 0;
        gen_count = 0;
        move_count = 0;
        timeout = 0;
        prev_score = 0;
        i = 0;
        j = 0;
        system_clk_counter = 0;
        
        // Initialize test flag signals
        bird_moved_up = 0;
        pipe_generated = 0;
        pipe_moved = 0;
        collision_detected = 0;
        
        $dumpfile("flappy_bird_wave.vcd");
        $dumpvars(0, DE1_SoC_testbench);
        
        // Initialize inputs
        KEY = 4'b1111; // Active-low buttons
        SW = 10'b0;
        
        // Small delay before applying reset
        #100;
        
        // Apply reset
        $display("[%0t] Applying system reset", $time);
        KEY[3] = 0; // Assert reset
        #200;
        wait_sys_clks(5);
        KEY[3] = 1; // Release reset
        reset_test_signals;
        wait_sys_clks(10);
        
        // Verify post-reset state
        if (LEDR !== 10'b0) begin
            $display("[%0t] ERROR: LEDR not cleared after reset (expected 0, got %b)", $time, LEDR);
            error_count = error_count + 1;
        end
        
        if (HEX0 !== 7'b1111111) begin
            $display("[%0t] ERROR: HEX0 not blank after reset (expected 1111111, got %b)", $time, HEX0);
            error_count = error_count + 1;
        end
        
        if (!valid_score || score_ones !== 0 || score_tens !== 0 || score_hunds !== 0) begin
            $display("[%0t] ERROR: Score not zero after reset (got %d%d%d)", $time, score_hunds, score_tens, score_ones);
            error_count = error_count + 1;
        end
        
        if (error_count == 0) $display("[%0t] Reset sequence verified", $time);
        
        // Test 1: Basic jump mechanics
        $display("[%0t] Testing jump mechanics", $time);
        reset_test_signals;
        KEY[0] = 0; // Jump button press
        wait_sys_clks(1);
        KEY[0] = 1;
        wait_sys_clks(3);
        if (!bird_moved_up) begin
            $display("[%0t] ERROR: Jump not detected", $time);
            error_count = error_count + 1;
        end
        else $display("[%0t] Jump registered successfully", $time);
        
        // Test 2: Pipe generation and movement
        $display("[%0t] Testing pipe mechanics", $time);
        reset_test_signals;
        wait_sys_clks(20); // Allow pipe generation cycle
        
        // Verify pipe generation
        gen_count = 0;
        timeout = 100;
        while (gen_count < 3 && timeout > 0) begin
            @(posedge SYSTEM_CLOCK);
            timeout = timeout - 1;
            if (pipe_generated) begin
                gen_count = gen_count + 1;
                $display("[%0t] Pipe generated #%0d", $time, gen_count);
                pipe_generated = 0;
            end
        end
        
        if (gen_count < 3) begin
            $display("[%0t] ERROR: Only %d pipes generated (expected 3)", $time, gen_count);
            error_count = error_count + 1;
        end
        
        // Verify pipe movement
        move_count = 0;
        timeout = 200;
        while (move_count < 5 && timeout > 0) begin
            @(posedge SYSTEM_CLOCK);
            timeout = timeout - 1;
            if (pipe_moved) begin
                move_count = move_count + 1;
                $display("[%0t] Pipe moved #%0d", $time, move_count);
                pipe_moved = 0;
            end
        end
        
        if (move_count < 5) begin
            $display("[%0t] ERROR: Only %d pipe movements detected (expected 5)", $time, move_count);
            error_count = error_count + 1;
        end
        
        if (error_count == 0) $display("[%0t] Pipe mechanics verified", $time);
        
        // Test 3: Score increment on pipe clearance
        $display("[%0t] Testing score increment", $time);
        reset_test_signals;
        prev_score = 0;
        
        // Navigate through 3 pipes
        for (i = 0; i < 3; i = i + 1) begin
            wait_sys_clks(15); // Wait for pipe approach
            KEY[0] = 0; 
            wait_sys_clks(1);
            KEY[0] = 1;
            wait_sys_clks(10); // Allow score update
            
            // Verify score incremented
            if (valid_score) begin
                if (score_ones !== prev_score + 1) begin
                    $display("[%0t] ERROR: Score mismatch (expected %d, got %d)", $time, prev_score+1, score_ones);
                    error_count = error_count + 1;
                end
                else begin
                    prev_score = score_ones;
                    $display("[%0t] Score incremented to %0d", $time, prev_score);
                end
            end
            else begin
                $display("[%0t] ERROR: Invalid score display after pipe clearance", $time);
                error_count = error_count + 1;
            end
        end
        
        if (error_count == 0) $display("[%0t] Score increment verified", $time);
        
        // Test 4: Collision detection
        $display("[%0t] Testing collision detection", $time);
        reset_test_signals;
        
        // Force collision by not jumping
        wait_sys_clks(25); // Wait for pipe approach
        wait_sys_clks(15); // Allow collision to register
        
        // Verify game over state
        if (!collision_detected) begin
            $display("[%0t] ERROR: Collision not detected", $time);
            error_count = error_count + 1;
        end
        
        if (HEX0 === 7'b1111111) begin
            $display("[%0t] ERROR: Game over not displayed on HEX0", $time);
            error_count = error_count + 1;
        end
        
        if (error_count == 0) $display("[%0t] Collision detected - Game over activated", $time);
        
        // Test 5: Reset after game over
        $display("[%0t] Testing post-game-over reset", $time);
        KEY[3] = 0;
        wait_sys_clks(5);
        KEY[3] = 1;
        reset_test_signals;
        wait_sys_clks(10);
        
        // Verify reset cleared game over state
        if (HEX0 !== 7'b1111111) begin
            $display("[%0t] ERROR: HEX0 not cleared after reset (got %b)", $time, HEX0);
            error_count = error_count + 1;
        end
        
        if (!valid_score || score_ones !== 0) begin
            $display("[%0t] ERROR: Score not reset after game over (got %d)", $time, score_ones);
            error_count = error_count + 1;
        end
        
        if (error_count == 0) $display("[%0t] Post-game-over reset verified", $time);
        
        // Test 6: Rapid jumps stress test
        $display("[%0t] Testing rapid jump handling", $time);
        for (i = 0; i < 8; i = i + 1) begin
            KEY[0] = 0;
            wait_sys_clks(1);
            KEY[0] = 1;
            wait_sys_clks(2);
        end
        wait_sys_clks(10);
        $display("[%0t] Rapid jumps handled without lockup", $time);
        
        // Final cleanup
        $display("[%0t] All tests completed. Error count: %0d", $time, error_count);
        if (error_count > 0) $display("TEST FAILURE");
        else $display("TEST SUCCESS");
        $finish;
    end
endmodule