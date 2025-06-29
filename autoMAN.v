
`include "Defs.txt"
module autoMAN
(
	input iVGA_CLK, iRST_n, 
	input enable, 
	input cHS, cVS, 
	output reg [3*`COLOR_WIDTH - 1: 0] RGB_out
);


parameter width =  `RS * `CHAR_WIDTH * `WIDTH_IN_CHARS;
parameter height = `RS * `CHAR_HEIGHT * `HEIGHT_IN_CHARS;

wire [3*`COLOR_WIDTH - 1: 0] RGB_temp;

wire [0 : `MAXIMUM_NUMBER_OF_CHARS * 8 - 1] Buffer = "Hello-World int x = 213 |hi|";

reg [15:0] addrx, addry;
always@(posedge iVGA_CLK, negedge iRST_n) 
begin

if (!iRST_n)
begin
   addrx <= 0;
   addry <= 0;
end	
else if (cHS==1'b0 && cVS==1'b0)
begin
   addrx <= 0;
   addry <= 0;
end
else if (enable == 1'b1) begin
  if (addrx == width - 1)
  begin 
     addrx <= 0;
     if (addry == height - 1)
        addry <= 0;
     else
        addry <= addry + 1;
  end
  else
     addrx <= addrx + 1;
end


end

//  0 -> 25 : `A` -> `Z`
// 26 -> 51 : `a` -> `z`
// 52 -> 61 : `0` -> `9`
// 62 -> 64	: `=`, `|`, `-`

wire [7:0] data [0 : `MAXIMUM_NUMBER_OF_CHARS - 1'b1];

wire [7:0] index, address;
assign address = addrx / 30 + `WIDTH_IN_CHARS*(addry / 40);
generate
    genvar j;
    for (j = 0; j < `MAXIMUM_NUMBER_OF_CHARS; j = j + 1) begin : required_block_name
		assign data[j] = Buffer[8*(j) -: 8];
    end
endgenerate

always@(posedge iVGA_CLK) begin
	RGB_out <= (address >= `MAXIMUM_NUMBER_OF_CHARS || data[address] == `terminating_char || data[address] == 0 || data[address] == " ") ? 12'd0 : 
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


endmodule


module char2index
(
	input  [7:0] in_char,
	output [7:0] out_index
);


assign out_index = 
(in_char == "-") ? 8'd64 :
(
	(in_char == "=") ? 8'd62 : 
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
;

endmodule