
`timescale 1ns/100ps

module Coder(
	input	wire	clk,
	input	wire	reset_n,
	input	wire	CountClear_n,
	input	wire	SignalA,
	input	wire	SignalB,
	output wire	signed[31:0]	dout
//	output reg[2:0] state

);

reg [3:0] count_clk;
always@(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		count_clk <= 4'd0;
	end
	else
	begin
		if(count_clk < 4'd9)
		begin
			count_clk <= count_clk + 4'd1;
		end
		else
		begin
			count_clk <= 4'd0;
		end
	end
end
wire clk_100k;
assign clk_100k = (count_clk < 4'd5) ? 1'b0 : 1'b1;
//-----------------------------------------------

reg A1;
reg A2;
reg B1;
reg B2;
always@(posedge clk_100k)
begin
	if(~reset_n)
	begin
		A1 <= 0;
		A2 <= 0;
		B1 <= 0;
		B2 <= 0;
	end
	else
	begin
		A1 <= SignalA;
		A2 <= A1;
		B1 <= SignalB;
		B2 <= B1;
	end
end

//============================================//

reg Coder_rst;
reg [2:0] count_rst;
always@(posedge clk_100k)
begin
	if((~reset_n) || (~CountClear_n))
	begin
		if(count_rst < 3'd7)
		begin
			count_rst <= count_rst + 3'd1;
			Coder_rst <= Coder_rst;
		end
		else
		begin
			count_rst <= count_rst;
			Coder_rst <= 0;
		end
	end
	else
	begin
		count_rst <= 3'd0;
		Coder_rst <= 1;
	end
end

//-------------------------------------------

reg signed[31:0] count;
assign dout = count;

reg [2:0] state;
always@(posedge clk_100k)
begin
	if(~Coder_rst)
	begin
		count <= 0;
		state <= 0;
	end
	else
	begin
		case(state)
			0:
			begin
				if(SignalA==1 && A1==1 && A2==1 && SignalB==0 && B1==0 && B2==0)
				begin
					if(count == 32'h7fffffff)
					begin
						count <= 0;
					end
					else
					begin
						count <= count+32'd1;
					end
					state <= 1;
				end
				else if(SignalA==1 && A1==1 && A2==1 && SignalB==1 && B1==1 && B2==1)
				begin
					if(count == 32'h80000000)
					begin
						count <= 0;
					end
					else
					begin
						count <= count-32'd1;
					end
					state <= 1;
				end
				else
				begin
					count <= count;
					state <= 0;
				end
			end
			1:
			begin
				if(SignalA==0 && A1==0 && A2==0)
				begin
					count <= count;
					state <= 0;
				end
				else
				begin
					count <= count;
					state <= 1;
				end
			end
			default:
			begin
				count <= 0;
				state <= 0;
			end
		endcase
	end
end


//reg [2:0]	count1;
////reg [2:0] state;
//always@(posedge clk_100k)
//begin
//	if(~Coder_rst)
//	begin
//		count <= 0;
//		count1 <= 0;
//		state <= 0;
//	end
//	else
//	begin
//		case(state)
//			0:
//			begin
//				if(SignalA==1&&A2==1&&A1==0&&SignalB==0)
//				begin
//					count <= 0;
//					count1 <= 0;
//					state <= 2;
//				end
//				else if(SignalB==1&&B2==1&&B1==0&&SignalA==0)
//				begin
//					count <= 0;
//					count1 <= 0;
//					state <= 3;
//				end
//				else
//				begin
//					count <= 0;
//					count1 <= 0;
//					state <= 0;
//				end
//			end
//			1: // Increase
//			begin
//				if(SignalA==1&&A2==1&&A1==0&&SignalB==0)
//				begin
////					if(count == 32'h7fffffff)
////					begin
////						count <= 0;
////					end
////					else
////					begin
////						count <= count+32'd1;
////					end
//					count <= count;
//					count1 <= 0;
//					state <= 2;
//				end
//				else if(SignalB==1&&B2==1&&B1==0&&SignalA==0)
//				begin
////					if(count == 32'h80000000)
////					begin
////						count <= 0;
////					end
////					else
////					begin
////						count <= count-32'd1;
////					end
//					count <= count;
//					count1 <= 0;
//					state <= 3;
//				end
//				else
//				begin
//					count <= count;
//					count1 <= 0;
//					state <= 1;
//				end
//			end
//			2:
//			begin
//				if(SignalA==1&&A2==1&&A1==1&&SignalB==0)
//				begin
//					if(count1 < 3)
//					begin
//						count <= count;
//						count1 <= count1 + 3'd1;
//						state <= 2;
//					end
//					else
//					begin
//						if(count == 32'h7fffffff)
//						begin
//							count <= 0;
//						end
//						else
//						begin
//							count <= count+32'd1;
//						end
//						count1 <= 0;
//						state <= 1;
//					end
//				end
//				else
//				begin
//					count <= count;
//					count1 <= 0;
//					state <= 1;
//				end
//			end
//			3:
//			begin
//				if(SignalB==1&&B2==1&&B1==1&&SignalA==0)
//				begin
//					if(count1 < 3)
//					begin
//						count <= count;
//						count1 <= count1 + 3'd1;
//						state <= 3;
//					end
//					else
//					begin
//						if(count == 32'h80000000)
//						begin
//							count <= 0;
//						end
//						else
//						begin
//							count <= count-32'd1;
//						end
//						count1 <= 0;
//						state <= 1;
//					end
//				end
//				else
//				begin
//					count <= count;
//					count1 <= 0;
//					state <= 1;
//				end
//			end
//			default:
//			begin
//				count <= 0;
//				state <= 0;
//			end
//		endcase		
//	end
//end

endmodule