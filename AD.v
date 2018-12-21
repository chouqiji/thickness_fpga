///////////////////////////////////////////////////////////////////////////////////
//module name:	AD
//file name:	Ad.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//AD采样使能
//
`timescale    1ns/100ps

module    AD(
    input    wire    clk_100,
	 input 	 wire 	RESET_N,
	 input    wire    reset_n,
	 input 	 wire 	clk_100_delay,
	 input 	 wire 	burst_syn,
	 input 	 wire    [1:0]	   AD_sample_flag,
	 output	 reg 	   AD_sample_en,
	 output	 wire 	AD_data_valid,
	 output	 wire		clk_sample,
	 output   wire    clk_sample_delay,
	 output   wire    oAD0_CLK
	 //input	 wire		clk_sample,
	 
);

	reg    clk_50;
	reg    clk_25;
	reg    clk_50_delay;
	reg    clk_25_delay;
	reg    [15:0]   counter;
	reg    [1:0]    state; 
	
always@(posedge clk_100 or negedge RESET_N)
    begin
	     if(~RESET_N)
		  begin
		      clk_50 <= 0;
		  end
		  else
		  begin
		      clk_50 <= ~clk_50;
		  end
    end

always@(posedge clk_50 or negedge RESET_N)
    begin
	     if(~RESET_N)
		  begin
		      clk_25 <= 0;
		  end
		  else
		  begin
		      clk_25 <= ~clk_25;
		  end
    end

always@(posedge clk_100_delay or negedge RESET_N)
    begin
	     if(~RESET_N)
		  begin
		      clk_50_delay <= 0;
		  end
		  else
		  begin
		      clk_50_delay <= ~clk_50_delay;
		  end
    end

always@(posedge clk_50_delay or negedge RESET_N)
    begin
	     if(~RESET_N)
		  begin
		      clk_25_delay <= 0;
		  end
		  else
		  begin
		      clk_25_delay <= ~clk_25_delay;
		  end
    end
		
	parameter    STATE_IDLE	  = 2'd0,
					 STATE_SAMPLE = 2'd1,
					 STATE_QUIT	  = 2'd2;			

always@(posedge clk_sample or negedge reset_n)
    begin
	     if(~reset_n)
		  begin
		      AD_sample_en <= 0;
			   counter      <= 0;
			   state        <= STATE_IDLE;
		  end
		  else
		  begin
		      case(state)
				STATE_IDLE:
				begin
				    if(burst_syn)
					 begin
					     AD_sample_en <= 1;
						  counter      <= 0;
						  state        <= STATE_SAMPLE;
					 end
					 else
					 begin
					     AD_sample_en <= 0;
						  counter      <= 0;
						  state        <= STATE_IDLE;
					 end
				end
				STATE_SAMPLE:
				begin
			       if(counter < 8191)
					 begin
					     AD_sample_en <= 1;
						  counter      <= counter + 13'b1;
						  state        <= STATE_SAMPLE;
					 end
					 else
					 begin
					     AD_sample_en <= 0;
						  counter      <= 0;
						  state        <= STATE_QUIT;
					 end
				end
				STATE_QUIT:
				begin
				    if(~burst_syn)
					 begin
					     AD_sample_en <= 0;
						  counter      <= 0;
						  state        <= STATE_IDLE;
					 end
					 else
					 begin
					     AD_sample_en <= 0;
						  counter      <= 0;
						  state        <= STATE_QUIT;
					 end
				end
				default:
				begin
			       AD_sample_en <= 0;
					 counter      <= 0;
					 state        <= STATE_IDLE;
				end
			   endcase
        end
	 end

	assign clk_sample       = (AD_sample_flag == 2) ? clk_100 : (AD_sample_flag == 1) ? clk_50 : clk_25;
	assign clk_sample_delay = (AD_sample_flag == 2) ? clk_100_delay : (AD_sample_flag == 1) ? clk_50_delay : clk_25_delay;
	assign oAD0_CLK         = clk_sample_delay & AD_sample_en;
	assign AD_data_valid    = AD_sample_en;

endmodule
