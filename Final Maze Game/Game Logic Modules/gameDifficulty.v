module gameDifficulty(
	input hard,
	input med,
	input easy,
	input clock,
	input resetn,
	output reg playHard, playMedium, playEasy, externalReset, error
	);
	
	reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'd0,
				HARD = 3'd1,
				MEDIUM = 3'd2,
				EASY = 3'd3,
				GAME_OVER = 3'd4;
				//IDLE = 3'd5;
	
	always @ (*)
	begin: state_table
		case(currentState)
			IDLE: begin	
				if(hard == 1 & med == 0 & easy == 0) 
					nextState = HARD;
				else if(hard == 0 & med == 1 & easy == 0) 
					nextState = MEDIUM;
				else if(hard == 0 & med == 0 & easy == 1) 
					nextState = EASY;
				else if(!hard & !med & !easy) 
					nextState = GAME_OVER;
				//else if(hard & med & !easy | hard & !med & easy | !hard & med & easy)
				//	nextState = ERROR;
				else 
					nextState = IDLE;
			end
			
			HARD: nextState =  hard ? HARD : GAME_OVER;
			
			MEDIUM: nextState =  med ? MEDIUM : GAME_OVER;
			
			EASY: nextState =  easy ? EASY : GAME_OVER;
			
			GAME_OVER: nextState = IDLE;
			
		//	ERROR: nextState = IDLE;
			
			default : nextState = IDLE;
		endcase
	end
	
	always @ (*)
	begin: send_game_difficulty_info
		playHard = 1'd0;
		playMedium = 1'd0;
		playEasy = 1'd0;
		externalReset = 1'd0;
		error = 1'b0;
		
		case (currentState)
			IDLE: begin
				playHard = 1'd0;
				playMedium = 1'd0;
				playEasy = 1'd0;
				externalReset = 1'd0;
			end
			
			HARD: playHard = 1'd1;
			
			MEDIUM: playMedium = 1'd1;
			
			EASY: playEasy = 1'd1;
			
			GAME_OVER: begin
				externalReset = 1'd1;
				playHard = 1'd0;
				playMedium = 1'd0;
				playEasy = 1'd0;
			end
			
			//ERROR: error = 1'b1;
			
		endcase
	end
	
	always @ (posedge clock) 
	begin
		if(!resetn)
			currentState <= IDLE;
		else
			currentState <= nextState;
	end
	
endmodule
