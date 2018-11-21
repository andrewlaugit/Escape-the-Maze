vlib work

vlog position.v

vsim position

log {/*}

add wave {/*}

force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns 

####################################################resetn
force {KEY[0]} 0
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

##################################################from 0,0 move right one
force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 0
run 10ns

###################################################from new position move down

force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00011011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 0
run 10ns

###################################################from new position move right

force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 0
run 20ns

###################################################from new position move right

force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 0
run 20ns

####################################################resetn
force {KEY[0]} 0
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

#################################################from 0,0, try to move up (illegal)
force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00011101
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011101
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011101
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 10ns

#################################################from 0,0, try to move left (illegal)
force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00011100
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011100
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 20ns

###############################################move down from curent position
force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00011011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011011
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00011011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 0
run 10ns

############################################move right results in gameOver condition, position shouldn't change
force {KEY[0]} 1
force {ps2_key_pressed} 1
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 0
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 0
force {gameOver} 0
run 10ns

force {KEY[0]} 1
force {ps2_key_pressed} 0
force {ps2_key_data[7:0]} 00100011
force {doneCheckLegal} 1
force {isLegal} 1
force {gameOver} 1
run 30ns
