module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	snakeDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] snakeRGB, 
					     
		  // obstacles 
					input		logic	obstacleDrawingRequest,
					input		logic	[7:0] obstacleRGB,
			  
		  // background 
					input    logic FoodDrawingRequest, // box of numbers
					input		logic	[7:0] foodRGB,   
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] bgGameWinRGB, 
					input		logic	bgGameWinDr, 
					
			// other		
					input 	logic dim_screen_req,
					input 	logic [10:0] pixelX,
					
			  
				   output	logic	[7:0] RGBOut
);


logic [7:0] current_layer_RGB;


always_comb begin
    if (snakeDrawingRequest == 1'b1)
        current_layer_RGB = snakeRGB;
    else if (obstacleDrawingRequest == 1'b1)
        current_layer_RGB = obstacleRGB;
    else if (FoodDrawingRequest == 1'b1)
        current_layer_RGB = foodRGB;
    else
        current_layer_RGB = backGroundRGB;
end


always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        RGBOut <= 8'b0;
    end else begin
    
        if (bgGameWinDr == 1'b1) begin
            RGBOut <= bgGameWinRGB; 
            
        end else if (dim_screen_req == 1'b1 && pixelX < 11'd480) begin
           
			  RGBOut <= { 1'b0, current_layer_RGB[7:6], 1'b0, current_layer_RGB[4:3], 1'b0, current_layer_RGB[1] };
            
        end else begin

            RGBOut <= current_layer_RGB; 
        end 
        
    end
end

endmodule

