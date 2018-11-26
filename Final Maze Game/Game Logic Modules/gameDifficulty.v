module gameDifficulty(
	input clock,
	input resetn,
	input hard,
	input med,
	input easy,
	output reg playHard, playMedium, playEasy, externalReset,
	output reg [4:0] scorePlusFiveX, scorePlusFiveY, scoreMinusFiveX, scoreMinusFiveY
	);
	
	reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'd0,
				HARD = 3'd1,
				MEDIUM = 3'd2,
				EASY = 3'd3,
				GAME_OVER = 3'd4;
	
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
				else 
					nextState = IDLE;
			end
			
			HARD: nextState =  hard ? HARD : GAME_OVER;
			
			MEDIUM: nextState =  med ? MEDIUM : GAME_OVER;
			
			EASY: nextState =  easy ? EASY : GAME_OVER;
			
			GAME_OVER: nextState = !resetn ? IDLE : GAME_OVER;
			
			default : nextState = IDLE;
		endcase
	end
	
	always @ (*)
	begin: send_game_difficulty_info
		playHard = 1'd0;
		playMedium = 1'd0;
		playEasy = 1'd0;
		externalReset = 1'd0;
		
		scorePlusFiveX = 5'd0;
		scorePlusFiveY = 5'd0;
		scoreMinusFiveX = 5'd0;
		scoreMinusFiveY = 5'd0;
		
		case (currentState)
			IDLE: begin
				playHard = 1'd0;
				playMedium = 1'd0;
				playEasy = 1'd0;
				externalReset = 1'd0;
			end
			
			HARD: begin
				playHard = 1'd1;
				
				scorePlusFiveX = 5'd1;
				scorePlusFiveY = 5'd21;
				scoreMinusFiveX = 5'd3;
				scoreMinusFiveY = 5'd5;
			end
			
			MEDIUM: begin
				playMedium = 1'd1;
				
				scorePlusFiveX = 5'd21;
				scorePlusFiveY = 5'd4;
				scoreMinusFiveX = 5'd10;
				scoreMinusFiveY = 5'd6;
			end
			
			EASY: begin
				playEasy = 1'd1;
				
				scorePlusFiveX = 5'd17;
				scorePlusFiveY = 5'd9;
				scoreMinusFiveX = 5'd10;
				scoreMinusFiveY = 5'd9;
			end
			
			GAME_OVER: begin
				externalReset = 1'd1;
				playHard = 1'd0;
				playMedium = 1'd0;
				playEasy = 1'd0;
			end
		
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
