// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Feb 2025 
//(c) Technion IIT, Department of Electrical Engineering 2025 

module FoodMatrixBitMap (	
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX, // offset from top left  position 
    input  logic [10:0] offsetY,
    input  logic InsideRectangle, //input that the pixel is within a bracket 
    // input  logic random_hart, // PROBABLY USELESS !!! ******
    
    input  logic [224:0][2:0] MazeBitMapMask,

    output logic drawingRequest, //output that the pixel should be dispalyed 
    output logic [7:0] RGBout  //rgb value from the bitmap 
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

localparam logic [9:0] TILE_NUMBER_OF_X_BITS = 5; // 2^5 = 32  every object 
localparam logic [9:0] TILE_NUMBER_OF_Y_BITS = 5; // 2^5 = 32 

localparam int MAZE_NUMBER_OF__X_BITS = 4; // 2^4 = 16 / /the maze of the objects 
localparam int MAZE_NUMBER_OF__Y_BITS = 4; // 2^4 = 16

//-----

localparam logic [9:0] TILE_WIDTH_X = 10'b1 << TILE_NUMBER_OF_X_BITS ;
localparam logic [9:0] TILE_HEIGHT_Y = 1'b1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam logic [10:0] MAZE_WIDTH_X = 11'b1 << MAZE_NUMBER_OF__X_BITS ;
localparam logic [10:0] MAZE_HEIGHT_Y = 11'b1 << MAZE_NUMBER_OF__Y_BITS ;

logic [9:0] offsetX_LSB;
logic [9:0] offsetY_LSB; 
logic [10:0] offsetX_MSB;
logic [10:0] offsetY_MSB;
logic [9:0] address;
logic [0:2][7:0] color;

logic [7:0] targetIndex;

logic InsideRectangle_delay;
logic [7:0] targetIndex_delay;

assign offsetX_LSB = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
assign offsetY_LSB = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
assign offsetX_MSB = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
assign offsetY_MSB = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
assign address = (offsetY_LSB*TILE_WIDTH_X + offsetX_LSB);

assign targetIndex = (offsetX_MSB * 8'd15) + offsetY_MSB;

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
    .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/food_shrink.mif"),
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

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(10),
    .LPM_NUMWORDS(1024),
    .LPM_FILE("RTL/food_grow.mif"),
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst2 (
    .address(address),
    .inclock(clk),
    .q(color[1])
);

	lpm_rom #(
		 .LPM_WIDTH(8),
		 .LPM_WIDTHAD(10),
		 .LPM_NUMWORDS(1024),
		 .LPM_FILE("RTL/food_speed.mif"),
		 .LPM_TYPE               ("LPM_ROM"),
		 .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		 .LPM_OUTDATA            ("UNREGISTERED"), 
		 .AUTO_CARRY_CHAINS      ("ON"),
		 .AUTO_CASCADE_BUFFERS   ("ON"),
		 .INTENDED_DEVICE_FAMILY ("Cyclone V")  
	) rom_inst3 (
		 .address(address),
		 .inclock(clk),
		 .q(color[2])
	);

	always_ff@(posedge clk or negedge resetN)
	begin
		 if(!resetN) begin
			  RGBout <= 8'h00;
			  InsideRectangle_delay <= 1'b0;
			  targetIndex_delay <= 8'd0;
		 end
		 else begin
			  InsideRectangle_delay <= InsideRectangle;
			  targetIndex_delay <= targetIndex;

			  RGBout <= TRANSPARENT_ENCODING ; // default 
			  
			  if (InsideRectangle_delay == 1'b1 )	
					begin 
					case (MazeBitMapMask[targetIndex_delay])
								3'b000 : RGBout <= TRANSPARENT_ENCODING ;
								3'b001 : RGBout <= color[0];  // for shrink food
								3'b010 : RGBout <= color[1];  // for grow food
								3'b011 : RGBout <= color[2];  // for speed food
								default:  RGBout <= TRANSPARENT_ENCODING ;
						 endcase
					end 
		 end 
	end


	// decide if to draw the pixel or not 
	assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule