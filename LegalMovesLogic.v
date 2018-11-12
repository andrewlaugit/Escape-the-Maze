//Illegal moves in a gameboard:
//1. Get past the edge of the gameboard (ie: player hits the maze boundary and tries to continue moving in that direction)
//2. Hit a barrier in the game (ie: barrier which isn't the wall)
//3. Reached time limit (???)

module legalMove(
	input clock,
	input resetn,
	input [1:0] location,
	input doneChangePosition,
	output isLegalMove
	);
	
	parameter xLowerBound = 3'd000, xUpperBound = 3'd159, yLowerBound = 3'd000, yUpperBound = 3'd119;
	
	always @(posedge clock)
	if(!resetn)
		isLegalMove = 0; //at the beginning of the game, any move is legal since you're at the starting position
		
	else if (doneChangePosition) begin
		if(location[1] == xLowerBound | location[1] == xUpperBound | location[0] == yLowerBound | location[0] == yUpperBound) //if you've hit the edge of the gameboard
			isLegalMove = 1;
		
		//also somehow check if the position is on a barrier, but not sure how to input barrier location data (???)
		//else if(you've hit one of the boundaries)
			//isLegalMove = 1;
		
		else
			isLegalMove = 0;
	end
	
	else
		//no change to the value of isLegalMove
		//should you assume isLegalPosition is true (ie: isLegalPosition = 0)?

	assign doneChangePosition = 1;
endmodule
