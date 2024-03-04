
`define INSTR_QUEUE_DEPTH 2
`define WBUF_DEPTH 8
`define WBUF_DEPTH_INDEX 3

module cva6_wbuffer_model (
    input wire clk_i,
    input wire rst_ni,
    input wire cache_en_i,
    output wire empty_o,
    output wire not_ni_o,
    input wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_i,
    output reg [34:0] req_port_o,
    input wire miss_ack_i,
    output wire [33:0] miss_paddr_o,
    output wire miss_req_o,
    output wire miss_we_o,
    output wire [31:0] miss_wdata_o,
    output wire [0:0] miss_wuser_o,
    output wire [7:0] miss_vld_bits_o,
    output wire miss_nc_o,
    output wire [2:0] miss_size_o,
    output wire [1:0] miss_id_o,
    input wire miss_rtrn_vld_i,
    input wire [1:0] miss_rtrn_id_i,
    output wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] rd_tag_o,
    output wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] rd_idx_o,
    output wire [3:0] rd_off_o,
    output wire rd_req_o,
    output wire rd_tag_only_o,
    input wire rd_ack_i,
    input wire [31:0] rd_data_i,
    input wire [7:0] rd_vld_bits_i,
    input wire [7:0] rd_hit_oh_i,
    input wire wr_cl_vld_i,
    input wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_cl_idx_i,
    output reg [7:0] wr_req_o,
    input wire wr_ack_i,
    output wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] wr_idx_o,
    output wire [3:0] wr_off_o,
    output wire [31:0] wr_data_o,
    output wire [3:0] wr_data_be_o,
    output wire [0:0] wr_user_o,
    output wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] wbuffer_data_o,
    output wire [135:0] tx_paddr_o,
    output wire [3:0] tx_vld_o,

	output wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] port_io_wbuffer_q,
    output wire [23:0] port_io_wbuffer_summary_q
`ifdef EXPOSE_STATE
	, input wire [2:0] write_ptr_i
	, input wire [2:0] redo_ptr_i
	, input wire [2:0] mem_ack_ptr_i
	, input wire [2:0] mem_resp_ptr_i
