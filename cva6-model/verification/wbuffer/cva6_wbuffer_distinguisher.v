`timescale 5ns/5ns
    module tlb_tb(
        input clk
    );
        
    reg reset;
    reg past_reset;
    reg [2:0] counter;
    reg [7:0] CLK_CYCLE;
    reg init;
    initial begin
        past_reset = 0;
        reset = 0;
        init = 1;
        counter = 0;
        CLK_CYCLE = 0;
    end

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

        // Parameters and I/O connections
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

// Unused
wire cache_en_i;
reg tb_io_cache_en_i;
assign de_io_cache_en_i = 0; // tb_io_cache_en_i;
wire de_io_empty_o;
wire de_io_not_ni_o;
wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] de_io_req_port_i;
(* anyseq *) reg [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] tb_io_req_port_i;
assign de_io_req_port_i = tb_io_req_port_i;
reg [34:0] de_io_req_port_o;
// Ack from the miss handler (for signalling a received write request)
wire de_io_miss_ack_i;
(* anyseq *) reg tb_io_miss_ack_i;
assign de_io_miss_ack_i = tb_io_miss_ack_i;
wire [33:0] de_io_miss_paddr_o;
wire de_io_miss_req_o;
wire de_io_miss_we_o;
wire [31:0] de_io_miss_wdata_o;
wire [0:0] de_io_miss_wuser_o;
wire [7:0] de_io_miss_vld_bits_o;
wire de_io_miss_nc_o;
wire [2:0] de_io_miss_size_o;
wire [1:0] de_io_miss_id_o;
wire de_io_miss_rtrn_vld_i;
(* anyseq *) reg tb_io_miss_rtrn_vld_i;
assign de_io_miss_rtrn_vld_i = tb_io_miss_rtrn_vld_i;
wire [1:0] de_io_miss_rtrn_id_i;
(* anyseq *) reg [1:0] tb_io_miss_rtrn_id_i;
assign de_io_miss_rtrn_id_i = tb_io_miss_rtrn_id_i;
wire [ariane_pkg_DCACHE_TAG_WIDTH - 1:0] de_io_rd_tag_o;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_rd_idx_o;
wire [3:0] de_io_rd_off_o;
wire de_io_rd_req_o;
wire de_io_rd_tag_only_o;
wire de_io_rd_ack_i;
(* anyseq *) reg tb_io_rd_ack_i;
assign de_io_rd_ack_i = tb_io_rd_ack_i;
// Unused
wire [31:0] de_io_rd_data_i;
reg [31:0] tb_io_rd_data_i;
assign de_io_rd_data_i = 0; // tb_io_rd_data_i;
// Unused
wire [7:0] de_io_rd_vld_bits_i;
reg [7:0] tb_io_rd_vld_bits_i;
assign de_io_rd_vld_bits_i = 0; // tb_io_rd_vld_bits_i;
wire [7:0] de_io_rd_hit_oh_i;
(* anyseq *) reg [7:0] tb_io_rd_hit_oh_i;
assign de_io_rd_hit_oh_i = tb_io_rd_hit_oh_i;
// Assume: no cacheline writes
wire de_io_wr_cl_vld_i;
reg tb_io_wr_cl_vld_i;
assign de_io_wr_cl_vld_i = 0; // tb_io_wr_cl_vld_i;
// Assume: no cacheline writes
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_wr_cl_idx_i;
reg [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] tb_io_wr_cl_idx_i;
assign de_io_wr_cl_idx_i = 0; // tb_io_wr_cl_idx_i;
reg [7:0] de_io_wr_req_o;
// Assume: writes are acked immediately
wire de_io_wr_ack_i;
reg tb_io_wr_ack_i;
assign de_io_wr_ack_i = 1; // tb_io_wr_ack_i;
wire [wt_cache_pkg_DCACHE_CL_IDX_WIDTH - 1:0] de_io_wr_idx_o;
wire [3:0] de_io_wr_off_o;
wire [31:0] de_io_wr_data_o;
wire [3:0] de_io_wr_data_be_o;
wire [0:0] de_io_wr_user_o;
wire [(8 * (((((ariane_pkg_DCACHE_TAG_WIDTH + (ariane_pkg_DCACHE_INDEX_WIDTH - riscv_XLEN_ALIGN_BYTES)) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 13) + ariane_pkg_DCACHE_SET_ASSOC)) - 1:0] de_io_wbuffer_data_o;
wire [135:0] de_io_tx_paddr_o;
wire [3:0] de_io_tx_vld_o;

wire [31:0] de_io_tx_stat_data_o;

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
        );

    wire [2:0] de_io_port_wbuffer_summary [0:7];
    assign de_io_port_wbuffer_summary[0] = {de_io_wbuffer_data_o[86*0+17], de_io_wbuffer_data_o[86*0+13], de_io_wbuffer_data_o[86*0+9]}; 
    assign de_io_port_wbuffer_summary[1] = {de_io_wbuffer_data_o[86*1+17], de_io_wbuffer_data_o[86*1+13], de_io_wbuffer_data_o[86*1+9]}; 
    assign de_io_port_wbuffer_summary[2] = {de_io_wbuffer_data_o[86*2+17], de_io_wbuffer_data_o[86*2+13], de_io_wbuffer_data_o[86*2+9]}; 
    assign de_io_port_wbuffer_summary[3] = {de_io_wbuffer_data_o[86*3+17], de_io_wbuffer_data_o[86*3+13], de_io_wbuffer_data_o[86*3+9]}; 
    assign de_io_port_wbuffer_summary[4] = {de_io_wbuffer_data_o[86*4+17], de_io_wbuffer_data_o[86*4+13], de_io_wbuffer_data_o[86*4+9]}; 
    assign de_io_port_wbuffer_summary[5] = {de_io_wbuffer_data_o[86*5+17], de_io_wbuffer_data_o[86*5+13], de_io_wbuffer_data_o[86*5+9]}; 
    assign de_io_port_wbuffer_summary[6] = {de_io_wbuffer_data_o[86*6+17], de_io_wbuffer_data_o[86*6+13], de_io_wbuffer_data_o[86*6+9]}; 
    assign de_io_port_wbuffer_summary[7] = {de_io_wbuffer_data_o[86*7+17], de_io_wbuffer_data_o[86*7+13], de_io_wbuffer_data_o[86*7+9]}; 

    integer i;
    (* anyseq *) reg [1:0] choice;
    (* anyseq *) reg [1:0] addr;
    reg [7:0] txn_ctr;
    
        initial begin
            // Explicit intialization of the inputs
            // tb_io_miss_ack_i <= 0;
            // tb_io_rd_hit_oh_i <= 0;
            // tb_io_rd_ack_i <= 0;
            // tb_io_req_port_i <= 0;
            // tb_io_miss_rtrn_vld_i <= 0;
            // tb_io_miss_rtrn_id_i <= 0;
            // txn_ctr = 0;
            // Setup CSR
            #10;
            #10;
            #10;

            // for (i = 0; i < 20; i=i+1) begin
            //     if (choice == 2'b00)
            //         make_write_request((addr << 5), (addr << 5), 1947);
            //     else if (choice == 2'b01)
            //         make_mem_ack();
            //     else if (choice == 2'b10) begin
            //         make_mem_resp(txn_ctr); txn_ctr = txn_ctr + 1;
            //     end else
            //         make_delay();
            //     #10;
            // end

        end

    // Distinguisher signals
    reg [2:0] copy1_wbuffer_summary [0:7];
    reg [2:0] copy2_wbuffer_summary [0:7];
    (* anyseq *) reg [2:0] de_io_port_magic;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 1;
        end
        // if (counter >= 2 || !init) begin
        //     if (choice == 2'b00)
        //         make_write_request((addr << 5), (addr << 5), 1947);
        //     else if (choice == 2'b01)
        //         make_mem_ack();
        //     else if (choice == 2'b10) begin
        //         make_mem_resp(txn_ctr); txn_ctr = txn_ctr + 1;
        //     end else
        //         make_delay();
        // end

    if (CLK_CYCLE == 9) begin
        copy1_wbuffer_summary[0] = de_io_port_wbuffer_summary[0];
        copy1_wbuffer_summary[1] = de_io_port_wbuffer_summary[1];
        copy1_wbuffer_summary[2] = de_io_port_wbuffer_summary[2];
        copy1_wbuffer_summary[3] = de_io_port_wbuffer_summary[3];
        copy1_wbuffer_summary[4] = de_io_port_wbuffer_summary[4];
        copy1_wbuffer_summary[5] = de_io_port_wbuffer_summary[5];
        copy1_wbuffer_summary[6] = de_io_port_wbuffer_summary[6];
        copy1_wbuffer_summary[7] = de_io_port_wbuffer_summary[7];
        // copy2_wbuffer_summary[0] = de_io_port_wbuffer_summary[0];
        // copy2_wbuffer_summary[1] = de_io_port_wbuffer_summary[1];
        // copy2_wbuffer_summary[2] = de_io_port_wbuffer_summary[2];
        // copy2_wbuffer_summary[3] = de_io_port_wbuffer_summary[3];
        // copy2_wbuffer_summary[4] = de_io_port_wbuffer_summary[4];
        // copy2_wbuffer_summary[5] = de_io_port_wbuffer_summary[5];
        // copy2_wbuffer_summary[6] = de_io_port_wbuffer_summary[6];
        // copy2_wbuffer_summary[7] = de_io_port_wbuffer_summary[7];

        
if ((de_io_port_wbuffer_summary[de_io_port_magic]) == (3'b111)) begin
copy1_wbuffer_summary[de_io_port_magic] = 3'b110;

end else begin
copy1_wbuffer_summary[de_io_port_magic] = 3'b100;

end
// copy2_wbuffer_summary[0] = de_io_port_wbuffer_summary[0];
// copy2_wbuffer_summary[1] = de_io_port_wbuffer_summary[1];
// copy2_wbuffer_summary[2] = de_io_port_wbuffer_summary[2];
// copy2_wbuffer_summary[3] = de_io_port_wbuffer_summary[3];
// copy2_wbuffer_summary[4] = de_io_port_wbuffer_summary[4];
// copy2_wbuffer_summary[5] = de_io_port_wbuffer_summary[5];
// copy2_wbuffer_summary[6] = de_io_port_wbuffer_summary[6];
// copy2_wbuffer_summary[7] = de_io_port_wbuffer_summary[7];

    end else if (CLK_CYCLE == 12) begin
        assert ((((copy1_wbuffer_summary[0]) != (de_io_port_wbuffer_summary[0])) || ((copy1_wbuffer_summary[1]) != (de_io_port_wbuffer_summary[1])) || ((copy1_wbuffer_summary[2]) != (de_io_port_wbuffer_summary[2])) || ((copy1_wbuffer_summary[3]) != (de_io_port_wbuffer_summary[3])) || ((copy1_wbuffer_summary[4]) != (de_io_port_wbuffer_summary[4])) || ((copy1_wbuffer_summary[5]) != (de_io_port_wbuffer_summary[5])) || ((copy1_wbuffer_summary[6]) != (de_io_port_wbuffer_summary[6])) || ((copy1_wbuffer_summary[7]) != (de_io_port_wbuffer_summary[7]))) 
    // || 
    //     (((copy1_wbuffer_summary[0]) == (copy2_wbuffer_summary[0])) && ((copy1_wbuffer_summary[1]) == (copy2_wbuffer_summary[1])) && ((copy1_wbuffer_summary[2]) == (copy2_wbuffer_summary[2])) && ((copy1_wbuffer_summary[3]) == (copy2_wbuffer_summary[3])) && ((copy1_wbuffer_summary[4]) == (copy2_wbuffer_summary[4])) && ((copy1_wbuffer_summary[5]) == (copy2_wbuffer_summary[5])) && ((copy1_wbuffer_summary[6]) == (copy2_wbuffer_summary[6])) && ((copy1_wbuffer_summary[7]) == (copy2_wbuffer_summary[7])))
    );

    end else if (CLK_CYCLE == 10) begin
        // assert(((copy1_wbuffer_summary[0]) == (copy2_wbuffer_summary[0])) && ((copy1_wbuffer_summary[1]) == (copy2_wbuffer_summary[1])) && ((copy1_wbuffer_summary[2]) == (copy2_wbuffer_summary[2])) && ((copy1_wbuffer_summary[3]) == (copy2_wbuffer_summary[3])) && ((copy1_wbuffer_summary[4]) == (copy2_wbuffer_summary[4])) && ((copy1_wbuffer_summary[5]) == (copy2_wbuffer_summary[5])) && ((copy1_wbuffer_summary[6]) == (copy2_wbuffer_summary[6])) && ((copy1_wbuffer_summary[7]) == (copy2_wbuffer_summary[7])));
        // assert(0);
    end

    end

    endmodule
    
