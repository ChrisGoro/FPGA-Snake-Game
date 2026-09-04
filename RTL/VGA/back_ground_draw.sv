//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2025


module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,
					input 	logic	[18:0]	address,
					input logic draw,

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDrawReq, 
					output	logic	[7:0] MIF_VGA
);

const int	xFrameSize	=	635;
const int	yFrameSize	=	475;
const int	bracketOffset =	32;


localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel  

localparam int IMAGE_WIDTH = 320; 

logic [16:0] address_int;

assign address_int = ((pixelY >> 1) * IMAGE_WIDTH) + (pixelX >> 1);

 lpm_rom #(
    .LPM_WIDTH(8),
    .LPM_WIDTHAD(17),
	 .LPM_NUMWORDS(76800),
    .LPM_FILE("RTL/background.mif"),
	   .LPM_TYPE               ("LPM_ROM"),
      .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
		.LPM_OUTDATA            ("UNREGISTERED"), 
		.AUTO_CARRY_CHAINS      ("ON"),
		.AUTO_CASCADE_BUFFERS   ("ON"),
	   .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address_int),
	 .inclock(clk),
	// .outclock(clk),
    .q(MIF_VGA)
);



always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin
        BG_RGB <= 8'h00;
        boardersDrawReq <= 1'b0; 
    end 
    else begin
		if(draw) begin 
			boardersDrawReq <= 1'b1; 
			BG_RGB <= MIF_VGA; 
		end else begin
        boardersDrawReq <= 1'b0; 
        BG_RGB <= 8'h00; 
		end
    end 
	 
end

endmodule

