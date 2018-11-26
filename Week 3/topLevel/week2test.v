@@ -7,8 +7,7 @@ module week2test (
	SW,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	PS2_CLK,	PS2_DAT,
	
	// Outputs
	//pX,pY,nX,nY,
@ -16,13 +15,13 @@ module week2test (
	HEX0,	HEX1,	HEX2,	HEX3,	HEX4,	HEX5,
	LEDR,
	// The ports below are for the VGA output.  Do not change.
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,						//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_CLK,   					//	VGA Clock
	VGA_HS,						//	VGA H_SYNC
	VGA_VS,						//	VGA V_SYNC
	VGA_BLANK_N,				//	VGA BLANK
	VGA_SYNC_N,					//	VGA SYNC
	VGA_R,   					//	VGA Red[9:0]
	VGA_G,	 					//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]

);
@ -30,7 +29,7 @@ module week2test (
	// Inputs
	input				CLOCK_50;
	input		[3:0]	KEY;
	input [9:0] SW;
	input 	[9:0] SW;

	// Bidirectionals
	inout				PS2_CLK;
@ -88,7 +87,8 @@ module week2test (
	


	wire [2:0] itemType;
	wire [2:0] itemType1, itemType2, itemType3;
	reg [2:0] itemType;
	wire [4:0] xInDraw, yInDraw;
	wire [4:0] xInErase, yInErase;
	reg [8:0] x, y;
@ -100,7 +100,7 @@ module week2test (
	wire [4:0] checkX, checkY;
	

	wire [2:0] colourPlayer;
	wire [2:0] playerClr;
	wire [2:0] colourExit;
	wire drawMaze, drawBox, eraseBox;
	wire doneMaze, doneDraw, doneErase;
@ -130,9 +130,6 @@ module week2test (
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	maze_position_counter maze_run_thru(
		.clk(CLOCK_50),
		.enable(drawMaze),
@ -151,13 +148,38 @@ module week2test (
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
	
	mazeRam maze(
	maze3Ram mazeEasy( //easy
		.address(address),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(itemType)
		.q(itemType3)
	);
	
	eraseOldBox erase1(
@ -168,9 +190,11 @@ module week2test (
		.yIn(yInErase),
		.xLoc(xErase),
		.yLoc(yErase),
		.colour(),
		.done(doneErase)
	);
	
	
	eraseOldBox draw1(
		.clk(CLOCK_50),
		.eraseBox(drawBox),
@ -179,9 +203,12 @@ module week2test (
		.yIn(yInDraw),
		.xLoc(xDraw),
		.yLoc(yDraw),
		.colour(playerClr),
		.done(doneDraw)
	);
	
	
	
	always @(*) begin
		if(drawBox) begin
			x <= xDraw;
@ -212,7 +239,7 @@ module week2test (
		if(eraseBox)
			colour <= 3'b101;
		if(drawBox)
			colour <= 3'b001;
			colour <= playerClr;//3'b001;
		if(~drawMaze && ~eraseBox && ~drawBox)
			colour <= 3'b000;
	end
@ -300,72 +327,6 @@ module week2test (
		
endmodule


module eraseOldBox(
	input clk,
	input [0:0] eraseBox,
	input [0:0] resetn,
	input [4:0] xIn,
	input [4:0] yIn,
	output reg [8:0] xLoc,
	output reg [8:0] yLoc,
	output reg [0:0] done
	);
	
	reg [4:0] topLeftx, topLefty;
	reg [3:0] countx, county;
	reg [0:0] donep1;
	
	always@(posedge eraseBox) begin
		topLeftx <= xIn;
		topLefty <= yIn;
	end		
	
	always @(posedge clk) begin
		if(eraseBox) begin
			if(~done) begin
				if (countx == 8) begin
					countx <= 4'b0;
					county <= county + 1;
				end
				else begin
					if(~done && ~donep1)
						countx <= countx + 1;
				end
					
				if (county == 8 && countx == 8) begin
					donep1 <= 1;
					county <= 4'b0;
				end
					
				if (donep1) begin
					donep1 <= 0;
					done <= 1;
					xLoc <= 9'd0;
					yLoc <= 9'd0;
				end
							
				if (~donep1) begin
					done <= 0;
					xLoc <= 9'd80 + topLeftx*(10) + countx;
					yLoc <= topLefty*(10) + county;
				end
			end
			
			if(done) begin
				xLoc <= 9'd0;
				yLoc <= 9'd0;
			end
		end
		
		else begin
			xLoc <= 9'd0;
			yLoc <= 9'd0;
			done <= 0;
		end
	end
endmodule

//top level module
module handshake(
	clock,resetn,
@ -639,7 +600,7 @@ module positionDatapath (
	localparam MOVE_ONE_OVER = 5'b00001; //how big is one square on the board?
	
	reg [0:0] doneOnce;
	reg [0:0] doneOncep1;
	reg [0:0] doneTwice;

	//multiplexer for determining the value of tempCurrent X and Y
	//technically you don't need an always block for this stuff
@ -666,20 +627,6 @@ module positionDatapath (
		
	end
	
//	reg storeKeyPressed;
//	reg go;
//	
//	always @ (posedge received_data_en) begin
//		storeKeyPressed <= 0;
//	
//		if(storeKeyPressed == 1'b0 & received_data_en == 1'b1)
//			go <= 1'b1;
//		else
//			go <= 1'b0;
//		storeKeyPressed <= received_data_en;
//		
//	end
//	
	//ALU for determining the value of changedX and changedY
	always @ (posedge received_data_en,  negedge resetn)
	begin: changedPosition
@ -689,14 +636,14 @@ module positionDatapath (
			changedY <= 5'd0; //size?
			numberOfMoves <= 10'd0;
			doneOnce <= 0; 
			doneOncep1 <= 0;
			doneTwice <= 0;
		end
		
		else begin
			if(doneOncep1)
			if(doneTwice)
				doneOnce <= 0;
			if(doneOnce)
				doneOncep1 <= 1;
				doneTwice <= 1;
			if(~doneOnce) begin
				doneOnce <= 1'b1;
				if(moveLeft) begin