module movesCounter (
	input clock,
	input resetn,
	input [7:0] numberOfMoves,
	output reg noMoreMoves
	);
	
	localparam MAX_NUMBER_OF_MOVES = 8'd199;
	
	always @ (*)
	begin
		if(!resetn)
			noMoreMoves <= 1'd0;
		else if(numberOfMoves >= MAX_NUMBER_OF_MOVES)
			noMoreMoves <= 1'd1;
		else
			noMoreMoves <= 1'd0;
	end
	
endmodule

