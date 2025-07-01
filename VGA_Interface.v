

`include "Defs.txt"

module VGA_Interface(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_R,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_B,
	output		          		VGA_HS,
	output		          		VGA_VS,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N
);
`define BUFFER_LEN 6
`define CLK_BIT 15

wire VGA_CLK, DLY_RST;

Reset_Delay reset
(
	.iCLK(MAX10_CLK1_50),
	.oRESET(DLY_RST)
);

VGA_PLL vga_pll
(
	.areset(~DLY_RST),
	.inclk0(MAX10_CLK1_50),
	.c0(VGA_CLK)
);

VGA_controller VGA_CTRL
(
	.iVGA_CLK(VGA_CLK), 
	.iRST_n(DLY_RST), 
	.AutoMan_StaticImage(1'b0),
	.AdvanceCursor(~KEY[0]),
	.KeyboardInput(SW[7:0]),

	.r_data(VGA_R),
	.g_data(VGA_G),
	.b_data(VGA_B),
	
	.oHS(VGA_HS),
	.oVS(VGA_VS)
);

assign ARDUINO_RESET_N = 1'b1;

endmodule
