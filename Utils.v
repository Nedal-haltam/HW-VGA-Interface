
module FiveBit2text
(
	input [4:0] index,
	output [0 : 2 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
assign dig0 = (index % 10) + 8'd48;
assign dig1 = ((index / 10) % 10) + 8'd48;
assign text_index = { dig1, dig0 };

endmodule

module SixTeenBit2text_signed
(
	input [15:0] index,
	output [0 : 6 * 8 - 1] text_index
);


wire [15:0] twoscomp;
assign twoscomp = ~index + 1'b1;


wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;
assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;

wire [7:0] twoscomp_dig0;
wire [7:0] twoscomp_dig1;
wire [7:0] twoscomp_dig2;
wire [7:0] twoscomp_dig3;
wire [7:0] twoscomp_dig4;
assign twoscomp_dig0 = (twoscomp       % 10     ) + 8'd48;
assign twoscomp_dig1 = ((twoscomp / 10) % 10    ) + 8'd48;
assign twoscomp_dig2 = ((twoscomp / 100) % 10   ) + 8'd48;
assign twoscomp_dig3 = ((twoscomp / 1000) % 10  ) + 8'd48;
assign twoscomp_dig4 = ((twoscomp / 10000) % 10 ) + 8'd48;

assign text_index = (index[15]) ? { "-", twoscomp_dig4, twoscomp_dig3, twoscomp_dig2, twoscomp_dig1, twoscomp_dig0 } : { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule

module SixTeenBit2text_unsigned
(
	input [15:0] index,
	output [0 : 6 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;

assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;
assign text_index = { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule


module TwentySixBit2text_unsigned
(
	input [25:0] index,
	output [0 : 6 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;

assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;
assign text_index = { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule

module	Reset_Delay
(
	input		iCLK,
	output reg	oRESET
);

parameter addrw = 19;

reg [addrw: 0] Cont;

always@(posedge iCLK)
begin
	if(Cont!={20{1'b1}})
	begin
		Cont	<=	Cont+1;
		oRESET	<=	1'b0;
	end
	else
	Cont <= 0;
	oRESET	<=	1'b1;
end

endmodule

module bcd7seg (num, display);
	input [3:0] num;
	output [6 : 0] display;

	reg [6 : 0] display;

	always @ (num)
		case (num)
			4'h0: display = 7'b1000000;
			4'h1: display = 7'b1111001;
			4'h2: display = 7'b0100100;
			4'h3: display = 7'b0110000;
			4'h4: display = 7'b0011001;
			4'h5: display = 7'b0010010;
			4'h6: display = 7'b0000010;
			4'h7: display = 7'b1111000;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0010000;
			4'ha: display = 7'b0001000;
			4'hb: display = 7'b0000011;
			4'hc: display = 7'b1000110;
			4'hd: display = 7'b0100001;
			4'he: display = 7'b0000110;
			4'hf: display = 7'b0001110;
			default: display = 7'b1111111;
		endcase
endmodule
