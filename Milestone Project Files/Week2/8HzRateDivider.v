module rateDivider8Hz (
	input clock,
	input resetn,
	output reg [22:0] out
	);
	
	localparam COUNTDOWN = 7'd6_249_999;
	
	always @ (posedge clock)
	begin: ratedivider
		if(resetn)
			out <= 23'b0000000000000000000000;
		else if(out == 23'b00000000000000000000000)	
			out <= COUNTDOWN;
		else
			out <= out - 1'b1;
	end
	
endmodule

module delay2ClockCycles(
	input clock,
	input resetn,
	output reg [1:0] out
	);
	
	localparam COUNTDOWN = 2'b10;
	
	always @ (posedge clock)
	begin: delay
		if(resetn)
			out <= 2'b00;
		else if(out == 2'b00)
			out <= COUNTDOWN;
		else
			out <= out - 1'b1;
	end
	
endmodule
	