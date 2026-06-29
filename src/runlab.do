# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "victoryDisplay.sv"
vlog "topLight.sv"
vlog "slowDown.sv"
vlog "seg7.sv"
vlog "pointDisplay.sv"
vlog "pointCounter.sv"
vlog "playfield.sv"
vlog "pipeColumn.sv"
vlog "normalLight.sv"
vlog "newPipe.sv"
vlog "metaFilter.sv"
vlog "LEDDriver.sv"
vlog "LED_test.sv"
vlog "comparator10.sv"
vlog "collisionCheck.sv"
vlog "clock_divider.sv"
vlog "centerLight.sv"
vlog "bottomLight.sv"
vlog "birdLight.sv"
vlog "DE1_SoC.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do DE1_SoC_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
