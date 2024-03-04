module alu (
	clk_i,
	rst_ni,
	fu_data_i,
	result_o,
	alu_branch_res_o
);
	input wire clk_i;
	input wire rst_ni;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	output reg [31:0] result_o;
	output reg alu_branch_res_o;
	wire [31:0] operand_a_rev;
	wire [31:0] operand_a_rev32;
	wire [riscv_XLEN:0] operand_b_neg;
	wire [33:0] adder_result_ext_o;
	reg less;
	reg [31:0] rolw;
	reg [31:0] rorw;
	reg [31:0] orcbw;
	reg [31:0] rev8w;
	wire [5:0] cpop;
	wire [4:0] lz_tz_count;
	wire [4:0] lz_tz_wcount;
	wire lz_tz_empty;
	wire lz_tz_wempty;
	genvar k;
	generate
		for (k = 0; k < riscv_XLEN; k = k + 1) begin : genblk1
			assign operand_a_rev[k] = fu_data_i[98 - (0 + k)];
		end
		for (k = 0; k < 32; k = k + 1) begin : genblk2
			assign operand_a_rev32[k] = fu_data_i[98 - (0 + k)];
		end
	endgenerate
	reg adder_op_b_negate;
	wire adder_z_flag;
	wire [riscv_XLEN:0] adder_in_a;
	wire [riscv_XLEN:0] adder_in_b;
	wire [31:0] adder_result;
	reg [31:0] operand_a_bitmanip;
	reg [31:0] bit_indx;
	always @(*) begin
		adder_op_b_negate = 1'b0;
		case (fu_data_i[106-:8])
			8'd17, 8'd18, 8'd1, 8'd3, 8'd163, 8'd164, 8'd165: adder_op_b_negate = 1'b1;
			default:
				;
		endcase
	end
	localparam [0:0] ariane_pkg_BITMANIP = 1'b1;
	always @(*) begin
		operand_a_bitmanip = fu_data_i[98-:32];
		if (ariane_pkg_BITMANIP)
			case (fu_data_i[106-:8])
				8'd160: operand_a_bitmanip = fu_data_i[98-:32] << 1;
				8'd161: operand_a_bitmanip = fu_data_i[98-:32] << 2;
				8'd162: operand_a_bitmanip = fu_data_i[98-:32] << 3;
				8'd155: operand_a_bitmanip = fu_data_i[98:67] << 1;
				8'd156: operand_a_bitmanip = fu_data_i[98:67] << 2;
				8'd157: operand_a_bitmanip = fu_data_i[98:67] << 3;
				8'd138: operand_a_bitmanip = operand_a_rev;
				8'd139: operand_a_bitmanip = operand_a_rev32;
				8'd158, 8'd135, 8'd137: operand_a_bitmanip = fu_data_i[98:67];
				default:
					;
			endcase
	end
	assign adder_in_a = {operand_a_bitmanip, 1'b1};
	assign operand_b_neg = {fu_data_i[66-:32], 1'b0} ^ {33 {adder_op_b_negate}};
	assign adder_in_b = operand_b_neg;
	assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);
	assign adder_result = adder_result_ext_o[riscv_XLEN:1];
	assign adder_z_flag = ~|adder_result;
	always @(*) begin : branch_resolve
		alu_branch_res_o = 1'b1;
		case (fu_data_i[106-:8])
			8'd17: alu_branch_res_o = adder_z_flag;
			8'd18: alu_branch_res_o = ~adder_z_flag;
			8'd13, 8'd14: alu_branch_res_o = less;
			8'd15, 8'd16: alu_branch_res_o = ~less;
			default: alu_branch_res_o = 1'b1;
		endcase
	end
	wire shift_left;
	wire shift_arithmetic;
	wire [31:0] shift_amt;
	wire [31:0] shift_op_a;
	wire [31:0] shift_op_a32;
	wire [31:0] shift_result;
	wire [31:0] shift_result32;
	wire [riscv_XLEN:0] shift_right_result;
	wire [32:0] shift_right_result32;
	wire [31:0] shift_left_result;
	wire [31:0] shift_left_result32;
	assign shift_amt = fu_data_i[66-:32];
	assign shift_left = (fu_data_i[106-:8] == 8'd9) | (fu_data_i[106-:8] == 8'd11);
	assign shift_arithmetic = (fu_data_i[106-:8] == 8'd7) | (fu_data_i[106-:8] == 8'd12);
	wire [riscv_XLEN:0] shift_op_a_64;
	wire [32:0] shift_op_a_32;
	assign shift_op_a = (shift_left ? operand_a_rev : fu_data_i[98-:32]);
	assign shift_op_a32 = (shift_left ? operand_a_rev32 : fu_data_i[98:67]);
	assign shift_op_a_64 = {shift_arithmetic & shift_op_a[31], shift_op_a};
	assign shift_op_a_32 = {shift_arithmetic & shift_op_a[31], shift_op_a32};
	assign shift_right_result = $unsigned($signed(shift_op_a_64) >>> shift_amt[5:0]);
	assign shift_right_result32 = $unsigned($signed(shift_op_a_32) >>> shift_amt[4:0]);
	genvar j;
	generate
		for (j = 0; j < riscv_XLEN; j = j + 1) begin : genblk3
			assign shift_left_result[j] = shift_right_result[31 - j];
		end
		for (j = 0; j < 32; j = j + 1) begin : genblk4
			assign shift_left_result32[j] = shift_right_result32[31 - j];
		end
	endgenerate
	assign shift_result = (shift_left ? shift_left_result : shift_right_result[31:0]);
	assign shift_result32 = (shift_left ? shift_left_result32 : shift_right_result32[31:0]);
	always @(*) begin : sv2v_autoblock_1
		reg sgn;
		sgn = 1'b0;
		if (((((fu_data_i[106-:8] == 8'd21) || (fu_data_i[106-:8] == 8'd13)) || (fu_data_i[106-:8] == 8'd15)) || (fu_data_i[106-:8] == 8'd151)) || (fu_data_i[106-:8] == 8'd153))
			sgn = 1'b1;
		less = $signed({sgn & fu_data_i[98], fu_data_i[98-:32]}) < $signed({sgn & fu_data_i[66], fu_data_i[66-:32]});
	end
	generate
		if (ariane_pkg_BITMANIP) begin : gen_bitmanip
			popcount #(.INPUT_WIDTH(riscv_XLEN)) i_cpop_count(
				.data_i(operand_a_bitmanip),
				.popcount_o(cpop)
			);
			lzc #(
				.WIDTH(riscv_XLEN),
				.MODE(1)
			) i_clz_64b(
				.in_i(operand_a_bitmanip),
				.cnt_o(lz_tz_count),
				.empty_o(lz_tz_empty)
			);
			lzc #(
				.WIDTH(32),
				.MODE(1)
			) i_clz_32b(
				.in_i(operand_a_bitmanip[31:0]),
				.cnt_o(lz_tz_wcount),
				.empty_o(lz_tz_wempty)
			);
		end
	endgenerate
	always @(*) begin
		result_o = 1'sb0;
		case (fu_data_i[106-:8])
			8'd6, 8'd163: result_o = fu_data_i[98-:32] & operand_b_neg[riscv_XLEN:1];
			8'd5, 8'd164: result_o = fu_data_i[98-:32] | operand_b_neg[riscv_XLEN:1];
			8'd4, 8'd165: result_o = fu_data_i[98-:32] ^ operand_b_neg[riscv_XLEN:1];
			8'd0, 8'd1, 8'd158, 8'd160, 8'd161, 8'd162, 8'd155, 8'd156, 8'd157: result_o = adder_result;
			8'd2, 8'd3: result_o = {adder_result[31:0]};
			8'd9, 8'd8, 8'd7: result_o = shift_result32;
			8'd11, 8'd10, 8'd12: result_o = {shift_result32[31:0]};
			8'd21, 8'd22: result_o = {{31 {1'b0}}, less};
			default:
				;
		endcase
		if (ariane_pkg_BITMANIP) begin
			bit_indx = 1 << (fu_data_i[66-:32] & 31);
			orcbw = {{8 {|fu_data_i[98:91]}}, {8 {|fu_data_i[90:83]}}, {8 {|fu_data_i[82:75]}}, {8 {|fu_data_i[74:67]}}};
			rev8w = {{fu_data_i[74:67]}, {fu_data_i[82:75]}, {fu_data_i[90:83]}, {fu_data_i[98:91]}};
			rolw = ({fu_data_i[98:67]} << fu_data_i[39:35]) | ({fu_data_i[98:67]} >> -fu_data_i[39:35]);
			rorw = ({fu_data_i[98:67]} >> fu_data_i[39:35]) | ({fu_data_i[98:67]} << -fu_data_i[39:35]);
			case (fu_data_i[106-:8])
				8'd159: result_o = {fu_data_i[98:67]} << fu_data_i[40:35];
				8'd151: result_o = (less ? fu_data_i[66-:32] : fu_data_i[98-:32]);
				8'd152: result_o = (less ? fu_data_i[66-:32] : fu_data_i[98-:32]);
				8'd153: result_o = (~less ? fu_data_i[66-:32] : fu_data_i[98-:32]);
				8'd154: result_o = (~less ? fu_data_i[66-:32] : fu_data_i[98-:32]);
				8'd143, 8'd144: result_o = fu_data_i[98-:32] & ~bit_indx;
				8'd145, 8'd146: result_o = |(fu_data_i[98-:32] & bit_indx);
				8'd147, 8'd148: result_o = fu_data_i[98-:32] ^ bit_indx;
				8'd149, 8'd150: result_o = fu_data_i[98-:32] | bit_indx;
				8'd136, 8'd138: result_o = (lz_tz_empty ? lz_tz_count + 1 : lz_tz_count);
				8'd137, 8'd139: result_o = (lz_tz_wempty ? 32 : lz_tz_wcount);
				8'd134, 8'd135: result_o = cpop;
				8'd131: result_o = {{24 {fu_data_i[74]}}, fu_data_i[74:67]};
				8'd132: result_o = {{16 {fu_data_i[82]}}, fu_data_i[82:67]};
				8'd133: result_o = {{16 {1'b0}}, fu_data_i[82:67]};
				8'd125: result_o = (fu_data_i[98-:32] << fu_data_i[39:35]) | (fu_data_i[98-:32] >> (riscv_XLEN - fu_data_i[39:35]));
				8'd126: result_o = {rolw};
				8'd127, 8'd128: result_o = (fu_data_i[98-:32] >> fu_data_i[39:35]) | (fu_data_i[98-:32] << (riscv_XLEN - fu_data_i[39:35]));
				8'd130, 8'd129: result_o = {rorw};
				8'd123: result_o = orcbw;
				8'd124: result_o = rev8w;
				default:
					;
			endcase
		end
	end
endmodule
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
	fifo_v3_4F30F_AEF03 #(
		.dtype_riscv_PLEN(riscv_PLEN),
		.dtype_riscv_XLEN(riscv_XLEN),
		.DEPTH(1)
	) i_amo_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_amo_buffer),
		.testmode_i(1'b0),
		.full_o(amo_valid),
		.empty_o(ready_o),
		.usage_o(),
		.data_i(amo_data_in),
		.push_i(valid_i),
		.data_o(amo_data_out),
		.pop_i(amo_resp_i[64])
	);
endmodule
module ariane (
	clk_i,
	rst_ni,
	boot_addr_i,
	hart_id_i,
	irq_i,
	ipi_i,
	time_irq_i,
	debug_req_i,
	axi_req_o,
	axi_resp_i
);
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [31:0] boot_addr_i;
	input wire [31:0] hart_id_i;
	input wire [1:0] irq_i;
	input wire ipi_i;
	input wire time_irq_i;
	input wire debug_req_i;
	localparam ariane_axi_AddrWidth = 64;
	localparam ariane_axi_IdWidth = 4;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam cva6_config_pkg_CVA6ConfigFetchUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigFetchUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_FETCH_USER_WIDTH = 1;
	localparam ariane_pkg_AXI_USER_WIDTH = ariane_pkg_FETCH_USER_WIDTH;
	localparam ariane_axi_UserWidth = ariane_pkg_AXI_USER_WIDTH;
	localparam ariane_axi_DataWidth = 64;
	localparam ariane_axi_StrbWidth = 8;
	output wire [280:0] axi_req_o;
	input wire [83:0] axi_resp_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cvxif_pkg_X_ID_WIDTH = ariane_pkg_TRANS_ID_BITS;
	localparam ariane_pkg_NR_RGPR_PORTS = 2;
	localparam cvxif_pkg_X_NUM_RS = ariane_pkg_NR_RGPR_PORTS;
	localparam cvxif_pkg_X_RFR_WIDTH = riscv_XLEN;
	localparam cvxif_pkg_X_MEM_WIDTH = 64;
	wire [208:0] cvxif_req;
	localparam cvxif_pkg_X_RFW_WIDTH = riscv_XLEN;
	wire [196:0] cvxif_resp;
	cva6 #(.ArianeCfg(ArianeCfg)) i_cva6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.boot_addr_i(boot_addr_i),
		.hart_id_i(hart_id_i),
		.irq_i(irq_i),
		.ipi_i(ipi_i),
		.time_irq_i(time_irq_i),
		.debug_req_i(debug_req_i),
		.cvxif_req_o(cvxif_req),
		.cvxif_resp_i(cvxif_resp),
		.axi_req_o(axi_req_o),
		.axi_resp_i(axi_resp_i)
	);
	localparam cva6_config_pkg_CVA6ConfigCvxifEn = 0;
	localparam [0:0] ariane_pkg_CVXIF_PRESENT = cva6_config_pkg_CVA6ConfigCvxifEn;
	generate
		if (ariane_pkg_CVXIF_PRESENT) begin : gen_example_coprocessor
			cvxif_example_coprocessor i_cvxif_coprocessor(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.cvxif_req_i(cvxif_req),
				.cvxif_resp_o(cvxif_resp)
			);
		end
	endgenerate
endmodule
module ariane_regfile_lol (
	clk_i,
	rst_ni,
	test_en_i,
	raddr_i,
	rdata_o,
	waddr_i,
	wdata_i,
	we_i
);
	parameter [31:0] DATA_WIDTH = 32;
	parameter [31:0] NR_READ_PORTS = 2;
	parameter [31:0] NR_WRITE_PORTS = 2;
	parameter [0:0] ZERO_REG_ZERO = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [(NR_READ_PORTS * 5) - 1:0] raddr_i;
	output wire [(NR_READ_PORTS * DATA_WIDTH) - 1:0] rdata_o;
	input wire [(NR_WRITE_PORTS * 5) - 1:0] waddr_i;
	input wire [(NR_WRITE_PORTS * DATA_WIDTH) - 1:0] wdata_i;
	input wire [NR_WRITE_PORTS - 1:0] we_i;
	localparam ADDR_WIDTH = 5;
	localparam NUM_WORDS = 32;
	wire [31:ZERO_REG_ZERO] mem_clocks;
	reg [DATA_WIDTH - 1:0] mem [0:31];
	reg [(NR_WRITE_PORTS * 31) + 0:1] waddr_onehot;
	reg [(NR_WRITE_PORTS * 31) + 0:1] waddr_onehot_q;
	reg [(NR_WRITE_PORTS * DATA_WIDTH) - 1:0] wdata_q;
	genvar i;
	generate
		for (i = 0; i < NR_READ_PORTS; i = i + 1) begin : genblk1
			assign rdata_o[i * DATA_WIDTH+:DATA_WIDTH] = mem[raddr_i[(i * 5) + 4-:5]];
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni) begin : sample_waddr
		if (~rst_ni)
			wdata_q <= 1'sb0;
		else begin
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < NR_WRITE_PORTS; i = i + 1)
					if (we_i[i])
						wdata_q[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_i[i * DATA_WIDTH+:DATA_WIDTH];
			end
			waddr_onehot_q <= waddr_onehot;
		end
	end
	always @(*) begin : decode_write_addess
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 0; i < NR_WRITE_PORTS; i = i + 1)
				begin : sv2v_autoblock_3
					reg [31:0] j;
					for (j = 1; j < NUM_WORDS; j = j + 1)
						if (we_i[i] && (waddr_i[i * 5+:5] == j))
							waddr_onehot[(i * 31) + j] = 1'b1;
						else
							waddr_onehot[(i * 31) + j] = 1'b0;
				end
		end
	end
	genvar x;
	generate
		for (x = ZERO_REG_ZERO; x < NUM_WORDS; x = x + 1) begin : genblk2
			wire [NR_WRITE_PORTS - 1:0] waddr_ored;
			genvar i;
			for (i = 0; i < NR_WRITE_PORTS; i = i + 1) begin : genblk1
				assign waddr_ored[i] = waddr_onehot[(i * 31) + x];
			end
			cluster_clock_gating i_cg(
				.clk_i(clk_i),
				.en_i(|waddr_ored),
				.test_en_i(test_en_i),
				.clk_o(mem_clocks[x])
			);
		end
	endgenerate
	always @(*) begin : latch_wdata
		if (ZERO_REG_ZERO)
			mem[0] = 1'sb0;
		begin : sv2v_autoblock_4
			reg [31:0] i;
			for (i = 0; i < NR_WRITE_PORTS; i = i + 1)
				begin : sv2v_autoblock_5
					reg [31:0] k;
					for (k = ZERO_REG_ZERO; k < NUM_WORDS; k = k + 1)
						if (mem_clocks[k] && waddr_onehot_q[(i * 31) + k])
							mem[k] = wdata_q[i * DATA_WIDTH+:DATA_WIDTH];
				end
		end
	end
