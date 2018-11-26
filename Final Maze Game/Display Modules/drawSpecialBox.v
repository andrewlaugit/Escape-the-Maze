module drawSpecialBox(
	input clk,
	input [0:0] drawSpecial,
	input [0:0] resetn,
	input [4:0] xPlus,
	input [4:0] yPlus,
	input [4:0] xMinus,
	input [4:0] yMinus,
	output reg [8:0] xLoc,
	output reg [8:0] yLoc,
	output reg [2:0] colour,
	output reg [0:0] done
	);
	
	reg [3:0] countx, county;
	reg [0:0] donep1, donePlus;

	always@(*) begin
		if(county == 3 | county == 4 | county == 5) begin
			if(countx == 0 | countx == 8)
				colour <= 3'b111;
			else begin
				if(drawPlus)
					colour <= 3'b010;
				else
					colour <= 3'b100;
			end
		end
		else begin
			if(drawPlus) begin
				if(countx == 3 | countx == 4 | countx == 5)
					colour <= 3'b010;
				else
					colour <= 3'b111;
			end
			else
				colour <= 3'b111;
		end
	end
	
	always @(posedge clk) begin
		if(~resetn) begin
			countx <= 4'b0;
			county <= 4'b0;
			donep1 <= 1'b0;
			donePlus <= 1'b0;
			done <= 1'b0;
		end
		
		if(drawSpecial) begin
			if(~done) begin
				if (countx == 8) begin
					countx <= 4'b0;
					county <= county + 1;
				end
				else begin
					if(~done && ~donep1)
						countx <= countx + 1;
				end
					
				if (county == 8 && countx == 8) begin
					donep1 <= 1;
					county <= 4'b0;
				end
					
				if (donep1) begin
					donep1 <= 0;
					if(donePlus) begin
						done <= 1;
						xLoc <= 9'd0;
						yLoc <= 9'd0;
					end
					else begin
						donePlus <= 1;
					end
				end
							
				if (~donep1) begin
					done <= 0;
					if(donePlus) begin
						xLoc <= 9'd80 + xMinus*(10) + countx;
						yLoc <= yMinus*(10) + county;
					end
					else begin
						xLoc <= 9'd80 + xPlus*(10) + countx;
						yLoc <= yPlus*(10) + county;
					end
				end
			end
			
			if(done) begin
				xLoc <= 9'd0;
				yLoc <= 9'd0;
			end
		end
		
		else begin
			xLoc <= 9'd0;
			yLoc <= 9'd0;
			done <= 0;
		end
	end
endmodule