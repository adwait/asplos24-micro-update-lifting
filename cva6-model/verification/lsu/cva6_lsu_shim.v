

module cva6_lsu_shim (
    input wire clk_i,
    input wire rst_ni,
    
    input wire [31:0] instr_i,
    input is_load_i,
    input store_commit_i,
    input wire instr_valid_i,
    input wire store_mem_resp_i,
    input wire load_mem_resp_i,
    output wire load_req_o,
    output wire ready_o
`ifdef EXPOSE_STATE
    , output wire [7:0] store_state_o
    , output wire [1:0] load_state_o
`endif
);

    parameter [31:0] ASID_WIDTH = 1;
	localparam ariane_pkg_NrMaxRules = 16;
	localparam [6433:0] ariane_pkg_ArianeDefaultConfig = 6434'b10000000000000000000000000001000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000;
	parameter [6433:0] ArianeCfg = ariane_pkg_ArianeDefaultConfig;
	localparam ariane_pkg_NR_SB_ENTRIES = 8;
	localparam ariane_pkg_TRANS_ID_BITS = 3;
	localparam cva6_config_pkg_CVA6ConfigXlen = 32;
	localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
	localparam riscv_VLEN = 32;
	localparam riscv_PLEN = 34;
	localparam riscv_PPNW = 22;
	localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
	localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
	localparam ariane_pkg_DATA_USER_WIDTH = 1;
	localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
	localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
	localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
	localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
	localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;


    wire de_io_flush_i;
    reg tb_io_flush_i;
    assign de_io_flush_i = 0; // tb_io_flush_i;

wire de_io_no_st_pending_o;
    wire de_io_amo_valid_commit_i;
    reg tb_io_amo_valid_commit_i;
    assign de_io_amo_valid_commit_i = 0; // tb_io_amo_valid_commit_i;

    wire [110:0] de_io_fu_data_i;
    reg [110:0] tb_io_fu_data_i;
    assign de_io_fu_data_i = tb_io_fu_data_i;

wire de_io_lsu_ready_o;
    wire de_io_lsu_valid_i;
    reg tb_io_lsu_valid_i;
    assign de_io_lsu_valid_i = tb_io_lsu_valid_i;
    assign ready_o = de_io_lsu_ready_o;

wire [2:0] de_io_load_trans_id_o;
wire [31:0] de_io_load_result_o;
wire de_io_load_valid_o;
wire [64:0] de_io_load_exception_o;
wire [2:0] de_io_store_trans_id_o;
wire [31:0] de_io_store_result_o;
wire de_io_store_valid_o;
wire [64:0] de_io_store_exception_o;
    wire de_io_commit_i;
    reg tb_io_commit_i;
    assign de_io_commit_i = store_commit_i; // tb_io_commit_i;

wire de_io_commit_ready_o;
    wire [2:0] de_io_commit_tran_id_i;
    reg [2:0] tb_io_commit_tran_id_i;
    assign de_io_commit_tran_id_i = tb_io_commit_tran_id_i;

    wire de_io_enable_translation_i;
    reg tb_io_enable_translation_i;
    assign de_io_enable_translation_i = 0; // tb_io_enable_translation_i;

    wire de_io_en_ld_st_translation_i;
    reg tb_io_en_ld_st_translation_i;
    assign de_io_en_ld_st_translation_i = 0; // tb_io_en_ld_st_translation_i;

    wire [32:0] de_io_icache_areq_i;
    reg [32:0] tb_io_icache_areq_i;
    assign de_io_icache_areq_i = 0; // tb_io_icache_areq_i;

wire [99:0] de_io_icache_areq_o;
    wire [1:0] de_io_priv_lvl_i;
    reg [1:0] tb_io_priv_lvl_i;
    assign de_io_priv_lvl_i = 0; // tb_io_priv_lvl_i;

    wire [1:0] de_io_ld_st_priv_lvl_i;
    reg [1:0] tb_io_ld_st_priv_lvl_i;
    assign de_io_ld_st_priv_lvl_i = 0; // tb_io_ld_st_priv_lvl_i;

    wire de_io_sum_i;
    reg tb_io_sum_i;
    assign de_io_sum_i = 0; // tb_io_sum_i;

    wire de_io_mxr_i;
    reg tb_io_mxr_i;
    assign de_io_mxr_i = 0; // tb_io_mxr_i;

    wire [21:0] de_io_satp_ppn_i;
    reg [21:0] tb_io_satp_ppn_i;
    assign de_io_satp_ppn_i = 0; // tb_io_satp_ppn_i;

    wire [ASID_WIDTH - 1:0] de_io_asid_i;
    reg [ASID_WIDTH - 1:0] tb_io_asid_i;
    assign de_io_asid_i = 0; // tb_io_asid_i;

    wire [ASID_WIDTH - 1:0] de_io_asid_to_be_flushed_i;
    reg [ASID_WIDTH - 1:0] tb_io_asid_to_be_flushed_i;
    assign de_io_asid_to_be_flushed_i = 0; // tb_io_asid_to_be_flushed_i;

    wire [31:0] de_io_vaddr_to_be_flushed_i;
    reg [31:0] tb_io_vaddr_to_be_flushed_i;
    assign de_io_vaddr_to_be_flushed_i = 0; // tb_io_vaddr_to_be_flushed_i;

    wire de_io_flush_tlb_i;
    reg tb_io_flush_tlb_i;
    assign de_io_flush_tlb_i = 0; // tb_io_flush_tlb_i;

