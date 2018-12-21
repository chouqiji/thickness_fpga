///////////////////////////////////////////////////////////////////////////////////
//module name:	ARM_interface
//file name:	ARM_interface.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//负责FPGA与ARM之间的数据传输以及报警
//
`timescale 1ns/100ps

module ARM_interface(
	input    wire    signed    [31:0]    CoderPosition,
	input 	wire    [7:0]     ARM_A                  ,
	inout 	wire    [15:0]    ARM_D                  ,
	input    wire    [9:0]     ARM_read_fifo_data     ,
	input    wire    [9:0]     ARM_MAX_data           ,
	output 	reg     [7:0] 	   LightScale             ,
	output 	reg     [2:0] 	   burst_period           ,
	output 	reg     [9:0]   	pulse_period           ,
	output 	reg     [5:0]   	pulse_num              ,
	output 	reg     [11:0]	   gain_codeA             ,
	output 	reg     [1:0] 	   AD_sample_flag         ,
	input 	wire 			      clk_sys                ,
	input 	wire 			      clk_coder              ,
	input 	wire 			      RESET_N                ,
	input 	wire 			      iARM_CE_N              ,
	input 	wire 			      iARM_OE_N              ,
	input 	wire 			      iARM_WE_N              ,
	input    wire              ARM_data_ready         ,
	input    wire              SensorOK_en            ,
	input    wire 			      protect_en             ,
	output 	wire 			      alarm_buzzer           ,
	output   wire              ARM_read_fifo_rdreq    ,
	output 	reg 			      ARM_powdn_cmd          ,
	output   reg               ARM_read_over          ,
	output   reg               PositionClear_n        ,
	output   reg               alarm_en
	
);
	wire clk_2hz;
	reg [23:0] count_clk;
	 wire  		      ARM_read         ;
	 wire             ARM_read_fifo_clk;
    wire 				AlarmPicture_en; 
    reg    [15:0]    ARM_read_data    ;
    reg 			      ARM_read_buf  = 0;
    reg 			      ARM_read_buf2 = 0;
	
always @ (posedge clk_sys)
    begin
	     if(!RESET_N)
		  begin
				ARM_read_buf  <= 0;
				ARM_read_buf2 <= 0;
		  end
		  else 
		  begin
		      ARM_read_buf  <= ARM_read    ;
				ARM_read_buf2 <= ARM_read_buf;
		  end
    end

always@(*)                 //组合逻辑采用
    begin
	 case(ARM_A[7:2])         //组合逻辑一律用“=”
	     6'h20   : ARM_read_data = {6'd0,ARM_read_fifo_data}             ;
		  6'h21   : ARM_read_data = {14'h0,AlarmPicture_en,ARM_data_ready};
		  6'h22   : ARM_read_data = CoderPosition[15:0]                   ;
		  6'h23   : ARM_read_data = CoderPosition[31:16]                  ;
		  6'h30   : ARM_read_data = {6'd0,ARM_MAX_data}                   ;
		  default : ARM_read_data = 0                                     ;
	 endcase
	 end
	
always@(posedge iARM_WE_N)
    begin
	     if(!iARM_CE_N)                  //ARM checked
	     begin
		  case(ARM_A[7:2])                 // 
		      6'h00:burst_period[  2:0] <= ARM_D[ 2:0];
				6'h01:AD_sample_flag[1:0] <= ARM_D[ 1:0];
				6'h03:pulse_period[  9:0] <= ARM_D[ 9:0];
				6'h04:pulse_num[     5:0] <= ARM_D[ 5:0];
				6'h05:gain_codeA[   11:0] <= ARM_D[11:0];
				6'h06:LightScale[    7:0] <= ARM_D[ 7:0];
				6'h08:PositionClear_n     <= ARM_D[   0];
				6'h0C:ARM_read_over       <= ARM_D[	  0];
				6'h0D:ARM_powdn_cmd       <= ARM_D[	  0];
				6'h0E:alarm_en            <= ARM_D[	  0];
				default:;
        endcase
		  end
    end
	
always@(posedge clk_coder or negedge RESET_N)
    begin
	     if(~RESET_N)
		  begin
		      count_clk <= 24'd0;
		  end
		  else
		  begin
		      if(count_clk < 24'd2000000)
			   begin
				    count_clk <= count_clk + 24'd1;
			   end
			   else
			   begin
			       count_clk <= 24'd0;
			   end
        end
    end
	 
    assign    AlarmPicture_en     = protect_en | (~SensorOK_en)                  ;
	 assign    ARM_read_fifo_rdreq = (!ARM_read_buf2) & ARM_read_buf&ARM_A[7] & (!ARM_A[6]) & (!ARM_A[5]) & (!ARM_A[4]) & (!ARM_A[3]) & (!ARM_A[2]);
	 assign    alarm_buzzer        = clk_2hz & protect_en & SensorOK_en & alarm_en;
	 assign    ARM_read            = ~iARM_CE_N & ~iARM_OE_N                      ;
	 assign    ARM_D               = ARM_read ? ARM_read_data : 16'hzzzz          ;
    assign    clk_2hz             = (count_clk < 24'd500000) ? 1'b1 : 1'b0       ;	

endmodule	
	
	
	
	
	
	
	
	