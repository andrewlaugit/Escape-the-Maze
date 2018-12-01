`timescale 1ns / 1ns

// This module connects all the modules needed to run the game.
// It connects the logic with the display elements, along with the
// keyboard and switches/keys on the board.

// top level module for game
module EscapeTheMazeGame (
	// Board inputs
	CLOCK_50, KEY, SW,

	// Keyboard Bidirectional ports
	PS2_CLK,	PS2_DAT,
	
	// Board output ports
	HEX0,	HEX1,	HEX3,	HEX4,	HEX5,	LEDR,
	
	// VGA output ports
	VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B
);

	// Inputs
	input				CLOCK_50;
	input		[3:0]	KEY;
	input 	[9:0] SW;

	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;

	// Outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]

	output   [9:0] LEDR;
	output 	[6:0] HEX0,HEX1,HEX3,HEX4,HEX5;
	
	
	// Internal Wires
	wire 				resetn;
	wire				ps2_key_pressed;
	wire		[7:0]	ps2_key_data;
	
	wire 		[7:0] scoreGame;
	wire     [6:0] timeElapsed;

	wire 		[2:0] itemType1, itemType2, itemType3;
	wire 		[2:0] playerClr, screenClr, specialClr;
	
	wire 		[4:0] xInDraw, yInDraw;
	wire 		[4:0] xInErase, yInErase;
	wire 		[4:0] xPlus, yPlus, xMinus, yMinus;
	wire 		[4:0] checkX, checkY;
	
	wire 		[8:0] xRun, yRun;
	wire 		[8:0] xErase, yErase;
	wire 		[8:0] xScreen, yScreen;
	wire 		[8:0] xSpecial, ySpecial;
	wire 		[8:0] xDraw, yDraw;
	
	wire 		[9:0] addressFromDraw;

	wire 				playHard, playMedium, playEasy;
	wire 				drawMaze, drawSpecial, drawBox, eraseBox;
	wire 				doneMaze, doneSpecial, doneDraw, doneErase, doneScreen;
	wire 				drawWinner, drawGameOver, drawStart, drawClear;
	wire 				gameWon, gameOver;
	wire 				externalReset;
	
	// Internal Registers
	
	reg		[7:0]	last_data_received;
	reg 		[2:0] colour;
	reg 		[2:0] itemType;
	reg 		[8:0] x, y;
	reg 		[9:0] address;
	
	assign resetn = KEY[0];
	
	// set all LEDs to turn on when game ends
	assign LEDR[0] = (drawWinner | drawGameOver);
	assign LEDR[1] = (drawWinner | drawGameOver);
	assign LEDR[2] = (drawWinner | drawGameOver);
	assign LEDR[3] = (drawWinner | drawGameOver);
	assign LEDR[4] = (drawWinner | drawGameOver);
	assign LEDR[5] = (drawWinner | drawGameOver);
	assign LEDR[6] = (drawWinner | drawGameOver);
	assign LEDR[7] = (drawWinner | drawGameOver);
	assign LEDR[8] = (drawWinner | drawGameOver);
	assign LEDR[9] = (drawWinner | drawGameOver);
	
	// determine which address to use to access maze information on RAM
	always @(*) begin
		if(drawMaze)
			address <= addressFromDraw;
		else 
			address <= {checkY, checkX};
	end
	
	// determine which Maze information to use
	always @(*) begin
		if (playHard)
			itemType <= itemType2;
		if (playMedium)
			itemType <= itemType1;
		if (playEasy)
			itemType <= itemType3;
	end
	
	// determine which x,y coordinates to use
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
		if(drawSpecial) begin
			x <= xSpecial;
			y <= ySpecial;
		end
		if(drawWinner || drawGameOver || drawStart || drawClear) begin
			x <= xScreen;
			y <= yScreen;
		end
		
	end
	
	// determine colour to use
	always @(*) begin
		if(resetn | ~externalReset)
			colour <= 3'b0;
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
			colour <= playerClr;
		if(drawSpecial)
			colour <= specialClr;
		if(drawWinner || drawGameOver || drawStart || drawClear)
			colour <= screenClr;
		if(~drawMaze && ~eraseBox && ~drawBox && ~drawSpecial && ~(drawWinner || drawGameOver || drawStart || drawClear))
			colour <= 3'b000;
	end
	
	// determine last_data_received for input logic
	always @(posedge CLOCK_50)	begin
		if(resetn | ~externalReset)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end
	
	// VGA Display module
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(1'b1),
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
	
	// Maze Display Counter
	maze_position_counter maze_run_thru(
		.clk(CLOCK_50),
		.enable(drawMaze),
		.resetn(resetn | ~externalReset),
		.address(addressFromDraw),
		.xLoc(xRun),
		.yLoc(yRun),
		.done(doneMaze)
	);
	
	// Maze design RAM modules
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
	
	// Move character on screen
	eraseOldBox erase1(
		.clk(CLOCK_50),	
		.eraseBox(eraseBox),
		.resetn(resetn | ~externalReset),
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
		.resetn(resetn | ~externalReset),
		.xIn(xInDraw),
		.yIn(yInDraw),
		.xLoc(xDraw),
		.yLoc(yDraw),
		.colour(playerClr),
		.done(doneDraw)
	);
	
	// Draw start, win, game over screen
	outputScreen draw2(
		.clk(CLOCK_50),
		.drawWinner(drawWinner),
		.drawGameOver(drawGameOver),
		.drawStart(drawStart | externalReset),
		.drawClear(drawClear),
		.resetn(resetn),
		.xLoc(xScreen),
		.yLoc(yScreen),
		.colour(screenClr),
		.done(doneScreen)
	);
	
	// Draw +,- boxes
	outputSpecialBox draw3(
		.clk(CLOCK_50),
		.drawSpecial(drawSpecial),
		.resetn(resetn | ~externalReset),
		.xPlus(xPlus),
		.yPlus(yPlus),
		.xMinus(xMinus),
		.yMinus(yMinus),
		.xLoc(xSpecial),
		.yLoc(ySpecial),
		.colour(specialClr),
		.done(doneSpecial)
	);
	
	// Keyboard input module
	PS2_Controller PS2 (
		.CLOCK_50(CLOCK_50),
		.reset(~resetn),
		.PS2_CLK	(PS2_CLK),
		.PS2_DAT	(PS2_DAT),
		.received_data	(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);

	
	// Game logic module
	handshake FSM(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.ps2_key_pressed(ps2_key_pressed),
		.ps2_key_data(ps2_key_data),
		.valueInMemory(itemType),
		.doneMaze(doneMaze),
		.doneDraw(doneDraw),
		.doneErase(doneErase),
		.doneSpecial(doneSpecial), 
		.doneScreen(doneScreen),
		.hard(SW[9]),
		.med(SW[8]),
		.easy(SW[7]),
		.score(scoreGame),
		.drawX(xInDraw),
		.drawY(yInDraw),
		.prevX(xInErase),
		.prevY(yInErase),
		.changedX(checkX),
		.changedY(checkY),
		.drawBox(drawBox),
		.eraseBox(eraseBox),
		.drawMaze(drawMaze),
		.drawSpecial(drawSpecial),
		.drawStart(drawStart),
		.drawClear(drawClear),
		.gameWon(drawWinner),
		.gameOver(drawGameOver),
		.playHard(playHard),
		.playMedium(playMedium),
		.playEasy(playEasy),
		.externalReset(externalReset),
		.addFiveX(xPlus),
		.addFiveY(yPlus),
		.subFiveX(xMinus),
		.subFiveY(yMinus),
		.timeElapsed(timeElapsed)
	);
	
	// 7 segment display modules
	Hexadecimal_To_Seven_Segment Segment0 ( //ones digit of time
		.hex_number(timeElapsed%10'd10),
		.seven_seg_display(HEX0)
	);
	
	Hexadecimal_To_Seven_Segment Segment1 ( //tens digit of time
		.hex_number	((timeElapsed/10'd10)%10'd10),
		.seven_seg_display(HEX1)
	);
	
	Hexadecimal_To_Seven_Segment Segment3 ( //ones digit of score
		.hex_number(scoreGame%10'd10),
		.seven_seg_display(HEX3)
	);
	
	Hexadecimal_To_Seven_Segment Segment4 ( //tens digit of score
		.hex_number	((scoreGame/10'd10)%10'd10),
		.seven_seg_display(HEX4)
	);
	
	Hexadecimal_To_Seven_Segment Segment5 ( //hundreds digit of score
		.hex_number	((scoreGame/10'd100)),
		.seven_seg_display(HEX5)
	);
	
endmodule
