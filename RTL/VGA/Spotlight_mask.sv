module Spotlight_mask (
	
	input logic clk,
	input logic resetN,
	
	input logic [7:0] RGB,
	
	input logic [3:0] snakeHeadX,
	input logic [3:0] snakeHeadY,
	
	input logic [10:0] pixelX,
	input logic [10:0] pixelY,
	
	input logic enableSpotlight,
	
	output logic [7:0] RGBout
);


parameter int SNAKE_MATRIX_SIZE = 5'd32;		// size of cell of matrix displaying snake body (typically 32 pixels)

parameter int OUTER_SPOTLIGHT_RADIUS = 11'd128;			
parameter int INNER_SPOTLIGHT_RADIUS = 11'd88;

localparam int PLAY_AREA_WIDTH = 480;

logic [10:0] snakeHeadPixelX;
logic [10:0] snakeHeadPixelY;

logic signed [11:0] pixelDistanceX;
logic signed [11:0] pixelDistanceY;
logic [19:0] pixelDistance; 		

logic pixelIsInPlayArea;


assign snakeHeadPixelX = (snakeHeadX * SNAKE_MATRIX_SIZE) + (SNAKE_MATRIX_SIZE >> 1);
assign snakeHeadPixelY = (snakeHeadY * SNAKE_MATRIX_SIZE) + (SNAKE_MATRIX_SIZE >> 1);


assign pixelDistanceX = $signed({1'b0, pixelX}) - $signed({1'b0,snakeHeadPixelX});
assign pixelDistanceY = $signed({1'b0, pixelY}) - $signed({1'b0,snakeHeadPixelY});

assign pixelDistance = pixelDistanceX * pixelDistanceX + pixelDistanceY * pixelDistanceY;		// distance of current pixel from snake head


always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
		RGBout <= 8'b0;
	end else begin
			
		if(enableSpotlight && pixelX < PLAY_AREA_WIDTH) begin
			if(pixelDistance < (INNER_SPOTLIGHT_RADIUS * INNER_SPOTLIGHT_RADIUS) )	begin		// pixel is inside INNER circle - regular draw	
				RGBout <= RGB;
			end 
			else if(pixelDistance < (OUTER_SPOTLIGHT_RADIUS * OUTER_SPOTLIGHT_RADIUS) ) begin		// pixel is inside OUTER circle - dimmed draw	
				RGBout <= { 1'b0, RGB[7:6], 1'b0, RGB[4:3], 1'b0, RGB[1] };
			end
			else begin		// pixel is outside circle - draw black
				RGBout <= 8'd0;
			end
		
		end else begin
			
			// pixel is outside dimming area or no dimming needed - regular draw
			RGBout <= RGB;
		
		end
	end
end

endmodule