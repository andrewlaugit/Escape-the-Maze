`timescale 1ns/1ns

//MASSIVE NOTE: Change [4:0]/5'b/whatever else is 5 bits wide to 6 bits wide so that it can actually account for 32, and not 31
//(or maybe not idk i think it works regardless because you'll never get to [32:32] since the index starts at 0 and goes up to 31)

//how to input ram/memory?
//something to do with "open textfile blah blah blah"

//*************************************************************************************************************************************************
//top level module
module week2test(
	CLOCK_50,
	KEY,
	SW,
	PS2_CLK,
	PS2_DAT,
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
	LEDR
);

	// Inputs
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;

	// Bidirectionals
	inout PS2_CLK;
	inout PS2_DAT;

	//output
	//output [7:0] received_data
	output HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output LEDR;

	// Internal Wires
	wire [7:0] ps2_key_data;
	wire ps2_key_pressed;

	// Internal Registers
	reg [7:0] last_data_received;

	// State Machine Registers

	always @(posedge CLOCK_50)
	begin
		if (KEY[0] == 1'b0)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end

	//internal modules
	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50(CLOCK_50),
		.reset(KEY[0]),

		// Bidirectionals
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),

		// Outputs
		.received_data(ps2_key_data),
		.received_data_en(ps2_key_pressed)
	);
	
	wire doneCheckLegal, isLegal;
	wire moveUp, moveDown, moveLeft, moveRight;
	wire doneChangePosition;
	
	positionControl POSCTRL(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.received_data_en(ps2_key_pressed),
		.received_data(ps2_key_data),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneChangePosition(doneChangePosition)
	);
	
	//will this cause currentX and currentY to always be reset to 0,0 every time the top level module is instantiated?
	//if so, how can I input 0,0 only once at the beginning of the game?
	wire [4:0] currentX, currentY;
	assign currentX = 5'b00000;
	assign currentY = 5'b00000;
	
	wire [4:0] changedX, changedY;
	wire [4:0] newX, newY;
	
	positionDatapath POSDATA( 
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.currentX(currentX),
		.currentY(currentY),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(gameOver),
		.changedX(changedX),
		.changedY(changedY),
		.newX(newX),
		.newY(newY)
	);
	
	wire gameOver;
	wire [9:0] RAM;
	
	//$readmemh("memory.txt", RAM); syntax for reading from memory?
	
	wire [1:0] delay2clock;
	wire go;
	
	delay2ClockCycles DELAY(.clock(CLOCK_50), .resetn(KEY[0]), .out(delay2clock));
	assign go = (delay2clock == 0) ? 1 : 0;
	
	legalControl LEGALCTRL(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.doneChangePosition(doneChangePosition),
		.memory(RAM),
		.x(changedX),
		.y(changedY),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(gameOver)
	);
	
	//still have to instantiate rate divider and 2 clock cycle delay stuff
endmodule

//************************************************************************************************************************************************
//change position FSM
//http://www.ee.ic.ac.uk/pcheung/teaching/ee2_digital/Lecture%207%20-%20FSM%20part%202.pdf info about FSMs

module positionControl(
	input clock,
	input resetn,
	input received_data_en,
	input [7:0] received_data,
	input doneCheckLegal,
	input isLegal,
	output reg moveUp,
	output reg moveDown,
	output reg moveLeft,
	output reg moveRight,
	output reg doneChangePosition
	);
	
	reg [3:0]  currentState, nextState;
	
	localparam  IDLE = 5'b00000,
				LOAD_DIRECTION = 5'b00001,
				CHANGE_POSITION = 5'b00010,
				MODIFICATIONS = 5'b00011,
				CHANGE_CURRENT = 5'b00100,
				DONT_CHANGE_CURRENT = 5'b00101;
				
	//next state logic
	//Question: what do I do exactly with the next state info?
	//should i send out the changePosition done flag only?
	//do I need to enable the registers to read/write data?
	always @ (*)
	begin: state_table
		case(currentState)
			IDLE: nextState = received_data_en ? LOAD_DIRECTION : IDLE;
			
			LOAD_DIRECTION: nextState = CHANGE_POSITION;
			
			CHANGE_POSITION: nextState = doneCheckLegal ? MODIFICATIONS : CHANGE_POSITION;
			
			MODIFICATIONS: nextState = isLegal ? CHANGE_CURRENT : DONT_CHANGE_CURRENT;
			
			CHANGE_CURRENT: nextState = IDLE;
			
			DONT_CHANGE_CURRENT: nextState = IDLE;
			
			default: nextState = IDLE;
		endcase
	end
	
	//raising the doneChangePosition flag
	//if you needed enable signals for the registers, this is where you would add them
	//just change the states to have begin/end
	always @ (*)
	begin: isDoneChangingPosition
		doneChangePosition = 1'b0;
		case(currentState)
			IDLE: doneChangePosition = 1'b0;
			
			LOAD_DIRECTION: doneChangePosition = 1'b0;
			
			CHANGE_POSITION: doneChangePosition = 1'b0;
			
			MODIFICATIONS: doneChangePosition = 1'b0;
			
			//where should i raise the flag that the position has changed?
			CHANGE_CURRENT: doneChangePosition = 1'b1;
			
			DONT_CHANGE_CURRENT: doneChangePosition = 1'b1;
			
			default: doneChangePosition = 1'b0; //technically don't need default
		endcase
	end
	
	localparam  W = 8'h1d; //move up
	localparam	A = 8'h1c; //move left
	localparam	S = 8'h1b; //move down
	localparam	D = 8'h23; //move right
				
	//determine if key pressed corresponds to moving up/down/left/right
	always @ (*)
	begin: directionOfMovement
	
		moveUp = 1'b0;
		moveDown = 1'b0;
		moveRight = 1'b0;
		moveLeft = 1'b0;
		
		case(received_data)
			A: moveLeft = 1'b1;
			
			D: moveRight = 1'b1;
			
			W: moveUp = 1'b1;
			
			S: moveDown = 1'b1;
			//don't need default since variables are already initialized at the top of the case statement
			default: begin
				moveUp = 1'b0;
				moveDown = 1'b0;
				moveRight = 1'b0;
				moveLeft = 1'b0;
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

//24 x 24 board size
//each box is 10 bits wide

//Questions: Do I need load signals on the registers for tempCurrent, changedPosition, and newPosition?
module positionDatapath (
	input clock,
	input resetn,
	input [4:0] currentX, currentY,
	input moveLeft, moveRight, moveUp, moveDown,
	input doneLegal, isLegal, gameOver,
	output reg [4:0] changedX, changedY,
	output reg [4:0] newX, newY
	//output reg donePosition
	);
	
	//do I need these 2?
	//localparam STARTING_X_POSITION = 5'b00000 //size? initialize it to 0
	//localparam STARTING_Y_POSITION = 5'b00000 //size? initialize it to 0
	
	localparam MOVE_ONE_OVER = 5'b00001; //how big is one square on the board?
	
	reg [4:0] tempCurrentX, tempCurrentY; //size?

	//multiplexer for determining the value of tempCurrent X and Y
	//technically you don't need an always block for this stuff
	always @ (posedge clock) 
	begin: tempCurrent
	
		if(!resetn) begin
		//do I need this here? because...
			tempCurrentX <= currentX;
			tempCurrentY <= currentY;
		end
		
		else begin
			//... this takes care of the case where resetn is 0 (ie: do the resetting) and sets (X,Y) to (0,0)
			tempCurrentX <= (~resetn & currentX) | (resetn & newX);
			tempCurrentY <= (~resetn & currentY) | (resetn & newY);
		end
		
	end
	
	//ALU for determining the value of changedX and changedY
	always @ (posedge clock)
	begin: changedPosition

		if(!resetn) begin
			changedX <= 5'b00000; //size?
			changedY <= 5'b00000; //size?
		end
		
		else if(moveLeft) begin
			changedX <= tempCurrentX - MOVE_ONE_OVER;
			changedY <= tempCurrentY;
		end
		
		else if(moveRight) begin
			changedX <= tempCurrentX + MOVE_ONE_OVER;
			changedY <= tempCurrentY;
		end
		
		else if(moveUp) begin
			changedY <= tempCurrentY - MOVE_ONE_OVER;
			changedX <= tempCurrentX;
		end
		
		else if(moveDown) begin
			changedY <= tempCurrentY + MOVE_ONE_OVER;
			changedX <= tempCurrentX;
		end
		
		else begin
			changedX <= tempCurrentX;
			changedY = tempCurrentY;
		end
		//donePosition = 1'b1 //raise donePosition flag so legal moves FSM can do its thing
	end
	
	//multiplexer for determining the value of newPosition
	//technically you don't need an always block for this stuff
	always @ (posedge clock)
	begin: newPosition
		if(!resetn) begin 	
			newX <= 5'b00000; //size?
			newY <= 5'b00000; //size?
		end
		
		else if(doneLegal & gameOver) begin //no change to newX or newY, should I load them with the current or changed values of X and Y?
			newX <= tempCurrentX;
			newY <= tempCurrentY;
		end
		
		else if(doneLegal & !gameOver) begin
			newX <= (~isLegal & tempCurrentX) | (isLegal & changedX);
			newY <= (~isLegal & tempCurrentY) | (isLegal & changedY);
		end
		 
	end
	
endmodule

//************************************************************************************************************************************************
//legal moves FSM

//need to read from RAM/memory
//what is the dimensions of memory/the gameboard?

//do you need a datapath for this FSM? since you're not manipulating any inputs/outputs

//size of memory is 32x32 (ie: 320 x 320) array
//only use 24x24 (first 24 elements)

module legalControl(
//need to input moveLeft/Right/Up/Down into this module?
	input clock,
	input resetn,
	input doneChangePosition,
	input [9:0] memory, //size? 32x32 means 32 rows, 32 cols which translate into 1 row, 32^2 = 1024 0 2^10 cols
	input [5:0] x, //size?
	input [4:0] y, //size?
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
				
	localparam WIDTH = 5'b10000; //width of a row in the array is 32
	
	wire [2:0] valueInMemory; //the max bit width of anything in memory is 3 since the max number stored in memory is 4
	assign valueInMemory = memory[WIDTH * y + x]; //store the value (0, 1, 2, 3, etc) in a wire for comparisons later
	
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
				if(x == LEFT && moveLeft) //single & or double &? what does == return, a single bit or true/false?
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
			
			WON: nextState = IDLE;
			
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

//**************************************************************************************************************************************************
//8 Hz rate divider used for drawing onto the screen
module rateDivider8Hz (
	input clock,
	input resetn,
	output reg [22:0] out
	);
	
	localparam COUNTDOWN = 23'd6_249_999;
	
	always @ (posedge clock)
	begin: ratedivider
		if(resetn)
			out <= 23'b0000000000000000000000;
		else if(out == 23'b00000000000000000000000)	
			out <= COUNTDOWN;
		else
			out <= out - 1'b1;
	end
	
endmodule

//************************************************************************************************************************************************
//2 clock cycle delay for reading from RAM
module delay2ClockCycles(
	input clock,
	input resetn,
	output reg [1:0] out
	);
	
	localparam COUNTDOWN = 2'b10;
	
	always @ (posedge clock)
	begin: delay
		if(resetn)
			out <= 2'b00;
		else if(out == 2'b00)
			out <= COUNTDOWN;
		else
			out <= out - 1'b1;
	end
	
endmodule

//************************************************************************************************************************************************
