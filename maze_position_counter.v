//completed : Nov 16  10:54

`timescale 1ns / 1ns

module maze_position_counter(
	input clk,
	input resetn,
	output reg [9:0] address,
	output reg [8:0] xLoc,
	output reg [8:0] yLoc
	//output reg [0:0] done
	);
	
	parameter xSize = 24, ySize = 24, boxSize = 9;
	reg [4:0] x,y;
	reg [3:0] countx;
	reg [3:0] county;
	reg doneBox, donep1;
	
	//increments access address
	always @(negedge clk) begin
		if (~resetn) begin
			x <= 5'b0;
			y <= 5'b0;
		end
		//if(~done) begin
			if (doneBox) begin
				if (x == xSize-1 && ~donep1) begin
					x <= 5'b0;
					y <= y + 1;
				end
				else
					x <= x + 1;
				if (y == ySize-1 && x == xSize-1 && ~donep1)
					y <= 5'b0;
			end
		//end
	end
	
	//finished condition
	always @(posedge clk) begin
		if (~resetn)
			address <= 10'b0;
		if (doneBox)
			address <= x + y*32;
	end
	
	//increments display location
	always @(posedge clk) begin
		if(~resetn) begin
			xLoc <= 9'd80;
			yLoc <= 9'b0;
			countx <= 5'b0;
			county <= 5'b0;
			doneBox <= 0;
			donep1 <= 0;
			//done <= 0;
		end
		else begin
			xLoc <= 9'd80;
			yLoc <= 9'b0;
			//if(xLoc == 319 && yLoc == 240)
				//done <= 1;
			
			//if(~done) begin
				if (countx == boxSize-1) begin
					countx <= 5'b0;
					county <= county + 1;
				end
				else begin
					if(~doneBox && ~donep1)
						countx <= countx + 1;
				end
					
				if (county == boxSize-1 && countx == boxSize-1) begin
					donep1 <= 1;
					county <= 5'b0;
				end
					
				if (donep1) begin
					donep1 <= 0;
					doneBox <= 1;
				end
							
				if (~donep1)
					doneBox <= 0;
				end
				
				if(~doneBox) begin
					xLoc <= 9'd80 + x*(boxSize+1) + countx;
					yLoc <= y*(boxSize+1) + county;
				end
			//end
	end
	
endmodule