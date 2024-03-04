

    module wbuffer_tb (
        input clk
    );

        reg reset;
        reg [7:0] counter;
        reg init;

        initial begin
            reset = 0;
            counter = 0;
            init = 1;
        end


localparam ariane_pkg_NrMaxRules = 16;
localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 
    6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
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
localparam wt_cache_pkg_L15_TID_WIDTH = 2;
localparam wt_cache_pkg_CACHE_ID_WIDTH = wt_cache_pkg_L15_TID_WIDTH;
localparam [31:0] ariane_pkg_DCACHE_LINE_WIDTH = 128;
localparam wt_cache_pkg_DCACHE_OFFSET_WIDTH = 4;
localparam wt_cache_pkg_DCACHE_NUM_WORDS = 2 ** (ariane_pkg_DCACHE_INDEX_WIDTH - wt_cache_pkg_DCACHE_OFFSET_WIDTH);
localparam wt_cache_pkg_DCACHE_CL_IDX_WIDTH = $clog2(wt_cache_pkg_DCACHE_NUM_WORDS);
localparam wt_cache_pkg_DCACHE_WBUF_DEPTH = 8;
localparam riscv_XLEN_ALIGN_BYTES = 2;
localparam wt_cache_pkg_DCACHE_MAX_TX = 4;
localparam riscv_IS_XLEN64 = 1'b0;


        // CSR tasks
        task mem_miss_ack;
            tb_io_miss_ack_i <= 1;
        endtask
        task mem_miss_lower;
            tb_io_miss_ack_i <= 0;
        endtask
        // Response from the cache specifying the cache way
        task cache_rd_resp (input [ariane_pkg_DCACHE_SET_ASSOC-1:0] way);
            tb_io_rd_ack_i <= 1;
            tb_io_rd_hit_oh_i <= way;
        endtask
        task cache_lower_resp;
            tb_io_rd_ack_i <= 0;
        endtask
        // Request from the core asking for a write request (a new transaction)
        task core_wr_req (
            input [ariane_pkg_DCACHE_INDEX_WIDTH-1:0] address_index,
            input [ariane_pkg_DCACHE_TAG_WIDTH-1:0]   address_tag,
            input [31:0]                   data_wdata
            // ,
            // input [DCACHE_USER_WIDTH-1:0]  data_wuser,
            // input                          data_req,
            // input                          data_we,
            // input [(riscv::XLEN/8)-1:0]    data_be,
            // input [1:0]                    data_size,
            // input                          kill_req,
            // input                          tag_valid
        );
            tb_io_req_port_i <= {
                address_index, address_tag, data_wdata, 1'd0, 1'd1, 1'd0, 4'd15, 2'd0, 1'd0, 1'd0
            };
        endtask
        task core_lower_req;
            tb_io_req_port_i <= 0;
        endtask
        task mem_resp_ack (input [wt_cache_pkg_CACHE_ID_WIDTH-1:0] txn_id);
            tb_io_miss_rtrn_vld_i <= 1;
            tb_io_miss_rtrn_id_i <= txn_id;
        endtask
        task mem_resp_lower;
            tb_io_miss_rtrn_vld_i <= 0;
        endtask



// Unused
wire de_io_cache_en_i;
wire mo_io_cache_en_i;
reg tb_io_cache_en_i;
assign de_io_cache_en_i = 0; // tb_io_cache_en_i;
assign mo_io_cache_en_i = 0; // tb_io_cache_en_i;

wire de_io_empty_o;
wire mo_io_empty_o;
wire de_io_not_ni_o;
wire mo_io_not_ni_o;

wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] de_io_req_port_i;
wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] mo_io_req_port_i;
reg [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] tb_io_req_port_i;
assign de_io_req_port_i = tb_io_req_port_i;
assign mo_io_req_port_i = tb_io_req_port_i;

reg [34:0] de_io_req_port_o;
reg [34:0] mo_io_req_port_o;
// Ack from the miss handler (for signalling a received write request)
wire de_io_miss_ack_i;
wire mo_io_miss_ack_i;
reg tb_io_miss_ack_i;
assign de_io_miss_ack_i = tb_io_miss_ack_i;
assign mo_io_miss_ack_i = tb_io_miss_ack_i;

