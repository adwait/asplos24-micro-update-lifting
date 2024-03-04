module store_unit (
	clk_i,
	rst_ni,
	flush_i,
	no_st_pending_o,
	store_buffer_empty_o,
	valid_i,
	lsu_ctrl_i,
	pop_st_o,
	commit_i,
	commit_ready_o,
	amo_valid_commit_i,
	valid_o,
	trans_id_o,
	result_o,
	ex_o,
	translation_req_o,
	vaddr_o,
	paddr_i,
	ex_i,
	dtlb_hit_i,
	page_offset_i,
	page_offset_matches_o,
	amo_req_o,
	amo_resp_i,
	req_port_i,
	req_port_o
`ifdef EXPOSE_STATE
	, store_state_o
`endif
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	output wire no_st_pending_o;
	output wire store_buffer_empty_o;
	input wire valid_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [84:0] lsu_ctrl_i;
	output reg pop_st_o;
	input wire commit_i;
	output wire commit_ready_o;
	input wire amo_valid_commit_i;
	output reg valid_o;
	output wire [2:0] trans_id_o;
	output wire [31:0] result_o;
	output reg [64:0] ex_o;
	output reg translation_req_o;
	output wire [31:0] vaddr_o;
	localparam riscv_PLEN = 34;
	input wire [33:0] paddr_i;
	input wire [64:0] ex_i;
	input wire dtlb_hit_i;
	input wire [11:0] page_offset_i;
	output wire page_offset_matches_o;
	output wire [134:0] amo_req_o;
	input wire [64:0] amo_resp_i;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	input wire [34:0] req_port_i;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	output wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_o;
	assign result_o = 1'sb0;
	reg [1:0] state_d;
	reg [1:0] state_q;
	wire st_ready;
	reg st_valid;
	reg st_valid_without_flush;
	wire instr_is_amo;
	function automatic ariane_pkg_is_amo;
		input reg [7:0] op;
		if ((8'd46 <= op) && (8'd67 >= op))
			ariane_pkg_is_amo = 1'b1;
		else
			ariane_pkg_is_amo = 1'b0;
	endfunction
	assign instr_is_amo = ariane_pkg_is_amo(lsu_ctrl_i[10-:8]);
	reg [31:0] st_data_n;
	reg [31:0] st_data_q;
	reg [3:0] st_be_n;
	reg [3:0] st_be_q;
	reg [1:0] st_data_size_n;
	reg [1:0] st_data_size_q;
	reg [3:0] amo_op_d;
	reg [3:0] amo_op_q;
	reg [2:0] trans_id_n;
	reg [2:0] trans_id_q;
	assign vaddr_o = lsu_ctrl_i[83-:32];
	assign trans_id_o = trans_id_q;
	always @(*) begin : store_control
		translation_req_o = 1'b0;
		valid_o = 1'b0;
		st_valid = 1'b0;
		st_valid_without_flush = 1'b0;
		pop_st_o = 1'b0;
		ex_o = ex_i;
		trans_id_n = lsu_ctrl_i[2-:ariane_pkg_TRANS_ID_BITS];
		state_d = state_q;
		case (state_q)
			2'd0:
				if (valid_i) begin
					state_d = 2'd1;
					translation_req_o = 1'b1;
					pop_st_o = 1'b1;
					if (!dtlb_hit_i) begin
						state_d = 2'd2;
						pop_st_o = 1'b0;
					end
					if (!st_ready) begin
						state_d = 2'd3;
						pop_st_o = 1'b0;
					end
				end
			2'd1: begin
				valid_o = 1'b1;
				if (!flush_i)
					st_valid = 1'b1;
				st_valid_without_flush = 1'b1;
				if (valid_i && !instr_is_amo) begin
					translation_req_o = 1'b1;
					state_d = 2'd1;
					pop_st_o = 1'b1;
					if (!dtlb_hit_i) begin
						state_d = 2'd2;
						pop_st_o = 1'b0;
					end
					if (!st_ready) begin
						state_d = 2'd3;
						pop_st_o = 1'b0;
					end
				end
				else
					state_d = 2'd0;
			end
			2'd3: begin
				translation_req_o = 1'b1;
				if (st_ready && dtlb_hit_i)
					state_d = 2'd0;
			end
			2'd2: begin
				translation_req_o = 1'b1;
				if (dtlb_hit_i)
					state_d = 2'd0;
			end
		endcase
		if (ex_i[0] && (state_q != 2'd0)) begin
			pop_st_o = 1'b1;
			st_valid = 1'b0;
			state_d = 2'd0;
			valid_o = 1'b1;
		end
		if (flush_i)
			state_d = 2'd0;
	end
	localparam riscv_IS_XLEN64 = 1'b0;
	function automatic [31:0] ariane_pkg_data_align;
		input reg [2:0] addr;
		input reg [63:0] data;
		reg [2:0] addr_tmp;
		reg [63:0] data_tmp;
		begin
			addr_tmp = {addr[2] && riscv_IS_XLEN64, addr[1:0]};
			data_tmp = {64 {1'b0}};
			case (addr_tmp)
				3'b000: data_tmp[31:0] = {data[31:0]};
				3'b001: data_tmp[31:0] = {data[23:0], data[31:24]};
				3'b010: data_tmp[31:0] = {data[15:0], data[31:16]};
				3'b011: data_tmp[31:0] = {data[7:0], data[31:8]};
				3'b100: data_tmp = {data[31:0], data[63:32]};
				3'b101: data_tmp = {data[23:0], data[63:24]};
				3'b110: data_tmp = {data[15:0], data[63:16]};
				3'b111: data_tmp = {data[7:0], data[63:8]};
			endcase
			ariane_pkg_data_align = data_tmp[31:0];
		end
	endfunction
	function automatic [1:0] ariane_pkg_extract_transfer_size;
		input reg [7:0] op;
		case (op)
			8'd35, 8'd36, 8'd81, 8'd85, 8'd47, 8'd49, 8'd59, 8'd60, 8'd61, 8'd62, 8'd63, 8'd64, 8'd65, 8'd66, 8'd67: ariane_pkg_extract_transfer_size = 2'b11;
			8'd37, 8'd38, 8'd39, 8'd82, 8'd86, 8'd46, 8'd48, 8'd50, 8'd51, 8'd52, 8'd53, 8'd54, 8'd55, 8'd56, 8'd57, 8'd58: ariane_pkg_extract_transfer_size = 2'b10;
			8'd40, 8'd41, 8'd42, 8'd83, 8'd87: ariane_pkg_extract_transfer_size = 2'b01;
			8'd43, 8'd45, 8'd44, 8'd84, 8'd88: ariane_pkg_extract_transfer_size = 2'b00;
			default: ariane_pkg_extract_transfer_size = 2'b11;
		endcase
	endfunction
	always @(*) begin
		st_be_n = lsu_ctrl_i[18-:4];
		st_data_n = (instr_is_amo ? lsu_ctrl_i[50:19] : ariane_pkg_data_align(lsu_ctrl_i[54:52], lsu_ctrl_i[50-:32]));
		st_data_size_n = ariane_pkg_extract_transfer_size(lsu_ctrl_i[10-:8]);
		case (lsu_ctrl_i[10-:8])
			8'd46, 8'd47: amo_op_d = 4'b0001;
			8'd48, 8'd49: amo_op_d = 4'b0010;
			8'd50, 8'd59: amo_op_d = 4'b0011;
			8'd51, 8'd60: amo_op_d = 4'b0100;
			8'd52, 8'd61: amo_op_d = 4'b0101;
			8'd53, 8'd62: amo_op_d = 4'b0110;
			8'd54, 8'd63: amo_op_d = 4'b0111;
			8'd55, 8'd64: amo_op_d = 4'b1000;
			8'd56, 8'd65: amo_op_d = 4'b1001;
			8'd57, 8'd66: amo_op_d = 4'b1010;
			8'd58, 8'd67: amo_op_d = 4'b1011;
			default: amo_op_d = 4'b0000;
		endcase
	end
	wire store_buffer_valid;
	wire amo_buffer_valid;
	wire store_buffer_ready;
	wire amo_buffer_ready;
	assign store_buffer_valid = st_valid & (amo_op_q == 4'b0000);
	assign amo_buffer_valid = st_valid & (amo_op_q != 4'b0000);
	assign st_ready = store_buffer_ready; //  & amo_buffer_ready;

	output wire [7:0] store_state_o;
	assign store_state_o = {state_q_3, state_q_2, state_q_1, state_q_0};
	wire [1:0] state_q_0;
	wire [1:0] state_q_1;
	wire [1:0] state_q_2;
	wire [1:0] state_q_3;

	store_buffer store_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.no_st_pending_o(no_st_pending_o),
		.store_buffer_empty_o(store_buffer_empty_o),
		.page_offset_i(page_offset_i),
		.page_offset_matches_o(page_offset_matches_o),
		.commit_i(commit_i),
		.commit_ready_o(commit_ready_o),
		.ready_o(store_buffer_ready),
		.valid_i(store_buffer_valid),
		.valid_without_flush_i(st_valid_without_flush),
		.paddr_i(paddr_i),
		.data_i(st_data_q),
		.be_i(st_be_q),
		.data_size_i(st_data_size_q),
		.req_port_i(req_port_i),
		.req_port_o(req_port_o)
`ifdef EXPOSE_STATE
		, .state_q_0(state_q_0)
		, .state_q_1(state_q_1)
		, .state_q_2(state_q_2)
		, .state_q_3(state_q_3)
`endif
	);
	amo_buffer i_amo_buffer(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.valid_i(amo_buffer_valid),
		.ready_o(amo_buffer_ready),
		.paddr_i(paddr_i),
		.amo_op_i(amo_op_q),
		.data_i(st_data_q),
		.data_size_i(st_data_size_q),
		.amo_req_o(amo_req_o),
		.amo_resp_i(amo_resp_i),
		.amo_valid_commit_i(amo_valid_commit_i),
		.no_st_pending_i(no_st_pending_o)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 2'd0;
			st_be_q <= 1'sb0;
			st_data_q <= 1'sb0;
			st_data_size_q <= 1'sb0;
			trans_id_q <= 1'sb0;
			amo_op_q <= 4'b0000;
		end
		else begin
			state_q <= state_d;
			st_be_q <= st_be_n;
			st_data_q <= st_data_n;
			trans_id_q <= trans_id_n;
			st_data_size_q <= st_data_size_n;
			amo_op_q <= amo_op_d;
		end
endmodule