`endif
);

	localparam ariane_pkg_NrMaxRules = 16;
localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 
    6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = 12; // $clog2(32'd32768 / 32'd8);
localparam cva6_config_pkg_CVA6ConfigXlen = 32;
localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
localparam riscv_PLEN = 34;
localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
localparam ariane_pkg_DATA_USER_WIDTH = 1;
localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
localparam wt_cache_pkg_L15_TID_WIDTH = 2;
localparam wt_cache_pkg_CACHE_ID_WIDTH = wt_cache_pkg_L15_TID_WIDTH;
localparam [31:0] ariane_pkg_DCACHE_LINE_WIDTH = 128;
localparam wt_cache_pkg_DCACHE_OFFSET_WIDTH = 4;
localparam wt_cache_pkg_DCACHE_NUM_WORDS = 2 ** (ariane_pkg_DCACHE_INDEX_WIDTH - wt_cache_pkg_DCACHE_OFFSET_WIDTH);
localparam wt_cache_pkg_DCACHE_CL_IDX_WIDTH = 8; // $clog2(wt_cache_pkg_DCACHE_NUM_WORDS);
localparam wt_cache_pkg_DCACHE_WBUF_DEPTH = 8;
localparam riscv_XLEN_ALIGN_BYTES = 2;
localparam wt_cache_pkg_DCACHE_MAX_TX = 4;
localparam riscv_IS_XLEN64 = 1'b0;

	// We only care about the tags and the content (and only atomically changed stuff)
	// reg [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] wbuffer_q;


    // Summary only maintains the (dirty, valid, txnblock, checked) bits (per buffer entry)
    reg [2:0] wbuffer_summary_q [0:7];
    // wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] port_io_wbuffer_q;
	assign port_io_wbuffer_summary_q = {wbuffer_summary_q[7], wbuffer_summary_q[6], wbuffer_summary_q[5], wbuffer_summary_q[4], wbuffer_summary_q[3], wbuffer_summary_q[2], wbuffer_summary_q[1], wbuffer_summary_q[0]};

reg [2:0] wbuffer_summary_q_0;
reg [2:0] wbuffer_summary_q_1;
reg [2:0] wbuffer_summary_q_2;
reg [2:0] wbuffer_summary_q_3;
reg [2:0] wbuffer_summary_q_4;
reg [2:0] wbuffer_summary_q_5;
reg [2:0] wbuffer_summary_q_6;
reg [2:0] wbuffer_summary_q_7;

    reg inner_miss_rtrn_vld_i;

    // Instruction (input) queue
    // Core write request
	// reg [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] req_port_i_queue[0:`INSTR_QUEUE_DEPTH-1];
    // // Read acknowledgement (from cache)
	// reg rd_ack_i_queue [0:`INSTR_QUEUE_DEPTH-1];
    // // Write acknoweldgement (from memory)
	// reg miss_ack_i_queue [0:`INSTR_QUEUE_DEPTH-1];
	// // Write completion (from memory)
	// reg miss_rtrn_vld_i_queue [0:`INSTR_QUEUE_DEPTH-1];

    // Transactional triggers (one per buffer entry)
    wire synth__txn_rcv_write;
    wire synth__txn_ack_write;
    wire synth__txn_prop_write;
    wire synth__txn_clr_write;

    // Reception pointer
    wire [`WBUF_DEPTH_INDEX-1:0] write_ptr;
    // Way acknowledgement
    wire [`WBUF_DEPTH_INDEX-1:0] mem_ack_ptr;
    // Propagation pointer
    wire [`WBUF_DEPTH_INDEX-1:0] redo_ptr;
    // Clearing pointer
    wire [`WBUF_DEPTH_INDEX-1:0] mem_resp_ptr;

    assign write_ptr = write_ptr_i;
    assign redo_ptr = redo_ptr_i;
    assign mem_ack_ptr = mem_ack_ptr_i;
    assign mem_resp_ptr = mem_resp_ptr_i;

    wire replay;
    assign replay = (req_port_i[76:65] == prev_req[0][11:0] && prev_req[0][12]) ||
        (req_port_i[76:65] == prev_req[1][11:0] && prev_req[1][12]) ||
        (req_port_i[76:65] == prev_req[2][11:0] && prev_req[2][12]) ||
        (req_port_i[76:65] == prev_req[3][11:0] && prev_req[3][12]);

    // Write request from the core
    assign synth__txn_rcv_write = req_port_i[9] & !replay;
    // Read from cahce (for way)
    assign synth__txn_ack_write = miss_ack_i;
    // Write acknowledgement
    assign synth__txn_prop_write = req_port_i[9] && replay;
    // Clearing
    assign synth__txn_clr_write = inner_miss_rtrn_vld_i;


    reg [13:0] prev_req [0:3];
    reg [13:0] prev_req_0;
    reg [13:0] prev_req_1;
    reg [13:0] prev_req_2;
    reg [13:0] prev_req_3;

    always @(posedge clk_i ) begin
        if (!rst_ni) begin
            prev_req[0] = 0;
            prev_req[1] = 0;
            prev_req[2] = 0;
            prev_req[3] = 0;
            inner_miss_rtrn_vld_i = 1'b0;
        end else begin
            inner_miss_rtrn_vld_i = miss_rtrn_vld_i;
            if (req_port_i[9])
                if (prev_req[0][12] && prev_req[0][11:0] == req_port_i[76:65])
                    prev_req[0][13] = 1'b1;
                else if (prev_req[1][12] && prev_req[1][11:0] == req_port_i[76:65])
                    prev_req[1][13] = 1'b1;
                else if (prev_req[2][12] && prev_req[2][11:0] == req_port_i[76:65])
                    prev_req[2][13] = 1'b1;
                else if (prev_req[3][12] && prev_req[3][11:0] == req_port_i[76:65])
                    prev_req[3][13] = 1'b1;
                else if (!prev_req[0][12]) begin
                    prev_req[0][12] = 1'b1;
                    prev_req[0][11:0] = req_port_i[76:65];
                end else if (!prev_req[1][12]) begin
                    prev_req[1][12] = 1'b1;
                    prev_req[1][11:0] = req_port_i[76:65];
                end else if (!prev_req[2][12]) begin
                    prev_req[2][12] = 1'b1;
                    prev_req[2][11:0] = req_port_i[76:65];
                end else if (!prev_req[3][12]) begin
                    prev_req[3][12] = 1'b1;
                    prev_req[3][11:0] = req_port_i[76:65];
                end
        end
    end   

	always @(posedge clk_i) begin
		if (~rst_ni) begin
            
            wbuffer_summary_q[0] <= 0;
            wbuffer_summary_q[1] <= 0;
            wbuffer_summary_q[2] <= 0;
            wbuffer_summary_q[3] <= 0;
            wbuffer_summary_q[4] <= 0;
            wbuffer_summary_q[5] <= 0;
            wbuffer_summary_q[6] <= 0;
            wbuffer_summary_q[7] <= 0;
            
            // req_port_i_queue[0] <= 0;
            // rd_ack_i_queue[0] <= 0;
            // miss_ack_i_queue[0] <= 0;
            // miss_rtrn_vld_i_queue[0] <= 0;

		end else begin
            // req_port_i_queue[0] = req_port_i;
            // rd_ack_i_queue[0] = rd_ack_i;
            // miss_ack_i_queue[0] = miss_ack_i;
            // miss_rtrn_vld_i_queue[0] = miss_rtrn_vld_i;

            if (synth__txn_rcv_write) begin
                if (wbuffer_summary_q[write_ptr] == 3'b000)
                    wbuffer_summary_q[write_ptr] = 3'b110;
            end
            if (synth__txn_ack_write) begin
                if (wbuffer_summary_q[mem_ack_ptr] == 3'b110)
                    wbuffer_summary_q[mem_ack_ptr] = 3'b011;
            end
            if (synth__txn_prop_write) begin
                if (wbuffer_summary_q[redo_ptr] == 3'b011)
                    wbuffer_summary_q[redo_ptr] = 3'b111;
            end
            if (synth__txn_clr_write) begin
                if (wbuffer_summary_q[mem_resp_ptr] == 3'b011)
                    wbuffer_summary_q[mem_resp_ptr] = 3'b000;
                else if (wbuffer_summary_q[mem_resp_ptr] == 3'b111)
                    wbuffer_summary_q[mem_resp_ptr] = 3'b110;
            end
		end

        wbuffer_summary_q_0 = wbuffer_summary_q[0];
        wbuffer_summary_q_1 = wbuffer_summary_q[1];
        wbuffer_summary_q_2 = wbuffer_summary_q[2];
        wbuffer_summary_q_3 = wbuffer_summary_q[3];
        wbuffer_summary_q_4 = wbuffer_summary_q[4];
        wbuffer_summary_q_5 = wbuffer_summary_q[5];
        wbuffer_summary_q_6 = wbuffer_summary_q[6];
        wbuffer_summary_q_7 = wbuffer_summary_q[7];

        prev_req_0 = prev_req[0];
        prev_req_1 = prev_req[1];
        prev_req_2 = prev_req[2];
        prev_req_3 = prev_req[3];
	end
    
endmodule