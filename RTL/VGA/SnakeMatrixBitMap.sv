// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 

import game_pkg::*;	// game package including global state machine states and important parameters

module SnakeMatrixBitMap (	
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX, 
    input  logic [10:0] offsetY,
    input  logic InsideRectangle, 
    input  logic [224:0] snakeMatrix,
    input  game_state_t current_state,
	 
    output logic drawingRequest, 
    output logic [7:0] RGBout  
);

	localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

	localparam logic [9:0] TILE_NUMBER_OF_X_BITS = 5; 
	localparam logic [9:0] TILE_NUMBER_OF_Y_BITS = 5; 

	localparam int MAZE_NUMBER_OF__X_BITS = 4; 
	localparam int MAZE_NUMBER_OF__Y_BITS = 4; 

	localparam logic [9:0] TILE_WIDTH_X = 10'b1 << TILE_NUMBER_OF_X_BITS;
	localparam logic [9:0] TILE_HEIGHT_Y = 1'b1 << TILE_NUMBER_OF_Y_BITS;
	localparam logic [10:0] MAZE_WIDTH_X = 11'b1 << MAZE_NUMBER_OF__X_BITS;
	localparam logic [10:0] MAZE_HEIGHT_Y = 11'b1 << MAZE_NUMBER_OF__Y_BITS;

	logic [9:0] offsetX_LSB;
	logic [9:0] offsetY_LSB; 
	logic [10:0] offsetX_MSB;
	logic [10:0] offsetY_MSB;
	logic [9:0] address;
	logic [0:1][7:0] color;
	logic [7:0] targetIndex;

	logic InsideRectangle_delay;
	logic [7:0] targetIndex_delay;

	assign offsetX_LSB = offsetX[(TILE_NUMBER_OF_X_BITS-1):0]; 
	assign offsetY_LSB = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0]; 
	assign offsetX_MSB = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS]; 
	assign offsetY_MSB = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS]; 
	assign address = (offsetY_LSB*TILE_WIDTH_X + offsetX_LSB);
	assign targetIndex = (offsetX_MSB * 8'd15) + offsetY_MSB;

	lpm_rom #(
		 .LPM_WIDTH(8),
		 .LPM_WIDTHAD(10),
		 .LPM_NUMWORDS(1024),
		 .LPM_FILE("RTL/snake_body.mif"),
		 .LPM_TYPE               ("LPM_ROM"),
		 .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		 .LPM_OUTDATA            ("UNREGISTERED"), 
		 .AUTO_CARRY_CHAINS      ("ON"),
		 .AUTO_CASCADE_BUFFERS   ("ON"),
		 .INTENDED_DEVICE_FAMILY ("Cyclone V")  
	) rom_inst (
		 .address(address),
		 .inclock(clk),
		 .q(color[0])
	);

	always_ff@(posedge clk or negedge resetN) begin
		 if(!resetN) begin
			  RGBout <= 8'h00;
			  InsideRectangle_delay <= 1'b0;
			  targetIndex_delay <= 8'd0;
		 end
		 else begin
			  // Pipeline delay 
			  InsideRectangle_delay <= InsideRectangle;
			  targetIndex_delay <= targetIndex;

			  RGBout <= TRANSPARENT_ENCODING; 
			  
			  // Output logic synced with ROM delay
			  if (InsideRectangle_delay == 1'b1) begin 
					if (snakeMatrix[targetIndex_delay] == 1'b1) begin
						 RGBout <= color[0];
					end 
					else begin 
						 RGBout <= TRANSPARENT_ENCODING; 
					end
			  end 
		 end 
	end

	assign drawingRequest = (RGBout != TRANSPARENT_ENCODING && current_state != IDLE) ? 1'b1 : 1'b0; 

endmodule