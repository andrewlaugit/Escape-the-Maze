module legalControl(
	input clock,
	input resetn,
	input externalReset,
	input doneChangePosition,
	input [2:0] valueInMemory,
	input [4:0] x,
	input [4:0] y,
	input [4:0] scorePlusFiveX, scorePlusFiveY, scoreMinusFiveX, scoreMinusFiveY,
	input moveLeft, moveRight, moveUp, moveDown,
	input noMoreMoves, noMoreTime,
	output reg doneCheckLegal,
	output reg isLegal,
	output reg gameWon, 
	output reg gameOver,
	output reg scorePlusFive, scoreMinusFive
	);
	
	//declarations of values in memory
	localparam AVAILABLE   = 4'h1,
				OCCUPIED      = 4'h0,
				START         = 4'h2,
				END           = 4'h3,
				YOUR_POSITION = 4'h4,
				PLUS_FIVE     = 4'h5,
				MINUS_FIVE    = 4'h6;
					
	reg [3:0] currentState, nextState;
	
	//declarations of states
	localparam IDLE                = 4'd0,
				CHECK_MEMORY          = 4'd1,
				NOT_LEGAL             = 4'd2,
				LEGAL                 = 4'd3,
				ADD_FIVE_TO_SCORE     = 4'd4,
				MINUS_FIVE_FROM_SCORE = 4'd5,
				WON                   = 4'd6,
				GAME_OVER             = 4'd7;

	//declaration of top row, bottom row, left column, right column of the maze board
	localparam  TOP    = 5'b00000,
					LEFT   = 5'b00000,
					RIGHT  = 5'b10111,
					BOTTOM = 5'b10111;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentState)
			IDLE: begin
				if(doneChangePosition)
					nextState = CHECK_MEMORY;
				else if(noMoreMoves || noMoreTime)
					nextState = GAME_OVER;
				else
					nextState = IDLE;
				end
			
			CHECK_MEMORY: begin
				if(externalReset)
					nextState = GAME_OVER;
				else if(noMoreMoves || noMoreTime) 
					nextState = GAME_OVER;
					
				else if(x == LEFT && moveLeft)
					nextState = NOT_LEGAL;
				else if(x == RIGHT && moveRight)
					nextState = NOT_LEGAL;
				else if(y == TOP && moveUp)
					nextState = NOT_LEGAL;
				else if(y == BOTTOM && moveDown)
					nextState = NOT_LEGAL;
					
				else if(x == scorePlusFiveX & y == scorePlusFiveY)
					nextState = ADD_FIVE_TO_SCORE;
					
				else if(x == scoreMinusFiveX & y == scoreMinusFiveY)
					nextState = MINUS_FIVE_FROM_SCORE;
					
				else if(valueInMemory == OCCUPIED)
					nextState = NOT_LEGAL;
					
				else
					nextState = LEGAL;
			end
			
			NOT_LEGAL: nextState = IDLE;
			
			LEGAL: begin
				if(valueInMemory == END)
					nextState = WON;
				else
					nextState = IDLE;
			end
			
			ADD_FIVE_TO_SCORE: nextState = IDLE;
			
			MINUS_FIVE_FROM_SCORE: nextState = IDLE;
			
			WON: nextState = resetn ? WON : IDLE;
						
			GAME_OVER : nextState = resetn ? GAME_OVER : IDLE;
			
			default: nextState = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameWon = 1'b0;
		gameOver = 1'b0;
		
		case(currentState)
		
			IDLE: doneCheckLegal <= 1'b0;
			
			CHECK_MEMORY: begin
				doneCheckLegal <= 1'b0;
				scorePlusFive  <= 1'b0;
				scoreMinusFive <= 1'b0;
			end
			
			LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal        <= 1'b1;
			end
			
			NOT_LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal        <= 1'b0;
			end 
			
			ADD_FIVE_TO_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal        <= 1'b1;
				scorePlusFive  <= 1'b1;
			end
			
			MINUS_FIVE_FROM_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal        <= 1'b1;
				scoreMinusFive <= 1'b1;
			end
			
			WON: begin
				doneCheckLegal <= 1'b1;
				isLegal        <= 1'b1;
				gameWon        <= 1'b1;
			end
			
			GAME_OVER: begin
				doneCheckLegal <= 1'b1;
				gameOver       <= 1'b1;
				isLegal        <= 1'b0;
			end
			
			
		endcase
	end
	
	//current state registers
	always @ (posedge clock)
	begin: state_FFs
		if(!resetn || externalReset)
			currentState <= IDLE;
		else
			currentState <= nextState;
	end
	
endmodule