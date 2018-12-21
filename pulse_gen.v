///////////////////////////////////////////////////////////////////////////////////
//module name:	pulse_gen
//file name:	pulse_gen.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//
//

`timescale 1ns/100ps

module    pulse_gen(
	 input	 wire    [9:0]    pulse_period,//��������
	 input	 wire    [5:0]	   pulse_num   ,//��������
    input    wire    clk                  ,
	 input	 wire		RESET_N	            ,
	 input	 wire		burst_syn            ,//ͬ���ź�
	 input	 wire	   protect_en           ,
	 output	 wire		pulse_out
//	output	reg[3:0]			state_wr
//	input		wire[1:0]	AD_sample_flag,
	
	);

    wire    [8:0]    pulse_periodH       ;
	 wire	   [8:0]		pulse_periodL       ;
	 reg	   [31:0]	p_counter           ;
	 reg	   [9:0]		freq_div_counter = 0;
	 reg	   [5:0]		pulse_counter = 0   ;
	 reg	   [3:0]		state_wr = 0        ;									
//	wire [31:0] T_1s;
//	assign T_1s = (AD_sample_flag == 2) ? 32'd100_000_000 : (AD_sample_flag == 1) ? 32'd50_000_000 : 32'd25_000_000;
	 parameter    T_1s       = 32'd100_000_000;
	 parameter	  STATE_IDLE = 3'h0           ,
					  STATE_H	 = 3'h1           ,
					  STATE_L	 = 3'h2           ,
					  STATE_P	 = 3'h3           ,
					  STATE_QUIT = 3'h4           ;
					
always@(posedge clk or negedge RESET_N)
begin
    if(~RESET_N)
	 begin
	     freq_div_counter <= 0 ;
		  pulse_counter <= 0    ;
		  p_counter <= 32'd0    ;
		  state_wr <= STATE_IDLE;
	 end
	 else
	 begin
	     case(state_wr)
		  STATE_IDLE:
				begin
				    freq_div_counter <= 6'h0 ;
					 pulse_counter    <= 4'h0 ;
					 p_counter        <= 32'd0;
					 if(burst_syn)
					 begin
					     state_wr <= STATE_H;
					 end
					 else
					 begin
					     state_wr <= STATE_IDLE;
					 end
				end
        STATE_H:
				begin
				    if(protect_en)
					 begin
					     freq_div_counter <= 6'h0   ;
						  pulse_counter    <= 4'h0   ;
						  p_counter        <= 32'd0  ;
						  state_wr         <= STATE_P;
					 end
					 else if(freq_div_counter >= pulse_periodH - 1)
					 begin
					     state_wr         <= STATE_L;
						  freq_div_counter <= 6'h0   ;
						  p_counter        <= 32'd0  ;
					 end
					 else
					 begin
						  freq_div_counter <= freq_div_counter + 6'h1;
						  p_counter        <= 32'd0                  ;
						  state_wr         <= STATE_H                ;
					 end
				end
        STATE_L:
				begin
					 if(protect_en)
					 begin
					     freq_div_counter <= 6'h0   ;
						  pulse_counter    <= 4'h0   ;
						  p_counter        <= 32'd0  ;
						  state_wr         <= STATE_P;
					 end
					 else if(pulse_counter >= pulse_num - 1)
					 begin
					     p_counter <= 32'd0     ;
						  state_wr  <= STATE_QUIT;
					 end
					 else
					 begin
					     if(freq_div_counter >= pulse_periodL - 1)
						  begin
						      state_wr         <= STATE_H             ;
							   p_counter        <= 32'd0               ;
							   freq_div_counter <= 6'h0                ; 
							   pulse_counter    <= pulse_counter + 6'h1;
						  end
					     else
						  begin
						      state_wr         <= STATE_L                ;
							   p_counter        <= 32'd0                  ;
							   freq_div_counter <= freq_div_counter + 6'h1;
						  end
					 end
				end
        STATE_P:
				begin
				    freq_div_counter <= 6'h0;
					 pulse_counter    <= 4'h0;
					 if(p_counter >= T_1s)
					 begin
					     p_counter <= 32'd0     ;
						  state_wr  <= STATE_IDLE;
					 end
					 else
					 begin
					     p_counter <= p_counter + 32'd1;
						  state_wr <= STATE_P           ;
					 end
				end
        STATE_QUIT:
				begin
				    if(~burst_syn)
					 begin
					     state_wr <= STATE_IDLE;
					 end
					 else
					 begin
					     state_wr <= STATE_QUIT;	
					 end			
				end
        default:
				begin
				    freq_div_counter <= 0         ;
					 pulse_counter    <= 0         ;
					 p_counter        <= 32'd0     ;
					 state_wr         <= STATE_IDLE;
				end
		  endcase
    end
end

    assign    pulse_out     = (state_wr == STATE_H)              ;//��������	
	 assign    pulse_periodH = pulse_period[9:1] + pulse_period[0];
	 assign    pulse_periodL = pulse_period[9:1]                  ;

endmodule

