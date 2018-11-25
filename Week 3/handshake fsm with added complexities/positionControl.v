module positionControl(
	input clock,
	input resetn,
	input received_data_en,
	input [7:0] received_data,
	input doneCheckLegal,
	input isLegal,
	input doneMaze,
	input doneDraw,
	input doneErase,
	output reg moveUp,
	output reg moveDown,
	output reg moveLeft,
	output reg moveRight,
	output reg drawBox,
	output reg eraseBox,
	output reg drawMaze,
	output reg doneChangePosition
	);
	
	reg [3:0] currentState, nextState;
	
	localparam  DRAW_MAZE 				= 4'd0,
					IDLE 						= 4'd1,
					LOAD_DIRECTION 		= 4'd2,
					DELETE_OLD 				= 4'd3,
					CHANGE_POSITION 		= 4'd4,
					MODIFICATIONS 			= 4'd5,
					CHANGE_CURRENT 		= 4'd6,
					DONT_CHANGE_CURRENT 	= 4'd7,
					DRAW_NEW 				= 4'd8;
				
	//next state logic
	always @ (*)
	begin: state_table
		case(currentState)
			DRAW_MAZE:				nextState = doneMaze ? IDLE : DRAW_MAZE;
			IDLE: 					nextState = received_data_en ? LOAD_DIRECTION : IDLE;
			LOAD_DIRECTION: 		nextState = received_data_en ? LOAD_DIRECTION : DELETE_OLD;
			DELETE_OLD: 			nextState = doneErase ? CHANGE_POSITION : DELETE_OLD;
			CHANGE_POSITION: 		nextState = doneCheckLegal ? MODIFICATIONS : CHANGE_POSITION;
			MODIFICATIONS: 		nextState = isLegal ? CHANGE_CURRENT : DONT_CHANGE_CURRENT;
			CHANGE_CURRENT: 		nextState = DRAW_NEW;
			DONT_CHANGE_CURRENT: nextState = DRAW_NEW;
			DRAW_NEW: 				nextState = doneDraw ? IDLE : DRAW_NEW;
			default: 				nextState = IDLE;
		endcase
	end
	
	always @ (*)
	begin: isDoneChangingPosition
		doneChangePosition = 1'b0;
		drawBox = 1'b0;
		eraseBox = 1'b0;
		drawMaze = 1'b0;
		
		case(currentState)
			DRAW_MAZE: drawMaze = 1'b1;
			
			IDLE: doneChangePosition = 1'b0;
			
			LOAD_DIRECTION: doneChangePosition = 1'b1;
			
			DELETE_OLD: begin
				eraseBox = 1'b1;
				doneChangePosition = 1'b1;
			end
			
			CHANGE_POSITION: doneChangePosition = 1'b0;
			
			MODIFICATIONS: doneChangePosition = 1'b0;

			DRAW_NEW: drawBox = 1'b1;
		
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
			currentState <= DRAW_MAZE;
		else
			currentState <= nextState;
	end

endmodule