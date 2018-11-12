//module to increment/decrement player's x/y position

module changeLocation(
	input clock,
	input resetn,
	input {1:0] currentPosition,
	input moveLeft,
	input moveRight,
	input moveUp,
	input moveDown,
	input isLegalMove,
	output [1:0] move,
	output doneAdd
	);
	
	wire [1:0] newPosition, changedPosition;
	
	always @ (*) begin
		if(moveLeft) begin
			changedPosition[1] = currentPosition[1] - 1;
			doneAdd = 1;
		end
		
		else if(moveRight) begin
			changedPosition[1] = currentPosition[1] + 1;
			doneAdd = 1;
		end
		
		else
			changedPosition[1] = currentPosition[1];
		
		if(moveUp) begin
			changedPosition[0] = currentPosition[0] - 1;
			doneAdd = 1;
		end
		
		else if(moveDown) begin
			changedPosition[0] = currentPosition[0] + 1;
			doneAdd = 1;
		end
		
		else
			changedPosition[0] = currentPosition[0];
	end
	
	always @ (posedge clock) begin
		if(!resetn)
			newPosition <= 2'b0;
		else if(isLegalMove)
			newPosition <= changedPosition;
		else 
			newPosition <= currentPosition;
	end
	
	assign move = newPosition;
	
endmodule
			
	
