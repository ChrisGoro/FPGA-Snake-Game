module background_mux (

	input logic	clk,
	input logic	resetN,

	input logic [7:0] BG_RGB,
	input logic background_dr,
	
	input logic [7:0] BG_START_RGB,
	input logic bg_start_dr,
	
	input logic [7:0] BG_GAME_WIN_RGB,
	input logic bg_game_win_dr,
	
	input logic [7:0] BG_SCORES_INFO_RGB,
	input logic bg_scores_info_dr,
	
	input logic [7:0] BG_GAME_OVER_RGB,
	input logic bg_game_over_dr,
	
	input logic [7:0] CURRENT_SCORE_RGB,
	input logic current_score_dr,
	
	input logic [7:0] GAME_WIN_SCORE_RGB,
	input logic game_win_score_dr,
	
	input logic [7:0] LVL1_HIGH_SCORE_RGB,
	input logic lvl1_high_score_dr,
	
	input logic [7:0] LVL2_HIGH_SCORE_RGB,
	input logic lvl2_high_score_dr,
	
	input logic [7:0] LVL3_HIGH_SCORE_RGB,
	input logic lvl3_high_score_dr,
		
	// Base background outputs
	output logic bg_dr_out,
	output logic [7:0] BG_RGB_OUT,
	
	// Overlay outputs
	output logic overlay_dr_out,
	output logic [7:0] OVERLAY_RGB_OUT
);


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			BG_RGB_OUT	<= 8'b0;
			bg_dr_out <= 1'b0;
			OVERLAY_RGB_OUT <= 8'b0;
			overlay_dr_out <= 1'b0;
	end
	
	else begin
		
		// Overlay logic
		overlay_dr_out <= 1'b1;
		
		if(game_win_score_dr == 1'b1)
			OVERLAY_RGB_OUT <= GAME_WIN_SCORE_RGB;  // fourth priority 
			
		else if(bg_game_win_dr == 1'b1)
			OVERLAY_RGB_OUT <= BG_GAME_WIN_RGB;  // eighth priority 
		
		else if(bg_game_over_dr == 1'b1)
			OVERLAY_RGB_OUT <= BG_GAME_OVER_RGB;  // nineth priority 
			
		else begin
			OVERLAY_RGB_OUT <= 8'b0;
			overlay_dr_out <= 1'b0;
		end

		// Base background logic
		bg_dr_out <= 1'b1;
		
		if (bg_start_dr == 1'b1 )   
			BG_RGB_OUT <= BG_START_RGB;  // first priority 
			
		else if(current_score_dr == 1'b1)
			BG_RGB_OUT <= CURRENT_SCORE_RGB;  // second priority 

		else if(bg_scores_info_dr == 1'b1)
			BG_RGB_OUT <= BG_SCORES_INFO_RGB;  // third priority 
			
		else if(lvl1_high_score_dr == 1'b1)
			BG_RGB_OUT <= LVL1_HIGH_SCORE_RGB;  // fifth priority 
			
		else if(lvl2_high_score_dr == 1'b1)
			BG_RGB_OUT <= LVL2_HIGH_SCORE_RGB;  // sixth priority 
			
		else if(lvl3_high_score_dr == 1'b1)
			BG_RGB_OUT <= LVL3_HIGH_SCORE_RGB;  // seventh priority 
			
		else if(background_dr == 1'b1)
			BG_RGB_OUT <= BG_RGB;  		// tenth priority 
			
		else begin
			BG_RGB_OUT	<= 8'b0;		// nothing to draw
			bg_dr_out <= 1'b0;
		end
		
	end
	
end

endmodule