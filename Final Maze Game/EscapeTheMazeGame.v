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

	/*****************************************************************************
	 *                 Internal Wires and Registers Declarations                 *
	 *****************************************************************************/

	// Internal Wires
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;

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
	
	wire gameWon, gameLost, gameOver, playHard, playMedium, playEasy, externalReset, error;
	
	handshake FSM(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.ps2_key_pressed(ps2_key_pressed),
		.ps2_key_data(ps2_key_data),
		.valueInMemory(itemType),
		.doneMaze(doneMaze),
		.doneDraw(doneDraw),
		.doneErase(doneErase),
		
		.drawX(xInDraw),
		.drawY(yInDraw),
		.prevX(xInErase),
		.prevY(yInErase),
		
		.changedX(checkX),
		.changedY(checkY),
		.score(scoreGame),
		
		.drawBox(drawBox),
		.eraseBox(eraseBox),
		.drawMaze(drawMaze),
		
		.gameWon(gameWon),
		.gameLost(gameLost),
		.gameOver(gameOver),
		
		.hard(SW[9]),
		.med(SW[8]),
		.easy(SW[7]),
		.playHard(playHard),
		.playMedium(playMedium),
		.playEasy(playEasy),
		.externalReset(externalReset),
		.error(error)
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
