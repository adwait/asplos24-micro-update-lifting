

    module tlb_tb (
        input clk
    );

        reg reset_n;
        reg [7:0] counter;
        reg init;

        initial begin
            reset = 0;
            counter = 0;
            init = 1;
        end

        // // CSR tasks
        // task make_tlb_lookup (input [19:0] vpn, input [8:0] asid);
        //     tb_io_update_i = 0;
        //     tb_io_lu_vaddr_i = {vpn, 12'h000};
        //     tb_io_lu_asid_i = asid;
        //     // Update stuff
        //     tb_io_flush_i = 0;
        //     tb_io_asid_to_be_flushed_i = 0;
        //     tb_io_vaddr_to_be_flushed_i = 0;
        // endtask
        // task make_tlb_update (input [19:0] vpn, input [8:0] asid, input [31:0] entry_data);
        //     tb_io_update_i = {1'b1, 1'b0, vpn, asid, entry_data};
        //     tb_io_lu_vaddr_i = 0;
        //     tb_io_lu_asid_i = 0;
        //     // Do not update anything
        //     tb_io_flush_i = 0;
        //     tb_io_asid_to_be_flushed_i = 0;
        //     tb_io_vaddr_to_be_flushed_i = 0;
        // endtask
        // task make_tlb_flush(input [19:0] vpn, input [8:0] asid);
        //     tb_io_update_i = 0;
        //     tb_io_lu_vaddr_i = 0;
        //     tb_io_lu_asid_i = 0;
        //     // Flush
        //     tb_io_flush_i = 1;
        //     tb_io_asid_to_be_flushed_i = asid;
        //     tb_io_vaddr_to_be_flushed_i = {vpn, 12'h000};
        // endtask

        // Parameters and I/O connections
        parameter [31:0] TLB_ENTRIES = 4;
        parameter [31:0] ASID_WIDTH = 1;
        localparam cva6_config_pkg_CVA6ConfigXlen = 32;
        localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
        localparam riscv_VLEN = 32;        
        
        wire de_io_flush_i_0;
        wire de_io_flush_i_1;
        (* anyseq *) reg tb_io_flush_i;
        assign de_io_flush_i_0 = tb_io_flush_i;
        assign de_io_flush_i_1 = tb_io_flush_i;

        wire [62:0] de_io_update_i_0;
        wire [62:0] de_io_update_i_1;
        (* anyseq *) reg [62:0] tb_io_update_i_0;
        (* anyseq *) reg [62:0] tb_io_update_i_1;
        assign de_io_update_i_0 = tb_io_update_i_0;
        assign de_io_update_i_1 = tb_io_update_i_1;

        // Lookup
        wire de_io_lu_access_i_0;
        wire de_io_lu_access_i_1;
        reg tb_io_lu_access_i = 0;
        assign de_io_lu_access_i_0 = tb_io_lu_access_i;
        assign de_io_lu_access_i_1 = tb_io_lu_access_i;
        wire [ASID_WIDTH - 1:0] de_io_lu_asid_i_0;
        wire [ASID_WIDTH - 1:0] de_io_lu_asid_i_1;
        reg [ASID_WIDTH - 1:0] tb_io_lu_asid_i = 0;
        assign de_io_lu_asid_i_0 = tb_io_lu_asid_i;
        assign de_io_lu_asid_i_1 = tb_io_lu_asid_i;
        wire [31:0] de_io_lu_vaddr_i_0;
        wire [31:0] de_io_lu_vaddr_i_1;
        reg [31:0] tb_io_lu_vaddr_i = 0;
        assign de_io_lu_vaddr_i_0 = tb_io_lu_vaddr_i;
        assign de_io_lu_vaddr_i_1 = tb_io_lu_vaddr_i;
        wire [31:0] de_io_lu_content_o_0;
        wire [31:0] de_io_lu_content_o_1;

        wire [ASID_WIDTH - 1:0] de_io_asid_to_be_flushed_i_0;
        wire [ASID_WIDTH - 1:0] de_io_asid_to_be_flushed_i_1;
        reg [ASID_WIDTH - 1:0] tb_io_asid_to_be_flushed_i = 0;
        assign de_io_asid_to_be_flushed_i_0 = tb_io_asid_to_be_flushed_i;
        assign de_io_asid_to_be_flushed_i_1 = tb_io_asid_to_be_flushed_i;
        wire [31:0] de_io_vaddr_to_be_flushed_i_0;
        wire [31:0] de_io_vaddr_to_be_flushed_i_1;
        reg [31:0] tb_io_vaddr_to_be_flushed_i = 0;
        assign de_io_vaddr_to_be_flushed_i_0 = tb_io_vaddr_to_be_flushed_i;
        assign de_io_vaddr_to_be_flushed_i_1 = tb_io_vaddr_to_be_flushed_i;

        wire de_io_lu_is_4M_o_0;
        wire de_io_lu_is_4M_o_1;
        wire de_io_lu_hit_o_0;
        wire de_io_lu_hit_o_1;

        wire [(TLB_ENTRIES * 31) - 1:0] de_io_tags_q_0;
        wire [(TLB_ENTRIES * 31) - 1:0] de_io_tags_q_1;
        wire [(TLB_ENTRIES * 32) - 1:0] de_io_content_q_0;
        wire [(TLB_ENTRIES * 32) - 1:0] de_io_content_q_1;
        wire [TLB_ENTRIES-1:0] de_io_replace_en_0;
        wire [TLB_ENTRIES-1:0] de_io_replace_en_1;

        cva6_tlb_sv32 tlb_i_0 (
            .clk_i(clk),
            .rst_ni(reset),
            .flush_i(de_io_flush_i_0),
            .update_i(de_io_update_i_0),
            .lu_access_i(de_io_lu_access_i_0),
            .lu_asid_i(de_io_lu_asid_i_0),
            .lu_vaddr_i(de_io_lu_vaddr_i_0),
            .lu_content_o(de_io_lu_content_o_0),
            .asid_to_be_flushed_i(de_io_asid_to_be_flushed_i_0),
            .vaddr_to_be_flushed_i(de_io_vaddr_to_be_flushed_i_0),
            .lu_is_4M_o(de_io_lu_is_4M_o_0),
            .lu_hit_o(de_io_lu_hit_o_0),

            .port_content_q_o(de_io_content_q_0),
            .port_tags_q_o(de_io_tags_q_0),
            .port_replace_en_o(de_io_replace_en_0)
        );

        cva6_tlb_sv32 tlb_i_1 (
            .clk_i(clk),
            .rst_ni(reset),
            .flush_i(de_io_flush_i_1),
            .update_i(de_io_update_i_1),
            .lu_access_i(de_io_lu_access_i_1),
            .lu_asid_i(de_io_lu_asid_i_1),
            .lu_vaddr_i(de_io_lu_vaddr_i_1),
            .lu_content_o(de_io_lu_content_o_1),
            .asid_to_be_flushed_i(de_io_asid_to_be_flushed_i_1),
            .vaddr_to_be_flushed_i(de_io_vaddr_to_be_flushed_i_1),
            .lu_is_4M_o(de_io_lu_is_4M_o_1),
            .lu_hit_o(de_io_lu_hit_o_1),

            .port_content_q_o(de_io_content_q_1),
            .port_tags_q_o(de_io_tags_q_1),
            .port_replace_en_o(de_io_replace_en_1)
        );

    always @(posedge clk ) begin
        counter <= counter + 1;
        if (init && counter > 1) begin
            reset <= 1;
        end
        if (init && counter == 3) begin
            init <= 0;
        end 
        if (counter > 6) begin
            assume(tb_io_update_i_0 == tb_io_update_i_1);
            assume(tb_io_update_i_0[62]);
            assume(tb_io_update_i_1[62]);
            assume(!tb_io_flush_i);
        end
        if (counter == 16) begin
            assert(de_io_content_q_0 == de_io_content_q_1);
        end
    end

    endmodule
    