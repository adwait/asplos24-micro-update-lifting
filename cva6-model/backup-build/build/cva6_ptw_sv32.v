module cva6_ptw_sv32 (
	clk_i,
	rst_ni,
	flush_i,
	ptw_active_o,
	walking_instr_o,
	ptw_error_o,
	ptw_access_exception_o,
	enable_translation_i,
	en_ld_st_translation_i,
	lsu_is_store_i,
	req_port_i,
	req_port_o,
	itlb_update_o,
	dtlb_update_o,
	update_vaddr_o,
	asid_i,
	itlb_access_i,
	itlb_hit_i,
	itlb_vaddr_i,
	dtlb_access_i,
	dtlb_hit_i,
	dtlb_vaddr_i,
	satp_ppn_i,
	mxr_i,
	itlb_miss_o,
	dtlb_miss_o,
	pmpcfg_i,
	pmpaddr_i,
	bad_paddr_o
);
	parameter signed [31:0] ASID_WIDTH = 1;
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	output wire ptw_active_o;
	output wire walking_instr_o;
	output reg ptw_error_o;
	output reg ptw_access_exception_o;
	input wire enable_translation_i;
	input wire en_ld_st_translation_i;
	input wire lsu_is_store_i;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [34:0] req_port_i;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam riscv_PLEN = 34;
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	output reg [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_o;
	output reg [62:0] itlb_update_o;
	output reg [62:0] dtlb_update_o;
	localparam riscv_VLEN = 32;
	output wire [31:0] update_vaddr_o;
	input wire [ASID_WIDTH - 1:0] asid_i;
	input wire itlb_access_i;
	input wire itlb_hit_i;
	input wire [31:0] itlb_vaddr_i;
	input wire dtlb_access_i;
	input wire dtlb_hit_i;
	input wire [31:0] dtlb_vaddr_i;
	localparam riscv_PPNW = 22;
	input wire [21:0] satp_ppn_i;
	input wire mxr_i;
	output reg itlb_miss_o;
	output reg dtlb_miss_o;
	input wire [127:0] pmpcfg_i;
	input wire [511:0] pmpaddr_i;
	output wire [33:0] bad_paddr_o;
	reg data_rvalid_q;
	reg [31:0] data_rdata_q;
	wire [31:0] pte;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	assign pte = sv2v_cast_32(data_rdata_q);
	reg [2:0] state_q;
	reg [2:0] state_d;
	reg ptw_lvl_q;
	reg ptw_lvl_n;
	reg is_instr_ptw_q;
	reg is_instr_ptw_n;
	reg global_mapping_q;
	reg global_mapping_n;
	reg tag_valid_n;
	reg tag_valid_q;
	reg [ASID_WIDTH - 1:0] tlb_update_asid_q;
	reg [ASID_WIDTH - 1:0] tlb_update_asid_n;
	reg [31:0] vaddr_q;
	reg [31:0] vaddr_n;
	reg [33:0] ptw_pptr_q;
	reg [33:0] ptw_pptr_n;
	assign update_vaddr_o = vaddr_q;
	assign ptw_active_o = state_q != 3'd0;
	assign walking_instr_o = is_instr_ptw_q;
	wire [((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1) * 1:1] sv2v_tmp_E9073;
	assign sv2v_tmp_E9073 = ptw_pptr_q[ariane_pkg_DCACHE_INDEX_WIDTH - 1:0];
	always @(*) req_port_o[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)] = sv2v_tmp_E9073;
	wire [((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42)) * 1:1] sv2v_tmp_7E4B3;
	assign sv2v_tmp_7E4B3 = ptw_pptr_q[(ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) - 1:ariane_pkg_DCACHE_INDEX_WIDTH];
	always @(*) req_port_o[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))] = sv2v_tmp_7E4B3;
	wire [1:1] sv2v_tmp_7ADE6;
	assign sv2v_tmp_7ADE6 = 1'sb0;
	always @(*) req_port_o[1] = sv2v_tmp_7ADE6;
	wire [32:1] sv2v_tmp_82AC4;
	assign sv2v_tmp_82AC4 = 1'sb0;
	always @(*) req_port_o[42-:32] = sv2v_tmp_82AC4;
	localparam [3:0] riscv_MODE_SV = 4'd1;
	localparam riscv_SV = (riscv_MODE_SV == 4'd1 ? 32 : 39);
	wire [20:1] sv2v_tmp_C842C;
	assign sv2v_tmp_C842C = vaddr_q[riscv_SV - 1:12];
	always @(*) itlb_update_o[60-:20] = sv2v_tmp_C842C;
	wire [20:1] sv2v_tmp_7BECB;
	assign sv2v_tmp_7BECB = vaddr_q[riscv_SV - 1:12];
	always @(*) dtlb_update_o[60-:20] = sv2v_tmp_7BECB;
	wire [1:1] sv2v_tmp_DA1A0;
	assign sv2v_tmp_DA1A0 = ptw_lvl_q == 1'd0;
	always @(*) itlb_update_o[61] = sv2v_tmp_DA1A0;
	wire [1:1] sv2v_tmp_22011;
	assign sv2v_tmp_22011 = ptw_lvl_q == 1'd0;
	always @(*) dtlb_update_o[61] = sv2v_tmp_22011;
	wire [9:1] sv2v_tmp_14BA6;
	assign sv2v_tmp_14BA6 = tlb_update_asid_q;
	always @(*) itlb_update_o[40-:9] = sv2v_tmp_14BA6;
	wire [9:1] sv2v_tmp_5EC01;
	assign sv2v_tmp_5EC01 = tlb_update_asid_q;
	always @(*) dtlb_update_o[40-:9] = sv2v_tmp_5EC01;
	wire [32:1] sv2v_tmp_AC7A4;
	assign sv2v_tmp_AC7A4 = pte | (global_mapping_q << 5);
	always @(*) itlb_update_o[31-:32] = sv2v_tmp_AC7A4;
	wire [32:1] sv2v_tmp_29929;
	assign sv2v_tmp_29929 = pte | (global_mapping_q << 5);
	always @(*) dtlb_update_o[31-:32] = sv2v_tmp_29929;
	wire [1:1] sv2v_tmp_7C039;
	assign sv2v_tmp_7C039 = tag_valid_q;
	always @(*) req_port_o[0] = sv2v_tmp_7C039;
	wire allow_access;
	assign bad_paddr_o = (ptw_access_exception_o ? ptw_pptr_q : 'b0);
	pmp #(
		.PLEN(riscv_PLEN),
		.PMP_LEN(32),
		.NR_ENTRIES(ArianeCfg[31-:32])
	) i_pmp_ptw(
		.addr_i(ptw_pptr_q),
		.priv_lvl_i(2'b01),
		.access_type_i(3'b001),
		.conf_addr_i(pmpaddr_i),
		.conf_i(pmpcfg_i),
		.allow_o(allow_access)
	);
	function automatic [3:0] ariane_pkg_be_gen_32;
		input reg [1:0] addr;
		input reg [1:0] size;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			case (size)
				2'b10: begin
					ariane_pkg_be_gen_32 = 4'b1111;
					_sv2v_jump = 2'b11;
				end
				2'b01:
					case (addr[1:0])
						2'b00: begin
							ariane_pkg_be_gen_32 = 4'b0011;
							_sv2v_jump = 2'b11;
						end
						2'b01: begin
							ariane_pkg_be_gen_32 = 4'b0110;
							_sv2v_jump = 2'b11;
						end
						2'b10: begin
							ariane_pkg_be_gen_32 = 4'b1100;
							_sv2v_jump = 2'b11;
						end
					endcase
				2'b00:
					case (addr[1:0])
						2'b00: begin
							ariane_pkg_be_gen_32 = 4'b0001;
							_sv2v_jump = 2'b11;
						end
						2'b01: begin
							ariane_pkg_be_gen_32 = 4'b0010;
							_sv2v_jump = 2'b11;
						end
						2'b10: begin
							ariane_pkg_be_gen_32 = 4'b0100;
							_sv2v_jump = 2'b11;
						end
						2'b11: begin
							ariane_pkg_be_gen_32 = 4'b1000;
							_sv2v_jump = 2'b11;
						end
					endcase
				default: begin
					ariane_pkg_be_gen_32 = 4'b0000;
					_sv2v_jump = 2'b11;
				end
			endcase
			if (_sv2v_jump == 2'b00) begin
				ariane_pkg_be_gen_32 = 4'b0000;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	wire [4:1] sv2v_tmp_EB02D;
	assign sv2v_tmp_EB02D = ariane_pkg_be_gen_32(req_port_o[(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_INDEX_WIDTH - 2):(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_INDEX_WIDTH - 1)], req_port_o[3-:2]);
	always @(*) req_port_o[7-:4] = sv2v_tmp_EB02D;
	always @(*) begin : ptw
		tag_valid_n = 1'b0;
		req_port_o[9] = 1'b0;
		req_port_o[3-:2] = 2'b10;
		req_port_o[8] = 1'b0;
		ptw_error_o = 1'b0;
		ptw_access_exception_o = 1'b0;
		itlb_update_o[62] = 1'b0;
		dtlb_update_o[62] = 1'b0;
		is_instr_ptw_n = is_instr_ptw_q;
		ptw_lvl_n = ptw_lvl_q;
		ptw_pptr_n = ptw_pptr_q;
		state_d = state_q;
		global_mapping_n = global_mapping_q;
		tlb_update_asid_n = tlb_update_asid_q;
		vaddr_n = vaddr_q;
		itlb_miss_o = 1'b0;
		dtlb_miss_o = 1'b0;
		case (state_q)
			3'd0: begin
				ptw_lvl_n = 1'd0;
				global_mapping_n = 1'b0;
				is_instr_ptw_n = 1'b0;
				if (((enable_translation_i & itlb_access_i) & ~itlb_hit_i) & ~dtlb_access_i) begin
					ptw_pptr_n = {satp_ppn_i, itlb_vaddr_i[riscv_SV - 1:22], 2'b00};
					is_instr_ptw_n = 1'b1;
					tlb_update_asid_n = asid_i;
					vaddr_n = itlb_vaddr_i;
					state_d = 3'd1;
					itlb_miss_o = 1'b1;
				end
				else if ((en_ld_st_translation_i & dtlb_access_i) & ~dtlb_hit_i) begin
					ptw_pptr_n = {satp_ppn_i, dtlb_vaddr_i[riscv_SV - 1:22], 2'b00};
					tlb_update_asid_n = asid_i;
					vaddr_n = dtlb_vaddr_i;
					state_d = 3'd1;
					dtlb_miss_o = 1'b1;
				end
			end
			3'd1: begin
				req_port_o[9] = 1'b1;
				if (req_port_i[34]) begin
					tag_valid_n = 1'b1;
					state_d = 3'd2;
				end
			end
			3'd2:
				if (data_rvalid_q) begin
					if (pte[5])
						global_mapping_n = 1'b1;
					if (!pte[0] || (!pte[1] && pte[2]))
						state_d = 3'd4;
					else begin
						state_d = 3'd0;
						if (pte[1] || pte[3]) begin
							if (is_instr_ptw_q) begin
								if (!pte[3] || !pte[6])
									state_d = 3'd4;
								else
									itlb_update_o[62] = 1'b1;
							end
							else begin
								if (pte[6] && (pte[1] || (pte[3] && mxr_i)))
									dtlb_update_o[62] = 1'b1;
								else
									state_d = 3'd4;
								if (lsu_is_store_i && (!pte[2] || !pte[7])) begin
									dtlb_update_o[62] = 1'b0;
									state_d = 3'd4;
								end
							end
							if ((ptw_lvl_q == 1'd0) && (pte[19:10] != {10 {1'sb0}})) begin
								state_d = 3'd4;
								dtlb_update_o[62] = 1'b0;
								itlb_update_o[62] = 1'b0;
							end
						end
						else begin
							if (ptw_lvl_q == 1'd0) begin
								ptw_lvl_n = 1'd1;
								ptw_pptr_n = {pte[31-:22], vaddr_q[21:12], 2'b00};
							end
							state_d = 3'd1;
							if (ptw_lvl_q == 1'd1) begin
								ptw_lvl_n = 1'd1;
								state_d = 3'd4;
							end
						end
					end
					if (!allow_access) begin
						itlb_update_o[62] = 1'b0;
						dtlb_update_o[62] = 1'b0;
						ptw_pptr_n = ptw_pptr_q;
						state_d = 3'd5;
					end
				end
			3'd4: begin
				state_d = 3'd0;
				ptw_error_o = 1'b1;
			end
			3'd5: begin
				state_d = 3'd0;
				ptw_access_exception_o = 1'b1;
			end
			3'd3:
				if (data_rvalid_q)
					state_d = 3'd0;
			default: state_d = 3'd0;
		endcase
		if (flush_i)
			if (((state_q == 3'd2) && !data_rvalid_q) || ((state_q == 3'd1) && req_port_i[34]))
				state_d = 3'd3;
			else
				state_d = 3'd0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 3'd0;
			is_instr_ptw_q <= 1'b0;
			ptw_lvl_q <= 1'd0;
			tag_valid_q <= 1'b0;
			tlb_update_asid_q <= 1'sb0;
			vaddr_q <= 1'sb0;
			ptw_pptr_q <= 1'sb0;
			global_mapping_q <= 1'b0;
			data_rdata_q <= 1'sb0;
			data_rvalid_q <= 1'b0;
		end
		else begin
			state_q <= state_d;
			ptw_pptr_q <= ptw_pptr_n;
			is_instr_ptw_q <= is_instr_ptw_n;
			ptw_lvl_q <= ptw_lvl_n;
			tag_valid_q <= tag_valid_n;
			tlb_update_asid_q <= tlb_update_asid_n;
			vaddr_q <= vaddr_n;
			global_mapping_q <= global_mapping_n;
			data_rdata_q <= req_port_i[32-:32];
			data_rvalid_q <= req_port_i[33];
		end
endmodule
