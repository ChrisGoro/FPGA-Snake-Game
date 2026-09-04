module game_over_draw(  
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic draw,
    output logic [7:0] BG_GAME_OVER_RGB,
    output logic       bg_game_over_dr,
	 output logic 		  dim_screen_req
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

localparam int IMAGE_WIDTH = 344;
localparam int IMAGE_HEIGHT = 292;
// Centered for 480x480 screen: (480-343)/2 = 68, (480-292)/2 = 94
localparam int OFFSET_X = 68;
localparam int OFFSET_Y = 94;

localparam int IMAGE_ROM_WIDTH = 172; // Compressed ROM width

logic [14:0] address;
logic [10:0] local_X;
logic [10:0] local_Y;
logic [7:0] MIF_VGA;

logic insideRectangle;
logic insideRectangle_delay;

// Calculate local coordinates relative to the image bounding box
assign local_X = pixelX - OFFSET_X;
assign local_Y = pixelY - OFFSET_Y;
// Pixel doubling: shift right by 1 (divide by 2)
assign address = ((local_Y >> 1) * IMAGE_ROM_WIDTH) + (local_X >> 1);

assign dim_screen_req = draw;

assign insideRectangle = (draw && (pixelX >= OFFSET_X) && (pixelX < OFFSET_X + IMAGE_WIDTH) && 
                                  (pixelY >= OFFSET_Y) && (pixelY < OFFSET_Y + IMAGE_HEIGHT));

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(15), 
    .LPM_NUMWORDS(25112),
    .LPM_FILE("RTL/background_game_over_compressed.mif"), 
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst_game_over (
    .address(address),
    .inclock(clk),
    .q(MIF_VGA)
);

always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        BG_GAME_OVER_RGB <= 8'h00;
        bg_game_over_dr <= 1'b0; 
		  insideRectangle_delay <= 1'b0;
    end 
    else begin
		  insideRectangle_delay <= insideRectangle;
		  
        // Check if drawing is enabled and beam is within the bounding box
        if (insideRectangle_delay == 1'b1) begin
						  
				if (MIF_VGA != TRANSPARENT_ENCODING) begin
                bg_game_over_dr <= 1'b1; 
                BG_GAME_OVER_RGB <= MIF_VGA; 
            end else begin
                bg_game_over_dr <= 1'b0; 
                BG_GAME_OVER_RGB <= 8'h00; 
            end 
				
        end else begin
            bg_game_over_dr <= 1'b0; 
            BG_GAME_OVER_RGB <= 8'h00; 
        end
    end 
end
endmodule