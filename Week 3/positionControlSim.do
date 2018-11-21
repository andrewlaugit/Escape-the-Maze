vlib work

vlog positionFSM.v

vsim positionControl

log {/*}

add wave {/*}

force {clock} 0 0ns, 1 {5ns} -r 10ns 

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {resetn} 0
force {received_data_en} 1
force {received_data[7:0]} 0010 0011
force {doneCheckLegal} 0
force {isLegal} 0
run 10ns

force {resetn} 1
force {received_data_en} 0
force {received_data[7:0]} 0010 0011
force {doneCheckLegal} 0
force {isLegal} 0
run 10ns

force {resetn} 1
force {received_data_en} 1
force {received_data[7:0]} 0010 0011
force {doneCheckLegal} 0
force {isLegal} 0
run 10ns

force {resetn} 1
force {received_data_en} 1
force {received_data[7:0]} 0010 0011
force {doneCheckLegal} 1
force {isLegal} 0
run 10ns

force {resetn} 1
force {received_data_en} 1
force {received_data[7:0]} 0010 0011
force {doneCheckLegal} 1
force {isLegal} 1
run 10ns
