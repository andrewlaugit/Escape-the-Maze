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
	input memory //size?
	input x, //size?
	input y, //size?
	output reg doneCheckLegal,
	output reg isLegal,
	output reg gameOver
	);
	
	localparam AVAILABLE = 1'h1,
				OCCUPIED = 1'h0,
				START = 1'h2,
				END = 1'h3,
				YOUR_POSITION = 1'h4;
	
	reg [2:0] currentState, nextState;
	
	localparam IDLE = 3'b000,
				CHECK_MEMORY = 3'b001,
				NOT_LEGAL = 3'b010
				LEGAL = 3'b011,
				WON = 3'b100;
	
	//next state logic
	always @ (*) 
	begin: state_table
		case(currentState)
			IDLE: nextState = doneChangePosition ? CHECK_MEMORY : IDLE;
			//CHECK_MEMORY: nextState = (memory[whatever position] != OCCUPIED ) ? LEGAL : NOT_LEGAL; 
			//LEGAL: nextState = (memory[whatever position] == END) ? WON : IDLE;
			WON: nextState = IDLE;
			NOT_LEGAL: nextState = IDLE;
			default: nextState = IDLE;
		endcase
	end

	//datapath control signals
	always @ (*)
	begin
		doneCheckLegal = 1'b0;
		isLegal = 1'b0;
		gameOver = 1'b0;
		case(currentState)
			IDLE: doneCheckLegal = 1'b0;
			CHECK_MEMORY: doneCheckLegal = 1'b0;
			LEGAL: begin
				doneCheckLegal = 1'b1;
				isLegal = 1'b1;
			end
			NOT_LEGAL: begin
				doneCheckLegal = 1'b1;
				isLegal = 1'b1;
			end
			WON: begin
				doneCheckLegal = 1'b1;
				isLegal = 1'b1;
				gameOver = 1'b1;
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

//do you need a datapath for this FSM? since the control can already generate flags for isLegal, doneCheckLegal, gameOver

/*module legalDatapath();

endmodule*/
