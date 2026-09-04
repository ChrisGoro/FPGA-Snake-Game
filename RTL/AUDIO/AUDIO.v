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
// CREATED		"Mon Jul 06 19:22:58 2026"

module AUDIO(
	resetN,
	clk,
	volume,
	startMelody,
	AUDIN,
	melodySelect,
	AUDOUT
);


input wire	resetN;
input wire	clk;
input wire	volume;
input wire	startMelody;
input wire	[1:2] AUDIN;
input wire	[3:0] melodySelect;
output wire	[4:7] AUDOUT;

wire	[4:7] AUDOUT_ALTERA_SYNTHESIZED;
wire	en;
wire	[7:0] sinAddr;
wire	[15:0] sinVal;
wire	[11:0] SYNTHESIZED_WIRE_0;
wire	[2:0] SYNTHESIZED_WIRE_1;
wire	[3:0] SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;





audio_codec_controller	b2v_inst(
	.CLOCK31_5(clk),
	.resetN(resetN),
	.AUD_ADCLRCK(AUDIN[1]),
	.AUD_BCLK(AUDIN[2]),
	.AUD_I2C_SDAT(AUDOUT_ALTERA_SYNTHESIZED[7]),
	.dacdata_left(sinVal),
	.dacdata_right(sinVal),
	.AUD_DACDAT(AUDOUT_ALTERA_SYNTHESIZED[4]),
	.AUD_XCK(AUDOUT_ALTERA_SYNTHESIZED[5]),
	.AUD_I2C_SCLK(AUDOUT_ALTERA_SYNTHESIZED[6])
	
	
	);


sintable	b2v_inst1(
	.clk(clk),
	.resetN(resetN),
	.volume(volume),
	.ADDR(sinAddr),
	.Q(sinVal));
	defparam	b2v_inst1.COUNT_SIZE = 8;


prescaler	b2v_inst3(
	.clk(clk),
	.resetN(resetN),
	.preScaleValue(SYNTHESIZED_WIRE_0),
	.slowEnPulse(en)
	);


ToneDecoder	b2v_inst4(
	.octave(SYNTHESIZED_WIRE_1),
	.tone(SYNTHESIZED_WIRE_2),
	.preScaleValue(SYNTHESIZED_WIRE_0));


melody_player_1	b2v_inst5(
	.resetN(resetN),
	.CLOCK_31p5(clk),
	.startMelody(startMelody),
	.melodySelect(melodySelect),
	.EnableSoundOut(SYNTHESIZED_WIRE_3),
	
	.octave(SYNTHESIZED_WIRE_1),
	.tone(SYNTHESIZED_WIRE_2));


addr_counter	b2v_inst9(
	.clk(clk),
	.resetN(resetN),
	.en(SYNTHESIZED_WIRE_3),
	.en1(en),
	.addr(sinAddr));
	defparam	b2v_inst9.COUNT_SIZE = 8;

assign	AUDOUT = AUDOUT_ALTERA_SYNTHESIZED;

endmodule
