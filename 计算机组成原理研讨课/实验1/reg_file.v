`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input                       clk,
	input  [`ADDR_WIDTH - 1:0]  waddr,
	input  [`ADDR_WIDTH - 1:0]  raddr1,
	input  [`ADDR_WIDTH - 1:0]  raddr2,
	input                       wen,
	input  [`DATA_WIDTH - 1:0]  wdata,
	output [`DATA_WIDTH - 1:0]  rdata1,
	output [`DATA_WIDTH - 1:0]  rdata2
);

	// 32*32-bit register
	reg    [`DATA_WIDTH - 1:0]  r [`DATA_WIDTH - 1:0];

	// synchronous write
	always @(posedge clk) begin
		r[0] <= 32'b0; 
		if (wen == 1 && waddr != 0)
			r[waddr] <= wdata;	
	end

	// asynchronous read
	assign rdata1 = r[raddr1];
	assign rdata2 = r[raddr2];

endmodule
