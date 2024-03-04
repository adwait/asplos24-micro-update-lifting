


`define NUM_REGS    32
`define WORD_SIZE   32

// sodor_tb.v

module store_unit_model_tb (
    input clk
    // input [31:0] fe_in_io_imem_resp_bits_data,
    // output [`WORD_SIZE*`NUM_REGS-1:0] port_regfile
);
    
    reg reset;
    reg [2:0] counter;
    reg [4:0] CLK_CYCLE;
    reg init;

    initial begin
        reset = 1;
        init = 1;
        counter = 0;
        CLK_CYCLE = 0;
    end

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 0 && init) begin
            reset <= 0;
        end
        if (counter == 2 && init) begin
            reset <= 1;
        end
    end


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

    // wire [1:0] de_io_state_q_0_o;
    // wire [1:0] de_io_state_q_1_o;
    // wire [1:0] de_io_state_q_2_o;
    // wire [1:0] de_io_state_q_3_o;
    wire [7:0] de_io_store_state_o;

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
        .req_port_o(de_io_req_port_o),
        .store_state_o(de_io_store_state_o)
        // .state_q_0(de_io_state_q_0_o),
        // .state_q_1(de_io_state_q_1_o),
        // .state_q_2(de_io_state_q_2_o),
        // .state_q_3(de_io_state_q_3_o)
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

    wire mo_io_page_offset_matches_o;
    wire de_io_ready_o;

    wire [7:0] mo_io_state_q;

    cva6_su_model su_model_i (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .commit_i(de_io_commit_i), 
        .page_offset_i(de_io_page_offset_i),
        .page_offset_matches_o(mo_io_page_offset_matches_o),
        .ready_o(de_io_ready_o),
        .port_store_instr_queue_state(mo_io_state_q)
    );


    integer i;
    (* anyseq *) reg [1:0] choice_mem;
    (* anyseq *) reg choice_core;
    (* anyseq *) reg [33:0] vaddr;
    (* anyseq *) reg [31:0] data;
    (* anyseq *) reg [11:0] poffset;

    reg [1:0] store_seen;

    always @(posedge clk) begin

        if (init && counter < 2) begin
            
            store_seen = 0;
            lower_store_request();
            lower_memory_grant();
            lower_commit();

            tb_io_store_mem_resp_i = 0;
            tb_io_instr_valid_i = 0;

        end else begin

            lower_store_request();
            lower_memory_grant();
            lower_commit();
            
            tb_io_store_mem_resp_i = 0;
            tb_io_instr_valid_i = 0;
            
            if (store_seen == 0) begin
                if (choice_core && de_io_ready_o) begin
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

            assert((!(
                (de_io_page_offset_matches_o && !mo_io_page_offset_matches_o) ||
                (!de_io_page_offset_matches_o && mo_io_page_offset_matches_o)
            )) && (mo_io_state_q == de_io_store_state_o)
            );
        end        
    end

endmodule