wire [33:0] de_io_miss_paddr_o;
wire [33:0] mo_io_miss_paddr_o;
wire de_io_miss_req_o;
wire mo_io_miss_req_o;
wire de_io_miss_we_o;
wire mo_io_miss_we_o;
wire [31:0] de_io_miss_wdata_o;
wire [31:0] mo_io_miss_wdata_o;
wire [0:0] de_io_miss_wuser_o;
wire [0:0] mo_io_miss_wuser_o;
wire [7:0] de_io_miss_vld_bits_o;
wire [7:0] mo_io_miss_vld_bits_o;
wire de_io_miss_nc_o;
wire mo_io_miss_nc_o;
wire [2:0] de_io_miss_size_o;
wire [2:0] mo_io_miss_size_o;
wire [1:0] de_io_miss_id_o;
wire [1:0] mo_io_miss_id_o;

wire de_io_miss_rtrn_vld_i;
wire mo_io_miss_rtrn_vld_i;
reg tb_io_miss_rtrn_vld_i;
assign de_io_miss_rtrn_vld_i = tb_io_miss_rtrn_vld_i;
assign mo_io_miss_rtrn_vld_i = tb_io_miss_rtrn_vld_i;
wire [1:0] de_io_miss_rtrn_id_i;
wire [1:0] mo_io_miss_rtrn_id_i;
reg [1:0] tb_io_miss_rtrn_id_i;
assign de_io_miss_rtrn_id_i = tb_io_miss_rtrn_id_i;
assign mo_io_miss_rtrn_id_i = tb_io_miss_rtrn_id_i;

wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] de_io_rd_tag_o;
wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] mo_io_rd_tag_o;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_rd_idx_o;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] mo_io_rd_idx_o;
wire [3:0] de_io_rd_off_o;
wire [3:0] mo_io_rd_off_o;
wire de_io_rd_req_o;
wire mo_io_rd_req_o;
wire de_io_rd_tag_only_o;
wire mo_io_rd_tag_only_o;

wire de_io_rd_ack_i;
wire mo_io_rd_ack_i;
reg tb_io_rd_ack_i;
assign de_io_rd_ack_i = tb_io_rd_ack_i;
assign mo_io_rd_ack_i = tb_io_rd_ack_i;
// Unused
wire [31:0] de_io_rd_data_i;
wire [31:0] mo_io_rd_data_i;
reg [31:0] tb_io_rd_data_i;
assign de_io_rd_data_i = 0; // tb_io_rd_data_i;
assign mo_io_rd_data_i = 0; // tb_io_rd_data_i;

// Unused
wire [7:0] de_io_rd_vld_bits_i;
wire [7:0] mo_io_rd_vld_bits_i;
reg [7:0] tb_io_rd_vld_bits_i;
assign de_io_rd_vld_bits_i = 0; // tb_io_rd_vld_bits_i;
assign mo_io_rd_vld_bits_i = 0; // tb_io_rd_vld_bits_i;

wire [7:0] de_io_rd_hit_oh_i;
wire [7:0] mo_io_rd_hit_oh_i;
reg [7:0] tb_io_rd_hit_oh_i;
assign de_io_rd_hit_oh_i = tb_io_rd_hit_oh_i;
assign mo_io_rd_hit_oh_i = tb_io_rd_hit_oh_i;

// Assume: no cacheline writes
wire de_io_wr_cl_vld_i;
wire mo_io_wr_cl_vld_i;
reg tb_io_wr_cl_vld_i;
assign de_io_wr_cl_vld_i = 0; // tb_io_wr_cl_vld_i;
assign mo_io_wr_cl_vld_i = 0; // tb_io_wr_cl_vld_i;

// Assume: no cacheline writes
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_wr_cl_idx_i;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] mo_io_wr_cl_idx_i;
reg [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] tb_io_wr_cl_idx_i;
assign de_io_wr_cl_idx_i = 0; // tb_io_wr_cl_idx_i;
assign mo_io_wr_cl_idx_i = 0; // tb_io_wr_cl_idx_i;

