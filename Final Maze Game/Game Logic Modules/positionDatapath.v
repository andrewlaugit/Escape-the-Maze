module positionDatapath (
	input clock,
	input resetn,
	input externalReset,
	input received_data_en,
	input [4:0] currentX, currentY,
	input moveLeft, moveRight, moveUp, moveDown,
	input doneLegal, isLegal, 
	input gameWon, gameOver,
	input scorePlusFive, scoreMinusFive,
	output reg [4:0] tempCurrentX, tempCurrentY,
	output reg [4:0] changedX, changedY,
	output reg [4:0] newX, newY,
	output reg [4:0] prevX, prevY,
	output reg [7:0] numberOfMoves
	);
	
	localparam MOVE_ONE_OVER = 5'b00001;
	
	reg [0:0] doneOnce;
	reg [0:0] doneOncep1;

	always @ (posedge clock) 
	begin: tempCurrent
	
		if(!resetn || externalReset) begin
			tempCurrentX <= currentX;
			tempCurrentY <= currentY;
			prevX <= currentX;
			prevY <= currentY;
			
		end
		
		else begin
			prevX <= tempCurrentX;
			prevY <= tempCurrentY;
			tempCurrentX <= newX;
			tempCurrentY <= newY;
		end
		
	end
	
	//ALU for determining the value of changedX and changedY
	always @ (posedge received_data_en, negedge resetn, posedge externalReset)
	begin: changedPosition

		if(!resetn || externalReset) begin
			changedX <= 5'd1;
			changedY <= 5'd0;
			numberOfMoves <= 8'd0;
			doneOnce <= 0; 
			doneOncep1 <= 0;
		end
		
		else begin
			if(doneOncep1)
				doneOnce <= 0;
			if(doneOnce)
				doneOncep1 <= 1;
			if(~doneOnce) begin
				doneOnce <= 1'b1;
				
				if(gameWon | gameOver) begin
					changedX <= tempCurrentX;
					changedY <= tempCurrentY;
					numberOfMoves <= numberOfMoves + 8'd0;
				end
				
				else begin
					if(scorePlusFive) begin
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 8'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 8'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 8'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 8'd5;
						end
					end
					
					else if(scoreMinusFive) begin
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 8'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 8'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 8'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 8'd5;
						end
					end
					
					else begin
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 8'd1;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 8'd1;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 8'd1;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 8'd1;
						end
					
						else begin	
							changedX <= tempCurrentX;
							changedY <= tempCurrentY;
						end
					end
				end
			end
		end	
	end
	
	//determining the value of newPosition
	always @ (posedge clock)
	begin: newPosition
		if(!resetn || externalReset) begin 	
			newX <= 5'd1;
			newY <= 5'd0;
		end
		
		if(gameOver) begin
			newX <= tempCurrentX;
			newY <= tempCurrentY;
		end
		
		else if(doneLegal & (gameWon | gameOver)) begin
			newX <= tempCurrentX;
			newY <= tempCurrentY;
		end
		
		else if(doneLegal & !(gameWon | gameOver)) begin
			
			if(isLegal) begin
				newX <= changedX;
				newY <= changedY;
			end
			
			else if(!isLegal) begin
				newX <= tempCurrentX;
				newY <= tempCurrentY;
			end
		end
		 
	end
	
endmodule
