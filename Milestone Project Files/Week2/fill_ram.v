//completed :

`timescale 1ns / 1ns

module fill_ram(
	input clk,
	input resetn,
	output reg [0:0] fromTxt,
	output reg [9:0] address,
	output [2:0] colour,
	output reg [0:0] done
	);
	
	reg [4:0] x;
	reg [4:0] y;
	reg [0:0] donep1;
	
	read_txt_to_ram txtToRam(
		.x(x),
		.y(y),
		.clk(clk),
		.positionVal(colour)
	);

	
	
	//increments access address
	always @(negedge clk) begin
		if (~resetn) begin
			x <= 5'b0;
			y <= 5'b0;
		end
		if (~donep1) begin
			if (x == 31 && ~donep1) begin
				x <= 5'b0;
				y <= y + 1;
			end
			else
				x <= x + 1;
			if (y == 31 && ~donep1)
				y <= 5'b0;
		end
	end
	
	//donep1
	always @(posedge clk) begin
		if (~resetn)
			donep1 <= 1'b0;
		if (address == 10'b1111111111)
			donep1 <= 1'b1;
	end
	
	
	//finished condition
	always @(posedge clk) begin
		if (~resetn)
			address <= 10'b0;
		if (address == 10'b0 && donep1)
			done <= 1'b1;
	end	
endmodule
	
	