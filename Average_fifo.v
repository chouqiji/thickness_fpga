///////////////////////////////////////////////////////////////////////////////////
//模块名称：	Average_fifo
//文件名称：	Average_fifo.v
//编写时间：	2016-04-04 
//编码    ：	
//功能描述：	
//	电磁超声信号累计平均模块
//`define simulate

`timescale 1ns/100ps

module Average_fifo(
	input		wire			clk,
	input		wire			reset_n,
	input		wire[9:0]	data_in,
	input		wire			data_in_valid,
	input 	wire			dout_enable,
	input		wire			armfifo_full,
	output	reg[15:0]	dout,
	output	reg			dout_ready,
	output	wire			Avgfifo_full,
	output	reg			armfifo_wrreq,
	output	reg[2:0]		state
    );

reg[15:0] data_acc;
reg[3:0] acc_counter;
reg aclr;
reg wrreq;
reg rdreq;

wire wrreq1;
wire rdreq1;
wire aclr1;
wire empty1;
wire full1;
wire[15:0] data1;
wire[15:0] q1;

assign data1 = data_acc;
assign aclr1 = (acc_counter[0]==0) ? aclr : 1'b0;
assign wrreq1 = (acc_counter[0]==0) ? wrreq : 1'b0;
assign rdreq1 = rdreq;	
	
Avgfifo_8192X16 Avgfifo_8192X16_u1(
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
wire[15:0] data2;
wire[15:0] q2;

assign data2 = data_acc;
assign aclr2 = (acc_counter[0]==0) ? 1'b0 : aclr;
assign wrreq2 = (acc_counter[0]==0) ? 1'b0 : wrreq;
assign rdreq2 = rdreq;	

Avgfifo_8192X16 Avgfifo_8192X16_u2(
		.aclr(aclr2),
		.clock(clk),
		.data(data2),
		.rdreq(rdreq2),
		.wrreq(wrreq2),
		.empty(empty2),
		.full(full2),
		.q(q2)
		);	

//wire[15:0] fifo_out;
//assign fifo_out = (acc_counter == 0) ? 16'b0 : (acc_counter[0]==1) ? q1 : q2;	


//wire empty;
//assign empty = (acc_counter[0]==0) ? empty2 : empty1;
assign Avgfifo_full = (acc_counter[0]==0) ? full1 : full2;

//输入的数据及有效信号延时1个时钟
reg[8:0] fifo_datain_d;
always@(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		fifo_datain_d <= 0;
	end
	else
	begin
		fifo_datain_d <= fifo_datain;
	end
end

//reg[2:0] state;
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
		dout_ready <= 0;
		armfifo_wrreq <= 0;
		state <= 0;
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
					dout_ready <= 0;
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
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 0;
				end
			end
			1:
			begin
				if(~Avgfifo_full)
				begin
					aclr <= 0;
					wrreq <= 1;
					rdreq <= 0;
					data_acc <= {7'd0,fifo_datain_d};
					acc_counter <= acc_counter;
					dout <= 0;
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 1;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter + 4'd1;
					dout <= 0;
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 2;
				end
			end
			2:
			begin
				if(data_in_valid)
				begin
					aclr <= 1;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;
					dout_ready <= 0;
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
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 2;
				end
			end
			3:
			begin
				if(~Avgfifo_full)
				begin
					aclr <= 0;
					wrreq <= 1;
					rdreq <= 0;
					data_acc <= {7'd0,fifo_datain_d};
					acc_counter <= acc_counter;
					dout <= 0;
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 3;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <= 0;
					data_acc <= 0;
					acc_counter <= acc_counter + 4'd1;
					dout_ready <= 1;
					dout <= 0;
					armfifo_wrreq <= 0;
					state <= 4;
				end
			end
			4:
			begin
				if(dout_enable)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=1;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;	
					dout_ready <= 1;
					armfifo_wrreq <= 0;
					state <= 5;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=0;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= 0;	
					dout_ready <= 1;
					armfifo_wrreq <= 0;
					state <= 4;
				end
				
			end
			5:	//�ȴ�FIFO���ݶ��
			begin
				aclr <= 0;
				wrreq <= 0;
				rdreq <=1;
				data_acc <= 0;
				acc_counter <= acc_counter;
				dout <= 0;	
				dout_ready <= 0;
				armfifo_wrreq <= 0;
				state <= 6;
			end
			6:
			begin
				if(~armfifo_full)
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=1;
					data_acc <= 0;
					acc_counter <= acc_counter;
					dout <= dout_tmp[17:2];
					//dout <= {q1[8:0],7'd0};
					dout_ready <= 0;
					armfifo_wrreq <= 1;
					state <= 6;
				end
				else
				begin
					aclr <= 0;
					wrreq <= 0;
					rdreq <=0;
					data_acc <= 0;
					acc_counter <= 0;
					dout <= 0;
					dout_ready <= 0;
					armfifo_wrreq <= 0;
					state <= 0;
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
				dout_ready <= 0;
				armfifo_wrreq <= 0;
				state <= 0;
			end
		endcase
	end
end		
endmodule