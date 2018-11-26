module handshake(
	// Inputs
	input clock,
	input resetn,
	
	input [7:0] ps2_key_data,
	input ps2_key_pressed,
	
	input [2:0] valueInMemory,
	
	input doneMaze, doneDraw, doneErase, doneSpecial, doneScreen,
	input hard, med, easy,
	
	//Outputs
	output [9:0] score,
	
	output [4:0] drawX, drawY, prevX, prevY,
	output [4:0] changedX, changedY,
	
	output drawBox,eraseBox,drawMaze, drawStart, drawClear,
	
	output gameWon, gameOver,
	output playHard, playMedium, playEasy, externalReset
	);
	
	wire doneCheckLegal, isLegal;
	wire moveUp, moveDown, moveLeft, moveRight;
	wire doneChangePosition;
	
	wire [4:0] tempCurrentX, tempCurrentY;
	
	wire [7:0] numberOfMoves;
	
	wire noMoreMoves, noMoreTime;
	wire [25:0] delay;
	
	wire scorePenalty, scoreBonus;
	wire [4:0] plusFiveX, plusFiveY, minusFiveX, minusFiveY;

	wire over;
	
	gameDifficulty DIFFICULTY(
		.clock(clock),
		.resetn(resetn),
		
		.hard(hard),
		.med(med),
		.easy(easy),
		
		.playHard(playHard),
		.playMedium(playMedium),
		.playEasy(playEasy),
		
		.externalReset(externalReset),
		
		.scorePlusFiveX(plusFiveX),
		.scorePlusFiveY(plusFiveY),
		.scoreMinusFiveX(minusFiveX),
		.scoreMinusFiveY(minusFiveY)
	);
	
	positionControl POSCTRL(
		.clock(clock),
		.resetn(resetn),
		
		.switch9(hard),
		.switch8(med),
		.switch7(easy),
		
		.received_data_en(ps2_key_pressed),
		.received_data(ps2_key_data),
		
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		
		.doneMaze(doneMaze),
		.doneSpecial(doneSpecial),
		.doneDraw(doneDraw),
		.doneErase(doneErase),
		.doneScreen(doneScreen),
		
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		
		.drawBox(drawBox),
		.eraseBox(eraseBox),
		.drawMaze(drawMaze),
		.drawStart(drawStart),
		.drawClear(drawClear),
		
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
		.gameWon(gameWon),
		.gameOver(over),
		
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
		.gameOver(over),
		.gameWon(gameWon),
		
		.scorePlusFiveX(plusFiveX),
		.scorePlusFiveY(plusFiveY),
		.scoreMinusFiveX(minusFiveX),
		.scoreMinusFiveY(minusFiveY)
	);
	
	movesCounter COUNTMOVES(
		.clock(clock),
		.resetn(resetn),
		.numberOfMoves(numberOfMoves),
		.noMoreMoves(noMoreMoves)
	);
	
	assign score = numberOfMoves;
	
	assign gameOver = over;
	
endmodule