import game_pkg::*; 

module sound_manager (
	input  logic clk,
	input  logic resetN,

	// Game Events
	input  food_t food_type,
	input  game_state_t current_state,
	input  logic specialFoodEffectEnable,

	// Melody ended signal
	input  logic melodyEnded, 

	output logic startMelody,
	output logic [3:0] melodySelect
);

localparam [3:0] MELODY_WIN = 4'h1;
localparam [3:0] MELODY_GAME_OVER = 4'h2;
localparam [3:0] MELODY_FOOD_SPECIAL = 4'hD;
localparam [3:0] MELODY_FOOD_SHRINK = 4'h4;
localparam [3:0] MELODY_FOOD_GROW = 4'h5;
localparam [3:0] MELODY_IDLE_BG = 4'hB;
localparam [3:0] NO_MELODY = 4'h0;

food_t last_food_type;
game_state_t last_game_state;
logic last_specialFoodEffect;

// delay pipeline to force melody reset
logic [10:0] delay_counter;
logic [3:0] pending_melody;
logic first_boot;

logic request_trigger;
logic [3:0] requested_melody;

// comb logic: determine if a track change is needed in this clock cycle
always_comb begin
	request_trigger = 1'b0;
	requested_melody = NO_MELODY;

	case (current_state)
		IDLE: begin
			if (last_game_state != IDLE || first_boot) begin
				request_trigger = 1'b1;
				requested_melody = MELODY_IDLE_BG;
			end else if (melodyEnded) begin
				request_trigger = 1'b1;
				requested_melody = MELODY_IDLE_BG;
			end
		end

		PLAY_LVL_1, PLAY_LVL_2, PLAY_LVL_3: begin
			if (last_game_state == IDLE) begin
				request_trigger = 1'b1;
				requested_melody = NO_MELODY; // turn off idle music
			end
			else if (specialFoodEffectEnable != last_specialFoodEffect) begin
				request_trigger = 1'b1;
				requested_melody = specialFoodEffectEnable ? MELODY_FOOD_SPECIAL : NO_MELODY;
			end
			else if (specialFoodEffectEnable == 1'b0 && food_type != NO_FOOD && last_food_type == NO_FOOD) begin
				if (food_type == SHRINK_FOOD) begin
					request_trigger = 1'b1;
					requested_melody = MELODY_FOOD_SHRINK;
				end else if (food_type == GROW_FOOD) begin
					request_trigger = 1'b1;
					requested_melody = MELODY_FOOD_GROW;
				end
			end
		end

		GAME_OVER: begin
			if (last_game_state != GAME_OVER) begin
				request_trigger = 1'b1;
				requested_melody = MELODY_GAME_OVER;
			end
		end

		WIN: begin
			if (last_game_state != WIN) begin
				request_trigger = 1'b1;
				requested_melody = MELODY_WIN;
			end
		end
	endcase
end

// synch logic: pipeline control and sending commands to the player
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		last_food_type <= NO_FOOD; 
		last_game_state <= IDLE;
		last_specialFoodEffect <= 1'b0;
		first_boot <= 1'b1;
		
		melodySelect <= 4'h0;
		startMelody <= 1'b0;
		delay_counter <= 4'd0;
		pending_melody <= 4'h0;

	end else begin
		last_food_type <= food_type; 
		last_game_state <= current_state;
		last_specialFoodEffect <= specialFoodEffectEnable;

		if(startMelody) startMelody <= 1'b0; // impulse is always one clk long

		// If a new event occurred
		if (request_trigger) begin
			first_boot <= 1'b0;
			pending_melody <= requested_melody; // save what needs to be played
			melodySelect <= NO_MELODY;          // mute the current track
			startMelody <= 1'b0;
			delay_counter <= 4'd15;             // start the reset timer (15 clocks)
		end
		
		if (request_trigger) begin
			pending_melody <= requested_melody; 
			melodySelect <= NO_MELODY;          
			startMelody <= 1'b0;
			
			if (first_boot) begin
				delay_counter <= 11'd2000;		// first boot - wait longer to allow proper device start
				first_boot <= 1'b0;
			end else begin
				delay_counter <= 11'd15;   // regular wait
			end
		end
		
		// Process the delay pipeline
		else if (delay_counter > 0) begin
			delay_counter <= delay_counter - 1'b1;
			
			// at 3 cycles remaining, set the new address so ROM has time to read it
			if (delay_counter == 3) begin
				melodySelect <= pending_melody; 
			end
			
			// at 1 cycle remaining, send the start command (player is guaranteed to be reset and ready)
			if (delay_counter == 1) begin
				if (pending_melody != NO_MELODY) begin
					startMelody <= 1'b1; 
				end
			end
		end
	end
end

endmodule