reg [7:0] de_io_wr_req_o;
reg [7:0] mo_io_wr_req_o;

// Assume: writes are acked immediately
wire de_io_wr_ack_i;
wire mo_io_wr_ack_i;
reg tb_io_wr_ack_i;
assign de_io_wr_ack_i = 1; // tb_io_wr_ack_i;
assign mo_io_wr_ack_i = 1; // tb_io_wr_ack_i;

wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_wr_idx_o;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] mo_io_wr_idx_o;
wire [3:0] de_io_wr_off_o;
wire [3:0] mo_io_wr_off_o;
wire [31:0] de_io_wr_data_o;
wire [31:0] mo_io_wr_data_o;
wire [3:0] de_io_wr_data_be_o;
wire [3:0] mo_io_wr_data_be_o;
wire [0:0] de_io_wr_user_o;
wire [0:0] mo_io_wr_user_o;
wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] de_io_wbuffer_data_o;
wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] mo_io_wbuffer_data_o;
wire [135:0] de_io_tx_paddr_o;
wire [135:0] mo_io_tx_paddr_o;
wire [3:0] de_io_tx_vld_o;
wire [3:0] mo_io_tx_vld_o;

wire [31:0] mo_io_port_io_wbuffer_summary_q;

wire [31:0] de_io_tx_stat_data_o;

task get_header;
    $display("| pktid | wtag     | data     | user | dirty | valid | txblock | ckd | hit_oh |");
    $display("|=======|==========|==========|======|=======|=======|=========|=====|========|");
endtask

