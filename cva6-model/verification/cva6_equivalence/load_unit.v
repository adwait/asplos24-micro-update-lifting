module load_unit (
	clk_i,
	rst_ni,
	flush_i,
	valid_i,
	lsu_ctrl_i,
	pop_ld_o,
	valid_o,
	trans_id_o,
	result_o,
	ex_o,
	translation_req_o,
	vaddr_o,
	paddr_i,
	ex_i,
	dtlb_hit_i,
	dtlb_ppn_i,
	page_offset_o,
	page_offset_matches_i,
	store_buffer_empty_i,
	commit_tran_id_i,
	req_port_i,
	req_port_o,
	dcache_wbuffer_not_ni_i
`ifdef EXPOSE_STATE	
	, load_state_o
`endif
);
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire valid_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [84:0] lsu_ctrl_i;
	output reg pop_ld_o;
	output reg valid_o;
	output reg [2:0] trans_id_o;
	output reg [31:0] result_o;
	output reg [64:0] ex_o;
	output reg translation_req_o;
	output wire [31:0] vaddr_o;
	localparam riscv_PLEN = 34;
	input wire [33:0] paddr_i;
	input wire [64:0] ex_i;
	input wire dtlb_hit_i;
	localparam riscv_PPNW = 22;
	input wire [21:0] dtlb_ppn_i;
	output wire [11:0] page_offset_o;
	input wire page_offset_matches_i;
	input wire store_buffer_empty_i;
	input wire [2:0] commit_tran_id_i;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	input wire [34:0] req_port_i;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	output reg [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_o;
	input wire dcache_wbuffer_not_ni_i;
	reg [3:0] state_d;
	reg [3:0] state_q;
	localparam riscv_XLEN_ALIGN_BYTES = 2;
	reg [12:0] load_data_d;
	reg [12:0] load_data_q;
	wire [12:0] in_data;
	assign page_offset_o = lsu_ctrl_i[63:52];
	assign vaddr_o = lsu_ctrl_i[83-:32];
	wire [1:1] sv2v_tmp_52ECA;
	assign sv2v_tmp_52ECA = 1'b0;
	always @(*) req_port_o[8] = sv2v_tmp_52ECA;
	wire [32:1] sv2v_tmp_82AC4;
	assign sv2v_tmp_82AC4 = 1'sb0;
	always @(*) req_port_o[42-:32] = sv2v_tmp_82AC4;
	assign in_data = {lsu_ctrl_i[2-:ariane_pkg_TRANS_ID_BITS], lsu_ctrl_i[53:52], lsu_ctrl_i[10-:8]};
	wire [((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1) * 1:1] sv2v_tmp_0A7E4;
	assign sv2v_tmp_0A7E4 = lsu_ctrl_i[51 + ariane_pkg_DCACHE_INDEX_WIDTH:52];
	always @(*) req_port_o[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)] = sv2v_tmp_0A7E4;
	wire [((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42)) * 1:1] sv2v_tmp_500C1;
	assign sv2v_tmp_500C1 = paddr_i[(ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH) - 1:ariane_pkg_DCACHE_INDEX_WIDTH];
	always @(*) req_port_o[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))] = sv2v_tmp_500C1;
	wire [32:1] sv2v_tmp_C5B66;
	assign sv2v_tmp_C5B66 = ex_i[64-:32];
	always @(*) ex_o[64-:32] = sv2v_tmp_C5B66;
	wire [32:1] sv2v_tmp_39B40;
	assign sv2v_tmp_39B40 = ex_i[32-:32];
	always @(*) ex_o[32-:32] = sv2v_tmp_39B40;
	wire paddr_ni;
	wire not_commit_time;
	wire inflight_stores;
	wire stall_ni;

