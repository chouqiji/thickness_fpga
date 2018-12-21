///////////////////////////////////////////////////////////////////////////////////
//module name:	burst_syn_ctrl
//file name:	burst_syn_ctrl.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//电磁超声信号处理模块
//
`timescale 1ns/100ps

module    signal_pro(
	 input	 wire    [9:0]    AD_data_in         ,
	 input	 wire    [2:0]    burst_period       ,
	 input	 wire    [9:0]	   pulse_period       ,
    input    wire			      clk                , 
	 input	 wire			      reset_n            ,
	 input	 wire			      AD_data_valid      ,
	 input 	 wire             ARM_read_fifo_clk  ,
	 input    wire			      ARM_read_fifo_rdreq,
	 input 	 wire             ARM_read_over      ,
	 output	 wire    [9:0]	   ARM_read_fifo_data ,
	 output	 wire    [9:0]	   ARM_MAX_data       ,
	 output	 wire 			   ARM_data_ready

);	

    wire    [9:0]    filter_data     ;
	 wire    [9:0]    Avg_data        ;
    wire	            fif0_wrreq      ;
    wire	            fifo_empty      ;
    wire	            fifo_full       ;
    wire	            fifo_aclr       ;
	 wire    [9:0]    fif0_data_in    ;
	 reg     [9:0]    MAX_tmp = 0     ;
	 reg     [9:0]    MAX_data_reg = 0;
	 reg     [15:0]   DataNum = 0     ;
	 wire    [15:0]   dead_num        ;
	
highpass    U_highpass(
    .Clock(clk)         ,
	 .Input1(AD_data_in) ,
	 .Output(filter_data),
	 .aclr(AD_data_valid)
	 
	 );
//assign filter_data = AD_data_in;
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// 信号处理部分;
// 对信号进行平均处理，以消除噪声；
// 测厚：取半轴信号；探伤：取信号包络；	
Average    U1_Average(
     .clk			 (clk				),
	  .reset_n		 (reset_n		),
	  .data_in_valid(AD_data_valid),
	  .data_in		 (filter_data  ),
	  .burst_period (burst_period ),	
	  .dout_enable  (ARM_read_over),
	  .dout			 (Avg_data		),
	  .armfifo_full (fifo_full		),
	  .armfifo_aclr (fifo_aclr		),
	  .armfifo_wrreq(fif0_wrreq	)
		
    );		
	
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//FIFO存数据----------------------------------------	
//FIFO数据为空之后，才能把整串数据写进FIFO
fifo_8192X10b result_fifo(
    .wrclk  (clk						 ),
	 .rdclk  (ARM_read_fifo_clk	 ),
	 .aclr   (!reset_n || fifo_aclr),
	 .data   (fif0_data_in			 ),
	 .wrreq  (fif0_wrreq				 ),
	 .rdreq  (ARM_read_fifo_rdreq	 ),
	 .rdempty(fifo_empty				 ),
	 .wrfull (fifo_full				 ),
	 .q      (ARM_read_fifo_data	 )
	
	);
//assign fifo_aclr = ARM_read_over & (~AD_data_valid);
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//最大值提取----------------------------------------
//	 reg    armfifo_full_buf = 0;
always@(posedge clk)
begin
    if(!reset_n) 
	 begin
	     MAX_tmp      <= 0   ;
		  MAX_data_reg <= 0   ;
		  DataNum      = 16'd0;
	 end
	 else
	 begin
			//armfifo_full_buf <= armfifo_full;
	     if(fifo_aclr) 
		  begin
		      MAX_tmp <= 0;
				DataNum = 16'd0;
		  end
		      else if(fif0_wrreq)
			   begin
			       if(burst_period == 7)
			       begin
			           DataNum = DataNum + 16'd1;
				        if((dead_num < DataNum <= 3000) & (MAX_tmp < fif0_data_in))
				        begin
				            MAX_tmp <= fif0_data_in;
				        end
				        else 
				        begin
				            MAX_tmp <= MAX_tmp;
				        end
			       end
			       else
			       begin
			           MAX_data_reg <= MAX_tmp;
			       end
			   end
            else if(burst_period != 7)
			   begin
			       DataNum = DataNum + 16'd1;
				    if((DataNum > dead_num) & (MAX_tmp < fif0_data_in))
				    begin
				        MAX_tmp <= fif0_data_in;
				    end
				    else
				    begin
				        MAX_tmp <= MAX_tmp;
				    end
			   end
			   else
			   begin
			       MAX_data_reg <= MAX_tmp;
			   end
        end
//if (fif0_wrreq&&({armfifo_full_buf,armfifo_full} == 2'b01)) //fifo满的时候更新最大值
//if ({armfifo_full_buf,armfifo_full} == 2'b01) //fifo满的时候更新最大值
//MAX_data_reg <= MAX_tmp;
end
    assign    dead_num       = (pulse_period == 25) ? 16'd550: 16'd1000;
    assign    fif0_data_in   = Avg_data                                ;
    assign    ARM_data_ready = fifo_full                               ;
    assign    ARM_MAX_data   = MAX_data_reg                            ;

endmodule                   