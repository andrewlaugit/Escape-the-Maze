#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog user1Ram.v
#load simultation using test as top level module
vsim -L altera_mf_ver user1Ram
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clock} 0 0ns, 1 {20ns} -r 40ns

force {wren} 0
force {data} 111

force {address} 7'd0
run 40 ns
force {address} 7'd1
run 40 ns
force {address} 7'd2
run 40 ns
force {address} 7'd3
run 40 ns
force {address} 7'd4
run 40 ns
force {address} 7'd5
run 40 ns
force {address} 7'd6
run 40 ns
force {address} 7'd7
run 40 ns
force {address} 7'd8
run 40 ns
force {address} 7'd9
run 40 ns
force {address} 7'd10
run 40 ns
force {address} 7'd11
run 40 ns
force {address} 7'd12
run 40 ns
force {address} 7'd13
run 40 ns
force {address} 7'd14
run 40 ns
force {address} 7'd15
run 40 ns