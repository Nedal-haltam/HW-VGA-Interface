
`include "Defs.txt"

module video_sync_generator
(
   input reset,
   input vga_clk,
   output reg blank_n,
   output reg HS,
   output reg VS,
   output DataSource
);

////////////////////////////////
parameter resx = 128;
parameter resxbar = 640 - resx;
////////////////////////////////
parameter resy = 96;
parameter resybar = 480 - resy;
////////////////////////////////
parameter H_sync_cycle = 96;
parameter hori_back  = 144;
parameter hori_line  = 800;
////////////////////////////////
parameter V_sync_cycle = 2;
parameter vert_back  = 35;
parameter vert_line  = 525;
////////////////////////////////
parameter hori_front = 16;
parameter vert_front = 10;
////////////////////////////////
parameter startx = hori_back;
parameter starty = vert_back;
parameter endx   = startx    + (`WIDTH_IN_CHARS  * `CHAR_WIDTH * `RS);
parameter endy   = starty    + (`HEIGHT_IN_CHARS * `CHAR_HEIGHT * `RS);



//////////////////////////
reg [10:0] h_cnt;
reg [9:0]  v_cnt;
wire cHD,cVD,cDEN,hori_valid,vert_valid;
///////
always@(negedge vga_clk,posedge reset)
begin
  if (reset)
  begin
     h_cnt<=11'd0;
     v_cnt<=10'd0;
  end
    else
    begin
      if (h_cnt==hori_line-1)
      begin 
         h_cnt<=11'd0;
         if (v_cnt==vert_line-1)
            v_cnt<=10'd0;
         else
            v_cnt<=v_cnt+1;
      end
      else
         h_cnt<=h_cnt+1;
    end
end 
/////
assign cHD = ~((h_cnt) < H_sync_cycle);
assign cVD = ~((v_cnt) < V_sync_cycle);


assign DataSource = h_cnt >= startx && h_cnt < endx && v_cnt >= starty && v_cnt < endy;

// these valid flags are high when we should output our data to the monitor and increament our addr in the memory
assign hori_valid = h_cnt >= hori_back && h_cnt < (hori_line-hori_front);
assign vert_valid = v_cnt >= vert_back && v_cnt < (vert_line-vert_front);

// this is the blank_n
assign cDEN = hori_valid && vert_valid;

always@(negedge vga_clk)
begin
  HS<=cHD;
  VS<=cVD;
  blank_n<=cDEN;
end

endmodule


