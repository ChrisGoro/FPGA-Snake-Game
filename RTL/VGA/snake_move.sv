import game_pkg::*; // game package including global state machine states and important parameters

module snake_move (	
    input  logic clk,
    input  logic resetN,
    input  logic startOfFrame,        // 75 Hz
    input  logic up_direction_key,    
    input  logic down_direction_key,  
    input  logic left_direction_key,  
    input  logic right_direction_key, 
    
    input  food_t foodEaten,
	 
	 input  logic [224:0] obstacleMatrix,
    
    input  game_state_t current_state, 
	 
	 input  logic speed_boost_enable,
    
    output logic gameFinish,
    
    output logic [10:0] topLeftX, 
    output logic [10:0] topLeftY,

    output logic [224:0] snakeMatrix,
    output logic [3:0] snakeHeadX,
    output logic [3:0] snakeHeadY,
	 
	 output dir_t current_dir,
	 
	 output logic gameWin,
	 
	 output logic [5:0] snake_length,
	 
	 output logic snakeCry			// changes snake head bit map when snake "dead"
);

localparam int MATRIX_HEIGHT = 15;
localparam int MATRIX_WIDTH = 15;

localparam int FRAMES_PER_UPDATE = 18; 
localparam int HALF_SPEEDUP_FRAMES_PER_UPDATE = 14; 
localparam int SPEEDUP_FRAMES_PER_UPDATE = 9; 
localparam int SPEEDDOWN_FRAMES_PER_UPDATE = 22;

localparam logic [7:0] DEFAULT_POS = { 4'd7, 4'd7 };

localparam logic [5:0] DEFAULT_SNAKE_LENGTH = 6'd7;
localparam logic [5:0] MIN_SNAKE_LENGTH = 6'd2;
localparam logic [5:0] MAX_SNAKE_LENGTH = 6'd32;

localparam logic [5:0] HALF_SPEEDUP_SNAKE_LENGTH = 6'd5;		// after this length snakes moves with HALF_SPEEDUP speed
localparam logic [5:0] SPEEDUP_SNAKE_LENGTH = 6'd2;			// after this length snakes moves with SPEEDUP speed
localparam logic [5:0] SPEEDDOWN_SNAKE_LENGTH = 6'd10;		// after this length snakes moves with SPEEDDOWN speed

dir_t next_dir;


logic [5:0] frame_counter;

logic [3:0] snakeTailX;
logic [3:0] snakeTailY;

food_t food_type;

logic [7:0] snakeMatrixQueue [0:224];

logic can_move;

logic [7:0] current_tail_idx;
logic [7:0] current_head_idx;

logic [3:0] next_tail_x;		// the coordinates of next tail segment
logic [3:0] next_tail_y;
logic [7:0] next_tail_idx;		// the index of the next tail segment

logic [3:0] next_head_x;		// the coordinates of next head segment
logic [3:0] next_head_y;
logic [7:0] next_head_idx;		// the index of the next head segment

logic [5:0] active_frames_per_update; // Dynamically changes speed


