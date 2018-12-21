///////////////////////////////////////////////////////////////////////////////////
//ģ�����ƣ�	AD_clk_gen
//�ļ����ƣ�	AD_clk_gen.v
//��дʱ�䣺	2015-2-2
//����    ��	xuji
//����������	
//ADʱ�ӿ���ģ�飬����AD����ʱ��AD_clk(����)��AD_clk2(���)
//�Լ�AD������Ч�ź�AD_data_valid��

`timescale 1ns/100ps
module AD_clk_gen(
	input		wire			reset_n,
	input		wire			clk_sample,
	input 	wire 			burst_syn,
	//input		wire			Avg_Sram_full,
	output	reg 			AD_sample_en,
	output	wire 			AD_data_valid	//AD������Ч�źţ�������ʹ���ź�(AD_sample_en)�ӳ�5��ʱ�ӣ�	
	);
	
//============================================================
	//---����AD���������źţ�������ADоƬ��ʱ���źţ�ֻ������Ҫ�ɼ����ݵ�ʱ������ɼ�����������---
	parameter	STATE_IDLE		= 2'd0,
					STATE_SAMPLE	= 2'd1,
					STATE_QUIT		= 2'd2;
					
	reg[15:0] counter;
	reg[1:0] state; 
	always@(posedge clk_sample or negedge reset_n)
	begin
		if(~reset_n)
		begin
			AD_sample_en <= 0;
			counter <= 0;
			state <= STATE_IDLE;
		end
		else
		begin
			case(state)
				STATE_IDLE:
				begin
					if(burst_syn)
					begin
						AD_sample_en <= 1;
						counter <= 0;
						state <= STATE_SAMPLE;
					end
					else
					begin
						AD_sample_en <= 0;
						counter <= 0;
						state <= STATE_IDLE;
					end
				end
				STATE_SAMPLE:
				begin
					if(counter < 8191)
					begin
						AD_sample_en <= 1;
						counter <= counter + 13'b1;
						state <= STATE_SAMPLE;
					end
					else
					begin
						AD_sample_en <= 0;
						counter <= 0;
						state <= STATE_QUIT;
					end
				end
				STATE_QUIT:
				begin
					if(~burst_syn)
					begin
						AD_sample_en <= 0;
						counter <= 0;
						state <= STATE_IDLE;
					end
					else
					begin
						AD_sample_en <= 0;
						counter <= 0;
						state <= STATE_QUIT;
					end
				end
				
				default:
				begin
					AD_sample_en <= 0;
					counter <= 0;
					state <= STATE_IDLE;
				end
			endcase
		end
	end

	assign AD_data_valid = AD_sample_en;	
	
	//----����AD������Ч�źţ�����AD9215�ֲᣬ��ʱ������������֮���ӳ�5��ʱ��-----
//	reg AD_sample_en_1d, AD_sample_en_2d, AD_sample_en_3d, AD_sample_en_4d, AD_sample_en_5d;
//	always@(posedge AD_clk2 or negedge reset_n)
//	begin
//		if(~reset_n)
//		begin
//			AD_sample_en_1d <= 0;
//			AD_sample_en_2d <= 0;
//			AD_sample_en_3d <= 0;
//			AD_sample_en_4d <= 0;
//			AD_sample_en_5d <= 0;
//		end
//		else
//		begin
//			AD_sample_en_1d <= AD_sample_en_tmp;
//			AD_sample_en_2d <= AD_sample_en_1d;
//			AD_sample_en_3d <= AD_sample_en_2d;
//			AD_sample_en_4d <= AD_sample_en_3d;
//			AD_sample_en_5d <= AD_sample_en_4d;
//		end
//	end
//	assign AD_data_valid = AD_sample_en_5d;
//	assign AD_sample_en = AD_sample_en_tmp || AD_data_valid;	//����AD���ݱ�ʱ���ӳ�5��ʱ�ӣ�����Чʱ���������ڲ���������
//	assign AD_clk = AD_sample_en && AD_clk2;
	
endmodule