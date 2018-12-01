module countTime(
	input clock, 
	input resetn,
	input externalReset,
	output noMoreTime,
	output [6:0] timeElapsed
	);
	
	wire [25:0] slowDown;
	
	delay1Hz DELAY(
		.clock(clock),
		.resetn(resetn),
		.slowDown(slowDown)
	);
	
	wire go; //if 1 second has passed, count up by 1 in timeElapsed
	assign go = (slowDown == 0) ? 1'b1 : 1'b0;
	
	gameDuration DURATION(
		.go(go),
		.clock(clock),
		.resetn(resetn),
		.timeUp(noMoreTime),
		.externalReset(externalReset),
		.timeElapsed(timeElapsed)
	);
	
endmodule

module delay1Hz(
	input clock,
	input resetn,
	output reg [25:0] slowDown
	);

	always @ (posedge clock)
	begin
		if(!resetn)
			slowDown <= 26'd49_999_999; //counting down from 49,999,999 slows down the frequency to 1 Hz
		else if(slowDown == 1'b0)
			slowDown <= 26'd49_999_999;
		else
			slowDown <= slowDown - 1'b1;
	end
	
endmodule

module gameDuration(
	input clock,
	input resetn, 
	input go,
	input externalReset,
	output timeUp,
	output reg [6:0] timeElapsed
	);
	
	localparam timeLimit = 7'd100;

	always @ (posedge clock)
	begin
		if(!resetn || externalReset)
			timeElapsed <= 7'd0;
		else if(timeElapsed == (timeLimit + 1'b1)) //if time limit has been reached
			timeElapsed <= 7'd0;
		else if(go && !externalReset && !timeUp)
			timeElapsed <= timeElapsed + 1'b1; //increment the time elapsed during the game
		else if(timeUp) //if time's up don't change the time elapsed
			timeElapsed <= timeElapsed;
	end
	
	assign timeUp = (timeElapsed == timeLimit) ? 1'b1 : 1'b0;

endmodule
