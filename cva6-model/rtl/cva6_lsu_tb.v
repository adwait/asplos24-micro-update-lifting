


    module load_store_unit_tb ();
        parameter PHASE_TIME = 10;
        parameter CLK_CYCLE_TIME = PHASE_TIME * 2;
        parameter IMEM_INTERVAL = 20;
        parameter SIM_CYCLE = 21; // 100000000;
        parameter SIM_TIME = SIM_CYCLE * PHASE_TIME * 2;

        reg [31:0] 			CLK_CYCLE;
        reg 				clk;
        reg 				reset;
        
        initial begin
            clk = 1;
            forever #PHASE_TIME clk = ~clk;
        end

        initial begin
            reset = 1;
            // #IMEM_INTERVAL reset = 1;
            #IMEM_INTERVAL 
            reset = 0;
            #IMEM_INTERVAL 
            #IMEM_INTERVAL 
            reset = 1;
        end

        initial begin
            CLK_CYCLE = 32'h0;
        end
        
        always @(posedge clk) begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        end

        initial begin
            $dumpfile("lsu_wave_pipeline.vcd");
            $dumpvars(0, load_store_unit_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = 100;

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
    assign de_io_commit_i = tb_io_commit_i;

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

    task serve_load_1;
        begin
            tb_io_dcache_req_ports_i[69] = 1'b1;
            tb_io_dcache_req_ports_i[68:35] = 34'd0;
        end
    endtask
    task serve_load_2 (input [31:0] data);
        begin

            tb_io_dcache_req_ports_i[69] = 1'b0;
            tb_io_dcache_req_ports_i[68] = 1'b1; 
            tb_io_dcache_req_ports_i[67:36] = data;
            tb_io_dcache_req_ports_i[35] = 1'b0;
        end
    endtask
    task serve_load_3;
        begin
            tb_io_dcache_req_ports_i[69:35] = 35'd0;
        end
    endtask

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
        .clk_i(clk),
	    .rst_ni(reset),
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
    );


    reg [31:0] addr;
    reg [2:0] commit_id;
    
    reg [31:0] data;
    reg choice;

    integer i;

    initial begin
        #20;
        tb_io_dcache_req_ports_i = 105'd0;
        tb_io_commit_i = 0;
        tb_io_commit_tran_id_i = 0;
        tb_io_fu_data_i = 0;
        tb_io_lsu_valid_i = 0;
        #60;
        
        for (i = 0; i < 5; i=i+1) begin
            // commit_id = $random(seed);
            // addr = $random(seed);
            // data = $random(seed);
            // choice = $random(seed);

            raise_store_request(20, 24, 1);
            #20;
            lower_store_request();
            
            
            #20;
            #20;

            // raise_store_request(40, 24, 1);
            // #20;
            // lower_store_request();

            // #20;
            // #20;

            // raise_store_request(60, 24, 1);
            // #20;
            // lower_store_request();

            // #20;
            // #20;

            // raise_store_request(80, 24, 1);
            // #20;
            // lower_store_request();


            raise_load_request(20, 2);
            
            #20;
            store_commit();
            lower_load_request();
            
            #20;
            store_decommit();
            
            serve_load_2(36);
            load_commit(2);
            #20;
            

            #20;
            serve_store_1();
            #20;
            
            serve_load_1();
            #20;
            serve_store_2();
            #20;
            serve_load_3();



            #100;
            $finish;





            // if (choice) begin
            //     raise_load_request(addr, commit_id);
            //     serve_load_1();
                
            //     #20;
            //     lower_load_request();
                
            //     #20;
            //     serve_load_2(data);
            //     load_commit(commit_id);

            //     #20;
            //     serve_load_3();
            // end else begin
                // raise_store_request(addr, data, commit_id);
                // #20
                // lower_store_request();

                // serve_store_1();
                // #20;
                // store_commit();
                
                // #20;
                // store_decommit();
                // serve_store_2();
                
            // end

            #20;
        end    
    end
    
    endmodule
    