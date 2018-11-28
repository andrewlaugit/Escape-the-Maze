`timescale 1ns/1ns
module week1test(resetn, clock, doneAdd, position, legality, newPosition);
//159 in binary: 10011111 (8 bits)
//119 in binary: 1110111 (7 bits, need to pad the top bit with 0)
//total input is 16 bits wide
//
	input resetn;
	input [15:0] position;
	input clock;
	output doneAdd;
	output legality;
	output [15:0] newPosition;
	
	wire left, right, up, down, legal;
	wire [15:0] changedPosition;
	
	changeLocation MOVE(
		.clock(clock), 
		.resetn(resetn), 
		.currentPosition(position), 
		.moveLeft(left), 
		.moveRight(right), 
		.moveUp(up), 
		.moveDown(down),
		.isLegalMove(legal),
		.move(newPosition),
		.addFlag(doneAdd),
		.changedPosition(changedPosition)
		);
		
	legalMove LEGAL(
		.clock(clock),
		.resetn(resetn),
		.location(changedPosition),
		.doneAdd(doneAdd),
		.isLegalMove(legal)
		);
		
	assign legality = legal;

endmodule

module changeLocation(
	input clock,
	input resetn,
	input [15:0] currentPosition,
	input moveLeft,
	input moveRight,
	input moveUp,
	input moveDown,
	input isLegalMove,
	output reg [15:0] changedPosition,
	output [15:0] move,
	output addFlag
	);
	
	reg [15:0] newPosition;
	reg doneAdd;
	
	always @ (*) begin
		if(!resetn) begin
			doneAdd = 1'b0;
			//changedPosition = 16'b0000000000000000;
		end
		
		else if(moveLeft) begin
			changedPosition[15:8] = currentPosition[15:8] - 1'b1;
			doneAdd = 1'b1;
		end
		
		else if(moveRight) begin
			changedPosition[15:8] = currentPosition[15:8] + 1'b1;
			doneAdd = 1'b1;
		end
		
		else
			changedPosition[15:8] = currentPosition[15:8];
			doneAdd = 1'b1;
		
		if(moveUp) begin
			changedPosition[7:0] = currentPosition[7:0] - 1'b1;
			doneAdd = 1'b1;
		end
		
		else if(moveDown) begin
			changedPosition[7:0] = currentPosition[7:0] + 1'b1;
			doneAdd = 1'b1;
		end
		
		else
			changedPosition[7:0] = currentPosition[7:0];
			doneAdd = 1'b1;
	end
	
	always @ (posedge clock) begin
		if(!resetn)
			newPosition <= 16'b0000000000000000;
		else if(isLegalMove)
			newPosition <= changedPosition;
		else 
			newPosition <= currentPosition;
	end
	
	assign move = newPosition;
	assign addFlag = doneAdd;
	
endmodule

module legalMove(
	input clock,
	input resetn,
	input [15:0] location,
	input doneAdd,
	output reg isLegalMove
	);
	
	parameter xLowerBound = 8'b00000000, xUpperBound = 8'b10011111, yLowerBound = 8'b00000000, yUpperBound = 8'b01110111;
	
	always @ (posedge clock)
	if(!resetn)
		isLegalMove = 1'b0; //at the beginning of the game, any move is legal since you're at the starting position
	else if(doneAdd) begin
		if(location[15:8] == xLowerBound | location[15:8] == xUpperBound | location[7:0] == yLowerBound | location[7:0] == yUpperBound) //if you've hit the edge of the gameboard
			isLegalMove = 1'b0;
		
		//also somehow check if the position is on a barrier, but not sure how to input barrier location data (???)
		//else if(you've hit one of the boundaries)
			//isLegalMove = 1;
		
		else
			isLegalMove = 1'b1;
	end
	
	else
		isLegalMove = 1'b1;

endmodule


