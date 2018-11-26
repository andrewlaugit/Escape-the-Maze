`timescale 1ns / 1ns

module EscapeTheMazeGame (
	// Board inputs
	CLOCK_50, KEY, SW,

	// Keyboard Bidirectional ports
	PS2_CLK,	PS2_DAT,
	
	// Board output ports
	HEX0,	HEX1,	HEX2,	HEX3,	HEX4,	HEX5,	LEDR,
	
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
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]

	output   [9:0] LEDR;
	output 	[6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	
	
	// Internal Wires
	wire 				resetn;
	wire				ps2_key_pressed;
	wire		[7:0]	ps2_key_data;
	
	wire 		[9:0] scoreGame;

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
	wire 				doneMaze, doneSpecial, doneDraw, doneErase;
	wire 				drawWinner, drawGameOver, drawStart, drawClear;
	wire 				doneScreen;
	wire 				gameWon, gameOver;

	//wire externalReset;
	
	// Internal Registers
	
	reg		[7:0]	last_data_received;
	reg 		[2:0] colour;
	reg 		[2:0] itemType;
	reg 		[8:0] x, y;
	reg 		[9:0] address;
	
	assign resetn = KEY[0];
	
	assign LEDR[0] = playHard;
	assign LEDR[1] = playMedium;
	assign LEDR[2] = playEasy;
	assign LEDR[3] = doneScreen;
	assign LEDR[4] = drawStart;
	assign LEDR[5] = drawClear;
	assign LEDR[6] = doneSpecial;
	assign LEDR[7] = drawMaze;
	assign LEDR[8] = (gameWon | gameOver);
	assign LEDR[9] = (gameWon | gameOver);
	
	
	/*assign LEDR[0] = (gameWon | gameOver);
	assign LEDR[1] = (gameWon | gameOver);
	assign LEDR[2] = (gameWon | gameOver);
	assign LEDR[3] = (gameWon | gameOver);
	assign LEDR[4] = (gameWon | gameOver);
	assign LEDR[5] = (gameWon | gameOver);
	assign LEDR[6] = (gameWon | gameOver);
	assign LEDR[7] = (gameWon | gameOver);
	assign LEDR[8] = (gameWon | gameOver);
	assign LEDR[9] = (gameWon | gameOver);
	*/

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
		if (playHard)
			itemType <= itemType2;
		if (playMedium)
			itemType <= itemType1;
		if (playEasy)
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
	
	//move character on screen
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
	
	//draw start, win, game over screen
	outputScreen draw2(
		.clk(CLOCK_50),
		.drawWinner(drawWinner),
		.drawGameOver(drawGameOver),
		.drawStart(drawStart),
		.drawClear(drawClear),
		.resetn(resetn),
		.xLoc(xScreen),
		.yLoc(yScreen),
		.colour(screenClr),
		.done(doneScreen)
	);
	
	//draw +,- boxes
	outputSpecialBox draw3(
		.clk(CLOCK_50),
		.drawSpecial(drawSpecial),
		.resetn(resetn),
		.xPlus(xPlus),
		.yPlus(yPlus),
		.xMinus(xMinus),
		.yMinus(yMinus),
		.xLoc(xSpecial),
		.yLoc(ySpecial),
		.colour(specialClr),
		.done(doneSpecial)
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
		if(drawSpecial) begin
			x <= xSpecial;
			y <= ySpecial;
		end
		if(drawWinner || drawGameOver || drawStart || drawClear) begin
			x <= xScreen;
			y <= yScreen;
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
		else if(eraseBox)
			colour <= 3'b101;
		else if(drawBox)
			colour <= playerClr;
		else if(drawSpecial)
			colour <= specialClr;
		else if(drawWinner || drawGameOver || drawStart || drawClear)
			colour <= screenClr;
		else //(~drawMaze && ~eraseBox && ~drawBox)
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
		.drawStart(drawStart),
		.drawClear(drawClear),
		
		.gameWon(drawWinner),
		.gameOver(drawGameOver),
		
		.playHard(playHard),
		.playMedium(playMedium),
		.playEasy(playEasy),
		.externalReset(externalReset)
		
		.addFiveX(xPlus),
		.addFiveY(yPlus),
		.subFiveX(xMinus),
		.subFiveY(yMinus)
		
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
