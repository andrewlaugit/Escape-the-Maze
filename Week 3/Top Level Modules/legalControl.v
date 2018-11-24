module legalControl(
	input clock,
	input resetn,
	input doneChangePosition,
	input [2:0] valueInMemory,
	//input [9:0] memory, 
	input [4:0] x,
	input [4:0] y,
	input moveLeft, moveRight, moveUp, moveDown,
	output reg doneCheckLegal,
	output reg isLegal,
	output reg gameOver,
	output reg scorePlusFive, scoreMinusFive,
	output reg [2:0] currentStateL, nextStateL
	);
	
	localparam AVAILABLE = 4'h1,
				OCCUPIED = 4'h0,
				START = 4'h2,
				END = 4'h3,
				YOUR_POSITION = 4'h4;
				PLUS_FIVE = 4'h5;
				MINUS_FIVE = 4'h6;
				
	localparam WIDTH = 5'b10000; 
	
	//wire [2:0] valueInMemory;
	//assign valueInMemory = memory[WIDTH * y + x];
	
	//reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'b000,
				CHECK_MEMORY = 3'b001,
				NOT_LEGAL = 3'b010,
				LEGAL = 3'b011,
				ADD_FIVE_TO_SCORE = 3'b100;
				MINUS_FIVE_FROM_SCORE = 3'b101;
				WON = 3'b110;
				
	localparam  TOP = 5'b00000,
					LEFT = 5'b00000,
					RIGHT = 5'b10111,
					BOTTOM = 5'b10111;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentStateL)
			IDLE: nextStateL = doneChangePosition ? CHECK_MEMORY : IDLE;
			
			CHECK_MEMORY: begin
				if(x == LEFT && moveLeft)
					nextStateL = NOT_LEGAL;
				else if(x == RIGHT && moveRight)
					nextStateL = NOT_LEGAL;
				else if(y == TOP && moveUp)
					nextStateL = NOT_LEGAL;
				else if(y == BOTTOM && moveDown)
					nextStateL = NOT_LEGAL;
				else if(valueInMemory == OCCUPIED)
					nextStateL = NOT_LEGAL;
				else if(valueInMemory == PLUS_FIVE)
					nextStateL = ADD_FIVE_TO_SCORE;
				else if(valueInMemory == MINUS_FIVE)
					nextStateL = MINUS_FIVE_FROM_SCORE;
				else
					nextStateL = LEGAL;
			end
			
			NOT_LEGAL: nextStateL = IDLE;
			
			LEGAL: nextStateL = (valueInMemory == END) ? WON : IDLE;
			
			ADD_FIVE_TO_SCORE: nextStateL = IDLE;
			
			MINUS_FIVE_FROM_SCORE: nextStateL = IDLE;
			
			WON: nextStateL = resetn ? WON : IDLE; //if not reset, remain in won state; if reset, start again from the top
			
			default: nextStateL = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		scorePlusFive = 1'b0;
		scoreMinusFive = 1'b0;
		
		case(currentStateL)
		
			IDLE: doneCheckLegal <= 1'b0;
			
			CHECK_MEMORY: doneCheckLegal <= 1'b0;
			
			LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
			end
			
			NOT_LEGAL: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b0;
			end
			
			ADD_FIVE_TO_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
				scorePlusFive <= 1'b1;
			end
			
			MINUS_FIVE_FROM_SCORE: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
				scoreMinusFive <= 1'b1;
			end
			
			WON: begin
				doneCheckLegal <= 1'b1;
				isLegal <= 1'b1;
				gameOver <= 1'b1;
			end
			
		endcase
	end
	
	//current state registers
	always @ (posedge clock)
	begin: state_FFs
		if(!resetn)
			currentStateL <= IDLE;
		else
			currentStateL <= nextStateL;
	end
	
endmodule