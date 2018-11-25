`timescale 1ns/1ns

module week2test (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	// Bidirectionals
	PS2_CLK,	PS2_DAT,
	
	// Outputs
	//pX,pY,nX,nY,
	//scoreGame,
	HEX0,	HEX1,	HEX2,	HEX3,	HEX4,	HEX5,
	LEDR,
	// The ports below are for the VGA output.  Do not change.
	VGA_CLK,   					//	VGA Clock
	VGA_HS,						//	VGA H_SYNC
	VGA_VS,						//	VGA V_SYNC
	VGA_BLANK_N,				//	VGA BLANK
	VGA_SYNC_N,					//	VGA SYNC
	VGA_R,   					//	VGA Red[9:0]
	VGA_G,	 					//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]

);

	// Inputs
	input				CLOCK_50;
	input		[3:0]	KEY;
	input 	[9:0] SW;

	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;

	/*****************************************************************************
	 *                 Internal Wires and Registers Declarations                 *
	 *****************************************************************************/

	// Internal Wires
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;

	//output [4:0] nX, nY;
	//output [4:0] pX, pY;
	wire [9:0] scoreGame;

	output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	
	// Internal Registers
	reg			[7:0]	last_data_received;
	
	wire [4:0] nXMod4;
	wire [4:0] nYMod4;
	
	assign nXMod4 = xInDraw/3'b100;
	assign nYMod4 = yInDraw/3'b100;





	// Do not change the following outputs
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]

	output   [9:0] LEDR;
	
	wire resetn, enable;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	reg [2:0] colour;
	reg [2:0] vgaColour;
	reg [0:0] player1work;
	reg [0:0] exitwork;
	


	wire [2:0] itemType1, itemType2, itemType3;
	reg [2:0] itemType;
	wire [4:0] xInDraw, yInDraw;
	wire [4:0] xInErase, yInErase;
	reg [8:0] x, y;
	wire [8:0] xRun, yRun;
	wire [8:0] xErase, yErase;
	wire [8:0] xDraw, yDraw;
	reg [9:0] address;
	wire [9:0] addressFromDraw;
	wire [4:0] checkX, checkY;
	

	wire [2:0] playerClr;
	wire [2:0] colourExit;
	wire drawMaze, drawBox, eraseBox;
	wire doneMaze, doneDraw, doneErase;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(1'b1),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
	
	maze_position_counter maze_run_thru(
		.clk(CLOCK_50),
		.enable(drawMaze),
		.resetn(resetn),
		.address(addressFromDraw),
		.xLoc(xRun),
		.yLoc(yRun),
		.done(doneMaze)
	);
	
	
	always @(*) begin
		if(drawMaze)
			address <= addressFromDraw;
		else 
			address <= {checkY, checkX};
	end
	
	always @(*) begin
		if(SW[9])
			itemType <= itemType2;
		if(SW[8])
			itemType <= itemType1;
		if(SW[7])
			itemType <= itemType3;
	end
	
	
	maze1Ram mazeHard( //hard
		.address(address),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(itemType1)
	);
	
	maze2Ram mazeCrazy( //crazy
		.address(address),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(itemType2)
	);
	
	maze3Ram mazeEasy( //easy
		.address(address),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(itemType3)
	);
	
	eraseOldBox erase1(
		.clk(CLOCK_50),	
		.eraseBox(eraseBox),
		.resetn(resetn),
		.xIn(xInErase),
		.yIn(yInErase),
		.xLoc(xErase),
		.yLoc(yErase),
		.colour(),
		.done(doneErase)
	);
	
	
	eraseOldBox draw1(
		.clk(CLOCK_50),
		.eraseBox(drawBox),
		.resetn(resetn),
		.xIn(xInDraw),
		.yIn(yInDraw),
		.xLoc(xDraw),
		.yLoc(yDraw),
		.colour(playerClr),
		.done(doneDraw)
	);
	
	
	
	always @(*) begin
		if(drawBox) begin
			x <= xDraw;
			y <= yDraw;
		end
		if(eraseBox) begin
			x <= xErase;
			y <= yErase;
		end
		if(drawMaze) begin
			x <= xRun;
			y <= yRun;
		end
	end
	
	
	always @(*) begin
		if(drawMaze) begin
			if(itemType == 3'b1)
				colour <= 3'b101;
			if(itemType == 3'b0)
				colour <= 3'b110;
			if(itemType == 3'd2)
				colour <= 3'b001;
			if(itemType == 3'd3)
				colour <= 3'b010;
		end
		if(eraseBox)
			colour <= 3'b101;
		if(drawBox)
			colour <= playerClr;//3'b001;
		if(~drawMaze && ~eraseBox && ~drawBox)
			colour <= 3'b000;
	end
	
	always @(posedge CLOCK_50)	begin
		if (KEY[0] == 1'b0)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end

	PS2_Controller PS2 (
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.PS2_CLK	(PS2_CLK),
		.PS2_DAT	(PS2_DAT),
		.received_data	(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);

	wire over;
	assign LEDR[0] = over;
	assign LEDR[1] = over;
	assign LEDR[2] = over;
	assign LEDR[3] = over;
	assign LEDR[4] = over;
	assign LEDR[5] = over;
	assign LEDR[6] = over;
	assign LEDR[7] = over;
	assign LEDR[8] = over;
	assign LEDR[9] = over;
	
	handshake FSM(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.ps2_key_pressed(ps2_key_pressed),
		.ps2_key_data(ps2_key_data),
		.valueInMemory(itemType),
		.drawX(xInDraw),
		.drawY(yInDraw),
		.prevX(xInErase),
		.prevY(yInErase),
		.score(scoreGame),
		.doneMaze(doneMaze),
		.doneDraw(doneDraw),
		.doneErase(doneErase),
		.drawBox(drawBox),
		.eraseBox(eraseBox),
		.drawMaze(drawMaze),
		.changedX(checkX),
		.changedY(checkY),
		.doneGame(over)
	);
	
		
	Hexadecimal_To_Seven_Segment Segment0 (
		.hex_number(scoreGame%10'd10),
		.seven_seg_display(HEX0)
	);
	
	Hexadecimal_To_Seven_Segment Segment1 (
		.hex_number	((scoreGame/10'd10)%10'd10),
		.seven_seg_display(HEX1)
	);
	
	Hexadecimal_To_Seven_Segment Segment2 (
		.hex_number	((scoreGame/10'd100)),
		.seven_seg_display(HEX2)
	);
	
	Hexadecimal_To_Seven_Segment Segment3 (
		.hex_number(scoreGame%10'd10),
		.seven_seg_display(HEX3)
	);
	
	Hexadecimal_To_Seven_Segment Segment4 (
		.hex_number	((scoreGame/10'd10)%10'd10),
		.seven_seg_display(HEX4)
	);
	
	Hexadecimal_To_Seven_Segment Segment5 (
		.hex_number	((scoreGame/10'd100)),
		.seven_seg_display(HEX5)
	);
		
endmodule

//top level module
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



//************************************************************************************************************************************************
//change position FSM	
//http://www.ee.ic.ac.uk/pcheung/teaching/ee2_digital/Lecture%207%20-%20FSM%20part%202.pdf info about FSMs

module positionControl(
	input clock,
	input resetn,
	input received_data_en,
	input [7:0] received_data,
	input doneCheckLegal,
	input isLegal,
	input doneMaze,
	input doneDraw,
	input doneErase,
	output reg moveUp,
	output reg moveDown,
	output reg moveLeft,
	output reg moveRight,
	output reg drawBox,
	output reg eraseBox,
	output reg drawMaze,
	output reg doneChangePosition,
	output reg [3:0] currentStateP, nextStateP
	);
	
	//reg [3:0] currentStateP, nextStateP;
	
	localparam  DRAW_MAZE 				= 4'd0,
					IDLE 						= 4'd1,
					LOAD_DIRECTION 		= 4'd2,
					DELETE_OLD 				= 4'd3,
					CHANGE_POSITION 		= 4'd4,
					MODIFICATIONS 			= 4'd5,
					CHANGE_CURRENT 		= 4'd6,
					DONT_CHANGE_CURRENT 	= 4'd7,
					DRAW_NEW 				= 4'd8;
				
	//next state logic
	//Question: what do I do exactly with the next state info?
	//should i send out the changePosition done flag only?
	//do I need to enable the registers to read/write data?
	always @ (*)
	begin: state_table
		case(currentStateP)
			DRAW_MAZE:				nextStateP = doneMaze ? IDLE : DRAW_MAZE;
			IDLE: 					nextStateP = received_data_en ? LOAD_DIRECTION : IDLE;
			LOAD_DIRECTION: 		nextStateP = received_data_en ? LOAD_DIRECTION : DELETE_OLD;
			DELETE_OLD: 			nextStateP = doneErase ? CHANGE_POSITION : DELETE_OLD;
			CHANGE_POSITION: 		nextStateP = doneCheckLegal ? MODIFICATIONS : CHANGE_POSITION;
			MODIFICATIONS: 		nextStateP = isLegal ? CHANGE_CURRENT : DONT_CHANGE_CURRENT;
			CHANGE_CURRENT: 		nextStateP = DRAW_NEW;
			DONT_CHANGE_CURRENT: nextStateP = DRAW_NEW;
			DRAW_NEW: 				nextStateP = doneDraw ? IDLE : DRAW_NEW;
			default: 				nextStateP = IDLE;
		endcase
	end
	
	//raising the doneChangePosition flag
	//if you needed enable signals for the registers, this is where you would add them
	//just change the states to have begin/end
	always @ (*)
	begin: isDoneChangingPosition
		doneChangePosition = 1'b0;
		drawBox = 1'b0;
		eraseBox = 1'b0;
		drawMaze = 1'b0;
		
		case(currentStateP)
			DRAW_MAZE: drawMaze = 1'b1;
			
			IDLE: doneChangePosition = 1'b0;
			
			LOAD_DIRECTION: doneChangePosition = 1'b1;
			
			DELETE_OLD: begin
				eraseBox = 1'b1;
				doneChangePosition = 1'b1;
			end
			
			CHANGE_POSITION: doneChangePosition = 1'b0;
			
			MODIFICATIONS: doneChangePosition = 1'b0;
			
			//where should i raise the flag that the position has changed?
			//CHANGE_CURRENT: //doneChangePosition = 1'b0;
			
			//DONT_CHANGE_CURRENT: //doneChangePosition = 1'b0;
			
			DRAW_NEW: drawBox = 1'b1;
			
			//default: doneChangePosition = 1'b0; //technically don't need default
		endcase
	end
	
	localparam  W = 8'h1d; //move up
	localparam	A = 8'h1c; //move left
	localparam	S = 8'h1b; //move down
	localparam	D = 8'h23; //move right
				
	//determine if key pressed corresponds to moving up/down/left/right
	always @ (*)
	begin: directionOfMovement
	
		moveUp = 1'b0;
		moveDown = 1'b0;
		moveRight = 1'b0;
		moveLeft = 1'b0;
		
		case(received_data)
			A: moveLeft = 1'b1;
			
			D: moveRight = 1'b1;
			
			W: moveUp = 1'b1;
			
			S: moveDown = 1'b1;
			//don't need default since variables are already initialized at the top of the case statement
			default: begin
				moveUp = 1'b0;
				moveDown = 1'b0;
				moveRight = 1'b0;
				moveLeft = 1'b0;
			end
			
		endcase
	end
	
	//current state registers
	always @ (posedge clock)
	begin: state_FFs
		if(!resetn)
			currentStateP <= DRAW_MAZE;
		else
			currentStateP <= nextStateP;
	end

endmodule

//24 x 24 board size
//each box is 10 bits wide

//Questions: Do I need load signals on the registers for tempCurrent, changedPosition, and newPosition?
module positionDatapath (
	input clock,
	input resetn,
	input received_data_en,
	input [4:0] currentX, currentY,
	input moveLeft, moveRight, moveUp, moveDown,
	input doneLegal, isLegal, gameOver,
	input scorePlusFive, scoreMinusFive,
	output reg [4:0] tempCurrentX, tempCurrentY,
	output reg [4:0] changedX, changedY,
	output reg [4:0] newX, newY,
	output reg [4:0] prevX, prevY,
	output reg [9:0] numberOfMoves
	//output reg donePosition
	);
	
	localparam MOVE_ONE_OVER = 5'b00001; //how big is one square on the board?
	
	reg [0:0] doneOnce;
	reg [0:0] doneTwice;

	//multiplexer for determining the value of tempCurrent X and Y
	//technically you don't need an always block for this stuff
	always @ (posedge clock) 
	begin: tempCurrent
	
		if(!resetn) begin
		//do I need this here? because...
			tempCurrentX <= currentX;
			tempCurrentY <= currentY;
			prevX <= currentX;
			prevY <= currentY;
			
		end
		
		else begin
			//... this takes care of the case where resetn is 0 (ie: do the resetting) and sets (X,Y) to (0,0)
			//doneOnce <= 0;
			prevX <= tempCurrentX;
			prevY <= tempCurrentY;
			tempCurrentX <= newX;
			tempCurrentY <= newY;
		end
		
	end
	
	//ALU for determining the value of changedX and changedY
	always @ (posedge received_data_en,  negedge resetn)
	begin: changedPosition

		if(!resetn) begin
			changedX <= 5'd1; //size?
			changedY <= 5'd0; //size?
			numberOfMoves <= 10'd0;
			doneOnce <= 0; 
			doneTwice <= 0;
		end
		
		else begin
			if(doneTwice)
				doneOnce <= 0;
			if(doneOnce)
				doneTwice <= 1;
			if(~doneOnce) begin
				doneOnce <= 1'b1;
				if(gameOver) begin
					changedX <= tempCurrentX;
					changedY <= tempCurrentY;
					numberOfMoves <= numberOfMoves + 10'd0;
				end
				
				else begin
					if(scorePlusFive) begin
					
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
					end
					else if(scoreMinusFive) begin
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
					end
					
					else begin
					
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
					end
					
					else begin	
						changedX <= tempCurrentX;
						changedY <= tempCurrentY;
					end
				end
			end
			
		end	
		//donePosition = 1'b1 //raise donePosition flag so legal moves FSM can do its thing
	end
	
	
	
	//multiplexer for determining the value of newPosition
	//technically you don't need an always block for this stuff
	always @ (posedge clock)
	begin: newPosition
		if(!resetn) begin 	
			newX <= 5'd1;
			newY <= 5'd0;
		end
		
		else if(doneLegal & gameOver) begin //no change to newX or newY, should I load them with the current or changed values of X and Y?
			newX <= tempCurrentX;
			newY <= tempCurrentY;
		end
		
		else if(doneLegal & !gameOver) begin
			
			if(isLegal) begin
				newX <= changedX;
				newY <= changedY;
			end
			
			else if(!isLegal) begin
				newX <= tempCurrentX;
				newY <= tempCurrentY;
			end
		end
		 
	end
	
endmodule

//************************************************************************************************************************************************
module legalControl(
	input clock,
	input resetn,
	input doneChangePosition,
	input [2:0] valueInMemory,
	//input [9:0] memory, 
	input [4:0] x,
	input [4:0] y,
	input moveLeft, moveRight, moveUp, moveDown,
	output reg doneCheckLegal,
	output reg isLegal,
	output reg gameOver,
	output reg scorePlusFive, scoreMinusFive,
	output reg [2:0] currentStateL, nextStateL
	);
	
	localparam AVAILABLE = 4'h1,
				OCCUPIED = 4'h0,
				START = 4'h2,
				END = 4'h3,
				YOUR_POSITION = 4'h4;
				PLUS_FIVE = 4'h5;
				MINUS_FIVE = 4'h6;
				
	localparam WIDTH = 5'b10000; 
	
	//wire [2:0] valueInMemory;
	//assign valueInMemory = memory[WIDTH * y + x];
	
	//reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'b000,
				CHECK_MEMORY = 3'b001,
				NOT_LEGAL = 3'b010,
				LEGAL = 3'b011,
				ADD_FIVE_TO_SCORE = 3'b100;
				MINUS_FIVE_FROM_SCORE = 3'b101;
				WON = 3'b110;
				
	localparam  TOP = 5'b00000,
					LEFT = 5'b00000,
					RIGHT = 5'b10111,
					BOTTOM = 5'b10111;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentStateL)
			IDLE: nextStateL = doneChangePosition ? CHECK_MEMORY : IDLE;
			
			CHECK_MEMORY: begin
				if(x == LEFT && moveLeft)
					nextStateL = NOT_LEGAL;
				else if(x == RIGHT && moveRight)
					nextStateL = NOT_LEGAL;
				else if(y == TOP && moveUp)
					nextStateL = NOT_LEGAL;
				else if(y == BOTTOM && moveDown)
					nextStateL = NOT_LEGAL;
				else if(valueInMemory == OCCUPIED)
					nextStateL = NOT_LEGAL;
				else if(valueInMemory == PLUS_FIVE)
					nextStateL = ADD_FIVE_TO_SCORE;
				else if(valueInMemory == MINUS_FIVE)
					nextStateL = MINUS_FIVE_FROM_SCORE;
				else
					nextStateL = LEGAL;
			end
			
			NOT_LEGAL: nextStateL = IDLE;
			
			LEGAL: nextStateL = (valueInMemory == END) ? WON : IDLE;
			
			ADD_FIVE_TO_SCORE: nextStateL = IDLE;
			
			MINUS_FIVE_FROM_SCORE: nextStateL = IDLE;
			
			WON: nextStateL = resetn ? WON : IDLE; //if not reset, remain in won state; if reset, start again from the top
			
			default: nextStateL = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		scorePlusFive = 1'b0;
		scoreMinusFive = 1'b0;
		
		case(currentStateL)
		
			IDLE: doneCheckLegal <= 1'b0;
			
			CHECK_MEMORY: doneCheckLegal <= 1'b0;
			
			LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
			end
			
			NOT_LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b0;
			end
			
			ADD_FIVE_TO_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b0;
				scorePlusFive <= 1'b1;
			end
			
			MINUS_FIVE_FROM_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b0;
				scoreMinusFive <= 1'b1;
			end
			
			WON: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
				gameOver <= 1'b1;
			end
			
		endcase
	end
	
	//current state registers
	always @ (posedge clock)
	begin: state_FFs
		if(!resetn)
			currentStateL <= IDLE;
		else
			currentStateL <= nextStateL;
	end
	
endmodule
