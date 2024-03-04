module load_store_unit (
	clk_i,
	rst_ni,
	flush_i,
	no_st_pending_o,
	amo_valid_commit_i,
	fu_data_i,
	lsu_ready_o,
	lsu_valid_i,
	load_trans_id_o,
	load_result_o,
	load_valid_o,
	load_exception_o,
	store_trans_id_o,
	store_result_o,
	store_valid_o,
	store_exception_o,
	commit_i,
	commit_ready_o,
	commit_tran_id_i,
	enable_translation_i,
	en_ld_st_translation_i,
	icache_areq_i,
	icache_areq_o,
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
	dcache_req_ports_i,
	dcache_req_ports_o,
	dcache_wbuffer_empty_i,
	dcache_wbuffer_not_ni_i,
	amo_req_o,
	amo_resp_i,
	pmpcfg_i,
	pmpaddr_i
`ifdef EXPOSE_STATE
	, store_state_o
	, load_state_o
`endif
);
	parameter [31:0] ASID_WIDTH = 1;
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	output wire no_st_pending_o;
	input wire amo_valid_commit_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	output wire lsu_ready_o;
	input wire lsu_valid_i;
	output wire [2:0] load_trans_id_o;
	output wire [31:0] load_result_o;
	output wire load_valid_o;
	output wire [64:0] load_exception_o;
	output wire [2:0] store_trans_id_o;
	output wire [31:0] store_result_o;
	output wire store_valid_o;
	output wire [64:0] store_exception_o;
	input wire commit_i;
	output wire commit_ready_o;
	input wire [2:0] commit_tran_id_i;
	input wire enable_translation_i;
	input wire en_ld_st_translation_i;
	localparam riscv_VLEN = 32;
	input wire [32:0] icache_areq_i;
	localparam riscv_PLEN = 34;
	output wire [99:0] icache_areq_o;
	input wire [1:0] priv_lvl_i;
	input wire [1:0] ld_st_priv_lvl_i;
	input wire sum_i;
	input wire mxr_i;
	localparam riscv_PPNW = 22;
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
	input wire [104:0] dcache_req_ports_i;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	output wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (3 * ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10)) - 1 : (3 * (1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))) + ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 8)):(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9)] dcache_req_ports_o;
	input wire dcache_wbuffer_empty_i;
	input wire dcache_wbuffer_not_ni_i;
	output wire [134:0] amo_req_o;
	input wire [64:0] amo_resp_i;
	input wire [127:0] pmpcfg_i;
	input wire [511:0] pmpaddr_i;
	reg data_misaligned;
	wire [84:0] lsu_ctrl;
	wire pop_st;
	wire pop_ld;
	wire [31:0] vaddr_i;
	wire [31:0] vaddr_xlen;
	wire overflow;
	wire [3:0] be_i;
	assign vaddr_xlen = $unsigned($signed(fu_data_i[34-:32]) + $signed(fu_data_i[98-:32]));
	assign vaddr_i = vaddr_xlen[31:0];
	localparam [3:0] riscv_MODE_SV = 4'd1;
	localparam riscv_SV = (riscv_MODE_SV == 4'd1 ? 32 : 39);
	assign overflow = !((&vaddr_xlen[31:riscv_SV - 1] == 1'b1) || (|vaddr_xlen[31:riscv_SV - 1] == 1'b0));
	reg st_valid_i;
	reg ld_valid_i;
	wire ld_translation_req;
	wire st_translation_req;
	wire [31:0] ld_vaddr;
	wire [31:0] st_vaddr;
	reg translation_req;
	reg translation_valid;
	reg [31:0] mmu_vaddr;
	reg [33:0] mmu_paddr;
	wire [64:0] mmu_exception;
	wire dtlb_hit;
	wire [21:0] dtlb_ppn;
	wire ld_valid;
	wire [2:0] ld_trans_id;
	wire [31:0] ld_result;
	wire st_valid;
	wire [2:0] st_trans_id;
	wire [31:0] st_result;
	wire [11:0] page_offset;
	wire page_offset_matches;
	reg [64:0] misaligned_exception;
	wire [64:0] ld_ex;
	wire [64:0] st_ex;
	localparam ariane_pkg_MMU_PRESENT = 1'b0;
	generate
		if (ariane_pkg_MMU_PRESENT && 1'd0) begin : gen_mmu_sv39
			mmu #(
				.INSTR_TLB_ENTRIES(16),
				.DATA_TLB_ENTRIES(16),
				.ASID_WIDTH(ASID_WIDTH),
				.ArianeCfg(ArianeCfg)
			) i_cva6_mmu(
				.misaligned_ex_i(misaligned_exception),
				.lsu_is_store_i(st_translation_req),
				.lsu_req_i(translation_req),
				.lsu_vaddr_i(mmu_vaddr),
				.lsu_valid_o(translation_valid),
				.lsu_paddr_o(mmu_paddr),
				.lsu_exception_o(mmu_exception),
				.lsu_dtlb_hit_o(dtlb_hit),
				.lsu_dtlb_ppn_o(dtlb_ppn),
				.req_port_i(dcache_req_ports_i[0+:35]),
				.req_port_o(dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) + 0+:(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))]),
				.icache_areq_i(icache_areq_i),
				.asid_to_be_flushed_i(asid_to_be_flushed_i),
				.vaddr_to_be_flushed_i(vaddr_to_be_flushed_i),
				.icache_areq_o(icache_areq_o),
				.pmpcfg_i(pmpcfg_i),
				.pmpaddr_i(pmpaddr_i),
				.*
			);
		end
		else if (ariane_pkg_MMU_PRESENT && 1'd1) begin : gen_mmu_sv32
			cva6_mmu_sv32 #(
				.INSTR_TLB_ENTRIES(16),
				.DATA_TLB_ENTRIES(16),
				.ASID_WIDTH(ASID_WIDTH),
				.ArianeCfg(ArianeCfg)
			) i_cva6_mmu(
				.misaligned_ex_i(misaligned_exception),
				.lsu_is_store_i(st_translation_req),
				.lsu_req_i(translation_req),
				.lsu_vaddr_i(mmu_vaddr),
				.lsu_valid_o(translation_valid),
				.lsu_paddr_o(mmu_paddr),
				.lsu_exception_o(mmu_exception),
				.lsu_dtlb_hit_o(dtlb_hit),
				.lsu_dtlb_ppn_o(dtlb_ppn),
				.req_port_i(dcache_req_ports_i[0+:35]),
				.req_port_o(dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) + 0+:(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))]),
				.icache_areq_i(icache_areq_i),
				.asid_to_be_flushed_i(asid_to_be_flushed_i),
				.vaddr_to_be_flushed_i(vaddr_to_be_flushed_i),
				.icache_areq_o(icache_areq_o),
				.pmpcfg_i(pmpcfg_i),
				.pmpaddr_i(pmpaddr_i),
				.*
			);
		end
		else begin : gen_no_mmu
			assign icache_areq_o[99] = icache_areq_i[32];
			assign icache_areq_o[98-:34] = icache_areq_i[33:0];
			assign icache_areq_o[64-:65] = 1'sb0;
			assign dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42) : ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) : ((0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42) : ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)))) + ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)) - 1)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)] = 1'sb0;
			assign dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? ariane_pkg_DCACHE_TAG_WIDTH + 42 : ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) - (ariane_pkg_DCACHE_TAG_WIDTH + 42)) : ((0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? ariane_pkg_DCACHE_TAG_WIDTH + 42 : ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) - (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + ((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))) - 1)-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))] = 1'sb0;
			assign dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 42 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) - 33) : (0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 42 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) - 33)) + 31)-:32] = 1'sb0;
			assign dcache_req_ports_o[0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 9 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 0)] = 1'b0;
			assign dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 7 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 2) : (0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 7 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 2)) + 3)-:4] = 1'sb1;
			assign dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 3 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 6) : (0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 3 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 6)) + 1)-:2] = 2'b11;
			assign dcache_req_ports_o[0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 8 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 1)] = 1'b0;
			assign dcache_req_ports_o[0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 1 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 8)] = 1'sb0;
			assign dcache_req_ports_o[0 + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9)] = 1'b0;
			assign itlb_miss_o = 1'b0;
			assign dtlb_miss_o = 1'b0;
			assign dtlb_ppn = mmu_vaddr[33:12];
			assign dtlb_hit = 1'b1;
			assign mmu_exception = 1'sb0;
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni) begin
					mmu_paddr <= 1'sb0;
					translation_valid <= 1'sb0;
				end
				else begin
					mmu_paddr <= {2'b0, mmu_vaddr};
					translation_valid <= translation_req;
				end
		end
	endgenerate
	wire store_buffer_empty;
	store_unit i_store_unit(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.no_st_pending_o(no_st_pending_o),
		.store_buffer_empty_o(store_buffer_empty),
		.valid_i(st_valid_i),
		.lsu_ctrl_i(lsu_ctrl),
		.pop_st_o(pop_st),
		.commit_i(commit_i),
		.commit_ready_o(commit_ready_o),
		.amo_valid_commit_i(amo_valid_commit_i),
		.valid_o(st_valid),
		.trans_id_o(st_trans_id),
		.result_o(st_result),
		.ex_o(st_ex),
		.translation_req_o(st_translation_req),
		.vaddr_o(st_vaddr),
		.paddr_i(mmu_paddr),
		.ex_i(mmu_exception),
		.dtlb_hit_i(dtlb_hit),
		.page_offset_i(page_offset),
		.page_offset_matches_o(page_offset_matches),
		.amo_req_o(amo_req_o),
		.amo_resp_i(amo_resp_i),
		.req_port_i(dcache_req_ports_i[70+:35]),
		.req_port_o(dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) + (2 * (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9)))+:(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))])
