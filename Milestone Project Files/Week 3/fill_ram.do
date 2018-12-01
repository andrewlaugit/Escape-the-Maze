#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog fill_ram.v read_txt_to_ram.v
#load simultation using test as top level module
vsim fill_ram
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {20ns} -r 40ns

force {resetn} 1'b0
run 40 ns
force {resetn} 1'b1
run 4000 ns
