///////////////////////////////////////////////////////////////////////////////////
//module name:	burst_syn_ctrl
//file name:	burst_syn_ctrl.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//
//
`timescale 1ns/100ps	

module burst_syn_ctrl(
    input    wire[2:0]    burst_period ,           //0=>0hz 1=>25hz 2=>50hz 3=>100hz 4=>200hz 5=>400hz 6=>800hz 7=>10kHz(test)
	 input	 wire			  clk_100      ,
	 input	 wire			  reset_n	   ,         
	 output	 wire		     burst_syn    ,		          //
	 output	 reg		     pulsedMega_HV,		       //
	 output	 reg		     pulsedMega_tirgger		 //

	);

    reg    [29:0]    clk_div_num        ;//100M
	 reg	  [29:0] 	clk_div_couunter   ; 	
	 reg    [15:0]    count              ;
	 reg    [1:0]     state              ;
	 reg    [15:0]    count1             ;
	 reg    [1:0]     state1             ;
	 reg				   burst_syn_tmp_sec  ;
	 reg              burst_syn_tmp      ;
	 wire             burst_syn_tmp_first;
	 
//	parameter	burst_period 	= 3'd7;
//！！！注意：高压充电信号持续时间和重复频率之间的关系，如果高压充电信号持续时间是1S，那么重复频率大于1Hz的话，高压充电信号就连续了！
    parameter    repeat_freq 	               = 30'd100_000_000; //重复频率1Hz,时钟100MHz  
	 parameter	  HV_duration 	               = 30'd90_000_000 ; //高压充电持续时间1s,时钟100MHz
	 parameter	  pulsedMega_tirgger_delay    = 16'd5000       ; //脉冲触发信号延迟50us,时钟100MHz
	 parameter    pulsedMega_width            = 16'd4000       ; 
	 parameter	  burst_syn_delay 	         = 16'd24000      ; //脉冲触发信号延迟200us,时钟100MHz
	 parameter	  pulsedMega_tirgger_duration = burst_syn_delay + pulsedMega_width; //脉冲触发信号持续240us,时钟100MHz
//------------------------------------------------------
//	Repeat Freq Control 
//------------------------------------------------------
always@(posedge clk_100 or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     clk_div_num <= 0;
	 end
	 else
	 begin
	     case(burst_period)
		      0:clk_div_num <= 0          ;	//0hz
				1:clk_div_num <= 4000000    ; //����������	25hz,100Mϵͳʱ�ӣ���Ҫ4000000�η�Ƶ
				2:clk_div_num <= 2000000    ;//����������	50hz,100Mϵͳʱ�ӣ���Ҫ2000000�η�Ƶ
				3:clk_div_num <= 1000000    ;//����������	100hz,100Mϵͳʱ�ӣ���Ҫ1000000�η�Ƶ
				4:clk_div_num <= 500000     ;//����������	200hz,100Mϵͳʱ�ӣ���Ҫ500000�η�Ƶ
//				4:clk_div_num <= repeat_freq;//����������	2
				5:clk_div_num <= 250000     ;//����������	400hz,100Mϵͳʱ�ӣ���Ҫ250000�η�Ƶ
				6:clk_div_num <= 125000     ;//����������	800hz,100Mϵͳʱ�ӣ���Ҫ125000�η�Ƶ
				7:clk_div_num <= repeat_freq;
		  endcase
    end
end
//------------------------------------------------------
//	pulsedMega_HV Control Signal
//------------------------------------------------------
always@(posedge clk_100 or negedge reset_n)
begin	 
    if(~reset_n)
	 begin
	     clk_div_couunter  <= 0;
		  pulsedMega_HV     <= 0;
		  burst_syn_tmp_sec <= 0;
	 end
	 else if(clk_div_num == 0)
	     begin
		      pulsedMega_HV     = 1'b0;
			   burst_syn_tmp_sec = 1'b0;
		  end
	 else
	 begin
	     if(clk_div_couunter >= (clk_div_num - 1))
		  begin
		      clk_div_couunter <= 0;
		  end
		  else
		  begin
				clk_div_couunter <= clk_div_couunter + 1'b1;
		  end
		      burst_syn_tmp_sec <= (clk_div_couunter > (clk_div_num - 50));
			   pulsedMega_HV     <= (burst_period == 7) ? ((clk_div_couunter > (clk_div_num - HV_duration))) : 1'b0;
    end
end	
//------------------------------------------------------
//	pulsedMega_tirgger Control Signal
//------------------------------------------------------	
always@(posedge clk_100 or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     pulsedMega_tirgger <= 0    ;
		  count              <= 16'h0;
		  state              <= 0    ;
	 end
	 else
	 begin
	    case(state)
        0:
		      begin
			      if(pulsedMega_HV)
			      begin
					    pulsedMega_tirgger <= 0    ;
						 count              <= 16'h0;
						 state              <= 1    ;
					end
					else
					begin
						 pulsedMega_tirgger <= 0    ;
						 count              <= 16'h0;
						 state              <= 0    ;
					end
			   end
        1:
		      begin
				    if(~pulsedMega_HV)
					 begin
					     pulsedMega_tirgger <= 0    ;
						  count              <= 16'h0;
						  state              <= 2    ;
					 end
					 else
					 begin
					     pulsedMega_tirgger <= pulsedMega_tirgger;
						  count              <= count             ;
						  state              <= 1                 ;
					 end
				end
        2:
				begin
				    if(count < pulsedMega_tirgger_delay)
					 begin
					     pulsedMega_tirgger <= 0            ;
						  count              <= count + 16'h1;
						  state              <= 2            ;
					 end
					 else         
					 begin         
					     pulsedMega_tirgger <= 1    ;
						  count              <= 16'h0;
						  state              <= 3    ;
					 end
				end
        3:
				begin
				    if(count < pulsedMega_tirgger_duration)
					 begin
					     pulsedMega_tirgger <= 1            ;
						  count              <= count + 16'h1;
						  state              <= 3            ;
					 end
					 else
					 begin
					     pulsedMega_tirgger <= 0    ;
						  count              <= 16'h0;
						  state              <= 0    ;
					 end
				end
        default:
		      begin
				    pulsedMega_tirgger <= 0    ;
					 count              <= 16'h0;
					 state              <= 0    ;
				end
	     endcase
    end
end
//------------------------------------------------------
//	burst_syn Control Signal
//------------------------------------------------------	
always@(posedge clk_100 or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     burst_syn_tmp <= 0    ;
		  count1        <= 16'h0;
		  state1        <= 0    ;
	 end
	 else
	 begin
	     case(state1)
		  0:
		      begin
				    if(pulsedMega_tirgger)
					 begin
					     burst_syn_tmp <= 0    ;
						  count1        <= 16'h0;
						  state1        <= 1    ;
					 end
					 else
					 begin
					     burst_syn_tmp <= 0    ;
						  count1        <= 16'h0;
						  state1        <= 0    ;
					 end
				end
        1:
		      begin
				    if(count1 < burst_syn_delay)
					 begin
					     burst_syn_tmp <= 0             ;
						  count1        <= count1 + 16'h1;
						  state1        <= 1             ;
					 end
					 else
					 begin
					     burst_syn_tmp <= 1    ;
						  count1        <= 16'h0;
						  state1        <= 2    ;
					 end
				end
        2:
				begin
					 if(count1 < 16'd50)
					 begin
					     burst_syn_tmp <= 1             ;
						  count1        <= count1 + 16'h1;
						  state1        <= 2             ;
					 end
					 else
					 begin
					     burst_syn_tmp <= 0    ;
						  count1        <= 16'h0;
						  state1        <= 3    ;
					 end
				end
		  3:
				begin
				    if(pulsedMega_tirgger)
					 begin
					     burst_syn_tmp <= 0    ;
						  count1        <= 16'h0;
						  state1        <= 3    ;
					 end
					 else
					 begin
						  burst_syn_tmp <= 0    ;
						  count1        <= 16'h0;
						  state1        <= 0    ;
					 end
				end
        default:
		      begin
				    burst_syn_tmp <= 0    ;
					 count1        <= 16'h0;
					 state1        <= 0    ;
				end
        endcase
    end
end
	
    assign    burst_syn_tmp_first = burst_syn_tmp;
	 assign    burst_syn           = (burst_period == 7) ? burst_syn_tmp_first : burst_syn_tmp_sec;

endmodule
	
//	reg[21:0] clk_div_couunter_sec;	
//	reg	burst_syn_tmp_sec;//���崮ͬ��
//	always@(posedge clk_100 or negedge reset_n)
//	begin
//	  
//		if(~reset_n)
//		begin
//			clk_div_couunter_sec <= 0;
//			burst_syn_tmp_sec <= 0;
//		end
//		else if(clk_div_num == 0)
//		begin
//			burst_syn_tmp_sec = 1'b0;
//		end
//		else
//		begin
//			if(clk_div_couunter_sec >= (clk_div_num-1))
//			begin
//				clk_div_couunter_sec <= 0;
//			end
//			else
//			begin
//				clk_div_couunter_sec <= clk_div_couunter_sec + 1'b1;
//			end
//			burst_syn_tmp_sec <= (clk_div_couunter_sec > (clk_div_num-50));
//		end
//		
//		
//	end

	
//	//������ͬ���ź�
//	reg	burst_syn_test = 0	;//���崮ͬ��
//	reg[13:0] burst_syn_test_counter = 0;
//	always@(posedge clk_100)
//	begin
//		if(~reset_n)
//		begin
//			burst_syn_test_counter <= 0;
//			burst_syn_test <= 0;//��ʱ�������ź�
//		end
//		else
//		begin
//			burst_syn_test_counter <= burst_syn_test_counter + 1'b1;
//			burst_syn_test <= (burst_syn_test_counter < 50);//��ʱ�������ź�
//		end
//	end
//	
//	assign burst_syn = (burst_period == 7) ? burst_syn_test : burst_syn_tmp_sec;


