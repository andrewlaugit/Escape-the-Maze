#defines working directory where all verilog compiled files go
vlib work
#compile all verilog modules in test.v to working directory
vlog gameDifficulty.v
#load simultation using test as top level module
vsim gameDifficulty
#log all signals and add some signals to waveform window
log {/*}
#add all items in top level simulation module
add wave {/*}


force {clock} 0 0ns, 1 {20ns} -r 40ns

force {resetn} 0
force {hard} 0
force {med} 0
force {easy} 0
run 40ns

force {resetn} 1
force {hard} 0
force {med} 0
force {easy} 0
run 40ns

force {resetn} 1
force {hard} 1
force {med} 0
force {easy} 0
run 40ns

force {resetn} 1
force {hard} 0
force {med} 1
force {easy} 0
run 40ns

force {resetn} 1
force {hard} 0
force {med} 0
force {easy} 1
run 40ns

force {resetn} 1
force {hard} 0
force {med} 0
force {easy} 0
run 40ns