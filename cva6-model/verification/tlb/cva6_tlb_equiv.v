

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
        // wire de_io_clk_i;
        // reg tb_io_clk_i;
        // assign de_io_clk_i = tb_io_clk_i;
        // wire de_io_rst_ni;
        // reg tb_io_rst_ni;
        // assign de_io_rst_ni = tb_io_rst_ni;
        wire de_io_flush_i;
        wire mo_io_flush_i;
        (* anyseq *) reg tb_io_flush_i;
        assign de_io_flush_i = tb_io_flush_i;
        assign mo_io_flush_i = tb_io_flush_i;
        wire [62:0] de_io_update_i;
        wire [62:0] mo_io_update_i;
        (* anyseq *) reg [62:0] tb_io_update_i;
        assign de_io_update_i = tb_io_update_i;
        assign mo_io_update_i = tb_io_update_i;
        wire de_io_lu_access_i;
        wire mo_io_lu_access_i;
        (* anyseq *) reg tb_io_lu_access_i;
        assign de_io_lu_access_i = tb_io_lu_access_i;
        assign mo_io_lu_access_i = tb_io_lu_access_i;
        wire [ASID_WIDTH - 1:0] de_io_lu_asid_i;
        wire [ASID_WIDTH - 1:0] mo_io_lu_asid_i;
        (* anyseq *) reg [ASID_WIDTH - 1:0] tb_io_lu_asid_i;
        assign de_io_lu_asid_i = tb_io_lu_asid_i;
        assign mo_io_lu_asid_i = tb_io_lu_asid_i;
        wire [31:0] de_io_lu_vaddr_i;
        wire [31:0] mo_io_lu_vaddr_i;
        (* anyseq *) reg [31:0] tb_io_lu_vaddr_i;
        assign de_io_lu_vaddr_i = tb_io_lu_vaddr_i;
        assign mo_io_lu_vaddr_i = tb_io_lu_vaddr_i;

        wire [31:0] de_io_lu_content_o;
        wire [31:0] mo_io_lu_content_o;

        wire [ASID_WIDTH - 1:0] de_io_asid_to_be_flushed_i;
        wire [ASID_WIDTH - 1:0] mo_io_asid_to_be_flushed_i;
        reg [ASID_WIDTH - 1:0] tb_io_asid_to_be_flushed_i = 0;
        assign de_io_asid_to_be_flushed_i = tb_io_asid_to_be_flushed_i;
        assign mo_io_asid_to_be_flushed_i = tb_io_asid_to_be_flushed_i;
        wire [31:0] de_io_vaddr_to_be_flushed_i;
        wire [31:0] mo_io_vaddr_to_be_flushed_i;
        reg [31:0] tb_io_vaddr_to_be_flushed_i = 0;
        assign de_io_vaddr_to_be_flushed_i = tb_io_vaddr_to_be_flushed_i;
        assign mo_io_vaddr_to_be_flushed_i = tb_io_vaddr_to_be_flushed_i;

        wire de_io_lu_is_4M_o;
        wire mo_io_lu_is_4M_o;
        wire de_io_lu_hit_o;
        wire mo_io_lu_hit_o;

        wire [(TLB_ENTRIES * 31) - 1:0] mo_io_tags_q;
        wire [(TLB_ENTRIES * 32) - 1:0] mo_io_content_q;
        wire [(TLB_ENTRIES * 31) - 1:0] de_io_tags_q;
        wire [(TLB_ENTRIES * 32) - 1:0] de_io_content_q;
        wire [TLB_ENTRIES-1:0] de_io_replace_en;

        cva6_tlb_sv32 tlb_i (
            .clk_i(clk),
            .rst_ni(reset),
            .flush_i(de_io_flush_i),
            .update_i(de_io_update_i),
            .lu_access_i(de_io_lu_access_i),
            .lu_asid_i(de_io_lu_asid_i),
            .lu_vaddr_i(de_io_lu_vaddr_i),
            .lu_content_o(de_io_lu_content_o),
            .asid_to_be_flushed_i(de_io_asid_to_be_flushed_i),
            .vaddr_to_be_flushed_i(de_io_vaddr_to_be_flushed_i),
            .lu_is_4M_o(de_io_lu_is_4M_o),
            .lu_hit_o(de_io_lu_hit_o),

            .port_content_q_o(de_io_content_q),
            .port_tags_q_o(de_io_tags_q),
            .port_replace_en_o(de_io_replace_en)
        );

        cva6_tlb_model model (
            .clk_i(clk),
            .rst_ni(reset),
            .flush_i(mo_io_flush_i),
            .update_i(mo_io_update_i),
            .lu_access_i(mo_io_lu_access_i),
            .lu_asid_i(mo_io_lu_asid_i),
            .lu_vaddr_i(mo_io_lu_vaddr_i),
            .lu_content_o(mo_io_lu_content_o),
            .asid_to_be_flushed_i(mo_io_asid_to_be_flushed_i),
            .vaddr_to_be_flushed_i(mo_io_vaddr_to_be_flushed_i),
            .lu_is_4M_o(mo_io_lu_is_4M_o),
            .lu_hit_o(mo_io_lu_hit_o),

            .port_io_tags_q(mo_io_tags_q),
	        .port_io_content_q(mo_io_content_q),
            .port_io_replace_en(de_io_replace_en)
        );


    always @(posedge clk ) begin
        counter <= counter + 1;
        if (init && counter > 1) begin
            reset <= 1;
        end
        if (init && counter == 3) begin
            assume(tb_io_update_i == 0);
            init <= 0;
        end 
        if (reset) begin
            assert(mo_io_content_q == de_io_content_q);
            assert(mo_io_tags_q == de_io_tags_q);
        end
    end

    endmodule
    