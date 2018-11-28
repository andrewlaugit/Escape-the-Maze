//completed Nov 16, 20:30

`timescale 1ns / 1ns

// inputs
// x - 5 bits for x position
// y - 5 bits for y position 
//	clk - 50 MHz onboard clock
//  
// outputs
// positionVal - 3 bits to represent position
// ^^ 0 = border, 1 = open space, 2 = start, 3 = end

module read_txt_to_ram(x,y,clk, positionVal);//(x,y,val);
	input [4:0] x,y;
	input clk;
	output reg [2:0] positionVal;
	
	parameter ROW = 32, COL = 32;
	
	reg [ROW*4-1:0] mazeInfo [0:COL-1];
	reg [ROW*4-1:0] positionValRow;
	
	reg [6:0] val2;
	reg [6:0] val1;
	reg [6:0] val0;
	
	initial $readmemh("maze24x24_v1.txt", mazeInfo);
	
	always@(posedge clk) begin
		positionValRow <= mazeInfo [y];

		//32x4 bit needed per row = 128 = 2^7
		val2 <= (ROW-x)*4 - 2; 
		val1 <= (ROW-x)*4 - 3;
		val0 <= (ROW-x)*4 - 4;

		positionVal[2] <=  positionValRow[val2];
		positionVal[1] <=  positionValRow[val1];
		positionVal[0] <=  positionValRow[val0];
	end
endmodule