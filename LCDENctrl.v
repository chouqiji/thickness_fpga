///////////////////////////////////////////////////////////////////////////////////
//module name:	LCDENctrl
//file name:	LCDENctrl.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//
//
`timescale 1ns/100ps

module LCDENctrl(
	 input    wire[7:0]    LightScale,
    input    wire			  clk,
	 input	 wire			  reset_n,
	 output	 reg			  LCDen

);

reg    [9:0]    count_clk;

always@(posedge clk or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     count_clk <= 10'd0;
	 end
	 else
	 begin
	     if(count_clk < 10'd999)
		  begin
		      count_clk <= count_clk + 10'd1;
		  end
		  else
		  begin
		      count_clk <= 10'd0;
		  end
    end
end

always@(posedge clk or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     LCDen <= 0;
	 end
	 else
	 begin
	     case(LightScale)
		  1:LCDen       <= (count_clk < 10'd0   );
		  10:LCDen      <= (count_clk < 10'd100 );
		  20:LCDen      <= (count_clk < 10'd200 );
		  30:LCDen      <= (count_clk < 10'd300 );
		  40:LCDen      <= (count_clk < 10'd400 );
		  50:LCDen      <= (count_clk < 10'd500 );
		  60:LCDen      <= (count_clk < 10'd600 );
		  70:LCDen      <= (count_clk < 10'd700 );
		  80:LCDen      <= (count_clk < 10'd800 );
		  90:LCDen      <= (count_clk < 10'd900 );
		  100:LCDen     <= (count_clk < 10'd1000);
		  default:LCDen <= (count_clk < 10'd200 );
		  endcase
    end
end

endmodule
