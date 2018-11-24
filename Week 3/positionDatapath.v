module positionDatapath (
	input clock,
	input resetn,
	input received_data_en,
	input [4:0] currentX, currentY,
	input moveLeft, moveRight, moveUp, moveDown,
	input doneLegal, isLegal, gameOver,
	input scorePlusFive, scoreMinusFive,
	output reg [4:0] tempCurrentX, tempCurrentY,
	output reg [4:0] changedX, changedY,
	output reg [4:0] newX, newY,
	output reg [4:0] prevX, prevY,
	output reg [9:0] numberOfMoves
	//output reg donePosition
	);
	
	localparam MOVE_ONE_OVER = 5'b00001; //how big is one square on the board?
	
	reg [0:0] doneOnce;
	reg [0:0] doneOncep1;

	//multiplexer for determining the value of tempCurrent X and Y
	//technically you don't need an always block for this stuff
	always @ (posedge clock) 
	begin: tempCurrent
	
		if(!resetn) begin
		//do I need this here? because...
			tempCurrentX <= currentX;
			tempCurrentY <= currentY;
			prevX <= currentX;
			prevY <= currentY;
			
		end
		
		else begin
			//... this takes care of the case where resetn is 0 (ie: do the resetting) and sets (X,Y) to (0,0)
			//doneOnce <= 0;
			prevX <= tempCurrentX;
			prevY <= tempCurrentY;
			tempCurrentX <= newX;
			tempCurrentY <= newY;
		end
		
	end
	
//	reg storeKeyPressed;
//	reg go;
//	
//	always @ (posedge received_data_en) begin
//		storeKeyPressed <= 0;
//	
//		if(storeKeyPressed == 1'b0 & received_data_en == 1'b1)
//			go <= 1'b1;
//		else
//			go <= 1'b0;
//		storeKeyPressed <= received_data_en;
//		
//	end
//	
	//ALU for determining the value of changedX and changedY
	always @ (posedge received_data_en,  negedge resetn)
	begin: changedPosition

		if(!resetn) begin
			changedX <= 5'd1; //size?
			changedY <= 5'd0; //size?
			numberOfMoves <= 10'd0;
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
				if(gameOver) begin
					changedX <= tempCurrentX;
					changedY <= tempCurrentY;
					numberOfMoves <= numberOfMoves + 10'd0;
				end
				
				else begin
					if(scorePlusFive) begin
					
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd5;
						end
					end
					else if(scoreMinusFive) begin
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves - 10'd5;
						end
					end
					
					else begin
					
						if(moveLeft) begin
							changedX <= tempCurrentX - MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveRight) begin
							changedX <= tempCurrentX + MOVE_ONE_OVER;
							changedY <= changedY;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveUp) begin
							changedY <= tempCurrentY - MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
						
						else if(moveDown) begin
							changedY <= tempCurrentY + MOVE_ONE_OVER;
							changedX <= changedX;
							numberOfMoves <= numberOfMoves + 10'd1;
						end
					end
					
					else begin	
						changedX <= tempCurrentX;
						changedY <= tempCurrentY;
					end
				end
			end
			
		end	
		//donePosition = 1'b1 //raise donePosition flag so legal moves FSM can do its thing
	end
	
	
	
	//multiplexer for determining the value of newPosition
	//technically you don't need an always block for this stuff
	always @ (posedge clock)
	begin: newPosition
		if(!resetn) begin 	
			newX <= 5'd1;
			newY <= 5'd0;
		end
		
		else if(doneLegal & gameOver) begin //no change to newX or newY, should I load them with the current or changed values of X and Y?
			newX <= tempCurrentX;
			newY <= tempCurrentY;
		end
		
		else if(doneLegal & !gameOver) begin
			
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