import game_pkg::*;

module score_timer (
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,
    input  game_state_t current_state,
    
    output logic [3:0] score_ones,
    output logic [3:0] score_tens
);

    logic [6:0] frame_count; // 7 bits to hold up to 74

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            frame_count <= 7'd0;
            score_ones <= 4'd0;
            score_tens <= 4'd0;
        end else begin
            
            // Reset score when sitting in the main menu
            if (current_state == IDLE) begin
                frame_count <= 7'd0;
                score_ones <= 4'd0;
                score_tens <= 4'd0;
            end 
            
            // Only count up while actually playing
            else if (current_state == PLAY_LVL_1 || current_state == PLAY_LVL_2 || current_state == PLAY_LVL_3) begin
                
                if (score_tens == 4'd9 && score_ones == 4'd9) begin
						// Freeze the timer if it reaches 99
                end 
                else if (startOfFrame == 1'b1) begin
                    if (frame_count >= 7'd74) begin // 75 frames = 1 second
                        frame_count <= 7'd0;
                        
                        // BCD Increment Logic
                        if (score_ones == 4'd9) begin
                            score_ones <= 4'd0;
                            score_tens <= score_tens + 1'b1;
                        end else begin
                            score_ones <= score_ones + 1'b1;
                        end
                        
                    end else begin
                        frame_count <= frame_count + 1'b1;
                    end
                end
            end
        end
    end

endmodule 