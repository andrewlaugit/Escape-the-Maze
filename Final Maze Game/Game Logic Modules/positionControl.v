module positionControl(
	input clock, resetn, externalReset,
	input switch9, switch8, switch7,
	input received_data_en,
	input [7:0] received_data,
	input doneCheckLegal, isLegal,
	input doneMaze, doneSpecial,doneDraw, doneErase, doneScreen,
	output reg moveUp, moveDown, moveLeft, moveRight,
	output reg drawBox, drawMaze, eraseBox, drawStart, drawClear, drawSpecial,
	output reg doneChangePosition
	);
	
	reg [3:0] currentState, nextState;
	
	localparam  START_SCREEN         	= 4'd0,
					WAIT_FOR_SW          	= 4'd1,
					CLEAR_SCREEN         	= 4'd2,
					DRAW_MAZE 		         = 4'd3,
					DRAW_SPECIAL_BOX	      = 4'd4,
					IDLE 			            = 4'd5,
					LOAD_DIRECTION 		   = 4'd6,
					DELETE_OLD 		         = 4'd7,
					CHANGE_POSITION 	      = 4'd8,
					MODIFICATIONS 		      = 4'd9,
					CHANGE_CURRENT 	 	   = 4'd10,
					DONT_CHANGE_CURRENT 	   = 4'd11,
					DRAW_NEW 		         = 4'd12;
				
	//next state logic
	always @ (*)
	begin: state_table
		case(currentState)
			START_SCREEN:        	nextState = doneScreen ? WAIT_FOR_SW : START_SCREEN;
			WAIT_FOR_SW:         	nextState = (switch9 || switch8 || switch7) ? CLEAR_SCREEN : WAIT_FOR_SW;
			CLEAR_SCREEN:        	nextState = (switch9 || switch8 || switch7) ? (doneScreen ? DRAW_MAZE : CLEAR_SCREEN) : START_SCREEN;
			DRAW_MAZE:		         nextState = (switch9 || switch8 || switch7) ? (doneMaze ? DRAW_SPECIAL_BOX : DRAW_MAZE) : START_SCREEN;
			DRAW_SPECIAL_BOX:	      nextState = (switch9 || switch8 || switch7) ? (doneSpecial ? IDLE : DRAW_SPECIAL_BOX) : START_SCREEN;
			IDLE: 			         nextState = (switch9 || switch8 || switch7) ? (received_data_en ? LOAD_DIRECTION : IDLE) : START_SCREEN;
			LOAD_DIRECTION: 	      nextState = (switch9 || switch8 || switch7) ? (received_data_en ? LOAD_DIRECTION : DELETE_OLD) : START_SCREEN;
			DELETE_OLD: 		      nextState = (switch9 || switch8 || switch7) ? (doneErase ? CHANGE_POSITION : DELETE_OLD) : START_SCREEN;
			CHANGE_POSITION: 	      nextState = (switch9 || switch8 || switch7) ? (doneCheckLegal ? MODIFICATIONS : CHANGE_POSITION) : START_SCREEN;
			MODIFICATIONS: 		   nextState = (switch9 || switch8 || switch7) ? (isLegal ? CHANGE_CURRENT : DONT_CHANGE_CURRENT) : START_SCREEN;
			CHANGE_CURRENT: 	      nextState = (switch9 || switch8 || switch7) ? (DRAW_NEW) : START_SCREEN;
			DONT_CHANGE_CURRENT: 	nextState = (switch9 || switch8 || switch7) ? (DRAW_NEW) : START_SCREEN;
			DRAW_NEW: 		         nextState = (switch9 || switch8 || switch7) ? (doneDraw ? IDLE : DRAW_NEW) : START_SCREEN;
			default: 		         nextState = START_SCREEN;
		endcase
	end
	
	always @ (*)
	begin: isDoneChangingPosition
		drawStart = 1'b0;
		drawClear = 1'b0;
		doneChangePosition = 1'b0;
		drawBox = 1'b0;
		eraseBox = 1'b0;
		drawMaze = 1'b0;
		drawSpecial = 1'b0;
		
		case(currentState)
			START_SCREEN: drawStart = 1'b1;
			
			CLEAR_SCREEN: drawClear = 1'b1;
			
			DRAW_MAZE: drawMaze = 1'b1;
			
			DRAW_SPECIAL_BOX: drawSpecial = 1'b1;
			
			LOAD_DIRECTION: doneChangePosition = 1'b1;
			
			DELETE_OLD: begin
				eraseBox = 1'b1;
				doneChangePosition = 1'b1;
			end

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
		moveLeft = 1'b0;
		moveRight = 1'b0;
		
		if(!received_data_en) begin //reset the values of moveUp/moveDown/moveLeft/moveRight once the key has been released
			moveUp = 1'b0;
			moveDown = 1'b0;
			moveLeft = 1'b0;
			moveRight = 1'b0;
		end
		
		case(received_data)
			A: begin
				moveUp = 1'b0;
				moveDown = 1'b0;
				moveLeft = 1'b1;
				moveRight = 1'b0;
				end
			
			D: begin
				moveUp = 1'b0;
				moveDown = 1'b0;
				moveLeft = 1'b0;
				moveRight = 1'b1;
				end
			
			W: begin
				moveUp = 1'b1;
				moveDown = 1'b0;
				moveLeft = 1'b0;
				moveRight = 1'b0;
				end
			
			S: begin
				moveUp = 1'b0;
				moveDown = 1'b1;
				moveLeft = 1'b0;
				moveRight = 1'b0;
				end
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
		if(!resetn || externalReset)
			currentState <= START_SCREEN;
		else
			currentState <= nextState;
	end

endmodule
