module mazePathOut(
	input clk,
	input resetn,
	
	output reg [7:0] address,
	output reg [7:0] xLoc,
	output reg [7:0] yLoc
	);
	
	parameter xSize = 8, ySize = 6, maxBit=4, boxSize=4;
	reg [maxBit-1:0] x,y;
	reg [1:0] countx;
	reg [1:0] county;
	reg doneBox;
	
	always @(posedge doneBox) begin
			if (~resetn) begin
				address <= 8'b0;
				x <= 4'b0;
				y <= 4'b0;
			end
			else 
				address <= x + y*16 - 1;
			if (x == xSize)
				x <= 4'b0;
			else
				x <= x + 4'd1;
			if (y == ySize) begin
				y <= 4'b0;
			end
			else
				y <= y + 4'd1;
	end
	always @(posedge clk) begin
		if(~resetn) begin
			xLoc <= 8'b0;
			yLoc <= 8'b0;
			//address <= 6'b0;
			//x <= 4'b0;
			//y <= 4'b0;
		end
		else begin
			if (countx == boxSize-1)
				county <= county + 1;
			if (county == boxSize-1)
				doneBox = 1'b1;
			
			xLoc <= x*boxSize + countx;
			yLoc <= y*boxSize + county;
			countx <= countx + 4'b1;		
		end
	end
endmodule