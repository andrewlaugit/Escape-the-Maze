module mazePathOut(
	input clk,
	input resetn,
	
	output reg [7:0] address,
	output reg [7:0] xLoc,
	output reg [7:0] yLoc
	);
	
	parameter xSize = 8, ySize = 6, boxSize = 20;
	reg [3:0] x,y;
	reg [4:0] countx;
	reg [4:0] county;
	reg doneBox, donep1;
	
	//increments access address
	always @(negedge clk) begin
		if (~resetn) begin
			x <= 4'b0;
			y <= 4'b0;
		end
		if (donep1) begin
			if (x == xSize-1) begin
				x <= 4'b0;
				y <= y + 1;
			end
			else
				x <= x + 1;
			if (y == ySize)
				y <= 4'b0;
		end
	end
	always @(posedge clk) begin
		if (~resetn)
			address <= 8'b0;
		if (doneBox)
			address <= x + y*16;
	end
	
	//increments display location
	always @(posedge clk) begin
		if(~resetn) begin
			xLoc <= 8'b0;
			yLoc <= 8'b0;
			countx <= 5'b0;
			county <= 5'b0;
			doneBox <= 0;
			donep1 <= 0;
		end
		else begin
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
				xLoc <= x*boxSize + countx;
				yLoc <= y*boxSize + county;
			end
	end
	
endmodule