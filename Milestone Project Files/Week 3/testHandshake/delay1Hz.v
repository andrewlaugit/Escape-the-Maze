module delay1Hz(
	input clock,
	input resetn,
	output reg [25:0] slowDown
	);

	always @ (posedge clock)
	begin
		if(!resetn)
			slowDown <= 26'd0;
		else if(slowDown == 1'b0)
			slowDown <= 26'b10111110101111000001111111;
		else
			slowDown <= slowDown - 1'b1;
	end
	
endmodule

/*module gameDuration(
	input go,
	input clock,
	input resetn, 
	output reg [6:0] timeElapsed,
	);
	
	always @ (posedge clock)
	begin
		if(!resetn)
			timeElapsed <= 7'd0;
		else if(timeElapsed == 7'd100)
			timeElapsed <= 7'd0;
		else if(go)
			timeElapsed <= timeElapsed + 1'b1;
	end

endmodule*/

//to connect these 2 together:
/*
wire go;
assign go = (slowDown == 0) ? 1 : 0;
*/