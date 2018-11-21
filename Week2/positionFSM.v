//http://www.ee.ic.ac.uk/pcheung/teaching/ee2_digital/Lecture%207%20-%20FSM%20part%202.pdf info about FSMs
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
	
	
		