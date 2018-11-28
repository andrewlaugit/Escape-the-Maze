/* outputSpecialBox is used to send x,y coordinates and colour to the vga
 * in order to create the +5 and -5 boxes in the maze. This module will use
 * the input xPlus and yPlus to create a 9x9 pixel [+] box on the maze. Next,
 * it will use xMinus and yMinus to create a 9x9 pixel [-] box in the maze.
 * After both of those are done, 'done' is set to high'
 */

module outputSpecialBox(
	input				clk,
	input 				drawSpecial,
	input 				resetn,
	input 		[4:0] xPlus,
	input 		[4:0] yPlus,
	input 		[4:0] xMinus,
	input 		[4:0] yMinus,
	output reg 	[8:0] xLoc,
	output reg 	[8:0] yLoc,
	output reg 	[2:0] colour,
	output reg 	[0:0] done
	);
	
	// internal registers
	reg 			[3:0] countx, county;
	reg			[0:0] donep1, donePlus;
	reg 			[4:0] xP,yP,xM,yM;
	
	// set internal registers to input values when drawSpecial goes high
	always@(posedge drawSpecial) begin
		if(~resetn) begin
			xP <= 5'd0;
			yP <= 5'd0;
			xM <= 5'd0;
			yM <= 5'd0;
		end
		else begin
			xP <= xPlus;
			yP <= yPlus;
			xM <= xMinus;
			yM <= yMinus;
		end
	end

	// determines which colour to use based on +/- and row/col
	always@(*) begin
		if(~resetn) 
			colour <= 3'b0;
		else begin
			if(county == 3 || county == 4 || county == 5) begin
				if(countx == 1 || countx == 0)
					colour <= 3'b111; //white
				else begin
					if(~donePlus)
						colour <= 3'b100; //red
					else
						colour <= 3'b010; //green
				end
			end
			else begin
				if(~donePlus && (countx == 4 || countx == 5 || countx == 6))
					colour <= 3'b100; //red
				else
					colour <= 3'b111; //white
			end
		end
	end
	
	// increment x/y location for use in VGA controller
	always @(posedge clk) begin
		if(~resetn) begin
			countx 	<= 4'b0;
			county 	<= 4'b0;
			xLoc 		<= 9'b0;
			yLoc 		<=	9'b0;
			donep1 	<=	1'b0;
			donePlus <= 1'b0;
			done 		<= 1'b0;
		end
		
		if(drawSpecial) begin
			if(~done) begin
				if (countx == 8) begin
					countx <= 4'd0;
					county <= county + 4'd1;
				end
				else begin
					if(~done && ~donep1)
						countx <= countx + 4'd1;
				end
					
				if (county == 8 && countx == 4'd8) begin
					donep1 <= 1'd1;
					county <= 4'd0;
				end
					
				if (donep1) begin
					donep1 <= 1'd0;
					
					if(donePlus) begin
						done <= 1'd1;
						xLoc <= 9'd0;
						yLoc <= 9'd0;
					end
					else begin
						donePlus <= 1'd1;
					end
				end
							
				if (~donep1) begin
					done <= 1'd0;
					if(donePlus) begin
						xLoc <= 9'd80 + xM*(10) + countx;
						yLoc <= yM*(10) + county;
					end
					else begin
						xLoc <= 9'd80 + xP*(10) + countx;
						yLoc <= yP*(10) + county;
					end
				end
			end
			
			if(done) begin
				xLoc <= 9'd0;
				yLoc <= 9'd0;
			end
		end
		
		else begin
			countx 	<= 4'd0;
			county 	<= 4'd0;
			xLoc 		<= 9'd0;
			yLoc 		<= 9'd0;
			donePlus <= 1'd0;
			donep1 	<= 1'd0;
			done 		<= 1'd0;
		end
	end
endmodule