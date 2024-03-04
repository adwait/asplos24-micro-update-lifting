

`define INSTR_QUEUE_DEPTH 1

module cva6_tlb_model (
    input clk_i,
	input rst_ni,
	input flush_i, 
	input wire [62:0] update_i, 
	input wire lu_access_i,
	input wire [ASID_WIDTH - 1:0] lu_asid_i,
	input wire [31:0] lu_vaddr_i,
	output reg [31:0] lu_content_o,
	input wire [ASID_WIDTH - 1:0] asid_to_be_flushed_i,
	input wire [31:0] vaddr_to_be_flushed_i,
	output reg lu_is_4M_o,
	output reg lu_hit_o,

	output [(TLB_ENTRIES * 31) - 1:0] port_io_tags_q,
	output [(TLB_ENTRIES * 32) - 1:0] port_io_content_q,
	input [TLB_ENTRIES-1:0] port_io_replace_en
);

	localparam [31:0] TLB_ENTRIES = 4;
	localparam [31:0] TLB_ENTRIES_WIDTH = 2;
	localparam [31:0] ASID_WIDTH = 1;
	
	// We only care about the tags and the content (and only atomically changed stuff)
	reg [(TLB_ENTRIES * 31) - 1:0] tags_q;
	wire [(TLB_ENTRIES * 31) - 1:0] port_io_tags_q;
	assign port_io_tags_q = tags_q;
	// reg [(TLB_ENTRIES * 31) - 1:0] tags_n;
	reg [(TLB_ENTRIES * 32) - 1:0] content_q;
	wire [(TLB_ENTRIES * 32) - 1:0] port_io_content_q;
	assign port_io_content_q = content_q;
	
	// Flushes
	reg flush_i_queue;
	reg [ASID_WIDTH-1:0] asid_to_be_flushed_i_queue;
	reg [31:0] vaddr_to_be_flushed_i_queue;
	// Updates
	reg [62:0] update_i_queue;

	// Don't want to model this precisely
	wire [TLB_ENTRIES-1:0] replace_en;
	// reg [TLB_ENTRIES_WIDTH-1:0] nxt_replace_en;
	assign replace_en = port_io_replace_en; // nxt_replace_en;

		reg synth__txn_flush_all;
		reg synth__txn_update;
		reg synth__txn_none;
		reg synth__txn_flush_one;

wire [32:0] content_q_0;
wire [31:0] tags_q_0;
assign content_q_0 = content_q[0*32+31:0*32];
assign tags_q_0 = tags_q[0*31+30:0*31];
wire [32:0] content_q_1;
wire [31:0] tags_q_1;
assign content_q_1 = content_q[1*32+31:1*32];
assign tags_q_1 = tags_q[1*31+30:1*31];
wire [32:0] content_q_2;
wire [31:0] tags_q_2;
assign content_q_2 = content_q[2*32+31:2*32];
assign tags_q_2 = tags_q[2*31+30:2*31];
wire [32:0] content_q_3;
wire [31:0] tags_q_3;
assign content_q_3 = content_q[3*32+31:3*32];
assign tags_q_3 = tags_q[3*31+30:3*31];


	always @(posedge clk_i or negedge rst_ni) begin
		// nxt_replace_en = $random;
		if (~rst_ni) begin
			tags_q      <= 0;
			content_q   <= 0;

flush_i_queue <= 0;
asid_to_be_flushed_i_queue <= 0;
vaddr_to_be_flushed_i_queue <= 0;
update_i_queue <= 0;

		end else begin

flush_i_queue = flush_i;
asid_to_be_flushed_i_queue = asid_to_be_flushed_i;
vaddr_to_be_flushed_i_queue = vaddr_to_be_flushed_i;
update_i_queue = update_i;


			synth__txn_flush_all = flush_i_queue && (asid_to_be_flushed_i_queue == 0) && (vaddr_to_be_flushed_i_queue == 0);
			synth__txn_update = !(flush_i_queue) && update_i_queue[62];
			synth__txn_none = !(synth__txn_flush_all || synth__txn_update);
			synth__txn_flush_one = 0;


			if (synth__txn_flush_all) begin	
				tags_q[0 * 31] = 1'b0;
				tags_q[1 * 31] = 1'b0;
				tags_q[2 * 31] = 1'b0;
				tags_q[3 * 31] = 1'b0;
			end
			
			if (synth__txn_update) begin
				case (replace_en)
		4'b0001: begin
			tags_q[0*31+:31] = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};
			content_q[0*32+:32] = update_i[31-:32];
		end
		4'b0010: begin
			tags_q[1*31+:31] = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};
			content_q[1*32+:32] = update_i[31-:32];
		end
		4'b0100: begin
			tags_q[2*31+:31] = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};
			content_q[2*32+:32] = update_i[31-:32];
		end
		4'b1000: begin
			tags_q[3*31+:31] = {update_i[40-:9], update_i[60:51], update_i[50:41], update_i[61], 1'b1};
			content_q[3*32+:32] = update_i[31-:32];
		end
					// default: 
				endcase
			end

			if (synth__txn_flush_one) begin
				case (replace_en)
		4'b0001: begin
			tags_q[0*31] = 1'b0;
		end
		4'b0010: begin
			tags_q[1*31] = 1'b0;
		end
		4'b0100: begin
			tags_q[2*31] = 1'b0;
		end
		4'b1000: begin
			tags_q[3*31] = 1'b0;
		end
					// default: 
				endcase
				
			end

			if (synth__txn_none) begin
				tags_q = tags_q;
				content_q = content_q;
			end
		end
		
	end
    
endmodule