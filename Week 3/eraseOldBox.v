module eraseOldBox(
	input clk,
	input [0:0] eraseBox,
	input [0:0] resetn,
	input [4:0] xIn,
	input [4:0] yIn,
	output reg [8:0] xLoc,
	output reg [8:0] yLoc,
	output reg [2:0] colour,
	output reg [0:0] done
	);
	
	reg [4:0] topLeftx, topLefty;
	reg [3:0] countx, county;
	reg [0:0] donep1;
	reg [6:0] address;
	wire [2:0]  clrRam;
	
	always@(*) begin
		colour <= clrRam;
		address <= countx + county*(9);
	end	
	always@(posedge eraseBox) begin
		topLeftx <= xIn;
		topLefty <= yIn;
	end

	user1Ram player(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(clrRam)
	);	
	
	always @(posedge clk) begin
		if(~resetn) begin
			countx <= 4'b0;
			county <= 4'b0;
			donep1 <= 1'b0;
			done <= 1'b0;
		end
		
		if(eraseBox) begin
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
					done <= 1;
					xLoc <= 9'd0;
					yLoc <= 9'd0;
				end
							
				if (~donep1) begin
					done <= 0;
					xLoc <= 9'd80 + topLeftx*(10) + countx;
					yLoc <= topLefty*(10) + county;
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