endmodule
module ariane_regfile (
	clk_i,
	rst_ni,
	test_en_i,
	raddr_i,
	rdata_o,
	waddr_i,
	wdata_i,
	we_i
);
	parameter [31:0] DATA_WIDTH = 32;
	parameter [31:0] NR_READ_PORTS = 2;
	parameter [31:0] NR_WRITE_PORTS = 2;
	parameter [0:0] ZERO_REG_ZERO = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [(NR_READ_PORTS * 5) - 1:0] raddr_i;
	output wire [(NR_READ_PORTS * DATA_WIDTH) - 1:0] rdata_o;
	input wire [(NR_WRITE_PORTS * 5) - 1:0] waddr_i;
	input wire [(NR_WRITE_PORTS * DATA_WIDTH) - 1:0] wdata_i;
	input wire [NR_WRITE_PORTS - 1:0] we_i;
	localparam ADDR_WIDTH = 5;
	localparam NUM_WORDS = 32;
	reg [(32 * DATA_WIDTH) - 1:0] mem;
	reg [(NR_WRITE_PORTS * 32) - 1:0] we_dec;
	always @(*) begin : we_decoder
		begin : sv2v_autoblock_1
			reg [31:0] j;
			for (j = 0; j < NR_WRITE_PORTS; j = j + 1)
				begin : sv2v_autoblock_2
					reg [31:0] i;
					for (i = 0; i < NUM_WORDS; i = i + 1)
						if (waddr_i[j * 5+:5] == i)
							we_dec[(j * 32) + i] = we_i[j];
						else
							we_dec[(j * 32) + i] = 1'b0;
				end
		end
	end
	function automatic [DATA_WIDTH - 1:0] sv2v_cast_9134D;
		input reg [DATA_WIDTH - 1:0] inp;
		sv2v_cast_9134D = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni) begin : register_write_behavioral
		if (~rst_ni)
			mem <= {NUM_WORDS {sv2v_cast_9134D(1'sb0)}};
		else begin : sv2v_autoblock_3
			reg [31:0] j;
			for (j = 0; j < NR_WRITE_PORTS; j = j + 1)
				begin
					begin : sv2v_autoblock_4
						reg [31:0] i;
						for (i = 0; i < NUM_WORDS; i = i + 1)
							if (we_dec[(j * 32) + i])
								mem[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_i[j * DATA_WIDTH+:DATA_WIDTH];
					end
					if (ZERO_REG_ZERO)
						mem[0+:DATA_WIDTH] <= 1'sb0;
				end
		end
	end
	genvar i;
	generate
		for (i = 0; i < NR_READ_PORTS; i = i + 1) begin : genblk1
			assign rdata_o[i * DATA_WIDTH+:DATA_WIDTH] = mem[raddr_i[i * 5+:5] * DATA_WIDTH+:DATA_WIDTH];
		end
	endgenerate
endmodule
module axi_adapter (
	clk_i,
	rst_ni,
	req_i,
	type_i,
	amo_i,
	gnt_o,
	addr_i,
	we_i,
	wdata_i,
	be_i,
	size_i,
	id_i,
	valid_o,
	rdata_o,
	id_o,
	critical_word_o,
	critical_word_valid_o,
	axi_req_o,
	axi_resp_i
);
	parameter [31:0] DATA_WIDTH = 256;
	parameter [0:0] CRITICAL_WORD_FIRST = 0;
	parameter [31:0] AXI_ID_WIDTH = 10;
	parameter [31:0] CACHELINE_BYTE_OFFSET = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire req_i;
	input wire type_i;
	input wire [3:0] amo_i;
	output reg gnt_o;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [31:0] addr_i;
	input wire we_i;
	input wire [((DATA_WIDTH / riscv_XLEN) * 32) - 1:0] wdata_i;
	input wire [((DATA_WIDTH / riscv_XLEN) * 4) - 1:0] be_i;
	input wire [1:0] size_i;
	input wire [AXI_ID_WIDTH - 1:0] id_i;
	output reg valid_o;
	output reg [((DATA_WIDTH / riscv_XLEN) * 32) - 1:0] rdata_o;
	output reg [AXI_ID_WIDTH - 1:0] id_o;
	output reg [31:0] critical_word_o;
	output reg critical_word_valid_o;
	localparam ariane_axi_AddrWidth = 64;
	localparam ariane_axi_IdWidth = 4;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam cva6_config_pkg_CVA6ConfigFetchUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigFetchUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_FETCH_USER_WIDTH = 1;
	localparam ariane_pkg_AXI_USER_WIDTH = ariane_pkg_FETCH_USER_WIDTH;
	localparam ariane_axi_UserWidth = ariane_pkg_AXI_USER_WIDTH;
	localparam ariane_axi_DataWidth = 64;
	localparam ariane_axi_StrbWidth = 8;
	output reg [280:0] axi_req_o;
	input wire [83:0] axi_resp_i;
	localparam BURST_SIZE = (DATA_WIDTH / riscv_XLEN) - 1;
	localparam ADDR_INDEX = ($clog2(DATA_WIDTH / 32) > 0 ? $clog2(DATA_WIDTH / 32) : 1);
	reg [3:0] state_q;
	reg [3:0] state_d;
	reg [ADDR_INDEX - 1:0] cnt_d;
	reg [ADDR_INDEX - 1:0] cnt_q;
	reg [((DATA_WIDTH / riscv_XLEN) * 32) - 1:0] cache_line_d;
	reg [((DATA_WIDTH / riscv_XLEN) * 32) - 1:0] cache_line_q;
	reg [(DATA_WIDTH / riscv_XLEN) - 1:0] addr_offset_d;
	reg [(DATA_WIDTH / riscv_XLEN) - 1:0] addr_offset_q;
	reg [AXI_ID_WIDTH - 1:0] id_d;
	reg [AXI_ID_WIDTH - 1:0] id_q;
	reg [ADDR_INDEX - 1:0] index;
	reg [3:0] amo_d;
	reg [3:0] amo_q;
	reg [1:0] size_d;
	reg [1:0] size_q;
	localparam axi_pkg_ATOP_ADD = 3'b000;
	localparam axi_pkg_ATOP_ATOMICLOAD = 2'b10;
	localparam axi_pkg_ATOP_ATOMICSWAP = 6'b110000;
	localparam axi_pkg_ATOP_CLR = 3'b001;
	localparam axi_pkg_ATOP_EOR = 3'b010;
	localparam axi_pkg_ATOP_LITTLE_END = 1'b0;
	localparam axi_pkg_ATOP_NONE = 2'b00;
	localparam axi_pkg_ATOP_SET = 3'b011;
	localparam axi_pkg_ATOP_SMAX = 3'b100;
	localparam axi_pkg_ATOP_SMIN = 3'b101;
	localparam axi_pkg_ATOP_UMAX = 3'b110;
	localparam axi_pkg_ATOP_UMIN = 3'b111;
	function automatic [5:0] atop_from_amo;
		input reg [3:0] amo;
		reg [5:0] result;
		begin
			result = 6'b000000;
			case (amo)
				4'b0000: result = {axi_pkg_ATOP_NONE, 4'b0000};
				4'b0011: result = {axi_pkg_ATOP_ATOMICSWAP};
				4'b0100: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_ADD};
				4'b0101: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_CLR};
				4'b0110: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_SET};
				4'b0111: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_EOR};
				4'b1000: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_SMAX};
				4'b1001: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_UMAX};
				4'b1010: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_SMIN};
				4'b1011: result = {axi_pkg_ATOP_ATOMICLOAD, axi_pkg_ATOP_LITTLE_END, axi_pkg_ATOP_UMIN};
				4'b1100: result = {axi_pkg_ATOP_NONE, 4'b0000};
				4'b1101: result = {axi_pkg_ATOP_NONE, 4'b0000};
				default: result = 6'b000000;
			endcase
			atop_from_amo = result;
		end
	endfunction
	function automatic amo_returns_data;
		input reg [3:0] amo;
		reg [5:0] atop;
		reg is_load;
		reg is_swap_or_cmp;
		begin
			atop = atop_from_amo(amo);
			is_load = atop[5:4] == axi_pkg_ATOP_ATOMICLOAD;
			is_swap_or_cmp = atop[5:4] == axi_pkg_ATOP_ATOMICSWAP[5:4];
			amo_returns_data = is_load || is_swap_or_cmp;
		end
	endfunction
	localparam axi_pkg_BURST_INCR = 2'b01;
	localparam axi_pkg_BURST_WRAP = 2'b10;
	localparam axi_pkg_RESP_EXOKAY = 2'b01;
	always @(*) begin : axi_fsm
		axi_req_o[176] = 1'b0;
		axi_req_o[276-:64] = addr_i;
		axi_req_o[194-:3] = 3'b000;
		axi_req_o[187-:4] = 4'b0000;
		axi_req_o[212-:8] = 8'b00000000;
		axi_req_o[204-:3] = {1'b0, size_i};
		axi_req_o[201-:2] = axi_pkg_BURST_INCR;
		axi_req_o[199] = 1'b0;
		axi_req_o[198-:4] = 4'b0000;
		axi_req_o[191-:4] = 4'b0000;
		axi_req_o[280-:4] = id_i;
		axi_req_o[183-:6] = atop_from_amo(amo_i);
		axi_req_o[177-:ariane_axi_UserWidth] = 1'sb0;
		axi_req_o[1] = 1'b0;
		axi_req_o[95-:64] = (CRITICAL_WORD_FIRST || (type_i == 1'd0) ? addr_i : {addr_i[31:CACHELINE_BYTE_OFFSET], {{CACHELINE_BYTE_OFFSET} {1'b0}}});
		axi_req_o[13-:3] = 3'b000;
		axi_req_o[6-:4] = 4'b0000;
		axi_req_o[31-:8] = 8'b00000000;
		axi_req_o[23-:3] = {1'b0, size_i};
		axi_req_o[20-:2] = (CRITICAL_WORD_FIRST ? axi_pkg_BURST_WRAP : axi_pkg_BURST_INCR);
		axi_req_o[18] = 1'b0;
		axi_req_o[17-:4] = 4'b0000;
		axi_req_o[10-:4] = 4'b0000;
		axi_req_o[99-:4] = id_i;
		axi_req_o[2-:ariane_axi_UserWidth] = 1'sb0;
		axi_req_o[101] = 1'b0;
		axi_req_o[175-:64] = wdata_i[0+:32];
		axi_req_o[111-:8] = be_i[0+:4];
		axi_req_o[103] = 1'b0;
		axi_req_o[102-:ariane_axi_UserWidth] = 1'sb0;
		axi_req_o[100] = 1'b0;
		axi_req_o[0] = 1'b0;
		gnt_o = 1'b0;
		valid_o = 1'b0;
		id_o = axi_resp_i[71-:4];
		critical_word_o = axi_resp_i[67-:64];
		critical_word_valid_o = 1'b0;
		rdata_o = cache_line_q;
		state_d = state_q;
		cnt_d = cnt_q;
		cache_line_d = cache_line_q;
		addr_offset_d = addr_offset_q;
		id_d = id_q;
		amo_d = amo_q;
		size_d = size_q;
		index = 1'sb0;
		case (state_q)
			4'd0: begin
				cnt_d = 1'sb0;
				if (req_i)
					if (we_i) begin
						axi_req_o[176] = 1'b1;
						axi_req_o[101] = 1'b1;
						axi_req_o[199] = amo_i == 4'b0010;
						if (type_i == 1'd0) begin
							axi_req_o[103] = 1'b1;
							gnt_o = axi_resp_i[83] & axi_resp_i[81];
							case ({axi_resp_i[83], axi_resp_i[81]})
								2'b11: state_d = 4'd1;
								2'b01: state_d = 4'd2;
								2'b10: state_d = 4'd3;
								default: state_d = 4'd0;
							endcase
							if (axi_resp_i[83]) begin
								amo_d = amo_i;
								size_d = size_i;
							end
						end
						else begin
							axi_req_o[212-:8] = BURST_SIZE;
							axi_req_o[175-:64] = wdata_i[0+:32];
							axi_req_o[111-:8] = be_i[0+:4];
							if (axi_resp_i[81])
								cnt_d = BURST_SIZE - 1;
							else
								cnt_d = BURST_SIZE;
							case ({axi_resp_i[83], axi_resp_i[81]})
								2'b11: state_d = 4'd3;
								2'b01: state_d = 4'd4;
								2'b10: state_d = 4'd3;
								default:
									;
							endcase
						end
					end
					else begin
						axi_req_o[1] = 1'b1;
						axi_req_o[18] = amo_i == 4'b0001;
						gnt_o = axi_resp_i[82];
						if (type_i != 1'd0) begin
							axi_req_o[31-:8] = BURST_SIZE;
							cnt_d = BURST_SIZE;
						end
						if (axi_resp_i[82]) begin
							state_d = (type_i == 1'd0 ? 4'd6 : 4'd7);
							addr_offset_d = addr_i[ADDR_INDEX + 2:3];
						end
					end
			end
			4'd2: begin
				axi_req_o[176] = 1'b1;
				if (axi_resp_i[83]) begin
					gnt_o = 1'b1;
					state_d = 4'd1;
					amo_d = amo_i;
					size_d = size_i;
				end
			end
			4'd4: begin
				axi_req_o[101] = 1'b1;
				axi_req_o[103] = cnt_q == {ADDR_INDEX {1'sb0}};
				if (type_i == 1'd0) begin
					axi_req_o[175-:64] = wdata_i[0+:32];
					axi_req_o[111-:8] = be_i[0+:4];
				end
				else begin
					axi_req_o[175-:64] = wdata_i[(BURST_SIZE - cnt_q) * 32+:32];
					axi_req_o[111-:8] = be_i[(BURST_SIZE - cnt_q) * 4+:4];
				end
				axi_req_o[176] = 1'b1;
				axi_req_o[212-:8] = BURST_SIZE;
				case ({axi_resp_i[83], axi_resp_i[81]})
					2'b01:
						if (cnt_q == 0)
							state_d = 4'd5;
						else
							cnt_d = cnt_q - 1;
					2'b10: state_d = 4'd3;
					2'b11:
						if (cnt_q == 0) begin
							state_d = 4'd1;
							gnt_o = 1'b1;
						end
						else begin
							state_d = 4'd3;
							cnt_d = cnt_q - 1;
						end
					default:
						;
				endcase
			end
			4'd5: begin
				axi_req_o[176] = 1'b1;
				axi_req_o[212-:8] = BURST_SIZE;
				if (axi_resp_i[83]) begin
					state_d = 4'd1;
					gnt_o = 1'b1;
				end
			end
			4'd3: begin
				axi_req_o[101] = 1'b1;
				if (type_i != 1'd0) begin
					axi_req_o[175-:64] = wdata_i[(BURST_SIZE - cnt_q) * 32+:32];
					axi_req_o[111-:8] = be_i[(BURST_SIZE - cnt_q) * 4+:4];
				end
				if (cnt_q == {ADDR_INDEX {1'sb0}}) begin
					axi_req_o[103] = 1'b1;
					if (axi_resp_i[81]) begin
						state_d = 4'd1;
						gnt_o = 1'b1;
					end
				end
				else if (axi_resp_i[81])
					cnt_d = cnt_q - 1;
			end
			4'd1: begin
				id_o = axi_resp_i[79-:4];
				if (axi_resp_i[80]) begin
					axi_req_o[100] = 1'b1;
					if (amo_returns_data(amo_q)) begin
						if (axi_resp_i[72]) begin
							valid_o = 1'b1;
							axi_req_o[0] = 1'b1;
							state_d = 4'd0;
							rdata_o = axi_resp_i[67-:64];
						end
						else
							state_d = 4'd9;
					end
					else begin
						valid_o = 1'b1;
						state_d = 4'd0;
						if (amo_q == 4'b0010)
							if (axi_resp_i[75-:2] == axi_pkg_RESP_EXOKAY)
								rdata_o = 1'b0;
							else
								rdata_o = (size_q == 2'b10 ? (1'b1 << 32) | 64'b0000000000000000000000000000000000000000000000000000000000000001 : 64'b0000000000000000000000000000000000000000000000000000000000000001);
					end
				end
			end
			4'd9:
				if (axi_resp_i[72]) begin
					axi_req_o[0] = 1'b1;
					state_d = 4'd0;
					valid_o = 1'b1;
					rdata_o = axi_resp_i[67-:64];
				end
			4'd7, 4'd6: begin
				if (CRITICAL_WORD_FIRST)
					index = addr_offset_q + (BURST_SIZE - cnt_q);
				else
					index = BURST_SIZE - cnt_q;
				axi_req_o[0] = 1'b1;
				if (axi_resp_i[72]) begin
					if (CRITICAL_WORD_FIRST) begin
						if ((state_q == 4'd7) && (cnt_q == BURST_SIZE)) begin
							critical_word_valid_o = 1'b1;
							critical_word_o = axi_resp_i[67-:64];
						end
					end
					else if (index == addr_offset_q) begin
						critical_word_valid_o = 1'b1;
						critical_word_o = axi_resp_i[67-:64];
					end
					if (axi_resp_i[1]) begin
						id_d = axi_resp_i[71-:4];
						state_d = 4'd8;
					end
					if (state_q == 4'd7)
						cache_line_d[index * 32+:32] = axi_resp_i[67-:64];
					else
						cache_line_d[0+:32] = axi_resp_i[67-:64];
					cnt_d = cnt_q - 1;
				end
			end
			4'd8: begin
				valid_o = 1'b1;
				state_d = 4'd0;
				id_o = id_q;
			end
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 4'd0;
			cnt_q <= 1'sb0;
			cache_line_q <= 1'sb0;
			addr_offset_q <= 1'sb0;
			id_q <= 1'sb0;
			amo_q <= 4'b0000;
			size_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			cnt_q <= cnt_d;
			cache_line_q <= cache_line_d;
			addr_offset_q <= addr_offset_d;
			id_q <= id_d;
			amo_q <= amo_d;
			size_q <= size_d;
		end
endmodule
module axi_shim (
	clk_i,
	rst_ni,
	rd_req_i,
	rd_gnt_o,
	rd_addr_i,
	rd_blen_i,
	rd_size_i,
	rd_id_i,
	rd_lock_i,
	rd_rdy_i,
	rd_last_o,
	rd_valid_o,
	rd_data_o,
	rd_user_o,
	rd_id_o,
	rd_exokay_o,
	wr_req_i,
	wr_gnt_o,
	wr_addr_i,
	wr_data_i,
	wr_user_i,
	wr_be_i,
	wr_blen_i,
	wr_size_i,
	wr_id_i,
	wr_lock_i,
	wr_atop_i,
	wr_rdy_i,
	wr_valid_o,
	wr_id_o,
	wr_exokay_o,
	axi_req_o,
	axi_resp_i
);
	parameter [31:0] AxiUserWidth = 64;
	parameter [31:0] AxiNumWords = 4;
	parameter [31:0] AxiIdWidth = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire rd_req_i;
	output wire rd_gnt_o;
	input wire [63:0] rd_addr_i;
	input wire [$clog2(AxiNumWords) - 1:0] rd_blen_i;
	input wire [1:0] rd_size_i;
	input wire [AxiIdWidth - 1:0] rd_id_i;
	input wire rd_lock_i;
	input wire rd_rdy_i;
	output wire rd_last_o;
	output wire rd_valid_o;
	output wire [63:0] rd_data_o;
	output wire [AxiUserWidth - 1:0] rd_user_o;
	output wire [AxiIdWidth - 1:0] rd_id_o;
	output wire rd_exokay_o;
	input wire wr_req_i;
	output reg wr_gnt_o;
	input wire [63:0] wr_addr_i;
	input wire [(AxiNumWords * 64) - 1:0] wr_data_i;
	input wire [(AxiNumWords * AxiUserWidth) - 1:0] wr_user_i;
	input wire [(AxiNumWords * 8) - 1:0] wr_be_i;
	input wire [$clog2(AxiNumWords) - 1:0] wr_blen_i;
	input wire [1:0] wr_size_i;
	input wire [AxiIdWidth - 1:0] wr_id_i;
	input wire wr_lock_i;
	input wire [5:0] wr_atop_i;
	input wire wr_rdy_i;
	output wire wr_valid_o;
	output wire [AxiIdWidth - 1:0] wr_id_o;
	output wire wr_exokay_o;
	localparam ariane_axi_AddrWidth = 64;
	localparam ariane_axi_IdWidth = 4;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam cva6_config_pkg_CVA6ConfigFetchUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigFetchUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_FETCH_USER_WIDTH = 1;
	localparam ariane_pkg_AXI_USER_WIDTH = ariane_pkg_FETCH_USER_WIDTH;
	localparam ariane_axi_UserWidth = ariane_pkg_AXI_USER_WIDTH;
	localparam ariane_axi_DataWidth = 64;
	localparam ariane_axi_StrbWidth = 8;
	output reg [280:0] axi_req_o;
	input wire [83:0] axi_resp_i;
	localparam AddrIndex = ($clog2(AxiNumWords) > 0 ? $clog2(AxiNumWords) : 1);
	reg [3:0] wr_state_q;
	reg [3:0] wr_state_d;
	wire [AddrIndex - 1:0] wr_cnt_d;
	reg [AddrIndex - 1:0] wr_cnt_q;
	wire wr_single_req;
	wire wr_cnt_done;
	reg wr_cnt_clr;
	reg wr_cnt_en;
	assign wr_single_req = wr_blen_i == 0;
	localparam axi_pkg_BURST_INCR = 2'b01;
	wire [2:1] sv2v_tmp_6E9DC;
	assign sv2v_tmp_6E9DC = axi_pkg_BURST_INCR;
	always @(*) axi_req_o[201-:2] = sv2v_tmp_6E9DC;
	wire [64:1] sv2v_tmp_930DC;
	assign sv2v_tmp_930DC = wr_addr_i;
	always @(*) axi_req_o[276-:64] = sv2v_tmp_930DC;
	wire [3:1] sv2v_tmp_448EB;
	assign sv2v_tmp_448EB = wr_size_i;
	always @(*) axi_req_o[204-:3] = sv2v_tmp_448EB;
	wire [8:1] sv2v_tmp_8D74F;
	assign sv2v_tmp_8D74F = wr_blen_i;
	always @(*) axi_req_o[212-:8] = sv2v_tmp_8D74F;
	wire [4:1] sv2v_tmp_96550;
	assign sv2v_tmp_96550 = wr_id_i;
	always @(*) axi_req_o[280-:4] = sv2v_tmp_96550;
	wire [3:1] sv2v_tmp_B8D42;
	assign sv2v_tmp_B8D42 = 3'b000;
	always @(*) axi_req_o[194-:3] = sv2v_tmp_B8D42;
	wire [4:1] sv2v_tmp_88B04;
	assign sv2v_tmp_88B04 = 4'b0000;
	always @(*) axi_req_o[187-:4] = sv2v_tmp_88B04;
	wire [1:1] sv2v_tmp_2B037;
	assign sv2v_tmp_2B037 = wr_lock_i;
	always @(*) axi_req_o[199] = sv2v_tmp_2B037;
	wire [4:1] sv2v_tmp_D3810;
	assign sv2v_tmp_D3810 = 4'b0000;
	always @(*) axi_req_o[198-:4] = sv2v_tmp_D3810;
	wire [4:1] sv2v_tmp_32328;
	assign sv2v_tmp_32328 = 4'b0000;
	always @(*) axi_req_o[191-:4] = sv2v_tmp_32328;
	wire [6:1] sv2v_tmp_FD09F;
	assign sv2v_tmp_FD09F = wr_atop_i;
	always @(*) axi_req_o[183-:6] = sv2v_tmp_FD09F;
	wire [64:1] sv2v_tmp_96288;
	assign sv2v_tmp_96288 = wr_data_i[wr_cnt_q * 64+:64];
	always @(*) axi_req_o[175-:64] = sv2v_tmp_96288;
	wire [1:1] sv2v_tmp_5F7C7;
	assign sv2v_tmp_5F7C7 = wr_user_i[wr_cnt_q * AxiUserWidth+:AxiUserWidth];
	always @(*) axi_req_o[102-:ariane_axi_UserWidth] = sv2v_tmp_5F7C7;
	wire [8:1] sv2v_tmp_CF23C;
	assign sv2v_tmp_CF23C = wr_be_i[wr_cnt_q * 8+:8];
	always @(*) axi_req_o[111-:8] = sv2v_tmp_CF23C;
	wire [1:1] sv2v_tmp_1AB64;
	assign sv2v_tmp_1AB64 = wr_cnt_done;
	always @(*) axi_req_o[103] = sv2v_tmp_1AB64;
	localparam axi_pkg_RESP_EXOKAY = 2'b01;
	assign wr_exokay_o = axi_resp_i[75-:2] == axi_pkg_RESP_EXOKAY;
	wire [1:1] sv2v_tmp_3E233;
	assign sv2v_tmp_3E233 = wr_rdy_i;
	always @(*) axi_req_o[100] = sv2v_tmp_3E233;
	assign wr_valid_o = axi_resp_i[80];
	assign wr_id_o = axi_resp_i[79-:4];
	assign wr_cnt_done = wr_cnt_q == wr_blen_i;
	assign wr_cnt_d = (wr_cnt_clr ? {AddrIndex {1'sb0}} : (wr_cnt_en ? wr_cnt_q + 1 : wr_cnt_q));
	always @(*) begin : p_axi_write_fsm
		wr_state_d = wr_state_q;
		axi_req_o[176] = 1'b0;
		axi_req_o[101] = 1'b0;
		wr_gnt_o = 1'b0;
		wr_cnt_en = 1'b0;
		wr_cnt_clr = 1'b0;
		case (wr_state_q)
			4'd0:
				if (wr_req_i) begin
					axi_req_o[176] = 1'b1;
					axi_req_o[101] = 1'b1;
					if (wr_single_req) begin
						wr_cnt_clr = 1'b1;
						wr_gnt_o = axi_resp_i[83] & axi_resp_i[81];
						case ({axi_resp_i[83], axi_resp_i[81]})
							2'b01: wr_state_d = 4'd1;
							2'b10: wr_state_d = 4'd2;
							default: wr_state_d = 4'd0;
						endcase
					end
					else begin
						wr_cnt_en = axi_resp_i[81];
						case ({axi_resp_i[83], axi_resp_i[81]})
							2'b11: wr_state_d = 4'd2;
							2'b01: wr_state_d = 4'd3;
							2'b10: wr_state_d = 4'd2;
							default:
								;
						endcase
					end
				end
			4'd1: begin
				axi_req_o[176] = 1'b1;
				if (axi_resp_i[83]) begin
					wr_state_d = 4'd0;
					wr_gnt_o = 1'b1;
				end
			end
			4'd3: begin
				axi_req_o[101] = 1'b1;
				axi_req_o[176] = 1'b1;
				case ({axi_resp_i[83], axi_resp_i[81]})
					2'b01:
						if (wr_cnt_done) begin
							wr_state_d = 4'd4;
							wr_cnt_clr = 1'b1;
						end
						else
							wr_cnt_en = 1'b1;
					2'b10: wr_state_d = 4'd2;
					2'b11:
						if (wr_cnt_done) begin
							wr_state_d = 4'd0;
							wr_gnt_o = 1'b1;
							wr_cnt_clr = 1'b1;
						end
						else begin
							wr_state_d = 4'd2;
							wr_cnt_en = 1'b1;
						end
					default:
						;
				endcase
			end
			4'd4: begin
				axi_req_o[176] = 1'b1;
				if (axi_resp_i[83]) begin
					wr_state_d = 4'd0;
					wr_gnt_o = 1'b1;
				end
			end
			4'd2: begin
				axi_req_o[101] = 1'b1;
				if (wr_cnt_done) begin
					if (axi_resp_i[81]) begin
						wr_state_d = 4'd0;
						wr_cnt_clr = 1'b1;
						wr_gnt_o = 1'b1;
					end
				end
				else if (axi_resp_i[81])
					wr_cnt_en = 1'b1;
			end
			default: wr_state_d = 4'd0;
		endcase
	end
	wire [2:1] sv2v_tmp_20CF9;
	assign sv2v_tmp_20CF9 = axi_pkg_BURST_INCR;
	always @(*) axi_req_o[20-:2] = sv2v_tmp_20CF9;
	wire [64:1] sv2v_tmp_975D7;
	assign sv2v_tmp_975D7 = rd_addr_i;
	always @(*) axi_req_o[95-:64] = sv2v_tmp_975D7;
	wire [3:1] sv2v_tmp_2B990;
	assign sv2v_tmp_2B990 = rd_size_i;
	always @(*) axi_req_o[23-:3] = sv2v_tmp_2B990;
	wire [8:1] sv2v_tmp_E0E65;
	assign sv2v_tmp_E0E65 = rd_blen_i;
	always @(*) axi_req_o[31-:8] = sv2v_tmp_E0E65;
	wire [4:1] sv2v_tmp_7B90C;
	assign sv2v_tmp_7B90C = rd_id_i;
	always @(*) axi_req_o[99-:4] = sv2v_tmp_7B90C;
	wire [3:1] sv2v_tmp_A8AC6;
	assign sv2v_tmp_A8AC6 = 3'b000;
	always @(*) axi_req_o[13-:3] = sv2v_tmp_A8AC6;
	wire [4:1] sv2v_tmp_49C20;
	assign sv2v_tmp_49C20 = 4'b0000;
	always @(*) axi_req_o[6-:4] = sv2v_tmp_49C20;
	wire [1:1] sv2v_tmp_99F91;
	assign sv2v_tmp_99F91 = rd_lock_i;
	always @(*) axi_req_o[18] = sv2v_tmp_99F91;
	wire [4:1] sv2v_tmp_042AF;
	assign sv2v_tmp_042AF = 4'b0000;
	always @(*) axi_req_o[17-:4] = sv2v_tmp_042AF;
	wire [4:1] sv2v_tmp_F01FC;
	assign sv2v_tmp_F01FC = 4'b0000;
	always @(*) axi_req_o[10-:4] = sv2v_tmp_F01FC;
	wire [1:1] sv2v_tmp_8FD7F;
	assign sv2v_tmp_8FD7F = rd_req_i;
	always @(*) axi_req_o[1] = sv2v_tmp_8FD7F;
	assign rd_gnt_o = rd_req_i & axi_resp_i[82];
	wire [1:1] sv2v_tmp_967F1;
	assign sv2v_tmp_967F1 = rd_rdy_i;
	always @(*) axi_req_o[0] = sv2v_tmp_967F1;
	assign rd_data_o = axi_resp_i[67-:64];
	assign rd_user_o = axi_resp_i[0-:ariane_axi_UserWidth];
	assign rd_last_o = axi_resp_i[1];
	assign rd_valid_o = axi_resp_i[72];
	assign rd_id_o = axi_resp_i[71-:4];
	assign rd_exokay_o = axi_resp_i[3-:2] == axi_pkg_RESP_EXOKAY;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			wr_state_q <= 4'd0;
			wr_cnt_q <= 1'sb0;
		end
		else begin
			wr_state_q <= wr_state_d;
			wr_cnt_q <= wr_cnt_d;
		end
endmodule
module branch_unit (
	clk_i,
	rst_ni,
	debug_mode_i,
	fu_data_i,
	pc_i,
	is_compressed_instr_i,
	fu_valid_i,
	branch_valid_i,
	branch_comp_res_i,
	branch_result_o,
	branch_predict_i,
	resolved_branch_o,
	resolve_branch_o,
	branch_exception_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire debug_mode_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	localparam riscv_VLEN = 32;
	input wire [31:0] pc_i;
	input wire is_compressed_instr_i;
	input wire fu_valid_i;
	input wire branch_valid_i;
	input wire branch_comp_res_i;
	output reg [31:0] branch_result_o;
	input wire [34:0] branch_predict_i;
	output reg [69:0] resolved_branch_o;
	output reg resolve_branch_o;
	output reg [64:0] branch_exception_o;
	reg [31:0] target_address;
	reg [31:0] next_pc;
	function automatic ariane_pkg_op_is_branch;
		input reg [7:0] op;
		if (|{op == 8'd17, op == 8'd18, op == 8'd13, op == 8'd15, op == 8'd14, op == 8'd16})
			ariane_pkg_op_is_branch = 1'b1;
		else
			ariane_pkg_op_is_branch = 1'b0;
	endfunction
	always @(*) begin : mispredict_handler
		reg [31:0] jump_base;
		jump_base = (fu_data_i[106-:8] == 8'd19 ? fu_data_i[98:67] : pc_i);
		target_address = {riscv_VLEN {1'b0}};
		resolve_branch_o = 1'b0;
		resolved_branch_o[36-:32] = {riscv_VLEN {1'b0}};
		resolved_branch_o[3] = 1'b0;
		resolved_branch_o[69] = branch_valid_i;
		resolved_branch_o[4] = 1'b0;
		resolved_branch_o[2-:3] = branch_predict_i[34-:3];
		next_pc = pc_i + (is_compressed_instr_i ? {{30 {1'b0}}, 2'h2} : {{29 {1'b0}}, 3'h4});
		target_address = $unsigned($signed(jump_base) + $signed(fu_data_i[34:3]));
		if (fu_data_i[106-:8] == 8'd19)
			target_address[0] = 1'b0;
		branch_result_o = next_pc;
		resolved_branch_o[68-:32] = pc_i;
		if (branch_valid_i) begin
			resolved_branch_o[36-:32] = (branch_comp_res_i ? target_address : next_pc);
			resolved_branch_o[3] = branch_comp_res_i;
			if (ariane_pkg_op_is_branch(fu_data_i[106-:8])) begin
				resolved_branch_o[2-:3] = 3'd1;
				resolved_branch_o[4] = branch_comp_res_i != (branch_predict_i[34-:3] == 3'd1);
			end
			if ((fu_data_i[106-:8] == 8'd19) && ((branch_predict_i[34-:3] == 3'd0) || (target_address != branch_predict_i[31-:riscv_VLEN]))) begin
				resolved_branch_o[4] = 1'b1;
				if (branch_predict_i[34-:3] != 3'd4)
					resolved_branch_o[2-:3] = 3'd3;
			end
			resolve_branch_o = 1'b1;
		end
	end
	localparam [31:0] riscv_INSTR_ADDR_MISALIGNED = 0;
	always @(*) begin : exception_handling
		branch_exception_o[64-:32] = riscv_INSTR_ADDR_MISALIGNED;
		branch_exception_o[0] = 1'b0;
		branch_exception_o[32-:32] = {pc_i};
		if (branch_valid_i && (target_address[0] != 1'b0))
			branch_exception_o[0] = 1'b1;
	end
endmodule
module commit_stage (
	clk_i,
	rst_ni,
	halt_i,
	flush_dcache_i,
	exception_o,
	dirty_fp_state_o,
	single_step_i,
	commit_instr_i,
	commit_ack_o,
	waddr_o,
	wdata_o,
	we_gpr_o,
	we_fpr_o,
	amo_resp_i,
	pc_o,
	csr_op_o,
	csr_wdata_o,
	csr_rdata_i,
	csr_exception_i,
	csr_write_fflags_o,
	commit_lsu_o,
	commit_lsu_ready_i,
	commit_tran_id_o,
	amo_valid_commit_o,
	no_st_pending_i,
	commit_csr_o,
	fence_i_o,
	fence_o,
	flush_commit_o,
	sfence_vma_o
);
	parameter [31:0] NR_COMMIT_PORTS = 2;
	input wire clk_i;
	input wire rst_ni;
	input wire halt_i;
	input wire flush_dcache_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	output reg [64:0] exception_o;
	output reg dirty_fp_state_o;
	input wire single_step_i;
	localparam ariane_pkg_REG_ADDR_SIZE = 6;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam riscv_VLEN = 32;
	input wire [(NR_COMMIT_PORTS * 202) - 1:0] commit_instr_i;
	output reg [NR_COMMIT_PORTS - 1:0] commit_ack_o;
	output wire [(NR_COMMIT_PORTS * 5) - 1:0] waddr_o;
	output reg [(NR_COMMIT_PORTS * 32) - 1:0] wdata_o;
	output reg [NR_COMMIT_PORTS - 1:0] we_gpr_o;
	output reg [NR_COMMIT_PORTS - 1:0] we_fpr_o;
	input wire [64:0] amo_resp_i;
	output wire [31:0] pc_o;
	output reg [7:0] csr_op_o;
	output reg [31:0] csr_wdata_o;
	input wire [31:0] csr_rdata_i;
	input wire [64:0] csr_exception_i;
	output reg csr_write_fflags_o;
	output reg commit_lsu_o;
	input wire commit_lsu_ready_i;
	output wire [2:0] commit_tran_id_o;
	output reg amo_valid_commit_o;
	input wire no_st_pending_i;
	output reg commit_csr_o;
	output reg fence_i_o;
	output reg fence_o;
	output reg flush_commit_o;
	output reg sfence_vma_o;
	genvar i;
	generate
		for (i = 0; i < NR_COMMIT_PORTS; i = i + 1) begin : gen_waddr
			assign waddr_o[i * 5+:5] = commit_instr_i[(i * 202) + 141-:5];
		end
	endgenerate
	assign pc_o = commit_instr_i[201-:32];
	localparam cva6_config_pkg_CVA6ConfigFpuEn = 0;
	localparam riscv_FPU_EN = cva6_config_pkg_CVA6ConfigFpuEn;
	localparam riscv_IS_XLEN64 = 1'b0;
	localparam [0:0] ariane_pkg_RVD = (riscv_IS_XLEN64 ? 1 : 0) & riscv_FPU_EN;
	localparam riscv_IS_XLEN32 = 1'b1;
	localparam [0:0] ariane_pkg_RVF = (riscv_IS_XLEN64 | riscv_IS_XLEN32) & riscv_FPU_EN;
	localparam cva6_config_pkg_CVA6ConfigF16En = 0;
	localparam [0:0] ariane_pkg_XF16 = cva6_config_pkg_CVA6ConfigF16En;
	localparam cva6_config_pkg_CVA6ConfigF16AltEn = 0;
	localparam [0:0] ariane_pkg_XF16ALT = cva6_config_pkg_CVA6ConfigF16AltEn;
	localparam cva6_config_pkg_CVA6ConfigF8En = 0;
	localparam [0:0] ariane_pkg_XF8 = cva6_config_pkg_CVA6ConfigF8En;
	localparam [0:0] ariane_pkg_FP_PRESENT = (((ariane_pkg_RVF | ariane_pkg_RVD) | ariane_pkg_XF16) | ariane_pkg_XF16ALT) | ariane_pkg_XF8;
	function automatic ariane_pkg_is_rd_fpr;
		input reg [7:0] op;
		if (ariane_pkg_FP_PRESENT) begin
			if (|{(8'd81 <= op) && (8'd84 >= op), (8'd89 <= op) && (8'd98 >= op), op == 8'd100, op == 8'd101, op == 8'd102, op == 8'd104, (8'd107 <= op) && (8'd111 >= op), (8'd118 <= op) && (8'd121 >= op)})
				ariane_pkg_is_rd_fpr = 1'b1;
			else
				ariane_pkg_is_rd_fpr = 1'b0;
		end
		else
			ariane_pkg_is_rd_fpr = 1'b0;
	endfunction
	always @(*) begin : dirty_fp_state
		dirty_fp_state_o = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < NR_COMMIT_PORTS; i = i + 1)
				dirty_fp_state_o = dirty_fp_state_o | (commit_ack_o[i] & (|{commit_instr_i[(i * 202) + 166-:4] == 4'd7, commit_instr_i[(i * 202) + 166-:4] == 4'd8} || ariane_pkg_is_rd_fpr(commit_instr_i[(i * 202) + 162-:8])));
		end
	end
	assign commit_tran_id_o = commit_instr_i[169-:3];
	wire instr_0_is_amo;
	function automatic ariane_pkg_is_amo;
		input reg [7:0] op;
		if ((8'd46 <= op) && (8'd67 >= op))
			ariane_pkg_is_amo = 1'b1;
		else
			ariane_pkg_is_amo = 1'b0;
	endfunction
	assign instr_0_is_amo = ariane_pkg_is_amo(commit_instr_i[162-:8]);
	localparam cva6_config_pkg_CVA6ConfigAExtEn = 1;
	localparam [0:0] ariane_pkg_RVA = cva6_config_pkg_CVA6ConfigAExtEn;
	always @(*) begin : commit
		commit_ack_o[0] = 1'b0;
		commit_ack_o[1] = 1'b0;
		amo_valid_commit_o = 1'b0;
		we_gpr_o[0] = 1'b0;
		we_gpr_o[1] = 1'b0;
		we_fpr_o = {NR_COMMIT_PORTS {1'b0}};
		commit_lsu_o = 1'b0;
		commit_csr_o = 1'b0;
		wdata_o[0+:32] = (amo_resp_i[64] ? amo_resp_i[31:0] : commit_instr_i[136-:32]);
		wdata_o[32+:32] = commit_instr_i[338-:32];
		csr_op_o = 8'd0;
		csr_wdata_o = {riscv_XLEN {1'b0}};
		fence_i_o = 1'b0;
		fence_o = 1'b0;
		sfence_vma_o = 1'b0;
		csr_write_fflags_o = 1'b0;
		flush_commit_o = 1'b0;
		if ((commit_instr_i[104] && !commit_instr_i[36]) && !halt_i) begin
			commit_ack_o[0] = 1'b1;
			if (ariane_pkg_is_rd_fpr(commit_instr_i[162-:8]))
				we_fpr_o[0] = 1'b1;
			else
				we_gpr_o[0] = 1'b1;
			if ((commit_instr_i[166-:4] == 4'd2) && !instr_0_is_amo)
				if (commit_lsu_ready_i) begin
					commit_ack_o[0] = 1'b1;
					commit_lsu_o = 1'b1;
				end
				else
					commit_ack_o[0] = 1'b0;
			if (|{commit_instr_i[166-:4] == 4'd7, commit_instr_i[166-:4] == 4'd8}) begin
				csr_wdata_o = {{27 {1'b0}}, commit_instr_i[73-:5]};
				csr_write_fflags_o = 1'b1;
				commit_ack_o[0] = 1'b1;
			end
			if (commit_instr_i[166-:4] == 4'd6) begin
				csr_op_o = commit_instr_i[162-:8];
				csr_wdata_o = commit_instr_i[136-:32];
				if (!csr_exception_i[0]) begin
					commit_csr_o = 1'b1;
					wdata_o[0+:32] = csr_rdata_i;
					commit_ack_o[0] = 1'b1;
				end
				else begin
					commit_ack_o[0] = 1'b0;
					we_gpr_o[0] = 1'b0;
				end
			end
			if (commit_instr_i[162-:8] == 8'd30) begin
				sfence_vma_o = no_st_pending_i;
				commit_ack_o[0] = no_st_pending_i;
			end
			if ((commit_instr_i[162-:8] == 8'd29) || (flush_dcache_i && (commit_instr_i[166-:4] != 4'd2))) begin
				commit_ack_o[0] = no_st_pending_i;
				fence_i_o = no_st_pending_i;
			end
			if (commit_instr_i[162-:8] == 8'd28) begin
				commit_ack_o[0] = no_st_pending_i;
				fence_o = no_st_pending_i;
			end
			if (ariane_pkg_RVA && instr_0_is_amo) begin
				commit_ack_o[0] = amo_resp_i[64];
				flush_commit_o = amo_resp_i[64];
				amo_valid_commit_o = 1'b1;
				we_gpr_o[0] = amo_resp_i[64];
			end
		end
		if (NR_COMMIT_PORTS > 1)
			if ((((((commit_ack_o[0] && commit_instr_i[306]) && !halt_i) && (commit_instr_i[166-:4] != 4'd6)) && !flush_dcache_i) && !instr_0_is_amo) && !single_step_i)
				if ((!exception_o[0] && !commit_instr_i[238]) && |{commit_instr_i[368-:4] == 4'd3, commit_instr_i[368-:4] == 4'd1, commit_instr_i[368-:4] == 4'd4, commit_instr_i[368-:4] == 4'd5, commit_instr_i[368-:4] == 4'd7, commit_instr_i[368-:4] == 4'd8}) begin
					if (ariane_pkg_is_rd_fpr(commit_instr_i[364-:8]))
						we_fpr_o[1] = 1'b1;
					else
						we_gpr_o[1] = 1'b1;
					commit_ack_o[1] = 1'b1;
					if (|{commit_instr_i[368-:4] == 4'd7, commit_instr_i[368-:4] == 4'd8}) begin
						if (csr_write_fflags_o)
							csr_wdata_o = {{27 {1'b0}}, commit_instr_i[73-:5] | commit_instr_i[275-:5]};
						else
							csr_wdata_o = {{27 {1'b0}}, commit_instr_i[275-:5]};
						csr_write_fflags_o = 1'b1;
					end
				end
	end
	always @(*) begin : exception_handling
		exception_o[0] = 1'b0;
		exception_o[64-:32] = 1'sb0;
		exception_o[32-:32] = 1'sb0;
		if (commit_instr_i[104]) begin
			if (csr_exception_i[0]) begin
				exception_o = csr_exception_i;
				exception_o[32-:32] = commit_instr_i[68-:32];
			end
			if (commit_instr_i[36])
				exception_o = commit_instr_i[100-:65];
		end
		if (halt_i)
			exception_o[0] = 1'b0;
	end
endmodule
module controller (
	clk_i,
	rst_ni,
	set_pc_commit_o,
	flush_if_o,
	flush_unissued_instr_o,
	flush_id_o,
	flush_ex_o,
	flush_bp_o,
	flush_icache_o,
	flush_dcache_o,
	flush_dcache_ack_i,
	flush_tlb_o,
	halt_csr_i,
	halt_o,
	eret_i,
	ex_valid_i,
	set_debug_pc_i,
	resolved_branch_i,
	flush_csr_i,
	fence_i_i,
	fence_i,
	sfence_vma_i,
	flush_commit_i
);
	input wire clk_i;
	input wire rst_ni;
	output reg set_pc_commit_o;
	output reg flush_if_o;
	output reg flush_unissued_instr_o;
	output reg flush_id_o;
	output reg flush_ex_o;
	output reg flush_bp_o;
	output reg flush_icache_o;
	output reg flush_dcache_o;
	input wire flush_dcache_ack_i;
	output reg flush_tlb_o;
	input wire halt_csr_i;
	output reg halt_o;
	input wire eret_i;
	input wire ex_valid_i;
	input wire set_debug_pc_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [69:0] resolved_branch_i;
	input wire flush_csr_i;
	input wire fence_i_i;
	input wire fence_i;
	input wire sfence_vma_i;
	input wire flush_commit_i;
	reg fence_active_d;
	reg fence_active_q;
	reg flush_dcache;
	always @(*) begin : flush_ctrl
		fence_active_d = fence_active_q;
		set_pc_commit_o = 1'b0;
		flush_if_o = 1'b0;
		flush_unissued_instr_o = 1'b0;
		flush_id_o = 1'b0;
		flush_ex_o = 1'b0;
		flush_dcache = 1'b0;
		flush_icache_o = 1'b0;
		flush_tlb_o = 1'b0;
		flush_bp_o = 1'b0;
		if (resolved_branch_i[4]) begin
			flush_unissued_instr_o = 1'b1;
			flush_if_o = 1'b1;
		end
		if (fence_i) begin
			set_pc_commit_o = 1'b1;
			flush_if_o = 1'b1;
			flush_unissued_instr_o = 1'b1;
			flush_id_o = 1'b1;
			flush_ex_o = 1'b1;
			flush_dcache = 1'b1;
			fence_active_d = 1'b1;
		end
		if (fence_i_i) begin
			set_pc_commit_o = 1'b1;
			flush_if_o = 1'b1;
			flush_unissued_instr_o = 1'b1;
			flush_id_o = 1'b1;
			flush_ex_o = 1'b1;
			flush_icache_o = 1'b1;
			flush_dcache = 1'b1;
			fence_active_d = 1'b1;
		end
		if (flush_dcache_ack_i && fence_active_q)
			fence_active_d = 1'b0;
		else if (fence_active_q)
			flush_dcache = 1'b1;
		if (sfence_vma_i) begin
			set_pc_commit_o = 1'b1;
			flush_if_o = 1'b1;
			flush_unissued_instr_o = 1'b1;
			flush_id_o = 1'b1;
			flush_ex_o = 1'b1;
			flush_tlb_o = 1'b1;
		end
		if (flush_csr_i || flush_commit_i) begin
			set_pc_commit_o = 1'b1;
			flush_if_o = 1'b1;
			flush_unissued_instr_o = 1'b1;
			flush_id_o = 1'b1;
			flush_ex_o = 1'b1;
		end
		if ((ex_valid_i || eret_i) || set_debug_pc_i) begin
			set_pc_commit_o = 1'b0;
			flush_if_o = 1'b1;
			flush_unissued_instr_o = 1'b1;
			flush_id_o = 1'b1;
			flush_ex_o = 1'b1;
			flush_bp_o = 1'b1;
		end
	end
	always @(*) halt_o = halt_csr_i || fence_active_q;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			fence_active_q <= 1'b0;
			flush_dcache_o <= 1'b0;
		end
		else begin
			fence_active_q <= fence_active_d;
			flush_dcache_o <= flush_dcache;
		end
endmodule
module csr_buffer (
	clk_i,
	rst_ni,
	flush_i,
	fu_data_i,
	csr_ready_o,
	csr_valid_i,
	csr_result_o,
	csr_commit_i,
	csr_addr_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	output reg csr_ready_o;
	input wire csr_valid_i;
	output wire [31:0] csr_result_o;
	input wire csr_commit_i;
	output wire [11:0] csr_addr_o;
	reg [12:0] csr_reg_n;
	reg [12:0] csr_reg_q;
	assign csr_result_o = fu_data_i[98-:32];
	assign csr_addr_o = csr_reg_q[12-:12];
	always @(*) begin : write
		csr_reg_n = csr_reg_q;
		csr_ready_o = 1'b1;
		if ((csr_reg_q[0] || csr_valid_i) && ~csr_commit_i)
			csr_ready_o = 1'b0;
		if (csr_valid_i) begin
			csr_reg_n[12-:12] = fu_data_i[46:35];
			csr_reg_n[0] = 1'b1;
		end
		if (csr_commit_i && ~csr_valid_i)
			csr_reg_n[0] = 1'b0;
		if (flush_i)
			csr_reg_n[0] = 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			csr_reg_q <= 13'h0000;
		else
			csr_reg_q <= csr_reg_n;
endmodule
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
	localparam [2:0] dm_CauseBreakpoint = 3'h1;
	localparam [2:0] dm_CauseRequest = 3'h3;
	localparam [2:0] dm_CauseSingleStep = 3'h4;
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
				dcsr_d[8-:3] = dm_CauseBreakpoint;
			end
			if (ex_i[0] && (ex_i[64-:32] == riscv_DEBUG_REQUEST)) begin
				dcsr_d[1-:2] = priv_lvl_o;
				dpc_d = {pc_i};
				debug_mode_d = 1'b1;
				set_debug_pc_o = 1'b1;
				dcsr_d[8-:3] = dm_CauseRequest;
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
				dcsr_d[8-:3] = dm_CauseSingleStep;
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
	localparam [63:0] dm_HaltAddress = 64'h0000000000000800;
	localparam [63:0] dm_ExceptionAddress = 2056;
	always @(*) begin : priv_output
		trap_vector_base_o = {mtvec_q[31:2], 2'b00};
		if (trap_to_priv_lvl == 2'b01)
			trap_vector_base_o = {stvec_q[31:2], 2'b00};
		if (debug_mode_q)
			trap_vector_base_o = DmBaseAddress[31:0] + dm_ExceptionAddress[31:0];
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
module cva6 (
	clk_i,
	rst_ni,
	boot_addr_i,
	hart_id_i,
	irq_i,
	ipi_i,
	time_irq_i,
	debug_req_i,
	cvxif_req_o,
	cvxif_resp_i,
	axi_req_o,
	axi_resp_i
);
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [31:0] boot_addr_i;
	input wire [31:0] hart_id_i;
	input wire [1:0] irq_i;
	input wire ipi_i;
	input wire time_irq_i;
	input wire debug_req_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cvxif_pkg_X_ID_WIDTH = ariane_pkg_TRANS_ID_BITS;
	localparam ariane_pkg_NR_RGPR_PORTS = 2;
	localparam cvxif_pkg_X_NUM_RS = ariane_pkg_NR_RGPR_PORTS;
	localparam cvxif_pkg_X_RFR_WIDTH = riscv_XLEN;
	localparam cvxif_pkg_X_MEM_WIDTH = 64;
	output wire [208:0] cvxif_req_o;
	localparam cvxif_pkg_X_RFW_WIDTH = riscv_XLEN;
	input wire [196:0] cvxif_resp_i;
	localparam ariane_axi_AddrWidth = 64;
	localparam ariane_axi_IdWidth = 4;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam cva6_config_pkg_CVA6ConfigFetchUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigFetchUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_FETCH_USER_WIDTH = 1;
	localparam ariane_pkg_AXI_USER_WIDTH = ariane_pkg_FETCH_USER_WIDTH;
	localparam ariane_axi_UserWidth = ariane_pkg_AXI_USER_WIDTH;
	localparam ariane_axi_DataWidth = 64;
	localparam ariane_axi_StrbWidth = 8;
	output wire [280:0] axi_req_o;
	input wire [83:0] axi_resp_i;
	wire [1:0] priv_lvl;
	wire [64:0] ex_commit;
	wire [69:0] resolved_branch;
	wire [31:0] pc_commit;
	wire eret;
	localparam ariane_pkg_NR_COMMIT_PORTS = 2;
	wire [1:0] commit_ack;
	wire [31:0] trap_vector_base_commit_pcgen;
	wire [31:0] epc_commit_pcgen;
	wire [163:0] fetch_entry_if_id;
	wire fetch_valid_if_id;
	wire fetch_ready_id_if;
	localparam ariane_pkg_REG_ADDR_SIZE = 6;
	wire [201:0] issue_entry_id_issue;
	wire issue_entry_valid_id_issue;
	wire is_ctrl_fow_id_issue;
	wire issue_instr_issue_id;
	wire [31:0] rs1_forwarding_id_ex;
	wire [31:0] rs2_forwarding_id_ex;
	wire [110:0] fu_data_id_ex;
	wire [31:0] pc_id_ex;
	wire is_compressed_instr_id_ex;
	wire flu_ready_ex_id;
	wire [2:0] flu_trans_id_ex_id;
	wire flu_valid_ex_id;
	wire [31:0] flu_result_ex_id;
	wire [64:0] flu_exception_ex_id;
	wire alu_valid_id_ex;
	wire branch_valid_id_ex;
	wire [34:0] branch_predict_id_ex;
	wire resolve_branch_ex_id;
	wire lsu_valid_id_ex;
	wire lsu_ready_ex_id;
	wire [2:0] load_trans_id_ex_id;
	wire [31:0] load_result_ex_id;
	wire load_valid_ex_id;
	wire [64:0] load_exception_ex_id;
	wire [31:0] store_result_ex_id;
	wire [2:0] store_trans_id_ex_id;
	wire store_valid_ex_id;
	wire [64:0] store_exception_ex_id;
	wire mult_valid_id_ex;
	wire fpu_ready_ex_id;
	wire fpu_valid_id_ex;
	wire [1:0] fpu_fmt_id_ex;
	wire [2:0] fpu_rm_id_ex;
	wire [2:0] fpu_trans_id_ex_id;
	wire [31:0] fpu_result_ex_id;
	wire fpu_valid_ex_id;
	wire [64:0] fpu_exception_ex_id;
	wire csr_valid_id_ex;
	wire [2:0] x_trans_id_ex_id;
	wire [31:0] x_result_ex_id;
	wire x_valid_ex_id;
	wire [64:0] x_exception_ex_id;
	wire x_we_ex_id;
	wire x_issue_valid_id_ex;
	wire x_issue_ready_ex_id;
	wire [31:0] x_off_instr_id_ex;
	wire csr_commit_commit_ex;
	wire dirty_fp_state;
	wire lsu_commit_commit_ex;
	wire lsu_commit_ready_ex_commit;
	wire [2:0] lsu_commit_trans_id;
	wire no_st_pending_ex;
	wire no_st_pending_commit;
	wire amo_valid_commit;
	wire [403:0] commit_instr_id_commit;
	wire [9:0] waddr_commit_id;
	wire [63:0] wdata_commit_id;
	wire [1:0] we_gpr_commit_id;
	wire [1:0] we_fpr_commit_id;
	wire [4:0] fflags_csr_commit;
	wire [1:0] fs;
	wire [2:0] frm_csr_id_issue_ex;
	wire [6:0] fprec_csr_ex;
	wire enable_translation_csr_ex;
	wire en_ld_st_translation_csr_ex;
	wire [1:0] ld_st_priv_lvl_csr_ex;
	wire sum_csr_ex;
	wire mxr_csr_ex;
	localparam riscv_PPNW = 22;
	wire [21:0] satp_ppn_csr_ex;
	localparam ariane_pkg_ASID_WIDTH = 1;
	wire [0:0] asid_csr_ex;
	wire [11:0] csr_addr_ex_csr;
	wire [7:0] csr_op_commit_csr;
	wire [31:0] csr_wdata_commit_csr;
	wire [31:0] csr_rdata_csr_commit;
	wire [64:0] csr_exception_csr_commit;
	wire tvm_csr_id;
	wire tw_csr_id;
	wire tsr_csr_id;
	wire [97:0] irq_ctrl_csr_id;
	wire dcache_en_csr_nbdcache;
	wire csr_write_fflags_commit_cs;
	wire icache_en_csr;
	wire debug_mode;
	wire single_step_csr_commit;
	wire [127:0] pmpcfg;
	localparam riscv_PLEN = 34;
	wire [511:0] pmpaddr;
	wire [4:0] addr_csr_perf;
	wire [31:0] data_csr_perf;
	wire [31:0] data_perf_csr;
	wire we_csr_perf;
	wire icache_flush_ctrl_cache;
	wire itlb_miss_ex_perf;
	wire dtlb_miss_ex_perf;
	wire dcache_miss_cache_perf;
	wire icache_miss_cache_perf;
	wire set_pc_ctrl_pcgen;
	wire flush_csr_ctrl;
	wire flush_unissued_instr_ctrl_id;
	wire flush_ctrl_if;
	wire flush_ctrl_id;
	wire flush_ctrl_ex;
	wire flush_ctrl_bp;
	wire flush_tlb_ctrl_ex;
	wire fence_i_commit_controller;
	wire fence_commit_controller;
	wire sfence_vma_commit_controller;
	wire halt_ctrl;
	wire halt_csr_ctrl;
	wire dcache_flush_ctrl_cache;
	wire dcache_flush_ack_cache_ctrl;
	wire set_debug_pc;
	wire flush_commit;
	wire [99:0] icache_areq_ex_cache;
	wire [32:0] icache_areq_cache_ex;
	wire [35:0] icache_dreq_if_cache;
	localparam [31:0] ariane_pkg_FETCH_WIDTH = 32;
	wire [131:0] icache_dreq_cache_if;
	wire [134:0] amo_req;
	wire [64:0] amo_resp;
	wire sb_full;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (3 * ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10)) - 1 : (3 * (1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))) + ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 8)):(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9)] dcache_req_ports_ex_cache;
	wire [104:0] dcache_req_ports_cache_ex;
	wire dcache_commit_wbuffer_empty;
	wire dcache_commit_wbuffer_not_ni;
	frontend #(.ArianeCfg(ArianeCfg)) i_frontend(
		.flush_i(flush_ctrl_if),
		.flush_bp_i(1'b0),
		.debug_mode_i(debug_mode),
		.boot_addr_i(boot_addr_i[31:0]),
		.icache_dreq_i(icache_dreq_cache_if),
		.icache_dreq_o(icache_dreq_if_cache),
		.resolved_branch_i(resolved_branch),
		.pc_commit_i(pc_commit),
		.set_pc_commit_i(set_pc_ctrl_pcgen),
		.set_debug_pc_i(set_debug_pc),
		.epc_i(epc_commit_pcgen),
		.eret_i(eret),
		.trap_vector_base_i(trap_vector_base_commit_pcgen),
		.ex_valid_i(ex_commit[0]),
		.fetch_entry_o(fetch_entry_if_id),
		.fetch_entry_valid_o(fetch_valid_if_id),
		.fetch_entry_ready_i(fetch_ready_id_if),
		.*
	);
	id_stage id_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_ctrl_if),
		.debug_req_i(debug_req_i),
		.fetch_entry_i(fetch_entry_if_id),
		.fetch_entry_valid_i(fetch_valid_if_id),
		.fetch_entry_ready_o(fetch_ready_id_if),
		.issue_entry_o(issue_entry_id_issue),
		.issue_entry_valid_o(issue_entry_valid_id_issue),
		.is_ctrl_flow_o(is_ctrl_fow_id_issue),
		.issue_instr_ack_i(issue_instr_issue_id),
		.priv_lvl_i(priv_lvl),
		.fs_i(fs),
		.frm_i(frm_csr_id_issue_ex),
		.irq_i(irq_i),
		.irq_ctrl_i(irq_ctrl_csr_id),
		.debug_mode_i(debug_mode),
		.tvm_i(tvm_csr_id),
		.tw_i(tw_csr_id),
		.tsr_i(tsr_csr_id)
	);
	localparam ariane_pkg_NR_WB_PORTS = 5;
	issue_stage #(
		.NR_ENTRIES(ariane_pkg_NR_SB_ENTRIES),
		.NR_WB_PORTS(ariane_pkg_NR_WB_PORTS),
		.NR_COMMIT_PORTS(ariane_pkg_NR_COMMIT_PORTS)
	) issue_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.sb_full_o(sb_full),
		.flush_unissued_instr_i(flush_unissued_instr_ctrl_id),
		.flush_i(flush_ctrl_id),
		.decoded_instr_i(issue_entry_id_issue),
		.decoded_instr_valid_i(issue_entry_valid_id_issue),
		.is_ctrl_flow_i(is_ctrl_fow_id_issue),
		.decoded_instr_ack_o(issue_instr_issue_id),
		.rs1_forwarding_o(rs1_forwarding_id_ex),
		.rs2_forwarding_o(rs2_forwarding_id_ex),
		.fu_data_o(fu_data_id_ex),
		.pc_o(pc_id_ex),
		.is_compressed_instr_o(is_compressed_instr_id_ex),
		.flu_ready_i(flu_ready_ex_id),
		.alu_valid_o(alu_valid_id_ex),
		.branch_valid_o(branch_valid_id_ex),
		.branch_predict_o(branch_predict_id_ex),
		.resolve_branch_i(resolve_branch_ex_id),
		.lsu_ready_i(lsu_ready_ex_id),
		.lsu_valid_o(lsu_valid_id_ex),
		.mult_valid_o(mult_valid_id_ex),
		.fpu_ready_i(fpu_ready_ex_id),
		.fpu_valid_o(fpu_valid_id_ex),
		.fpu_fmt_o(fpu_fmt_id_ex),
		.fpu_rm_o(fpu_rm_id_ex),
		.csr_valid_o(csr_valid_id_ex),
		.x_issue_valid_o(x_issue_valid_id_ex),
		.x_issue_ready_i(x_issue_ready_ex_id),
		.x_off_instr_o(x_off_instr_id_ex),
		.resolved_branch_i(resolved_branch),
		.trans_id_i({flu_trans_id_ex_id, load_trans_id_ex_id, store_trans_id_ex_id, fpu_trans_id_ex_id, x_trans_id_ex_id}),
		.wbdata_i({flu_result_ex_id, load_result_ex_id, store_result_ex_id, fpu_result_ex_id, x_result_ex_id}),
		.ex_ex_i({flu_exception_ex_id, load_exception_ex_id, store_exception_ex_id, fpu_exception_ex_id, x_exception_ex_id}),
		.wt_valid_i({flu_valid_ex_id, load_valid_ex_id, store_valid_ex_id, fpu_valid_ex_id, x_valid_ex_id}),
		.x_we_i(x_we_ex_id),
		.waddr_i(waddr_commit_id),
		.wdata_i(wdata_commit_id),
		.we_gpr_i(we_gpr_commit_id),
		.we_fpr_i(we_fpr_commit_id),
		.commit_instr_o(commit_instr_id_commit),
		.commit_ack_i(commit_ack),
		.*
	);
	ex_stage #(
		.ASID_WIDTH(ariane_pkg_ASID_WIDTH),
		.ArianeCfg(ArianeCfg)
	) ex_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.debug_mode_i(debug_mode),
		.flush_i(flush_ctrl_ex),
		.rs1_forwarding_i(rs1_forwarding_id_ex),
		.rs2_forwarding_i(rs2_forwarding_id_ex),
		.fu_data_i(fu_data_id_ex),
		.pc_i(pc_id_ex),
		.is_compressed_instr_i(is_compressed_instr_id_ex),
		.flu_result_o(flu_result_ex_id),
		.flu_trans_id_o(flu_trans_id_ex_id),
		.flu_valid_o(flu_valid_ex_id),
		.flu_exception_o(flu_exception_ex_id),
		.flu_ready_o(flu_ready_ex_id),
		.alu_valid_i(alu_valid_id_ex),
		.branch_valid_i(branch_valid_id_ex),
		.branch_predict_i(branch_predict_id_ex),
		.resolved_branch_o(resolved_branch),
		.resolve_branch_o(resolve_branch_ex_id),
		.csr_valid_i(csr_valid_id_ex),
		.csr_addr_o(csr_addr_ex_csr),
		.csr_commit_i(csr_commit_commit_ex),
		.mult_valid_i(mult_valid_id_ex),
		.lsu_ready_o(lsu_ready_ex_id),
		.lsu_valid_i(lsu_valid_id_ex),
		.load_result_o(load_result_ex_id),
		.load_trans_id_o(load_trans_id_ex_id),
		.load_valid_o(load_valid_ex_id),
		.load_exception_o(load_exception_ex_id),
		.store_result_o(store_result_ex_id),
		.store_trans_id_o(store_trans_id_ex_id),
		.store_valid_o(store_valid_ex_id),
		.store_exception_o(store_exception_ex_id),
		.lsu_commit_i(lsu_commit_commit_ex),
		.lsu_commit_ready_o(lsu_commit_ready_ex_commit),
		.commit_tran_id_i(lsu_commit_trans_id),
		.no_st_pending_o(no_st_pending_ex),
		.fpu_ready_o(fpu_ready_ex_id),
		.fpu_valid_i(fpu_valid_id_ex),
		.fpu_fmt_i(fpu_fmt_id_ex),
		.fpu_rm_i(fpu_rm_id_ex),
		.fpu_frm_i(frm_csr_id_issue_ex),
		.fpu_prec_i(fprec_csr_ex),
		.fpu_trans_id_o(fpu_trans_id_ex_id),
		.fpu_result_o(fpu_result_ex_id),
		.fpu_valid_o(fpu_valid_ex_id),
		.fpu_exception_o(fpu_exception_ex_id),
		.amo_valid_commit_i(amo_valid_commit),
		.amo_req_o(amo_req),
		.amo_resp_i(amo_resp),
		.x_valid_i(x_issue_valid_id_ex),
		.x_ready_o(x_issue_ready_ex_id),
		.x_off_instr_i(x_off_instr_id_ex),
		.x_trans_id_o(x_trans_id_ex_id),
		.x_exception_o(x_exception_ex_id),
		.x_result_o(x_result_ex_id),
		.x_valid_o(x_valid_ex_id),
		.x_we_o(x_we_ex_id),
		.cvxif_req_o(cvxif_req_o),
		.cvxif_resp_i(cvxif_resp_i),
		.itlb_miss_o(itlb_miss_ex_perf),
		.dtlb_miss_o(dtlb_miss_ex_perf),
		.enable_translation_i(enable_translation_csr_ex),
		.en_ld_st_translation_i(en_ld_st_translation_csr_ex),
		.flush_tlb_i(flush_tlb_ctrl_ex),
		.priv_lvl_i(priv_lvl),
		.ld_st_priv_lvl_i(ld_st_priv_lvl_csr_ex),
		.sum_i(sum_csr_ex),
		.mxr_i(mxr_csr_ex),
		.satp_ppn_i(satp_ppn_csr_ex),
		.asid_i(asid_csr_ex),
		.icache_areq_i(icache_areq_cache_ex),
		.icache_areq_o(icache_areq_ex_cache),
		.dcache_req_ports_i(dcache_req_ports_cache_ex),
		.dcache_req_ports_o(dcache_req_ports_ex_cache),
		.dcache_wbuffer_empty_i(dcache_commit_wbuffer_empty),
		.dcache_wbuffer_not_ni_i(dcache_commit_wbuffer_not_ni),
		.pmpcfg_i(pmpcfg),
		.pmpaddr_i(pmpaddr)
	);
	assign no_st_pending_commit = no_st_pending_ex & dcache_commit_wbuffer_empty;
	commit_stage #(.NR_COMMIT_PORTS(ariane_pkg_NR_COMMIT_PORTS)) commit_stage_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.halt_i(halt_ctrl),
		.flush_dcache_i(dcache_flush_ctrl_cache),
		.exception_o(ex_commit),
		.dirty_fp_state_o(dirty_fp_state),
		.single_step_i(single_step_csr_commit),
		.commit_instr_i(commit_instr_id_commit),
		.commit_ack_o(commit_ack),
		.no_st_pending_i(no_st_pending_commit),
		.waddr_o(waddr_commit_id),
		.wdata_o(wdata_commit_id),
		.we_gpr_o(we_gpr_commit_id),
		.we_fpr_o(we_fpr_commit_id),
		.commit_lsu_o(lsu_commit_commit_ex),
		.commit_lsu_ready_i(lsu_commit_ready_ex_commit),
		.commit_tran_id_o(lsu_commit_trans_id),
		.amo_valid_commit_o(amo_valid_commit),
		.amo_resp_i(amo_resp),
		.commit_csr_o(csr_commit_commit_ex),
		.pc_o(pc_commit),
		.csr_op_o(csr_op_commit_csr),
		.csr_wdata_o(csr_wdata_commit_csr),
		.csr_rdata_i(csr_rdata_csr_commit),
		.csr_write_fflags_o(csr_write_fflags_commit_cs),
		.csr_exception_i(csr_exception_csr_commit),
		.fence_i_o(fence_i_commit_controller),
		.fence_o(fence_commit_controller),
		.sfence_vma_o(sfence_vma_commit_controller),
		.flush_commit_o(flush_commit)
	);
	csr_regfile #(
		.AsidWidth(ariane_pkg_ASID_WIDTH),
		.DmBaseAddress(ArianeCfg[95-:64]),
		.NrCommitPorts(ariane_pkg_NR_COMMIT_PORTS),
		.NrPMPEntries(ArianeCfg[31-:32])
	) csr_regfile_i(
		.flush_o(flush_csr_ctrl),
		.halt_csr_o(halt_csr_ctrl),
		.commit_instr_i(commit_instr_id_commit),
		.commit_ack_i(commit_ack),
		.boot_addr_i(boot_addr_i[31:0]),
		.hart_id_i(hart_id_i[31:0]),
		.ex_i(ex_commit),
		.csr_op_i(csr_op_commit_csr),
		.csr_write_fflags_i(csr_write_fflags_commit_cs),
		.dirty_fp_state_i(dirty_fp_state),
		.csr_addr_i(csr_addr_ex_csr),
		.csr_wdata_i(csr_wdata_commit_csr),
		.csr_rdata_o(csr_rdata_csr_commit),
		.pc_i(pc_commit),
		.csr_exception_o(csr_exception_csr_commit),
		.epc_o(epc_commit_pcgen),
		.eret_o(eret),
		.set_debug_pc_o(set_debug_pc),
		.trap_vector_base_o(trap_vector_base_commit_pcgen),
		.priv_lvl_o(priv_lvl),
		.fs_o(fs),
		.fflags_o(fflags_csr_commit),
		.frm_o(frm_csr_id_issue_ex),
		.fprec_o(fprec_csr_ex),
		.irq_ctrl_o(irq_ctrl_csr_id),
		.ld_st_priv_lvl_o(ld_st_priv_lvl_csr_ex),
		.en_translation_o(enable_translation_csr_ex),
		.en_ld_st_translation_o(en_ld_st_translation_csr_ex),
		.sum_o(sum_csr_ex),
		.mxr_o(mxr_csr_ex),
		.satp_ppn_o(satp_ppn_csr_ex),
		.asid_o(asid_csr_ex),
		.tvm_o(tvm_csr_id),
		.tw_o(tw_csr_id),
		.tsr_o(tsr_csr_id),
		.debug_mode_o(debug_mode),
		.single_step_o(single_step_csr_commit),
		.dcache_en_o(dcache_en_csr_nbdcache),
		.icache_en_o(icache_en_csr),
		.perf_addr_o(addr_csr_perf),
		.perf_data_o(data_csr_perf),
		.perf_data_i(data_perf_csr),
		.perf_we_o(we_csr_perf),
		.pmpcfg_o(pmpcfg),
		.pmpaddr_o(pmpaddr),
		.debug_req_i(debug_req_i),
		.ipi_i(ipi_i),
		.irq_i(irq_i),
		.time_irq_i(time_irq_i),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	perf_counters i_perf_counters(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.debug_mode_i(debug_mode),
		.addr_i(addr_csr_perf),
		.we_i(we_csr_perf),
		.data_i(data_csr_perf),
		.data_o(data_perf_csr),
		.commit_instr_i(commit_instr_id_commit),
		.commit_ack_i(commit_ack),
		.l1_icache_miss_i(icache_miss_cache_perf),
		.l1_dcache_miss_i(dcache_miss_cache_perf),
		.itlb_miss_i(itlb_miss_ex_perf),
		.dtlb_miss_i(dtlb_miss_ex_perf),
		.sb_full_i(sb_full),
		.if_empty_i(~fetch_valid_if_id),
		.ex_i(ex_commit),
		.eret_i(eret),
		.resolved_branch_i(resolved_branch)
	);
	controller controller_i(
		.set_pc_commit_o(set_pc_ctrl_pcgen),
		.flush_unissued_instr_o(flush_unissued_instr_ctrl_id),
		.flush_if_o(flush_ctrl_if),
		.flush_id_o(flush_ctrl_id),
		.flush_ex_o(flush_ctrl_ex),
		.flush_bp_o(flush_ctrl_bp),
		.flush_tlb_o(flush_tlb_ctrl_ex),
		.flush_dcache_o(dcache_flush_ctrl_cache),
		.flush_dcache_ack_i(dcache_flush_ack_cache_ctrl),
		.halt_csr_i(halt_csr_ctrl),
		.halt_o(halt_ctrl),
		.eret_i(eret),
		.ex_valid_i(ex_commit[0]),
		.set_debug_pc_i(set_debug_pc),
		.flush_csr_i(flush_csr_ctrl),
		.resolved_branch_i(resolved_branch),
		.fence_i_i(fence_i_commit_controller),
		.fence_i(fence_commit_controller),
		.sfence_vma_i(sfence_vma_commit_controller),
		.flush_commit_i(flush_commit),
		.flush_icache_o(icache_flush_ctrl_cache),
		.clk_i(clk_i),
		.rst_ni(rst_ni)
	);
	std_cache_subsystem #(.ArianeCfg(ArianeCfg)) i_cache_subsystem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.priv_lvl_i(priv_lvl),
		.icache_en_i(icache_en_csr),
		.icache_flush_i(icache_flush_ctrl_cache),
		.icache_miss_o(icache_miss_cache_perf),
		.icache_areq_i(icache_areq_ex_cache),
		.icache_areq_o(icache_areq_cache_ex),
		.icache_dreq_i(icache_dreq_if_cache),
		.icache_dreq_o(icache_dreq_cache_if),
		.dcache_enable_i(dcache_en_csr_nbdcache),
		.dcache_flush_i(dcache_flush_ctrl_cache),
		.dcache_flush_ack_o(dcache_flush_ack_cache_ctrl),
		.amo_req_i(amo_req),
		.amo_resp_o(amo_resp),
		.dcache_miss_o(dcache_miss_cache_perf),
		.wbuffer_empty_o(dcache_commit_wbuffer_empty),
		.dcache_req_ports_i(dcache_req_ports_ex_cache),
		.dcache_req_ports_o(dcache_req_ports_cache_ex),
		.axi_req_o(axi_req_o),
		.axi_resp_i(axi_resp_i)
	);
	assign dcache_commit_wbuffer_not_ni = 1'b1;
	task automatic ariane_pkg_check_cfg;
		input reg [6433:0] Cfg;
		;
	endtask
	initial ariane_pkg_check_cfg(ArianeCfg);
	instr_tracer_if tracer_if(clk_i);
	assign tracer_if.rstn = rst_ni;
	assign tracer_if.flush_unissued = flush_unissued_instr_ctrl_id;
	assign tracer_if.flush = flush_ctrl_ex;
	assign tracer_if.instruction = id_stage_i.fetch_entry_i.instruction;
	assign tracer_if.fetch_valid = id_stage_i.fetch_entry_valid_i;
	assign tracer_if.fetch_ack = id_stage_i.fetch_entry_ready_o;
	assign tracer_if.issue_ack = issue_stage_i.i_scoreboard.issue_ack_i;
	assign tracer_if.issue_sbe = issue_stage_i.i_scoreboard.issue_instr_o;
	assign tracer_if.waddr = waddr_commit_id;
	assign tracer_if.wdata = wdata_commit_id;
	assign tracer_if.we_gpr = we_gpr_commit_id;
	assign tracer_if.we_fpr = we_fpr_commit_id;
	assign tracer_if.commit_instr = commit_instr_id_commit;
	assign tracer_if.commit_ack = commit_ack;
	assign tracer_if.resolve_branch = resolved_branch;
	assign tracer_if.st_valid = ex_stage_i.lsu_i.i_store_unit.store_buffer_i.valid_i;
	assign tracer_if.st_paddr = ex_stage_i.lsu_i.i_store_unit.store_buffer_i.paddr_i;
	assign tracer_if.ld_valid = ex_stage_i.lsu_i.i_load_unit.req_port_o.tag_valid;
	assign tracer_if.ld_kill = ex_stage_i.lsu_i.i_load_unit.req_port_o.kill_req;
	assign tracer_if.ld_paddr = ex_stage_i.lsu_i.i_load_unit.paddr_i;
	assign tracer_if.exception = commit_stage_i.exception_o;
	assign tracer_if.priv_lvl = priv_lvl;
	assign tracer_if.debug_mode = debug_mode;
	instr_tracer instr_tracer_i(
		.tracer_if(tracer_if),
		.hart_id_i(hart_id_i)
	);
endmodule
module cvxif_fu (
	clk_i,
	rst_ni,
	fu_data_i,
	x_valid_i,
	x_ready_o,
	x_off_instr_i,
	x_trans_id_o,
	x_exception_o,
	x_result_o,
	x_valid_o,
	x_we_o,
	cvxif_req_o,
	cvxif_resp_i
);
	input wire clk_i;
	input wire rst_ni;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	input wire x_valid_i;
	output reg x_ready_o;
	input wire [31:0] x_off_instr_i;
	output reg [2:0] x_trans_id_o;
	output reg [64:0] x_exception_o;
	output reg [31:0] x_result_o;
	output reg x_valid_o;
	output reg x_we_o;
	localparam cvxif_pkg_X_ID_WIDTH = ariane_pkg_TRANS_ID_BITS;
	localparam ariane_pkg_NR_RGPR_PORTS = 2;
	localparam cvxif_pkg_X_NUM_RS = ariane_pkg_NR_RGPR_PORTS;
	localparam cvxif_pkg_X_RFR_WIDTH = riscv_XLEN;
	localparam cvxif_pkg_X_MEM_WIDTH = 64;
	output reg [208:0] cvxif_req_o;
	localparam cvxif_pkg_X_RFW_WIDTH = riscv_XLEN;
	input wire [196:0] cvxif_resp_i;
	reg illegal_n;
	reg illegal_q;
	reg [2:0] illegal_id_n;
	reg [2:0] illegal_id_q;
	reg [31:0] illegal_instr_n;
	reg [31:0] illegal_instr_q;
	always @(*) begin
		cvxif_req_o = 1'sb0;
		cvxif_req_o[0] = 1'b1;
		x_ready_o = cvxif_resp_i[162];
		if (x_valid_i) begin
			cvxif_req_o[186] = x_valid_i;
			cvxif_req_o[185-:32] = x_off_instr_i;
			cvxif_req_o[151-:3] = fu_data_i[2-:ariane_pkg_TRANS_ID_BITS];
			cvxif_req_o[85+:cvxif_pkg_X_RFR_WIDTH] = fu_data_i[98-:32];
			cvxif_req_o[117+:cvxif_pkg_X_RFR_WIDTH] = fu_data_i[66-:32];
			cvxif_req_o[84-:cvxif_pkg_X_NUM_RS] = 2'b11;
			cvxif_req_o[82] = x_valid_i;
			cvxif_req_o[81-:3] = fu_data_i[2-:ariane_pkg_TRANS_ID_BITS];
			cvxif_req_o[78] = 1'b0;
		end
	end
	localparam [31:0] riscv_ILLEGAL_INSTR = 2;
	always @(*) begin
		illegal_n = illegal_q;
		illegal_id_n = illegal_id_q;
		illegal_instr_n = illegal_instr_q;
		if (((~cvxif_resp_i[161] && cvxif_req_o[186]) && cvxif_resp_i[162]) && ~illegal_n) begin
			illegal_n = 1'b1;
			illegal_id_n = cvxif_req_o[151-:3];
			illegal_instr_n = cvxif_req_o[185-:32];
		end
		x_valid_o = cvxif_resp_i[48];
		x_trans_id_o = (x_valid_o ? cvxif_resp_i[47-:3] : {3 {1'sb0}});
		x_result_o = (x_valid_o ? cvxif_resp_i[44-:32] : {32 {1'sb0}});
		x_exception_o[64-:32] = (x_valid_o ? cvxif_resp_i[5-:6] : {32 {1'sb0}});
		x_exception_o[0] = (x_valid_o ? cvxif_resp_i[6] : 1'b0);
		x_exception_o[32-:32] = 1'sb0;
		x_we_o = (x_valid_o ? cvxif_resp_i[7] : 1'b0);
		if (illegal_n)
			if (~x_valid_o) begin
				x_trans_id_o = illegal_id_n;
				x_result_o = 1'sb0;
				x_valid_o = 1'b1;
				x_exception_o[64-:32] = riscv_ILLEGAL_INSTR;
				x_exception_o[0] = 1'b1;
				x_exception_o[32-:32] = illegal_instr_n;
				x_we_o = 1'sb0;
				illegal_n = 1'sb0;
			end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			illegal_q <= 1'b0;
			illegal_id_q <= 1'sb0;
			illegal_instr_q <= 1'sb0;
		end
		else begin
			illegal_q <= illegal_n;
			illegal_id_q <= illegal_id_n;
			illegal_instr_q <= illegal_instr_n;
		end
endmodule
module dromajo_ram (
	Clk_CI,
	Rst_RBI,
	CSel_SI,
	WrEn_SI,
	BEn_SI,
	WrData_DI,
	Addr_DI,
	RdData_DO
);
	parameter ADDR_WIDTH = 10;
	parameter DATA_DEPTH = 1024;
	parameter OUT_REGS = 0;
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire CSel_SI;
	input wire WrEn_SI;
	input wire [7:0] BEn_SI;
	input wire [63:0] WrData_DI;
	input wire [ADDR_WIDTH - 1:0] Addr_DI;
	output wire [63:0] RdData_DO;
	localparam DATA_BYTES = 8;
	reg [63:0] RdData_DN;
	reg [63:0] RdData_DP;
	reg [63:0] Mem_DP [DATA_DEPTH - 1:0];
	initial begin : sv2v_autoblock_1
		integer hex_file;
		integer num_bytes;
		reg signed [63:0] address;
		reg signed [63:0] value;
		string f_name;
		begin : sv2v_autoblock_2
			reg signed [31:0] k;
			for (k = 0; k < DATA_DEPTH; k = k + 1)
				Mem_DP[k] = 0;
		end
		if ($value$plusargs("checkpoint=%s", f_name)) begin
			hex_file = $fopen({f_name, ".mainram.hex"}, "r");
			while (!$feof(hex_file)) begin
				num_bytes = $fscanf(hex_file, "%d %h\n", address, value);
				Mem_DP[address] = value;
			end
			$display("Done syncing RAM with dromajo...\n");
		end
		else
			$display("Failed syncing RAM: provide path to a checkpoint.\n");
	end
	always @(posedge Clk_CI)
		if (CSel_SI) begin
			if (WrEn_SI) begin
				if (BEn_SI[0])
					Mem_DP[Addr_DI][7:0] <= WrData_DI[7:0];
				if (BEn_SI[1])
					Mem_DP[Addr_DI][15:8] <= WrData_DI[15:8];
				if (BEn_SI[2])
					Mem_DP[Addr_DI][23:16] <= WrData_DI[23:16];
				if (BEn_SI[3])
					Mem_DP[Addr_DI][31:24] <= WrData_DI[31:24];
				if (BEn_SI[4])
					Mem_DP[Addr_DI][39:32] <= WrData_DI[39:32];
				if (BEn_SI[5])
					Mem_DP[Addr_DI][47:40] <= WrData_DI[47:40];
				if (BEn_SI[6])
					Mem_DP[Addr_DI][55:48] <= WrData_DI[55:48];
				if (BEn_SI[7])
					Mem_DP[Addr_DI][63:56] <= WrData_DI[63:56];
			end
			RdData_DN <= Mem_DP[Addr_DI];
		end
	generate
		if (OUT_REGS > 0) begin : g_outreg
			always @(posedge Clk_CI or negedge Rst_RBI)
				if (Rst_RBI == 1'b0)
					RdData_DP <= 0;
				else
					RdData_DP <= RdData_DN;
		end
		if (OUT_REGS == 0) begin : g_oureg_byp
			wire [64:1] sv2v_tmp_7FD8C;
			assign sv2v_tmp_7FD8C = RdData_DN;
			always @(*) RdData_DP = sv2v_tmp_7FD8C;
		end
	endgenerate
	assign RdData_DO = RdData_DP;
endmodule
module ex_stage (
	clk_i,
	rst_ni,
	flush_i,
	debug_mode_i,
	rs1_forwarding_i,
	rs2_forwarding_i,
	fu_data_i,
	pc_i,
	is_compressed_instr_i,
	flu_result_o,
	flu_trans_id_o,
	flu_exception_o,
	flu_ready_o,
	flu_valid_o,
	alu_valid_i,
	branch_valid_i,
	branch_predict_i,
	resolved_branch_o,
	resolve_branch_o,
	csr_valid_i,
	csr_addr_o,
	csr_commit_i,
	mult_valid_i,
	lsu_ready_o,
	lsu_valid_i,
	load_valid_o,
	load_result_o,
	load_trans_id_o,
	load_exception_o,
	store_valid_o,
	store_result_o,
	store_trans_id_o,
	store_exception_o,
	lsu_commit_i,
	lsu_commit_ready_o,
	commit_tran_id_i,
	no_st_pending_o,
	amo_valid_commit_i,
	fpu_ready_o,
	fpu_valid_i,
	fpu_fmt_i,
	fpu_rm_i,
	fpu_frm_i,
	fpu_prec_i,
	fpu_trans_id_o,
	fpu_result_o,
	fpu_valid_o,
	fpu_exception_o,
	x_valid_i,
	x_ready_o,
	x_off_instr_i,
	x_trans_id_o,
	x_exception_o,
	x_result_o,
	x_valid_o,
	x_we_o,
	cvxif_req_o,
	cvxif_resp_i,
	enable_translation_i,
	en_ld_st_translation_i,
	flush_tlb_i,
	priv_lvl_i,
	ld_st_priv_lvl_i,
	sum_i,
	mxr_i,
	satp_ppn_i,
	asid_i,
	icache_areq_i,
	icache_areq_o,
	dcache_req_ports_i,
	dcache_req_ports_o,
	dcache_wbuffer_empty_i,
	dcache_wbuffer_not_ni_i,
	amo_req_o,
	amo_resp_i,
	itlb_miss_o,
	dtlb_miss_o,
	pmpcfg_i,
	pmpaddr_i
);
	parameter [31:0] ASID_WIDTH = 1;
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire debug_mode_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [31:0] rs1_forwarding_i;
	input wire [31:0] rs2_forwarding_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	input wire [110:0] fu_data_i;
	input wire [31:0] pc_i;
	input wire is_compressed_instr_i;
	output reg [31:0] flu_result_o;
	output reg [2:0] flu_trans_id_o;
	output wire [64:0] flu_exception_o;
	output reg flu_ready_o;
	output wire flu_valid_o;
	input wire alu_valid_i;
	input wire branch_valid_i;
	input wire [34:0] branch_predict_i;
	output wire [69:0] resolved_branch_o;
	output wire resolve_branch_o;
	input wire csr_valid_i;
	output wire [11:0] csr_addr_o;
	input wire csr_commit_i;
	input wire mult_valid_i;
	output wire lsu_ready_o;
	input wire lsu_valid_i;
	output wire load_valid_o;
	output wire [31:0] load_result_o;
	output wire [2:0] load_trans_id_o;
	output wire [64:0] load_exception_o;
	output wire store_valid_o;
	output wire [31:0] store_result_o;
	output wire [2:0] store_trans_id_o;
	output wire [64:0] store_exception_o;
	input wire lsu_commit_i;
	output wire lsu_commit_ready_o;
	input wire [2:0] commit_tran_id_i;
	output wire no_st_pending_o;
	input wire amo_valid_commit_i;
	output wire fpu_ready_o;
	input wire fpu_valid_i;
	input wire [1:0] fpu_fmt_i;
	input wire [2:0] fpu_rm_i;
	input wire [2:0] fpu_frm_i;
	input wire [6:0] fpu_prec_i;
	output wire [2:0] fpu_trans_id_o;
	output wire [31:0] fpu_result_o;
	output wire fpu_valid_o;
	output wire [64:0] fpu_exception_o;
	input wire x_valid_i;
	output wire x_ready_o;
	input wire [31:0] x_off_instr_i;
	output wire [2:0] x_trans_id_o;
	output wire [64:0] x_exception_o;
	output wire [31:0] x_result_o;
	output wire x_valid_o;
	output wire x_we_o;
	localparam cvxif_pkg_X_ID_WIDTH = ariane_pkg_TRANS_ID_BITS;
	localparam ariane_pkg_NR_RGPR_PORTS = 2;
	localparam cvxif_pkg_X_NUM_RS = ariane_pkg_NR_RGPR_PORTS;
	localparam cvxif_pkg_X_RFR_WIDTH = riscv_XLEN;
	localparam cvxif_pkg_X_MEM_WIDTH = 64;
	output wire [208:0] cvxif_req_o;
	localparam cvxif_pkg_X_RFW_WIDTH = riscv_XLEN;
	input wire [196:0] cvxif_resp_i;
	input wire enable_translation_i;
	input wire en_ld_st_translation_i;
	input wire flush_tlb_i;
	input wire [1:0] priv_lvl_i;
	input wire [1:0] ld_st_priv_lvl_i;
	input wire sum_i;
	input wire mxr_i;
	localparam riscv_PPNW = 22;
	input wire [21:0] satp_ppn_i;
	input wire [ASID_WIDTH - 1:0] asid_i;
	input wire [32:0] icache_areq_i;
	localparam riscv_PLEN = 34;
	output wire [99:0] icache_areq_o;
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
	output wire itlb_miss_o;
	output wire dtlb_miss_o;
	input wire [127:0] pmpcfg_i;
	input wire [511:0] pmpaddr_i;
	reg current_instruction_is_sfence_vma;
	reg [ASID_WIDTH - 1:0] asid_to_be_flushed;
	reg [31:0] vaddr_to_be_flushed;
	wire alu_branch_res;
	wire [31:0] alu_result;
	wire [31:0] csr_result;
	wire [31:0] mult_result;
	wire [31:0] branch_result;
	wire csr_ready;
	wire mult_ready;
	wire [2:0] mult_trans_id;
	wire mult_valid;
	wire [110:0] alu_data;
	assign alu_data = (alu_valid_i | branch_valid_i ? fu_data_i : {111 {1'sb0}});
	alu alu_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.fu_data_i(alu_data),
		.result_o(alu_result),
		.alu_branch_res_o(alu_branch_res)
	);
	branch_unit branch_unit_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.debug_mode_i(debug_mode_i),
		.fu_data_i(fu_data_i),
		.pc_i(pc_i),
		.is_compressed_instr_i(is_compressed_instr_i),
		.fu_valid_i((((alu_valid_i || lsu_valid_i) || csr_valid_i) || mult_valid_i) || fpu_valid_i),
		.branch_valid_i(branch_valid_i),
		.branch_comp_res_i(alu_branch_res),
		.branch_result_o(branch_result),
		.branch_predict_i(branch_predict_i),
		.resolved_branch_o(resolved_branch_o),
		.resolve_branch_o(resolve_branch_o),
		.branch_exception_o(flu_exception_o)
	);
	csr_buffer csr_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.fu_data_i(fu_data_i),
		.csr_valid_i(csr_valid_i),
		.csr_ready_o(csr_ready),
		.csr_result_o(csr_result),
		.csr_commit_i(csr_commit_i),
		.csr_addr_o(csr_addr_o)
	);
	assign flu_valid_o = ((alu_valid_i | branch_valid_i) | csr_valid_i) | mult_valid;
	always @(*) begin
		flu_result_o = {branch_result};
		flu_trans_id_o = fu_data_i[2-:ariane_pkg_TRANS_ID_BITS];
		if (alu_valid_i)
			flu_result_o = alu_result;
		else if (csr_valid_i)
			flu_result_o = csr_result;
		else if (mult_valid) begin
			flu_result_o = mult_result;
			flu_trans_id_o = mult_trans_id;
		end
	end
	always @(*) flu_ready_o = csr_ready & mult_ready;
	wire [110:0] mult_data;
	assign mult_data = (mult_valid_i ? fu_data_i : {111 {1'sb0}});
	mult i_mult(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.mult_valid_i(mult_valid_i),
		.fu_data_i(mult_data),
		.result_o(mult_result),
		.mult_valid_o(mult_valid),
		.mult_ready_o(mult_ready),
		.mult_trans_id_o(mult_trans_id)
	);
	localparam cva6_config_pkg_CVA6ConfigFpuEn = 0;
	localparam riscv_FPU_EN = cva6_config_pkg_CVA6ConfigFpuEn;
	localparam riscv_IS_XLEN64 = 1'b0;
	localparam [0:0] ariane_pkg_RVD = (riscv_IS_XLEN64 ? 1 : 0) & riscv_FPU_EN;
	localparam riscv_IS_XLEN32 = 1'b1;
	localparam [0:0] ariane_pkg_RVF = (riscv_IS_XLEN64 | riscv_IS_XLEN32) & riscv_FPU_EN;
	localparam cva6_config_pkg_CVA6ConfigF16En = 0;
	localparam [0:0] ariane_pkg_XF16 = cva6_config_pkg_CVA6ConfigF16En;
	localparam cva6_config_pkg_CVA6ConfigF16AltEn = 0;
	localparam [0:0] ariane_pkg_XF16ALT = cva6_config_pkg_CVA6ConfigF16AltEn;
	localparam cva6_config_pkg_CVA6ConfigF8En = 0;
	localparam [0:0] ariane_pkg_XF8 = cva6_config_pkg_CVA6ConfigF8En;
	localparam [0:0] ariane_pkg_FP_PRESENT = (((ariane_pkg_RVF | ariane_pkg_RVD) | ariane_pkg_XF16) | ariane_pkg_XF16ALT) | ariane_pkg_XF8;
	generate
		if (ariane_pkg_FP_PRESENT) begin : fpu_gen
			wire [110:0] fpu_data;
			assign fpu_data = (fpu_valid_i ? fu_data_i : {111 {1'sb0}});
			fpu_wrap fpu_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(flush_i),
				.fpu_valid_i(fpu_valid_i),
				.fpu_ready_o(fpu_ready_o),
				.fu_data_i(fpu_data),
				.fpu_fmt_i(fpu_fmt_i),
				.fpu_rm_i(fpu_rm_i),
				.fpu_frm_i(fpu_frm_i),
				.fpu_prec_i(fpu_prec_i),
				.fpu_trans_id_o(fpu_trans_id_o),
				.result_o(fpu_result_o),
				.fpu_valid_o(fpu_valid_o),
				.fpu_exception_o(fpu_exception_o)
			);
		end
		else begin : no_fpu_gen
			assign fpu_ready_o = 1'sb0;
			assign fpu_trans_id_o = 1'sb0;
			assign fpu_result_o = 1'sb0;
			assign fpu_valid_o = 1'sb0;
			assign fpu_exception_o = 1'sb0;
		end
	endgenerate
	wire [110:0] lsu_data;
	assign lsu_data = (lsu_valid_i ? fu_data_i : {111 {1'sb0}});
	load_store_unit #(
		.ASID_WIDTH(ASID_WIDTH),
		.ArianeCfg(ArianeCfg)
	) lsu_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.no_st_pending_o(no_st_pending_o),
		.fu_data_i(lsu_data),
		.lsu_ready_o(lsu_ready_o),
		.lsu_valid_i(lsu_valid_i),
		.load_trans_id_o(load_trans_id_o),
		.load_result_o(load_result_o),
		.load_valid_o(load_valid_o),
		.load_exception_o(load_exception_o),
		.store_trans_id_o(store_trans_id_o),
		.store_result_o(store_result_o),
		.store_valid_o(store_valid_o),
		.store_exception_o(store_exception_o),
		.commit_i(lsu_commit_i),
		.commit_ready_o(lsu_commit_ready_o),
		.commit_tran_id_i(commit_tran_id_i),
		.enable_translation_i(enable_translation_i),
		.en_ld_st_translation_i(en_ld_st_translation_i),
		.icache_areq_i(icache_areq_i),
		.icache_areq_o(icache_areq_o),
		.priv_lvl_i(priv_lvl_i),
		.ld_st_priv_lvl_i(ld_st_priv_lvl_i),
		.sum_i(sum_i),
		.mxr_i(mxr_i),
		.satp_ppn_i(satp_ppn_i),
		.asid_i(asid_i),
		.asid_to_be_flushed_i(asid_to_be_flushed),
		.vaddr_to_be_flushed_i(vaddr_to_be_flushed),
		.flush_tlb_i(flush_tlb_i),
		.itlb_miss_o(itlb_miss_o),
		.dtlb_miss_o(dtlb_miss_o),
		.dcache_req_ports_i(dcache_req_ports_i),
		.dcache_req_ports_o(dcache_req_ports_o),
		.dcache_wbuffer_empty_i(dcache_wbuffer_empty_i),
		.dcache_wbuffer_not_ni_i(dcache_wbuffer_not_ni_i),
		.amo_valid_commit_i(amo_valid_commit_i),
		.amo_req_o(amo_req_o),
		.amo_resp_i(amo_resp_i),
		.pmpcfg_i(pmpcfg_i),
		.pmpaddr_i(pmpaddr_i)
	);
	localparam cva6_config_pkg_CVA6ConfigCvxifEn = 0;
	localparam [0:0] ariane_pkg_CVXIF_PRESENT = cva6_config_pkg_CVA6ConfigCvxifEn;
	generate
		if (ariane_pkg_CVXIF_PRESENT) begin : gen_cvxif
			wire [110:0] cvxif_data;
			assign cvxif_data = (x_valid_i ? fu_data_i : {111 {1'sb0}});
			cvxif_fu cvxif_fu_i(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.fu_data_i(fu_data_i),
				.x_valid_i(x_valid_i),
				.x_ready_o(x_ready_o),
				.x_off_instr_i(x_off_instr_i),
				.x_trans_id_o(x_trans_id_o),
				.x_exception_o(x_exception_o),
				.x_result_o(x_result_o),
				.x_valid_o(x_valid_o),
				.x_we_o(x_we_o),
				.cvxif_req_o(cvxif_req_o),
				.cvxif_resp_i(cvxif_resp_i)
			);
		end
		else begin : gen_no_cvxif
			assign cvxif_req_o = 1'sb0;
			assign x_trans_id_o = 1'sb0;
			assign x_exception_o = 1'sb0;
			assign x_result_o = 1'sb0;
			assign x_valid_o = 1'sb0;
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			current_instruction_is_sfence_vma <= 1'b0;
		else if (flush_i)
			current_instruction_is_sfence_vma <= 1'b0;
		else if ((fu_data_i[106-:8] == 8'd30) && csr_valid_i)
			current_instruction_is_sfence_vma <= 1'b1;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			asid_to_be_flushed <= 1'sb0;
			vaddr_to_be_flushed <= 1'sb0;
		end
		else if (~current_instruction_is_sfence_vma && ~((fu_data_i[106-:8] == 8'd30) && csr_valid_i)) begin
			vaddr_to_be_flushed <= rs1_forwarding_i;
			asid_to_be_flushed <= rs2_forwarding_i[ASID_WIDTH - 1:0];
		end
endmodule
module fpu_wrap (
	clk_i,
	rst_ni,
	flush_i,
	fpu_valid_i,
	fpu_ready_o,
	fu_data_i,
	fpu_fmt_i,
	fpu_rm_i,
	fpu_frm_i,
	fpu_prec_i,
	fpu_trans_id_o,
	result_o,
	fpu_valid_o,
	fpu_exception_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire fpu_valid_i;
	output reg fpu_ready_o;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	input wire [1:0] fpu_fmt_i;
	input wire [2:0] fpu_rm_i;
	input wire [2:0] fpu_frm_i;
	input wire [6:0] fpu_prec_i;
	output wire [2:0] fpu_trans_id_o;
	localparam cva6_config_pkg_CVA6ConfigFpuEn = 0;
	localparam riscv_FPU_EN = cva6_config_pkg_CVA6ConfigFpuEn;
	localparam riscv_IS_XLEN64 = 1'b0;
	localparam [0:0] ariane_pkg_RVD = (riscv_IS_XLEN64 ? 1 : 0) & riscv_FPU_EN;
	localparam riscv_IS_XLEN32 = 1'b1;
	localparam [0:0] ariane_pkg_RVF = (riscv_IS_XLEN64 | riscv_IS_XLEN32) & riscv_FPU_EN;
	localparam cva6_config_pkg_CVA6ConfigF16En = 0;
	localparam [0:0] ariane_pkg_XF16 = cva6_config_pkg_CVA6ConfigF16En;
	localparam cva6_config_pkg_CVA6ConfigF16AltEn = 0;
	localparam [0:0] ariane_pkg_XF16ALT = cva6_config_pkg_CVA6ConfigF16AltEn;
	localparam cva6_config_pkg_CVA6ConfigF8En = 0;
	localparam [0:0] ariane_pkg_XF8 = cva6_config_pkg_CVA6ConfigF8En;
	localparam ariane_pkg_FLEN = (ariane_pkg_RVD ? 64 : (ariane_pkg_RVF ? 32 : (ariane_pkg_XF16 ? 16 : (ariane_pkg_XF16ALT ? 16 : (ariane_pkg_XF8 ? 8 : 1)))));
	output wire [ariane_pkg_FLEN - 1:0] result_o;
	output wire fpu_valid_o;
	output wire [64:0] fpu_exception_o;
	reg state_q;
	reg state_d;
	localparam [0:0] ariane_pkg_FP_PRESENT = (((ariane_pkg_RVF | ariane_pkg_RVD) | ariane_pkg_XF16) | ariane_pkg_XF16ALT) | ariane_pkg_XF8;
	localparam [31:0] ariane_pkg_LAT_COMP_FP16 = 'd1;
	localparam [31:0] ariane_pkg_LAT_COMP_FP16ALT = 'd1;
	localparam [31:0] ariane_pkg_LAT_COMP_FP32 = 'd2;
	localparam [31:0] ariane_pkg_LAT_COMP_FP64 = 'd3;
	localparam [31:0] ariane_pkg_LAT_COMP_FP8 = 'd1;
	localparam [31:0] ariane_pkg_LAT_CONV = 'd2;
	localparam [31:0] ariane_pkg_LAT_DIVSQRT = 'd2;
	localparam [31:0] ariane_pkg_LAT_NONCOMP = 'd1;
	localparam cva6_config_pkg_CVA6ConfigFVecEn = 0;
	localparam [0:0] ariane_pkg_XFVEC = cva6_config_pkg_CVA6ConfigFVecEn;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	function automatic [3:0] sv2v_cast_C5FF0;
		input reg [3:0] inp;
		sv2v_cast_C5FF0 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_26E92;
		input reg [2:0] inp;
		sv2v_cast_26E92 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_5C706;
		input reg [1:0] inp;
		sv2v_cast_5C706 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 32) - 1:0] sv2v_cast_CDC93;
		input reg [((32'd4 * 32'd5) * 32) - 1:0] inp;
		sv2v_cast_CDC93 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 2) - 1:0] sv2v_cast_15FEF;
		input reg [((32'd4 * 32'd5) * 2) - 1:0] inp;
		sv2v_cast_15FEF = inp;
	endfunction
	generate
		if (ariane_pkg_FP_PRESENT) begin : fpu_gen
			wire [ariane_pkg_FLEN - 1:0] operand_a_i;
			wire [ariane_pkg_FLEN - 1:0] operand_b_i;
			wire [ariane_pkg_FLEN - 1:0] operand_c_i;
			assign operand_a_i = fu_data_i[66 + ariane_pkg_FLEN:67];
			assign operand_b_i = fu_data_i[34 + ariane_pkg_FLEN:35];
			assign operand_c_i = fu_data_i[2 + ariane_pkg_FLEN:3];
			localparam OPBITS = fpnew_pkg_OP_BITS;
			localparam FMTBITS = 3;
			localparam IFMTBITS = 2;
			localparam [42:0] FPU_FEATURES = {sv2v_cast_32(riscv_XLEN), ariane_pkg_XFVEC, 1'b1, sv2v_cast_5({ariane_pkg_RVF, ariane_pkg_RVD, ariane_pkg_XF16, ariane_pkg_XF8, ariane_pkg_XF16ALT}), sv2v_cast_4({ariane_pkg_XFVEC && ariane_pkg_XF8, ariane_pkg_XFVEC && (ariane_pkg_XF16 || ariane_pkg_XF16ALT), 1'b1, 1'b1})};
			localparam [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] FPU_IMPLEMENTATION = {sv2v_cast_CDC93({{ariane_pkg_LAT_COMP_FP32, ariane_pkg_LAT_COMP_FP64, ariane_pkg_LAT_COMP_FP16, ariane_pkg_LAT_COMP_FP8, ariane_pkg_LAT_COMP_FP16ALT}, {fpnew_pkg_NUM_FP_FORMATS {ariane_pkg_LAT_DIVSQRT}}, {fpnew_pkg_NUM_FP_FORMATS {ariane_pkg_LAT_NONCOMP}}, {fpnew_pkg_NUM_FP_FORMATS {ariane_pkg_LAT_CONV}}}), sv2v_cast_15FEF({{fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}, {fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}}), 2'd3};
			reg [ariane_pkg_FLEN - 1:0] operand_a_d;
			reg [ariane_pkg_FLEN - 1:0] operand_a_q;
			wire [ariane_pkg_FLEN - 1:0] operand_a;
			reg [ariane_pkg_FLEN - 1:0] operand_b_d;
			reg [ariane_pkg_FLEN - 1:0] operand_b_q;
			wire [ariane_pkg_FLEN - 1:0] operand_b;
			reg [ariane_pkg_FLEN - 1:0] operand_c_d;
			reg [ariane_pkg_FLEN - 1:0] operand_c_q;
			wire [ariane_pkg_FLEN - 1:0] operand_c;
			reg [3:0] fpu_op_d;
			reg [3:0] fpu_op_q;
			wire [3:0] fpu_op;
			reg fpu_op_mod_d;
			reg fpu_op_mod_q;
			wire fpu_op_mod;
			reg [2:0] fpu_srcfmt_d;
			reg [2:0] fpu_srcfmt_q;
			wire [2:0] fpu_srcfmt;
			reg [2:0] fpu_dstfmt_d;
			reg [2:0] fpu_dstfmt_q;
			wire [2:0] fpu_dstfmt;
			reg [1:0] fpu_ifmt_d;
			reg [1:0] fpu_ifmt_q;
			wire [1:0] fpu_ifmt;
			reg [2:0] fpu_rm_d;
			reg [2:0] fpu_rm_q;
			wire [2:0] fpu_rm;
			reg fpu_vec_op_d;
			reg fpu_vec_op_q;
			wire fpu_vec_op;
			reg [2:0] fpu_tag_d;
			reg [2:0] fpu_tag_q;
			wire [2:0] fpu_tag;
			wire fpu_in_ready;
			reg fpu_in_valid;
			wire fpu_out_ready;
			wire fpu_out_valid;
			wire [4:0] fpu_status;
			reg hold_inputs;
			reg use_hold;
			always @(*) begin : input_translation
				reg vec_replication;
				reg replicate_c;
				reg check_ah;
				operand_a_d = operand_a_i;
				operand_b_d = operand_b_i;
				operand_c_d = operand_c_i;
				fpu_op_d = sv2v_cast_C5FF0(6);
				fpu_op_mod_d = 1'b0;
				fpu_dstfmt_d = sv2v_cast_26E92('d0);
				fpu_ifmt_d = sv2v_cast_5C706(2);
				fpu_rm_d = fpu_rm_i;
				fpu_vec_op_d = fu_data_i[110-:4] == 4'd8;
				fpu_tag_d = fu_data_i[2-:ariane_pkg_TRANS_ID_BITS];
				vec_replication = fpu_rm_i[0];
				replicate_c = 1'b0;
				check_ah = 1'b0;
				if (!((3'b000 <= fpu_rm_i) && (3'b100 >= fpu_rm_i)))
					fpu_rm_d = fpu_frm_i;
				if (fpu_vec_op_d)
					fpu_rm_d = fpu_frm_i;
				case (fpu_fmt_i)
					2'b00: fpu_dstfmt_d = sv2v_cast_26E92('d0);
					2'b01: fpu_dstfmt_d = (fpu_vec_op_d ? sv2v_cast_26E92('d4) : sv2v_cast_26E92('d1));
					2'b10:
						if (!fpu_vec_op_d && (fpu_rm_i == 3'b101))
							fpu_dstfmt_d = sv2v_cast_26E92('d4);
						else
							fpu_dstfmt_d = sv2v_cast_26E92('d2);
					default: fpu_dstfmt_d = sv2v_cast_26E92('d3);
				endcase
				fpu_srcfmt_d = fpu_dstfmt_d;
				case (fu_data_i[106-:8])
					8'd89: begin
						fpu_op_d = sv2v_cast_C5FF0(2);
						replicate_c = 1'b1;
					end
					8'd90: begin
						fpu_op_d = sv2v_cast_C5FF0(2);
						fpu_op_mod_d = 1'b1;
						replicate_c = 1'b1;
					end
					8'd91: fpu_op_d = sv2v_cast_C5FF0(3);
					8'd92: fpu_op_d = sv2v_cast_C5FF0(4);
					8'd93: begin
						fpu_op_d = sv2v_cast_C5FF0(7);
						fpu_rm_d = {1'b0, fpu_rm_i[1:0]};
						check_ah = 1'b1;
					end
					8'd94: fpu_op_d = sv2v_cast_C5FF0(5);
					8'd95: fpu_op_d = sv2v_cast_C5FF0(0);
					8'd96: begin
						fpu_op_d = sv2v_cast_C5FF0(0);
						fpu_op_mod_d = 1'b1;
					end
					8'd97: fpu_op_d = sv2v_cast_C5FF0(1);
					8'd98: begin
						fpu_op_d = sv2v_cast_C5FF0(1);
						fpu_op_mod_d = 1'b1;
					end
					8'd99: begin
						fpu_op_d = sv2v_cast_C5FF0(11);
						if (fpu_vec_op_d) begin
							fpu_op_mod_d = fpu_rm_i[0];
							vec_replication = 1'b0;
							case (fpu_fmt_i)
								2'b00: fpu_ifmt_d = sv2v_cast_5C706(2);
								2'b01, 2'b10: fpu_ifmt_d = sv2v_cast_5C706(1);
								2'b11: fpu_ifmt_d = sv2v_cast_5C706(0);
							endcase
						end
						else begin
							fpu_op_mod_d = operand_c_i[0];
							if (operand_c_i[1])
								fpu_ifmt_d = sv2v_cast_5C706(3);
							else
								fpu_ifmt_d = sv2v_cast_5C706(2);
						end
					end
					8'd100: begin
						fpu_op_d = sv2v_cast_C5FF0(12);
						if (fpu_vec_op_d) begin
							fpu_op_mod_d = fpu_rm_i[0];
							vec_replication = 1'b0;
							case (fpu_fmt_i)
								2'b00: fpu_ifmt_d = sv2v_cast_5C706(2);
								2'b01, 2'b10: fpu_ifmt_d = sv2v_cast_5C706(1);
								2'b11: fpu_ifmt_d = sv2v_cast_5C706(0);
							endcase
						end
						else begin
							fpu_op_mod_d = operand_c_i[0];
							if (operand_c_i[1])
								fpu_ifmt_d = sv2v_cast_5C706(3);
							else
								fpu_ifmt_d = sv2v_cast_5C706(2);
						end
					end
					8'd101: begin
						fpu_op_d = sv2v_cast_C5FF0(10);
						if (fpu_vec_op_d) begin
							vec_replication = 1'b0;
							case (operand_c_i[1:0])
								2'b00: fpu_srcfmt_d = sv2v_cast_26E92('d0);
								2'b01: fpu_srcfmt_d = sv2v_cast_26E92('d4);
								2'b10: fpu_srcfmt_d = sv2v_cast_26E92('d2);
								2'b11: fpu_srcfmt_d = sv2v_cast_26E92('d3);
							endcase
						end
						else
							case (operand_c_i[2:0])
								3'b000: fpu_srcfmt_d = sv2v_cast_26E92('d0);
								3'b001: fpu_srcfmt_d = sv2v_cast_26E92('d1);
								3'b010: fpu_srcfmt_d = sv2v_cast_26E92('d2);
								3'b110: fpu_srcfmt_d = sv2v_cast_26E92('d4);
								3'b011: fpu_srcfmt_d = sv2v_cast_26E92('d3);
							endcase
					end
					8'd102: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = {1'b0, fpu_rm_i[1:0]};
						check_ah = 1'b1;
					end
					8'd103: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = 3'b011;
						fpu_op_mod_d = 1'b1;
						check_ah = 1'b1;
						vec_replication = 1'b0;
					end
					8'd104: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = 3'b011;
						check_ah = 1'b1;
						vec_replication = 1'b0;
					end
					8'd105: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_rm_d = {1'b0, fpu_rm_i[1:0]};
						check_ah = 1'b1;
					end
					8'd106: begin
						fpu_op_d = sv2v_cast_C5FF0(9);
						fpu_rm_d = {1'b0, fpu_rm_i[1:0]};
						check_ah = 1'b1;
					end
					8'd107: begin
						fpu_op_d = sv2v_cast_C5FF0(7);
						fpu_rm_d = 3'b000;
					end
					8'd108: begin
						fpu_op_d = sv2v_cast_C5FF0(7);
						fpu_rm_d = 3'b001;
					end
					8'd109: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = 3'b000;
					end
					8'd110: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = 3'b001;
					end
					8'd111: begin
						fpu_op_d = sv2v_cast_C5FF0(6);
						fpu_rm_d = 3'b010;
					end
					8'd112: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_rm_d = 3'b010;
					end
					8'd113: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_op_mod_d = 1'b1;
						fpu_rm_d = 3'b010;
					end
					8'd114: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_rm_d = 3'b001;
					end
					8'd115: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_op_mod_d = 1'b1;
						fpu_rm_d = 3'b001;
					end
					8'd116: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_rm_d = 3'b000;
					end
					8'd117: begin
						fpu_op_d = sv2v_cast_C5FF0(8);
						fpu_op_mod_d = 1'b1;
						fpu_rm_d = 3'b000;
					end
					8'd118: begin
						fpu_op_d = sv2v_cast_C5FF0(13);
						fpu_op_mod_d = fpu_rm_i[0];
						vec_replication = 1'b0;
						fpu_srcfmt_d = sv2v_cast_26E92('d0);
					end
					8'd119: begin
						fpu_op_d = sv2v_cast_C5FF0(14);
						fpu_op_mod_d = fpu_rm_i[0];
						vec_replication = 1'b0;
						fpu_srcfmt_d = sv2v_cast_26E92('d0);
					end
					8'd120: begin
						fpu_op_d = sv2v_cast_C5FF0(13);
						fpu_op_mod_d = fpu_rm_i[0];
						vec_replication = 1'b0;
						fpu_srcfmt_d = sv2v_cast_26E92('d1);
					end
					8'd121: begin
						fpu_op_d = sv2v_cast_C5FF0(14);
						fpu_op_mod_d = fpu_rm_i[0];
						vec_replication = 1'b0;
						fpu_srcfmt_d = sv2v_cast_26E92('d1);
					end
					default:
						;
				endcase
				if (!fpu_vec_op_d && check_ah)
					if (fpu_rm_i[2])
						fpu_dstfmt_d = sv2v_cast_26E92('d4);
				if (fpu_vec_op_d && vec_replication)
					if (replicate_c)
						case (fpu_dstfmt_d)
							sv2v_cast_26E92('d0): operand_c_d = (ariane_pkg_RVD ? {2 {operand_c_i[31:0]}} : operand_c_i);
							sv2v_cast_26E92('d2), sv2v_cast_26E92('d4): operand_c_d = (ariane_pkg_RVD ? {4 {operand_c_i[15:0]}} : {2 {operand_c_i[15:0]}});
							sv2v_cast_26E92('d3): operand_c_d = (ariane_pkg_RVD ? {8 {operand_c_i[7:0]}} : {4 {operand_c_i[7:0]}});
						endcase
					else
						case (fpu_dstfmt_d)
							sv2v_cast_26E92('d0): operand_b_d = (ariane_pkg_RVD ? {2 {operand_b_i[31:0]}} : operand_b_i);
							sv2v_cast_26E92('d2), sv2v_cast_26E92('d4): operand_b_d = (ariane_pkg_RVD ? {4 {operand_b_i[15:0]}} : {2 {operand_b_i[15:0]}});
							sv2v_cast_26E92('d3): operand_b_d = (ariane_pkg_RVD ? {8 {operand_b_i[7:0]}} : {4 {operand_b_i[7:0]}});
						endcase
			end
			always @(*) begin : p_inputFSM
				fpu_ready_o = 1'b0;
				fpu_in_valid = 1'b0;
				hold_inputs = 1'b0;
				use_hold = 1'b0;
				state_d = state_q;
				case (state_q)
					1'd0: begin
						fpu_ready_o = 1'b1;
						fpu_in_valid = fpu_valid_i;
						if (fpu_valid_i & ~fpu_in_ready) begin
							fpu_ready_o = 1'b0;
							hold_inputs = 1'b1;
							state_d = 1'd1;
						end
					end
					1'd1: begin
						fpu_in_valid = 1'b1;
						use_hold = 1'b1;
						if (fpu_in_ready) begin
							fpu_ready_o = 1'b1;
							state_d = 1'd0;
						end
					end
					default:
						;
				endcase
				if (flush_i)
					state_d = 1'd0;
			end
			always @(posedge clk_i or negedge rst_ni) begin : fp_hold_reg
				if (~rst_ni) begin
					state_q <= 1'd0;
					operand_a_q <= 1'sb0;
					operand_b_q <= 1'sb0;
					operand_c_q <= 1'sb0;
					fpu_op_q <= 1'sb0;
					fpu_op_mod_q <= 1'sb0;
					fpu_srcfmt_q <= 1'sb0;
					fpu_dstfmt_q <= 1'sb0;
					fpu_ifmt_q <= 1'sb0;
					fpu_rm_q <= 1'sb0;
					fpu_vec_op_q <= 1'sb0;
					fpu_tag_q <= 1'sb0;
				end
				else begin
					state_q <= state_d;
					if (hold_inputs) begin
						operand_a_q <= operand_a_d;
						operand_b_q <= operand_b_d;
						operand_c_q <= operand_c_d;
						fpu_op_q <= fpu_op_d;
						fpu_op_mod_q <= fpu_op_mod_d;
						fpu_srcfmt_q <= fpu_srcfmt_d;
						fpu_dstfmt_q <= fpu_dstfmt_d;
						fpu_ifmt_q <= fpu_ifmt_d;
						fpu_rm_q <= fpu_rm_d;
						fpu_vec_op_q <= fpu_vec_op_d;
						fpu_tag_q <= fpu_tag_d;
					end
				end
			end
			assign operand_a = (use_hold ? operand_a_q : operand_a_d);
			assign operand_b = (use_hold ? operand_b_q : operand_b_d);
			assign operand_c = (use_hold ? operand_c_q : operand_c_d);
			assign fpu_op = (use_hold ? fpu_op_q : fpu_op_d);
			assign fpu_op_mod = (use_hold ? fpu_op_mod_q : fpu_op_mod_d);
			assign fpu_srcfmt = (use_hold ? fpu_srcfmt_q : fpu_srcfmt_d);
			assign fpu_dstfmt = (use_hold ? fpu_dstfmt_q : fpu_dstfmt_d);
			assign fpu_ifmt = (use_hold ? fpu_ifmt_q : fpu_ifmt_d);
			assign fpu_rm = (use_hold ? fpu_rm_q : fpu_rm_d);
			assign fpu_vec_op = (use_hold ? fpu_vec_op_q : fpu_vec_op_d);
			assign fpu_tag = (use_hold ? fpu_tag_q : fpu_tag_d);
			wire [(3 * ariane_pkg_FLEN) - 1:0] fpu_operands;
			assign fpu_operands[0+:ariane_pkg_FLEN] = operand_a;
			assign fpu_operands[ariane_pkg_FLEN+:ariane_pkg_FLEN] = operand_b;
			assign fpu_operands[2 * ariane_pkg_FLEN+:ariane_pkg_FLEN] = operand_c;
			fpnew_top_60D59 #(
				.Features(FPU_FEATURES),
				.Implementation(FPU_IMPLEMENTATION)
			) i_fpnew_bulk(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(fpu_operands),
				.rnd_mode_i(fpu_rm),
				.op_i(sv2v_cast_C5FF0(fpu_op)),
				.op_mod_i(fpu_op_mod),
				.src_fmt_i(sv2v_cast_26E92(fpu_srcfmt)),
				.dst_fmt_i(sv2v_cast_26E92(fpu_dstfmt)),
				.int_fmt_i(sv2v_cast_5C706(fpu_ifmt)),
				.vectorial_op_i(fpu_vec_op),
				.tag_i(fpu_tag),
				.in_valid_i(fpu_in_valid),
				.in_ready_o(fpu_in_ready),
				.flush_i(flush_i),
				.result_o(result_o),
				.status_o(fpu_status),
				.tag_o(fpu_trans_id_o),
				.out_valid_o(fpu_out_valid),
				.out_ready_i(fpu_out_ready),
				.busy_o()
			);
			assign fpu_exception_o[64-:32] = {59'h000000000000000, fpu_status};
			assign fpu_exception_o[0] = 1'b0;
			assign fpu_out_ready = 1'b1;
			assign fpu_valid_o = fpu_out_valid;
		end
	endgenerate
endmodule
module id_stage (
	clk_i,
	rst_ni,
	flush_i,
	debug_req_i,
	fetch_entry_i,
	fetch_entry_valid_i,
	fetch_entry_ready_o,
	issue_entry_o,
	issue_entry_valid_o,
	is_ctrl_flow_o,
	issue_instr_ack_i,
	priv_lvl_i,
	fs_i,
	frm_i,
	irq_i,
	irq_ctrl_i,
	debug_mode_i,
	tvm_i,
	tw_i,
	tsr_i
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire debug_req_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [163:0] fetch_entry_i;
	input wire fetch_entry_valid_i;
	output reg fetch_entry_ready_o;
	localparam ariane_pkg_REG_ADDR_SIZE = 6;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	output wire [201:0] issue_entry_o;
	output wire issue_entry_valid_o;
	output wire is_ctrl_flow_o;
	input wire issue_instr_ack_i;
	input wire [1:0] priv_lvl_i;
	input wire [1:0] fs_i;
	input wire [2:0] frm_i;
	input wire [1:0] irq_i;
	input wire [97:0] irq_ctrl_i;
	input wire debug_mode_i;
	input wire tvm_i;
	input wire tw_i;
	input wire tsr_i;
	reg [203:0] issue_n;
	reg [203:0] issue_q;
	wire is_control_flow_instr;
	wire [201:0] decoded_instruction;
	wire is_illegal;
	wire [31:0] instruction;
	wire is_compressed;
	localparam cva6_config_pkg_CVA6ConfigCExtEn = 1;
	localparam [0:0] ariane_pkg_RVC = cva6_config_pkg_CVA6ConfigCExtEn;
	generate
		if (ariane_pkg_RVC) begin : genblk1
			compressed_decoder compressed_decoder_i(
				.instr_i(fetch_entry_i[131-:32]),
				.instr_o(instruction),
				.illegal_instr_o(is_illegal),
				.is_compressed_o(is_compressed)
			);
		end
		else begin : genblk1
			assign instruction = fetch_entry_i[131-:32];
			assign is_illegal = 1'sb0;
			assign is_compressed = 1'sb0;
		end
	endgenerate
	decoder decoder_i(
		.debug_req_i(debug_req_i),
		.irq_ctrl_i(irq_ctrl_i),
		.irq_i(irq_i),
		.pc_i(fetch_entry_i[163-:32]),
		.is_compressed_i(is_compressed),
		.is_illegal_i(is_illegal),
		.instruction_i(instruction),
		.compressed_instr_i(fetch_entry_i[115:100]),
		.branch_predict_i(fetch_entry_i[99-:35]),
		.ex_i(fetch_entry_i[64-:65]),
		.priv_lvl_i(priv_lvl_i),
		.debug_mode_i(debug_mode_i),
		.fs_i(fs_i),
		.frm_i(frm_i),
		.tvm_i(tvm_i),
		.tw_i(tw_i),
		.tsr_i(tsr_i),
		.instruction_o(decoded_instruction),
		.is_control_flow_instr_o(is_control_flow_instr)
	);
	assign issue_entry_o = issue_q[202-:202];
	assign issue_entry_valid_o = issue_q[203];
	assign is_ctrl_flow_o = issue_q[0];
	always @(*) begin
		issue_n = issue_q;
		fetch_entry_ready_o = 1'b0;
		if (issue_instr_ack_i)
			issue_n[203] = 1'b0;
		if ((!issue_q[203] || issue_instr_ack_i) && fetch_entry_valid_i) begin
			fetch_entry_ready_o = 1'b1;
			issue_n = {1'b1, decoded_instruction, is_control_flow_instr};
		end
		if (flush_i)
			issue_n[203] = 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			issue_q <= 1'sb0;
		else
			issue_q <= issue_n;
endmodule
module instr_realign (
	clk_i,
	rst_ni,
	flush_i,
	valid_i,
	serving_unaligned_o,
	address_i,
	data_i,
	valid_o,
	addr_o,
	instr_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire valid_i;
	output wire serving_unaligned_o;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	input wire [31:0] address_i;
	localparam [31:0] ariane_pkg_FETCH_WIDTH = 32;
	input wire [31:0] data_i;
	localparam cva6_config_pkg_CVA6ConfigCExtEn = 1;
	localparam [0:0] ariane_pkg_RVC = cva6_config_pkg_CVA6ConfigCExtEn;
	localparam [31:0] ariane_pkg_INSTR_PER_FETCH = (ariane_pkg_RVC == 1'b1 ? 2 : 1);
	output reg [ariane_pkg_INSTR_PER_FETCH - 1:0] valid_o;
	output reg [(ariane_pkg_INSTR_PER_FETCH * 32) - 1:0] addr_o;
	output reg [(ariane_pkg_INSTR_PER_FETCH * 32) - 1:0] instr_o;
	wire [3:0] instr_is_compressed;
	genvar i;
	generate
		for (i = 0; i < ariane_pkg_INSTR_PER_FETCH; i = i + 1) begin : genblk1
			assign instr_is_compressed[i] = ~&data_i[i * 16+:2];
		end
	endgenerate
	reg [15:0] unaligned_instr_d;
	reg [15:0] unaligned_instr_q;
	reg unaligned_d;
	reg unaligned_q;
	reg [31:0] unaligned_address_d;
	reg [31:0] unaligned_address_q;
	assign serving_unaligned_o = unaligned_q;
	generate
		if (1) begin : realign_bp_32
			always @(*) begin : re_align
				unaligned_d = unaligned_q;
				unaligned_address_d = {address_i[31:2], 2'b10};
				unaligned_instr_d = data_i[31:16];
				valid_o[0] = valid_i;
				instr_o[0+:32] = (unaligned_q ? {data_i[15:0], unaligned_instr_q} : data_i[31:0]);
				addr_o[0+:32] = (unaligned_q ? unaligned_address_q : address_i);
				valid_o[1] = 1'b0;
				instr_o[32+:32] = 1'sb0;
				addr_o[32+:32] = {address_i[31:2], 2'b10};
				if (instr_is_compressed[0] || unaligned_q)
					if (instr_is_compressed[1]) begin
						unaligned_d = 1'b0;
						valid_o[1] = valid_i;
						instr_o[32+:32] = {16'b0000000000000000, data_i[31:16]};
					end
					else begin
						unaligned_d = 1'b1;
						unaligned_instr_d = data_i[31:16];
						unaligned_address_d = {address_i[31:2], 2'b10};
					end
				if (valid_i && address_i[1])
					if (!instr_is_compressed[0]) begin
						valid_o = 1'sb0;
						unaligned_d = 1'b1;
						unaligned_address_d = {address_i[31:2], 2'b10};
						unaligned_instr_d = data_i[15:0];
					end
					else
						valid_o = 1'b1;
			end
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			unaligned_q <= 1'b0;
			unaligned_address_q <= 1'sb0;
			unaligned_instr_q <= 1'sb0;
		end
		else begin
			if (valid_i) begin
				unaligned_address_q <= unaligned_address_d;
				unaligned_instr_q <= unaligned_instr_d;
			end
			if (flush_i)
				unaligned_q <= 1'b0;
			else if (valid_i)
				unaligned_q <= unaligned_d;
		end
endmodule
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
	localparam [0:0] ariane_pkg_MMU_PRESENT = 1'b1;
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
					mmu_paddr <= mmu_vaddr[33:0];
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
		.req_port_o(dcache_req_ports_o[(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9) + (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))+:(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10 : 1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))]),
		.dcache_wbuffer_not_ni_i(dcache_wbuffer_not_ni_i),
		.commit_tran_id_i(commit_tran_id_i),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i)
	);
	localparam [31:0] ariane_pkg_NR_LOAD_PIPE_REGS = 1;
	shift_reg_1F3E0_50B1B #(
		.dtype_riscv_XLEN(riscv_XLEN),
		.Depth(ariane_pkg_NR_LOAD_PIPE_REGS)
	) i_pipe_reg_load(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i({ld_valid, ld_trans_id, ld_result, ld_ex}),
		.d_o({load_valid_o, load_trans_id_o, load_result_o, load_exception_o})
	);
	localparam [31:0] ariane_pkg_NR_STORE_PIPE_REGS = 0;
	shift_reg_1F3E0_50B1B #(
		.dtype_riscv_XLEN(riscv_XLEN),
		.Depth(ariane_pkg_NR_STORE_PIPE_REGS)
	) i_pipe_reg_store(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i({st_valid, st_trans_id, st_result, st_ex}),
		.d_o({store_valid_o, store_trans_id_o, store_result_o, store_exception_o})
	);
	always @(*) begin : which_op
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
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i)
	);
endmodule
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
	assign paddr_ni = ariane_pkg_is_inside_nonidempotent_regions(ArianeCfg, {dtlb_ppn_i, 12'd0});
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
	always @(*) begin : sv2v_autoblock_1
		reg [1:0] status_cnt;
		reg write_pointer;
		reg read_pointer;
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
module mult (
	clk_i,
	rst_ni,
	flush_i,
	fu_data_i,
	mult_valid_i,
	result_o,
	mult_valid_o,
	mult_ready_o,
	mult_trans_id_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [110:0] fu_data_i;
	input wire mult_valid_i;
	output wire [31:0] result_o;
	output wire mult_valid_o;
	output wire mult_ready_o;
	output wire [2:0] mult_trans_id_o;
	wire mul_valid;
	wire div_valid;
	wire div_ready_i;
	wire [2:0] mul_trans_id;
	wire [2:0] div_trans_id;
	wire [31:0] mul_result;
	wire [31:0] div_result;
	wire div_valid_op;
	wire mul_valid_op;
	assign mul_valid_op = (~flush_i && mult_valid_i) && |{fu_data_i[106-:8] == 8'd68, fu_data_i[106-:8] == 8'd69, fu_data_i[106-:8] == 8'd70, fu_data_i[106-:8] == 8'd71, fu_data_i[106-:8] == 8'd72, fu_data_i[106-:8] == 8'd140, fu_data_i[106-:8] == 8'd141, fu_data_i[106-:8] == 8'd142};
	assign div_valid_op = (~flush_i && mult_valid_i) && |{fu_data_i[106-:8] == 8'd73, fu_data_i[106-:8] == 8'd74, fu_data_i[106-:8] == 8'd75, fu_data_i[106-:8] == 8'd76, fu_data_i[106-:8] == 8'd77, fu_data_i[106-:8] == 8'd78, fu_data_i[106-:8] == 8'd79, fu_data_i[106-:8] == 8'd80};
	assign div_ready_i = (mul_valid ? 1'b0 : 1'b1);
	assign mult_trans_id_o = (mul_valid ? mul_trans_id : div_trans_id);
	assign result_o = (mul_valid ? mul_result : div_result);
	assign mult_valid_o = div_valid | mul_valid;
	multiplier i_multiplier(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.trans_id_i(fu_data_i[2-:ariane_pkg_TRANS_ID_BITS]),
		.operator_i(fu_data_i[106-:8]),
		.operand_a_i(fu_data_i[98-:32]),
		.operand_b_i(fu_data_i[66-:32]),
		.result_o(mul_result),
		.mult_valid_i(mul_valid_op),
		.mult_valid_o(mul_valid),
		.mult_trans_id_o(mul_trans_id)
	);
	reg [31:0] operand_b;
	reg [31:0] operand_a;
	wire [31:0] result;
	wire div_signed;
	wire rem;
	reg word_op_d;
	reg word_op_q;
	assign div_signed = |{fu_data_i[106-:8] == 8'd73, fu_data_i[106-:8] == 8'd75, fu_data_i[106-:8] == 8'd77, fu_data_i[106-:8] == 8'd79};
	assign rem = |{fu_data_i[106-:8] == 8'd77, fu_data_i[106-:8] == 8'd78, fu_data_i[106-:8] == 8'd79, fu_data_i[106-:8] == 8'd80};
	function automatic [31:0] ariane_pkg_sext32;
		input reg [31:0] operand;
		ariane_pkg_sext32 = {operand[31:0]};
	endfunction
	always @(*) begin
		operand_a = 1'sb0;
		operand_b = 1'sb0;
		word_op_d = word_op_q;
		if (mult_valid_i && |{fu_data_i[106-:8] == 8'd73, fu_data_i[106-:8] == 8'd74, fu_data_i[106-:8] == 8'd75, fu_data_i[106-:8] == 8'd76, fu_data_i[106-:8] == 8'd77, fu_data_i[106-:8] == 8'd78, fu_data_i[106-:8] == 8'd79, fu_data_i[106-:8] == 8'd80})
			if (|{fu_data_i[106-:8] == 8'd75, fu_data_i[106-:8] == 8'd76, fu_data_i[106-:8] == 8'd79, fu_data_i[106-:8] == 8'd80}) begin
				if (div_signed) begin
					operand_a = ariane_pkg_sext32(fu_data_i[98:67]);
					operand_b = ariane_pkg_sext32(fu_data_i[66:35]);
				end
				else begin
					operand_a = fu_data_i[98:67];
					operand_b = fu_data_i[66:35];
				end
				word_op_d = 1'b1;
			end
			else begin
				operand_a = fu_data_i[98-:32];
				operand_b = fu_data_i[66-:32];
				word_op_d = 1'b0;
			end
	end
	serdiv #(.WIDTH(riscv_XLEN)) i_div(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.id_i(fu_data_i[2-:ariane_pkg_TRANS_ID_BITS]),
		.op_a_i(operand_a),
		.op_b_i(operand_b),
		.opcode_i({rem, div_signed}),
		.in_vld_i(div_valid_op),
		.in_rdy_o(mult_ready_o),
		.flush_i(flush_i),
		.out_vld_o(div_valid),
		.out_rdy_i(div_ready_i),
		.id_o(div_trans_id),
		.res_o(result)
	);
	assign div_result = (word_op_q ? ariane_pkg_sext32(result) : result);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			word_op_q <= 1'sb0;
		else
			word_op_q <= word_op_d;
endmodule
module multiplier (
	clk_i,
	rst_ni,
	trans_id_i,
	mult_valid_i,
	operator_i,
	operand_a_i,
	operand_b_i,
	result_o,
	mult_valid_o,
	mult_ready_o,
	mult_trans_id_o
);
	input wire clk_i;
	input wire rst_ni;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	input wire [2:0] trans_id_i;
	input wire mult_valid_i;
	input wire [7:0] operator_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	output reg [31:0] result_o;
	output wire mult_valid_o;
	output wire mult_ready_o;
	output wire [2:0] mult_trans_id_o;
	reg [31:0] clmul_q;
	reg [31:0] clmul_d;
	reg [31:0] clmulr_q;
	wire [31:0] clmulr_d;
	wire [31:0] operand_a;
	wire [31:0] operand_b;
	wire [31:0] operand_a_rev;
	wire [31:0] operand_b_rev;
	wire clmul_rmode;
	wire clmul_hmode;
	localparam [0:0] ariane_pkg_BITMANIP = 1'b1;
	generate
		if (ariane_pkg_BITMANIP) begin : gen_bitmanip
			assign clmul_rmode = operator_i == 8'd142;
			assign clmul_hmode = operator_i == 8'd141;
			genvar i;
			for (i = 0; i < riscv_XLEN; i = i + 1) begin : genblk1
				assign operand_a_rev[i] = operand_a_i[31 - i];
				assign operand_b_rev[i] = operand_b_i[31 - i];
			end
			assign operand_a = (clmul_rmode | clmul_hmode ? operand_a_rev : operand_a_i);
			assign operand_b = (clmul_rmode | clmul_hmode ? operand_b_rev : operand_b_i);
			always @(*) begin
				clmul_d = 1'sb0;
				begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = 0; i <= riscv_XLEN; i = i + 1)
						clmul_d = ((operand_b >> i) & 1 ? clmul_d ^ (operand_a << i) : clmul_d);
				end
			end
			for (i = 0; i < riscv_XLEN; i = i + 1) begin : genblk2
				assign clmulr_d[i] = clmul_d[31 - i];
			end
		end
	endgenerate
	reg [2:0] trans_id_q;
	reg mult_valid_q;
	wire [7:0] operator_d;
	reg [7:0] operator_q;
	wire [63:0] mult_result_d;
	reg [63:0] mult_result_q;
	reg sign_a;
	reg sign_b;
	wire mult_valid;
	assign mult_valid_o = mult_valid_q;
	assign mult_trans_id_o = trans_id_q;
	assign mult_ready_o = 1'b1;
	assign mult_valid = mult_valid_i && |{operator_i == 8'd68, operator_i == 8'd69, operator_i == 8'd70, operator_i == 8'd71, operator_i == 8'd72, operator_i == 8'd140, operator_i == 8'd141, operator_i == 8'd142};
	always @(*) begin
		sign_a = 1'b0;
		sign_b = 1'b0;
		if (operator_i == 8'd69) begin
			sign_a = 1'b1;
			sign_b = 1'b1;
		end
		else if (operator_i == 8'd71)
			sign_a = 1'b1;
		else begin
			sign_a = 1'b0;
			sign_b = 1'b0;
		end
	end
	assign mult_result_d = $signed({operand_a_i[31] & sign_a, operand_a_i}) * $signed({operand_b_i[31] & sign_b, operand_b_i});
	assign operator_d = operator_i;
	function automatic [31:0] ariane_pkg_sext32;
		input reg [31:0] operand;
		ariane_pkg_sext32 = {operand[31:0]};
	endfunction
	always @(*) begin : p_selmux
		case (operator_q)
			8'd69, 8'd70, 8'd71: result_o = mult_result_q[63:riscv_XLEN];
			8'd72: result_o = ariane_pkg_sext32(mult_result_q[31:0]);
			8'd140: result_o = clmul_q;
			8'd141: result_o = clmulr_q >> 1;
			8'd142: result_o = clmulr_q;
			default: result_o = mult_result_q[31:0];
		endcase
	end
	generate
		if (ariane_pkg_BITMANIP) begin : genblk2
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni) begin
					clmul_q <= 1'sb0;
					clmulr_q <= 1'sb0;
				end
				else begin
					clmul_q <= clmul_d;
					clmulr_q <= clmulr_d;
				end
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			mult_valid_q <= 1'sb0;
			trans_id_q <= 1'sb0;
			operator_q <= 8'd68;
			mult_result_q <= 1'sb0;
		end
		else begin
			trans_id_q <= trans_id_i;
			mult_valid_q <= mult_valid;
			operator_q <= operator_d;
			mult_result_q <= mult_result_d;
		end
endmodule
module perf_counters (
	clk_i,
	rst_ni,
	debug_mode_i,
	addr_i,
	we_i,
	data_i,
	data_o,
	commit_instr_i,
	commit_ack_i,
	l1_icache_miss_i,
	l1_dcache_miss_i,
	itlb_miss_i,
	dtlb_miss_i,
	sb_full_i,
	if_empty_i,
	ex_i,
	eret_i,
	resolved_branch_i
);
	input wire clk_i;
	input wire rst_ni;
	input wire debug_mode_i;
	input wire [4:0] addr_i;
	input wire we_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	input wire [31:0] data_i;
	output reg [31:0] data_o;
	localparam ariane_pkg_NR_COMMIT_PORTS = 2;
	localparam ariane_pkg_REG_ADDR_SIZE = 6;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam riscv_VLEN = 32;
	input wire [403:0] commit_instr_i;
	input wire [1:0] commit_ack_i;
	input wire l1_icache_miss_i;
	input wire l1_dcache_miss_i;
	input wire itlb_miss_i;
	input wire dtlb_miss_i;
	input wire sb_full_i;
	input wire if_empty_i;
	input wire [64:0] ex_i;
	input wire eret_i;
	input wire [69:0] resolved_branch_i;
	localparam [6:0] RegOffset = 12'hb03 >> 5;
	reg [(12'hb10 >= 12'hb03 ? (((12'hb10 - 12'hb03) + 1) * 32) + 90207 : (((12'hb03 - 12'hb10) + 1) * 32) + 90623):(12'hb10 >= 12'hb03 ? 90208 : 90624)] perf_counter_d;
	reg [(12'hb10 >= 12'hb03 ? (((12'hb10 - 12'hb03) + 1) * 32) + 90207 : (((12'hb03 - 12'hb10) + 1) * 32) + 90623):(12'hb10 >= 12'hb03 ? 90208 : 90624)] perf_counter_q;
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	always @(*) begin : perf_counters
		perf_counter_d = perf_counter_q;
		data_o = 'b0;
		if (!debug_mode_i) begin
			if (l1_icache_miss_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb03 : (12'hb03 - 12'hb03) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb03 : (12'hb03 - 12'hb03) + 12'hb10) * 32+:32] + 1'b1;
			if (l1_dcache_miss_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb04 : (12'hb03 - 12'hb04) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb04 : (12'hb03 - 12'hb04) + 12'hb10) * 32+:32] + 1'b1;
			if (itlb_miss_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb05 : (12'hb03 - 12'hb05) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb05 : (12'hb03 - 12'hb05) + 12'hb10) * 32+:32] + 1'b1;
			if (dtlb_miss_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb06 : (12'hb03 - 12'hb06) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb06 : (12'hb03 - 12'hb06) + 12'hb10) * 32+:32] + 1'b1;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < ariane_pkg_NR_COMMIT_PORTS; i = i + 1)
					if (commit_ack_i[i]) begin
						if (commit_instr_i[(i * 202) + 166-:4] == 4'd1)
							perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb07 : (12'hb03 - 12'hb07) + 12'hb10) * 32+:32] = perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb07 : (12'hb03 - 12'hb07) + 12'hb10) * 32+:32] + 1;
						if (commit_instr_i[(i * 202) + 166-:4] == 4'd2)
							perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb08 : (12'hb03 - 12'hb08) + 12'hb10) * 32+:32] = perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb08 : (12'hb03 - 12'hb08) + 12'hb10) * 32+:32] + 1;
						if (commit_instr_i[(i * 202) + 166-:4] == 4'd4)
							perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0b : (12'hb03 - 12'hb0b) + 12'hb10) * 32+:32] = perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0b : (12'hb03 - 12'hb0b) + 12'hb10) * 32+:32] + 1;
						if (((commit_instr_i[(i * 202) + 166-:4] == 4'd4) && ((commit_instr_i[(i * 202) + 162-:8] == {8 {1'sb0}}) || (commit_instr_i[(i * 202) + 162-:8] == 8'd19))) && ((commit_instr_i[(i * 202) + 142-:6] == 'd1) || (commit_instr_i[(i * 202) + 142-:6] == 'd5)))
							perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0c : (12'hb03 - 12'hb0c) + 12'hb10) * 32+:32] = perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0c : (12'hb03 - 12'hb0c) + 12'hb10) * 32+:32] + 1;
						if ((commit_instr_i[(i * 202) + 162-:8] == 8'd19) && (commit_instr_i[(i * 202) + 142-:6] == 'd0))
							perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0d : (12'hb03 - 12'hb0d) + 12'hb10) * 32+:32] = perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0d : (12'hb03 - 12'hb0d) + 12'hb10) * 32+:32] + 1;
					end
			end
			if (ex_i[0])
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb09 : (12'hb03 - 12'hb09) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb09 : (12'hb03 - 12'hb09) + 12'hb10) * 32+:32] + 1'b1;
			if (eret_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0a : (12'hb03 - 12'hb0a) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb0a : (12'hb03 - 12'hb0a) + 12'hb10) * 32+:32] + 1'b1;
			if (resolved_branch_i[69] && resolved_branch_i[4])
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0e : (12'hb03 - 12'hb0e) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb0e : (12'hb03 - 12'hb0e) + 12'hb10) * 32+:32] + 1'b1;
			if (sb_full_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb0f : (12'hb03 - 12'hb0f) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb0f : (12'hb03 - 12'hb0f) + 12'hb10) * 32+:32] + 1'b1;
			if (if_empty_i)
				perf_counter_d[(12'hb10 >= 12'hb03 ? 12'hb10 : (12'hb03 - 12'hb10) + 12'hb10) * 32+:32] = perf_counter_q[(12'hb10 >= 12'hb03 ? 12'hb10 : (12'hb03 - 12'hb10) + 12'hb10) * 32+:32] + 1'b1;
		end
		if ((sv2v_cast_12({RegOffset, addr_i}) >= 12'hb03) && (sv2v_cast_12({RegOffset, addr_i}) <= 12'hb10))
			data_o = perf_counter_q[(12'hb10 >= 12'hb03 ? {RegOffset, addr_i} : (12'hb03 + 12'hb10) - {RegOffset, addr_i}) * 32+:32];
		else
			data_o = 1'sb0;
		if (we_i)
			perf_counter_d[(12'hb10 >= 12'hb03 ? {RegOffset, addr_i} : (12'hb03 + 12'hb10) - {RegOffset, addr_i}) * 32+:32] = data_i;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			perf_counter_q <= 1'sb0;
		else
			perf_counter_q <= perf_counter_d;
endmodule
module serdiv (
	clk_i,
	rst_ni,
	id_i,
	op_a_i,
	op_b_i,
	opcode_i,
	in_vld_i,
	in_rdy_o,
	flush_i,
	out_vld_o,
	out_rdy_i,
	id_o,
	res_o
);
	parameter WIDTH = 64;
	input wire clk_i;
	input wire rst_ni;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	input wire [2:0] id_i;
	input wire [WIDTH - 1:0] op_a_i;
	input wire [WIDTH - 1:0] op_b_i;
	input wire [1:0] opcode_i;
	input wire in_vld_i;
	output reg in_rdy_o;
	input wire flush_i;
	output reg out_vld_o;
	input wire out_rdy_i;
	output wire [2:0] id_o;
	output wire [WIDTH - 1:0] res_o;
	reg [1:0] state_d;
	reg [1:0] state_q;
	reg [WIDTH - 1:0] res_q;
	wire [WIDTH - 1:0] res_d;
	reg [WIDTH - 1:0] op_a_q;
	wire [WIDTH - 1:0] op_a_d;
	reg [WIDTH - 1:0] op_b_q;
	wire [WIDTH - 1:0] op_b_d;
	wire op_a_sign;
	wire op_b_sign;
	wire op_b_zero;
	reg op_b_zero_q;
	wire op_b_zero_d;
	reg [2:0] id_q;
	wire [2:0] id_d;
	wire rem_sel_d;
	reg rem_sel_q;
	wire comp_inv_d;
	reg comp_inv_q;
	wire res_inv_d;
	reg res_inv_q;
	wire [WIDTH - 1:0] add_mux;
	wire [WIDTH - 1:0] add_out;
	wire [WIDTH - 1:0] add_tmp;
	wire [WIDTH - 1:0] b_mux;
	wire [WIDTH - 1:0] out_mux;
	reg [$clog2(WIDTH + 1) - 1:0] cnt_q;
	wire [$clog2(WIDTH + 1) - 1:0] cnt_d;
	wire cnt_zero;
	wire [WIDTH - 1:0] lzc_a_input;
	wire [WIDTH - 1:0] lzc_b_input;
	wire [WIDTH - 1:0] op_b;
	wire [$clog2(WIDTH) - 1:0] lzc_a_result;
	wire [$clog2(WIDTH) - 1:0] lzc_b_result;
	wire [$clog2(WIDTH + 1) - 1:0] shift_a;
	wire [$clog2(WIDTH + 1):0] div_shift;
	reg a_reg_en;
	reg b_reg_en;
	reg res_reg_en;
	wire ab_comp;
	wire pm_sel;
	reg load_en;
	wire lzc_a_no_one;
	wire lzc_b_no_one;
	wire div_res_zero_d;
	reg div_res_zero_q;
	assign op_b_zero = op_b_i == 0;
	assign op_a_sign = op_a_i[WIDTH - 1];
	assign op_b_sign = op_b_i[WIDTH - 1];
	assign lzc_a_input = ((opcode_i[0] & op_a_sign) & (op_a_i == -$signed(1)) ? {~op_a_i, 1'b1} : (opcode_i[0] & op_a_sign ? {~op_a_i, 1'b0} : op_a_i));
	assign lzc_b_input = (opcode_i[0] & op_b_sign ? ~op_b_i : op_b_i);
	lzc #(
		.MODE(1),
		.WIDTH(WIDTH)
	) i_lzc_a(
		.in_i(lzc_a_input),
		.cnt_o(lzc_a_result),
		.empty_o(lzc_a_no_one)
	);
	lzc #(
		.MODE(1),
		.WIDTH(WIDTH)
	) i_lzc_b(
		.in_i(lzc_b_input),
		.cnt_o(lzc_b_result),
		.empty_o(lzc_b_no_one)
	);
	assign shift_a = (lzc_a_no_one ? WIDTH : lzc_a_result);
	assign div_shift = (lzc_b_no_one ? WIDTH : lzc_b_result - shift_a);
	assign op_b = op_b_i <<< $unsigned(div_shift);
	assign div_res_zero_d = (load_en ? $signed(div_shift) < 0 : div_res_zero_q);
	assign pm_sel = load_en & ~(opcode_i[0] & (op_a_sign ^ op_b_sign));
	assign add_mux = (load_en ? op_a_i : op_b_q);
	assign b_mux = (load_en ? op_b : {comp_inv_q, op_b_q[WIDTH - 1:1]});
	assign out_mux = (rem_sel_q ? op_a_q : res_q);
	assign res_o = (res_inv_q ? -$signed(out_mux) : out_mux);
	assign ab_comp = ((op_a_q == op_b_q) | ((op_a_q > op_b_q) ^ comp_inv_q)) & (|op_a_q | op_b_zero_q);
	assign add_tmp = (load_en ? 0 : op_a_q);
	assign add_out = (pm_sel ? add_tmp + add_mux : add_tmp - $signed(add_mux));
	assign cnt_zero = cnt_q == 0;
	assign cnt_d = (load_en ? div_shift : (~cnt_zero ? cnt_q - 1 : cnt_q));
	always @(*) begin : p_fsm
		state_d = state_q;
		in_rdy_o = 1'b0;
		out_vld_o = 1'b0;
		load_en = 1'b0;
		a_reg_en = 1'b0;
		b_reg_en = 1'b0;
		res_reg_en = 1'b0;
		case (state_q)
			2'd0: begin
				in_rdy_o = 1'b1;
				if (in_vld_i) begin
					in_rdy_o = 1'b0;
					a_reg_en = 1'b1;
					b_reg_en = 1'b1;
					load_en = 1'b1;
					state_d = 2'd1;
				end
			end
			2'd1: begin
				if (~div_res_zero_q) begin
					a_reg_en = ab_comp;
					b_reg_en = 1'b1;
					res_reg_en = 1'b1;
				end
				if (div_res_zero_q) begin
					out_vld_o = 1'b1;
					state_d = 2'd2;
					if (out_rdy_i)
						state_d = 2'd0;
				end
				else if (cnt_zero)
					state_d = 2'd2;
			end
			2'd2: begin
				out_vld_o = 1'b1;
				if (out_rdy_i)
					state_d = 2'd0;
			end
			default: state_d = 2'd0;
		endcase
		if (flush_i) begin
			in_rdy_o = 1'b0;
			out_vld_o = 1'b0;
			a_reg_en = 1'b0;
			b_reg_en = 1'b0;
			load_en = 1'b0;
			state_d = 2'd0;
		end
	end
	assign rem_sel_d = (load_en ? opcode_i[1] : rem_sel_q);
	assign comp_inv_d = (load_en ? opcode_i[0] & op_b_sign : comp_inv_q);
	assign op_b_zero_d = (load_en ? op_b_zero : op_b_zero_q);
	assign res_inv_d = (load_en ? ((~op_b_zero | opcode_i[1]) & opcode_i[0]) & (op_a_sign ^ op_b_sign) : res_inv_q);
	assign id_d = (load_en ? id_i : id_q);
	assign id_o = id_q;
	assign op_a_d = (a_reg_en ? add_out : op_a_q);
	assign op_b_d = (b_reg_en ? b_mux : op_b_q);
	assign res_d = (load_en ? {WIDTH {1'sb0}} : (res_reg_en ? {res_q[WIDTH - 2:0], ab_comp} : res_q));
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (~rst_ni) begin
			state_q <= 2'd0;
			op_a_q <= 1'sb0;
			op_b_q <= 1'sb0;
			res_q <= 1'sb0;
			cnt_q <= 1'sb0;
			id_q <= 1'sb0;
			rem_sel_q <= 1'b0;
			comp_inv_q <= 1'b0;
			res_inv_q <= 1'b0;
			op_b_zero_q <= 1'b0;
			div_res_zero_q <= 1'b0;
		end
		else begin
			state_q <= state_d;
			op_a_q <= op_a_d;
			op_b_q <= op_b_d;
			res_q <= res_d;
			cnt_q <= cnt_d;
			id_q <= id_d;
			rem_sel_q <= rem_sel_d;
			comp_inv_q <= comp_inv_d;
			res_inv_q <= res_inv_d;
			op_b_zero_q <= op_b_zero_d;
			div_res_zero_q <= div_res_zero_d;
		end
	end
endmodule
module store_buffer (
	clk_i,
	rst_ni,
	flush_i,
	no_st_pending_o,
	store_buffer_empty_o,
	page_offset_i,
	page_offset_matches_o,
	commit_i,
	commit_ready_o,
	ready_o,
	valid_i,
	valid_without_flush_i,
	paddr_i,
	data_i,
	be_i,
	data_size_i,
	req_port_i,
	req_port_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	output reg no_st_pending_o;
	output wire store_buffer_empty_o;
	input wire [11:0] page_offset_i;
	output reg page_offset_matches_o;
	input wire commit_i;
	output reg commit_ready_o;
	output reg ready_o;
	input wire valid_i;
	input wire valid_without_flush_i;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_PLEN = 34;
	input wire [33:0] paddr_i;
	input wire [31:0] data_i;
	input wire [3:0] be_i;
	input wire [1:0] data_size_i;
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
	localparam [31:0] ariane_pkg_DEPTH_SPEC = 4;
	reg [291:0] speculative_queue_n;
	reg [291:0] speculative_queue_q;
	localparam [31:0] ariane_pkg_DEPTH_COMMIT = 8;
	reg [583:0] commit_queue_n;
	reg [583:0] commit_queue_q;
	reg [2:0] speculative_status_cnt_n;
	reg [2:0] speculative_status_cnt_q;
	reg [3:0] commit_status_cnt_n;
	reg [3:0] commit_status_cnt_q;
	reg [1:0] speculative_read_pointer_n;
	reg [1:0] speculative_read_pointer_q;
	reg [1:0] speculative_write_pointer_n;
	reg [1:0] speculative_write_pointer_q;
	reg [2:0] commit_read_pointer_n;
	reg [2:0] commit_read_pointer_q;
	reg [2:0] commit_write_pointer_n;
	reg [2:0] commit_write_pointer_q;
	assign store_buffer_empty_o = (speculative_status_cnt_q == 0) & no_st_pending_o;
	always @(*) begin : core_if
		reg [ariane_pkg_DEPTH_SPEC:0] speculative_status_cnt;
		speculative_status_cnt = speculative_status_cnt_q;
		ready_o = (speculative_status_cnt_q < 3) || commit_i;
		speculative_status_cnt_n = speculative_status_cnt_q;
		speculative_read_pointer_n = speculative_read_pointer_q;
		speculative_write_pointer_n = speculative_write_pointer_q;
		speculative_queue_n = speculative_queue_q;
		if (valid_i) begin
			speculative_queue_n[(speculative_write_pointer_q * 73) + 72-:34] = paddr_i;
			speculative_queue_n[(speculative_write_pointer_q * 73) + 38-:32] = data_i;
			speculative_queue_n[(speculative_write_pointer_q * 73) + 6-:4] = be_i;
			speculative_queue_n[(speculative_write_pointer_q * 73) + 2-:2] = data_size_i;
			speculative_queue_n[(speculative_write_pointer_q * 73) + 0] = 1'b1;
			speculative_write_pointer_n = speculative_write_pointer_q + 1'b1;
			speculative_status_cnt = speculative_status_cnt + 1;
		end
		if (commit_i) begin
			speculative_queue_n[(speculative_read_pointer_q * 73) + 0] = 1'b0;
			speculative_read_pointer_n = speculative_read_pointer_q + 1'b1;
			speculative_status_cnt = speculative_status_cnt - 1;
		end
		speculative_status_cnt_n = speculative_status_cnt;
		if (flush_i) begin
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < ariane_pkg_DEPTH_SPEC; i = i + 1)
					speculative_queue_n[(i * 73) + 0] = 1'b0;
			end
			speculative_write_pointer_n = speculative_read_pointer_q;
			speculative_status_cnt_n = 'b0;
		end
	end
	wire [1:1] sv2v_tmp_A682E;
	assign sv2v_tmp_A682E = 1'b0;
	always @(*) req_port_o[1] = sv2v_tmp_A682E;
	wire [1:1] sv2v_tmp_80AC7;
	assign sv2v_tmp_80AC7 = 1'b1;
	always @(*) req_port_o[8] = sv2v_tmp_80AC7;
	wire [1:1] sv2v_tmp_F170F;
	assign sv2v_tmp_F170F = 1'b0;
	always @(*) req_port_o[0] = sv2v_tmp_F170F;
	wire [((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1) * 1:1] sv2v_tmp_9099D;
	assign sv2v_tmp_9099D = commit_queue_q[(commit_read_pointer_q * 73) + ((38 + ariane_pkg_DCACHE_INDEX_WIDTH) >= 39 ? 38 + ariane_pkg_DCACHE_INDEX_WIDTH : ((38 + ariane_pkg_DCACHE_INDEX_WIDTH) + ((38 + ariane_pkg_DCACHE_INDEX_WIDTH) >= 39 ? (38 + ariane_pkg_DCACHE_INDEX_WIDTH) - 38 : (34 - ariane_pkg_DCACHE_INDEX_WIDTH) - 32)) - 1)-:((38 + ariane_pkg_DCACHE_INDEX_WIDTH) >= 39 ? (38 + ariane_pkg_DCACHE_INDEX_WIDTH) - 38 : (34 - ariane_pkg_DCACHE_INDEX_WIDTH) - 32)];
	always @(*) req_port_o[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)] = sv2v_tmp_9099D;
	wire [((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42)) * 1:1] sv2v_tmp_71805;
	assign sv2v_tmp_71805 = commit_queue_q[(commit_read_pointer_q * 73) + ((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) >= (39 + ariane_pkg_DCACHE_INDEX_WIDTH) ? 38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH) : ((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) + ((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) >= (39 + ariane_pkg_DCACHE_INDEX_WIDTH) ? ((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) - (39 + ariane_pkg_DCACHE_INDEX_WIDTH)) + 1 : ((39 + ariane_pkg_DCACHE_INDEX_WIDTH) - (38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH))) + 1)) - 1)-:((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) >= (39 + ariane_pkg_DCACHE_INDEX_WIDTH) ? ((38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH)) - (39 + ariane_pkg_DCACHE_INDEX_WIDTH)) + 1 : ((39 + ariane_pkg_DCACHE_INDEX_WIDTH) - (38 + (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_INDEX_WIDTH))) + 1)];
	always @(*) req_port_o[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))] = sv2v_tmp_71805;
	wire [32:1] sv2v_tmp_6B7F3;
	assign sv2v_tmp_6B7F3 = commit_queue_q[(commit_read_pointer_q * 73) + 38-:32];
	always @(*) req_port_o[42-:32] = sv2v_tmp_6B7F3;
	wire [4:1] sv2v_tmp_8DCF7;
	assign sv2v_tmp_8DCF7 = commit_queue_q[(commit_read_pointer_q * 73) + 6-:4];
	always @(*) req_port_o[7-:4] = sv2v_tmp_8DCF7;
	wire [2:1] sv2v_tmp_51F0D;
	assign sv2v_tmp_51F0D = commit_queue_q[(commit_read_pointer_q * 73) + 2-:2];
	always @(*) req_port_o[3-:2] = sv2v_tmp_51F0D;
	always @(*) begin : store_if
		reg [ariane_pkg_DEPTH_COMMIT:0] commit_status_cnt;
		commit_status_cnt = commit_status_cnt_q;
		commit_ready_o = commit_status_cnt_q < ariane_pkg_DEPTH_COMMIT;
		no_st_pending_o = commit_status_cnt_q == 0;
		commit_read_pointer_n = commit_read_pointer_q;
		commit_write_pointer_n = commit_write_pointer_q;
		commit_queue_n = commit_queue_q;
		req_port_o[9] = 1'b0;
		if (commit_queue_q[(commit_read_pointer_q * 73) + 0]) begin
			req_port_o[9] = 1'b1;
			if (req_port_i[34]) begin
				commit_queue_n[(commit_read_pointer_q * 73) + 0] = 1'b0;
				commit_read_pointer_n = commit_read_pointer_q + 1'b1;
				commit_status_cnt = commit_status_cnt - 1;
			end
		end
		if (commit_i) begin
			commit_queue_n[0 + (commit_write_pointer_q * 73)+:73] = speculative_queue_q[0 + (speculative_read_pointer_q * 73)+:73];
			commit_write_pointer_n = commit_write_pointer_n + 1'b1;
			commit_status_cnt = commit_status_cnt + 1;
		end
		commit_status_cnt_n = commit_status_cnt;
	end
	always @(*) begin : sv2v_autoblock_2
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		begin : address_checker
			page_offset_matches_o = 1'b0;
			begin : sv2v_autoblock_3
				reg [31:0] i;
				begin : sv2v_autoblock_4
					reg [31:0] _sv2v_value_on_break;
					for (i = 0; i < ariane_pkg_DEPTH_COMMIT; i = i + 1)
						if (_sv2v_jump < 2'b10) begin
							_sv2v_jump = 2'b00;
							if ((page_offset_i[11:3] == commit_queue_q[(i * 73) + 50-:9]) && commit_queue_q[(i * 73) + 0]) begin
								page_offset_matches_o = 1'b1;
								_sv2v_jump = 2'b10;
							end
							_sv2v_value_on_break = i;
						end
					if (!(_sv2v_jump < 2'b10))
						i = _sv2v_value_on_break;
					if (_sv2v_jump != 2'b11)
						_sv2v_jump = 2'b00;
				end
			end
			if (_sv2v_jump == 2'b00) begin
				begin : sv2v_autoblock_5
					reg [31:0] i;
					begin : sv2v_autoblock_6
						reg [31:0] _sv2v_value_on_break;
						for (i = 0; i < ariane_pkg_DEPTH_SPEC; i = i + 1)
							if (_sv2v_jump < 2'b10) begin
								_sv2v_jump = 2'b00;
								if ((page_offset_i[11:3] == speculative_queue_q[(i * 73) + 50-:9]) && speculative_queue_q[(i * 73) + 0]) begin
									page_offset_matches_o = 1'b1;
									_sv2v_jump = 2'b10;
								end
								_sv2v_value_on_break = i;
							end
						if (!(_sv2v_jump < 2'b10))
							i = _sv2v_value_on_break;
						if (_sv2v_jump != 2'b11)
							_sv2v_jump = 2'b00;
					end
				end
				if (_sv2v_jump == 2'b00)
					if ((page_offset_i[11:3] == paddr_i[11:3]) && valid_without_flush_i)
						page_offset_matches_o = 1'b1;
			end
		end
	end
	function automatic [72:0] sv2v_cast_79500;
		input reg [72:0] inp;
		sv2v_cast_79500 = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni) begin : p_spec
		if (~rst_ni) begin
			speculative_queue_q <= {ariane_pkg_DEPTH_SPEC {sv2v_cast_79500(0)}};
			speculative_read_pointer_q <= 1'sb0;
			speculative_write_pointer_q <= 1'sb0;
			speculative_status_cnt_q <= 1'sb0;
		end
		else begin
			speculative_queue_q <= speculative_queue_n;
			speculative_read_pointer_q <= speculative_read_pointer_n;
			speculative_write_pointer_q <= speculative_write_pointer_n;
			speculative_status_cnt_q <= speculative_status_cnt_n;
		end
	end
	always @(posedge clk_i or negedge rst_ni) begin : p_commit
		if (~rst_ni) begin
			commit_queue_q <= {ariane_pkg_DEPTH_COMMIT {sv2v_cast_79500(0)}};
			commit_read_pointer_q <= 1'sb0;
			commit_write_pointer_q <= 1'sb0;
			commit_status_cnt_q <= 1'sb0;
		end
		else begin
			commit_queue_q <= commit_queue_n;
			commit_read_pointer_q <= commit_read_pointer_n;
			commit_write_pointer_q <= commit_write_pointer_n;
			commit_status_cnt_q <= commit_status_cnt_n;
		end
	end
endmodule
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
	assign st_ready = store_buffer_ready & amo_buffer_ready;
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
