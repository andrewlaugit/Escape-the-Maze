#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog mazeRAM.v
#load simultation using test as top level module
vsim -L altera_mf_ver mazeRAM
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clock} 0 0ns, 1 {20ns} -r 40ns

force {wren} 0
force {data} 111

force {address} 10'b00
run 40 ns
force {address} 10'b01
run 40 ns
force {address} 10'b02
run 40 ns
force {address} 10'b1
run 40 ns
force {address} 10'b14
run 40 ns
force {address} 10'b15
run 40 ns
force {address} 10'b21
run 40 ns
force {address} 10'b25
run 40 ns