always_comb begin		
	current_tail_idx = (snakeTailX * MATRIX_HEIGHT) + snakeTailY;
	current_head_idx = (snakeHeadX * MATRIX_HEIGHT) + snakeHeadY;
	
	next_tail_x = snakeMatrixQueue[current_tail_idx][7:4];
	next_tail_y = snakeMatrixQueue[current_tail_idx][3:0];
	next_tail_idx = (next_tail_x * MATRIX_HEIGHT) + next_tail_y;
	
	can_move = ((next_dir == DIR_UP)    && (snakeHeadY > 0)) ||
                  ((next_dir == DIR_DOWN)  && (snakeHeadY < MATRIX_HEIGHT - 1)) ||
                  ((next_dir == DIR_LEFT)  && (snakeHeadX > 0)) ||
                  ((next_dir == DIR_RIGHT) && (snakeHeadX < MATRIX_WIDTH - 1));
						
	topLeftX = {7'b0, snakeHeadX} << 5;
	topLeftY = {7'b0, snakeHeadY} << 5;
	
	
	if(speed_boost_enable) active_frames_per_update = SPEEDUP_FRAMES_PER_UPDATE;		// full speedup
	else if(snake_length >= SPEEDDOWN_SNAKE_LENGTH) active_frames_per_update = SPEEDDOWN_FRAMES_PER_UPDATE;		// speed down
	else if(snake_length < SPEEDDOWN_SNAKE_LENGTH && snake_length > HALF_SPEEDUP_SNAKE_LENGTH) active_frames_per_update = FRAMES_PER_UPDATE;		// regular speed
	else if(snake_length <= HALF_SPEEDUP_SNAKE_LENGTH && snake_length > SPEEDUP_SNAKE_LENGTH) active_frames_per_update = HALF_SPEEDUP_FRAMES_PER_UPDATE;		// half speedup
	else active_frames_per_update = SPEEDUP_FRAMES_PER_UPDATE;		// full speedup
	
	
	case(next_dir)
		DIR_UP: begin
			next_head_x = snakeHeadX;
			next_head_y = snakeHeadY - 1;
		end
		
		DIR_DOWN: begin
			next_head_x = snakeHeadX;
			next_head_y = snakeHeadY + 1;
		end
		
		DIR_LEFT: begin
			next_head_x = snakeHeadX - 1;
			next_head_y = snakeHeadY;
		end
		
		DIR_RIGHT: begin
			next_head_x = snakeHeadX + 1;
			next_head_y = snakeHeadY;
		end
		
		default: begin
        next_head_x = snakeHeadX;
        next_head_y = snakeHeadY;
		end
	
	endcase
	
	next_head_idx = (next_head_x * MATRIX_HEIGHT) + next_head_y;

end

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
	 
		  snakeHeadX <= DEFAULT_POS[7:4];
		  snakeHeadY <= DEFAULT_POS[3:0];
		  
		  snakeTailX <= DEFAULT_POS[7:4] - 3'd6;
		  snakeTailY <= DEFAULT_POS[3:0];

		  //spawn snake with length of 7
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 1) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4], DEFAULT_POS[3:0] };
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 2) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 1'd1, DEFAULT_POS[3:0] };
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 3) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 2'd2, DEFAULT_POS[3:0] };
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 4) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 2'd3, DEFAULT_POS[3:0] };
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 5) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 3'd4, DEFAULT_POS[3:0] };
		  snakeMatrixQueue[(DEFAULT_POS[7:4] - 6) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 3'd5, DEFAULT_POS[3:0] };

		  snakeMatrix <= (225'b1 << ((DEFAULT_POS[7:4] - 1) * MATRIX_HEIGHT + DEFAULT_POS[3:0])) |
                       (225'b1 << ((DEFAULT_POS[7:4] - 2) * MATRIX_HEIGHT + DEFAULT_POS[3:0]));
		  
        frame_counter <= 0;
        current_dir <= DIR_UP;
        next_dir    <= DIR_UP;
		  
		  food_type <= NO_FOOD;
		  snake_length <= DEFAULT_SNAKE_LENGTH;
		  
		  snakeCry <= 1'b0;
    end 
    else begin
        
        if (up_direction_key    && current_dir != DIR_DOWN)  next_dir <= DIR_UP;
        if (down_direction_key  && current_dir != DIR_UP)    next_dir <= DIR_DOWN;
        if (left_direction_key  && current_dir != DIR_RIGHT) next_dir <= DIR_LEFT;
        if (right_direction_key && current_dir != DIR_LEFT)  next_dir <= DIR_RIGHT;
		  
		  if ( (current_state == PLAY_LVL_1 || current_state == PLAY_LVL_2 || current_state == PLAY_LVL_3)
				&& foodEaten != NO_FOOD) 	// save short foodEaten signal	
            food_type <= foodEaten;

        if (startOfFrame) begin
            
				case(current_state)
					
					IDLE: begin
						
						snakeHeadX <= DEFAULT_POS[7:4];
					   snakeHeadY <= DEFAULT_POS[3:0];
					  
					   snakeTailX <= DEFAULT_POS[7:4] - 3'd6;		// TODO: Change magic number 3'd6 to parameter DEFAULT_SNAKE_LENGTH
					   snakeTailY <= DEFAULT_POS[3:0];

					   //spawn snake with length of 7
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 1) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4], DEFAULT_POS[3:0] };
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 2) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 1'd1, DEFAULT_POS[3:0] };
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 3) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 2'd2, DEFAULT_POS[3:0] };
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 4) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 2'd3, DEFAULT_POS[3:0] };
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 5) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 3'd4, DEFAULT_POS[3:0] };
					   snakeMatrixQueue[(DEFAULT_POS[7:4] - 6) * MATRIX_HEIGHT + DEFAULT_POS[3:0]] <= { DEFAULT_POS[7:4] - 3'd5, DEFAULT_POS[3:0] };

					   snakeMatrix <= (225'b1 << ((DEFAULT_POS[7:4] - 1) * MATRIX_HEIGHT + DEFAULT_POS[3:0])) |
                                    (225'b1 << ((DEFAULT_POS[7:4] - 2) * MATRIX_HEIGHT + DEFAULT_POS[3:0]));
					  
					   frame_counter <= 0;
					   current_dir <= DIR_UP;
					   next_dir    <= DIR_UP;
						
						food_type <= NO_FOOD;
						snake_length <= DEFAULT_SNAKE_LENGTH;
						
						snakeCry <= 1'b0;
					end
					
					PLAY_LVL_1, PLAY_LVL_2, PLAY_LVL_3: begin	// game is currently played - all snake movement logic is here
						if(frame_counter >= active_frames_per_update) begin
							frame_counter <= 0;
							current_dir <= next_dir;
                
							if(can_move == 1'b1		// border collision
								&&	snakeMatrix[current_head_idx] == 1'b0 		// snake body collision
								&& obstacleMatrix[next_head_idx] == 1'b0		// obstacle collision
								&& snake_length >= MIN_SNAKE_LENGTH 	// reached min length 
							) begin
							
								case (next_dir)
								  DIR_UP: begin
								  
										snakeHeadY <= snakeHeadY - 1'd1;				
										snakeMatrixQueue[current_head_idx] <= { snakeHeadX, snakeHeadY - 1'd1};
								  end
								  
								  DIR_DOWN: begin 
								  
										snakeHeadY <= snakeHeadY + 1'd1;						
										snakeMatrixQueue[current_head_idx] <= { snakeHeadX, snakeHeadY + 1'd1};
								  end
								  
								  DIR_LEFT: begin 
								  
										snakeHeadX <= snakeHeadX - 1'd1;						
										snakeMatrixQueue[current_head_idx] <= { snakeHeadX - 1'd1, snakeHeadY };
								  end
								  
								  DIR_RIGHT: begin

										snakeHeadX <= snakeHeadX + 1'd1;						
										snakeMatrixQueue[current_head_idx] <= { snakeHeadX + 1'd1, snakeHeadY };
								  end
								endcase
								
								
								case(food_type) 	// define snake movement according to eaten food type
								
									NO_FOOD: begin		// no food eaten
									
										snakeTailX <= snakeMatrixQueue[current_tail_idx][7:4];		// save new tail coords
										snakeTailY <= snakeMatrixQueue[current_tail_idx][3:0];		// save new tail coords
					 
										snakeMatrix[current_head_idx] <= 1'b1;			// add next body segment
										
										snakeMatrixQueue[current_tail_idx] <= 7'd0; 		// clear prev tail pos
										snakeMatrix[current_tail_idx] <= 1'b0; 			// clear prev tail pos
									
									end
									
									SHRINK_FOOD: begin		// shrink food 
									
										snakeTailX <= snakeMatrixQueue[next_tail_idx][7:4];    // take next tail X pos from matrix
                              snakeTailY <= snakeMatrixQueue[next_tail_idx][3:0];    // take next tail y pos from matrix
										
										snakeMatrix[current_head_idx] <= 1'b1;		// add next body segment 
										
										snakeMatrixQueue[next_tail_idx] <= 7'd0;
										snakeMatrixQueue[current_tail_idx] <= 7'd0;        // clear both tail queue spots
										snakeMatrix[next_tail_idx] <= 1'b0;
										snakeMatrix[current_tail_idx] <= 1'b0;        // clear tail spot
										
										snake_length <= snake_length - 1;	// decrease snake length
										
										food_type <= NO_FOOD;		// clear eaten food type
										
									end
									
									GROW_FOOD: begin		// grow food
										
										snakeMatrix[current_head_idx] <= 1'b1;		// add next body segment
										
										snake_length <= snake_length + 1;	// increase snake length
										
										food_type <= NO_FOOD;		// clear eaten food type
										
									end
									
									SPECIAL_FOOD: begin // SPECIAL FOOD
										snakeTailX <= snakeMatrixQueue[current_tail_idx][7:4];
										snakeTailY <= snakeMatrixQueue[current_tail_idx][3:0];		
										snakeMatrix[current_head_idx] <= 1'b1;
										snakeMatrixQueue[current_tail_idx] <= 7'd0; 		
										snakeMatrix[current_tail_idx] <= 1'b0;
										 
										food_type <= NO_FOOD;
										
									end
																		
								endcase
								
						 
							end else begin
								if(snake_length < MIN_SNAKE_LENGTH) begin
									gameWin <= 1'b1;
									snakeCry <= 1'b1;
								end
								else gameFinish <= 1'b1;
							end
							
						end else begin
							frame_counter <= frame_counter + 1;
						end
					
					end
					
					GAME_OVER: begin
						gameFinish <= 1'b0;
						gameWin <= 1'b0;
						food_type <= NO_FOOD;
						snakeCry <= 1'b0;
					end
					
					WIN: begin
						gameFinish <= 1'b0;
						gameWin <= 1'b0;
						food_type <= NO_FOOD;
						snakeCry <= 1'b1;
					end
					
				endcase
        end
    end 
end

endmodule
