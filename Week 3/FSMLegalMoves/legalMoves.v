`timescale 1ns/1ns

module legalMoves(
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
	output reg gameOver
	);
	
	localparam AVAILABLE = 4'h1,
				OCCUPIED = 4'h0,
				START = 4'h2,
				END = 4'h3,
				YOUR_POSITION = 4'h4;
				
	localparam WIDTH = 5'b10000; 
	
	//wire [2:0] valueInMemory;
	//assign valueInMemory = memory[WIDTH * y + x];
	
	reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'b000,
				CHECK_MEMORY = 3'b001,
				NOT_LEGAL = 3'b010,
				LEGAL = 3'b011,
				WON = 3'b100;
				
	localparam  TOP = 5'b00000,
					LEFT = 5'b00000,
					RIGHT = 5'b10111,
					BOTTOM = 5'b10111;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentState)
			IDLE: nextState = doneChangePosition ? CHECK_MEMORY : IDLE;
			
			CHECK_MEMORY: begin
				if(x == LEFT && moveLeft)
					nextState = NOT_LEGAL;
				else if(x == RIGHT && moveRight)
					nextState = NOT_LEGAL;
				else if(y == TOP && moveUp)
					nextState = NOT_LEGAL;
				else if(y == BOTTOM && moveDown)
					nextState = NOT_LEGAL;
				else if(valueInMemory == OCCUPIED)
					nextState = NOT_LEGAL;
				else
					nextState = LEGAL;
			end
			
			LEGAL: nextState = (valueInMemory == END) ? WON : IDLE;
			
			WON: nextState = resetn ? IDLE : WON; //if not reset, remain in won state; if reset, start again from the top
			
			NOT_LEGAL: nextState = IDLE;
			
			default: nextState = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		
		case(currentState)
		
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
			currentState <= IDLE;
		else
			currentState <= nextState;
	end
	
endmodule

/*
//legal moves FSM

//need to read from RAM/memory
//what is the dimensions of memory/the gameboard?

//do you need a datapath for this FSM? since you're not manipulating any inputs/outputs

//size of memory is 32x32 (ie: 320 x 320) array
//only use 24x24 (first 24 elements)

module legalControl(
	input clock,
	input resetn,
	input doneChangePosition,
	//input [2:0] valueInMemory,
	input [9:0] memory, 
	input [4:0] x,
	input [4:0] y,
	input moveLeft, moveRight, moveUp, moveDown,
	output reg doneCheckLegal,
	output reg isLegal,
	output reg gameOver
	);
	
	localparam AVAILABLE = 4'h1,
				OCCUPIED = 4'h0,
				START = 4'h2,
				END = 4'h3,
				YOUR_POSITION = 4'h4;
				
	localparam WIDTH = 5'b10000; 
	
	wire [2:0] valueInMemory;
	assign valueInMemory = memory[WIDTH * y + x];
	
	reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'b000,
				CHECK_MEMORY = 3'b001,
				NOT_LEGAL = 3'b010,
				LEGAL = 3'b011,
				WON = 3'b100;
				
	localparam  TOP = 5'b00000,
					LEFT = 5'b00000,
					RIGHT = 5'b10111,
					BOTTOM = 5'b10111;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentState)
			IDLE: nextState = doneChangePosition ? CHECK_MEMORY : IDLE;
			
			CHECK_MEMORY: begin
				if(x == LEFT && moveLeft)
					nextState = NOT_LEGAL;
				else if(x == RIGHT && moveRight)
					nextState = NOT_LEGAL;
				else if(y == TOP && moveUp)
					nextState = NOT_LEGAL;
				else if(y == BOTTOM && moveDown)
					nextState = NOT_LEGAL;
				else if(valueInMemory == OCCUPIED)
					nextState = NOT_LEGAL;
				else
					nextState = LEGAL;
			end
			
			LEGAL: nextState = (valueInMemory == END) ? WON : IDLE;
			
			WON: nextState = resetn ? IDLE : WON; //if not reset, remain in won state; if reset, start again from the top
			
			NOT_LEGAL: nextState = IDLE;
			
			default: nextState = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		
		case(currentState)
		
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
			currentState <= IDLE;
		else
			currentState <= nextState;
	end
	
endmodule
*/