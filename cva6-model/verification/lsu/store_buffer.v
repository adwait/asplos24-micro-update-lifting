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
`ifdef EXPOSE_STATE
	, state_q_0
	, state_q_1
	, state_q_2
	, state_q_3
`endif
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
	localparam [31:0] ariane_pkg_DEPTH_COMMIT = 4;
	reg [291:0] commit_queue_n;
	reg [291:0] commit_queue_q;
	reg [2:0] speculative_status_cnt_n;
	reg [2:0] speculative_status_cnt_q;
	reg [2:0] commit_status_cnt_n;
	reg [2:0] commit_status_cnt_q;
	reg [1:0] speculative_read_pointer_n;
	reg [1:0] speculative_read_pointer_q;
	reg [1:0] speculative_write_pointer_n;
	reg [1:0] speculative_write_pointer_q;
	reg [1:0] commit_read_pointer_n;
	reg [1:0] commit_read_pointer_q;
	reg [1:0] commit_write_pointer_n;
	reg [1:0] commit_write_pointer_q;
	assign store_buffer_empty_o = (speculative_status_cnt_q == 0) & no_st_pending_o;

	output wire [1:0] state_q_0;
	assign state_q_0 = {speculative_queue_q[0], (speculative_queue_q[0] || commit_queue_q[0])};
	output wire [1:0] state_q_1;
	assign state_q_1 = {speculative_queue_q[73], (speculative_queue_q[73] || commit_queue_q[73])};
	output wire [1:0] state_q_2;
	assign state_q_2 = {speculative_queue_q[146], (speculative_queue_q[146] || commit_queue_q[146])};
	output wire [1:0] state_q_3;
	assign state_q_3 = {speculative_queue_q[219], (speculative_queue_q[219] || commit_queue_q[219])};

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