`ifdef EXPOSE_STATE
		, .store_state_o(store_state_o)
`endif
	);
	load_unit #(.ArianeCfg(ArianeCfg)) i_load_unit(
		.valid_i(ld_valid_i),
		.lsu_ctrl_i(lsu_ctrl),
		.pop_ld_o(pop_ld),
		.valid_o(ld_valid),
		.trans_id_o(ld_trans_id),
		.result_o(ld_result),
		.ex_o(ld_ex),
		.translation_req_o(ld_translation_req),
		.vaddr_o(ld_vaddr),
		.paddr_i(mmu_paddr),
		.ex_i(mmu_exception),
		.dtlb_hit_i(dtlb_hit),
		.dtlb_ppn_i(dtlb_ppn),
		.page_offset_o(page_offset),
		.page_offset_matches_i(page_offset_matches),
		.store_buffer_empty_i(store_buffer_empty),
		.req_port_i(dcache_req_ports_i[35+:35]),
		.req_port_o(dcache_req_ports_o[77+:77]),
			// (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))+:(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))
		// ]),
		.dcache_wbuffer_not_ni_i(dcache_wbuffer_not_ni_i),
		.commit_tran_id_i(commit_tran_id_i),
	`ifdef EXPOSE_STATE
		.load_state_o(load_state_o),
	`endif
		.*
	);

	output wire [1:0] load_state_o;
	output wire [7:0] store_state_o;

	localparam [31:0] ariane_pkg_NR_LOAD_PIPE_REGS = 1;
	shift_reg 
	// #(
	// 	.dtype_riscv_XLEN(riscv_XLEN),
	// 	.Depth(ariane_pkg_NR_LOAD_PIPE_REGS)
	// ) 
	i_pipe_reg_load(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i({ld_valid, ld_trans_id, ld_result, ld_ex}),
		.d_o({load_valid_o, load_trans_id_o, load_result_o, load_exception_o})
	);
	localparam [31:0] ariane_pkg_NR_STORE_PIPE_REGS = 0;
	shift_reg 
	// #(
	// 	.dtype_riscv_XLEN(riscv_XLEN),
	// 	.Depth(ariane_pkg_NR_STORE_PIPE_REGS)
	// ) 
	i_pipe_reg_store(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i({st_valid, st_trans_id, st_result, st_ex}),
		.d_o({store_valid_o, store_trans_id_o, store_result_o, store_exception_o})
	);
	always @(lsu_ctrl, ld_vaddr, st_vaddr) begin : which_op
		ld_valid_i = 1'b0;
		st_valid_i = 1'b0;
		translation_req = 1'b0;
		mmu_vaddr = {riscv_VLEN {1'b0}};
		case (lsu_ctrl[14-:4])
			4'd1: begin
				ld_valid_i = lsu_ctrl[84];
				translation_req = ld_translation_req;
				mmu_vaddr = ld_vaddr;
			end
			4'd2: begin
				st_valid_i = lsu_ctrl[84];
				translation_req = st_translation_req;
				mmu_vaddr = st_vaddr;
			end
			default:
				;
		endcase
	end
	function automatic [7:0] ariane_pkg_be_gen;
		input reg [2:0] addr;
		input reg [1:0] size;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			case (size)
				2'b11: begin
					ariane_pkg_be_gen = 8'b11111111;
					_sv2v_jump = 2'b11;
				end
				2'b10:
					case (addr[2:0])
						3'b000: begin
							ariane_pkg_be_gen = 8'b00001111;
							_sv2v_jump = 2'b11;
						end
						3'b001: begin
							ariane_pkg_be_gen = 8'b00011110;
							_sv2v_jump = 2'b11;
						end
						3'b010: begin
							ariane_pkg_be_gen = 8'b00111100;
							_sv2v_jump = 2'b11;
						end
						3'b011: begin
							ariane_pkg_be_gen = 8'b01111000;
							_sv2v_jump = 2'b11;
						end
						3'b100: begin
							ariane_pkg_be_gen = 8'b11110000;
							_sv2v_jump = 2'b11;
						end
					endcase
				2'b01:
					case (addr[2:0])
						3'b000: begin
							ariane_pkg_be_gen = 8'b00000011;
							_sv2v_jump = 2'b11;
						end
						3'b001: begin
							ariane_pkg_be_gen = 8'b00000110;
							_sv2v_jump = 2'b11;
						end
						3'b010: begin
							ariane_pkg_be_gen = 8'b00001100;
							_sv2v_jump = 2'b11;
						end
						3'b011: begin
							ariane_pkg_be_gen = 8'b00011000;
							_sv2v_jump = 2'b11;
						end
						3'b100: begin
							ariane_pkg_be_gen = 8'b00110000;
							_sv2v_jump = 2'b11;
						end
						3'b101: begin
							ariane_pkg_be_gen = 8'b01100000;
							_sv2v_jump = 2'b11;
						end
						3'b110: begin
							ariane_pkg_be_gen = 8'b11000000;
							_sv2v_jump = 2'b11;
						end
					endcase
				2'b00:
					case (addr[2:0])
						3'b000: begin
							ariane_pkg_be_gen = 8'b00000001;
							_sv2v_jump = 2'b11;
						end
						3'b001: begin
							ariane_pkg_be_gen = 8'b00000010;
							_sv2v_jump = 2'b11;
						end
						3'b010: begin
							ariane_pkg_be_gen = 8'b00000100;
							_sv2v_jump = 2'b11;
						end
						3'b011: begin
							ariane_pkg_be_gen = 8'b00001000;
							_sv2v_jump = 2'b11;
						end
						3'b100: begin
							ariane_pkg_be_gen = 8'b00010000;
							_sv2v_jump = 2'b11;
						end
						3'b101: begin
							ariane_pkg_be_gen = 8'b00100000;
							_sv2v_jump = 2'b11;
						end
						3'b110: begin
							ariane_pkg_be_gen = 8'b01000000;
							_sv2v_jump = 2'b11;
						end
						3'b111: begin
							ariane_pkg_be_gen = 8'b10000000;
							_sv2v_jump = 2'b11;
						end
					endcase
			endcase
			if (_sv2v_jump == 2'b00) begin
				ariane_pkg_be_gen = 8'b00000000;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
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
	localparam riscv_IS_XLEN64 = 1'b0;
	assign be_i = (riscv_IS_XLEN64 ? ariane_pkg_be_gen(vaddr_i[2:0], ariane_pkg_extract_transfer_size(fu_data_i[106-:8])) : ariane_pkg_be_gen_32(vaddr_i[1:0], ariane_pkg_extract_transfer_size(fu_data_i[106-:8])));
	localparam [31:0] riscv_LD_ACCESS_FAULT = 5;
	localparam [31:0] riscv_LD_ADDR_MISALIGNED = 4;
	localparam [31:0] riscv_ST_ACCESS_FAULT = 7;
	localparam [31:0] riscv_ST_ADDR_MISALIGNED = 6;
	always @(*) begin : data_misaligned_detection
		misaligned_exception = {{riscv_XLEN {1'b0}}, {riscv_XLEN {1'b0}}, 1'b0};
		data_misaligned = 1'b0;
		if (lsu_ctrl[84])
			case (lsu_ctrl[10-:8])
				8'd35, 8'd36, 8'd81, 8'd85, 8'd47, 8'd49, 8'd59, 8'd60, 8'd61, 8'd62, 8'd63, 8'd64, 8'd65, 8'd66, 8'd67:
					if (lsu_ctrl[54:52] != 3'b000)
						data_misaligned = 1'b1;
				8'd37, 8'd38, 8'd39, 8'd82, 8'd86, 8'd46, 8'd48, 8'd50, 8'd51, 8'd52, 8'd53, 8'd54, 8'd55, 8'd56, 8'd57, 8'd58:
					if (lsu_ctrl[53:52] != 2'b00)
						data_misaligned = 1'b1;
				8'd40, 8'd41, 8'd42, 8'd83, 8'd87:
					if (lsu_ctrl[52] != 1'b0)
						data_misaligned = 1'b1;
				default:
					;
			endcase
		if (data_misaligned)
			if (lsu_ctrl[14-:4] == 4'd1)
				misaligned_exception = {riscv_LD_ADDR_MISALIGNED, {lsu_ctrl[83-:32]}, 1'b1};
			else if (lsu_ctrl[14-:4] == 4'd2)
				misaligned_exception = {riscv_ST_ADDR_MISALIGNED, {lsu_ctrl[83-:32]}, 1'b1};
		if (en_ld_st_translation_i && lsu_ctrl[51])
			if (lsu_ctrl[14-:4] == 4'd1)
				misaligned_exception = {riscv_LD_ACCESS_FAULT, {lsu_ctrl[83-:32]}, 1'b1};
			else if (lsu_ctrl[14-:4] == 4'd2)
				misaligned_exception = {riscv_ST_ACCESS_FAULT, {lsu_ctrl[83-:32]}, 1'b1};
	end
	wire [84:0] lsu_req_i;
	assign lsu_req_i = {lsu_valid_i, vaddr_i, overflow, fu_data_i[66-:32], be_i, fu_data_i[110-:4], fu_data_i[106-:8], fu_data_i[2-:ariane_pkg_TRANS_ID_BITS]};
	lsu_bypass lsu_bypass_i(
		.lsu_req_i(lsu_req_i),
		.lsu_req_valid_i(lsu_valid_i),
		.pop_ld_i(pop_ld),
		.pop_st_i(pop_st),
		.lsu_ctrl_o(lsu_ctrl),
		.ready_o(lsu_ready_o),
		.*
	);
endmodule
