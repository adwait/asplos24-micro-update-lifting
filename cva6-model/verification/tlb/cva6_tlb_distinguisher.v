


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

wire [30:0] tdata;
assign tdata = {asid, vpn, 1'b0, 1'b1}; // {tb_io_update_i[40-:9], tb_io_update_i[60:51], tb_io_update_i[50:41], tb_io_update_i[61], 1'b1};
wire [31:0] cdata;
assign cdata = edata; // tb_io_update_i[31-:32];

        // CSR tasks
        task make_tlb_lookup (input [19:0] vpn, input [8:0] asid);
            tb_io_update_i = 0;
            tb_io_lu_vaddr_i = {vpn, 12'h000};
            tb_io_lu_asid_i = asid;
            // Update stuff
            tb_io_flush_i = 0;
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
        endtask
        task make_tlb_update (input [19:0] vpn, input [8:0] asid, input [31:0] entry_data);
            tb_io_update_i = {1'b1, 1'b0, vpn, asid, entry_data};
            tb_io_lu_vaddr_i = 0;
            tb_io_lu_asid_i = 0;
            // Do not update anything
            tb_io_flush_i = 0;
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
        endtask
        task make_tlb_flush(input [19:0] vpn, input [8:0] asid);
            tb_io_update_i = 0;
            tb_io_lu_vaddr_i = 0;
            tb_io_lu_asid_i = 0;
            // Flush
            tb_io_flush_i = 1;
            tb_io_asid_to_be_flushed_i = asid;
            tb_io_vaddr_to_be_flushed_i = {vpn, 12'h000};
        endtask

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
        reg tb_io_flush_i;
        assign de_io_flush_i = tb_io_flush_i;
        wire [62:0] de_io_update_i;
        reg [62:0] tb_io_update_i;
        assign de_io_update_i = tb_io_update_i;
        wire de_io_lu_access_i;
        reg tb_io_lu_access_i;
        assign de_io_lu_access_i = tb_io_lu_access_i;
        wire [ASID_WIDTH - 1:0] de_io_lu_asid_i;
        reg [ASID_WIDTH - 1:0] tb_io_lu_asid_i;
        assign de_io_lu_asid_i = tb_io_lu_asid_i;
        wire [31:0] de_io_lu_vaddr_i;
        reg [31:0] tb_io_lu_vaddr_i;
        assign de_io_lu_vaddr_i = tb_io_lu_vaddr_i;

        wire [31:0] de_io_lu_content_o;

        wire [ASID_WIDTH - 1:0] de_io_asid_to_be_flushed_i;
        reg [ASID_WIDTH - 1:0] tb_io_asid_to_be_flushed_i;
        assign de_io_asid_to_be_flushed_i = tb_io_asid_to_be_flushed_i;
        wire [31:0] de_io_vaddr_to_be_flushed_i;
        reg [31:0] tb_io_vaddr_to_be_flushed_i;
        assign de_io_vaddr_to_be_flushed_i = tb_io_vaddr_to_be_flushed_i;

        wire [127:0] de_io_port_content_q;
        wire [123:0] de_io_port_tags_q;

        wire de_io_lu_is_4M_o;
        wire de_io_lu_hit_o;

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
            .port_content_q_o(de_io_port_content_q),
            .port_tags_q_o(de_io_port_tags_q)
        );

    integer i;
    (* anyseq *) reg [1:0] choice;
    reg [1:0] choice_apply;
    (* anyseq *) reg [19:0] vpn;
    reg [19:0] vpn_apply;
    reg [8:0] asid;
    reg [8:0] asid_apply;
    (* anyseq *) reg [31:0] edata;
    reg [31:0] edata_apply;
    reg [1:0] choice;

        initial begin
            // Setup CSR
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;

        asid_apply <= asid;
        vpn_apply <= vpn;
        edata_apply <= edata;
        #20;
        for (i = 0; i < 20; i=i+1) begin
            if (choice == 2'b00)
                make_tlb_update(vpn_apply, asid_apply, edata_apply);
            else if (choice == 2'b01)
                make_tlb_flush(0, 0);
            else
                make_tlb_lookup(vpn_apply, asid_apply); 
            #20;
        end
        end

    // Distinguisher signals
    reg [123:0] copy1_tags_q;
    reg [127:0] copy1_content_q;
    reg [123:0] copy2_tags_q;
    reg [127:0] copy2_content_q;

    always @(posedge clk) begin
        assume(asid == 9'd1);
        counter <= counter + 1'b1;
        past_reset <= reset;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 1;
        end

    if (CLK_CYCLE == 6) begin
        copy1_tags_q = de_io_port_tags_q;
copy1_content_q = de_io_port_content_q;
copy2_tags_q = de_io_port_tags_q;
copy2_content_q = de_io_port_content_q;
copy1_tags_q[0] = 1'b0;
copy1_tags_q[31] = 1'b0;
copy1_tags_q[62] = 1'b0;
copy1_tags_q[93] = 1'b0;
copy2_tags_q = de_io_port_tags_q;
copy2_content_q = de_io_port_content_q;

    end else if (CLK_CYCLE == 7) begin
        assert ((! (((copy2_tags_q) == (de_io_port_tags_q)))) || (! (((copy2_content_q) == (de_io_port_content_q)))) || ((copy1_tags_q) == (copy2_tags_q)));
assert ((! (((copy2_tags_q) == (de_io_port_tags_q)))) || (! (((copy2_content_q) == (de_io_port_content_q)))) || ((copy1_content_q) == (copy2_content_q)));

    end
    end


    endmodule
    