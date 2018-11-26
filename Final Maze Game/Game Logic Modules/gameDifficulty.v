module gameDifficulty(
	input clock,
	input resetn,
	input hard,
	input med,
	input easy,
	output reg playHard, playMedium, playEasy, externalReset,
	output reg [4:0] scorePlusFiveX, scorePlusFiveY, scoreMinusFiveX, scoreMinusFiveY
	);
	
	always @ (*) begin
		if(hard & !med & !easy) begin
			playHard = 1'b1;
			externalReset = 1'b0;
			scorePlusFiveX = 5'd10;
			scorePlusFiveY = 5'd6;
			scoreMinusFiveX = 5'd15;
			scoreMinusFiveY = 5'd19;
		end
		
		else if(!hard & med & !easy) begin
			playMedium = 1'b1;
			externalReset = 1'b0;
			scorePlusFiveX = 5'd17;
			scorePlusFiveY = 5'd9;
			scoreMinusFiveX = 5'd4;
			scoreMinusFiveY = 5'd6;
		end
		
		else if(!hard & !med & easy) begin
			playEasy = 1'b1;
			externalReset = 1'b0;
			scorePlusFiveX = 5'd13;
			scorePlusFiveY = 5'd5;
			scoreMinusFiveX = 5'd10;
			scoreMinusFiveY = 5'd3;
		end
		
		else if(!hard & !med & !easy) begin
			externalReset = 1'b1;
			playHard = 1'b0;
			playMedium = 1'b0;
			playEasy = 1'b0;
			scorePlusFiveX = 5'd0;
			scorePlusFiveY = 5'd0;
			scoreMinusFiveX = 5'd0;
			scoreMinusFiveY = 5'd0;
		end
	end
	
endmodule
