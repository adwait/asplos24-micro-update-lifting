

    module store_buffer_tb();
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
            $dumpfile("store_buffer_wave_pipeline.vcd");
            $dumpvars(0, store_buffer_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = 100;

        localparam cva6_config_pkg_CVA6ConfigXlen = 32;
        localparam riscv_XLEN = cva6_config_pkg_CVA6ConfigXlen;
        localparam riscv_PLEN = 34;
        localparam cva6_config_pkg_CVA6ConfigDataUserEn = 0;
        localparam cva6_config_pkg_CVA6ConfigDataUserWidth = cva6_config_pkg_CVA6ConfigXlen;
        localparam ariane_pkg_DATA_USER_WIDTH = 1;
        localparam [31:0] ariane_pkg_DCACHE_USER_WIDTH = ariane_pkg_DATA_USER_WIDTH;
        localparam [31:0] ariane_pkg_CONFIG_L1D_SIZE = 32768;
        localparam [31:0] ariane_pkg_DCACHE_SET_ASSOC = 8;
        localparam [31:0] ariane_pkg_DCACHE_INDEX_WIDTH = $clog2(32'd32768 / 32'd8);
        localparam [31:0] ariane_pkg_DCACHE_TAG_WIDTH = riscv_PLEN - ariane_pkg_DCACHE_INDEX_WIDTH;
        localparam [31:0] ariane_pkg_DEPTH_SPEC = 4;
        localparam [31:0] ariane_pkg_DEPTH_COMMIT = 8;

        wire de_io_flush_i;
        reg tb_io_flush_i;
        assign de_io_flush_i = 0;
        // tb_io_flush_i;

        wire de_io_no_st_pending_o;
        wire de_io_store_buffer_empty_o;
        
        wire [11:0] de_io_page_offset_i;
        reg [11:0] tb_io_page_offset_i;
        assign de_io_page_offset_i = tb_io_page_offset_i;
        
        wire de_io_page_offset_matches_o;
        
        wire de_io_commit_i;
        reg tb_io_commit_i;
        assign de_io_commit_i = tb_io_commit_i;
        
        wire de_io_commit_ready_o;
        wire de_io_ready_o;
        
        wire de_io_valid_i;
        reg tb_io_valid_i;
        assign de_io_valid_i = tb_io_valid_i;
        wire de_io_valid_without_flush_i;
        reg tb_io_valid_without_flush_i;
        assign de_io_valid_without_flush_i = tb_io_valid_without_flush_i;
        wire [33:0] de_io_paddr_i;
        reg [33:0] tb_io_paddr_i;
        assign de_io_paddr_i = tb_io_paddr_i;
        wire [31:0] de_io_data_i;
        reg [31:0] tb_io_data_i;
        assign de_io_data_i = tb_io_data_i;
        wire [3:0] de_io_be_i;
        reg [3:0] tb_io_be_i;
        assign de_io_be_i = tb_io_be_i;
        wire [1:0] de_io_data_size_i;
        reg [1:0] tb_io_data_size_i;
        assign de_io_data_size_i = tb_io_data_size_i;
        wire [34:0] de_io_req_port_i;
        reg [34:0] tb_io_req_port_i;
        assign de_io_req_port_i = tb_io_req_port_i;
        
        wire [(((ariane_pkg_DCACHE_INDEX_WIDTH + ariane_pkg_DCACHE_TAG_WIDTH) + riscv_XLEN) + ariane_pkg_DCACHE_USER_WIDTH) + 9:0] de_io_req_port_o;


        task raise_store_request (input [33:0] paddr, input [31:0] data);
            begin
                tb_io_valid_i = 1;
                tb_io_valid_without_flush_i = 1;
                tb_io_paddr_i = paddr;
                tb_io_data_i = data;
                tb_io_be_i = 0;
                tb_io_data_size_i = 3;
            end
        endtask
        task lower_store_request;
            begin
                tb_io_valid_i = 0;
                tb_io_valid_without_flush_i = 0;
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

        // task raise_flush;
        //     begin
        //         tb_io_flush_i = 1;
        //     end
        // endtask
        // task lower_flush;
        //     begin
        //         tb_io_flush_i = 0;
        //     end
        // endtask

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

        task set_page_offset (input [11:0] page_offset);
            begin
                tb_io_page_offset_i = page_offset;
            end
        endtask




    store_buffer sb_i (
        .clk_i(clk),
        .rst_ni(reset),
        .flush_i(de_io_flush_i),
        .no_st_pending_o(de_io_no_st_pending_o),
        .store_buffer_empty_o(de_io_store_buffer_empty_o),
        .page_offset_i(de_io_page_offset_i),
        .page_offset_matches_o(de_io_page_offset_matches_o),
        .commit_i(de_io_commit_i),
        .commit_ready_o(de_io_commit_ready_o),
        .ready_o(de_io_ready_o),
        .valid_i(de_io_valid_i),
        .valid_without_flush_i(de_io_valid_without_flush_i),
        .paddr_i(de_io_paddr_i),
        .data_i(de_io_data_i),
        .be_i(de_io_be_i),
        .data_size_i(de_io_data_size_i),
        .req_port_i(de_io_req_port_i),
        .req_port_o(de_io_req_port_o)
    );

    integer i;
    reg [1:0] choice;
    reg [33:0] paddr;
    reg [31:0] data;
    reg [11:0] poffset;
    // reg [31:0] edata;

    initial begin
        #20;
        
        for (i = 0; i < 10; i=i+1) begin
            lower_store_request();
            lower_memory_grant();
            lower_commit();

            paddr = $random(seed);
            data = $random(seed);
            poffset = $random(seed);
            choice = $random(seed);
            
            if (choice == 2'b00)
                raise_store_request(paddr, data);
            else if (choice == 2'b01)
                raise_memory_grant();
            else if (choice == 2'b10)
                raise_commit();
            else
                set_page_offset(poffset);
            
            #20;
        end    
    end
    
    endmodule
    