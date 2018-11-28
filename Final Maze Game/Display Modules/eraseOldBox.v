/* eraseOldBox is used to send x/y coordinates and colour to the vga in
 * order to show the movement of the player within the maze. For each move,
 * eraseOldBox is called twice, once to overwrite the colours in the old 
 * position to yellow (maze path colour), and once draw the mario character
 * in the new position. This module will draw 9x9 boxes and will output the
 * colours needed to create an image of mario head, with data stored in 'user1Ram'.
 * When the 9x9 box is has been completed, 'done' is set to high.
 */

module eraseOldBox(
	input 				clk,
	input 		 		resetn,
	input 				eraseBox,
	input 		[4:0] xIn,
	input 		[4:0] yIn,
	output reg 	[8:0] xLoc,
	output reg	[8:0] yLoc,
	output reg 	[2:0] colour,
	output reg 	[0:0] done
	);
	
	// internal wires and registers
	reg 			[4:0] topLeftx, topLefty;
	reg 			[3:0] countx, county;
	reg 			[6:0] address;
	reg 			[0:0] donep1;
	wire 			[2:0]  clrRam;

	// contains the mario image used to show current position
	user1Ram player(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(clrRam)
	);	
	
	// determine which colour and calculate the address to use
	always@(*) begin
		if(~resetn) begin
			colour <= 3'b0;
			address <= 7'b0;
		end
		else begin
			colour <= clrRam;
			address <= countx + county*(9);
		end
	end
	
	// store the top left coordinate of the current position
	// when the eraseBox signal is high
	always@(posedge eraseBox) begin
		if(~resetn) begin
			topLeftx <= 5'b0;
			topLefty <= 5'b0;
		end
		else begin
			topLeftx <= xIn;
			topLefty <= yIn;
		end
	end

	// increment the x and y coordinates across all
	// pixels in the 9x9 box that where mario will go/was
	always @(posedge clk) begin
		if(~resetn) begin
			countx <= 4'b0;
			county <= 4'b0;
			donep1 <= 1'b0;
			done <= 1'b0;
		end
		
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
				else begin // (~donep1) 
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
			countx <= 4'b0;
			county <= 4'b0;
			donep1 <= 1'b0;
			done <= 1'b0;
		end
	end
endmodule