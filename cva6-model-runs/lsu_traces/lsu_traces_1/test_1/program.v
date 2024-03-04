


    module cva6_lsu_model_tb ();
        parameter PHASE_TIME = 10;
        parameter CLK_CYCLE_TIME = PHASE_TIME * 2;
        parameter IMEM_INTERVAL = 20;
        parameter SIM_CYCLE = 25; // 100000000;
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
            $dumpfile("lsu_model_wave_pipeline.vcd");
            $dumpvars(0, cva6_lsu_model_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = 917;

    reg [31:0] tb_io_instr_i;
    wire [31:0] de_io_instr_i;
    assign de_io_instr_i = tb_io_instr_i;
    reg tb_io_is_load_i;
    wire de_io_is_load_i;
    assign de_io_is_load_i = tb_io_is_load_i;
    reg tb_io_instr_valid_i;
    wire de_io_instr_valid_i;
    assign de_io_instr_valid_i = tb_io_instr_valid_i;


    reg tb_io_store_mem_resp_i;
    wire de_io_store_mem_resp_i;
    assign de_io_store_mem_resp_i = tb_io_store_mem_resp_i;
    reg tb_io_load_mem_resp_i;
    wire de_io_load_mem_resp_i;
    assign de_io_load_mem_resp_i = tb_io_load_mem_resp_i;

    wire de_io_ready_o;
    wire mo_io_ready_o;
    wire de_io_load_req_o;
    wire mo_io_load_req_o;

    wire de_io_store_commit_i;
    reg tb_io_store_commit_i;
    assign de_io_store_commit_i = tb_io_store_commit_i;

    cva6_lsu_shim shim_i (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i),
        .is_load_i(de_io_is_load_i),
        .store_commit_i(de_io_store_commit_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .load_mem_resp_i(de_io_load_mem_resp_i),
        .load_req_o(de_io_load_req_o),
        .ready_o(de_io_ready_o)
    );

    cva6_lsu_model model_i (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i),
        .is_load_i(de_io_is_load_i),
        .store_commit_i(de_io_store_commit_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .load_mem_resp_i(de_io_load_mem_resp_i),
        .load_req_o(mo_io_load_req_o),
        .ready_o(mo_io_ready_o)
    );

    
    reg load_state;
    reg store_state;
    reg store_uncommitted;

    reg choice;
    reg [31:0] addr;
    
    reg [1:0] wait_ctr;

    integer i;

    initial begin
        #20;
            load_state = 0;
            store_state = 0;
            store_uncommitted = 0;
            choice = 0;
            wait_ctr = 0;

            tb_io_instr_i = 32'd0;
            tb_io_instr_valid_i = 0;
            tb_io_load_mem_resp_i = 0;
            tb_io_store_mem_resp_i = 0;
            tb_io_store_commit_i = 0;

        #40;
    
    
        for (i = 0; i < 30; i = i + 1) begin
            
            choice = $random(seed);
            addr = 12'hcad; // $random(seed) % 2;
            
            if (wait_ctr == 0) begin
                choice = ((de_io_ready_o && mo_io_ready_o) || load_state) ? choice : 0;
                tb_io_store_commit_i = 0;
                if (choice) begin
                    if (!load_state && de_io_ready_o) begin
                        $display("load @ addr: %h", addr);
                        tb_io_instr_i = addr;
                        tb_io_is_load_i = 1;
                        tb_io_instr_valid_i = 1;
                        load_state = 1;
                        wait_ctr = 3;
                    end else begin
                        if (de_io_load_req_o && mo_io_load_req_o) begin
                            tb_io_load_mem_resp_i = 1;
                            tb_io_instr_valid_i = 0;
                            load_state = 0;
                            wait_ctr = 3;
                        end
                    end
                end else begin
                    if (!store_state && de_io_ready_o) begin
                        // if (!load_state) begin
                            $display("store @ addr: %h", addr);
                            tb_io_instr_i = addr;
                            tb_io_is_load_i = 0;
                            tb_io_instr_valid_i = 1;
                            store_state = 1;
                            store_uncommitted = 1;
                            wait_ctr = 3;
                        // end
                    end else begin
                        tb_io_store_mem_resp_i = 1;
                        tb_io_instr_valid_i = 0;
                        store_state = 0;
                        wait_ctr = 3;
                    end
                end
            end else begin
                if (wait_ctr == 1 && store_state && store_uncommitted) begin
                    tb_io_store_commit_i = 1;
                    store_uncommitted = 0;
                end
                wait_ctr = wait_ctr - 1;
                tb_io_instr_valid_i = 0;
                tb_io_instr_i = 32'd0;
                tb_io_load_mem_resp_i = 0;
                tb_io_store_mem_resp_i = 0;
            end

            #20;
        end

        wait_ctr = wait_ctr - 1;
        tb_io_instr_valid_i = 0;
        tb_io_instr_i = 32'd0;
        tb_io_load_mem_resp_i = 0;
        tb_io_store_mem_resp_i = 0;
    end
    
endmodule
    