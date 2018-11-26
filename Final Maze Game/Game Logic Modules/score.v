module score (
	input resetn,
	input externalReset,
	input receivedData,
	input scorePlusFive, scoreMinusFive,
	input isLegal,
	output reg [7:0] score
	);
	
	reg [0:0] changed, resetChanged, doneChange;
	
	always @(*) begin
		
		if(!resetn | externalReset) begin
			score <= 8'd0;
			changed <= 1'b0;
		end
		
		else if(~changed) begin
			if(scorePlusFive) begin
				score <= score + 8'd5;
				changed <= 1'b1;
			end
			else if(scoreMinusFive) begin
				score <= score - 8'd5;
				changed <= 1'b1;
			end
			else if(isLegal) begin
				score <= score + 8'd1;
				changed <= 1'b1;
			end				
		end
		
		if(resetChanged && ~doneChange) begin
			changed <= 1'b0;
			doneChange <= 1'b1;
		end
		if(resetChanged && ~change) begin
		end
	end
	
	always@(posedge receivedData)
		resetChanged <= 1'b1;
endmodule
