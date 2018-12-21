///////////////////////////////////////////////////////////////////////////////////
//module name:	PowerDown
//file name:	PowerDown.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//
//
`timescale 1ns/100ps

module PowerDown(
    input    wire    RESET_N      ,
    input 	 wire 	clk_sys      ,
	 input 	 wire 	pow_key_det  ,
	 input 	 wire 	ARM_powdn_cmd,
	 output 	 wire 	powen_sys
	
);

    reg    [31:0]    pow_key_det_cnt  = 0;
	 reg    [31:0] 	powdn_delay_cnt  = 0;
	 reg    [16:0] 	div_cnt          = 0;
	 reg 			      FPGA_powdn_cmd   = 0;
	 reg 			      Sys_powdn_r      = 0;
	 reg 			      powdn_cnt_puls   = 0;
	 reg              pow_key_det_buf1 = 0;
	 reg              pow_key_det_buf2 = 0;	
	
always @(posedge clk_sys)
begin
    if(!RESET_N)
	 begin
	     div_cnt        <= 0;
		  powdn_cnt_puls <= 0;
	 end
	 if(div_cnt<80_000)
	 begin
	     div_cnt        <= div_cnt+1'b1;
		  powdn_cnt_puls <= 0           ;
	 end
	 else                                //if(div_cnt>=80_000)
	     begin
		      div_cnt        <= 0;
				powdn_cnt_puls <= 1;
		  end
    end	
	
always @(posedge clk_sys)
    begin
	 if(!RESET_N)
	 begin
	     pow_key_det_cnt <= 0;
		  FPGA_powdn_cmd  <= 0;
		  Sys_powdn_r     <= 0; 
	 end
	 else if(powdn_cnt_puls)
	 begin
	     pow_key_det_buf1 <= pow_key_det            ;
		  pow_key_det_buf2 <= pow_key_det_buf1       ;
	 if({pow_key_det_buf2,pow_key_det_buf1} == 2'b00)
	 begin
	     pow_key_det_cnt <= pow_key_det_cnt + 32'b1 ;
		  if(pow_key_det_cnt > 5_000)
		      FPGA_powdn_cmd <= 1                    ;
	 end
		  else
		      pow_key_det_cnt <= 0;
		  if(ARM_powdn_cmd || FPGA_powdn_cmd)
				powdn_delay_cnt <= powdn_delay_cnt+1'b1;
		  else
				powdn_delay_cnt <= powdn_delay_cnt     ;
		  if(powdn_delay_cnt > 1_000)	
				Sys_powdn_r <= 0                       ;
		  else
				Sys_powdn_r <= 1                       ;				
    end
end	
	
assign    powen_sys = Sys_powdn_r;

endmodule


