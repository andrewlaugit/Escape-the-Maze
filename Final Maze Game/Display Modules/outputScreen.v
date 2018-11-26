module outputScreen(
	input clk,
	input [0:0] drawWinner,
	input [0:0] drawGameOver,
	input [0:0] drawStart,
	input [0:0] drawClear,
	input [0:0] resetn,
	output reg [8:0] xLoc,
	output reg [8:0] yLoc,
	output reg [2:0] colour,
	output reg [0:0] done
	);
	
	reg [7:0] countx, county;
	reg [0:0] donep1;
	reg [15:0] address;
	wire [2:0]  startClr, gameoverClr, winnerClr;
	
	always@(*) begin
		address <= countx + county*(240);
	end	
	
	startRam player(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(startClr)
	);

	gameoverRam gg(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(gameoverClr)
	);

	winnerRam win(
		.address(address),
		.clock(clk),
		.data(3'b000),
		.wren(1'b0),
		.q(winnerClr)
	);

	always @(*) begin
		if(drawClear)
			colour <= 3'b001;
		if(drawStart)
			colour <= startClr;
		if(drawGameOver)
			colour <= gameoverClr;
		if(drawWinner)
			colour <= winnerClr;
		if(~drawClear && ~drawStart && ~drawGameOver && ~drawWinner)
			colour <= 3'b000;
	end
	
	always @(posedge clk) begin
		if(~resetn) begin
			countx <= 8'b0;
			county <= 8'b0;
			donep1 <= 1'b0;
			done <= 1'b0;
		end
		
		if(drawClear || drawStart || drawGameOver || drawWinner) begin
			if(~done) begin
				if (countx == 239) begin
					countx <= 8'b0;
					county <= county + 1;
				end
				else begin
					if(~done && ~donep1)
						countx <= countx + 1;
				end
					
				if (county == 239 && countx == 239) begin
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
					xLoc <= 9'd80 + countx;
					yLoc <= county;
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