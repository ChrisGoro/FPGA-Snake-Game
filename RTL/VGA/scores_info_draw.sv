module scores_info_draw (  
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic draw,
    output logic [7:0] BG_SCORES_INFO_RGB,
    output logic       bg_scores_info_dr
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

localparam int IMAGE_WIDTH  = 124;
localparam int IMAGE_HEIGHT = 231;
// Centered for 640x480 screen: (160-124)/2 + 480 = 498, (480-231)/2 - 30 = 94
localparam int OFFSET_X = 498;
localparam int OFFSET_Y = 94;

logic [14:0] address;
logic [10:0] local_X;
logic [10:0] local_Y;
logic [7:0] MIF_VGA;

// Calculate local coordinates relative to the image bounding box
assign local_X = pixelX - OFFSET_X;
assign local_Y = pixelY - OFFSET_Y;
assign address = (local_Y * IMAGE_WIDTH) + local_X;

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(15), 
    .LPM_NUMWORDS(28644),
    .LPM_FILE("RTL/background_scores_info.mif"), 
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst_scores (
    .address(address),
    .inclock(clk),
    .q(MIF_VGA)
);

always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        BG_SCORES_INFO_RGB <= 8'h00;
        bg_scores_info_dr <= 1'b0; 
    end 
    else begin
        // Check if drawing is enabled and beam is within the bounding box
        if (draw && (pixelX >= OFFSET_X) && (pixelX < OFFSET_X + IMAGE_WIDTH) && 
                    (pixelY >= OFFSET_Y) && (pixelY < OFFSET_Y + IMAGE_HEIGHT)) begin
				bg_scores_info_dr <= (MIF_VGA != TRANSPARENT_ENCODING) ? 1'b1 : 1'b0; 
            BG_SCORES_INFO_RGB <= MIF_VGA; 
        end else begin
            bg_scores_info_dr <= 1'b0; 
            BG_SCORES_INFO_RGB <= 8'h00; 
        end
    end 
end
endmodule