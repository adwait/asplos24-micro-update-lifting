module cache_ctrl (
	clk_i,
	rst_ni,
	flush_i,
	bypass_i,
	busy_o,
	req_port_i,
	req_port_o,
	req_o,
	addr_o,
	gnt_i,
	data_o,
	be_o,
	tag_o,
	data_i,
	we_o,
	hit_way_i,
	miss_req_o,
	miss_gnt_i,
	active_serving_i,
	critical_word_i,
	critical_word_valid_i,
	bypass_gnt_i,
	bypass_valid_i,
	bypass_data_i,
	mshr_addr_o,
	mshr_addr_matches_i,
	mshr_index_matches_i
);
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire bypass_i;
	output wire busy_o;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
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
	output reg [7:0] req_o;
	output reg [ariane_pkg_DCACHE_INDEX_WIDTH - 1:0] addr_o;
	input wire gnt_i;
	localparam [31:0] ariane_pkg_DCACHE_LINE_WIDTH = 128;
	output reg [(ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 1:0] data_o;
	output reg [((((ariane_pkg_DCACHE_TAG_WIDTH + 7) / 8) + 16) + ariane_pkg_DCACHE_SET_ASSOC) - 1:0] be_o;
	output wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] tag_o;
	input wire [((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? (ariane_pkg_DCACHE_SET_ASSOC * ((ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 2)) - 1 : (ariane_pkg_DCACHE_SET_ASSOC * (1 - ((ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 1))) + ((ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 0)):((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? 0 : (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 1)] data_i;
	output reg we_o;
	input wire [7:0] hit_way_i;
	output reg [140:0] miss_req_o;
	input wire miss_gnt_i;
	input wire active_serving_i;
	input wire [63:0] critical_word_i;
	input wire critical_word_valid_i;
	input wire bypass_gnt_i;
	input wire bypass_valid_i;
	input wire [63:0] bypass_data_i;
	output reg [55:0] mshr_addr_o;
	input wire mshr_addr_matches_i;
	input wire mshr_index_matches_i;
	reg [3:0] state_d;
	reg [3:0] state_q;
	reg [7:0] hit_way_d;
	reg [7:0] hit_way_q;
	reg [(ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 76:0] mem_req_d;
	reg [(ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 76:0] mem_req_q;
	assign busy_o = state_q != 4'd0;
	assign tag_o = mem_req_d[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))];
	reg [127:0] cl_i;
	always @(*) begin : way_select
		cl_i = 1'sb0;
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < ariane_pkg_DCACHE_SET_ASSOC; i = i + 1)
				if (hit_way_i[i])
					cl_i = data_i[((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? (i * ((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 2 : 1 - ((ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 1))) + ((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? 129 : (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) - 128) : ((i * ((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 2 : 1 - ((ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) + 1))) + ((ariane_pkg_DCACHE_TAG_WIDTH + 129) >= 0 ? 129 : (ariane_pkg_DCACHE_TAG_WIDTH + ariane_pkg_DCACHE_LINE_WIDTH) - 128)) + 127)-:128];
		end
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
	function automatic ariane_pkg_is_inside_cacheable_regions;
		input reg [6433:0] Cfg;
		input reg [63:0] address;
		reg [15:0] pass;
		begin
			pass = 1'sb0;
			begin : sv2v_autoblock_2
				reg [31:0] k;
				for (k = 0; k < Cfg[2177-:32]; k = k + 1)
					pass[k] = ariane_pkg_range_check(Cfg[1122 + (k * 64)+:64], Cfg[98 + (k * 64)+:64], address);
			end
			ariane_pkg_is_inside_cacheable_regions = |pass;
		end
	endfunction
	localparam std_cache_pkg_DCACHE_BYTE_OFFSET = 4;
	always @(*) begin : cache_ctrl_fsm
		reg [6:0] cl_offset;
		cl_offset = mem_req_q[(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_INDEX_WIDTH - 4):(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_INDEX_WIDTH - 4)] << 6;
		state_d = state_q;
		mem_req_d = mem_req_q;
		hit_way_d = hit_way_q;
		req_port_o[34] = 1'b0;
		req_port_o[33] = 1'b0;
		req_port_o[32-:32] = 1'sb0;
		miss_req_o = 1'sb0;
		mshr_addr_o = 1'sb0;
		req_o = 1'sb0;
		addr_o = req_port_i[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)];
		data_o = 1'sb0;
		be_o = 1'sb0;
		we_o = 1'sb0;
		mem_req_d[0] = mem_req_d[0] | req_port_i[1];
		case (state_q)
			4'd0:
				if (req_port_i[9] && !flush_i) begin
					req_o = 1'sb1;
					mem_req_d[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)] = req_port_i[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)];
					mem_req_d[76-:8] = req_port_i[7-:4];
					mem_req_d[68-:2] = req_port_i[3-:2];
					mem_req_d[66] = req_port_i[8];
					mem_req_d[65-:64] = req_port_i[42-:32];
					mem_req_d[0] = req_port_i[1];
					if (bypass_i) begin
						state_d = 4'd2;
						req_port_o[34] = (req_port_i[8] ? 1'b0 : 1'b1);
						mem_req_d[1] = 1'b1;
					end
					else if (gnt_i) begin
						state_d = 4'd1;
						mem_req_d[1] = 1'b0;
						if (!req_port_i[8])
							req_port_o[34] = 1'b1;
					end
				end
			4'd1, 4'd8:
				if (!req_port_i[1] && ((req_port_i[0] || (state_q == 4'd8)) || mem_req_q[66])) begin
					if (state_q != 4'd8)
						mem_req_d[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))] = req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))];
					if (req_port_i[9] && !flush_i)
						req_o = 1'sb1;
					if (|hit_way_i) begin
						if ((req_port_i[9] && !mem_req_q[66]) && !flush_i) begin
							state_d = 4'd1;
							mem_req_d[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)] = req_port_i[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)];
							mem_req_d[76-:8] = req_port_i[7-:4];
							mem_req_d[68-:2] = req_port_i[3-:2];
							mem_req_d[66] = req_port_i[8];
							mem_req_d[65-:64] = req_port_i[42-:32];
							mem_req_d[0] = req_port_i[1];
							mem_req_d[1] = 1'b0;
							req_port_o[34] = gnt_i;
							if (!gnt_i)
								state_d = 4'd0;
						end
						else
							state_d = 4'd0;
						case (mem_req_q[(ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_INDEX_WIDTH - 4)])
							1'b0: req_port_o[32-:32] = cl_i[63:0];
							1'b1: req_port_o[32-:32] = cl_i[127:64];
						endcase
						if (!mem_req_q[66])
							req_port_o[33] = ~mem_req_q[0];
						else begin
							state_d = 4'd5;
							hit_way_d = hit_way_i;
						end
					end
					else
						state_d = 4'd7;
					mshr_addr_o = {tag_o, mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)]};
					if ((mshr_index_matches_i && mem_req_q[66]) || mshr_addr_matches_i)
						state_d = 4'd9;
					if (!ariane_pkg_is_inside_cacheable_regions(ArianeCfg, {{'d30 {1'b0}}, tag_o, {ariane_pkg_DCACHE_INDEX_WIDTH {1'b0}}})) begin
						mem_req_d[1] = 1'b1;
						state_d = 4'd7;
					end
				end
				else begin
					addr_o = mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)];
					req_o = 1'sb1;
					if (!gnt_i)
						state_d = 4'd3;
				end
			4'd3, 4'd4: begin
				addr_o = mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)];
				req_o = 1'sb1;
				if (req_port_i[0]) begin
					mem_req_d[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))] = req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))];
					state_d = 4'd4;
				end
				if (gnt_i)
					state_d = (state_d == 4'd3 ? 4'd1 : 4'd8);
			end
			4'd5: begin
				mshr_addr_o = {mem_req_q[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))], mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)]};
				if (!mshr_index_matches_i) begin
					req_o = hit_way_q;
					addr_o = mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)];
					we_o = 1'b1;
					be_o[7-:ariane_pkg_DCACHE_SET_ASSOC] = hit_way_q;
					be_o[8 + (cl_offset >> 3)+:8] = mem_req_q[76-:8];
					data_o[2 + cl_offset+:64] = mem_req_q[65-:64];
					data_o[0] = 1'b1;
					data_o[1] = 1'b1;
					if (gnt_i) begin
						req_port_o[34] = 1'b1;
						state_d = 4'd0;
					end
				end
				else
					state_d = 4'd9;
			end
			4'd9: begin
				mshr_addr_o = {mem_req_q[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))], mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)]};
				if (!mshr_index_matches_i) begin
					req_o = 1'sb1;
					addr_o = mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)];
					if (gnt_i)
						state_d = 4'd8;
				end
			end
			4'd2:
				if (!req_port_i[1] && (req_port_i[0] || mem_req_q[66])) begin
					mem_req_d[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))] = req_port_i[ariane_pkg_DCACHE_TAG_WIDTH + 42-:((ariane_pkg_DCACHE_TAG_WIDTH + 42) >= 43 ? ariane_pkg_DCACHE_TAG_WIDTH : 44 - (ariane_pkg_DCACHE_TAG_WIDTH + 42))];
					state_d = 4'd7;
				end
			4'd7: begin
				mshr_addr_o = {mem_req_q[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))], mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)]};
				miss_req_o[140] = 1'b1;
				miss_req_o[0] = mem_req_q[1];
				miss_req_o[139-:64] = {mem_req_q[ariane_pkg_DCACHE_TAG_WIDTH + 76-:((ariane_pkg_DCACHE_TAG_WIDTH + 76) >= 77 ? ariane_pkg_DCACHE_TAG_WIDTH + 0 : 78 - (ariane_pkg_DCACHE_TAG_WIDTH + 76))], mem_req_q[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)]};
				miss_req_o[75-:8] = mem_req_q[76-:8];
				miss_req_o[67-:2] = mem_req_q[68-:2];
				miss_req_o[65] = mem_req_q[66];
				miss_req_o[64-:64] = mem_req_q[65-:64];
				if (bypass_gnt_i) begin
					state_d = 4'd6;
					if (mem_req_q[66])
						req_port_o[34] = 1'b1;
				end
				if (miss_gnt_i && !mem_req_q[66])
					state_d = 4'd10;
				else if (miss_gnt_i) begin
					state_d = 4'd0;
					req_port_o[34] = 1'b1;
				end
				if (mshr_addr_matches_i && !active_serving_i)
					state_d = 4'd9;
			end
			4'd10: begin
				if (req_port_i[9])
					req_o = 1'sb1;
				if (critical_word_valid_i) begin
					req_port_o[33] = ~mem_req_q[0];
					req_port_o[32-:32] = critical_word_i;
					if (req_port_i[9]) begin
						mem_req_d[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 77) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76)) - (ariane_pkg_DCACHE_TAG_WIDTH + 77)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 77) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 76))) + 1)] = req_port_i[ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)-:((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) >= (ariane_pkg_DCACHE_TAG_WIDTH + 43) ? ((ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42)) - (ariane_pkg_DCACHE_TAG_WIDTH + 43)) + 1 : ((ariane_pkg_DCACHE_TAG_WIDTH + 43) - (ariane_pkg_DCACHE_INDEX_WIDTH + (ariane_pkg_DCACHE_TAG_WIDTH + 42))) + 1)];
						mem_req_d[76-:8] = req_port_i[7-:4];
						mem_req_d[68-:2] = req_port_i[3-:2];
						mem_req_d[66] = req_port_i[8];
						mem_req_d[65-:64] = req_port_i[42-:32];
						mem_req_d[0] = req_port_i[1];
						state_d = 4'd0;
						if (gnt_i) begin
							state_d = 4'd1;
							mem_req_d[1] = 1'b0;
							req_port_o[34] = 1'b1;
						end
					end
					else
						state_d = 4'd0;
				end
			end
			4'd6:
				if (bypass_valid_i) begin
					req_port_o[32-:32] = bypass_data_i;
					req_port_o[33] = ~mem_req_q[0];
					state_d = 4'd0;
				end
		endcase
		if (req_port_i[1]) begin
			req_port_o[33] = 1'b1;
			if (!(|{state_q == 4'd7, state_q == 4'd10}))
				state_d = 4'd0;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 4'd0;
			mem_req_q <= 1'sb0;
			hit_way_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			mem_req_q <= mem_req_d;
			hit_way_q <= hit_way_d;
		end
endmodule
