// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Intel and sold by Intel or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"
// CREATED		"Sun Jul 05 23:44:56 2026"

module TOP_VGA_DEMO(
	CLOCK_50,
	PS2_CLK,
	PS2_DAT,
	resetN_pin,
	AUDIN,
	KEY,
	redLight,
	yellowLight,
	greenLight,
	boardersDrawReq,
	AUDOUT,
	BG_RGB,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	OVGA
);


input wire	CLOCK_50;
input wire	PS2_CLK;
input wire	PS2_DAT;
input wire	resetN_pin;
input wire	[1:2] AUDIN;
input wire	[3:3] KEY;
output wire	redLight;
output wire	yellowLight;
output wire	greenLight;
output wire	boardersDrawReq;
output wire	[4:7] AUDOUT;
output wire	[7:0] BG_RGB;
output wire	[6:0] HEX0;
output wire	[6:0] HEX1;
output wire	[6:0] HEX2;
output wire	[6:0] HEX3;
output wire	[6:0] HEX4;
output wire	[6:0] HEX5;
output wire	[28:0] OVGA;

wire	[18:0] address;
wire	bg_overlay_dr;
wire	[7:0] BG_OVERLAY_RGB;
wire	[7:0] BG_RGB_ALTERA_SYNTHESIZED;
wire	boardersDrawReq_ALTERA_SYNTHESIZED;
wire	clk;
wire	collision;
wire	collisionSnakeFood;
wire	[1:0] current_level;
wire	[2:0] current_state;
wire	dim_screen_req;
wire	FoodDrawingRequest;
wire	[2:0] foodEaten;
wire	[7:0] foodRGB;
wire	gameFinish;
wire	gameWin;
wire	hit_obstacle;
wire	[9:0] keyIsPressed;
wire	[3:0] keyPad;
wire	keypadValid;
wire	lvl1_win_pulse;
wire	lvl2_win_pulse;
wire	lvl3_win_pulse;
wire	obstacleDrawingRequest;
wire	[224:0] obstacleMatrix;
wire	[7:0] obstacleRGB;
wire	[10:0] pixelX;
wire	[10:0] pixelY;
wire	resetN;
wire	singleHit;
wire	snakeDR;
wire	[3:0] snakeHeadX;
wire	[3:0] snakeHeadY;
wire	[224:0] snakeMatrix;
wire	[7:0] snakeRGB;
wire	specialFoodEffectEnable;
wire	startOfFrame;
wire	[7:0] SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	[3:0] SYNTHESIZED_WIRE_2;
wire	[10:0] SYNTHESIZED_WIRE_3;
wire	[10:0] SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	[7:0] SYNTHESIZED_WIRE_6;
wire	[0:0] SYNTHESIZED_WIRE_9;

assign	redLight = SYNTHESIZED_WIRE_9[0];
assign	yellowLight = SYNTHESIZED_WIRE_9[0];
assign	greenLight = SYNTHESIZED_WIRE_9[0];




VGA_Controller	b2v_inst(
	.clk(clk),
	.resetN(resetN),
	.RGBIn(SYNTHESIZED_WIRE_0),
	.startOfFrame(startOfFrame),
	.address(address),
	.oVGA(OVGA),
	.PixelX(pixelX),
	.PixelY(pixelY));


sound_manager	b2v_inst1(
	.clk(clk),
	.resetN(resetN),
	.key_pressed(keypadValid),
	.food_eaten(singleHit),
	.current_state(current_state),
	.startMelody(SYNTHESIZED_WIRE_1),
	.melodySelect(SYNTHESIZED_WIRE_2));


game_controller	b2v_inst11(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.drawing_request_snake(snakeDR),
	.drawing_request_boarders(boardersDrawReq_ALTERA_SYNTHESIZED),
	.drawing_request_food(FoodDrawingRequest),
	.gameFinish(gameFinish),
	.gameWin(gameWin),
	.foodEaten(foodEaten),
	.NumberKey(keyIsPressed),
	.collision(collision),
	.SingleHitPulse(singleHit),
	
	.lvl1_win_pulse(lvl1_win_pulse),
	.lvl2_win_pulse(lvl2_win_pulse),
	.lvl3_win_pulse(lvl3_win_pulse),
	.specialFoodEffectEnable(specialFoodEffectEnable),
	.current_level(current_level),
	.current_state(current_state));
	defparam	b2v_inst11.SPECIAL_FOOD_EFFECT_DURATION = 375;


TOP_KBD	b2v_inst16(
	.CLOCK_50(clk),
	.resetN(resetN),
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),
	
	
	
	
	
	
	
	
	.keyPadValid(keypadValid),
	.keyIsPressed(keyIsPressed)
	);


MyConstant	b2v_inst17(
	.value(SYNTHESIZED_WIRE_9));
	defparam	b2v_inst17.MyValue = 0;
	defparam	b2v_inst17.size = 1;


