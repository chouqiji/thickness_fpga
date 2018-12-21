`timescale 1ps/1ps

module reg_8192X16(
	input	wire	clk,
	input	wire[10:0]	addr,
	input	wire[11:0]	data,
	input	wire		wren,
	output	wire[11:0]	q
	);

//reg[15:0] data_tmp[8191:0];
reg [11:0] data_tmp[2047:0];

always@(posedge clk)
begin
	if(wren)
	begin
		data_tmp[addr] <= data;
	end
	else
	begin
		data_tmp[addr] <= data_tmp[addr];
	end
end

assign q = wren ? 16'b0 : data_tmp[addr];

endmodule
