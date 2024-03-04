
import random

def make_testblock_by_seed(seed):
    return f"""

    module tlb_tb();
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

wire [30:0] tdata;
assign tdata = {{asid, vpn, 1'b0, 1'b1}}; // {{tb_io_update_i[40-:9], tb_io_update_i[60:51], tb_io_update_i[50:41], tb_io_update_i[61], 1'b1}};
wire [31:0] cdata;
assign cdata = edata; // tb_io_update_i[31-:32];

        initial begin
            CLK_CYCLE = 32'h0;
        end
        
        always @(posedge clk) begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        end

        initial begin
            $dumpfile("tlb_wave_pipeline.vcd");
            $dumpvars(0, tlb_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = {seed};

        // CSR tasks
        task make_tlb_lookup (input [19:0] vpn, input [8:0] asid);
            tb_io_update_i = 0;
            tb_io_lu_vaddr_i = {{vpn, 12'h000}};
            tb_io_lu_asid_i = asid;
            // Update stuff
            tb_io_flush_i = 0;
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
        endtask
        task make_tlb_update (input [19:0] vpn, input [8:0] asid, input [31:0] entry_data);
            tb_io_update_i = {{1'b1, 1'b0, vpn, asid, entry_data}};
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
            tb_io_vaddr_to_be_flushed_i = {{vpn, 12'h000}};
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
            .lu_hit_o(de_io_lu_hit_o)
        );

    integer i;
    reg [1:0] choice;
    reg [19:0] vpn;
    reg [8:0] asid;
    reg [31:0] edata;

        initial begin
            // Setup CSR
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;

        asid = 9'd1;
        vpn = $random(seed);
        edata = $random(seed);
        #20;
        for (i = 0; i < 20; i=i+1) begin
            choice = $random(seed);
            if (choice == 2'b00)
                make_tlb_update(vpn, asid, edata);
            else if (choice == 2'b01)
                make_tlb_flush(0, 0);
            else if (choice == 2'b10)
                make_tlb_lookup(vpn, 9'd1); 
            else
                make_tlb_flush(vpn, 9'd1);
            asid = 9'd1;
            vpn = $random(seed);
            edata = $random(seed);
            #20;
        end

            // make_tlb_update(20'd10, 9'd1, 32'hffffffff);
            // // make_csr_write(32'h0000007f, 32'hffffffff, 0);
            // #20;
            // make_tlb_lookup(20'd10, 9'd1);
            // #20
            // // make_csr_write(32'h00007f7f, 32'h00000000, 1);
            // make_tlb_flush(0, 0);
            // #20;
            // make_tlb_lookup(20'd10, 9'd1);
        end
    endmodule
    """

def make_testblock_by_program(instr_frames):
    seed = random.Random().randint(1, 1 << 10)
    def get_express_instr(iframe):
        return f"""
            tb_io_update_i = 63'd{iframe["update"]};
            tb_io_lu_vaddr_i = 0;
            tb_io_lu_asid_i = 0;
            // Flush
            tb_io_flush_i = 1'b{iframe["flush"]};
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
            #20;    
        """
    express_instr = "\n\n".join([get_express_instr(iframe) for iframe in instr_frames])

    return f"""

    module tlb_tb();
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

wire [30:0] tdata;
assign tdata = {{asid, vpn, 1'b0, 1'b1}}; // {{tb_io_update_i[40-:9], tb_io_update_i[60:51], tb_io_update_i[50:41], tb_io_update_i[61], 1'b1}};
wire [31:0] cdata;
assign cdata = edata; // tb_io_update_i[31-:32];

        initial begin
            CLK_CYCLE = 32'h0;
        end
        
        always @(posedge clk) begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        end

        initial begin
            $dumpfile("tlb_wave_pipeline.vcd");
            $dumpvars(0, tlb_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = {seed};

        // CSR tasks
        task make_tlb_lookup (input [19:0] vpn, input [8:0] asid);
            tb_io_update_i = 0;
            tb_io_lu_vaddr_i = {{vpn, 12'h000}};
            tb_io_lu_asid_i = asid;
            // Update stuff
            tb_io_flush_i = 0;
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
        endtask
        task make_tlb_update (input [19:0] vpn, input [8:0] asid, input [31:0] entry_data);
            tb_io_update_i = {{1'b1, 1'b0, vpn, asid, entry_data}};
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
            tb_io_vaddr_to_be_flushed_i = {{vpn, 12'h000}};
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
            .lu_hit_o(de_io_lu_hit_o)
        );

    integer i;
    reg [1:0] choice;
    reg [19:0] vpn;
    reg [8:0] asid;
    reg [31:0] edata;

        initial begin
            // Setup CSR
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;

        asid = 9'd1;
        vpn = $random(seed);
        edata = $random(seed);
        #20;
        for (i = 0; i < 1; i=i+1) begin
            choice = $random(seed);
            if (choice == 2'b00)
                make_tlb_update(vpn, asid, edata);
            else if (choice == 2'b01)
                make_tlb_flush(0, 0);
            else if (choice == 2'b10)
                make_tlb_lookup(vpn, 9'd1); 
            else
                make_tlb_flush(vpn, 9'd1);
            asid = 9'd1;
            vpn = $random(seed);
            edata = $random(seed);
            #20;
        end
        {express_instr}

        end
    endmodule
    """


def make_distinguish_block(t, assumes, block, asserts):
    return """


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
assign tdata = {{asid, vpn, 1'b0, 1'b1}}; // {{tb_io_update_i[40-:9], tb_io_update_i[60:51], tb_io_update_i[50:41], tb_io_update_i[61], 1'b1}};
wire [31:0] cdata;
assign cdata = edata; // tb_io_update_i[31-:32];

        // CSR tasks
        task make_tlb_lookup (input [19:0] vpn, input [8:0] asid);
            tb_io_update_i = 0;
            tb_io_lu_vaddr_i = {{vpn, 12'h000}};
            tb_io_lu_asid_i = asid;
            // Update stuff
            tb_io_flush_i = 0;
            tb_io_asid_to_be_flushed_i = 0;
            tb_io_vaddr_to_be_flushed_i = 0;
        endtask
        task make_tlb_update (input [19:0] vpn, input [8:0] asid, input [31:0] entry_data);
            tb_io_update_i = {{1'b1, 1'b0, vpn, asid, entry_data}};
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
            tb_io_vaddr_to_be_flushed_i = {{vpn, 12'h000}};
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

    if (CLK_CYCLE == {}) begin
        {}
    end else if (CLK_CYCLE == {}) begin
        {}
    end
    end


    endmodule
    """.format(t-1, ''.join(assumes) + ''.join(block), t, ''.join(asserts))