AUDIO	b2v_inst18(
	.volume(KEY),
	.clk(clk),
	.resetN(resetN),
	.startMelody(SYNTHESIZED_WIRE_1),
	.AUDIN(AUDIN),
	.melodySelect(SYNTHESIZED_WIRE_2),
	.AUDOUT(AUDOUT));


background	b2v_inst2(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.lvl1_win_pulse(lvl1_win_pulse),
	.lvl2_win_pulse(lvl2_win_pulse),
	.lvl3_win_pulse(lvl3_win_pulse),
	.address(address),
	.current_state(current_state),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.background_dr(boardersDrawReq_ALTERA_SYNTHESIZED),
	.background_overlay_dr(bg_overlay_dr),
	.dim_screen_req(dim_screen_req),
	.BACKGROUND_OVERLAY_RGB(BG_OVERLAY_RGB),
	.BG_RGB(BG_RGB_ALTERA_SYNTHESIZED));


MyConstant	b2v_inst20(
	.value(SYNTHESIZED_WIRE_3));
	defparam	b2v_inst20.MyValue = 0;
	defparam	b2v_inst20.size = 11;


MyConstant	b2v_inst21(
	.value(SYNTHESIZED_WIRE_4));
	defparam	b2v_inst21.MyValue = 0;
	defparam	b2v_inst21.size = 11;

assign	SYNTHESIZED_WIRE_5 =  ~resetN_pin;


Food_Obstacle_Display	b2v_inst4(
	.startOfFrame(startOfFrame),
	.singleHit(singleHit),
	.clk(clk),
	.resetN(resetN),
	.current_level(current_level),
	.current_state(current_state),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.snakeHeadX(snakeHeadX),
	.snakeHeadY(snakeHeadY),
	.snakeMatrix(snakeMatrix),
	.topLeftX(SYNTHESIZED_WIRE_3),
	.topLeftY(SYNTHESIZED_WIRE_4),
	.FoodDrawingRequest(FoodDrawingRequest),
	.obstacleDrawingRequest(obstacleDrawingRequest),
	.hit_obstacle(hit_obstacle),
	.foodEaten(foodEaten),
	.foodRGB(foodRGB),
	
	.obstacleRGB(obstacleRGB));


ALL_HEXSS	b2v_inst5(
	.clk(clk),
	.resetN(resetN),
	
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5));


Snake_Block	b2v_inst6(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.up_direction_key(keyIsPressed[8]),
	.down_direction_key(keyIsPressed[2]),
	.left_direction_key(keyIsPressed[4]),
	.right_direction_key(keyIsPressed[6]),
	.collision(collision),
	.hit_obstacle(hit_obstacle),
	.speed_boost_enable(specialFoodEffectEnable),
	.current_state(current_state),
	.foodEaten(foodEaten),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.gameFinish(gameFinish),
	.snakeDR(snakeDR),
	.gameWin(gameWin),
	.snakeHeadX(snakeHeadX),
	.snakeHeadY(snakeHeadY),
	.snakeMatrix(snakeMatrix),
	.snakeRGB(snakeRGB));
	defparam	b2v_inst6.initial_x = 280;
	defparam	b2v_inst6.initial_x_speed = 60;
	defparam	b2v_inst6.initial_y = 185;
	defparam	b2v_inst6.initial_y_speed = 20;


CLK_31P5	b2v_inst7(
	.refclk(CLOCK_50),
	.rst(SYNTHESIZED_WIRE_5),
	.outclk_0(clk),
	.locked(resetN));


Spotlight_mask	b2v_inst8(
	.clk(clk),
	.resetN(resetN),
	.enableSpotlight(specialFoodEffectEnable),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.RGB(SYNTHESIZED_WIRE_6),
	.snakeHeadX(snakeHeadX),
	.snakeHeadY(snakeHeadY),
	.RGBout(SYNTHESIZED_WIRE_0));
	defparam	b2v_inst8.INNER_SPOTLIGHT_RADIUS = 90;
	defparam	b2v_inst8.OUTER_SPOTLIGHT_RADIUS = 128;
	defparam	b2v_inst8.SNAKE_MATRIX_SIZE = 32;


objects_mux	b2v_inst9(
	.clk(clk),
	.resetN(resetN),
	.snakeDrawingRequest(snakeDR),
	.obstacleDrawingRequest(obstacleDrawingRequest),
	.FoodDrawingRequest(FoodDrawingRequest),
	.BGDrawingRequest(boardersDrawReq_ALTERA_SYNTHESIZED),
	.bgGameWinDr(bg_overlay_dr),
	.dim_screen_req(dim_screen_req),
	.backGroundRGB(BG_RGB_ALTERA_SYNTHESIZED),
	.bgGameWinRGB(BG_OVERLAY_RGB),
	.foodRGB(foodRGB),
	.obstacleRGB(obstacleRGB),
	.pixelX(pixelX),
	.snakeRGB(snakeRGB),
	.RGBOut(SYNTHESIZED_WIRE_6));

assign	boardersDrawReq = boardersDrawReq_ALTERA_SYNTHESIZED;
assign	BG_RGB = BG_RGB_ALTERA_SYNTHESIZED;

endmodule