wire de_io_itlb_miss_o;
wire de_io_dtlb_miss_o;
    wire [104:0] de_io_dcache_req_ports_i;
    reg [104:0] tb_io_dcache_req_ports_i;
    assign de_io_dcache_req_ports_i = tb_io_dcache_req_ports_i;

wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? (3 * ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 10)) - 1 : (3 * (1 - ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9))) + ((((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 8)):(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + 42) >= 0 ? 0 : (((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9)] de_io_dcache_req_ports_o;
    wire de_io_dcache_wbuffer_empty_i;
    reg tb_io_dcache_wbuffer_empty_i;
    // info: setting to 0 to avoid deadlock
    assign de_io_dcache_wbuffer_empty_i = 0; // tb_io_dcache_wbuffer_empty_i;

    wire de_io_dcache_wbuffer_not_ni_i;
    reg tb_io_dcache_wbuffer_not_ni_i;
    // info: setting to 0 to avoid deadlock
    assign de_io_dcache_wbuffer_not_ni_i = 0; // tb_io_dcache_wbuffer_not_ni_i;

wire [134:0] de_io_amo_req_o;
    wire [64:0] de_io_amo_resp_i;
    reg [64:0] tb_io_amo_resp_i;
    assign de_io_amo_resp_i = 0; // tb_io_amo_resp_i;

    wire [127:0] de_io_pmpcfg_i;
    reg [127:0] tb_io_pmpcfg_i;
    assign de_io_pmpcfg_i = 0; // tb_io_pmpcfg_i;

    wire [511:0] de_io_pmpaddr_i;
    reg [511:0] tb_io_pmpaddr_i;
    assign de_io_pmpaddr_i = 0; // tb_io_pmpaddr_i;

    task raise_load_request (input [31:0] addr, input [2:0] commit_id);
        begin
            tb_io_fu_data_i = {4'b1, 8'd37, addr, 32'd0, 32'd0, commit_id};
            tb_io_lsu_valid_i = 1;
        end
    endtask
    task lower_load_request;
        begin
            tb_io_lsu_valid_i = 0;
        end
    endtask
    task load_commit (input [2:0] commit_id);
        begin
            tb_io_commit_tran_id_i = commit_id;
        end
    endtask

    // task serve_load_1;
    //     begin
    //         tb_io_dcache_req_ports_i[69] = 1'b1;
    //         tb_io_dcache_req_ports_i[68:35] = 34'd0;
    //     end
    // endtask
    // task serve_load_2 (input [31:0] data);
    //     begin
    //         tb_io_dcache_req_ports_i[69] = 1'b0;
    //         tb_io_dcache_req_ports_i[68] = 1'b1; 
    //         tb_io_dcache_req_ports_i[67:36] = data;
    //         tb_io_dcache_req_ports_i[35] = 1'b0;
    //     end
    // endtask
    // task serve_load_3;
    //     begin
    //         tb_io_dcache_req_ports_i[69:35] = 35'd0;
    //     end
    // endtask

    task raise_store_request (input [31:0] addr, input [31:0] data, input [2:0] commit_id);
        begin
            tb_io_fu_data_i = {4'd2, 8'd39, addr, data, 32'd0,  commit_id};
            tb_io_lsu_valid_i = 1;
        end
    endtask
    task lower_store_request;
        begin
            tb_io_lsu_valid_i = 0;
        end
    endtask
    
    task store_commit;
        begin
            tb_io_commit_i = 1;
        end
    endtask
    task store_decommit;
        begin
            tb_io_commit_i = 0;
        end
    endtask

    task serve_store_1;
        begin
            tb_io_dcache_req_ports_i[104] = 1'b1;
        end
    endtask
    task serve_store_2;
        begin
            tb_io_dcache_req_ports_i[104] = 1'b0;
        end
    endtask
    


    load_store_unit lsu_i (
        .clk_i(clk_i),
	    .rst_ni(rst_ni),
	    .flush_i(de_io_flush_i),
	    .no_st_pending_o(de_io_no_st_pending_o),
	    .amo_valid_commit_i(de_io_amo_valid_commit_i),
	    .fu_data_i(de_io_fu_data_i),
	    .lsu_ready_o(de_io_lsu_ready_o),
	    .lsu_valid_i(de_io_lsu_valid_i),
	    .load_trans_id_o(de_io_load_trans_id_o),
	    .load_result_o(de_io_load_result_o),
	    .load_valid_o(de_io_load_valid_o),
	    .load_exception_o(de_io_load_exception_o),
	    .store_trans_id_o(de_io_store_trans_id_o),
	    .store_result_o(de_io_store_result_o),
	    .store_valid_o(de_io_store_valid_o),
	    .store_exception_o(de_io_store_exception_o),
	    .commit_i(de_io_commit_i),
	    .commit_ready_o(de_io_commit_ready_o),
	    .commit_tran_id_i(de_io_commit_tran_id_i),
	    .enable_translation_i(de_io_enable_translation_i),
	    .en_ld_st_translation_i(de_io_en_ld_st_translation_i),
	    .icache_areq_i(de_io_icache_areq_i),
	    .icache_areq_o(de_io_icache_areq_o),
	    .priv_lvl_i(de_io_priv_lvl_i),
	    .ld_st_priv_lvl_i(de_io_ld_st_priv_lvl_i),
	    .sum_i(de_io_sum_i),
	    .mxr_i(de_io_mxr_i),
	    .satp_ppn_i(de_io_satp_ppn_i),
	    .asid_i(de_io_asid_i),
	    .asid_to_be_flushed_i(de_io_asid_to_be_flushed_i),
	    .vaddr_to_be_flushed_i(de_io_vaddr_to_be_flushed_i),
	    .flush_tlb_i(de_io_flush_tlb_i),
	    .itlb_miss_o(de_io_itlb_miss_o),
	    .dtlb_miss_o(de_io_dtlb_miss_o),
	    .dcache_req_ports_i(de_io_dcache_req_ports_i),
	    .dcache_req_ports_o(de_io_dcache_req_ports_o),
	    .dcache_wbuffer_empty_i(de_io_dcache_wbuffer_empty_i),
	    .dcache_wbuffer_not_ni_i(de_io_dcache_wbuffer_not_ni_i),
	    .amo_req_o(de_io_amo_req_o),
	    .amo_resp_i(de_io_amo_resp_i),
	    .pmpcfg_i(de_io_pmpcfg_i),
	    .pmpaddr_i(de_io_pmpaddr_i)
`ifdef EXPOSE_STATE
        , .store_state_o(store_state_o)
        , .load_state_o(load_state_o)
`endif
    );

    reg [2:0] load_memreq_state;
    
    reg [1:0] load_req_state;
    reg [1:0] store_req_state;
    
    reg [31:0] dummy_data;

    reg x_load_mem_resp_i;

    assign load_req_o = de_io_dcache_req_ports_o[77+9];
    
    always @(posedge clk_i ) begin

        if (~rst_ni) begin
            tb_io_dcache_req_ports_i = 105'd0;
            tb_io_commit_i = 0;
            tb_io_commit_tran_id_i = 0;
            tb_io_fu_data_i = 0;
            tb_io_lsu_valid_i = 0;    

            x_load_mem_resp_i = 0;

`ifndef FORMAL
    dummy_data = 32'hdeadbeef;
`endif


            load_memreq_state = 3'd0;
            load_req_state = 2'd0;
            store_req_state = 2'd0;
        end else begin

            tb_io_dcache_req_ports_i[69:35] = {load_mem_resp_i, x_load_mem_resp_i, dummy_data, 1'd0};
        
            if (store_mem_resp_i) begin
                $display("store_mem_resp_i");
                serve_store_1();
            end else begin
                serve_store_2();
            end

            // if (load_mem_resp_i) begin
            //     $display("load_mem_resp_i");
            //     serve_load_1();
            //     load_memreq_state = 3'd1;
            // end else if (load_memreq_state == 3'd1) begin
            //     if (de_io_dcache_req_ports_o[77+9]) begin 
            //         serve_load_2(32'hdeadbeef);
            //         load_memreq_state = 3'd2;
            //     end
            // end else if (load_memreq_state == 3'd2) begin
            //     if (!de_io_dcache_req_ports_o[77+9]) begin 
            //         serve_load_3();
            //         load_memreq_state = 3'd0;
            //     end
            // end

            if (instr_valid_i) begin
                if (!is_load_i) begin
                    $display("store request");
                    raise_store_request(instr_i, 32'hcafecafe, 2);
                    store_req_state = 2'd1;
                end else if (is_load_i) begin
                    $display("load request");
                    raise_load_request(instr_i, 1);
                    load_req_state = 2'd1;
                end
            end else begin
                if (load_req_state == 2'd1) begin
                    lower_load_request();
                    load_commit(1);
                    load_req_state = 2'd2;
                end else if (load_req_state == 2'd2) begin
                    load_commit(0);
                    load_req_state = 2'd0;
                end 
                
                if (store_req_state == 2'd1) begin
                    lower_store_request();
                    store_req_state = 2'd2;                    
                end else if (store_req_state == 2'd2) begin
                    store_commit();
                    store_req_state = 2'd3;
                end else if (store_req_state == 2'd3) begin
                    store_decommit();
                    store_req_state = 2'd0;
                end
            end

            x_load_mem_resp_i <= load_mem_resp_i;

        end  
    end

endmodule