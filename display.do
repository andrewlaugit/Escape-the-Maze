#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog displayOutput.v
#load simultation using test as top level module
vsim -L altera_mf_ver display
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {20ns} -r 40ns
force {KEY[0]} 1
run 50000 ns