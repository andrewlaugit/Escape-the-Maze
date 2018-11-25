module handshake(
	clock, resetn,
	ps2_key_pressed, ps2_key_data,
	valueInMemory,
	doneMaze, doneDraw, doneErase,
	drawX, drawY, prevX, prevY, 
	changedX, changedY,
	score,
	drawBox,eraseBox,drawMaze,
	gameWon, gameLost, gameOver,
	hard, med, easy,
	playHard, playMedium, playEasy, externalReset
	);

	// Inputs
	input clock;
	input resetn;
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
	input [2:0] valueInMemory;
	input doneMaze,doneDraw,doneErase;
	input hard, med, easy;
	
	//output
	output [9:0] score;
	output [4:0] drawX, drawY, prevX, prevY;
	output drawBox,eraseBox,drawMaze;
	
	output gameWon, gameLost, gameOver;
	output playHard, playMedium, playEasy, externalReset;
	
	wire doneCheckLegal, isLegal;
	wire moveUp, moveDown, moveLeft, moveRight;
	wire doneChangePosition;
	
	wire [4:0] tempCurrentX, tempCurrentY;
	
	output [4:0] changedX, changedY;
	
	wire [9:0] numberOfMoves;
	wire noMoreMoves, noMoreTime;
	wire [25:0] delay;
	
	wire scorePenalty, scoreBonus;
	
	gameDifficulty DIFFICULTY(
		.hard(hard),
		.med(med),
		.easy(easy),
		.clock(clock),
		.resetn(resetn),
		.playHard(playHard),
		.playMedium(playMedium),
		.playEasy(playEasy),
		.externalReset(externalReset)
	);
	
	positionControl POSCTRL(
		.clock(clock),
		.resetn(resetn),
		.received_data_en(ps2_key_pressed),
		.received_data(ps2_key_data),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.doneMaze(doneMaze),
		.doneDraw(doneDraw),
		.doneErase(doneErase),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.drawBox(drawBox),
		.eraseBox(eraseBox),
		.drawMaze(drawMaze),
		.doneChangePosition(doneChangePosition)
	);
	
	positionDatapath POSDATA( 
		.clock(clock),
		.resetn(resetn),
		.received_data_en(ps2_key_pressed),
		.currentX(5'd1),
		.currentY(5'd0),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(gameWon),
		.forceReset(externalReset),
		.scorePlusFive(scorePenalty),
		.scoreMinusFive(scoreBonus),
		.tempCurrentX(tempCurrentX),
		.tempCurrentY(tempCurrentY),
		.changedX(changedX),
		.changedY(changedY),
		.newX(drawX),
		.newY(drawY),
		.prevX(prevX),
		.prevY(prevY),
		.numberOfMoves(numberOfMoves)
		
	);
	
	legalControl LEGALCTRL(
		.clock(clock),
		.resetn(resetn),
		.doneChangePosition(doneChangePosition),
		.valueInMemory(valueInMemory),
		.x(changedX),
		.y(changedY),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.externalReset(externalReset),
		.noMoreMoves(noMoreMoves),
		.noMoreTime(noMoreTime),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameWon(gameWon),
		.gameLost(gameLost),
		.backToStart(gameOver),
		.scorePlusFive(scorePenalty),
		.scoreMinusFive(scoreBonus)
	);
	
	movesCounter COUNTMOVES(
		.clock(clock),
		.resetn(resetn),
		.numberOfMoves(numberOfMoves),
		.noMoreMoves(noMoreMoves)
	);
	
	delay1Hz ONESDELAY(
		.clock(clock),
		.resetn(resetn),
		.slowDown(delay)
	);
	
	wire go;
	assign go = (delay == 0) ? 1'b1 : 1'b0;
	
	gameDuration TIMEELAPSED(
		.go(go),
		.clock(clock),
		.resetn(resetn),
		.timeUp(noMoreTime)
	);
	
	assign score = numberOfMoves;
	
endmodule
