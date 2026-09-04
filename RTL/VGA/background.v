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
// CREATED		"Sun Jul 05 19:26:53 2026"

module background(
	clk,
	resetN,
	startOfFrame,
	lvl1_win_pulse,
	lvl2_win_pulse,
	lvl3_win_pulse,
	address,
	current_state,
	pixelX,
	pixelY,
	background_dr,
	dim_screen_req,
	bg_game_win_dr,
	BG_GAME_WIN_RGB,
	BG_RGB
);


input wire	clk;
input wire	resetN;
input wire	startOfFrame;
input wire	lvl1_win_pulse;
input wire	lvl2_win_pulse;
input wire	lvl3_win_pulse;
input wire	[18:0] address;
input wire	[2:0] current_state;
input wire	[10:0] pixelX;
input wire	[10:0] pixelY;
output wire	background_dr;
output wire	dim_screen_req;
output wire	bg_game_win_dr;
output wire	[7:0] BG_GAME_WIN_RGB;
output wire	[7:0] BG_RGB;

wire	bg_game_over_dr;
wire	[7:0] BG_GAME_OVER_RGB;
wire	bg_game_win_dr_internal;
wire	[7:0] BG_GAME_WIN_RGB_internal;
wire	current_combined_req;
wire	[7:0] current_combined_RGB;
wire	dim_screen_req_game_over;
wire	dim_screen_req_game_win;
wire	game_over_draw;
wire	game_win_combined_req;
wire	[7:0] game_win_combined_RGB;
wire	game_win_draw;
wire	lvl1_combined_req;
wire	[7:0] lvl1_combined_RGB;
wire	lvl2_combined_req;
wire	[7:0] lvl2_combined_RGB;
wire	lvl3_combined_req;
wire	[7:0] lvl3_combined_RGB;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	[7:0] SYNTHESIZED_WIRE_7;
wire	[7:0] SYNTHESIZED_WIRE_8;
wire	[7:0] SYNTHESIZED_WIRE_9;





back_ground_draw	b2v_inst(
	.clk(clk),
	.resetN(resetN),
	.draw(SYNTHESIZED_WIRE_0),
	.address(address),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.boardersDrawReq(SYNTHESIZED_WIRE_4),
	.BG_RGB(SYNTHESIZED_WIRE_7)
	);


start_screen_draw	b2v_inst1(
	.clk(clk),
	.resetN(resetN),
	.draw(SYNTHESIZED_WIRE_1),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.bg_start_dr(SYNTHESIZED_WIRE_5),
	.BG_START_RGB(SYNTHESIZED_WIRE_9));

assign	dim_screen_req = dim_screen_req_game_over | dim_screen_req_game_win;

assign	bg_game_win_dr = bg_game_over_dr | game_win_combined_req | bg_game_win_dr_internal;

assign	BG_GAME_WIN_RGB = BG_GAME_OVER_RGB | game_win_combined_RGB | BG_GAME_WIN_RGB_internal;


game_over_draw	b2v_inst13(
	.clk(clk),
	.resetN(resetN),
	.draw(game_over_draw),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.bg_game_over_dr(bg_game_over_dr),
	.dim_screen_req(dim_screen_req_game_over),
	.BG_GAME_OVER_RGB(BG_GAME_OVER_RGB));


game_win_draw	b2v_inst2(
	.clk(clk),
	.resetN(resetN),
	.draw(game_win_draw),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.bg_game_win_dr(bg_game_win_dr_internal),
	.dim_screen_req(dim_screen_req_game_win),
	.BG_GAME_WIN_RGB(BG_GAME_WIN_RGB_internal));


scores_info_draw	b2v_inst3(
	.clk(clk),
	.resetN(resetN),
	.draw(SYNTHESIZED_WIRE_2),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.bg_scores_info_dr(SYNTHESIZED_WIRE_6),
	.BG_SCORES_INFO_RGB(SYNTHESIZED_WIRE_8));


background_logic	b2v_inst4(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.current_state(current_state),
	.background_draw(SYNTHESIZED_WIRE_0),
	.start_screen_draw(SYNTHESIZED_WIRE_1),
	.game_over_draw(game_over_draw),
	.scores_info_draw(SYNTHESIZED_WIRE_2),
	.game_win_score_digits_draw(SYNTHESIZED_WIRE_3),
	.game_win_draw(game_win_draw));


Score_Display	b2v_inst5(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.lvl1_win_pulse(lvl1_win_pulse),
	.game_win_score_draw(SYNTHESIZED_WIRE_3),
	.lvl2_win_pulse(lvl2_win_pulse),
	.lvl3_win_pulse(lvl3_win_pulse),
	.current_state(current_state),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.lvl1_combined_req(lvl1_combined_req),
	.current_combined_req(current_combined_req),
	.lvl2_combined_req(lvl2_combined_req),
	.game_win_combined_req(game_win_combined_req),
	.lvl3_combined_req(lvl3_combined_req),
	.current_combined_RGB(current_combined_RGB),
	.game_win_combined_RGB(game_win_combined_RGB),
	.lvl1_combined_RGB(lvl1_combined_RGB),
	.lvl2_combined_RGB(lvl2_combined_RGB),
	.lvl3_combined_RGB12(lvl3_combined_RGB));


background_mux	b2v_inst8(
	.clk(clk),
	.resetN(resetN),
	.background_dr(SYNTHESIZED_WIRE_4),
	.bg_start_dr(SYNTHESIZED_WIRE_5),
	.bg_game_win_dr(bg_game_win_dr_internal),
	.bg_scores_info_dr(SYNTHESIZED_WIRE_6),
	.bg_game_over_dr(bg_game_over_dr),
	.current_score_dr(current_combined_req),
	.game_win_score_dr(game_win_combined_req),
	.lvl1_high_score_dr(lvl1_combined_req),
	.lvl2_high_score_dr(lvl2_combined_req),
	.lvl3_high_score_dr(lvl3_combined_req),
	.BG_GAME_OVER_RGB(BG_GAME_OVER_RGB),
	.BG_GAME_WIN_RGB(BG_GAME_WIN_RGB_internal),
	.BG_RGB(SYNTHESIZED_WIRE_7),
	.BG_SCORES_INFO_RGB(SYNTHESIZED_WIRE_8),
	.BG_START_RGB(SYNTHESIZED_WIRE_9),
	.CURRENT_SCORE_RGB(current_combined_RGB),
	.GAME_WIN_SCORE_RGB(game_win_combined_RGB),
	.LVL1_HIGH_SCORE_RGB(lvl1_combined_RGB),
	.LVL2_HIGH_SCORE_RGB(lvl2_combined_RGB),
	.LVL3_HIGH_SCORE_RGB(lvl3_combined_RGB),
	.bg_dr_out(background_dr),
	.BG_RGB_OUT(BG_RGB));


endmodule
