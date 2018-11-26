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
	output [7:0] score,
	
	output [4:0] drawX, drawY, prevX, prevY,
	output [4:0] changedX, changedY,
	
	output drawBox,eraseBox,drawMaze, drawStart, drawClear,drawSpecial,
	
	output gameWon, gameOver,
	output playHard, playMedium, playEasy, externalReset,
	
	output [4:0] addFiveX, addFiveY, subFiveX, subFiveY,
	
	output [6:0] timeElapsed

	);
	
	wire doneCheckLegal, isLegal;
	
	wire doneChangePosition;
	wire over;
	
	wire [4:0] tempCurrentX, tempCurrentY;
	
	wire [7:0] numberOfMoves;
	
	wire noMoreMoves, noMoreTime;
	wire [25:0] delay;
	
	
	wire [4:0] plusFiveX, plusFiveY, minusFiveX, minusFiveY;
	
	wire scorePenalty, scoreBonus;
	
	wire moveUp, moveDown, moveLeft, moveRight;
	
	assign addFiveX = plusFiveX;
	assign addFiveY = plusFiveY;
	assign subFiveX = minusFiveX;
	assign subFiveY = minusFiveY;
	
	
		
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
		.externalReset(externalReset),
		
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
		.drawSpecial(drawSpecial),
		
		.doneChangePosition(doneChangePosition)
	);
	
	positionDatapath POSDATA( 
		.clock(clock),
		.resetn(resetn),
		.externalReset(externalReset),
		
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
		.externalReset(externalReset),
		
		.doneChangePosition(doneChangePosition),
		.valueInMemory(valueInMemory),
		.x(changedX),
		.y(changedY),
		
		.scorePlusFiveX(plusFiveX),
		.scorePlusFiveY(plusFiveY),
		.scoreMinusFiveX(minusFiveX),
		.scoreMinusFiveY(minusFiveY),
		
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),

		.noMoreMoves(noMoreMoves),
		.noMoreTime(noMoreTime),
		
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(over),
		.gameWon(gameWon),
		
		.scorePlusFive(scorePenalty),
		.scoreMinusFive(scoreBonus)
	);
	
	movesCounter COUNTMOVES(
		.clock(clock),
		.resetn(resetn),
		.externalReset(externalReset),
		.numberOfMoves(numberOfMoves),
		.noMoreMoves(noMoreMoves)
	);
	
	countTime TIME(
		.clock(clock),
		.resetn(resetn),
		.noMoreTime(noMoreTime),
		.externalReset(externalReset),
		.timeElapsed(timeElapsed)
	);
	
	assign score = numberOfMoves;
	
	assign gameOver = over;
	
endmodule
