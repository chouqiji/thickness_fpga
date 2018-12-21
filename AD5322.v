///////////////////////////////////////////////////////////////////////////////////
//module name:	AD5322
//file name:	Ad5322.v
//time:			2018-3-16
//compant:	   orisonic
//======Introduction=======
//the driver of AD5322
//give the ChannelA_data and ChannelB_data,then put en to "1"
module    AD5322(
	 input    [11:0]    ChannelA_data,
	 input    [11:0]    ChannelB_data,
    input    wire      clk,          //less than 150MHz
	 input    wire      RESET_N,
	 input    wire      en,
	 output   sclk,
	 output   dout,
	 output   sync_n,
	 output   ldac_n	
	);
	
	reg    [15:0]    buffer_A = 0;
	reg    [15:0]    buffer_B = 0;
	reg    [5:0]     cnt      = 0;
	reg    [3:0]     sclk_cnt    ;
	reg    [2:0]     state_test  ;
	reg              dout_r   = 0;
	reg              sync_n_r = 0;
	reg              ldac_n_r = 0;
	
always@( posedge clk or negedge RESET_N) 
    begin
	     if(!RESET_N) 
		  begin
		      sclk_cnt <= 0;
		  end
		  else if(cnt>0) 
		  begin              //output sclk when sync_n is low
		      sclk_cnt <= sclk_cnt + 1'b1;
		  end
		  else 
		      sclk_cnt <= 0;		
    end
	
always @ ( posedge clk or negedge RESET_N) 
    begin
	     if(!RESET_N) 
		  begin
		      buffer_A <= 0;
			   buffer_B <= 0;
			   cnt      <= 6'b0;   
 			   dout_r   <= 0;  
 			   sync_n_r <= 0;
 			   ldac_n_r <= 0;
		  end
		  else
		  begin
		      if(en && cnt == 0) 
				begin		
				    cnt      <= 1;
				    buffer_A <= {4'b0011,ChannelA_data};
				    buffer_B <= {4'b1011,ChannelB_data};
			   end
			   else if ((cnt>0) && (sclk_cnt==1))	
			   begin
				if(cnt>0 && cnt<=16) 
				begin
				    sync_n_r <= 0;
					 dout_r   <= buffer_A[16-cnt];
				end
				else if(cnt>20 && cnt<=36) 
				begin
				    sync_n_r <= 0;
					 dout_r   <= buffer_B[36-cnt];
				end	
				else  
				begin
					 sync_n_r <= 1;
					 dout_r   <= 0;
				end
				if(cnt>38 && cnt<=40)
				    ldac_n_r <= 0;
				else 
					 ldac_n_r <= 1;
				if(cnt<=40)
					 cnt      <= cnt + 1'b1;
				else
					 cnt      <= 0; 
			   end
	     end	
    end
	
	assign sclk   = (sclk_cnt >= 8) ? 1'b1 : 1'b0;
	assign dout   = dout_r;
	assign sync_n = sync_n_r;
	assign ldac_n = ldac_n_r;

endmodule 
		/*
		else begin
		case (state_test)
		0:
			if(en && (cnt==6'b0))
			begin
				sync_n_r<=1;
				ldac_n_r<=1;
				dout_r<=0;
				state_test<=1;
				cnt<=1;
				buffer_A<={4'b0011,ChannelA_data};
				buffer_B<={4'b1011,ChannelB_data};
			end
		1:
			if((cnt>0) && (sclk_cnt==1))
			begin
				state_test<=2;
			end
			else
			begin
				state_test<=1;
			end
		2:		
			if(cnt>0 && cnt<=16)
			begin
				dout_r <= buffer_A[16-cnt];
				sync_n_r<=0;
				ldac_n_r<=1;
				state_test<=3;
				cnt<=cnt+1'b1;
			end
		3:
			if(cnt>16 && cnt<=20)
			begin
				dout_r<=0;
				sync_n_r<=1;
				ldac_n_r<=1;
				state_test<=4;
				cnt<=cnt+1'b1;
			end
		4:
			if(cnt>20 && cnt<=36)
			begin
				dout_r<=buffer_B[36-cnt];
				sync_n_r<=0;
				ldac_n_r<=1;
				state_test<=5;
				cnt<=cnt+1'b1;
			end
		5:
			if(cnt>36 && cnt<=38)
			begin
				ldac_n_r<=1;
				sync_n_r<=1;
				state_test<=6;
				cnt<=cnt+1'b1;
			end
		6:
			if(cnt>38 && cnt<=40)
			begin
				dout_r<=0;
				sync_n_r<=1;
				ldac_n_r<=0;
				state_test<=7;
				cnt<=cnt+1'b1;
			end	
		7:
			if(cnt>40)
			begin
				dout_r<=0;
				sync_n_r<=1;
				ldac_n_r<=1;
				cnt<=6'b0;
				state_test<=0;
			end
		default:
			begin
				buffer_A <= 0;
				buffer_B <= 0;
				cnt <= 6'b0;   
				dout_r <= 0;  
				sync_n_r <= 0;
				ldac_n_r <= 0;
			end	
	endcase
	end
	end*/

