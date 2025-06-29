


`include "Defs.txt"

module VGA_controller
(
	input iVGA_CLK,
	input iRST_n,
	input AutoMan_StaticImage,
	input AdvanceCursor,
	input [7:0] KeyboardInput,

	output [`COLOR_WIDTH - 1:0] r_data,
	output [`COLOR_WIDTH - 1:0] g_data,
	output [`COLOR_WIDTH - 1:0] b_data,
	
	output reg oHS,
	output reg oVS
);

parameter addrw = 19;

reg  [3*`COLOR_WIDTH - 1: 0] RGB_Data;
reg [addrw:0] tempADDRx;
reg [addrw:0] tempADDRy;
reg [addrw:0] ADDR;


wire [addrw:0] FINAL_ADDR;
wire DataSource;
wire [3*`COLOR_WIDTH - 1: 0] RGB_Static, RGB_Auto;
wire cBLANK_n,cHS,cVS;

////
video_sync_generator VSG 
(
	.vga_clk(iVGA_CLK),
	.reset(~iRST_n),
	.blank_n(cBLANK_n),
	.HS(cHS),
	.VS(cVS),
	.DataSource(DataSource)
);

////
////Addresss generator
always@(posedge iVGA_CLK , negedge iRST_n) 
begin

if (!iRST_n) 
	ADDR <= 0; 
else if (cHS==1'b0 && cVS==1'b0) 
	ADDR <= 0;
else if (cBLANK_n==1'b1)
	ADDR <= ADDR + 1;

end

always@(posedge iVGA_CLK , negedge iRST_n) begin
// ADDR = 0 -> 307200
// tempADDRx = 0 -> 127
// tempADDRy = 0 -> 95
if (!iRST_n)
begin
   tempADDRx <= 0;
   tempADDRy <= 0;
end	
else if (cHS==1'b0 && cVS==1'b0)
begin
   tempADDRx <= 0;
   tempADDRy <= 0;
end	

else if (cBLANK_n == 1'b1)
begin
  if (tempADDRx == `WIDTH - 1)
  begin 
     tempADDRx <= 0;
     if (tempADDRy == `HEIGHT - 1)
        tempADDRy <= 0;
     else
        tempADDRy <= tempADDRy + 1;
  end
  else
     tempADDRx <= tempADDRx + 1;
end

end

//////////////////////////////////////////////////////////////////////////////
ImageStatic IMG
(
	.address ( FINAL_ADDR ),
	.clock ( iVGA_CLK ),
	.q ( RGB_Static )
);
//////////////////////////////////////////////////////////////////////////////
autoMAN automan
(
	.iVGA_CLK(iVGA_CLK), 
	.iRST_n(iRST_n),
	.enable(DataSource),
	.cHS(cHS),
	.cVS(cVS),
	.AdvanceCursor(AdvanceCursor),
	.KeyboardInput(KeyboardInput),
	.RGB_out(RGB_Auto)
);

always@(negedge iVGA_CLK) begin
	if (AutoMan_StaticImage) begin
		RGB_Data <= RGB_Static;
	end
	else if (DataSource) begin
		RGB_Data <= RGB_Auto;
	end
	else begin
		RGB_Data <= 12'h000;
	end
end

assign r_data = (~cBLANK_n) ? 0 : RGB_Data[1*`COLOR_WIDTH - 1: 0*`COLOR_WIDTH];
assign g_data = (~cBLANK_n) ? 0 : RGB_Data[2*`COLOR_WIDTH - 1: 1*`COLOR_WIDTH];
assign b_data = (~cBLANK_n) ? 0 : RGB_Data[3*`COLOR_WIDTH - 1: 2*`COLOR_WIDTH];
assign FINAL_ADDR = (tempADDRx / `RS) + (tempADDRy / `RS)*(`WIDTH / `RS);
///////////////////////////////////////////////////////////////////////////////////////////////////

//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
end

endmodule
