module start_screen_draw (  
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic draw,
    output logic [7:0] BG_START_RGB,
    output logic       bg_start_dr 
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

localparam int IMAGE_WIDTH  = 480;
localparam int IMAGE_HEIGHT = 480;
localparam int OFFSET_X = 0;
localparam int OFFSET_Y = 0;

logic [18:0] address;
logic [10:0] local_X;
logic [10:0] local_Y;
logic [7:0] MIF_VGA;

// Calculate local coordinates relative to the image bounding box
assign local_X = pixelX - OFFSET_X;
assign local_Y = pixelY - OFFSET_Y;
assign address = (local_Y * IMAGE_WIDTH) + local_X;

lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(18), 
    .LPM_NUMWORDS(230400),
    .LPM_FILE("RTL/background_start.mif"), 
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst_start (
    .address(address),
    .inclock(clk),
    .q(MIF_VGA)
);

always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        BG_START_RGB <= 8'h00;
        bg_start_dr <= 1'b0; 
    end 
    else begin
        // Check if drawing is enabled and beam is within the bounding box
        if (draw && (pixelX >= OFFSET_X) && (pixelX < OFFSET_X + IMAGE_WIDTH) && 
                    (pixelY >= OFFSET_Y) && (pixelY < OFFSET_Y + IMAGE_HEIGHT)) begin
            bg_start_dr <= 1'b1; 
            BG_START_RGB <= MIF_VGA; 
        end else begin
            bg_start_dr <= 1'b0; 
            BG_START_RGB <= 8'h00; 
        end 
    end 
end
endmodule