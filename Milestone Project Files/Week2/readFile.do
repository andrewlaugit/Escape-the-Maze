#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog read_txt_to_ram.v
#load simultation using test as top level module
vsim read_txt_to_ram
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {20ns} -r 40ns

force {y} 2'h00

force {x} 2'h00
run 40 ns
force {x} 2'h01
run 40 ns
force {x} 2'h02
run 40 ns
force {x} 2'h03
run 40 ns
force {x} 2'h04
run 40 ns
force {x} 2'h05
run 40 ns
force {x} 2'h06
run 40 ns
force {x} 2'h07
run 40 ns
force {x} 2'h08
run 40 ns
force {x} 2'h09
run 40 ns

force {y} 2'h01

force {x} 2'h00
run 40 ns
force {x} 2'h01
run 40 ns
force {x} 2'h02
run 40 ns
force {x} 2'h03
run 40 ns
force {x} 2'h04
run 40 ns
force {x} 2'h05
run 40 ns
force {x} 2'h06
run 40 ns
force {x} 2'h07
run 40 ns
force {x} 2'h08
run 40 ns
force {x} 2'h09
run 40 ns

force {y} 2'h02

force {x} 2'h00
run 40 ns
force {x} 2'h01
run 40 ns
force {x} 2'h02
run 40 ns
force {x} 2'h03
run 40 ns
force {x} 2'h04
run 40 ns
force {x} 2'h05
run 40 ns
force {x} 2'h06
run 40 ns
force {x} 2'h07
run 40 ns
force {x} 2'h08
run 40 ns
force {x} 2'h09
run 40 ns

force {y} 2'h03

force {x} 2'h00
run 40 ns
force {x} 2'h01
run 40 ns
force {x} 2'h02
run 40 ns
force {x} 2'h03
run 40 ns
force {x} 2'h04
run 40 ns
force {x} 2'h05
run 40 ns
force {x} 2'h06
run 40 ns
force {x} 2'h07
run 40 ns
force {x} 2'h08
run 40 ns
force {x} 2'h09
run 40 ns

force {y} 2'h04

force {x} 2'h00
run 40 ns
force {x} 2'h01
run 40 ns
force {x} 2'h02
run 40 ns
force {x} 2'h03
run 40 ns
force {x} 2'h04
run 40 ns
force {x} 2'h05
run 40 ns
force {x} 2'h06
run 40 ns
force {x} 2'h07
run 40 ns
force {x} 2'h08
run 40 ns
force {x} 2'h09
run 40 ns
