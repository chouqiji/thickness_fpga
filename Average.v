`timescale 1ps/1ps

module Average(
	input		wire		clk,
	input		wire		reset_n,
	input		wire		data_in_valid,
	input		wire[9:0] data_in,
	input	   wire[2:0] burst_period,
	
	input 	wire		dout_enable,
	output	reg[9:0]	dout,
//	output	reg		reg_full,
	
	input		wire		armfifo_full,
	output	reg		armfifo_aclr,
	output	reg		armfifo_wrreq
    );

reg[16:0] data_acc;
reg[7:0] acc_counter;
reg aclr;
reg wrreq;
reg rdreq;

wire wrreq1;
wire rdreq1;
wire aclr1;
wire empty1;
wire full1;
wire[16:0] data1;
wire[16:0] q1;

assign data1 = data_acc;
assign aclr1 = (acc_counter[0]==0) ? aclr : 1'b0;
assign wrreq1 = (acc_counter[0]==0) ? wrreq : 1'b0;
assign rdreq1 = (acc_counter[0]==0) ? 1'b0 : rdreq;	
	
Avgfifo_8192X16 U1_Avgfifo_8192X16(
		.aclr(aclr1),
		.clock(clk),
		.data(data1),
		.rdreq(rdreq1),
		.wrreq(wrreq1),
		.empty(empty1),
		.full(full1),
		.q(q1)
		);

wire wrreq2;
wire rdreq2;
wire aclr2;
wire empty2;
wire full2;
wire[16:0] data2;
wire[16:0] q2;
wire[6:0] average_num;
wire[6:0] average_n;

assign data2 = data_acc;
assign aclr2 = (acc_counter[0]==0) ? 1'b0 : aclr;
assign wrreq2 = (acc_counter[0]==0) ? 1'b0 : wrreq;
assign rdreq2 = (acc_counter[0]==0) ? rdreq : 1'b0;	

assign average_n=(burst_period == 7) ? 7'd1: 7'd64;
assign average_num = average_n;

Avgfifo_8192X16 U2_Avgfifo_8192X16(
		.aclr(aclr2),
		.clock(clk),
		.data(data2),
		.rdreq(rdreq2),
		.wrreq(wrreq2),
		.empty(empty2),
		.full(full2),
		.q(q2)
		);	

wire[16:0] fifo_out;
assign fifo_out = (acc_counter == 0) ? 17'b0 : (acc_counter[0]==1) ? q1 : q2;	

//wire empty;
wire full;
//assign empty = (acc_counter[0]==0) ? empty2 : empty1;
assign full = (acc_counter[0]==0) ? full1 : full2;

//输入的数据及有效信号延时1个时钟
reg[9:0] data_in_d, data_in_2d;
always@(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		data_in_d <= 0;
		data_in_2d <= 0;
	end
	else
	begin
    
		data_in_d <= data_in;
		data_in_2d <= data_in_d;
	end
end

reg[3:0] state;

reg[67:0] shift;

reg[16:0] out;

always@(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		aclr <= 1;
		wrreq <= 0;
		rdreq <= 0;
		data_acc <= 0;
		acc_counter <= 0;
		dout <= 0;
		armfifo_aclr <= 0;
		armfifo_wrreq <= 0;
		state <= 0;
		
		shift<=68'b0;
	end
	else
	begin
		case(state)
			0:
			begin
				if(data_in_valid)
				begin
					aclr <= 1;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= 0;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 1;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= 0;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 0;
				end
			end
			1:
			begin
				if(~full)
				begin
					aclr <= 0;
					wrreq <= 1;
					rdreq <= 0;
					data_acc <= {7'd0,data_in_d};
					
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 1;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
               acc_counter<=acc_counter+8'd1;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					if(burst_period==7)
					begin
					state<=6;
					end
					else 
					begin
					state<=2;
					end
//					state <= 2;	//多次平均输出
//					state <= 6;	//不平均输出
				end
			end
			2:
			begin
				if(~data_in_valid)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 3;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 2;
				end
			end
			3:
			begin
				if(data_in_valid)
				begin
					aclr <= 1;
					wrreq <= 0;
					rdreq <= 1;
					data_acc <= 0;
					
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 4;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 3;
				end
			end
			4:	//等待FIFO数据读出
			begin
				aclr <= 1;
				wrreq <= 0;
				rdreq <= 1;
				data_acc <= 0;
				acc_counter <= acc_counter;
				dout <= 0;
				armfifo_aclr <= 0;
				armfifo_wrreq <= 0;
				state <= 5;
			end
			5:
			begin
				if(~full)
				begin
					aclr <= 0;
					wrreq <= 1;
					rdreq <= 1;
					data_acc <= fifo_out + {7'b0,data_in_2d};
				
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 5;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=0;
					data_acc <= 0;
					acc_counter <= acc_counter + 8'b1;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;

					if(acc_counter >= (average_num-1))     //if(acc_counter >= (average_num-1))
					begin
						state <= 6;
					end
					else
					begin
						state <= 2;
					end
					
				end
			end
			6:
			begin
				if(dout_enable)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=1;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;	
					armfifo_aclr <= 1;
					armfifo_wrreq <= 0;
					state <= 7;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;	
					
					
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 6;
				end
				
			end
			7:	//等待FIFO数据读出
			begin
				aclr <= 0;
				wrreq <= 0;
				rdreq <=1;
				data_acc <= 0;
				acc_counter <= acc_counter;
				dout <= 0;	
				armfifo_aclr <= 0;
				armfifo_wrreq <= 0;
				state <= 8;
			end
			8:
			begin
				if(~armfifo_full)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=1;
					data_acc <= 0;
					acc_counter <= acc_counter;
//					dout <= fifo_out[15:6];	//64次平均输出
//					dout <= fifo_out[9:0];	//	不平均输出
					if(burst_period == 7)
					begin
					
					shift <= {shift[50:0],fifo_out};    //实现了<<17位与低17位赋值
					out <= shift[67:51]+shift[50:34]+shift[33:17]+shift[16:0];
					dout <= out[11:2];		//移除低2位等于平均2^2次	
//		         dout<=fifo_out[9:0]; 

					end
					else
					begin
					dout <= fifo_out[15:6]; //移除低6位等于平均2^6次
					end
					armfifo_aclr <= 0;
					armfifo_wrreq <= 1;
					state <= 8;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=0;
					data_acc <= 0;
					acc_counter <= 0;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 9;
				end
			end
			9:
			begin
				if(~data_in_valid)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 0;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					armfifo_aclr <= 0;
					armfifo_wrreq <= 0;
					state <= 9;
				end
			end
			default:
			begin
				aclr <= 0;
				wrreq <= 0;
				rdreq <=0;
				data_acc <= 0;
				acc_counter <= 0;
				dout <= 0;
				armfifo_aclr <= 0;
				armfifo_wrreq <= 0;
				state <= 0;
			end
		endcase
	end
end		
endmodule
