
`timescale 1ns/100ps

module    protect(
    input    wire    clk       ,
	 input 	 wire		reset_n   ,
	 input 	 wire		protect_in,
	 input 	 wire		SensorOK  ,
	 output 	 reg 		protect_en,
	 output	 reg		SensorOK_en
	 //	input 	wire[1:0]	AD_sample_flag,
	
	);
//**************************** Introduction *******************************
// protect_in[0]: TempOV_protect(TempOV); 0-->protect;	1-->unprotect;
// protect_in[1]: HVCap_protect(IOV_HIGH); 0-->protect;		1-->unprotect;
//*************************************************************************
    parameter    STATE_IDLE	= 2'd0       ;
	 parameter    STATE_P_TEST = 2'd1       ;
	 parameter    STATE_P_WAIT	= 2'd2       ;
	 parameter    T_ns         = 24'd1000000;
//	wire [15:0] T_ns;	//T_ns = 40ns
//	assign T_ns = (AD_sample_flag == 4) ? 16'd2 : (AD_sample_flag == 1) ? 16'd3 : 16'd1;
	
	 reg    [23:0]    p_cnt;
	 reg    [1:0]	   state;
	 reg    [23:0]    p_cnt1;
	 reg    [1:0]	   state1;
	 
always@(posedge clk or negedge reset_n)
begin
    if(~reset_n)
	 begin
	     p_cnt      <= 24'd0     ;
		  protect_en <= 1'b1      ; 
		  state      <= STATE_IDLE;
	 end
	 else
	 begin
	     case(state)
		  STATE_IDLE:
		      begin
				    if(~protect_in)
					 begin
					     p_cnt      <=p_cnt + 24'd1;
						  protect_en <= 1'b0        ; 
						  state      <= STATE_P_TEST;
					 end
					 else
					 begin
				        p_cnt      <= 24'd0     ;
						  protect_en <= 1'b0      ;  
						  state      <= STATE_IDLE;
					 end
				end
        STATE_P_TEST:
		      begin
					 if(p_cnt >= T_ns)
					 begin
					     protect_en <= 1'b1; 
					 end
					 else
					 begin
					     protect_en <= 1'b0; 
					 end
					 if(~protect_in)
					 begin
					     p_cnt <=p_cnt + 24'd1;
						  state <= STATE_P_TEST;
					 end
					 else
					 begin
					     p_cnt <= p_cnt       ;
						  state <= STATE_P_WAIT;
					 end
				end
        STATE_P_WAIT:
				begin
				    if(p_cnt >= T_ns)
					 begin
					     protect_en <= 1'b1; 
					 end
					 else
					 begin
					     protect_en <= 1'b0; 
					 end
					 if(~protect_in)
					 begin
					     p_cnt <=p_cnt + 24'd1;
						  state <= STATE_P_TEST;
					 end
					 else
					 begin
					     p_cnt <= 0         ;
						  state <= STATE_IDLE;
					 end
				end
				
        default:
				begin
				    p_cnt      <= 24'd0     ;
					 protect_en <= 1'b1      ; 
					 state      <= STATE_IDLE;
				end
        endcase
    end
end

//*******************SensorOK Detect***********************//
// SensorOK; 0-->Sensor is not connect;	1-->Sensor is connect;
// SensorOK_en; 0-->Sensor is not connect;	1-->Sensor is connect;

//*************************************************************************

always@(posedge clk or negedge reset_n)
begin
    if(~reset_n)
	     begin
		      p_cnt1      <= 24'd0     ;
			   SensorOK_en <= 1'b0      ; 
			   state1      <= STATE_IDLE;
		  end
		  else
		  begin
		      case(state1)
				STATE_IDLE:
				    begin
					     if(~SensorOK)
					     begin
						      p_cnt1 <=p_cnt1 + 24'd1;
						      SensorOK_en <= 1'b1    ; 
						      state1 <= STATE_P_TEST ;
					     end
					     else
					     begin
						      p_cnt1 <= 24'd0     ;
						      SensorOK_en <= 1'b1 ; 
						      state1 <= STATE_IDLE;
					     end
				    end
				STATE_P_TEST:
				    begin
					     if(p_cnt1 >= T_ns)
					     begin
						      SensorOK_en <= 1'b0; 
					     end
					     else
					     begin
						      SensorOK_en <= 1'b1; 
					     end
					     if(~SensorOK)
					     begin
						      p_cnt1 <= p_cnt1 + 24'd1;
						      state1 <= STATE_P_TEST  ;
					     end
					     else
					     begin
						      p_cnt1 <= p_cnt1      ;
						      state1 <= STATE_P_WAIT;
					     end
				    end
				STATE_P_WAIT:
				    begin
					     if(p_cnt1 >= T_ns)
					     begin
						      SensorOK_en <= 1'b0; 
					     end
					     else
					     begin
						      SensorOK_en <= 1'b1; 
					     end
					     if(~SensorOK)
					     begin
						      p_cnt1 <= p_cnt1 + 24'd1;
						      state1 <= STATE_P_TEST  ;
					     end
					     else
					     begin
						      p_cnt1 <=          0;
						      state1 <= STATE_IDLE;
					     end
				    end
				default:
				    begin
					     p_cnt1      <= 24'd0     ;
					     SensorOK_en <= 1'b0      ; 
					     state1      <= STATE_IDLE;
				    end
			   endcase
    end
end	
	
endmodule
	
//	/**********************************************************************/
//	reg ProtectSig;
//	reg ProtectSig_former;
//
//	always@(posedge clk or negedge reset_n)
//	begin
//		if(!reset_n) 
//		begin
//			ProtectSig <= 1'b0;
//			ProtectSig_former <= 1'b0;
//		end
//		else 
//		begin
//			//ProtectSig <= protect_in[0] | (!protect_in[1]);
//			ProtectSig <= (!protect_in[1]);
//			ProtectSig_former <= ProtectSig;
//	//		ProtectSig <= 1'b1;
//		end
//	end
//	/**********************************************************************/
//	parameter T_40ns = 4'd2;
//	
//	reg[3:0] p_cnt;
//	always @ (posedge clk or negedge reset_n)
//	begin
//		if(!reset_n) 
//		begin
//			p_cnt <= 4'd0;
//		end
//		else 
//		begin
//			case({ProtectSig_former,ProtectSig}) //synopsys parallel_case
//				2'b11: 	begin p_cnt <= p_cnt+4'd1; end
//				2'b01:	begin p_cnt <= p_cnt+4'd1; end
//				2'b10:	begin p_cnt <= p_cnt;       end
//				2'b00:	begin p_cnt <= 4'd0;       end
//				default: begin p_cnt <= p_cnt;       end
//			endcase
//		end
//	end
//	
//	parameter State_unprotect	= 1'b0;
//	parameter State_protect 	= 1'b1;
//	
//	parameter T_1s = 32'd100_123_201;
//	
//	reg[31:0] count;
//	reg state;
//	
//	always@(posedge clk or negedge reset_n)
//	begin
//		if(~reset_n)
//		begin
//			state <= State_protect;
//			protect_en <= 1'b1;
//			count <= 0;
//		end
//		else 
//		begin
//			case(state)
//				State_unprotect:   
//				begin
//					if(p_cnt >= T_40ns)
//					begin
//						protect_en <= 1'b1;
//						state <= State_protect;
//						count <= 0;
//					end
//					else
//					begin
//						protect_en <= 1'b0;
//						state <= State_unprotect;
//						count <= 0;
//					end
//				end
//
//				State_protect:	
//				begin
//					protect_en <= 1'b1;
//					if(count >= T_1s )
//					begin
//						count <= 0;
//						state <= State_unprotect;
//					end
//					else  
//					begin
//						count <= count+32'b1;
//						state <= State_protect;	
//					end
//				end
//				
//				default:
//				begin
//					state <= State_protect;
//					protect_en <= 1'b1;
//					count <= 0;
//				end
//			endcase
//		end
//	end
	


	