`ifdef EXPOSE_STATE
	output wire [1:0] load_state_o;
	assign load_state_o = state_q[1:0];
`endif

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
	function automatic ariane_pkg_is_inside_nonidempotent_regions;
		input reg [6433:0] Cfg;
		input reg [63:0] address;
		reg [15:0] pass;
		begin
			pass = 1'sb0;
			begin : sv2v_autoblock_1
				reg [31:0] k;
				for (k = 0; k < Cfg[6337-:32]; k = k + 1)
					pass[k] = ariane_pkg_range_check(Cfg[5282 + (k * 64)+:64], Cfg[4258 + (k * 64)+:64], address);
			end
			ariane_pkg_is_inside_nonidempotent_regions = |pass;
		end
	endfunction
	assign paddr_ni = 0; // ariane_pkg_is_inside_nonidempotent_regions(ArianeCfg, {dtlb_ppn_i, 12'd0});
	assign not_commit_time = commit_tran_id_i != lsu_ctrl_i[2-:ariane_pkg_TRANS_ID_BITS];
	assign inflight_stores = !dcache_wbuffer_not_ni_i || !store_buffer_empty_i;
	assign stall_ni = (inflight_stores || not_commit_time) && paddr_ni;
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
	always @(*) begin : load_control
		state_d = state_q;
		load_data_d = load_data_q;
		translation_req_o = 1'b0;
		req_port_o[9] = 1'b0;
		req_port_o[1] = 1'b0;
		req_port_o[0] = 1'b0;
		req_port_o[7-:4] = lsu_ctrl_i[18-:4];
		req_port_o[3-:2] = ariane_pkg_extract_transfer_size(lsu_ctrl_i[10-:8]);
		pop_ld_o = 1'b0;
		case (state_q)
			4'd0:
				if (valid_i) begin
					translation_req_o = 1'b1;
					if (!page_offset_matches_i) begin
						req_port_o[9] = 1'b1;
						if (!req_port_i[34])
							state_d = 4'd1;
						else if (dtlb_hit_i && !stall_ni) begin
							state_d = 4'd2;
							pop_ld_o = 1'b1;
						end
						else if (dtlb_hit_i && stall_ni)
							state_d = 4'd5;
						else
							state_d = 4'd4;
					end
					else
						state_d = 4'd3;
				end
			4'd3:
				if (!page_offset_matches_i)
					state_d = 4'd1;
			4'd4, 4'd5: begin
				req_port_o[1] = 1'b1;
				req_port_o[0] = 1'b1;
				state_d = (state_q == 4'd5 ? 4'd8 : 4'd6);
			end
			4'd8:
				if (dcache_wbuffer_not_ni_i)
					state_d = 4'd6;
			4'd6: begin
				translation_req_o = 1'b1;
				if (dtlb_hit_i)
					state_d = 4'd1;
			end
			4'd1: begin
				translation_req_o = 1'b1;
				req_port_o[9] = 1'b1;
				if (req_port_i[34])
					if (dtlb_hit_i && !stall_ni) begin
						state_d = 4'd2;
						pop_ld_o = 1'b1;
					end
					else if (dtlb_hit_i && stall_ni)
						state_d = 4'd5;
					else
						state_d = 4'd4;
			end
			4'd2: begin
				req_port_o[0] = 1'b1;
				state_d = 4'd0;
				if (valid_i) begin
					translation_req_o = 1'b1;
					if (!page_offset_matches_i) begin
						req_port_o[9] = 1'b1;
						if (!req_port_i[34])
							state_d = 4'd1;
						else if (dtlb_hit_i && !stall_ni) begin
							state_d = 4'd2;
							pop_ld_o = 1'b1;
						end
						else if (dtlb_hit_i && stall_ni)
							state_d = 4'd5;
						else
							state_d = 4'd4;
					end
					else
						state_d = 4'd3;
				end
				if (ex_i[0])
					req_port_o[1] = 1'b1;
			end
			4'd7: begin
				req_port_o[1] = 1'b1;
				req_port_o[0] = 1'b1;
				state_d = 4'd0;
			end
		endcase
		if (ex_i[0] && valid_i) begin
			state_d = 4'd0;
			if (!req_port_i[33])
				pop_ld_o = 1'b1;
		end
		if (pop_ld_o && !ex_i[0])
			load_data_d = in_data;
		if (flush_i)
			state_d = 4'd7;
	end
	always @(*) begin : rvalid_output
		valid_o = 1'b0;
		ex_o[0] = 1'b0;
		trans_id_o = load_data_q[12-:3];
		if (req_port_i[33] && (state_q != 4'd7)) begin
			if (!req_port_o[1])
				valid_o = 1'b1;
			if (ex_i[0] && (state_q == 4'd2)) begin
				valid_o = 1'b1;
				ex_o[0] = 1'b1;
			end
		end
		if ((valid_i && ex_i[0]) && !req_port_i[33]) begin
			valid_o = 1'b1;
			ex_o[0] = 1'b1;
			trans_id_o = lsu_ctrl_i[2-:ariane_pkg_TRANS_ID_BITS];
		end
		else if (state_q == 4'd6)
			valid_o = 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 4'd0;
			load_data_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			load_data_q <= load_data_d;
		end
	wire [31:0] shifted_data;
	assign shifted_data = req_port_i[32-:32] >> {load_data_q[9-:2], 3'b000};
	wire [3:0] sign_bits;
	wire [1:0] idx_d;
	reg [1:0] idx_q;
	wire sign_bit;
	wire signed_d;
	reg signed_q;
	wire fp_sign_d;
	reg fp_sign_q;
	assign signed_d = |{load_data_d[7-:8] == 8'd37, load_data_d[7-:8] == 8'd40, load_data_d[7-:8] == 8'd43};
	assign fp_sign_d = |{load_data_d[7-:8] == 8'd82, load_data_d[7-:8] == 8'd83, load_data_d[7-:8] == 8'd84};
	localparam riscv_IS_XLEN64 = 1'b0;
	assign idx_d = (|{load_data_d[7-:8] == 8'd37, load_data_d[7-:8] == 8'd82} & riscv_IS_XLEN64 ? load_data_d[9-:2] + 3 : (|{load_data_d[7-:8] == 8'd40, load_data_d[7-:8] == 8'd83} ? load_data_d[9-:2] + 1 : load_data_d[9-:2]));
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : gen_sign_bits
			assign sign_bits[i] = req_port_i[0 + ((i + 1) * 8)];
		end
	endgenerate
	assign sign_bit = (signed_q & sign_bits[idx_q]) | fp_sign_q;
	always @(*)
		case (load_data_q[7-:8])
			8'd37, 8'd38, 8'd82: result_o = {shifted_data[31:0]};
			8'd40, 8'd41, 8'd83: result_o = {{16 {sign_bit}}, shifted_data[15:0]};
			8'd43, 8'd45, 8'd84: result_o = {{24 {sign_bit}}, shifted_data[7:0]};
			default: result_o = shifted_data[31:0];
		endcase
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (~rst_ni) begin
			idx_q <= 0;
			signed_q <= 0;
			fp_sign_q <= 0;
		end
		else begin
			idx_q <= idx_d;
			signed_q <= signed_d;
			fp_sign_q <= fp_sign_d;
		end
	end
endmodule
