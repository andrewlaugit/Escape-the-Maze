module countTime(
	input clock, 
	input resetn,
	output noMoreTime
	);
	
	wire [25:0] slowDown;
	
	delay1Hz DELAY(
		.clock(clock),
		.resetn(resetn),
		.slowDown(slowDown)
	);
	
	wire go;
	assign go = (slowDown == 0) ? 1'b1 : 1'b0;
	
	gameDuration DURATION(
		.go(go),
		.clock(clock),
		.resetn(resetn),
		.timeUp(noMoreTime)
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
			//slowDown <= 26'b0000000000000000000000000011;
			slowDown <= 26'b10111110101111000001111111;
		else if(slowDown == 1'b0)
			//slowDown <= 26'b0000000000000000000000000011;
			slowDown <= 26'b10111110101111000001111111;
		else
			slowDown <= slowDown - 1'b1;
	end
	
endmodule

module gameDuration(
	input clock,
	input resetn, 
	input go,
	output timeUp
	);
	
	localparam timeLimit = 7'd100;
	//localparam timeLimit = 7'd2;
	reg [6:0] timeElapsed;
	
	always @ (posedge clock)
	begin
		if(!resetn)
			timeElapsed <= 7'd0;
		else if(timeElapsed == (timeLimit + 1'b1))
			timeElapsed <= 7'd0;
		else if(go)
			timeElapsed <= timeElapsed + 1'b1;
	end
	
	assign timeUp = (timeElapsed == timeLimit) ? 1'b1 : 1'b0;

endmodule
