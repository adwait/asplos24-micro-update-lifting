module lsu_bypass (
	clk_i,
	rst_ni,
	flush_i,
	lsu_req_i,
	lsu_req_valid_i,
	pop_ld_i,
	pop_st_i,
	lsu_ctrl_o,
	ready_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [84:0] lsu_req_i;
	input wire lsu_req_valid_i;
	input wire pop_ld_i;
	input wire pop_st_i;
	output reg [84:0] lsu_ctrl_o;
	output wire ready_o;
	reg [169:0] mem_n;
	reg [169:0] mem_q;
	reg read_pointer_n;
	reg read_pointer_q;
	reg write_pointer_n;
	reg write_pointer_q;
	reg [1:0] status_cnt_n;
	reg [1:0] status_cnt_q;
	wire empty;
	assign empty = status_cnt_q == 0;
	assign ready_o = empty;
	reg [1:0] status_cnt;
	reg write_pointer;
	reg read_pointer;
		
	always @(*) begin : sv2v_autoblock_1
		status_cnt = status_cnt_q;
		write_pointer = write_pointer_q;
		read_pointer = read_pointer_q;
		mem_n = mem_q;
		if (lsu_req_valid_i) begin
			mem_n[write_pointer_q * 85+:85] = lsu_req_i;
			write_pointer = write_pointer + 1;
			status_cnt = status_cnt + 1;
		end
		if (pop_ld_i) begin
			mem_n[(read_pointer_q * 85) + 84] = 1'b0;
			read_pointer = read_pointer + 1;
			status_cnt = status_cnt - 1;
		end
		if (pop_st_i) begin
			mem_n[(read_pointer_q * 85) + 84] = 1'b0;
			read_pointer = read_pointer + 1;
			status_cnt = status_cnt - 1;
		end
		if (pop_st_i && pop_ld_i)
			mem_n = 1'sb0;
		if (flush_i) begin
			status_cnt = 1'sb0;
			write_pointer = 1'sb0;
			read_pointer = 1'sb0;
			mem_n = 1'sb0;
		end
		read_pointer_n = read_pointer;
		write_pointer_n = write_pointer;
		status_cnt_n = status_cnt;
	end
	always @(*) begin : output_assignments
		if (empty)
			lsu_ctrl_o = lsu_req_i;
		else
			lsu_ctrl_o = mem_q[read_pointer_q * 85+:85];
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			mem_q <= 1'sb0;
			status_cnt_q <= 1'sb0;
			write_pointer_q <= 1'sb0;
			read_pointer_q <= 1'sb0;
		end
		else begin
			mem_q <= mem_n;
			status_cnt_q <= status_cnt_n;
			write_pointer_q <= write_pointer_n;
			read_pointer_q <= read_pointer_n;
		end
endmodule
