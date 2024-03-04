module amo_buffer (
	clk_i,
	rst_ni,
	flush_i,
	valid_i,
	ready_o,
	amo_op_i,
	paddr_i,
	data_i,
	data_size_i,
	amo_req_o,
	amo_resp_i,
	amo_valid_commit_i,
	no_st_pending_i
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire valid_i;
	output wire ready_o;
	input wire [3:0] amo_op_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_PLEN = 34;
	input wire [33:0] paddr_i;
	input wire [31:0] data_i;
	input wire [1:0] data_size_i;
	output wire [134:0] amo_req_o;
	input wire [64:0] amo_resp_i;
	input wire amo_valid_commit_i;
	input wire no_st_pending_i;
	wire flush_amo_buffer;
	wire amo_valid;
	wire [71:0] amo_data_in;
	wire [71:0] amo_data_out;
	assign amo_req_o[134] = (no_st_pending_i & amo_valid_commit_i) & amo_valid;
	assign amo_req_o[133-:4] = amo_data_out[71-:4];
	assign amo_req_o[129-:2] = amo_data_out[1-:2];
	assign amo_req_o[127-:64] = {{30 {1'b0}}, amo_data_out[67-:34]};
	assign amo_req_o[63-:64] = {{32 {1'b0}}, amo_data_out[33-:32]};
	assign amo_data_in[71-:4] = amo_op_i;
	assign amo_data_in[33-:32] = data_i;
	assign amo_data_in[67-:34] = paddr_i;
	assign amo_data_in[1-:2] = data_size_i;
	assign flush_amo_buffer = flush_i & !amo_valid_commit_i;
	// fifo_v3_4F30F_AEF03 #(
	// 	.dtype_riscv_PLEN(riscv_PLEN),
	// 	.dtype_riscv_XLEN(riscv_XLEN),
	// 	.DEPTH(1)
	// ) i_amo_fifo(
	// 	.clk_i(clk_i),
	// 	.rst_ni(rst_ni),
	// 	.flush_i(flush_amo_buffer),
	// 	.testmode_i(1'b0),
	// 	.full_o(amo_valid),
	// 	.empty_o(ready_o),
	// 	.usage_o(),
	// 	.data_i(amo_data_in),
	// 	.push_i(valid_i),
	// 	.data_o(amo_data_out),
	// 	.pop_i(amo_resp_i[64])
	// );
endmodule
