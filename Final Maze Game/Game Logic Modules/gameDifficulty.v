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
		playHard <= 1'b0;
		playMedium <= 1'b0;
		playEasy <= 1'b0;
		
		scorePlusFiveX = 5'd0;
		scorePlusFiveY = 5'd0;
		scoreMinusFiveX = 5'd0;
		scoreMinusFiveY = 5'd0;
		
		externalReset <= 1'b0;
		
		if(hard & !med & !easy) begin
			playHard <= 1'b1;
			
			scorePlusFiveX = 5'd1;
			scorePlusFiveY = 5'd21;
			scoreMinusFiveX = 5'd3;
			scoreMinusFiveY = 5'd5;
		end
		
		else if(!hard & med & !easy) begin
			playMedium <= 1'b1;
			
			scorePlusFiveX = 5'd21;
			scorePlusFiveY = 5'd4;
			scoreMinusFiveX = 5'd10;
			scoreMinusFiveY = 5'd6;
		end
		
		else if(!hard & !med & easy) begin
			playEasy <= 1'b1;
			
			scorePlusFiveX = 5'd17;
			scorePlusFiveY = 5'd9;
			scoreMinusFiveX = 5'd10;
			scoreMinusFiveY = 5'd9;
		end
		
		else if(!hard & !med & !easy) begin
			externalReset <= 1'b1;
		end
	
endmodule
