
`include "Defs.txt"
module autoMAN
(
	input iVGA_CLK, iRST_n, 
	input enable, 
	input cHS, cVS, 
	input AdvanceCursor,
	input [7:0] KeyboardInput,
	output reg [3*`COLOR_WIDTH - 1: 0] RGB_out
);

parameter width =  `RS * `CHAR_WIDTH * `WIDTH_IN_CHARS;
parameter height = `RS * `CHAR_HEIGHT * `HEIGHT_IN_CHARS;

reg [24:0] halfclk;
reg [7:0] data [0 : `MAXIMUM_NUMBER_OF_CHARS - 1];
reg [31:0] Cursor;
reg [15:0] addrx, addry;

wire [3*`COLOR_WIDTH - 1: 0] RGB_temp;
wire [7:0] index, address, KeyboardInputIndex;

always@(posedge iVGA_CLK, negedge iRST_n) begin
	if (!iRST_n) begin
		addrx <= 0;
		addry <= 0;
	end	
	else if (cHS==1'b0 && cVS==1'b0) begin
		addrx <= 0;
		addry <= 0;
	end
	else if (enable == 1'b1) begin
		if (addrx == width - 1) begin 
			addrx <= 0;
			if (addry == height - 1) addry <= 0;
			else addry <= addry + 1;
		end
		else addrx <= addrx + 1;
	end
end

//  0 -> 25 : `A` -> `Z`
// 26 -> 51 : `a` -> `z`
// 52 -> 61 : `0` -> `9`
// 62 -> 64	: `=`, `|`, `-`

char2index KeyboardInput_C2I
(
	.in_char(KeyboardInput),
	.out_index(KeyboardInputIndex)
);


`define ResetScreen Cursor = 0; \
data[0] = "|"

`define PrintChar(c) data[Cursor] = c; \
data[Cursor + 1'b1] = "|"; \
Cursor = Cursor + 1'b1


always@(posedge AdvanceCursor) begin
	if (KeyboardInput == 8'h7F && Cursor > 0) begin
		Cursor = Cursor - 1'b1;
		data[Cursor] = "|";
	end
	else if (0 <= Cursor && Cursor < `MAXIMUM_NUMBER_OF_CHARS - 1) begin
		if (KeyboardInput == 8'h00) begin
			`ResetScreen;
		end
		else if (KeyboardInputIndex != 8'hFF || KeyboardInput == " ") begin
			`PrintChar(KeyboardInput);
		end
	end
end

always@(posedge iVGA_CLK) begin
	halfclk <= halfclk + 1'b1;
end

// always@(posedge halfclk[24]) begin
// 	`PrintChar("1");
// end



always@(posedge iVGA_CLK) begin
	RGB_out <= ((address == Cursor && halfclk >= (1 << 24)) || address > Cursor || address >= `MAXIMUM_NUMBER_OF_CHARS || data[address] == `terminating_char || data[address] == 0 || data[address] == " ") ? 12'd0 : 
	(
		(index == 8'hFF) ? 12'd0 : RGB_temp
	);
end

char2index C2I
(
	.in_char(data[address]),
	.out_index(index)
);

CharMap cmap
(
	.address 
	(
		(
			(index) * 48
		) + 

		(
			((addrx/`RS) % (`CHAR_WIDTH))
		) + 

		(
			(((addry/`RS) % (`CHAR_HEIGHT))*6)
		)
	),
	
	.clock ( ~iVGA_CLK ),
	.q ( RGB_temp )
);

assign address = addrx / 30 + `WIDTH_IN_CHARS*(addry / 40);

endmodule


module char2index
(
	input  [7:0] in_char,
	output [7:0] out_index
);


assign out_index = 
(in_char == "=") ? 8'd62 : 
(
	(in_char == "|") ? 8'd63 : 
	(
		(in_char == "-") ? 8'd64 : 
		(
			("a" <= in_char && in_char <= "z") ? (26 + (in_char - "a")) : 
			(
				("A" <= in_char && in_char <= "Z") ? (in_char - "A") : 
				(
					("0" <= in_char && in_char <= "9") ? (52 + (in_char - "0")) : 8'hFF
				)
			)
		)
	)
)
;

endmodule