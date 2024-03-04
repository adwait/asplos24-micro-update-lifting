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
