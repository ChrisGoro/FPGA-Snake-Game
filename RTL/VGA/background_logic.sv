import game_pkg::*; // game package including global state machine states and important parameters

module background_logic (

	input logic clk,
	input logic resetN,
	
	input logic startOfFrame,
	
	input game_state_t current_state,	// global game state
	
	output logic background_draw,
	output logic start_screen_draw,
	output logic game_over_draw,
	output logic scores_info_draw,
	output logic game_win_score_digits_draw,
	output logic game_win_draw
);


always_ff @(posedge clk or negedge resetN) begin
	if(!resetN) begin
		background_draw <= 1;
		start_screen_draw <= 1;
		game_over_draw <= 0;
		scores_info_draw <= 1;
		game_win_score_digits_draw <= 0;
		game_win_draw <= 0;
	
	end 
	else begin
		
		if(startOfFrame) begin
			case(current_state) 
			
				IDLE: begin
					background_draw <= 1;
					start_screen_draw <= 1;
					game_over_draw <= 0;
					scores_info_draw <= 1;
					game_win_score_digits_draw <= 0;
					game_win_draw <= 0;
				
				end
				
				
				PLAY_LVL_1, PLAY_LVL_2, PLAY_LVL_3: begin 
					background_draw <= 1;
					start_screen_draw <= 0;
					game_over_draw <= 0;
					scores_info_draw <= 1;
					game_win_score_digits_draw <= 0;
					game_win_draw <= 0;
				end
			
			
				GAME_OVER: begin
					background_draw <= 1;
					start_screen_draw <= 0;
					game_over_draw <= 1;
					scores_info_draw <= 1;
					game_win_score_digits_draw <= 0;
					game_win_draw <= 0;
				
				end
				
				WIN: begin
					background_draw <= 1;
					start_screen_draw <= 0;
					game_over_draw <= 0;
					scores_info_draw <= 1;
					game_win_score_digits_draw <= 1;
					game_win_draw <= 1;
				end
			
			endcase
		
		end
	
	end

end



endmodule