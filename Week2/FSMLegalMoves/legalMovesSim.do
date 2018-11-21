vlib work

vlog legalMoves.v

vsim legalMoves

log {/*}
add wave {/*}

#clock
force {clock} 0 0ns, 1 {5ns} -r 10ns 

######################################resetn
force {resetn} 0
force {doneChangePosition} 0
force {valueInMemory [2:0]} 000
force {x[4:0]} 00000
force {y[4:0]} 00000
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 0
force {moveDown} 0
run 10ns

######################################from 0,0, move left, no barrier, move should be illegal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00000
force {y[4:0]} 00000
force {moveLeft} 1
force {moveRight} 0
force {moveUp} 0
force {moveDown} 0
run 35ns

######################################from 0,0, move up, no barrier, move should be illegal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00000
force {y[4:0]} 00000
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 1
force {moveDown} 0
run 30ns

######################################from 0,0, move right, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00000
force {y[4:0]} 00000
force {moveLeft} 0
force {moveRight} 1
force {moveUp} 0
force {moveDown} 0
run 30ns

######################################from 1,0, move right, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00001
force {y[4:0]} 00000
force {moveLeft} 0
force {moveRight} 1
force {moveUp} 0
force {moveDown} 0
run 30ns

######################################from 2,0, move down, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00010
force {y[4:0]} 00000
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 0
force {moveDown} 1
run 30ns

######################################from 2,1, move down, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 00010
force {y[4:0]} 00001
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 0
force {moveDown} 1
run 30ns

######################################from 2,2, move down, yes barrier, move should be illegal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 000
force {x[4:0]} 00010
force {y[4:0]} 00010
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 0
force {moveDown} 1
run 30ns

######################################skip to some random position in the board, move up, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 01100
force {y[4:0]} 00111
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 1
force {moveDown} 0
run 30ns

######################################skip to some other random position in the board, move left, no barrier, move should be legal
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 10011
force {y[4:0]} 00011
force {moveLeft} 1
force {moveRight} 0
force {moveUp} 0
force {moveDown} 0
run 30ns

######################################skip to edge position in the board, move down, no barrier, exit found, move should be legal, game is won
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 011
force {x[4:0]} 11111
force {y[4:0]} 00011
force {moveLeft} 1
force {moveRight} 0
force {moveUp} 0
force {moveDown} 0
run 30ns

#####################################try to move up from win position, shouldn't move at all
force {resetn} 1
force {doneChangePosition} 1
force {valueInMemory [2:0]} 001
force {x[4:0]} 11111
force {y[4:0]} 00011
force {moveLeft} 0
force {moveRight} 0
force {moveUp} 1
force {moveDown} 0
run 30ns