module csr_regfile (
	clk_i,
	rst_ni,
	time_irq_i,
	flush_o,
	halt_csr_o,
	commit_instr_i,
	commit_ack_i,
	boot_addr_i,
	hart_id_i,
	ex_i,
	csr_op_i,
	csr_addr_i,
	csr_wdata_i,
	csr_rdata_o,
	dirty_fp_state_i,
	csr_write_fflags_i,
	pc_i,
	csr_exception_o,
	epc_o,
	eret_o,
	trap_vector_base_o,
	priv_lvl_o,
	fs_o,
	fflags_o,
	frm_o,
	fprec_o,
	irq_ctrl_o,
	en_translation_o,
	en_ld_st_translation_o,
	ld_st_priv_lvl_o,
	sum_o,
	mxr_o,
	satp_ppn_o,
	asid_o,
	irq_i,
	ipi_i,
	debug_req_i,
	set_debug_pc_o,
	tvm_o,
	tw_o,
	tsr_o,
	debug_mode_o,
	single_step_o,
	icache_en_o,
	dcache_en_o,
	perf_addr_o,
	perf_data_o,
	perf_data_i,
	perf_we_o,
	pmpcfg_o,
	pmpaddr_o
);
	parameter [63:0] DmBaseAddress = 64'h0000000000000000;
	parameter signed [31:0] AsidWidth = 1;
	parameter [31:0] NrCommitPorts = 2;
	parameter [31:0] NrPMPEntries = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire time_irq_i;
	output reg flush_o;
	output wire halt_csr_o;
	localparam ariane_pkg_REG_ADDR_SIZE = 6;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [(NrCommitPorts * 202) - 1:0] commit_instr_i;
	input wire [NrCommitPorts - 1:0] commit_ack_i;
	input wire [31:0] boot_addr_i;
	input wire [31:0] hart_id_i;
	input wire [64:0] ex_i;
	input wire [7:0] csr_op_i;
	input wire [11:0] csr_addr_i;
	input wire [31:0] csr_wdata_i;
	output reg [31:0] csr_rdata_o;
	input wire dirty_fp_state_i;
	input wire csr_write_fflags_i;
	input wire [31:0] pc_i;
	output reg [64:0] csr_exception_o;
	output reg [31:0] epc_o;
	output reg eret_o;
	output reg [31:0] trap_vector_base_o;
	output wire [1:0] priv_lvl_o;
	output wire [1:0] fs_o;
	output wire [4:0] fflags_o;
	output wire [2:0] frm_o;
	output wire [6:0] fprec_o;
	output wire [97:0] irq_ctrl_o;
	output wire en_translation_o;
	output reg en_ld_st_translation_o;
	output reg [1:0] ld_st_priv_lvl_o;
	output wire sum_o;
	output wire mxr_o;
	localparam riscv_PPNW = 22;
	output wire [21:0] satp_ppn_o;
	output wire [AsidWidth - 1:0] asid_o;
	input wire [1:0] irq_i;
	input wire ipi_i;
	input wire debug_req_i;
	output reg set_debug_pc_o;
	output wire tvm_o;
	output wire tw_o;
	output wire tsr_o;
	output wire debug_mode_o;
	output wire single_step_o;
	output wire icache_en_o;
	output wire dcache_en_o;
	output reg [4:0] perf_addr_o;
	output reg [31:0] perf_data_o;
	input wire [31:0] perf_data_i;
	output reg perf_we_o;
	output wire [127:0] pmpcfg_o;
	localparam riscv_PLEN = 34;
	output wire [511:0] pmpaddr_o;
	reg read_access_exception;
	reg update_access_exception;
	reg privilege_violation;
	reg csr_we;
	reg csr_read;
	reg [31:0] csr_wdata;
	reg [31:0] csr_rdata;
	reg [1:0] trap_to_priv_lvl;
	reg en_ld_st_translation_d;
	reg en_ld_st_translation_q;
	wire mprv;
	reg mret;
	reg sret;
	reg dret;
	reg dirty_fp_state_csr;
	reg [63:0] mstatus_q;
	reg [63:0] mstatus_d;
	wire [31:0] mstatus_extended;
	localparam riscv_ASIDW = 9;
	localparam riscv_ModeW = 1;
	reg [31:0] satp_q;
	reg [31:0] satp_d;
	reg [31:0] dcsr_q;
	reg [31:0] dcsr_d;
	wire [11:0] csr_addr;
	reg [1:0] priv_lvl_d;
	reg [1:0] priv_lvl_q;
	reg debug_mode_q;
	reg debug_mode_d;
	reg mtvec_rst_load_q;
	reg [31:0] dpc_q;
	reg [31:0] dpc_d;
	reg [31:0] dscratch0_q;
	reg [31:0] dscratch0_d;
	reg [31:0] dscratch1_q;
	reg [31:0] dscratch1_d;
	reg [31:0] mtvec_q;
	reg [31:0] mtvec_d;
	reg [31:0] medeleg_q;
	reg [31:0] medeleg_d;
	reg [31:0] mideleg_q;
	reg [31:0] mideleg_d;
	reg [31:0] mip_q;
	reg [31:0] mip_d;
	reg [31:0] mie_q;
	reg [31:0] mie_d;
	reg [31:0] mcounteren_q;
	reg [31:0] mcounteren_d;
	reg [31:0] mscratch_q;
	reg [31:0] mscratch_d;
	reg [31:0] mepc_q;
	reg [31:0] mepc_d;
	reg [31:0] mcause_q;
	reg [31:0] mcause_d;
	reg [31:0] mtval_q;
	reg [31:0] mtval_d;
	reg [31:0] stvec_q;
	reg [31:0] stvec_d;
	reg [31:0] scounteren_q;
	reg [31:0] scounteren_d;
	reg [31:0] sscratch_q;
	reg [31:0] sscratch_d;
	reg [31:0] sepc_q;
	reg [31:0] sepc_d;
	reg [31:0] scause_q;
	reg [31:0] scause_d;
	reg [31:0] stval_q;
	reg [31:0] stval_d;
	reg [31:0] dcache_q;
	reg [31:0] dcache_d;
	reg [31:0] icache_q;
	reg [31:0] icache_d;
	reg wfi_d;
	reg wfi_q;
	reg [63:0] cycle_q;
	reg [63:0] cycle_d;
	reg [63:0] instret_q;
	reg [63:0] instret_d;
	reg [127:0] pmpcfg_q;
	reg [127:0] pmpcfg_d;
	reg [511:0] pmpaddr_q;
	reg [511:0] pmpaddr_d;
	assign pmpcfg_o = pmpcfg_q[0+:128];
	assign pmpaddr_o = pmpaddr_q;
	reg [31:0] fcsr_q;
	reg [31:0] fcsr_d;
	assign csr_addr = csr_addr_i;
	assign fs_o = mstatus_q[14-:2];
	localparam riscv_IS_XLEN64 = 1'b0;
	assign mstatus_extended = (riscv_IS_XLEN64 ? mstatus_q[31:0] : {mstatus_q[63], mstatus_q[30:23], mstatus_q[22:0]});
	localparam [31:0] ariane_pkg_ARIANE_MARCHID = 32'd3;
	localparam cva6_config_pkg_CVA6ConfigF16En = 0;
	localparam [0:0] ariane_pkg_XF16 = cva6_config_pkg_CVA6ConfigF16En;
	localparam cva6_config_pkg_CVA6ConfigF16AltEn = 0;
	localparam [0:0] ariane_pkg_XF16ALT = cva6_config_pkg_CVA6ConfigF16AltEn;
	localparam cva6_config_pkg_CVA6ConfigF8En = 0;
	localparam [0:0] ariane_pkg_XF8 = cva6_config_pkg_CVA6ConfigF8En;
	localparam cva6_config_pkg_CVA6ConfigFVecEn = 0;
	localparam [0:0] ariane_pkg_XFVEC = cva6_config_pkg_CVA6ConfigFVecEn;
	localparam [0:0] ariane_pkg_NSX = ((ariane_pkg_XF16 | ariane_pkg_XF16ALT) | ariane_pkg_XF8) | ariane_pkg_XFVEC;
	localparam cva6_config_pkg_CVA6ConfigAExtEn = 1;
	localparam [0:0] ariane_pkg_RVA = cva6_config_pkg_CVA6ConfigAExtEn;
	localparam cva6_config_pkg_CVA6ConfigCExtEn = 1;
	localparam [0:0] ariane_pkg_RVC = cva6_config_pkg_CVA6ConfigCExtEn;
	localparam cva6_config_pkg_CVA6ConfigFpuEn = 0;
	localparam riscv_FPU_EN = cva6_config_pkg_CVA6ConfigFpuEn;
	localparam [0:0] ariane_pkg_RVD = (riscv_IS_XLEN64 ? 1 : 0) & riscv_FPU_EN;
	localparam riscv_IS_XLEN32 = 1'b1;
	localparam [0:0] ariane_pkg_RVF = (riscv_IS_XLEN64 | riscv_IS_XLEN32) & riscv_FPU_EN;
	localparam [31:0] ariane_pkg_ISA_CODE = ((((((((((ariane_pkg_RVA << 0) | (ariane_pkg_RVC << 2)) | (ariane_pkg_RVD << 3)) | (ariane_pkg_RVF << 5)) | 256) | 4096) | 0) | 262144) | 1048576) | (ariane_pkg_NSX << 23)) | 1073741824;
	localparam [63:0] riscv_SSTATUS_FS = 'h6000;
	localparam [63:0] riscv_SSTATUS_MXR = 'h80000;
	localparam [63:0] riscv_SSTATUS_SD = {riscv_IS_XLEN64, 31'h00000000, ~riscv_IS_XLEN64, 31'h00000000};
	localparam [63:0] riscv_SSTATUS_SIE = 'h2;
	localparam [63:0] riscv_SSTATUS_SPIE = 'h20;
	localparam [63:0] riscv_SSTATUS_SPP = 'h100;
	localparam [63:0] riscv_SSTATUS_SUM = 'h40000;
	localparam [63:0] riscv_SSTATUS_UIE = 'h1;
	localparam [63:0] riscv_SSTATUS_UPIE = 'h10;
	localparam [63:0] riscv_SSTATUS_UXL = 64'h0000000300000000;
	localparam [63:0] riscv_SSTATUS_XS = 'h18000;
	localparam [63:0] ariane_pkg_SMODE_STATUS_READ_MASK = ((((((((((riscv_SSTATUS_UIE | riscv_SSTATUS_SIE) | riscv_SSTATUS_SPIE) | riscv_SSTATUS_SPP) | riscv_SSTATUS_FS) | riscv_SSTATUS_XS) | riscv_SSTATUS_SUM) | riscv_SSTATUS_MXR) | riscv_SSTATUS_UPIE) | riscv_SSTATUS_SPIE) | riscv_SSTATUS_UXL) | riscv_SSTATUS_SD;
	always @(*) begin : csr_read_process
		read_access_exception = 1'b0;
		csr_rdata = 1'sb0;
		perf_addr_o = csr_addr[4:0];
		if (csr_read)
			case (csr_addr[11-:12])
				12'h001:
					if (mstatus_q[14-:2] == 2'b00)
						read_access_exception = 1'b1;
					else
						csr_rdata = {{27 {1'b0}}, fcsr_q[4-:5]};
				12'h002:
					if (mstatus_q[14-:2] == 2'b00)
						read_access_exception = 1'b1;
					else
						csr_rdata = {{29 {1'b0}}, fcsr_q[7-:3]};
				12'h003:
					if (mstatus_q[14-:2] == 2'b00)
						read_access_exception = 1'b1;
					else
						csr_rdata = {{24 {1'b0}}, fcsr_q[7-:3], fcsr_q[4-:5]};
				12'h800:
					if (mstatus_q[14-:2] == 2'b00)
						read_access_exception = 1'b1;
					else
						csr_rdata = {{25 {1'b0}}, fcsr_q[14-:7]};
				12'h7b0: csr_rdata = {dcsr_q};
				12'h7b1: csr_rdata = dpc_q;
				12'h7b2: csr_rdata = dscratch0_q;
				12'h7b3: csr_rdata = dscratch1_q;
				12'h7a0:
					;
				12'h7a1:
					;
				12'h7a2:
					;
				12'h7a3:
					;
				12'h100: csr_rdata = mstatus_extended & ariane_pkg_SMODE_STATUS_READ_MASK[31:0];
				12'h104: csr_rdata = mie_q & mideleg_q;
				12'h144: csr_rdata = mip_q & mideleg_q;
				12'h105: csr_rdata = stvec_q;
				12'h106: csr_rdata = scounteren_q;
				12'h140: csr_rdata = sscratch_q;
				12'h141: csr_rdata = sepc_q;
				12'h142: csr_rdata = scause_q;
				12'h143: csr_rdata = stval_q;
				12'h180:
					if ((priv_lvl_o == 2'b01) && mstatus_q[20])
						read_access_exception = 1'b1;
					else
						csr_rdata = satp_q;
				12'h300: csr_rdata = mstatus_extended;
				12'h301: csr_rdata = ariane_pkg_ISA_CODE;
				12'h302: csr_rdata = medeleg_q;
				12'h303: csr_rdata = mideleg_q;
				12'h304: csr_rdata = mie_q;
				12'h305: csr_rdata = mtvec_q;
				12'h306: csr_rdata = mcounteren_q;
				12'h340: csr_rdata = mscratch_q;
				12'h341: csr_rdata = mepc_q;
				12'h342: csr_rdata = mcause_q;
				12'h343: csr_rdata = mtval_q;
				12'h344: csr_rdata = mip_q;
				12'hf11: csr_rdata = 1'sb0;
				12'hf12: csr_rdata = ariane_pkg_ARIANE_MARCHID;
				12'hf13: csr_rdata = 1'sb0;
				12'hf14: csr_rdata = hart_id_i;
				12'hb00: csr_rdata = cycle_q[31:0];
				12'hb80: csr_rdata = cycle_q[63:32];
				12'hb02: csr_rdata = instret_q[31:0];
				12'hb82: csr_rdata = instret_q[63:32];
				12'hc00: csr_rdata = cycle_q[31:0];
				12'hc80: csr_rdata = cycle_q[63:32];
				12'hc02: csr_rdata = instret_q[31:0];
				12'hc82: csr_rdata = instret_q[63:32];
				12'hb03, 12'hb04, 12'hb05, 12'hb06, 12'hb07, 12'hb08, 12'hb09, 12'hb0a, 12'hb0b, 12'hb0c, 12'hb0d, 12'hb0e, 12'hb0f, 12'hb10, 12'hb11, 12'hb12, 12'hb13, 12'hb14, 12'hb15, 12'hb16, 12'hb17, 12'hb18, 12'hb19, 12'hb1a, 12'hb1b, 12'hb1c, 12'hb1d, 12'hb1e, 12'hb1f: csr_rdata = perf_data_i;
				12'h701: csr_rdata = dcache_q;
				12'h700: csr_rdata = icache_q;
				12'h3a0: csr_rdata = pmpcfg_q[0+:32];
				12'h3a1: csr_rdata = pmpcfg_q[32+:32];
				12'h3a2: csr_rdata = pmpcfg_q[64+:32];
				12'h3a3: csr_rdata = pmpcfg_q[96+:32];
				12'h3b0, 12'h3b1, 12'h3b2, 12'h3b3, 12'h3b4, 12'h3b5, 12'h3b6, 12'h3b7, 12'h3b8, 12'h3b9, 12'h3ba, 12'h3bb, 12'h3bc, 12'h3bd, 12'h3be, 12'h3bf: begin : sv2v_autoblock_1
					reg signed [31:0] index;
					index = csr_addr[3:0];
					if (pmpcfg_q[(index * 8) + 4] == 1'b1)
						csr_rdata = {10'b0000000000, pmpaddr_q[(index * 32) + 31-:32]};
					else
						csr_rdata = {10'b0000000000, pmpaddr_q[(index * 32) + 31-:31], 1'b0};
				end
				default: read_access_exception = 1'b1;
			endcase
	end
	reg [31:0] mask;
	localparam [0:0] ariane_pkg_ENABLE_CYCLE_COUNT = 1'b1;
	localparam [0:0] ariane_pkg_FP_PRESENT = (((ariane_pkg_RVF | ariane_pkg_RVD) | ariane_pkg_XF16) | ariane_pkg_XF16ALT) | ariane_pkg_XF8;
	localparam [63:0] ariane_pkg_SMODE_STATUS_WRITE_MASK = ((((riscv_SSTATUS_SIE | riscv_SSTATUS_SPIE) | riscv_SSTATUS_SPP) | riscv_SSTATUS_FS) | riscv_SSTATUS_SUM) | riscv_SSTATUS_MXR;
	localparam [0:0] ariane_pkg_ZERO_TVAL = 1'b0;
	localparam [31:0] riscv_BREAKPOINT = 3;
	localparam [31:0] riscv_DEBUG_REQUEST = 24;
	localparam [31:0] riscv_ENV_CALL_MMODE = 11;
	localparam [31:0] riscv_ENV_CALL_SMODE = 9;
	localparam [31:0] riscv_ENV_CALL_UMODE = 8;
	localparam [31:0] riscv_ILLEGAL_INSTR = 2;
	localparam [31:0] riscv_INSTR_ADDR_MISALIGNED = 0;
	localparam [31:0] riscv_INSTR_PAGE_FAULT = 12;
	localparam [31:0] riscv_IRQ_M_EXT = 11;
	localparam [31:0] riscv_IRQ_M_SOFT = 3;
	localparam [31:0] riscv_IRQ_M_TIMER = 7;
	localparam [31:0] riscv_LOAD_PAGE_FAULT = 13;
	localparam [31:0] riscv_MIP_MEIP = 1 << riscv_IRQ_M_EXT;
	localparam [31:0] riscv_MIP_MSIP = 1 << riscv_IRQ_M_SOFT;
	localparam [31:0] riscv_MIP_MTIP = 1 << riscv_IRQ_M_TIMER;
	localparam [31:0] riscv_IRQ_S_EXT = 9;
	localparam [31:0] riscv_MIP_SEIP = 1 << riscv_IRQ_S_EXT;
	localparam [31:0] riscv_IRQ_S_SOFT = 1;
	localparam [31:0] riscv_MIP_SSIP = 1 << riscv_IRQ_S_SOFT;
	localparam [31:0] riscv_IRQ_S_TIMER = 5;
	localparam [31:0] riscv_MIP_STIP = 1 << riscv_IRQ_S_TIMER;
	localparam [3:0] riscv_MODE_SV = 4'd1;
	localparam [31:0] riscv_STORE_PAGE_FAULT = 15;
	function automatic [31:0] sv2v_cast_A29B5;
		input reg [31:0] inp;
		sv2v_cast_A29B5 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin : csr_update
		reg [31:0] satp;
		reg [63:0] instret;
		satp = satp_q;
		instret = instret_q;
		cycle_d = cycle_q;
		instret_d = instret_q;
		if (!debug_mode_q) begin
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < NrCommitPorts; i = i + 1)
					if (commit_ack_i[i] && !ex_i[0])
						instret = instret + 1;
			end
			instret_d = instret;
			if (ariane_pkg_ENABLE_CYCLE_COUNT)
				cycle_d = cycle_q + 1'b1;
			else
				cycle_d = instret;
		end
		eret_o = 1'b0;
		flush_o = 1'b0;
		update_access_exception = 1'b0;
		set_debug_pc_o = 1'b0;
		perf_we_o = 1'b0;
		perf_data_o = 'b0;
		fcsr_d = fcsr_q;
		priv_lvl_d = priv_lvl_q;
		debug_mode_d = debug_mode_q;
		dcsr_d = dcsr_q;
		dpc_d = dpc_q;
		dscratch0_d = dscratch0_q;
		dscratch1_d = dscratch1_q;
		mstatus_d = mstatus_q;
		if (mtvec_rst_load_q)
			mtvec_d = {boot_addr_i} + 'h40;
		else
			mtvec_d = mtvec_q;
		medeleg_d = medeleg_q;
		mideleg_d = mideleg_q;
		mip_d = mip_q;
		mie_d = mie_q;
		mepc_d = mepc_q;
		mcause_d = mcause_q;
		mcounteren_d = mcounteren_q;
		mscratch_d = mscratch_q;
		mtval_d = mtval_q;
		dcache_d = dcache_q;
		icache_d = icache_q;
		sepc_d = sepc_q;
		scause_d = scause_q;
		stvec_d = stvec_q;
		scounteren_d = scounteren_q;
		sscratch_d = sscratch_q;
		stval_d = stval_q;
		satp_d = satp_q;
		en_ld_st_translation_d = en_ld_st_translation_q;
		dirty_fp_state_csr = 1'b0;
		pmpcfg_d = pmpcfg_q;
		pmpaddr_d = pmpaddr_q;
		if (csr_we)
			case (csr_addr[11-:12])
				12'h001:
					if (mstatus_q[14-:2] == 2'b00)
						update_access_exception = 1'b1;
					else begin
						dirty_fp_state_csr = 1'b1;
						fcsr_d[4-:5] = csr_wdata[4:0];
						flush_o = 1'b1;
					end
				12'h002:
					if (mstatus_q[14-:2] == 2'b00)
						update_access_exception = 1'b1;
					else begin
						dirty_fp_state_csr = 1'b1;
						fcsr_d[7-:3] = csr_wdata[2:0];
						flush_o = 1'b1;
					end
				12'h003:
					if (mstatus_q[14-:2] == 2'b00)
						update_access_exception = 1'b1;
					else begin
						dirty_fp_state_csr = 1'b1;
						fcsr_d[7:0] = csr_wdata[7:0];
						flush_o = 1'b1;
					end
				12'h800:
					if (mstatus_q[14-:2] == 2'b00)
						update_access_exception = 1'b1;
					else begin
						dirty_fp_state_csr = 1'b1;
						fcsr_d[14-:7] = csr_wdata[6:0];
						flush_o = 1'b1;
					end
				12'h7b0: begin
					dcsr_d = csr_wdata[31:0];
					dcsr_d[31-:4] = 4'h4;
					dcsr_d[3] = 1'b0;
					dcsr_d[10] = 1'b0;
					dcsr_d[9] = 1'b0;
				end
				12'h7b1: dpc_d = csr_wdata;
				12'h7b2: dscratch0_d = csr_wdata;
				12'h7b3: dscratch1_d = csr_wdata;
				12'h7a0:
					;
				12'h7a1:
					;
				12'h7a2:
					;
				12'h7a3:
					;
				12'h100: begin
					mask = ariane_pkg_SMODE_STATUS_WRITE_MASK[31:0];
					mstatus_d = (mstatus_q & ~{{32 {1'b0}}, mask}) | {{32 {1'b0}}, csr_wdata & mask};
					if (!ariane_pkg_FP_PRESENT)
						mstatus_d[14-:2] = 2'b00;
					flush_o = 1'b1;
				end
				12'h104: mie_d = (mie_q & ~mideleg_q) | (csr_wdata & mideleg_q);
				12'h144: begin
					mask = riscv_MIP_SSIP & mideleg_q;
					mip_d = (mip_q & ~mask) | (csr_wdata & mask);
				end
				12'h105: stvec_d = {csr_wdata[31:2], 1'b0, csr_wdata[0]};
				12'h106: scounteren_d = {csr_wdata[31:0]};
				12'h140: sscratch_d = csr_wdata;
				12'h141: sepc_d = {csr_wdata[31:1], 1'b0};
				12'h142: scause_d = csr_wdata;
				12'h143: stval_d = csr_wdata;
				12'h180: begin
					if ((priv_lvl_o == 2'b01) && mstatus_q[20])
						update_access_exception = 1'b1;
					else begin
						satp = sv2v_cast_A29B5(csr_wdata);
						satp[30-:9] = satp[30-:9] & {{riscv_ASIDW - AsidWidth {1'b0}}, {AsidWidth {1'b1}}};
						if ((sv2v_cast_4(satp[31-:1]) == 4'd0) || (sv2v_cast_4(satp[31-:1]) == riscv_MODE_SV))
							satp_d = satp;
					end
					flush_o = 1'b1;
				end
				12'h300: begin
					mstatus_d = {{32 {1'b0}}, csr_wdata};
					mstatus_d[16-:2] = 2'b00;
					if (!ariane_pkg_FP_PRESENT)
						mstatus_d[14-:2] = 2'b00;
					mstatus_d[4] = 1'b0;
					mstatus_d[0] = 1'b0;
					flush_o = 1'b1;
				end
				12'h301:
					;
				12'h302: begin
					mask = (((((1 << riscv_INSTR_ADDR_MISALIGNED) | (1 << riscv_BREAKPOINT)) | (1 << riscv_ENV_CALL_UMODE)) | (1 << riscv_INSTR_PAGE_FAULT)) | (1 << riscv_LOAD_PAGE_FAULT)) | (1 << riscv_STORE_PAGE_FAULT);
					medeleg_d = (medeleg_q & ~mask) | (csr_wdata & mask);
				end
				12'h303: begin
					mask = (riscv_MIP_SSIP | riscv_MIP_STIP) | riscv_MIP_SEIP;
					mideleg_d = (mideleg_q & ~mask) | (csr_wdata & mask);
				end
				12'h304: begin
					mask = ((((riscv_MIP_SSIP | riscv_MIP_STIP) | riscv_MIP_SEIP) | riscv_MIP_MSIP) | riscv_MIP_MTIP) | riscv_MIP_MEIP;
					mie_d = (mie_q & ~mask) | (csr_wdata & mask);
				end
				12'h305: begin
					mtvec_d = {csr_wdata[31:2], 1'b0, csr_wdata[0]};
					if (csr_wdata[0])
						mtvec_d = {csr_wdata[31:8], 7'b0000000, csr_wdata[0]};
				end
				12'h306: mcounteren_d = {csr_wdata[31:0]};
				12'h340: mscratch_d = csr_wdata;
				12'h341: mepc_d = {csr_wdata[31:1], 1'b0};
				12'h342: mcause_d = csr_wdata;
				12'h343: mtval_d = csr_wdata;
				12'h344: begin
					mask = (riscv_MIP_SSIP | riscv_MIP_STIP) | riscv_MIP_SEIP;
					mip_d = (mip_q & ~mask) | (csr_wdata & mask);
				end
				12'hb00: cycle_d[31:0] = csr_wdata;
				12'hb80: cycle_d[63:32] = csr_wdata;
				12'hb02: instret[31:0] = csr_wdata;
				12'hb82: instret[63:32] = csr_wdata;
				12'hb03, 12'hb04, 12'hb05, 12'hb06, 12'hb07, 12'hb08, 12'hb09, 12'hb0a, 12'hb0b, 12'hb0c, 12'hb0d, 12'hb0e, 12'hb0f, 12'hb10, 12'hb11, 12'hb12, 12'hb13, 12'hb14, 12'hb15, 12'hb16, 12'hb17, 12'hb18, 12'hb19, 12'hb1a, 12'hb1b, 12'hb1c, 12'hb1d, 12'hb1e, 12'hb1f: begin
					perf_data_o = csr_wdata;
					perf_we_o = 1'b1;
				end
				12'h701: dcache_d = {{31 {1'b0}}, csr_wdata[0]};
				12'h700: icache_d = {{31 {1'b0}}, csr_wdata[0]};
				12'h3a0: begin : sv2v_autoblock_3
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[(i * 8) + 7])
							pmpcfg_d[i * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a1: begin : sv2v_autoblock_4
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 4) * 8) + 7])
							pmpcfg_d[(i + 4) * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a2: begin : sv2v_autoblock_5
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 8) * 8) + 7])
							pmpcfg_d[(i + 8) * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a3: begin : sv2v_autoblock_6
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 12) * 8) + 7])
							pmpcfg_d[(i + 12) * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3b0, 12'h3b1, 12'h3b2, 12'h3b3, 12'h3b4, 12'h3b5, 12'h3b6, 12'h3b7, 12'h3b8, 12'h3b9, 12'h3ba, 12'h3bb, 12'h3bc, 12'h3bd, 12'h3be, 12'h3bf: begin : sv2v_autoblock_7
					reg signed [31:0] index;
					index = csr_addr[3:0];
					if (!pmpcfg_q[(index * 8) + 7] && !(pmpcfg_q[(index * 8) + 7] && (pmpcfg_q[(index * 8) + 4-:2] == 2'b01)))
						pmpaddr_d[index * 32+:32] = csr_wdata[31:0];
				end
				default: update_access_exception = 1'b1;
			endcase
		mstatus_d[35-:2] = 2'b10;
		mstatus_d[33-:2] = 2'b10;
		if (ariane_pkg_FP_PRESENT && (dirty_fp_state_csr || dirty_fp_state_i))
			mstatus_d[14-:2] = 2'b11;
		mstatus_d[63] = (mstatus_q[16-:2] == 2'b11) | (mstatus_q[14-:2] == 2'b11);
		if (csr_write_fflags_i)
			fcsr_d[4-:5] = csr_wdata_i[4:0] | fcsr_q[4-:5];
		mip_d[riscv_IRQ_M_EXT] = irq_i[0];
		mip_d[riscv_IRQ_M_SOFT] = ipi_i;
		mip_d[riscv_IRQ_M_TIMER] = time_irq_i;
		trap_to_priv_lvl = 2'b11;
		if ((!debug_mode_q && (ex_i[64-:32] != riscv_DEBUG_REQUEST)) && ex_i[0]) begin
			flush_o = 1'b0;
			if ((ex_i[64] && mideleg_q[ex_i[37:33]]) || (~ex_i[64] && medeleg_q[ex_i[37:33]]))
				trap_to_priv_lvl = (priv_lvl_o == 2'b11 ? 2'b11 : 2'b01);
			if (trap_to_priv_lvl == 2'b01) begin
				mstatus_d[1] = 1'b0;
				mstatus_d[5] = mstatus_q[1];
				mstatus_d[8] = priv_lvl_q[0];
				scause_d = ex_i[64-:32];
				sepc_d = {pc_i};
				stval_d = (1'b0 && (|{ex_i[64-:32] == 32'd2, ex_i[64-:32] == 32'd3, ex_i[64-:32] == 32'd8, ex_i[64-:32] == 32'd9, ex_i[64-:32] == 32'd11} || ex_i[64]) ? {32 {1'sb0}} : ex_i[32-:32]);
			end
			else begin
				mstatus_d[3] = 1'b0;
				mstatus_d[7] = mstatus_q[3];
				mstatus_d[12-:2] = priv_lvl_q;
				mcause_d = ex_i[64-:32];
				mepc_d = {pc_i};
				mtval_d = (1'b0 && (|{ex_i[64-:32] == 32'd2, ex_i[64-:32] == 32'd3, ex_i[64-:32] == 32'd8, ex_i[64-:32] == 32'd9, ex_i[64-:32] == 32'd11} || ex_i[64]) ? {32 {1'sb0}} : ex_i[32-:32]);
			end
			priv_lvl_d = trap_to_priv_lvl;
		end
		if (!debug_mode_q) begin
			dcsr_d[1-:2] = priv_lvl_o;
			if (ex_i[0] && (ex_i[64-:32] == riscv_BREAKPOINT)) begin
				dcsr_d[1-:2] = priv_lvl_o;
				case (priv_lvl_o)
					2'b11: begin
						debug_mode_d = dcsr_q[15];
						set_debug_pc_o = dcsr_q[15];
					end
					2'b01: begin
						debug_mode_d = dcsr_q[13];
						set_debug_pc_o = dcsr_q[13];
					end
					2'b00: begin
						debug_mode_d = dcsr_q[12];
						set_debug_pc_o = dcsr_q[12];
					end
					default:
						;
				endcase
				dpc_d = {pc_i};
			end
			if (ex_i[0] && (ex_i[64-:32] == riscv_DEBUG_REQUEST)) begin
				dcsr_d[1-:2] = priv_lvl_o;
				dpc_d = {pc_i};
				debug_mode_d = 1'b1;
				set_debug_pc_o = 1'b1;
			end
			if (dcsr_q[2] && commit_ack_i[0]) begin
				dcsr_d[1-:2] = priv_lvl_o;
				if (commit_instr_i[166-:4] == 4'd4)
					dpc_d = {commit_instr_i[32-:riscv_VLEN]};
				else if (ex_i[0])
					dpc_d = {trap_vector_base_o};
				else if (eret_o)
					dpc_d = {epc_o};
				else
					dpc_d = {commit_instr_i[201-:32] + (commit_instr_i[0] ? 'h2 : 'h4)};
				debug_mode_d = 1'b1;
				set_debug_pc_o = 1'b1;
			end
		end
		if ((debug_mode_q && ex_i[0]) && (ex_i[64-:32] == riscv_BREAKPOINT))
			set_debug_pc_o = 1'b1;
		if ((mprv && (sv2v_cast_4(satp_q[31-:1]) == riscv_MODE_SV)) && (mstatus_q[12-:2] != 2'b11))
			en_ld_st_translation_d = 1'b1;
		else
			en_ld_st_translation_d = en_translation_o;
		ld_st_priv_lvl_o = (mprv ? mstatus_q[12-:2] : priv_lvl_o);
		en_ld_st_translation_o = en_ld_st_translation_q;
		if (mret) begin
			eret_o = 1'b1;
			mstatus_d[3] = mstatus_q[7];
			priv_lvl_d = mstatus_q[12-:2];
			mstatus_d[12-:2] = 2'b00;
			mstatus_d[7] = 1'b1;
		end
		if (sret) begin
			eret_o = 1'b1;
			mstatus_d[1] = mstatus_q[5];
			priv_lvl_d = sv2v_cast_2({1'b0, mstatus_q[8]});
			mstatus_d[8] = 1'b0;
			mstatus_d[5] = 1'b1;
		end
		if (dret) begin
			eret_o = 1'b1;
			priv_lvl_d = sv2v_cast_2(dcsr_q[1-:2]);
			debug_mode_d = 1'b0;
		end
	end
	always @(*) begin : csr_op_logic
		csr_wdata = csr_wdata_i;
		csr_we = 1'b1;
		csr_read = 1'b1;
		mret = 1'b0;
		sret = 1'b0;
		dret = 1'b0;
		case (csr_op_i)
			8'd31: csr_wdata = csr_wdata_i;
			8'd33: csr_wdata = csr_wdata_i | csr_rdata;
			8'd34: csr_wdata = ~csr_wdata_i & csr_rdata;
			8'd32: csr_we = 1'b0;
			8'd24: begin
				csr_we = 1'b0;
				csr_read = 1'b0;
				sret = 1'b1;
			end
			8'd23: begin
				csr_we = 1'b0;
				csr_read = 1'b0;
				mret = 1'b1;
			end
			8'd25: begin
				csr_we = 1'b0;
				csr_read = 1'b0;
				dret = 1'b1;
			end
			default: begin
				csr_we = 1'b0;
				csr_read = 1'b0;
			end
		endcase
		if (privilege_violation) begin
			csr_we = 1'b0;
			csr_read = 1'b0;
		end
	end
	assign irq_ctrl_o[97-:32] = mie_q;
	assign irq_ctrl_o[65-:32] = mip_q;
	assign irq_ctrl_o[1] = mstatus_q[1];
	assign irq_ctrl_o[33-:32] = mideleg_q;
	assign irq_ctrl_o[0] = (~debug_mode_q & (~dcsr_q[2] | dcsr_q[11])) & ((mstatus_q[3] & (priv_lvl_o == 2'b11)) | (priv_lvl_o != 2'b11));
	always @(*) begin : privilege_check
		privilege_violation = 1'b0;
		if (|{csr_op_i == 8'd31, csr_op_i == 8'd33, csr_op_i == 8'd34, csr_op_i == 8'd32}) begin
			if (sv2v_cast_2(priv_lvl_o & csr_addr[9-:2]) != csr_addr[9-:2])
				privilege_violation = 1'b1;
			if ((csr_addr_i[11:4] == 8'h7b) && !debug_mode_q)
				privilege_violation = 1'b1;
			if ((12'hc00 <= csr_addr_i) && (12'hc1f >= csr_addr_i))
				case (priv_lvl_o)
					2'b11: privilege_violation = 1'b0;
					2'b01: privilege_violation = ~mcounteren_q[csr_addr_i[4:0]];
					2'b00: privilege_violation = ~mcounteren_q[csr_addr_i[4:0]] & ~scounteren_q[csr_addr_i[4:0]];
				endcase
		end
	end
	always @(*) begin : exception_ctrl
		csr_exception_o = 3'b000;
		if (update_access_exception || read_access_exception) begin
			csr_exception_o[64-:32] = riscv_ILLEGAL_INSTR;
			csr_exception_o[0] = 1'b1;
		end
		if (privilege_violation) begin
			csr_exception_o[64-:32] = riscv_ILLEGAL_INSTR;
			csr_exception_o[0] = 1'b1;
		end
	end
	always @(*) begin : wfi_ctrl
		wfi_d = wfi_q;
		if ((|(mip_q & mie_q) || debug_req_i) || irq_i[1])
			wfi_d = 1'b0;
		else if ((!debug_mode_q && (csr_op_i == 8'd27)) && !ex_i[0])
			wfi_d = 1'b1;
	end
	always @(*) begin : priv_output
		trap_vector_base_o = {mtvec_q[31:2], 2'b00};
		if (trap_to_priv_lvl == 2'b01)
			trap_vector_base_o = {stvec_q[31:2], 2'b00};
		if (ex_i[64] && (((trap_to_priv_lvl == 2'b11) && mtvec_q[0]) || ((trap_to_priv_lvl == 2'b01) && stvec_q[0])))
			trap_vector_base_o[7:2] = ex_i[38:33];
		epc_o = mepc_q[31:0];
		if (sret)
			epc_o = sepc_q[31:0];
		if (dret)
			epc_o = dpc_q[31:0];
	end
	always @(*) begin
		csr_rdata_o = csr_rdata;
		case (csr_addr[11-:12])
			12'h344: csr_rdata_o = csr_rdata | (irq_i[1] << riscv_IRQ_S_EXT);
			12'h144: csr_rdata_o = csr_rdata | ((irq_i[1] & mideleg_q[riscv_IRQ_S_EXT]) << riscv_IRQ_S_EXT);
			default:
				;
		endcase
	end
	assign priv_lvl_o = (debug_mode_q ? 2'b11 : priv_lvl_q);
	assign fflags_o = fcsr_q[4-:5];
	assign frm_o = fcsr_q[7-:3];
	assign fprec_o = fcsr_q[14-:7];
	assign satp_ppn_o = satp_q[21-:riscv_PPNW];
	assign asid_o = satp_q[21 + AsidWidth:22];
	assign sum_o = mstatus_q[18];
	assign en_translation_o = ((sv2v_cast_4(satp_q[31-:1]) == riscv_MODE_SV) && (priv_lvl_o != 2'b11) ? 1'b1 : 1'b0);
	assign mxr_o = mstatus_q[19];
	assign tvm_o = mstatus_q[20];
	assign tw_o = mstatus_q[21];
	assign tsr_o = mstatus_q[22];
	assign halt_csr_o = wfi_q;
	assign icache_en_o = icache_q[0] & ~debug_mode_q;
	assign dcache_en_o = dcache_q[0];
	assign mprv = (debug_mode_q && !dcsr_q[4] ? 1'b0 : mstatus_q[17]);
	assign debug_mode_o = debug_mode_q;
	assign single_step_o = dcsr_q[2];
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			priv_lvl_q <= 2'b11;
			fcsr_q <= 1'sb0;
			debug_mode_q <= 1'b0;
			dcsr_q <= 1'sb0;
			dcsr_q[1-:2] <= 2'b11;
			dcsr_q[31-:4] <= 4'h4;
			dpc_q <= 1'sb0;
			dscratch0_q <= {riscv_XLEN {1'b0}};
			dscratch1_q <= {riscv_XLEN {1'b0}};
			mstatus_q <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mtvec_rst_load_q <= 1'b1;
			mtvec_q <= 1'sb0;
			medeleg_q <= {riscv_XLEN {1'b0}};
			mideleg_q <= {riscv_XLEN {1'b0}};
			mip_q <= {riscv_XLEN {1'b0}};
			mie_q <= {riscv_XLEN {1'b0}};
			mepc_q <= {riscv_XLEN {1'b0}};
			mcause_q <= {riscv_XLEN {1'b0}};
			mcounteren_q <= {riscv_XLEN {1'b0}};
			mscratch_q <= {riscv_XLEN {1'b0}};
			mtval_q <= {riscv_XLEN {1'b0}};
			dcache_q <= {{31 {1'b0}}, 1'b1};
			icache_q <= {{31 {1'b0}}, 1'b1};
			sepc_q <= {riscv_XLEN {1'b0}};
			scause_q <= {riscv_XLEN {1'b0}};
			stvec_q <= {riscv_XLEN {1'b0}};
			scounteren_q <= {riscv_XLEN {1'b0}};
			sscratch_q <= {riscv_XLEN {1'b0}};
			stval_q <= {riscv_XLEN {1'b0}};
			satp_q <= {riscv_XLEN {1'b0}};
			cycle_q <= {riscv_XLEN {1'b0}};
			instret_q <= {riscv_XLEN {1'b0}};
			en_ld_st_translation_q <= 1'b0;
			wfi_q <= 1'b0;
			pmpcfg_q <= 1'sb0;
			pmpaddr_q <= 1'sb0;
		end
		else begin
			priv_lvl_q <= priv_lvl_d;
			fcsr_q <= fcsr_d;
			debug_mode_q <= debug_mode_d;
			dcsr_q <= dcsr_d;
			dpc_q <= dpc_d;
			dscratch0_q <= dscratch0_d;
			dscratch1_q <= dscratch1_d;
			mstatus_q <= mstatus_d;
			mtvec_rst_load_q <= 1'b0;
			mtvec_q <= mtvec_d;
			medeleg_q <= medeleg_d;
			mideleg_q <= mideleg_d;
			mip_q <= mip_d;
			mie_q <= mie_d;
			mepc_q <= mepc_d;
			mcause_q <= mcause_d;
			mcounteren_q <= mcounteren_d;
			mscratch_q <= mscratch_d;
			mtval_q <= mtval_d;
			dcache_q <= dcache_d;
			icache_q <= icache_d;
			sepc_q <= sepc_d;
			scause_q <= scause_d;
			stvec_q <= stvec_d;
			scounteren_q <= scounteren_d;
			sscratch_q <= sscratch_d;
			stval_q <= stval_d;
			satp_q <= satp_d;
			cycle_q <= cycle_d;
			instret_q <= instret_d;
			en_ld_st_translation_q <= en_ld_st_translation_d;
			wfi_q <= wfi_d;
			begin : sv2v_autoblock_8
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					if (i < NrPMPEntries) begin
						if ((pmpcfg_d[(i * 8) + 4-:2] != 2'b10) && !((pmpcfg_d[i * 8] == 1'b0) && (pmpcfg_d[(i * 8) + 1] == 1'b1)))
							pmpcfg_q[i * 8+:8] <= pmpcfg_d[i * 8+:8];
						else
							pmpcfg_q[i * 8+:8] <= pmpcfg_q[i * 8+:8];
						pmpaddr_q[i * 32+:32] <= pmpaddr_d[i * 32+:32];
					end
					else begin
						pmpcfg_q[i * 8+:8] <= 1'sb0;
						pmpaddr_q[i * 32+:32] <= 1'sb0;
					end
			end
		end
endmodule
