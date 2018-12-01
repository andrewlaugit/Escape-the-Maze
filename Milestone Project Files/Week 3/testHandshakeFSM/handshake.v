`timescale 1ns/1ns

//MASSIVE NOTE: Change [4:0]/5'b/whatever else is 5 bits wide to 6 bits wide so that it can actually account for 32, and not 31
//(or maybe not idk i think it works regardless because you'll never get to [32:32] since the index starts at 0 and goes up to 31)

//how to input ram/memory?
//something to do with "open textfile blah blah blah"

//*************************************************************************************************************************************************
//top level module
module handshake(
	clock,
	resetn,
	ps2_key_pressed,
	ps2_key_data,
	valueInMemory
);

	// Inputs
	input clock;
	input resetn;
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
	input [2:0] valueInMemory;
	
	wire doneCheckLegal, isLegal;
	wire moveUp, moveDown, moveLeft, moveRight;
	wire doneChangePosition;
	wire doneGame;
	
	wire [4:0] currentX, currentY;
	assign currentX = 5'b00000;
	assign currentY = 5'b00000;
	
	wire [4:0] tempCurrentX, tempCurrentY;
	wire [4:0] changedX, changedY;
	wire [4:0] newX, newY;
	
	wire [2:0] legalCurrentState, legalNextState;
	wire [3:0] positionCurrentState, positionNextState;
	
	positionControl POSCTRL(
		.clock(clock),
		.resetn(resetn),
		.received_data_en(ps2_key_pressed),
		.received_data(ps2_key_data),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneChangePosition(doneChangePosition),
		.currentStateP(positionCurrentState),
		.nextStateP(positionNextState)
	);

	positionDatapath POSDATA( 
		.clock(clock),
		.resetn(resetn),
		.currentX(currentX),
		.currentY(currentY),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(doneGame),
		.tempCurrentX(tempCurrentX),
		.tempCurrentY(tempCurrentY),
		.changedX(changedX),
		.changedY(changedY),
		.newX(newX),
		.newY(newY)
	);
	
	legalControl LEGALCTRL(
		.clock(clock),
		.resetn(resetn),
		.doneChangePosition(doneChangePosition),
		.valueInMemory(valueInMemory),
		.x(changedX),
		.y(changedY),
		.moveUp(moveUp),
		.moveDown(moveDown),
		.moveLeft(moveLeft),
		.moveRight(moveRight),
		.doneCheckLegal(doneCheckLegal),
		.isLegal(isLegal),
		.gameOver(doneGame),
		.currentStateL(legalCurrentState),
		.nextStateL(legalNextState)
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
	output reg doneChangePosition,
	output reg [3:0]  currentStateP, nextStateP
	);
	
	//reg [3:0] currentStateP, nextStateP;
	
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
		case(currentStateP)
			IDLE: nextStateP = received_data_en ? LOAD_DIRECTION : IDLE;
			
			LOAD_DIRECTION: nextStateP = !received_data_en ? CHANGE_POSITION : LOAD_DIRECTION;
			
			CHANGE_POSITION: nextStateP = doneCheckLegal ? MODIFICATIONS : CHANGE_POSITION;
			
			MODIFICATIONS: nextStateP = isLegal ? CHANGE_CURRENT : DONT_CHANGE_CURRENT;
			
			CHANGE_CURRENT: nextStateP = doneChangePosition ? IDLE : CHANGE_CURRENT;
			
			DONT_CHANGE_CURRENT: nextStateP = doneChangePosition ? IDLE : DONT_CHANGE_CURRENT;
			
			default: nextStateP = IDLE;
		endcase
	end
	
	//raising the doneChangePosition flag
	//if you needed enable signals for the registers, this is where you would add them
	//just change the states to have begin/end
	always @ (*)
	begin: isDoneChangingPosition
		doneChangePosition = 1'b0;
		case(currentStateP)
			IDLE: doneChangePosition = 1'b0;
			
			LOAD_DIRECTION: doneChangePosition = 1'b0;
			
			CHANGE_POSITION: doneChangePosition = 1'b1;
			
			MODIFICATIONS: doneChangePosition = 1'b1;
			
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
			currentStateP <= IDLE;
		else
			currentStateP <= nextStateP;
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
	output reg [4:0] tempCurrentX, tempCurrentY,
	output reg [4:0] changedX, changedY,
	output reg [4:0] newX, newY
	//output reg donePosition
	);
	
	//do I need these 2?
	//localparam STARTING_X_POSITION = 5'b00000 //size? initialize it to 0
	//localparam STARTING_Y_POSITION = 5'b00000 //size? initialize it to 0
	
	localparam MOVE_ONE_OVER = 5'b00001; //how big is one square on the board?
	
	//reg [4:0] tempCurrentX, tempCurrentY; //size?
	
	//assign tempCurrentX = (~resetn & currentX) | (resetn & newX);
	//assign tempCurrentY = (~resetn & currentY) | (resetn & newY);

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
			tempCurrentX <= newX;
			tempCurrentY <= newY;
		end
		
	end
	
	//ALU for determining the value of changedX and changedY
	always @ (posedge clock)
	begin: changedPosition

		if(!resetn) begin
			changedX <= 5'b00000; //size?
			changedY <= 5'b00000; //size?
		end
		
		else begin
			if(moveLeft) begin
				changedX <= tempCurrentX - MOVE_ONE_OVER;
				changedY <= changedY;
			end
			
			else if(moveRight) begin
				changedX <= tempCurrentX + MOVE_ONE_OVER;
				changedY <= changedY;
			end
			
			else if(moveUp) begin
				changedY <= tempCurrentY - MOVE_ONE_OVER;
				changedX <= changedX;
			end
			
			else if(moveDown) begin
				changedY <= tempCurrentY + MOVE_ONE_OVER;
				changedX <= changedX;
			end
			
			else begin
				changedX <= tempCurrentX;
				changedY <= tempCurrentY;
			end
			
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
			newX <= newX;
			newY <= newY;
		end
		
		else if(doneLegal & !gameOver) begin
			
			if(isLegal) begin
				newX <= changedX;
				newY <= changedY;
			end
			
			else begin
				newX <= tempCurrentX;
				newY <= tempCurrentY;
			end
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
	output reg [2:0] currentStateL, nextStateL
	);
	
	localparam AVAILABLE = 4'h1,
				OCCUPIED = 4'h0,
				START = 4'h2,
				END = 4'h3,
				YOUR_POSITION = 4'h4;
				
	localparam WIDTH = 5'b10000; 
	
	//wire [2:0] valueInMemory;
	//assign valueInMemory = memory[WIDTH * y + x];
	
	//reg [2:0] currentStateL, nextStateL;
	
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
				else
					nextStateL = LEGAL;
			end
			
			LEGAL: nextStateL = (valueInMemory == END) ? WON : IDLE;
			
			WON: nextStateL = resetn ? IDLE : WON; //if not reset, remain in won state; if reset, start again from the top
			
			NOT_LEGAL: nextStateL = IDLE;
			
			default: nextStateL = IDLE;
		endcase
	end

	//datapath control signals
	always @ (posedge clock)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		
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