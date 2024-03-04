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
	lu_hit_o,
	port_content_q_o,
	port_tags_q_o,
	port_replace_en_o
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

output wire [127:0] port_content_q_o;
assign port_content_q_o = content_q;
output wire [123:0] port_tags_q_o;
assign port_tags_q_o = tags_q;
output wire [TLB_ENTRIES-1:0] port_replace_en_o;
assign port_replace_en_o = replace_en;

wire [31:0] content_q_0;
wire [30:0] tags_q_0;
assign content_q_0 = content_q[0*32+31:0*32];
assign tags_q_0 = tags_q[0*31+30:0*31];
wire [31:0] content_q_1;
wire [30:0] tags_q_1;
assign content_q_1 = content_q[1*32+31:1*32];
assign tags_q_1 = tags_q[1*31+30:1*31];
wire [31:0] content_q_2;
wire [30:0] tags_q_2;
assign content_q_2 = content_q[2*32+31:2*32];
assign tags_q_2 = tags_q[2*31+30:2*31];
wire [31:0] content_q_3;
wire [30:0] tags_q_3;
assign content_q_3 = content_q[3*32+31:3*32];
assign tags_q_3 = tags_q[3*31+30:3*31];

wire [30:0] tdata;
assign tdata = update_i[31-:32];
wire [31:0] cdata;
assign cdata = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};

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
