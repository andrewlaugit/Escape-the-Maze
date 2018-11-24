module handshake(
	clock,resetn,
	ps2_key_pressed,ps2_key_data,
	valueInMemory,
	doneMaze,doneDraw,doneErase,
	drawX,drawY,prevX,prevY,
	score,
	drawBox,eraseBox,drawMaze,
	//positionCurrentState, positionNextState,
	changedX, changedY,doneGame
	);

	// Inputs
	input clock;
	input resetn;
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
	input [2:0] valueInMemory;
	input doneMaze,doneDraw,doneErase;
	
	//output
	output [9:0] score;
	output [4:0] drawX,drawY,prevX,prevY;
	output drawBox,eraseBox,drawMaze;
	
	wire doneCheckLegal, isLegal;
	wire moveUp, moveDown, moveLeft, moveRight;
	wire doneChangePosition;
	output doneGame;
	
	wire [4:0] currentX, currentY;
	assign currentX = 5'b00001;
	assign currentY = 5'b00000;
	
	wire [4:0] tempCurrentX, tempCurrentY;
	output [4:0] changedX, changedY;
	wire [9:0] numberOfMoves;
	
	wire [2:0] legalCurrentState, legalNextState;
	wire [3:0] positionCurrentState, positionNextState;
	
	wire scorePenalty, scoreBonus;
	
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
		.doneChangePosition(doneChangePosition),
		.currentStateP(positionCurrentState),
		.nextStateP(positionNextState)
	);

	positionDatapath POSDATA( 
		.clock(clock),
		.resetn(resetn),
		.currentX(5'd1),
		.currentY(5'd0),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(doneGame),
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
		.numberOfMoves(numberOfMoves),
		.received_data_en(ps2_key_pressed)
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
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(doneGame),
		.scorePlusFive(scorePenalty),
		.scoreMinusFive(scoreBonus)
		.currentStateL(legalCurrentState),
		.nextStateL(legalNextState)
	);

	assign score = numberOfMoves;
	
	//still have to instantiate rate divider and 2 clock cycle delay stuff
endmodule