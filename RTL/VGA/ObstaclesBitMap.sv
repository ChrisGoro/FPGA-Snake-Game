module ObstaclesBitMap (	
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX,  
    input  logic [10:0] offsetY,
    input  logic InsideRectangle, 
    
    input  logic [224:0] obstacleMatrix, 

    output logic drawingRequest, 
    output logic [7:0] RGBout  
);

	localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;

	localparam logic [9:0] TILE_NUMBER_OF_X_BITS = 5; 
	localparam logic [9:0] TILE_NUMBER_OF_Y_BITS = 5; 
	localparam int MAZE_NUMBER_OF__X_BITS = 4; 
	localparam int MAZE_NUMBER_OF__Y_BITS = 4; 

	logic [10:0] offsetX_MSB;
	logic [10:0] offsetY_MSB;
	logic [7:0] targetIndex;


	logic [9:0] rom_address; 
	logic [4:0] local_X;     
	logic [4:0] local_Y;     
	logic [7:0] MIF_VGA;

	// Pipeline alignment signals
	logic is_obstacle_tile;
	logic draw_enable_delay;

	// Matrix coordinate math (same as in foodBitMap)
	assign offsetX_MSB = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS - 1) : TILE_NUMBER_OF_X_BITS] ; 
	assign offsetY_MSB = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS - 1) : TILE_NUMBER_OF_Y_BITS] ; 
	assign targetIndex = (offsetX_MSB * 8'd15) + offsetY_MSB;

	// Calculate local pixel coordinates inside the 32x32 sprite
	assign local_X = offsetX[4:0];
	assign local_Y = offsetY[4:0];

	assign rom_address = {local_Y, local_X}; 

	// are we in the game area AND is there an obstacle at the current segment
	assign is_obstacle_tile = (InsideRectangle == 1'b1) && (obstacleMatrix[targetIndex] == 1'b1);

	// Instantiate the ROM
	lpm_rom #(
		 .LPM_WIDTH(8),
		 .LPM_WIDTHAD(10),
		 .LPM_NUMWORDS(1024), 
		 .LPM_FILE("RTL/obstacle.mif"), 
		 .LPM_TYPE               ("LPM_ROM"),
		 .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		 .LPM_OUTDATA            ("UNREGISTERED"), 
		 .AUTO_CARRY_CHAINS      ("ON"),
		 .AUTO_CASCADE_BUFFERS   ("ON"),
		 .INTENDED_DEVICE_FAMILY ("Cyclone V")  
	) rom_inst_obstacle (
		 .address(rom_address),
		 .inclock(clk),
		 .q(MIF_VGA)
	);

	always_ff@(posedge clk or negedge resetN)
	begin
		 if(!resetN) begin
			  RGBout <= TRANSPARENT_ENCODING;
			  draw_enable_delay <= 1'b0;
		 end
		 else begin
			  // Delay draw enable by 1 clock cycle to wait for ROM data
			  draw_enable_delay <= is_obstacle_tile; 
			  
			  if (draw_enable_delay == 1'b1) begin 
					if (MIF_VGA != TRANSPARENT_ENCODING) begin
						 RGBout <= MIF_VGA; // Draw colored pixel from ROM
					end else begin
						 RGBout <= TRANSPARENT_ENCODING; // Transparent background of the image
					end
			  end else begin
					RGBout <= TRANSPARENT_ENCODING; // Empty space between obstacles
			  end 
		 end 
	end

	// Drawing request signal goes to the multiplexer
	assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0; 

endmodule