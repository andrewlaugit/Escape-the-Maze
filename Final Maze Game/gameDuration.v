module gameDuration(
	input go,
	input clock,
	input resetn, 
	output timeUp
	);
	
	localparam timeLimit = 7'd99;
	reg [6:0] timeElapsed;
	
	always @ (posedge clock)
	begin
		if(!resetn)
			timeElapsed <= 7'd0;
		else if(timeElapsed == 7'd100)
			timeElapsed <= 7'd0;
		else if(go)
			timeElapsed <= timeElapsed + 1'b1;
	end
	
	assign timeUp = (timeElapsed == timeLimit) ? 1'b1 : 1'b0;

endmodule