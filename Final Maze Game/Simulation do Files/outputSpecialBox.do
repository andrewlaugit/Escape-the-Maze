#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog outputSpecialBox.v
#load simultation using test as top level module
vsim outputSpecialBox
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {20ns} -r 40ns

force {xPlus} 5'd10
force {yPlus} 5'd10
force {xMinus} 5'd5
force {yMinus} 5'd5

force {drawSpecial} 0
force {resetn} 0
run 40 ns

force {resetn} 1
force {drawSpecial} 1
run 10000 ns