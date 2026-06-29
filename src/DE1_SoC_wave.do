onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/HEX0
add wave -noupdate /DE1_SoC_testbench/HEX1
add wave -noupdate /DE1_SoC_testbench/HEX2
add wave -noupdate /DE1_SoC_testbench/HEX3
add wave -noupdate /DE1_SoC_testbench/HEX4
add wave -noupdate /DE1_SoC_testbench/HEX5
add wave -noupdate /DE1_SoC_testbench/LEDR
add wave -noupdate /DE1_SoC_testbench/KEY
add wave -noupdate /DE1_SoC_testbench/SW
add wave -noupdate /DE1_SoC_testbench/GPIO_1
add wave -noupdate /DE1_SoC_testbench/CLOCK_50
add wave -noupdate /DE1_SoC_testbench/SYSTEM_CLOCK
add wave -noupdate /DE1_SoC_testbench/system_clk_counter
add wave -noupdate /DE1_SoC_testbench/bird_moved_up
add wave -noupdate /DE1_SoC_testbench/pipe_generated
add wave -noupdate /DE1_SoC_testbench/pipe_moved
add wave -noupdate /DE1_SoC_testbench/collision_detected
add wave -noupdate /DE1_SoC_testbench/score_ones
add wave -noupdate /DE1_SoC_testbench/score_tens
add wave -noupdate /DE1_SoC_testbench/score_hunds
add wave -noupdate /DE1_SoC_testbench/valid_score
add wave -noupdate /DE1_SoC_testbench/i
add wave -noupdate /DE1_SoC_testbench/j
add wave -noupdate /DE1_SoC_testbench/gen_count
add wave -noupdate /DE1_SoC_testbench/move_count
add wave -noupdate /DE1_SoC_testbench/timeout
add wave -noupdate /DE1_SoC_testbench/error_count
add wave -noupdate /DE1_SoC_testbench/prev_score
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {242 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
