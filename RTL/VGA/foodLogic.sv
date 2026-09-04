import game_pkg::*;		// game package including global state machine states and important parameters

module FoodLogic (	
    input  logic clk,
    input  logic resetN,
    input  logic addNewFood, 
    
    input  logic [7:0] randIn,
    input  logic [224:0] snakeMatrix,
	 input  logic [224:0] obstacleMatrix,
    
    input  logic singleHit, // ONLY FOR FOOD COLLISIONS
    input  logic [3:0] snakeHeadX,
    input  logic [3:0] snakeHeadY,
	 
	 input  game_state_t current_state,
	 
	 output food_t foodEaten,
    output logic [224:0][2:0] foodMatrix
);

logic [7:0] targetIndex;
logic [7:0] eraseIndex;
logic [1:0] foodPending;
logic speedFoodPending;

logic [3:0] safeX;
logic [3:0] safeY;

logic [3:0] shrinkFoodCount;
logic [3:0] growFoodCount;
logic [3:0] speedFoodCount;

localparam logic [3:0] MAX_SHRINK_FOOD = 4'd4;
localparam logic [3:0] MAX_GROW_FOOD = 4'd10;
localparam logic [3:0] MAX_SPEED_FOOD = 4'd1;

assign safeX = (randIn[7:4] == 4'd15) ? 4'd14 : randIn[7:4]; 
assign safeY = (randIn[3:0] == 4'd15) ? 4'd14 : randIn[3:0]; 

assign targetIndex = (safeX * 8'd15) + safeY; 
assign eraseIndex = (snakeHeadX * 8'd15) + snakeHeadY; 
 
 // State machine for spawning
typedef enum logic [2:0] {
    IDLE_FOOD, 
    WAIT_FOR_HIT, 
    SPAWN_SHRINK, 
    SPAWN_GROW,
	 SPAWN_SPECIAL
} food_state_t;

food_state_t spawn_state;

always_ff@(posedge clk or negedge resetN) begin
    if(!resetN) begin
        foodMatrix <= '{default: NO_FOOD};
        spawn_state <= IDLE_FOOD;
        shrinkFoodCount <= 4'd0;
		  growFoodCount <= 4'd0;
		  speedFoodCount <= 4'd0;
        foodEaten <= NO_FOOD;
    end else begin
        
        if(current_state == IDLE) begin // current_state from game_controller
            foodMatrix <= '{default: NO_FOOD};
            spawn_state <= SPAWN_SHRINK; // Initial spawn when game starts
            shrinkFoodCount <= 4'd0;
				growFoodCount <= 4'd0;
				speedFoodCount <= 4'd0;
        end 
        else begin
            
				if(addNewFood == 1'b1) begin	// save the pulse to add new bonus food
					speedFoodPending <= 1'b1;
				end

            // COLLISION DETECTION 
            if(singleHit == 1'b1) begin 
				
                foodEaten <= food_t'(foodMatrix[eraseIndex]); // Send type to snake_move

					 if(foodMatrix[eraseIndex] == SHRINK_FOOD) begin
						  shrinkFoodCount <= shrinkFoodCount - 1'b1;	// eaten shrink food -> lower it's count
					 end
					 
					 if(foodMatrix[eraseIndex] == GROW_FOOD) begin
						  growFoodCount <= growFoodCount - 1'b1;	// eaten grow food -> lower it's count
					 end
					 
					 if(foodMatrix[eraseIndex] == SPECIAL_FOOD) begin
						  speedFoodCount <= speedFoodCount - 1'b1;
					 end
					 
                foodMatrix[eraseIndex] <= NO_FOOD;             // erase food
                
                // If we hit food, we want to spawn 2 more (if under limit)
                if(shrinkFoodCount < MAX_SHRINK_FOOD || foodMatrix[eraseIndex] == SHRINK_FOOD) begin 
						 spawn_state <= SPAWN_SHRINK;
                end else if (growFoodCount < MAX_GROW_FOOD || foodMatrix[eraseIndex] == GROW_FOOD) begin
                   spawn_state <= SPAWN_GROW;
                end else begin
						 spawn_state <= WAIT_FOR_HIT;
					 end
				end
            
            // SPAWNING LOGIC
            else begin
                // Clear the foodEaten signal after 1 clock cycle so we don't keep eating
                foodEaten <= NO_FOOD; 

                case(spawn_state)
                    WAIT_FOR_HIT: begin	// take care of bonus food while waiting for singleHit	  
                        if(speedFoodPending == 1'b1) begin
									if(speedFoodCount < MAX_SPEED_FOOD) begin
										spawn_state <= SPAWN_SPECIAL;
									end
									
									speedFoodPending <= 1'b0; 
								end
						  end
                    
						  SPAWN_SHRINK: begin
                        if(snakeMatrix[targetIndex] == 1'b0 && foodMatrix[targetIndex] == NO_FOOD && 
									obstacleMatrix[targetIndex] == 1'b0 && {snakeHeadX, snakeHeadY} != targetIndex) begin 
									
                            foodMatrix[targetIndex] <= SHRINK_FOOD; 
                            shrinkFoodCount <= shrinkFoodCount + 1'b1;

									 //  prevent getting stuck if grow food is already maxed out
									 if(growFoodCount < MAX_GROW_FOOD) begin
										  spawn_state <= SPAWN_GROW;      
									 end else begin
 										  spawn_state <= WAIT_FOR_HIT;
									 end
                        end
                    end
						  
                    SPAWN_GROW: begin
                        if(snakeMatrix[targetIndex] == 1'b0 && foodMatrix[targetIndex] == NO_FOOD &&
									obstacleMatrix[targetIndex] == 1'b0 && {snakeHeadX, snakeHeadY} != targetIndex) begin
									
                            foodMatrix[targetIndex] <= GROW_FOOD; 
                            growFoodCount <= growFoodCount + 1'b1;
                            spawn_state <= WAIT_FOR_HIT;      // Done spawning, wait for next hit
									 
                        end
                    end
						  
						  SPAWN_SPECIAL: begin
								if(snakeMatrix[targetIndex] == 1'b0 && foodMatrix[targetIndex] == NO_FOOD &&
									obstacleMatrix[targetIndex] == 1'b0 && {snakeHeadX, snakeHeadY} != targetIndex) begin 
									
									 foodMatrix[targetIndex] <= SPECIAL_FOOD; 
									 speedFoodCount <= speedFoodCount + 1'b1;
									 spawn_state <= WAIT_FOR_HIT;      
									 
								end
						  end
                    
                endcase
            end
        end
    end
end

endmodule