task get_buffer_entry (input [85:0] entry);
    $display("| %d    | %x | %x | %x    | %x     | %x     | %x       | %x   | %x     |", 4'd0, entry[85:54], entry[53:22], entry[21:21], entry[20:17], entry[16:13], entry[12:9], entry[8], entry[7:0]);
endtask
task get_buffer_entries;
`ifdef DEBUGPRINT
    display_time();
    get_header();
    get_buffer_entry(de_io_wbuffer_data_o[86*0+85:86*0]);
    get_buffer_entry(de_io_wbuffer_data_o[86*1+85:86*1]);
    get_buffer_entry(de_io_wbuffer_data_o[86*2+85:86*2]);
    get_buffer_entry(de_io_wbuffer_data_o[86*3+85:86*3]);
    get_buffer_entry(de_io_wbuffer_data_o[86*4+85:86*4]);
    get_buffer_entry(de_io_wbuffer_data_o[86*5+85:86*5]);
    get_buffer_entry(de_io_wbuffer_data_o[86*6+85:86*6]);
    get_buffer_entry(de_io_wbuffer_data_o[86*7+85:86*7]);
    // $display(de_io_miss_size_o);
`endif
endtask

task get_txn_header;
    $display("| txnid | vld | be | ptr |");
    $display("|=======|=====|====|=====|");
endtask

task get_txn_stat (input [7:0] entry);
    $display("| %d    | %x   | %x  | %b |", 4'd0, entry[7], entry[6:3], entry[2:0]);
endtask

task get_txn_stats;
    get_txn_header();
    get_txn_stat(de_io_tx_stat_data_o[8*0+7:8*0]);
    get_txn_stat(de_io_tx_stat_data_o[8*1+7:8*1]);
    get_txn_stat(de_io_tx_stat_data_o[8*2+7:8*2]);
    get_txn_stat(de_io_tx_stat_data_o[8*3+7:8*3]);
endtask

task make_write_request(
    input [ariane_pkg_DCACHE_INDEX_WIDTH-1:0] addr,
    input [ariane_pkg_DCACHE_TAG_WIDTH-1:0] tag,
    input [31:0] data

);
    // $display("make_write_request step 0");
    core_wr_req(addr, tag, data);
    #20;
    cache_rd_resp(4);
    // $display("make_write_request step 1");
    core_lower_req();
    #20
    cache_lower_resp();
    #20;
endtask

task make_cache_way_resp(input [2:0] way);
    // $display("make_cache_way_resp step 0");
    cache_rd_resp(way);
    #20;
    // $display("make_cache_way_resp step 1");
    cache_lower_resp();
    #20;
endtask

task make_mem_ack;
    // $display("make_mem_ack step 0");
    mem_miss_ack();
    #20;
    // $display("make_mem_ack step 1");
    mem_miss_lower();
    #20;
endtask

task make_mem_resp(input [2:0] txn_id);
    // $display("make_mem_resp step 0");
    mem_resp_ack(txn_id);
    #20;
    // $display("make_mem_resp step 1");
    mem_resp_lower();
    #20;
endtask

task make_delay;
    #20;
endtask

task display_time;
    $display("| Time: %x", CLK_CYCLE);
endtask


wire [2:0] de_io_write_ptr_o;
wire [2:0] de_io_redo_ptr_o;
wire [2:0] de_io_mem_ack_ptr_o;
wire [2:0] de_io_mem_resp_ptr_o;


wt_dcache_wbuffer wbuffer_i (
            .clk_i(clk),
            .rst_ni(reset),
            .cache_en_i(de_io_cache_en_i),
            .empty_o(de_io_empty_o),
            .not_ni_o(de_io_not_ni_o),
            .req_port_i(de_io_req_port_i),
            .req_port_o(de_io_req_port_o),
            .miss_ack_i(de_io_miss_ack_i),
            .miss_paddr_o(de_io_miss_paddr_o),
            .miss_req_o(de_io_miss_req_o),
            .miss_we_o(de_io_miss_we_o),
            .miss_wdata_o(de_io_miss_wdata_o),
            .miss_wuser_o(de_io_miss_wuser_o),
            .miss_vld_bits_o(de_io_miss_vld_bits_o),
            .miss_nc_o(de_io_miss_nc_o),
            .miss_size_o(de_io_miss_size_o),
            .miss_id_o(de_io_miss_id_o),
            .miss_rtrn_vld_i(de_io_miss_rtrn_vld_i),
            .miss_rtrn_id_i(de_io_miss_rtrn_id_i),
            .rd_tag_o(de_io_rd_tag_o),
            .rd_idx_o(de_io_rd_idx_o),
            .rd_off_o(de_io_rd_off_o),
            .rd_req_o(de_io_rd_req_o),
            .rd_tag_only_o(de_io_rd_tag_only_o),
            .rd_ack_i(de_io_rd_ack_i),
            .rd_data_i(de_io_rd_data_i),
            .rd_vld_bits_i(de_io_rd_vld_bits_i),
            .rd_hit_oh_i(de_io_rd_hit_oh_i),
            .wr_cl_vld_i(de_io_wr_cl_vld_i),
            .wr_cl_idx_i(de_io_wr_cl_idx_i),
            .wr_req_o(de_io_wr_req_o),
            .wr_ack_i(de_io_wr_ack_i),
            .wr_idx_o(de_io_wr_idx_o),
            .wr_off_o(de_io_wr_off_o),
            .wr_data_o(de_io_wr_data_o),
            .wr_data_be_o(de_io_wr_data_be_o),
            .wr_user_o(de_io_wr_user_o),
            .wbuffer_data_o(de_io_wbuffer_data_o),
            .tx_paddr_o(de_io_tx_paddr_o),
            .tx_vld_o(de_io_tx_vld_o),
            // For debug
            .tx_stat_data_o(de_io_tx_stat_data_o)
`ifdef EXPOSE_STATE
	, .write_ptr_o(de_io_write_ptr_o)
	, .redo_ptr_o(de_io_redo_ptr_o)
	, .mem_ack_ptr_o(de_io_mem_ack_ptr_o)
	, .mem_resp_ptr_o(de_io_mem_resp_ptr_o)
`endif
        );

        cva6_wbuffer_model model (
            .clk_i(clk),
            .rst_ni(reset),
            .cache_en_i(mo_io_cache_en_i),
            .empty_o(mo_io_empty_o),
            .not_ni_o(mo_io_not_ni_o),
            .req_port_i(mo_io_req_port_i),
            .req_port_o(mo_io_req_port_o),
            .miss_ack_i(mo_io_miss_ack_i),
            .miss_paddr_o(mo_io_miss_paddr_o),
            .miss_req_o(mo_io_miss_req_o),
            .miss_we_o(mo_io_miss_we_o),
            .miss_wdata_o(mo_io_miss_wdata_o),
            .miss_wuser_o(mo_io_miss_wuser_o),
            .miss_vld_bits_o(mo_io_miss_vld_bits_o),
            .miss_nc_o(mo_io_miss_nc_o),
            .miss_size_o(mo_io_miss_size_o),
            .miss_id_o(mo_io_miss_id_o),
            .miss_rtrn_vld_i(mo_io_miss_rtrn_vld_i),
            .miss_rtrn_id_i(mo_io_miss_rtrn_id_i),
            .rd_tag_o(mo_io_rd_tag_o),
            .rd_idx_o(mo_io_rd_idx_o),
            .rd_off_o(mo_io_rd_off_o),
            .rd_req_o(mo_io_rd_req_o),
            .rd_tag_only_o(mo_io_rd_tag_only_o),
            .rd_ack_i(mo_io_rd_ack_i),
            .rd_data_i(mo_io_rd_data_i),
            .rd_vld_bits_i(mo_io_rd_vld_bits_i),
            .rd_hit_oh_i(mo_io_rd_hit_oh_i),
            .wr_cl_vld_i(mo_io_wr_cl_vld_i),
            .wr_cl_idx_i(mo_io_wr_cl_idx_i),
            .wr_req_o(mo_io_wr_req_o),
            .wr_ack_i(mo_io_wr_ack_i),
            .wr_idx_o(mo_io_wr_idx_o),
            .wr_off_o(mo_io_wr_off_o),
            .wr_data_o(mo_io_wr_data_o),
            .wr_data_be_o(mo_io_wr_data_be_o),
            .wr_user_o(mo_io_wr_user_o),
            .wbuffer_data_o(mo_io_wbuffer_data_o),
            .tx_paddr_o(mo_io_tx_paddr_o),
            .tx_vld_o(mo_io_tx_vld_o),
            // For debug
            .port_io_wbuffer_summary_q(mo_io_port_io_wbuffer_summary_q)
`ifdef EXPOSE_STATE
	, .write_ptr_i(de_io_write_ptr_o)
	, .redo_ptr_i(de_io_redo_ptr_o)
	, .mem_ack_ptr_i(de_io_mem_ack_ptr_o)
	, .mem_resp_ptr_i(de_io_mem_resp_ptr_o)
`endif
        );


reg [2:0] wbuffer_data_o_0;
reg [2:0] wbuffer_data_o_1;
reg [2:0] wbuffer_data_o_2;
reg [2:0] wbuffer_data_o_3;
reg [2:0] wbuffer_data_o_4;
reg [2:0] wbuffer_data_o_5;
reg [2:0] wbuffer_data_o_6;
reg [2:0] wbuffer_data_o_7;

    always @(posedge clk ) begin
        counter <= counter + 1;
        if (init && counter > 1) begin
            reset <= 1;
        end
        if (init && counter == 3) begin
            init <= 0;
        end 
    end


reg [1:0] action;
reg [2:0] state;
reg occupied;

reg [1:0] txn_ctrs [0:3];
reg [1:0] txn_ctr;
reg [3:0] done_choices;
reg [1:0] prev_choice;

wire all_equal;
assign all_equal = (mo_io_port_io_wbuffer_summary_q == {
        wbuffer_data_o_7, wbuffer_data_o_6, wbuffer_data_o_5, wbuffer_data_o_4,
        wbuffer_data_o_3, wbuffer_data_o_2, wbuffer_data_o_1, wbuffer_data_o_0
    });


(* anyseq *) reg [1:0] choice;

    always @(posedge clk ) begin
        if (!reset) begin
            state = 0;
            action = 0;
            occupied = 0;
            done_choices = 0;
            tb_io_miss_ack_i <= 0;
            tb_io_rd_hit_oh_i <= 0;
            tb_io_rd_ack_i <= 0;
            tb_io_req_port_i <= 0;
            tb_io_miss_rtrn_vld_i <= 0;
            tb_io_miss_rtrn_id_i <= 0;
            
            txn_ctrs[0] = 0;
            txn_ctrs[1] = 0;
            txn_ctrs[2] = 0;
            txn_ctrs[3] = 0;
            txn_ctr = 0;
        end else begin
            if (!occupied)
                if (choice != 0) begin
                    if (!done_choices[choice]) begin
                        core_wr_req(choice << 5, choice << 5, 1947);
                        txn_ctrs[choice] = txn_ctr;
                        txn_ctr = txn_ctr + 1;
                        state = 1;
                        action = 1;
                        occupied = 1;
                        done_choices[choice] = 1;
                    end else begin
                        core_wr_req(choice << 5, choice << 5, 1947);
                        state = 1;
                        action = 2;
                        occupied = 1;
                        prev_choice = choice;
                    end
                end
            else begin 
                if (action == 1) begin
                    if (state == 1) begin
                        cache_rd_resp(4);
                        core_lower_req();
                        state = 2;
                    end else if (state == 2) begin
                        cache_lower_resp();
                        state = 3;
                    end else if (state == 3) begin
                        mem_miss_ack();
                        state = 4;
                    end else if (state == 4) begin
                        mem_miss_lower();
                        state = 0;
                        occupied = 0;
                        action = 0;
                    end
                end else if (action == 2) begin
                    if (state == 1) begin
                        cache_rd_resp(4);
                        core_lower_req();
                        state = 2;
                    end else if (state == 2) begin
                        cache_lower_resp();
                        state = 3;
                    end else if (state == 3) begin
                        mem_resp_ack(txn_ctrs[prev_choice]);
                        state = 4;
                        txn_ctrs[prev_choice] = txn_ctr;
                        txn_ctr = txn_ctr + 1;
                    end else if (state == 4) begin
                        mem_resp_lower();
                        state = 5;
                    end else if (state == 5) begin
                        mem_miss_ack();
                        state = 6;
                    end else if (state == 6) begin
                        mem_miss_lower();
                        state = 0;
                        occupied = 0;
                        action = 0;
                    end
                end
            end

            assert(all_equal);
        end 
    end


    always @(*) begin
        wbuffer_data_o_0 = {de_io_wbuffer_data_o[86*0+17], de_io_wbuffer_data_o[86*0+13], de_io_wbuffer_data_o[86*0+9]}; // , de_io_wbuffer_data_o[86*0+8];
        wbuffer_data_o_1 = {de_io_wbuffer_data_o[86*1+17], de_io_wbuffer_data_o[86*1+13], de_io_wbuffer_data_o[86*1+9]}; // , de_io_wbuffer_data_o[86*1+8];
        wbuffer_data_o_2 = {de_io_wbuffer_data_o[86*2+17], de_io_wbuffer_data_o[86*2+13], de_io_wbuffer_data_o[86*2+9]}; // , de_io_wbuffer_data_o[86*2+8];
        wbuffer_data_o_3 = {de_io_wbuffer_data_o[86*3+17], de_io_wbuffer_data_o[86*3+13], de_io_wbuffer_data_o[86*3+9]}; // , de_io_wbuffer_data_o[86*3+8];
        wbuffer_data_o_4 = {de_io_wbuffer_data_o[86*4+17], de_io_wbuffer_data_o[86*4+13], de_io_wbuffer_data_o[86*4+9]}; // , de_io_wbuffer_data_o[86*4+8];
        wbuffer_data_o_5 = {de_io_wbuffer_data_o[86*5+17], de_io_wbuffer_data_o[86*5+13], de_io_wbuffer_data_o[86*5+9]}; // , de_io_wbuffer_data_o[86*5+8];
        wbuffer_data_o_6 = {de_io_wbuffer_data_o[86*6+17], de_io_wbuffer_data_o[86*6+13], de_io_wbuffer_data_o[86*6+9]}; // , de_io_wbuffer_data_o[86*6+8];
        wbuffer_data_o_7 = {de_io_wbuffer_data_o[86*7+17], de_io_wbuffer_data_o[86*7+13], de_io_wbuffer_data_o[86*7+9]}; // , de_io_wbuffer_data_o[86*7+8];


    end

    endmodule
    