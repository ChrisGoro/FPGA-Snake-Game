module obstacle_map (

    input  logic [1:0] current_level, // from game controller
	 
    output logic [224:0] obstacleMatrix
);

   
   // Level 1: 
	localparam logic [224:0] LEVEL_1 = {
			  15'b000000000000000, // Col 14 (Right side of screen)
			  15'b000000000000000, // Col 13
			  15'b000000000001000, // Col 12
			  15'b000000000000000, // Col 11
			  15'b001000000000000, // Col 10
			  15'b000000000000000, // Col 9  
			  15'b000000000000000, // Col 8
			  15'b000000000000000, // Col 7
			  15'b000000000000000, // Col 6
			  15'b000000000001000, // Col 5  
			  15'b000000000000000, // Col 4
			  15'b000000000000000, // Col 3
			  15'b000100000000000, // Col 2
			  15'b000000000000000, // Col 1
			  15'b000000000000000  // Col 0  (Left side of screen)
		 }; 
    
   // Level 2: 
	localparam logic [224:0] LEVEL_2 = {
			  15'b000100000000000, // Col 14 (Right side of screen)
			  15'b000100000000000, // Col 13
			  15'b000100000000000, // Col 12
			  15'b000100000000000, // Col 11
			  15'b000000000001111, // Col 10
			  15'b000000000000000, // Col 9  
			  15'b000000000000000, // Col 8
			  15'b000000000000000, // Col 7
			  15'b000000000000000, // Col 6
			  15'b000000000000000, // Col 5  
			  15'b111100000000000, // Col 4
			  15'b000000000001000, // Col 3
			  15'b000000000001000, // Col 2
			  15'b000000000001000, // Col 1
			  15'b000000000001000  // Col 0  (Left side of screen)
		 }; 
	 
	// Level 3:
	localparam logic [224:0] LEVEL_3 = {
			  15'b000000000000000, // Col 14 (Right side of screen)
			  15'b000000000000000, // Col 13
			  15'b001111111111100, // Col 12
			  15'b001000000000100, // Col 11
			  15'b001000000000100, // Col 10
			  15'b001000000000100, // Col 9  
			  15'b000001000100000, // Col 8
			  15'b100001000100001, // Col 7
			  15'b100001000100001, // Col 6
			  15'b000001000100000, // Col 5  
			  15'b001000000000100, // Col 4
			  15'b001000000000100, // Col 3
			  15'b001000000000100, // Col 2
			  15'b001111111111100, // Col 1
			  15'b000000000000000  // Col 0  (Left side of screen)
		 }; 

   always_comb begin
       case(current_level)
           2'd1: obstacleMatrix = LEVEL_1;
           2'd2: obstacleMatrix = LEVEL_2;
			  2'd3: obstacleMatrix = LEVEL_3;
           default: obstacleMatrix = 225'b0;
       endcase
   end
	
endmodule 