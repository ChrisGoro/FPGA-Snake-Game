// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
// updated --Eyal Lev 2021

import game_pkg::*;        // game package including global state machine states and important parameters

module game_controller (    
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,  // short pulse every start of frame 30Hz 
    
    input  logic drawing_request_snake,
    input  logic drawing_request_boarders,
    input  logic drawing_request_food,
    
    input  logic gameFinish,    // input signal telling to finish game (game lost)
    input  logic gameWin,       // input signal telling to finish game (game won)
    
    input  logic [9:0] NumberKey,
	 
	 input  food_t foodEaten,
    
    output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
    output logic collision_Snake_Food, // active in case of collision between snake and food

    output logic [1:0] current_level,
    
    output logic lvl1_win_pulse,
    output logic lvl2_win_pulse,
    output logic lvl3_win_pulse,
            
    output game_state_t current_state,

	 output logic specialFoodEffectEnable,
	 
	 output logic sevenSegEnable
);

parameter [9:0] SPECIAL_FOOD_EFFECT_DURATION = 10'd375; 	// 375 / 75 (frames/sec) = 5 sec

logic flag; // a semaphore to set the output only once per frame regardless of number of collisions 
logic [9:0] NumberKeyPrev; // tracks the previous state of all keys for edge detection

logic [9:0] specialFoodEffectTimer; 	// counts frames according to special food effect duration

assign collision_Snake_Food = (drawing_request_snake && drawing_request_food);


always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin 
        flag <= 1'b0;
        SingleHitPulse <= 1'b0; 
        
        current_state <= IDLE;
        current_level <= 2'b0;
        
        lvl1_win_pulse <= 1'b0;
        lvl2_win_pulse <= 1'b0;
        lvl3_win_pulse <= 1'b0;
        
        NumberKeyPrev <= 10'b0; // reset previous key states
		  
		  specialFoodEffectTimer <= 10'b0;
		  specialFoodEffectEnable <= 1'b0;
		  
		  sevenSegEnable <= 1'b0;
    end 
    else begin 
    
        SingleHitPulse <= 1'b0; // default 
        
        lvl1_win_pulse <= 1'b0;
        lvl2_win_pulse <= 1'b0;
        lvl3_win_pulse <= 1'b0;
        
		  if ((current_state == PLAY_LVL_1 || current_state == PLAY_LVL_2 || current_state == PLAY_LVL_3) && (foodEaten == SPECIAL_FOOD)) begin
            specialFoodEffectTimer <= SPECIAL_FOOD_EFFECT_DURATION;
            specialFoodEffectEnable <= 1'b1;
        end
		  
        if(startOfFrame) begin
            flag <= 1'b0; // reset for next time
            
            NumberKeyPrev <= NumberKey; // save current key states for the next frame
				
				if(specialFoodEffectTimer > 0) begin
					specialFoodEffectTimer <= specialFoodEffectTimer - 1'b1;
					specialFoodEffectEnable <= 1'b1;
				end
				else specialFoodEffectEnable <= 1'b0;
				
				sevenSegEnable <= 1'b0;
            
            case(current_state) 
                
                IDLE: begin
                    // edge detection: transition only if the key was just pressed
                    if (NumberKey[1] && !NumberKeyPrev[1]) begin
                        current_state <= PLAY_LVL_1;
                        current_level <= 2'd1;
                    end
                    else if (NumberKey[2] && !NumberKeyPrev[2]) begin
                        current_state <= PLAY_LVL_2;
                        current_level <= 2'd2;
                    end
                    else if (NumberKey[3] && !NumberKeyPrev[3]) begin
                        current_state <= PLAY_LVL_3;
                        current_level <= 2'd3;
                    end
                end
                    
                PLAY_LVL_1, PLAY_LVL_2, PLAY_LVL_3: begin
                    if(gameWin) begin 
                        current_state <= WIN;
                        if (current_level == 2'd1) lvl1_win_pulse <= 1'b1;
                        else if (current_level == 2'd2) lvl2_win_pulse <= 1'b1;
                        else if (current_level == 2'd3) lvl3_win_pulse <= 1'b1;
                    end
                    else if(gameFinish) begin
                        current_state <= GAME_OVER;
                    end
						  
						  sevenSegEnable <= 1'b1;
                end
                
                GAME_OVER: begin
						  specialFoodEffectTimer <= 10'b0;
						  specialFoodEffectEnable <= 1'b0;
						  
                    if(NumberKey[1] && !NumberKeyPrev[1]) begin 
                        current_state <= IDLE;
                        current_level <= 2'b0;
                    end
                end
                
                WIN: begin 
						  specialFoodEffectTimer <= 10'b0;
						  specialFoodEffectEnable <= 1'b0;
						  
                    if(NumberKey[1] && !NumberKeyPrev[1]) begin 
                        current_state <= IDLE;
                        current_level <= 2'b0;
                    end
                end
                
            endcase
        end

        // food collision logic
        if (collision_Snake_Food && (flag == 1'b0)) begin 
            flag <= 1'b1; // to enter only once 
            SingleHitPulse <= 1'b1; 
        end

    end 
end

endmodule