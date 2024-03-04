// `define WB_DEBUG

module wt_dcache_wbuffer (
	clk_i,
	rst_ni,
	cache_en_i,
	empty_o,
	not_ni_o,
	req_port_i,
	req_port_o,
	miss_ack_i,
	miss_paddr_o,
	miss_req_o,
	miss_we_o,
	miss_wdata_o,
	miss_wuser_o,
	miss_vld_bits_o,
	miss_nc_o,
	miss_size_o,
	miss_id_o,
	miss_rtrn_vld_i,
	miss_rtrn_id_i,
	rd_tag_o,
	rd_idx_o,
	rd_off_o,
	rd_req_o,
	rd_tag_only_o,
	rd_ack_i,
	rd_data_i,
	rd_vld_bits_i,
	rd_hit_oh_i,
	wr_cl_vld_i,
	wr_cl_idx_i,
	wr_req_o,
	wr_ack_i,
	wr_idx_o,
	wr_off_o,
	wr_data_o,
	wr_data_be_o,
	wr_user_o,
	wbuffer_data_o,
	tx_paddr_o,
	tx_vld_o,
	// For debug
	tx_stat_data_o,
	port_rd_hit_oh_q
`ifdef EXPOSE_STATE
	, write_ptr_o
	, redo_ptr_o
	, mem_ack_ptr_o
	, mem_resp_ptr_o
`endif
);
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire cache_en_i;
	output wire empty_o;
	output wire not_ni_o;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = 12;// $clog2(32'd32768 / 32'd8);
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_PLEN = 34;
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	input wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_i;
	output reg [34:0] req_port_o;
	input wire miss_ack_i;
	output wire [33:0] miss_paddr_o;
	output wire miss_req_o;
	output wire miss_we_o;
	output wire [31:0] miss_wdata_o;
	output wire [0:0] miss_wuser_o;
	output wire [7:0] miss_vld_bits_o;
	output wire miss_nc_o;
	output wire [2:0] miss_size_o;
	localparam wt_cache_pkg_L15_TID_WIDTH = 2;
	localparam wt_cache_pkg_CACHE_ID_WIDTH = wt_cache_pkg_L15_TID_WIDTH;
	output wire [1:0] miss_id_o;
	input wire miss_rtrn_vld_i;
	input wire [1:0] miss_rtrn_id_i;
	output wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] rd_tag_o;
	localparam [31:0] ariane_pkg_DCACHE_LINE_WIDTH = 128;
	localparam wt_cache_pkg_DCACHE_OFFSET_WIDTH = 4;
	localparam wt_cache_pkg_DCACHE_NUM_WORDS = 2 ** (ariane_pkg_DCACHE_INDEX_WIDTH - wt_cache_pkg_DCACHE_OFFSET_WIDTH);
	localparam wt_cache_pkg_DCACHE_CL_IDX_WIDTH = 8; // $clog2(wt_cache_pkg_DCACHE_NUM_WORDS);
	output wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] rd_idx_o;
	output wire [3:0] rd_off_o;
	output wire rd_req_o;
	output wire rd_tag_only_o;
	input wire rd_ack_i;
	input wire [31:0] rd_data_i;
	input wire [7:0] rd_vld_bits_i;
	input wire [7:0] rd_hit_oh_i;
	input wire wr_cl_vld_i;
	input wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_cl_idx_i;
	output reg [7:0] wr_req_o;
	input wire wr_ack_i;
	output wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_idx_o;
	output wire [3:0] wr_off_o;
	output wire [31:0] wr_data_o;
	output wire [3:0] wr_data_be_o;
	output wire [0:0] wr_user_o;
	localparam wt_cache_pkg_DCACHE_WBUF_DEPTH = 8;
	localparam riscv_XLEN_ALIGN_BYTES = 2;
	output wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] wbuffer_data_o;
	output wire [31:0] tx_stat_data_o;
	localparam wt_cache_pkg_DCACHE_MAX_TX = 4;
	output wire [135:0] tx_paddr_o;
	output wire [3:0] tx_vld_o;
	reg [31:0] tx_stat_d;
	reg [31:0] tx_stat_q;
	reg [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] wbuffer_d;
	reg [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] wbuffer_q;
	wire [7:0] valid;
	wire [7:0] dirty;
	wire [7:0] tocheck;
	wire [7:0] wbuffer_hit_oh;
	wire [7:0] inval_hit;
	wire [31:0] bdirty;
	wire [2:0] next_ptr;
	wire [2:0] dirty_ptr;
	wire [2:0] hit_ptr;
	wire [2:0] wr_ptr;
	wire [2:0] check_ptr_d;
	reg [2:0] check_ptr_q;
	reg [2:0] check_ptr_q1;
	wire [2:0] rtrn_ptr;
	wire [1:0] tx_id;
	wire [1:0] rtrn_id;
	wire [1:0] bdirty_off;
	wire [3:0] tx_be;
	wire [33:0] wr_paddr;
	wire [33:0] rd_paddr;
	wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] rd_tag_d;
	reg [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] rd_tag_q;
	wire [7:0] rd_hit_oh_d;
	reg [7:0] rd_hit_oh_q;
	wire check_en_d;
	reg check_en_q;
	reg check_en_q1;
	wire full;
	reg dirty_rd_en;
	wire rdy;
	wire rtrn_empty;
	reg evict;
	reg [7:0] ni_pending_d;
	reg [7:0] ni_pending_q;
	reg wbuffer_wren;
	wire free_tx_slots;
	reg wr_cl_vld_q;
	wire wr_cl_vld_d;
	reg [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_cl_idx_q;
	wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_cl_idx_d;
	wire [33:0] debug_paddr [7:0];
	wire [(((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC) - 1:0] wbuffer_check_mux;
	wire [(((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC) - 1:0] wbuffer_dirty_mux;
	wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] miss_tag;
	wire is_nc_miss;
	wire is_ni;
	assign miss_tag = miss_paddr_o[ariane_pkg_DCACHE_INDEX_WIDTH+:ariane_pkg_DCACHE_TAG_WIDTH];

	output wire [2:0] write_ptr_o;
	// reg [2:0] reg_write_ptr_o;
	assign write_ptr_o = wr_ptr;
	output wire [2:0] redo_ptr_o;
	// reg [2:0] reg_redo_ptr_o;
	assign redo_ptr_o = wr_ptr;
	output wire [2:0] mem_ack_ptr_o;
	// reg [2:0] reg_mem_ack_ptr_o;
	assign mem_ack_ptr_o = dirty_ptr;
	output wire [2:0] mem_resp_ptr_o;
	// reg [2:0] reg_mem_resp_ptr_o;
	assign mem_resp_ptr_o = rtrn_ptr;

output wire [7:0] port_rd_hit_oh_q;
assign port_rd_hit_oh_q = rd_hit_oh_d;


	function automatic [64:0] sv2v_cast_65;
		input reg [64:0] inp;
		sv2v_cast_65 = inp;
	endfunction
	function automatic ariane_pkg_range_check;
		input reg [63:0] base;
		input reg [63:0] len;
		input reg [63:0] address;
		ariane_pkg_range_check = (address >= base) && (address < (sv2v_cast_65(base) + len));
	endfunction
	function automatic ariane_pkg_is_inside_cacheable_regions;
		input reg [6433:0] Cfg;
		input reg [63:0] address;
		reg [15:0] pass;
		begin
			pass = 1'sb0;
			begin : sv2v_autoblock_1
				reg [31:0] k;
				for (k = 0; k < Cfg[2177-:32]; k = k + 1)
					pass[k] = ariane_pkg_range_check(Cfg[1122 + (k * 64)+:64], Cfg[98 + (k * 64)+:64], address);
			end
			ariane_pkg_is_inside_cacheable_regions = |pass;
		end
	endfunction
	assign is_nc_miss = !ariane_pkg_is_inside_cacheable_regions(ArianeCfg, {{(64 - ariane_pkg_DCACHE_TAG_WIDTH) - ariane_pkg_DCACHE_INDEX_WIDTH {1'b0}}, miss_tag, {ariane_pkg_DCACHE_INDEX_WIDTH {1'b0}}});
	assign miss_nc_o = !cache_en_i || is_nc_miss;
	function automatic ariane_pkg_is_inside_nonidempotent_regions;
		input reg [6433:0] Cfg;
		input reg [63:0] address;
		reg [15:0] pass;
		begin
			pass = 1'sb0;
			begin : sv2v_autoblock_2
				reg [31:0] k;
				for (k = 0; k < Cfg[6337-:32]; k = k + 1)
					pass[k] = ariane_pkg_range_check(Cfg[5282 + (k * 64)+:64], Cfg[4258 + (k * 64)+:64], address);
			end
			ariane_pkg_is_inside_nonidempotent_regions = |pass;
		end
	endfunction
	assign is_ni = 0; //ariane_pkg_is_inside_nonidempotent_regions(ArianeCfg, {{(64 - ariane_pkg_DCACHE_TAG_WIDTH) - ariane_pkg_DCACHE_INDEX_WIDTH {1'b0}}, req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))], {ariane_pkg_DCACHE_INDEX_WIDTH {1'b0}}});
	assign miss_we_o = 1'b1;
	assign miss_vld_bits_o = 1'sb0;
	assign wbuffer_data_o = wbuffer_q;
	assign tx_stat_data_o = tx_stat_q;
	genvar k;
	generate
		for (k = 0; k < wt_cache_pkg_DCACHE_MAX_TX; k = k + 1) begin : gen_tx_vld
			assign tx_vld_o[k] = tx_stat_q[(k * 8) + 7];
			assign tx_paddr_o[k * 34+:34] = wbuffer_q[(tx_stat_q[(k * 8) + 2-:3] * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53)-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] << riscv_XLEN_ALIGN_BYTES;
		end
	endgenerate
	lzc #(.WIDTH(4)) i_vld_bdirty(
		.in_i(bdirty[dirty_ptr * 4+:4]),
		.cnt_o(bdirty_off),
		.empty_o()
	);
	assign miss_paddr_o = {wbuffer_dirty_mux[(ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))], bdirty_off};
	assign miss_id_o = tx_id;
	assign miss_req_o = |dirty && free_tx_slots;
	localparam riscv_IS_XLEN64 = 1'b0;
	function automatic [1:0] wt_cache_pkg_toSize32;
		input reg [3:0] be;
		reg [1:0] size;
		begin
			case (be)
				4'b1111: size = 2'b10;
				4'b1100, 4'b0011: size = 2'b01;
				default: size = 2'b00;
			endcase
			wt_cache_pkg_toSize32 = size;
		end
	endfunction
	function automatic [1:0] wt_cache_pkg_toSize64;
		input reg [7:0] be;
		reg [1:0] size;
		begin
			case (be)
				8'b11111111: size = 2'b11;
				8'b00001111, 8'b11110000: size = 2'b10;
				8'b11000000, 8'b00110000, 8'b00001100, 8'b00000011: size = 2'b01;
				default: size = 2'b00;
			endcase
			wt_cache_pkg_toSize64 = size;
		end
	endfunction
	assign miss_size_o = (riscv_IS_XLEN64 ? wt_cache_pkg_toSize64(bdirty[dirty_ptr * 4+:4]) : wt_cache_pkg_toSize32(bdirty[dirty_ptr * 4+:4]));
	function automatic [31:0] wt_cache_pkg_repData32;
		input reg [31:0] data;
		input reg [1:0] offset;
		input reg [1:0] size;
		reg [31:0] out;
		begin
			case (size)
				2'b00: begin : sv2v_autoblock_3
					reg signed [31:0] k;
					for (k = 0; k < 4; k = k + 1)
						out[k * 8+:8] = data[offset * 8+:8];
				end
				2'b01: begin : sv2v_autoblock_4
					reg signed [31:0] k;
					for (k = 0; k < 2; k = k + 1)
						out[k * 16+:16] = data[offset * 8+:16];
				end
				default: out = data;
			endcase
			wt_cache_pkg_repData32 = out;
		end
	endfunction
	function automatic [63:0] wt_cache_pkg_repData64;
		input reg [63:0] data;
		input reg [2:0] offset;
		input reg [1:0] size;
		reg [63:0] out;
		begin
			case (size)
				2'b00: begin : sv2v_autoblock_5
					reg signed [31:0] k;
					for (k = 0; k < 8; k = k + 1)
						out[k * 8+:8] = data[offset * 8+:8];
				end
				2'b01: begin : sv2v_autoblock_6
					reg signed [31:0] k;
					for (k = 0; k < 4; k = k + 1)
						out[k * 16+:16] = data[offset * 8+:16];
				end
				2'b10: begin : sv2v_autoblock_7
					reg signed [31:0] k;
					for (k = 0; k < 2; k = k + 1)
						out[k * 32+:32] = data[offset * 8+:32];
				end
				default: out = data;
			endcase
			wt_cache_pkg_repData64 = out;
		end
	endfunction
	assign miss_wdata_o = (riscv_IS_XLEN64 ? wt_cache_pkg_repData64(wbuffer_dirty_mux[53-:32], bdirty_off, miss_size_o[1:0]) : wt_cache_pkg_repData32(wbuffer_dirty_mux[53-:32], bdirty_off, miss_size_o[1:0]));
	assign miss_wuser_o = (riscv_IS_XLEN64 ? wt_cache_pkg_repData64(wbuffer_dirty_mux[21-:1], bdirty_off, miss_size_o[1:0]) : wt_cache_pkg_repData32(wbuffer_dirty_mux[21-:1], bdirty_off, miss_size_o[1:0]));
	function automatic [3:0] wt_cache_pkg_to_byte_enable4;
		input reg [1:0] offset;
		input reg [1:0] size;
		reg [3:0] be;
		begin
			be = 1'sb0;
			case (size)
				2'b00: be[offset] = 1'sb1;
				2'b01: be[offset+:2] = 1'sb1;
				default: be = 1'sb1;
			endcase
			wt_cache_pkg_to_byte_enable4 = be;
		end
	endfunction
	function automatic [7:0] wt_cache_pkg_to_byte_enable8;
		input reg [2:0] offset;
		input reg [1:0] size;
		reg [7:0] be;
		begin
			be = 1'sb0;
			case (size)
				2'b00: be[offset] = 1'sb1;
				2'b01: be[offset+:2] = 1'sb1;
				2'b10: be[offset+:4] = 1'sb1;
				default: be = 1'sb1;
			endcase
			wt_cache_pkg_to_byte_enable8 = be;
		end
	endfunction
	assign tx_be = (riscv_IS_XLEN64 ? wt_cache_pkg_to_byte_enable8(bdirty_off, miss_size_o[1:0]) : wt_cache_pkg_to_byte_enable4(bdirty_off, miss_size_o[1:0]));
	fifo_v3 #(
		.FALL_THROUGH(1'b0),
		.DATA_WIDTH(2),
		.DEPTH(wt_cache_pkg_DCACHE_MAX_TX)
	) i_rtrn_id_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'b0),
		.testmode_i(1'b0),
		.full_o(),
		.empty_o(rtrn_empty),
		.usage_o(),
		.data_i(miss_rtrn_id_i),
		.push_i(miss_rtrn_vld_i),
		.data_o(rtrn_id),
		.pop_i(evict)
	);
	always @(*) begin : p_tx_stat
		tx_stat_d = tx_stat_q;
		evict = 1'b0;
		wr_req_o = 1'sb0;
		if (!rtrn_empty && wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8])
			if (|wr_data_be_o && |wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 7-:ariane_pkg_DCACHE_SET_ASSOC]) begin
				wr_req_o = wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 7-:ariane_pkg_DCACHE_SET_ASSOC];
				if (wr_ack_i) begin
					evict = 1'b1;
					tx_stat_d[(rtrn_id * 8) + 7] = 1'b0;
				end
			end
			else begin
				evict = 1'b1;
				tx_stat_d[(rtrn_id * 8) + 7] = 1'b0;
			end
		if (dirty_rd_en) begin
			tx_stat_d[(tx_id * 8) + 7] = 1'b1;
			tx_stat_d[(tx_id * 8) + 2-:3] = dirty_ptr;
			tx_stat_d[(tx_id * 8) + 6-:4] = tx_be;
		end
	end
	assign free_tx_slots = |(~tx_vld_o);
	rr_arb_tree #(
		.NumIn(wt_cache_pkg_DCACHE_MAX_TX),
		.LockIn(1'b1),
		.DataWidth(1)
	) i_tx_id_rr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'sb0),
		.rr_i(2'sb0),
		.req_i(~tx_vld_o),
		.gnt_o(),
		.data_i(4'sb0),
		.gnt_i(dirty_rd_en),
		.req_o(),
		.data_o(),
		.idx_o(tx_id)
	);
	assign rd_tag_d = rd_paddr >> ariane_pkg_DCACHE_INDEX_WIDTH;
	assign rd_tag_only_o = 1'b1;
	assign rd_paddr = wbuffer_check_mux[(ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] << riscv_XLEN_ALIGN_BYTES;
	assign rd_req_o = |tocheck;
	assign rd_tag_o = rd_tag_q;
	assign rd_idx_o = rd_paddr[ariane_pkg_DCACHE_INDEX_WIDTH - 1:wt_cache_pkg_DCACHE_OFFSET_WIDTH];
	assign rd_off_o = rd_paddr[3:0];
	assign check_en_d = rd_req_o & rd_ack_i;
	assign rtrn_ptr = tx_stat_q[(rtrn_id * 8) + 2-:3];
	assign wr_data_be_o = tx_stat_q[(rtrn_id * 8) + 6-:4] & ~wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 20-:4];
	assign wr_paddr = wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53)-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] << riscv_XLEN_ALIGN_BYTES;
	assign wr_idx_o = wr_paddr[ariane_pkg_DCACHE_INDEX_WIDTH - 1:wt_cache_pkg_DCACHE_OFFSET_WIDTH];
	assign wr_off_o = wr_paddr[3:0];
	assign wr_data_o = wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 53-:32];
	assign wr_user_o = wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 21-:1];
	wire [(8 * wt_cache_pkg_DCACHE_CL_IDX_WIDTH) - 1:0] wtag_comp;
	assign wr_cl_vld_d = wr_cl_vld_i;
	assign wr_cl_idx_d = wr_cl_idx_i;
	generate
		for (k = 0; k < wt_cache_pkg_DCACHE_WBUF_DEPTH; k = k + 1) begin : gen_flags
			assign debug_paddr[k] = wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53)-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] << riscv_XLEN_ALIGN_BYTES;
			assign bdirty[k * 4+:4] = (|wbuffer_q[(k * ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 54)) + 12-:4] ? {4 {1'sb0}} : wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 20-:4] & wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 16-:4]);
			assign dirty[k] = |bdirty[k * 4+:4];
			assign valid[k] = |wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 16-:4];
			assign wbuffer_hit_oh[k] = valid[k] & (wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53)-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] == {req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))], req_port_i[(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - ((ariane_pkg_DCACHE_INDEX_WIDTH - 1) - (ariane_pkg_DCACHE_INDEX_WIDTH - 1)):(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - ((ariane_pkg_DCACHE_INDEX_WIDTH - 1) - riscv_XLEN_ALIGN_BYTES)]});
			assign wtag_comp[k * wt_cache_pkg_DCACHE_CL_IDX_WIDTH+:wt_cache_pkg_DCACHE_CL_IDX_WIDTH] = wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 1) - (ariane_pkg_DCACHE_INDEX_WIDTH - 3))) >= (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 3)) ? ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1)) : ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1))) + ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 1) - (ariane_pkg_DCACHE_INDEX_WIDTH - 3))) >= (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 3)) ? ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1))) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 3))) + 1 : ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 3)) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1)))) + 1)) - 1)-:((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 1) - (ariane_pkg_DCACHE_INDEX_WIDTH - 3))) >= (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - 2)) - 3)) ? ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1))) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 3))) + 1 : ((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 3)) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) - (((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) - 1) - ((ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) - 1)))) + 1)];
			assign inval_hit[k] = ((wr_cl_vld_d & valid[k]) & (wtag_comp[k * wt_cache_pkg_DCACHE_CL_IDX_WIDTH+:wt_cache_pkg_DCACHE_CL_IDX_WIDTH] == wr_cl_idx_d)) | ((wr_cl_vld_q & valid[k]) & (wtag_comp[k * wt_cache_pkg_DCACHE_CL_IDX_WIDTH+:wt_cache_pkg_DCACHE_CL_IDX_WIDTH] == wr_cl_idx_q));
			assign tocheck[k] = ~wbuffer_q[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8] & valid[k];
		end
	endgenerate
	assign wr_ptr = (|wbuffer_hit_oh ? hit_ptr : next_ptr);
	assign rdy = |wbuffer_hit_oh | ~full;
	lzc #(.WIDTH(wt_cache_pkg_DCACHE_WBUF_DEPTH)) i_vld_lzc(
		.in_i(~valid),
		.cnt_o(next_ptr),
		.empty_o(full)
	);
	lzc #(.WIDTH(wt_cache_pkg_DCACHE_WBUF_DEPTH)) i_hit_lzc(
		.in_i(wbuffer_hit_oh),
		.cnt_o(hit_ptr),
		.empty_o()
	);
	// rr_arb_tree_14F7C_E5B9D 
	rr_arb_tree #(
		// .DataType_ariane_pkg_DCACHE_INDEX_WIDTH(ariane_pkg_DCACHE_INDEX_WIDTH),
		// .DataType_ariane_pkg_DCACHE_SET_ASSOC(ariane_pkg_DCACHE_SET_ASSOC),
		// .DataType_ariane_pkg_DCACHE_TAG_WIDTH(ariane_pkg_DCACHE_TAG_WIDTH),
		// .DataType_ariane_pkg_DCACHE_USER_WIDTH(ariane_pkg_DCACHE_USER_WIDTH),
		// .DataType_riscv_XLEN(riscv_XLEN),
		// .DataType_riscv_XLEN_ALIGN_BYTES(riscv_XLEN_ALIGN_BYTES),
		.NumIn(wt_cache_pkg_DCACHE_WBUF_DEPTH),
		.DataWidth(86),
		.LockIn(1'b1)
	) i_dirty_rr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'sb0),
		.rr_i(3'sb0),
		.req_i(dirty),
		.gnt_o(),
		.data_i(wbuffer_q),
		.gnt_i(dirty_rd_en),
		.req_o(),
		.data_o(wbuffer_dirty_mux),
		.idx_o(dirty_ptr)
	);
	// rr_arb_tree_14F7C_E5B9D
	rr_arb_tree #(
		// .DataType_ariane_pkg_DCACHE_INDEX_WIDTH(ariane_pkg_DCACHE_INDEX_WIDTH),
		// .DataType_ariane_pkg_DCACHE_SET_ASSOC(ariane_pkg_DCACHE_SET_ASSOC),
		// .DataType_ariane_pkg_DCACHE_TAG_WIDTH(ariane_pkg_DCACHE_TAG_WIDTH),
		// .DataType_ariane_pkg_DCACHE_USER_WIDTH(ariane_pkg_DCACHE_USER_WIDTH),
		// .DataType_riscv_XLEN(riscv_XLEN),
		// .DataType_riscv_XLEN_ALIGN_BYTES(riscv_XLEN_ALIGN_BYTES),
		.NumIn(wt_cache_pkg_DCACHE_WBUF_DEPTH),
		.DataWidth(86)
	) i_clean_rr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'sb0),
		.rr_i(3'sb0),
		.req_i(tocheck),
		.gnt_o(),
		.data_i(wbuffer_q),
		.gnt_i(check_en_d),
		.req_o(),
		.data_o(wbuffer_check_mux),
		.idx_o(check_ptr_d)
	);
	wire [1:1] sv2v_tmp_AD78A;
	assign sv2v_tmp_AD78A = 1'sb0;
	always @(*) req_port_o[33] = sv2v_tmp_AD78A;
	wire [32:1] sv2v_tmp_D43F8;
	assign sv2v_tmp_D43F8 = 1'sb0;
	always @(*) req_port_o[32-:32] = sv2v_tmp_D43F8;
	wire [1:1] sv2v_tmp_3FCC7;
	assign sv2v_tmp_3FCC7 = 1'sb0;
	always @(*) req_port_o[0-:ariane_pkg_DCACHE_USER_WIDTH] = sv2v_tmp_3FCC7;
	assign rd_hit_oh_d = rd_hit_oh_i;
	wire ni_inside;
	wire ni_conflict;
	assign ni_inside = |ni_pending_q;
	assign ni_conflict = is_ni && ni_inside;
	assign not_ni_o = !ni_inside;
	assign empty_o = !(|valid);
	localparam ariane_pkg_DATA_USER_EN = cva6_config_pkg_CVA6ConfigDataUserEn;
	always @(*) begin : p_buffer
		wbuffer_d = wbuffer_q;
		ni_pending_d = ni_pending_q;
		dirty_rd_en = 1'b0;
		req_port_o[34] = 1'b0;
		wbuffer_wren = 1'b0;

		if (check_en_q1)
			if (wbuffer_q[(check_ptr_q1 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 16-:4]) begin

`ifdef WB_DEBUG
		$display("| Time: %d, Lookup returned, Way: %d, Index: %d", CLK_CYCLE, rd_hit_oh_q
		, (check_ptr_q1 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8);
		$display("=========================================");
`endif
				wbuffer_d[(check_ptr_q1 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8] = 1'b1;
				wbuffer_d[(check_ptr_q1 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 7-:ariane_pkg_DCACHE_SET_ASSOC] = rd_hit_oh_q;
			end
		begin : sv2v_autoblock_8
			reg signed [31:0] k;
			for (k = 0; k < wt_cache_pkg_DCACHE_WBUF_DEPTH; k = k + 1)
				if (inval_hit[k]) begin
`ifdef WB_DEBUG
		$display("| Time: %d, Invalidation A happening", CLK_CYCLE);
        $display("=========================================");
`endif
					wbuffer_d[(k * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8] = 1'b0;
				end
		end
		if (evict) begin
			begin : sv2v_autoblock_9
				reg signed [31:0] k;
				for (k = 0; k < 4; k = k + 1)
					if (tx_stat_q[(rtrn_id * 8) + (3 + k)]) begin
						wbuffer_d[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (9 + k)] = 1'b0;
						if (!wbuffer_q[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (17 + k)])
							wbuffer_d[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (13 + k)] = 1'b0;
					end
			end
			if (wbuffer_d[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 16-:4] == 0) begin

`ifdef WB_DEBUG
		$display("| Time: %d, Clearing due to completion", CLK_CYCLE);
        $display("=========================================");
`endif
				wbuffer_d[(rtrn_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8] = 1'b0;
				ni_pending_d[rtrn_ptr] = 1'b0;
			end
		end
		if (miss_req_o && miss_ack_i) begin
			dirty_rd_en = 1'b1;
			begin : sv2v_autoblock_10
				reg signed [31:0] k;
				for (k = 0; k < 4; k = k + 1)
					if (tx_be[k]) begin
						wbuffer_d[(dirty_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (17 + k)] = 1'b0;
						wbuffer_d[(dirty_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (9 + k)] = 1'b1;
					end
			end
		end
		if (req_port_i[9] && rdy)
			if (!ni_conflict) begin
				wbuffer_wren = 1'b1;
				req_port_o[34] = 1'b1;
				ni_pending_d[wr_ptr] = is_ni;
				wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + 8] = 1'b0;
				wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53)-:(((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53) >= 54 ? ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES) : 55 - ((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + 53))] = {req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))], req_port_i[(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - ((ariane_pkg_DCACHE_INDEX_WIDTH - 1) - (ariane_pkg_DCACHE_INDEX_WIDTH - 1)):(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - ((ariane_pkg_DCACHE_INDEX_WIDTH - 1) - riscv_XLEN_ALIGN_BYTES)]};
				begin : sv2v_autoblock_11
					reg signed [31:0] k;
					for (k = 0; k < 4; k = k + 1) begin
`ifdef WB_DEBUG		
		$display("| Time: %d, Invalidation B happening", CLK_CYCLE);
        $display("=========================================");
`endif
						if (req_port_i[4 + k]) begin
							wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (13 + k)] = 1'b1;
							wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (17 + k)] = 1'b1;
							wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (22 + (k * 8))+:8] = req_port_i[11 + (k * 8)+:8];
							if (ariane_pkg_DATA_USER_EN)
								wbuffer_d[(wr_ptr * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) + (21 + (k * 8))+:8] = req_port_i[10 + (k * 8)+:8];
						end
					end
				end
			end
	end
	function automatic [(((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC) - 1:0] sv2v_cast_43C66;
		input reg [(((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC) - 1:0] inp;
		sv2v_cast_43C66 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_BB1B5;
		input reg [7:0] inp;
		sv2v_cast_BB1B5 = inp;
	endfunction

	reg [32:0] CLK_CYCLE;

	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			CLK_CYCLE <= 0;
			wbuffer_q <= {wt_cache_pkg_DCACHE_WBUF_DEPTH {sv2v_cast_43C66(1'sb0)}};
			tx_stat_q <= {wt_cache_pkg_DCACHE_MAX_TX {sv2v_cast_BB1B5(1'sb0)}};
			ni_pending_q <= 1'sb0;
			check_ptr_q <= 1'sb0;
			check_ptr_q1 <= 1'sb0;
			check_en_q <= 1'sb0;
			check_en_q1 <= 1'sb0;
			rd_tag_q <= 1'sb0;
			rd_hit_oh_q <= 1'sb0;
			wr_cl_vld_q <= 1'sb0;
			wr_cl_idx_q <= 1'sb0;
		end
		else begin
			CLK_CYCLE <= CLK_CYCLE + 1;
			wbuffer_q <= wbuffer_d;
			tx_stat_q <= tx_stat_d;
			ni_pending_q <= ni_pending_d;
			check_ptr_q <= check_ptr_d;
			check_ptr_q1 <= check_ptr_q;
			check_en_q <= check_en_d;
			check_en_q1 <= check_en_q;
			rd_tag_q <= rd_tag_d;
			rd_hit_oh_q <= rd_hit_oh_d;
			wr_cl_vld_q <= wr_cl_vld_d;
			wr_cl_idx_q <= wr_cl_idx_d;
`ifdef WB_DEBUG
			$display("| Time: %d, valid: %b, bdirty: %b dirty: %b, dirty_off: %b, miss_size: %b, dirty_ptr: %d, be: %b", CLK_CYCLE, valid, bdirty, dirty, bdirty_off, miss_size_o, dirty_ptr, tx_be);
			$display("=========================================");
`endif
		end
	end
	generate
		for (k = 0; k < wt_cache_pkg_DCACHE_WBUF_DEPTH; k = k + 1) begin : gen_assert1
			genvar j;
		end
	endgenerate
endmodule
