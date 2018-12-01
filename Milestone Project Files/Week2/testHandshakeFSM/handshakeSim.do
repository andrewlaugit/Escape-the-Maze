vlib work
vlog handshake.v
vsim handshake

log {/*}
add wave {/*}

#clock
force {clock} 0 0ns, 1 {5ns} -r 10ns 

#move left: 1c = 00011100
#move right: 23 = 00100011
#move down: 1b = 00011011 
#move up: 1d = 00011101

####################################resetn
force {resetn} 0
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {valueInMemory[2:0]} 001
run 10ns

#################################move right from current position
force {resetn} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00100011
force {valueInMemory[2:0]} 001
run 10ns

force {resetn} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {valueInMemory[2:0]} 001
run 60ns
#results in a complete cycle