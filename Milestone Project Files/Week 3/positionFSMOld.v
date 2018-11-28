module positionControl(
	input clock,
	input resetn,
	input received_data_en,,
	input [7:0] received_data;
	input doneCheckLegal,
	input isLegal,
	output reg moveUp,
	output reg moveDown,
	output reg moveLeft,
	output reg moveRight,
	output reg doneChangePosition,
	output reg loadCurrent, loadChange, loadNew
	);
	
	reg [3:0]  currentState, nextState;
	
	localparam  IDLE = 5'b000,
				LOAD_DIRECTION = 5'b001,
				CHANGE_POSITION = 5'b010,
				MODIFICATIONS = 5'b011
				CHANGE_CURRENT = 5'b100,
				DONT_CHANGE_CURRENT = 5'b101;
				
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
	endcase
	
	//raising the doneChangePosition flag
	//with enable signals for registers
	always @ (*)
	begin: isDoneChangingPosition
		doneChangePosition = 1'b0;
		case(currentState)
			IDLE: doneChangePosition = 1'b0;
			
			LOAD_DIRECTION: begin 
				doneChangePosition = 1'b0;
				loadCurrent = 1'b1;
			end
			
			CHANGE_POSITION: begin
				doneChangePosition = 1'b0;
				loadChange = 1'b1;
			end
			
			MODIFICATIONS: doneChangePosition = 1'b0;
			
			//where should i raise the flag that the position has changed?
			CHANGE_CURRENT: doneChangePosition = 1'b1;
			
			DONT_CHANGE_CURRENT: doneChangePosition = 1'b1;
			
			default: doneChangePosition = 1'b0; //technically dont need default
		endcase
	end
	
	localparam W = 2'h1d, //move up
				A = 2'h1c, //move left
				S = 2'h1b, //move down
				D = 2'h23; //move right
				
	//determine if key pressed corresponds to moving up/down/left/rigt
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
		endcase
	endcase
	
	//current tate registers
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
	input currentX, //size?
	input currentY, //size?
	input moveLeft, moveRight, moveUp, moveDown,
	input doneLegal, isLegal, gameOver,
	output reg changedX, changedY, //size?
	output reg newX, newY //size?
	//output reg donePosition
	);
	
	//localparam STARTING_X_POSITION = //size? initialize it to 0
	//localparam STARTING_Y_POSITION = //size? initialize it to 0
	//localparam SIZE_OF_ONE_SQUARE = //how big is one square on the board?
	
	reg tempCurrentX, tempCurrentY; //size?
	reg changedX, changedY; //size?
	
	//do I actually need this always block?
	//Lab6Part2 code used this always block to determine what to load the registers with
	//don't think i need this
	/*always @ (posedge clock) begin
	if(!resetn) begin
		/*tempCurrentX <= 0;
		tempCurrentY <= 0;
		changedX <= 0;
		changedY <= 0;
		newX = 0;
		newY = 0;*/
	/*end
	else begin
		if(moveLeft)
			tempCurrentX <= currentX - SIZE_OF_ONE_SQUARE;
		else if(moveRight)
			tempCurrentX <= currentX + SIZE_OF_ONE_SQUARE;
		else if(moveUp)
			tempCurrentY <= currentY - SIZE_OF_ONE_SQUARE;
		else if(moveDown)
			tempCurrentY <= currentY + SIZE_OF_ONE_SQUARE;
		else begin //don't change the position
			tempCurrentX <= currentX;
			tempCurrentY <= currentY;
		end
	end*/
	
	//multiplexer for determining the value of tempCurrent X and Y
	//technically you don't need an always block for this stuff
	always @ (*) 
	begin: tempCurrent
		if(!resetn) begin
		//do I need this here? because...
			tempCurrentX = STARTING_X_POSITION;
			tempCurrentY = STARTING_Y_POSITION;
		end
		else 
			//... this takes care of the case where resetn is 0 (ie: do the resetting) and sets (X,Y) to (0,0)
			tempCurrentX = (~resetn & STARTING_X_POSITION) | (resetn & newXPosition);
			tempCurrentY = (~resetn & STARTING_Y_POSITION) | (resetn & newYPosition);
	end
	
	//ALU for determining the value of changedX and changedY
	always @ (*)
	begin: changedPosition
		if(!resetn) begin
			changedX = 0; //size?
			changedY = 0; //size?
		end
		else if(moveLeft) begin
			changedX = tempCurrentX - SIZE_OF_ONE_SQUARE;
			changedY = tempCurrentY;
		end
		else if(moveRight) begin
			changedX = tempCurrentX + SIZE_OF_ONE_SQUARE;
			changedY = tempCurrentY;
		end
		else if(moveUp) begin
			changedY = tempCurrentY - SIZE_OF_ONE_SQUARE;
			changedX = tempCurrentX;
		end
		else if(moveDown) begin
			changedY = tempCurrentY + SIZE_OF_ONE_SQUARE;
			changedX = tempCurrentX;
		end
		else begin
			changedX = tempCurrentX;
			changedY = tempCurrentY;
		end
		//donePosition = 1'b1 //raise donePosition flag so legal moves FSM can do its thing
	end
	
	//multiplexer for determining the value of newPosition
	//technically you don't need an always block for this stuff
	always @ (*)
	begin: newPosition
		if(!resetn) begin 	
			newX = 0; //size?
			newY = 0; //size?
		end
		else if(doneLegal & !gameOver) begin
			newX = (~isLegal & tempCurrentX) | (isLegal & changedX);
			newY = (~isLegal & tempCurrentY) | (isLegal & changedY);
		end
		else if(gameOver) begin //no change to newX or newY, should I load them with the current or changed values of X and Y?
			//don't do anything to newX or newY???
		end 
	end
	
endmodule
	
	
		