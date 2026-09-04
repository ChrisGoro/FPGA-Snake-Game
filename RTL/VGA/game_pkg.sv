/*

	Global game package file
	includes global state machine states
	and important parameters

*/

package game_pkg;


typedef enum logic [2:0] { IDLE, PLAY_LVL_1, PLAY_LVL_2, PLAY_LVL_3, WIN, GAME_OVER } game_state_t;

typedef enum logic [1:0] { DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT } dir_t;

typedef enum logic [2:0] { NO_FOOD, SHRINK_FOOD, GROW_FOOD, SPECIAL_FOOD } food_t;


endpackage