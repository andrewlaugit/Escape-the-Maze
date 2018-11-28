/* this module will output x,y colour information for the VGA
 * adapter to draw 'screens' when game starts, game is won,
 * game is over, or when game is being played. When the entire area
 * has been filled, the done signal will be raised.
 */
 
module outputScreen(
	input 				clk,
	input 				resetn,
	input 				drawWinner,
	input 				drawGameOver,
	input 				drawStart,
	input 				drawClear,
	output reg 	[8:0] xLoc,
	output reg 	[8:0] yLoc,
	output reg 	[2:0] colour,
	output reg 	[0:0] done
	);
	
	// internal wires and registers
	reg 			[7:0] countx, county;	
	reg 			[15:0] address;
	reg 			[0:0] donep1;
	wire 			[2:0]  startClr, gameoverClr, winnerClr;
	
	// convert counters in x location and y location into
	// address used to access colours matching location
	// on RAM modules
	always@(*) begin
		address <= countx + county*(240);
	end	
	
	// contains the image for the "start" background
	startRam player(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(startClr)
	);
	
	// contains the image for the "game over" background
	gameoverRam gg(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(gameoverClr)
	);

	// contains the image for the "win" background
	winnerRam win(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(winnerClr)
	);

	// determine which colour information to use based on which
	// background we are drawing
	always @(*) begin
		if(drawClear) // recolour the maze background to blue
			colour <= 3'b001;
		if(drawStart)
			colour <= startClr;
		if(drawGameOver)
			colour <= gameoverClr;
		if(drawWinner)
			colour <= winnerClr;
		if(~drawClear && ~drawStart && ~drawGameOver && ~drawWinner)
			colour <= 3'b000;
	end
	
	// increment through all spaces in the maze play area
	// area is a square from 80 - 320 on x and 0 - 240 on y
	always @(posedge clk) begin
		if(~resetn) begin
			countx <= 8'b0;
			county <= 8'b0;
			donep1 <= 1'b0;
			done <= 1'b0;
		end
		
		// screen to draw
		if(drawClear || drawStart || drawGameOver || drawWinner) begin
			if(~done) begin
			
				// when end of row reached (x at right side of screen), 
				// move to the next row on the screen
				if (countx == 239) begin
					countx <= 8'b0;
					county <= county + 1;
				end
				else begin //move to next column on row
					if(~done && ~donep1)
						countx <= countx + 1;
				end
				
				// finished counting
				if (county == 239 && countx == 239) begin
					donep1 <= 1;
					county <= 4'b0;
				end
					
				if (donep1) begin
					donep1 <= 0;
					done <= 1;
					xLoc <= 9'd0;
					yLoc <= 9'd0;
				end
				else begin // ~donep1
					done <= 0;
					xLoc <= 9'd80 + countx;
					yLoc <= county;
				end
			end
			else begin // done
				xLoc <= 9'd0;
				yLoc <= 9'd0;
			end
		end
		// no signal to draw screen
		else begin 
			xLoc <= 9'd0;
			yLoc <= 9'd0;
			done <= 0;
		end
	end
endmodule