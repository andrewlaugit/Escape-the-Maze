module fpga_demo(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [3:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	//SW[9] controls left
	//SW[8] controls right
	//SW[7] controls up
	//SW[6] controls down
	//SW[5:3] controls X position
	//SW[2:0] controls Y position
	//KEY[0] is active low reset
	//KEY[3] is clock
	//HEX1 display current X position
	//HEX0 display current Y Position
	//HEX3 display changed X position
	//HEX2 display changed Y Position
	//HEX5 display new X position
	//HEX4 display new Y position
	//LEDR[9] indicates doneAdd
	//LEDR[0] indicates isLegalMove
	//LEDR [5] indicates legalDone
	
	wire legalDone, doneAdd, isLegal;
	wire [5:0] newPosition;
	wire [5:0] changedPosition;
	
	changeLocation MOVE(
		.clock(KEY[3]), 
		.resetn(KEY[0]), 
		.currentPosition({SW[5:3], SW[2:0]}), 
		.moveLeft(SW[9]), 
		.moveRight(SW[8]), 
		.moveUp(SW[7]), 
		.moveDown(SW[6]),
		.isLegalMove(isLegal),
		.legalDone(legalDone),
		.move(newPosition),
		.doneAdd(doneAdd),
		.changedPosition(changedPosition)
		);
		
	/*module ram32x4 (
	address,
	clock,
	data,
	wren,
	q);*/
		
	legalMove LEGAL(
		.clock(KEY[3]),
		.resetn(KEY[0]),
		.location(changedPosition),
		.doneAdd(doneAdd),
		.legal(isLegal),
		.legalDone(legalDone)
		);
	
	assign LEDR[9] = doneAdd;
	assign LEDR[0] = isLegal;
	assign LEDR[5] = legalDone;
	
	//hex_decoder(hex_digit, segments)
	//HEX1 display current X position
	//HEX0 display current Y Position
	//HEX3 display changed X position
	//HEX2 display changed Y Position
	//HEX6 display new X position
	//HEX5 display new Y position
	
	hex_decoder H1(.hex_digit({1'b0, SW[5:3]}), .segments(HEX1));
	hex_decoder H0(.hex_digit({1'b0, SW[2:0]}), .segments(HEX0));
	
	hex_decoder H3(.hex_digit({1'b0, changedPosition[5:3]}), .segments(HEX3));
	hex_decoder H2(.hex_digit({1'b0, changedPosition[2:0]}), .segments(HEX2));
	
	hex_decoder H5(.hex_digit({1'b0, newPosition[5:3]}), .segments(HEX5));
	hex_decoder H4(.hex_digit({1'b0, newPosition[2:0]}), .segments(HEX4));
	
	
endmodule

module changeLocation(
	input clock,
	input resetn,
	input [5:0] currentPosition,
	input moveLeft,
	input moveRight,
	input moveUp,
	input moveDown,
	input isLegalMove,
	input legalDone,
	output reg [5:0] changedPosition,
	output [5:0] move,
	output reg doneAdd
	);
	
	//how can I change the value of currentPosition to match that of changedPosition if the move is legal?
	
	reg [5:0] newPosition;
	//reg doneAdd;
	
	always @ (posedge clock) begin
		//newPosition = 6'b000000;
			//changedPosition = 6'b000000;
		if(resetn == 1'b0) begin
			doneAdd <= 1'b0;
			changedPosition <= 6'b000000;
		end
		
		else if(moveLeft | moveRight | moveUp | moveDown) begin
			doneAdd <= 1'b0;
			if(moveLeft) begin
				changedPosition[5:3] <= currentPosition[5:3] - 1'b1;
				doneAdd <= 1'b1;
			end
			
			else if(moveRight) begin
				changedPosition[5:3] <= currentPosition[5:3] + 1'b1;
				doneAdd <= 1'b1;
			end

			if(moveUp) begin
				changedPosition[2:0] <= currentPosition[2:0] - 1'b1;
				doneAdd <= 1'b1;
			end
			
			else if(moveDown) begin
				changedPosition[2:0] <= currentPosition[2:0] + 1'b1;
				doneAdd <= 1'b1;
			end
			
		end
		
		else
			changedPosition[2:0] <= currentPosition[2:0];
			doneAdd <= 1'b1;
	end
	
	always @ (posedge clock) begin
		if(!resetn)
			newPosition = 6'b000000;
		else if(legalDone) begin
			if(!isLegalMove)
				newPosition <= currentPosition;
			else if(legalDone && isLegalMove)
				newPosition <= changedPosition;
		end
		else
			newPosition <= currentPosition;
	end
	
	assign move = newPosition;
	//assign currentPosition = newPosition;
	
endmodule

module legalMove(
	input clock,
	input resetn,
	input [5:0] location,
	input doneAdd,
	output reg legal,
	output legalDone
	);
	
	//for demo, change screen size to:
	//lower bound in x and y is still 0
	//upper bound in x = 4
	//upper bound in y = 4
	localparam X_LOWER_BOUND = 3'b0,
				  Y_LOWER_BOUND = 3'b0,
				  X_UPPER_BOUND = 3'b111,
				  Y_UPPER_BOUND = 3'b111;
				  
	reg isLegalMove = 1'b0;
	reg doneCheck = 1'b0;
	
	always @ (posedge clock) begin
	
		if(!resetn) begin
			isLegalMove <= 1'b0; //at the beginning of the game, any move is legal since you're at the starting position	
			doneCheck <= 1'b0;
		end
		
		else if(doneAdd) begin
			doneCheck <= 1'b0;
			
			if(location[5:3] == X_LOWER_BOUND || location[5:3] == X_UPPER_BOUND || location[2:0] == Y_LOWER_BOUND || location[2:0] == Y_UPPER_BOUND) begin//if you've hit the edge of the gameboard
				isLegalMove <= 1'b0;
				doneCheck <= 1'b1;
			//also somehow check if the position is on a barrier, but not sure how to input barrier location data (???)
			end
			
			else begin
				isLegalMove <= 1'b1;
				doneCheck <= 1'b1;
			end
	
		end
	end
	
	always @ (posedge clock) begin
		if(!resetn)
			legal <= 1'b0;
		else if(doneAdd)
			legal <= isLegalMove;
		else 
			legal <= 1'b1;
	end
	
	assign legalDone = doneCheck;

endmodule

module ram32x4 (
	address,
	clock,
	data,
	wren,
	q);

	input	[4:0]  address;
	input	  clock;
	input	[3:0]  data;
	input	  wren;
	output	[3:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [3:0] sub_wire0;
	wire [3:0] q = sub_wire0[3:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 32,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = 5,
		altsyncram_component.width_a = 4,
		altsyncram_component.width_byteena_a = 1;

endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
