#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog eraseOldBox.v
#load simultation using test as top level module
vsim -L altera_mf_ver eraseOldBox
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {20ns} -r 40ns
force {xIn} 5'd3
force {yIn} 5'd3
force {eraseBox} 0
force {resetn} 0
run 40 ns
force {eraseBox} 1
force {resetn} 1
run 8000 ns
