`timescale 1ns / 1ns

module display
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,
		LEDR,
		// The ports below are for the VGA output.  Do not change.
		/*VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		*/

	);

	input			CLOCK_50;				//	50 MHz
	input [0:0] KEY;
	// Do not change the following outputs
	/*
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	*/

	output   [9:0] LEDR;
	
	wire resetn, enable;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	reg [2:0] colour;
	reg [0:0] player1work;
	reg [0:0] exitwork;
	reg [6:0] addressforspecial;


	wire [2:0] itemType;
	wire [8:0] x;
	wire [8:0] y;
	wire [9:0] address;
	
	wire [2:0] colourPlayer;
	wire [2:0] colourExit;
	
	
	
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	/*
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(1'b1),
		/* Signals for the DAC to drive the monitor. */
		/*.VGA_R(VGA_R),
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
	*/
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	maze_position_counter maze_run_thru(
		.clk(CLOCK_50),
		.resetn(resetn),
		.address(address),
		.xLoc(x),
		.yLoc(y)
	);
	
	mazeRam maze(
		.address(address),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(itemType)
	);
	
   user1Ram player1(
		.address(addressforspecial),
		.clock(CLOCK_50),
		.data(3'b111),
		.wren(1'b0),
		.q(colourPlayer)
	);
		
	exitTileRam exit(
		.address(addressforspecial),
		.clock(CLOCK_50),
		.data(3'b0),
		.wren(1'b0),
		.q(colourExit)
	);
	
	always @(*) begin
	
		addressforspecial <= x%10 + (y%10)*9;
		
		if(itemType == 3'b1)
			colour <= 3'b101;
		if(itemType == 3'b0)
			colour <= 3'b110;
			
		if(itemType == 3'd2)
			player1work <= 1;		
		else
			player1work <= 0;
			
		if(itemType == 3'd3)
			exitwork <= 1;
		else
			exitwork <= 0;
		
		if(player1work) begin
			if(addressforspecial== 7'd1)
				colour <= 3'b111;
			else
				colour <= colourPlayer;
		end
		if(exitwork) begin
			if(addressforspecial== 7'd1)
				colour <= 3'b100;
			else
				colour <= colourExit;
		end		
	end
	

endmodule

