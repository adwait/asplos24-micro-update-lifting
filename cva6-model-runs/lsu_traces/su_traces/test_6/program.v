

    module store_unit_model_tb();
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
            $dumpfile("su_model_wave_pipeline.vcd");
            $dumpvars(0, store_unit_model_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = 674;

        localparam ariane_pkg_NR_SB_ENTRIES = 8;
        localparam ariane_pkg_TRANS_ID_BITS = 3;
        localparam cva6_config_pkg_CVA6ConfigXlen = 32;
        localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
        localparam riscv_VLEN = 32;
        localparam riscv_PLEN = 34;
        localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
        localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
        localparam ariane_pkg_DATA_USER_WIDTH = 1;
        localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
        localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
        localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
        localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
        localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
        localparam riscv_IS_XLEN64 = 1'b0;

        wire de_io_flush_i;
        reg tb_io_flush_i;
        assign de_io_flush_i = 0;
        
        wire de_io_no_st_pending_o;
        wire de_io_store_buffer_empty_o;
        
        wire de_io_valid_i;
        reg tb_io_valid_i;
        assign de_io_valid_i = tb_io_valid_i;
        wire [84:0] de_io_lsu_ctrl_i;
        reg [84:0] tb_io_lsu_ctrl_i;
        assign de_io_lsu_ctrl_i = tb_io_lsu_ctrl_i;
        
        wire de_io_pop_st_o;
        
        wire de_io_commit_i;
        reg tb_io_commit_i;
        assign de_io_commit_i = tb_io_commit_i;
        
        wire de_io_commit_ready_o;
        
        wire de_io_amo_valid_commit_i;
        reg tb_io_amo_valid_commit_i;
        assign de_io_amo_valid_commit_i = 0; // tb_io_amo_valid_commit_i;
        
        wire de_io_valid_o;
        wire [2:0] de_io_trans_id_o;
        wire [31:0] de_io_result_o;
        wire [64:0] de_io_ex_o;
        wire de_io_translation_req_o;
        wire [31:0] de_io_vaddr_o;

        wire [33:0] de_io_paddr_i;
        reg [33:0] tb_io_paddr_i;
        assign de_io_paddr_i = tb_io_paddr_i;
        wire [64:0] de_io_ex_i;
        reg [64:0] tb_io_ex_i;
        assign de_io_ex_i = 0; // tb_io_ex_i;
        wire de_io_dtlb_hit_i;
        reg tb_io_dtlb_hit_i;
        assign de_io_dtlb_hit_i = 1; // tb_io_dtlb_hit_i;
        wire [11:0] de_io_page_offset_i;
        reg [11:0] tb_io_page_offset_i;
        assign de_io_page_offset_i = tb_io_page_offset_i;
        
        wire de_io_page_offset_matches_o;        
        wire [134:0] de_io_amo_req_o;
        
        wire [64:0] de_io_amo_resp_i;
        reg [64:0] tb_io_amo_resp_i;
        assign de_io_amo_resp_i = 0; // tb_io_amo_resp_i;
        wire [34:0] de_io_req_port_i;
        reg [34:0] tb_io_req_port_i;
        assign de_io_req_port_i = tb_io_req_port_i;
        
        wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] de_io_req_port_o;

        task raise_store_request (input [31:0] vaddr, input [31:0] data);
            begin
                tb_io_valid_i = 1;
        // logic                           valid; 1 
        // logic [riscv::VLEN-1:0]         vaddr; 32
        // logic                           overflow; 1
        // riscv::xlen_t                   data; 32
        // logic [(riscv::XLEN/8)-1:0]     be; 4
        // fu_t                            fu; 4
        // fu_op                           operator; 8
        // logic [TRANS_ID_BITS-1:0]       trans_id; 3
                tb_io_lsu_ctrl_i = {1'b1, vaddr, 1'b0, data, 4'b0000, 4'b0010, 8'd39, 3'b000};
                tb_io_paddr_i = {2'b00, vaddr};
            end
        endtask
        task lower_store_request;
            begin
                tb_io_lsu_ctrl_i = 0;
                tb_io_valid_i = 0;
            end
        endtask

        task raise_commit;
            begin
                tb_io_commit_i = 1;
            end
        endtask
        task lower_commit;
            begin
                tb_io_commit_i = 0;
            end
        endtask

        task raise_memory_grant;
            begin
                tb_io_req_port_i = {1'b1, 34'b0};
            end
        endtask
        task lower_memory_grant;
            begin
                tb_io_req_port_i = {1'b0, 34'b0};
            end
        endtask

        task set_page_offset (input [11:0] page_offset);
            begin
                tb_io_page_offset_i = page_offset;
            end
        endtask

    store_unit su_i (
        .clk_i(clk),
        .rst_ni(reset),
        .flush_i(de_io_flush_i),
        .no_st_pending_o(de_io_no_st_pending_o),
        .store_buffer_empty_o(de_io_store_buffer_empty_o),
        .valid_i(de_io_valid_i),
        .lsu_ctrl_i(de_io_lsu_ctrl_i),
        .pop_st_o(de_io_pop_st_o),
        .commit_i(de_io_commit_i),
        .commit_ready_o(de_io_commit_ready_o),
        .amo_valid_commit_i(de_io_amo_valid_commit_i),
        .valid_o(de_io_valid_o),
        .trans_id_o(de_io_trans_id_o),
        .result_o(de_io_result_o),
        .ex_o(de_io_ex_o),
        .translation_req_o(de_io_translation_req_o),
        .vaddr_o(de_io_vaddr_o),
        .paddr_i(de_io_paddr_i),
        .ex_i(de_io_ex_i),
        .dtlb_hit_i(de_io_dtlb_hit_i),
        .page_offset_i(de_io_page_offset_i),
        .page_offset_matches_o(de_io_page_offset_matches_o),
        .amo_req_o(de_io_amo_req_o),
        .amo_resp_i(de_io_amo_resp_i),
        .req_port_i(de_io_req_port_i),
        .req_port_o(de_io_req_port_o)
    );

    wire [31:0] de_io_instr_i;
    reg [31:0] tb_io_instr_i;
    assign de_io_instr_i = tb_io_instr_i;
    wire de_io_instr_valid_i;
    reg tb_io_instr_valid_i;
    assign de_io_instr_valid_i = tb_io_instr_valid_i;
    wire de_io_store_mem_resp_i;
    reg tb_io_store_mem_resp_i;
    assign de_io_store_mem_resp_i = tb_io_store_mem_resp_i;

    cva6_su_model su_model_i (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .commit_i(tb_io_commit_i)
    );

    integer i;
    reg [1:0] choice_mem;
    reg choice_core;

    reg [1:0] store_seen;

    reg [33:0] vaddr;
    reg [31:0] data;
    reg [11:0] poffset;
    // reg [31:0] edata;

    initial begin

        $display("Running lifting!");

        store_seen = 0;
        lower_store_request();
        lower_memory_grant();
        lower_commit();
        #60;
        for (i = 0; i < 20; i=i+1) begin
            lower_store_request();
            lower_memory_grant();
            lower_commit();
            
            tb_io_store_mem_resp_i = 0;
            tb_io_instr_valid_i = 0;

            vaddr = $random(seed);
            data = $random(seed);
            poffset = $random(seed);
            choice_core = $random(seed);
            choice_mem = $random(seed);
            
            if (store_seen == 0) begin
                if (choice_core) begin
                    raise_store_request(vaddr, data);
                    store_seen = 2;


                    tb_io_instr_i = vaddr;
                    tb_io_instr_valid_i = 1;
                end
            end else begin
                if (store_seen == 1) begin
                    raise_commit();
                    // store_seen = 0;
                end
                store_seen = store_seen - 1;
            end

            if (&choice_mem) begin
                raise_memory_grant();

                tb_io_store_mem_resp_i = 1;
            end

            set_page_offset(poffset);
            
            #20;
        end    
    end
    
    endmodule
    
    
    