//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2025
// generating a number bitmap 

module NumbersBitMap (	
    input  logic clk,
    input  logic resetN,
    input  logic [10:0] offsetX,  // offset from top left  position 
    input  logic [10:0] offsetY,
    input  logic InsideRectangle, // input that the pixel is within a bracket 
    input  logic [3:0] digit,     // digit to display
    
    output logic        drawingRequest, // output that the pixel should be dispalyed 
    output logic [7:0]  RGBout
);


parameter int NUMBER_SIZE = 0; 	// 2 - double size, 1 - regular size, 0 - small size 
parameter logic [7:0] DIGIT_COLOR = 8'hff ; //set the color of the digit 

localparam logic[12:0] OBJECT_WIDTH_X = 6'd16;
localparam logic[12:0] OBJECT_WIDTH_Y = 6'd32;
localparam logic[12:0] digit_location_MIF = OBJECT_WIDTH_X*OBJECT_WIDTH_Y;

// generating a number bitmap from a MIF file
logic [12:0] address;
logic color;

logic InsideRectangle_delay;
 
lpm_rom #(
    .LPM_WIDTH(1),
    .LPM_WIDTHAD(13),
    .LPM_NUMWORDS(8192),
    .LPM_FILE("RTL/numbers.mif"),
    .LPM_TYPE               ("LPM_ROM"),
    .LPM_ADDRESS_CONTROL    ("REGISTERED"), 
    .LPM_OUTDATA            ("UNREGISTERED"), 
    .AUTO_CARRY_CHAINS      ("ON"),
    .AUTO_CASCADE_BUFFERS   ("ON"),
    .INTENDED_DEVICE_FAMILY ("Cyclone V")  
) rom_inst (
    .address(address),
    .inclock(clk),
    .q(color)
);


always_comb begin
	
	case(NUMBER_SIZE)
		
		2: address = ((digit_location_MIF*digit)+((offsetY>>1)*OBJECT_WIDTH_X + (offsetX>>1))); 	// Double size
		
		0: address = ((digit_location_MIF*digit)+((offsetY<<1)*OBJECT_WIDTH_X + (offsetX<<1)));	// Half size
		
		default: address = ((digit_location_MIF*digit)+((offsetY)*OBJECT_WIDTH_X + (offsetX))); 	// Original size of digit
	
	endcase

end


// pipeline (ff) to get the pixel color from the array 	 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest <= 1'b0;
		InsideRectangle_delay <= 1'b0; 
	end
	
	else begin
		InsideRectangle_delay <= InsideRectangle; 
		
		drawingRequest <= 1'b0;
		
	  	if (InsideRectangle_delay == 1'b1 )
			drawingRequest <= (color == 1'b1) ? 1'b1 : 1'b0;
 	end 
end

assign RGBout = DIGIT_COLOR ; // this is a fixed color 


endmodule