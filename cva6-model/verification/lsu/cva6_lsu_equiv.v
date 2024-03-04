


`define NUM_REGS    32
`define WORD_SIZE   32

// sodor_tb.v

module cva6_lsu_model_tb (
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

    reg prev_ready_model;
    reg prev_ready_shim;

    wire [7:0] de_io_store_state_o;
    wire [1:0] de_io_load_state_o;

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
`ifdef EXPOSE_STATE
        , .store_state_o(de_io_store_state_o)
        , .load_state_o(de_io_load_state_o)
`endif
    );

    wire [7:0] mo_io_store_state_o;
    wire [1:0] mo_io_load_state_o;

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
`ifdef EXPOSE_STATE
        , .port_store_instr_queue_state(mo_io_store_state_o)
        , .port_load_instr_queue_state(mo_io_load_state_o)
`endif
    );

    reg load_state;
    reg store_state;
    reg store_uncommitted;

    (* anyseq *) reg choice;
    (* anyseq *) reg [31:0] addr;

    reg [1:0] wait_ctr;

    integer i;

    always @(posedge clk) begin

        if (init && counter < 2) begin
            load_state = 0;
            store_state = 0;
            store_uncommitted = 0;
            // choice = 0;
            wait_ctr = 0;

            tb_io_instr_i = 32'd0;
            tb_io_instr_valid_i = 0;
            tb_io_load_mem_resp_i = 0;
            tb_io_store_mem_resp_i = 0;
            tb_io_store_commit_i = 0;

        end else begin

            prev_ready_model <= mo_io_ready_o;
            prev_ready_shim <= de_io_ready_o;

            if (wait_ctr == 0) begin
                tb_io_store_commit_i = 0;

                if (((de_io_ready_o && mo_io_ready_o) || load_state) && choice) begin
                    if (!load_state && (de_io_ready_o && mo_io_ready_o)) begin
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
                    if (!store_state && (de_io_ready_o && mo_io_ready_o)) begin
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
                if (wait_ctr == 1 && store_uncommitted && store_state) begin
                    tb_io_store_commit_i = 1;
                    store_uncommitted = 0;
                end
                wait_ctr = wait_ctr - 1;
                tb_io_instr_valid_i = 0;
                tb_io_instr_i = 32'd0;
                tb_io_load_mem_resp_i = 0;
                tb_io_store_mem_resp_i = 0;
            end


            // assert(0);
            assert ((!(
                ((de_io_ready_o && prev_ready_shim) && (!mo_io_ready_o && !prev_ready_model)) ||
                ((!de_io_ready_o && !prev_ready_shim) && (mo_io_ready_o && prev_ready_model))
            )) &&
                (mo_io_store_state_o == de_io_store_state_o) && (mo_io_load_state_o == de_io_load_state_o)
            );
        end        
    end

endmodule