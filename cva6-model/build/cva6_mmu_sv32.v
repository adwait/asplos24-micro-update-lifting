module cva6_mmu_sv32 (
	clk_i,
	rst_ni,
	flush_i,
	enable_translation_i,
	en_ld_st_translation_i,
	icache_areq_i,
	icache_areq_o,
	misaligned_ex_i,
	lsu_req_i,
	lsu_vaddr_i,
	lsu_is_store_i,
	lsu_dtlb_hit_o,
	lsu_dtlb_ppn_o,
	lsu_valid_o,
	lsu_paddr_o,
	lsu_exception_o,
	priv_lvl_i,
	ld_st_priv_lvl_i,
	sum_i,
	mxr_i,
	satp_ppn_i,
	asid_i,
	asid_to_be_flushed_i,
	vaddr_to_be_flushed_i,
	flush_tlb_i,
	itlb_miss_o,
	dtlb_miss_o,
	req_port_i,
	req_port_o,
	pmpcfg_i,
	pmpaddr_i
);
	parameter [31:0] INSTR_TLB_ENTRIES = 4;
	parameter [31:0] DATA_TLB_ENTRIES = 4;
	parameter [31:0] ASID_WIDTH = 1;
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire enable_translation_i;
	input wire en_ld_st_translation_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [32:0] icache_areq_i;
	localparam riscv_PLEN = 34;
	output reg [99:0] icache_areq_o;
	input wire [64:0] misaligned_ex_i;
	input wire lsu_req_i;
	input wire [31:0] lsu_vaddr_i;
	input wire lsu_is_store_i;
	output wire lsu_dtlb_hit_o;
	localparam riscv_PPNW = 22;
	output reg [21:0] lsu_dtlb_ppn_o;
	output reg lsu_valid_o;
	output reg [33:0] lsu_paddr_o;
	output reg [64:0] lsu_exception_o;
	input wire [1:0] priv_lvl_i;
	input wire [1:0] ld_st_priv_lvl_i;
	input wire sum_i;
	input wire mxr_i;
	input wire [21:0] satp_ppn_i;
	input wire [ASID_WIDTH - 1:0] asid_i;
	input wire [ASID_WIDTH - 1:0] asid_to_be_flushed_i;
	input wire [31:0] vaddr_to_be_flushed_i;
	input wire flush_tlb_i;
	output wire itlb_miss_o;
	output wire dtlb_miss_o;
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
	input wire [127:0] pmpcfg_i;
	input wire [511:0] pmpaddr_i;
	reg iaccess_err;
	reg daccess_err;
	wire ptw_active;
	wire walking_instr;
	wire ptw_error;
	wire ptw_access_exception;
	wire [33:0] ptw_bad_paddr;
	wire [31:0] update_vaddr;
	wire [62:0] update_ptw_itlb;
	wire [62:0] update_ptw_dtlb;
	wire itlb_lu_access;
	wire [31:0] itlb_content;
	wire itlb_is_4M;
	wire itlb_lu_hit;
	wire dtlb_lu_access;
	wire [31:0] dtlb_content;
	wire dtlb_is_4M;
	wire dtlb_lu_hit;
	assign itlb_lu_access = icache_areq_i[32];
	assign dtlb_lu_access = lsu_req_i;
	cva6_tlb_sv32 #(
		.TLB_ENTRIES(INSTR_TLB_ENTRIES),
		.ASID_WIDTH(ASID_WIDTH)
	) i_itlb(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_tlb_i),
		.update_i(update_ptw_itlb),
		.lu_access_i(itlb_lu_access),
		.lu_asid_i(asid_i),
		.asid_to_be_flushed_i(asid_to_be_flushed_i),
		.vaddr_to_be_flushed_i(vaddr_to_be_flushed_i),
		.lu_vaddr_i(icache_areq_i[31-:riscv_VLEN]),
		.lu_content_o(itlb_content),
		.lu_is_4M_o(itlb_is_4M),
		.lu_hit_o(itlb_lu_hit)
	);
	cva6_tlb_sv32 #(
		.TLB_ENTRIES(DATA_TLB_ENTRIES),
		.ASID_WIDTH(ASID_WIDTH)
	) i_dtlb(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_tlb_i),
		.update_i(update_ptw_dtlb),
		.lu_access_i(dtlb_lu_access),
		.lu_asid_i(asid_i),
		.asid_to_be_flushed_i(asid_to_be_flushed_i),
		.vaddr_to_be_flushed_i(vaddr_to_be_flushed_i),
		.lu_vaddr_i(lsu_vaddr_i),
		.lu_content_o(dtlb_content),
		.lu_is_4M_o(dtlb_is_4M),
		.lu_hit_o(dtlb_lu_hit)
	);
	cva6_ptw_sv32 #(
		.ASID_WIDTH(ASID_WIDTH),
		.ArianeCfg(ArianeCfg)
	) i_ptw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ptw_active_o(ptw_active),
		.walking_instr_o(walking_instr),
		.ptw_error_o(ptw_error),
		.ptw_access_exception_o(ptw_access_exception),
		.enable_translation_i(enable_translation_i),
		.update_vaddr_o(update_vaddr),
		.itlb_update_o(update_ptw_itlb),
		.dtlb_update_o(update_ptw_dtlb),
		.itlb_access_i(itlb_lu_access),
		.itlb_hit_i(itlb_lu_hit),
		.itlb_vaddr_i(icache_areq_i[31-:riscv_VLEN]),
		.dtlb_access_i(dtlb_lu_access),
		.dtlb_hit_i(dtlb_lu_hit),
		.dtlb_vaddr_i(lsu_vaddr_i),
		.req_port_i(req_port_i),
		.req_port_o(req_port_o),
		.pmpcfg_i(pmpcfg_i),
		.pmpaddr_i(pmpaddr_i),
		.bad_paddr_o(ptw_bad_paddr),
		.flush_i(flush_i),
		.en_ld_st_translation_i(en_ld_st_translation_i),
		.lsu_is_store_i(lsu_is_store_i),
		.asid_i(asid_i),
		.satp_ppn_i(satp_ppn_i),
		.mxr_i(mxr_i),
		.itlb_miss_o(itlb_miss_o),
		.dtlb_miss_o(dtlb_miss_o)
	);
	wire match_any_execute_region;
	wire pmp_instr_allow;
	localparam [31:0] riscv_INSTR_ACCESS_FAULT = 1;
	localparam [31:0] riscv_INSTR_PAGE_FAULT = 12;
	localparam [3:0] riscv_MODE_SV = 4'd1;
	localparam riscv_SV = (riscv_MODE_SV == 4'd1 ? 32 : 39);
	always @(*) begin : instr_interface
		icache_areq_o[99] = icache_areq_i[32];
		icache_areq_o[98-:34] = {{2 {1'b0}}, icache_areq_i[31-:riscv_VLEN]};
		icache_areq_o[64-:65] = 1'sb0;
		iaccess_err = icache_areq_i[32] && (((priv_lvl_i == 2'b00) && ~itlb_content[4]) || ((priv_lvl_i == 2'b01) && itlb_content[4]));
		if (enable_translation_i) begin
			if (icache_areq_i[32] && !((&icache_areq_i[31:riscv_SV - 1] == 1'b1) || (|icache_areq_i[31:riscv_SV - 1] == 1'b0)))
				icache_areq_o[64-:65] = {riscv_INSTR_ACCESS_FAULT, {icache_areq_i[31-:riscv_VLEN]}, 1'b1};
			icache_areq_o[99] = 1'b0;
			icache_areq_o[98-:34] = {itlb_content[31-:22], icache_areq_i[11:0]};
			if (itlb_is_4M)
				icache_areq_o[86:77] = icache_areq_i[21:12];
			if (itlb_lu_hit) begin
				icache_areq_o[99] = icache_areq_i[32];
				if (iaccess_err)
					icache_areq_o[64-:65] = {riscv_INSTR_PAGE_FAULT, {icache_areq_i[31-:riscv_VLEN]}, 1'b1};
				else if (!pmp_instr_allow)
					icache_areq_o[64-:65] = {riscv_INSTR_ACCESS_FAULT, icache_areq_i[31-:riscv_VLEN], 1'b1};
			end
			else if (ptw_active && walking_instr) begin
				icache_areq_o[99] = ptw_error | ptw_access_exception;
				if (ptw_error)
					icache_areq_o[64-:65] = {riscv_INSTR_PAGE_FAULT, {update_vaddr}, 1'b1};
				else
					icache_areq_o[64-:65] = {riscv_INSTR_ACCESS_FAULT, ptw_bad_paddr[33:2], 1'b1};
			end
		end
		if (!match_any_execute_region || (!enable_translation_i && !pmp_instr_allow))
			icache_areq_o[64-:65] = {riscv_INSTR_ACCESS_FAULT, icache_areq_o[98:67], 1'b1};
	end
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
	function automatic ariane_pkg_is_inside_execute_regions;
		input reg [6433:0] Cfg;
		input reg [63:0] address;
		reg [15:0] pass;
		begin
			pass = 1'sb0;
			begin : sv2v_autoblock_1
				reg [31:0] k;
				for (k = 0; k < Cfg[4257-:32]; k = k + 1)
					pass[k] = ariane_pkg_range_check(Cfg[3202 + (k * 64)+:64], Cfg[2178 + (k * 64)+:64], address);
			end
			ariane_pkg_is_inside_execute_regions = |pass;
		end
	endfunction
	assign match_any_execute_region = ariane_pkg_is_inside_execute_regions(ArianeCfg, {{30 {1'b0}}, icache_areq_o[98-:34]});
	pmp #(
		.PLEN(riscv_PLEN),
		.PMP_LEN(32),
		.NR_ENTRIES(ArianeCfg[31-:32])
	) i_pmp_if(
		.addr_i(icache_areq_o[98-:34]),
		.priv_lvl_i(priv_lvl_i),
		.access_type_i(3'b100),
		.conf_addr_i(pmpaddr_i),
		.conf_i(pmpcfg_i),
		.allow_o(pmp_instr_allow)
	);
	reg [31:0] lsu_vaddr_n;
	reg [31:0] lsu_vaddr_q;
	reg [31:0] dtlb_pte_n;
	reg [31:0] dtlb_pte_q;
	reg [64:0] misaligned_ex_n;
	reg [64:0] misaligned_ex_q;
	reg lsu_req_n;
	reg lsu_req_q;
	reg lsu_is_store_n;
	reg lsu_is_store_q;
	reg dtlb_hit_n;
	reg dtlb_hit_q;
	reg dtlb_is_4M_n;
	reg dtlb_is_4M_q;
	assign lsu_dtlb_hit_o = (en_ld_st_translation_i ? dtlb_lu_hit : 1'b1);
	reg [2:0] pmp_access_type;
	wire pmp_data_allow;
	localparam PPNWMin = 21;
	localparam [31:0] riscv_LD_ACCESS_FAULT = 5;
	localparam [31:0] riscv_LOAD_PAGE_FAULT = 13;
	localparam [31:0] riscv_STORE_PAGE_FAULT = 15;
	localparam [31:0] riscv_ST_ACCESS_FAULT = 7;
	always @(*) begin : data_interface
		lsu_vaddr_n = lsu_vaddr_i;
		lsu_req_n = lsu_req_i;
		misaligned_ex_n = misaligned_ex_i;
		dtlb_pte_n = dtlb_content;
		dtlb_hit_n = dtlb_lu_hit;
		lsu_is_store_n = lsu_is_store_i;
		dtlb_is_4M_n = dtlb_is_4M;
		lsu_paddr_o = {{2 {1'b0}}, lsu_vaddr_q};
		lsu_dtlb_ppn_o = {{2 {1'b0}}, lsu_vaddr_n[31:12]};
		lsu_valid_o = lsu_req_q;
		lsu_exception_o = misaligned_ex_q;
		pmp_access_type = (lsu_is_store_q ? 3'b010 : 3'b001);
		misaligned_ex_n[0] = misaligned_ex_i[0] & lsu_req_i;
		daccess_err = (((ld_st_priv_lvl_i == 2'b01) && !sum_i) && dtlb_pte_q[4]) || ((ld_st_priv_lvl_i == 2'b00) && !dtlb_pte_q[4]);
		if (en_ld_st_translation_i && !misaligned_ex_q[0]) begin
			lsu_valid_o = 1'b0;
			lsu_paddr_o = {dtlb_pte_q[31-:22], lsu_vaddr_q[11:0]};
			lsu_dtlb_ppn_o = dtlb_content[31-:22];
			if (dtlb_is_4M_q) begin
				lsu_paddr_o[21:12] = lsu_vaddr_q[21:12];
				lsu_dtlb_ppn_o[21:12] = lsu_vaddr_n[21:12];
			end
			if (dtlb_hit_q && lsu_req_q) begin
				lsu_valid_o = 1'b1;
				if (lsu_is_store_q) begin
					if ((!dtlb_pte_q[2] || daccess_err) || !dtlb_pte_q[7])
						lsu_exception_o = {riscv_STORE_PAGE_FAULT, {lsu_vaddr_q}, 1'b1};
					else if (!pmp_data_allow)
						lsu_exception_o = {riscv_ST_ACCESS_FAULT, lsu_paddr_o[33:2], 1'b1};
				end
				else if (daccess_err)
					lsu_exception_o = {riscv_LOAD_PAGE_FAULT, {lsu_vaddr_q}, 1'b1};
				else if (!pmp_data_allow)
					lsu_exception_o = {riscv_LD_ACCESS_FAULT, lsu_paddr_o[33:2], 1'b1};
			end
			else if (ptw_active && !walking_instr) begin
				if (ptw_error) begin
					lsu_valid_o = 1'b1;
					if (lsu_is_store_q)
						lsu_exception_o = {riscv_STORE_PAGE_FAULT, {update_vaddr}, 1'b1};
					else
						lsu_exception_o = {riscv_LOAD_PAGE_FAULT, {update_vaddr}, 1'b1};
				end
				if (ptw_access_exception) begin
					lsu_valid_o = 1'b1;
					lsu_exception_o = {riscv_LD_ACCESS_FAULT, ptw_bad_paddr[33:2], 1'b1};
				end
			end
		end
		else if ((lsu_req_q && !misaligned_ex_q[0]) && !pmp_data_allow)
			if (lsu_is_store_q)
				lsu_exception_o = {riscv_ST_ACCESS_FAULT, lsu_paddr_o[33:2], 1'b1};
			else
				lsu_exception_o = {riscv_LD_ACCESS_FAULT, lsu_paddr_o[33:2], 1'b1};
	end
	pmp #(
		.PLEN(riscv_PLEN),
		.PMP_LEN(32),
		.NR_ENTRIES(ArianeCfg[31-:32])
	) i_pmp_data(
		.addr_i(lsu_paddr_o),
		.priv_lvl_i(ld_st_priv_lvl_i),
		.access_type_i(pmp_access_type),
		.conf_addr_i(pmpaddr_i),
		.conf_i(pmpcfg_i),
		.allow_o(pmp_data_allow)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			lsu_vaddr_q <= 1'sb0;
			lsu_req_q <= 1'sb0;
			misaligned_ex_q <= 1'sb0;
			dtlb_pte_q <= 1'sb0;
			dtlb_hit_q <= 1'sb0;
			lsu_is_store_q <= 1'sb0;
			dtlb_is_4M_q <= 1'sb0;
		end
		else begin
			lsu_vaddr_q <= lsu_vaddr_n;
			lsu_req_q <= lsu_req_n;
			misaligned_ex_q <= misaligned_ex_n;
			dtlb_pte_q <= dtlb_pte_n;
			dtlb_hit_q <= dtlb_hit_n;
			lsu_is_store_q <= lsu_is_store_n;
			dtlb_is_4M_q <= dtlb_is_4M_n;
		end
endmodule
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
module cva6_tlb_sv32 (
	clk_i,
	rst_ni,
	flush_i,
	update_i,
	lu_access_i,
	lu_asid_i,
	lu_vaddr_i,
	lu_content_o,
	asid_to_be_flushed_i,
	vaddr_to_be_flushed_i,
	lu_is_4M_o,
	lu_hit_o
);
	parameter [31:0] TLB_ENTRIES = 4;
	parameter [31:0] ASID_WIDTH = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [62:0] update_i;
	input wire lu_access_i;
	input wire [ASID_WIDTH - 1:0] lu_asid_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [31:0] lu_vaddr_i;
	output reg [31:0] lu_content_o;
	input wire [ASID_WIDTH - 1:0] asid_to_be_flushed_i;
	input wire [31:0] vaddr_to_be_flushed_i;
	output reg lu_is_4M_o;
	output reg lu_hit_o;
	reg [(TLB_ENTRIES * 31) - 1:0] tags_q;
	reg [(TLB_ENTRIES * 31) - 1:0] tags_n;
	reg [(TLB_ENTRIES * 32) - 1:0] content_q;
	reg [(TLB_ENTRIES * 32) - 1:0] content_n;
	reg [9:0] vpn0;
	reg [9:0] vpn1;
	reg [TLB_ENTRIES - 1:0] lu_hit;
	reg [TLB_ENTRIES - 1:0] replace_en;
	always @(*) begin : translation
		vpn0 = lu_vaddr_i[21:12];
		vpn1 = lu_vaddr_i[31:22];
		lu_hit = {TLB_ENTRIES {1'd0}};
		lu_hit_o = 1'b0;
		lu_content_o = 32'h00000000;
		lu_is_4M_o = 1'b0;
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < TLB_ENTRIES; i = i + 1)
				if ((tags_q[i * 31] && ((lu_asid_i == tags_q[(i * 31) + 30-:9]) || content_q[(i * 32) + 5])) && (vpn1 == tags_q[(i * 31) + 21-:10]))
					if (tags_q[(i * 31) + 1] || (vpn0 == tags_q[(i * 31) + 11-:10])) begin
						lu_is_4M_o = tags_q[(i * 31) + 1];
						lu_content_o = content_q[i * 32+:32];
						lu_hit_o = 1'b1;
						lu_hit[i] = 1'b1;
					end
		end
	end
	wire asid_to_be_flushed_is0;
	wire vaddr_to_be_flushed_is0;
	reg [TLB_ENTRIES - 1:0] vaddr_vpn0_match;
	reg [TLB_ENTRIES - 1:0] vaddr_vpn1_match;
	assign asid_to_be_flushed_is0 = ~(|asid_to_be_flushed_i);
	assign vaddr_to_be_flushed_is0 = ~(|vaddr_to_be_flushed_i);
	always @(*) begin : update_flush
		tags_n = tags_q;
		content_n = content_q;
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 0; i < TLB_ENTRIES; i = i + 1)
				begin
					vaddr_vpn0_match[i] = vaddr_to_be_flushed_i[21:12] == tags_q[(i * 31) + 11-:10];
					vaddr_vpn1_match[i] = vaddr_to_be_flushed_i[31:22] == tags_q[(i * 31) + 21-:10];
					if (flush_i) begin
						if (asid_to_be_flushed_is0 && vaddr_to_be_flushed_is0)
							tags_n[i * 31] = 1'b0;
						else if ((asid_to_be_flushed_is0 && ((vaddr_vpn0_match[i] && vaddr_vpn1_match[i]) || (vaddr_vpn1_match[i] && tags_q[(i * 31) + 1]))) && ~vaddr_to_be_flushed_is0)
							tags_n[i * 31] = 1'b0;
						else if ((((!content_q[(i * 32) + 5] && ((vaddr_vpn0_match[i] && vaddr_vpn1_match[i]) || (vaddr_vpn1_match[i] && tags_q[(i * 31) + 1]))) && (asid_to_be_flushed_i == tags_q[(i * 31) + 30-:9])) && !vaddr_to_be_flushed_is0) && !asid_to_be_flushed_is0)
							tags_n[i * 31] = 1'b0;
						else if (((!content_q[(i * 32) + 5] && vaddr_to_be_flushed_is0) && (asid_to_be_flushed_i == tags_q[(i * 31) + 30-:9])) && !asid_to_be_flushed_is0)
							tags_n[i * 31] = 1'b0;
					end
					else if (update_i[62] & replace_en[i]) begin
						tags_n[i * 31+:31] = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};
						content_n[i * 32+:32] = update_i[31-:32];
					end
				end
		end
	end
	reg [(2 * (TLB_ENTRIES - 1)) - 1:0] plru_tree_q;
	reg [(2 * (TLB_ENTRIES - 1)) - 1:0] plru_tree_n;
	always @(*) begin : plru_replacement
		plru_tree_n = plru_tree_q;
		begin : sv2v_autoblock_3
			reg [31:0] i;
			for (i = 0; i < TLB_ENTRIES; i = i + 1)
				begin : sv2v_autoblock_4
					reg [31:0] idx_base;
					reg [31:0] shift;
					reg [31:0] new_index;
					if (lu_hit[i] & lu_access_i) begin : sv2v_autoblock_5
						reg [31:0] lvl;
						for (lvl = 0; lvl < $clog2(TLB_ENTRIES); lvl = lvl + 1)
							begin
								idx_base = $unsigned((2 ** lvl) - 1);
								shift = $clog2(TLB_ENTRIES) - lvl;
								new_index = ~((i >> (shift - 1)) & 32'b00000000000000000000000000000001);
								plru_tree_n[idx_base + (i >> shift)] = new_index[0];
							end
					end
				end
		end
		begin : sv2v_autoblock_6
			reg [31:0] i;
			for (i = 0; i < TLB_ENTRIES; i = i + 1)
				begin : sv2v_autoblock_7
					reg en;
					reg [31:0] idx_base;
					reg [31:0] shift;
					reg [31:0] new_index;
					en = 1'b1;
					begin : sv2v_autoblock_8
						reg [31:0] lvl;
						for (lvl = 0; lvl < $clog2(TLB_ENTRIES); lvl = lvl + 1)
							begin
								idx_base = $unsigned((2 ** lvl) - 1);
								shift = $clog2(TLB_ENTRIES) - lvl;
								new_index = (i >> (shift - 1)) & 32'b00000000000000000000000000000001;
								if (new_index[0])
									en = en & plru_tree_q[idx_base + (i >> shift)];
								else
									en = en & ~plru_tree_q[idx_base + (i >> shift)];
							end
					end
					replace_en[i] = en;
				end
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			tags_q <= {TLB_ENTRIES {31'd0}};
			content_q <= {TLB_ENTRIES {32'd0}};
			plru_tree_q <= {2 * (TLB_ENTRIES - 1) {1'd0}};
		end
		else begin
			tags_q <= tags_n;
			content_q <= content_n;
			plru_tree_q <= plru_tree_n;
		end
	initial begin : p_assertions
		
	end
	function signed [31:0] countSetBits;
		input reg [TLB_ENTRIES - 1:0] vector;
		reg signed [31:0] count;
		begin
			count = 0;
			begin : sv2v_autoblock_9
				integer idx;
				for (idx = TLB_ENTRIES - 1; idx >= 0; idx = idx - 1)
					count = count + vector[idx];
			end
			countSetBits = count;
		end
	endfunction
endmodule
module pmp (
	addr_i,
	access_type_i,
	priv_lvl_i,
	conf_addr_i,
	conf_i,
	allow_o
);
	parameter [31:0] PLEN = 34;
	parameter [31:0] PMP_LEN = 32;
	parameter [31:0] NR_ENTRIES = 4;
	input wire [PLEN - 1:0] addr_i;
	input wire [2:0] access_type_i;
	input wire [1:0] priv_lvl_i;
	input wire [(16 * PMP_LEN) - 1:0] conf_addr_i;
	input wire [127:0] conf_i;
	output reg allow_o;
	generate
		if (NR_ENTRIES > 0) begin : gen_pmp
			wire [NR_ENTRIES - 1:0] match;
			genvar i;
			for (i = 0; i < NR_ENTRIES; i = i + 1) begin : genblk1
				wire [PMP_LEN - 1:0] conf_addr_prev;
				assign conf_addr_prev = (i == 0 ? {PMP_LEN {1'sb0}} : conf_addr_i[(i - 1) * PMP_LEN+:PMP_LEN]);
				pmp_entry #(
					.PLEN(PLEN),
					.PMP_LEN(PMP_LEN)
				) i_pmp_entry(
					.addr_i(addr_i),
					.conf_addr_i(conf_addr_i[i * PMP_LEN+:PMP_LEN]),
					.conf_addr_prev_i(conf_addr_prev),
					.conf_addr_mode_i(conf_i[(i * 8) + 4-:2]),
					.match_o(match[i])
				);
			end
			always @(*) begin : sv2v_autoblock_1
				reg [0:1] _sv2v_jump;
				_sv2v_jump = 2'b00;
				begin : sv2v_autoblock_2
					reg signed [31:0] i;
					allow_o = 1'b0;
					begin : sv2v_autoblock_3
						reg signed [31:0] _sv2v_value_on_break;
						for (i = 0; i < NR_ENTRIES; i = i + 1)
							if (_sv2v_jump < 2'b10) begin
								_sv2v_jump = 2'b00;
								if ((priv_lvl_i != 2'b11) || conf_i[(i * 8) + 7])
									if (match[i]) begin
										if ((access_type_i & conf_i[(i * 8) + 2-:3]) != access_type_i)
											allow_o = 1'b0;
										else
											allow_o = 1'b1;
										_sv2v_jump = 2'b10;
									end
								_sv2v_value_on_break = i;
							end
						if (!(_sv2v_jump < 2'b10))
							i = _sv2v_value_on_break;
						if (_sv2v_jump != 2'b11)
							_sv2v_jump = 2'b00;
					end
					if (_sv2v_jump == 2'b00)
						if (i == NR_ENTRIES)
							if (priv_lvl_i == 2'b11)
								allow_o = 1'b1;
							else
								allow_o = 1'b0;
				end
			end
		end
		else begin : genblk1
			wire [1:1] sv2v_tmp_6821D;
			assign sv2v_tmp_6821D = 1'b1;
			always @(*) allow_o = sv2v_tmp_6821D;
		end
	endgenerate
endmodule
module pmp_entry (
	addr_i,
	conf_addr_i,
	conf_addr_prev_i,
	conf_addr_mode_i,
	match_o
);
	parameter [31:0] PLEN = 56;
	parameter [31:0] PMP_LEN = 54;
	input wire [PLEN - 1:0] addr_i;
	input wire [PMP_LEN - 1:0] conf_addr_i;
	input wire [PMP_LEN - 1:0] conf_addr_prev_i;
	input wire [1:0] conf_addr_mode_i;
	output reg match_o;
	wire [PLEN - 1:0] conf_addr_n;
	wire [$clog2(PLEN) - 1:0] trail_ones;
	assign conf_addr_n = ~conf_addr_i;
	lzc #(
		.WIDTH(PLEN),
		.MODE(1'b0)
	) i_lzc(
		.in_i(conf_addr_n),
		.cnt_o(trail_ones),
		.empty_o()
	);
	always @(*)
		case (conf_addr_mode_i)
			2'b01:
				if ((addr_i >= (conf_addr_prev_i << 2)) && (addr_i < (conf_addr_i << 2)))
					match_o = 1'b1;
				else
					match_o = 1'b0;
			2'b10, 2'b11: begin : sv2v_autoblock_1
				reg [PLEN - 1:0] base;
				reg [PLEN - 1:0] mask;
				reg [31:0] size;
				if (conf_addr_mode_i == 2'b10)
					size = 2;
				else
					size = trail_ones + 3;
				mask = 1'sb1 << size;
				base = (conf_addr_i << 2) & mask;
				match_o = ((addr_i & mask) == base ? 1'b1 : 1'b0);
			end
			2'b00: match_o = 1'b0;
			default: match_o = 0;
		endcase
endmodule
