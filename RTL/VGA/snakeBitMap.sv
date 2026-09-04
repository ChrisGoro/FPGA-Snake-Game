// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 

import game_pkg::*;		// game package including global state machine states and important parameters

module	snakeBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					
					input game_state_t current_state, 
					input dir_t current_dir, 
					
					input logic snakeCry,

					output logic drawingRequest, //output that the pixel should be dispalyed 
					output logic [7:0] RGBout	 //rgb value from the bitmap 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 

localparam  logic	[10:0] OBJECT_HEIGHT_Y = 11'b1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  logic	[10:0] OBJECT_WIDTH_X = 11'b1 <<  OBJECT_NUMBER_OF_X_BITS;

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 


logic	[9:0] address;

logic	[7:0] snakeHeadReg;
logic	[7:0] snakeHeadCry;

// head turn logic
logic [4:0] rot_X;
logic [4:0] rot_Y;

always_comb begin
	address = (rot_Y * OBJECT_WIDTH_X) + rot_X;
	
	case (current_dir)
		DIR_UP: begin 
			rot_X = 5'd31 - offsetX[4:0];
			rot_Y = 5'd31 - offsetY[4:0];
		end
		DIR_DOWN: begin 
			rot_X = offsetX[4:0];
			rot_Y = offsetY[4:0];
		end
		DIR_LEFT: begin 
			rot_X = offsetY[4:0];
			rot_Y = 5'd31 - offsetX[4:0];
		end
		DIR_RIGHT: begin 
			rot_X = 5'd31 - offsetY[4:0];
			rot_Y = offsetX[4:0];
		end
		default: begin
			rot_X = offsetX[4:0];
			rot_Y = offsetY[4:0];
		end
	endcase
end

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),               
	 .LPM_NUMWORDS(1024),           
    .LPM_FILE("RTL/snake_head.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(snakeHeadReg)
);

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),               
	 .LPM_NUMWORDS(1024),           
    .LPM_FILE("RTL/snake_head_cry.mif"),
		.LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst2 (
    .address(address),
	 .inclock(clk),
	// .outclock(clk),
    .q(snakeHeadCry)
);


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  

		if (InsideRectangle == 1'b1 ) begin // inside an external bracket  
			RGBout <= (snakeCry) ? snakeHeadCry : snakeHeadReg;
		end  	
	end
		
end

// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING && current_state != IDLE) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule