#defines working directory where all verilog compiled files go
vlib work1
#compile all verilog modules in test.v to working directory
vlog mazePathOut.v
#load simultation using test as top level module
vsim mazePathOut
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {20ns} -r 40ns
force {resetn} 0
run 40 ns
force {resetn} 1
run 10000 ns