
    module pmp_tb();
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
            reset = 1;
        end
        
        initial begin
            CLK_CYCLE = 32'h0;
        end
        
        always @(posedge clk) begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        end

        initial begin
            $dumpfile("pmp_wave_pipeline.vcd");
            $dumpvars(0, pmp_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        // Inputs to the CSR file
        wire [31:0] port_io_csr_wdata_i;
        wire [11:0] port_io_csr_addr_i;
        wire [7:0] port_io_csr_op_i;
        // And internal equivalents
        reg [31:0] tb_io_csr_wdata_i;
        reg [11:0] tb_io_csr_addr_i;
        reg [7:0] tb_io_csr_op_i;
        assign port_io_csr_wdata_i = tb_io_csr_wdata_i;
        assign port_io_csr_addr_i = tb_io_csr_addr_i;
        assign port_io_csr_op_i = tb_io_csr_op_i;

        // CSR tasks
        task make_csr_write (input [31:0] tin_pmpcfg_cfg_data, input [31:0] tin_pmpcfg_cfg_addr, input [3:0] tin_pmpcfg_addr);
            begin
                tb_io_csr_wdata_i = tin_pmpcfg_cfg_data;
                tb_io_csr_addr_i = {8'h3a, (tin_pmpcfg_addr >> 2)};
                tb_io_csr_op_i = 8'd31;
                #CLK_CYCLE_TIME
                tb_io_csr_wdata_i = tin_pmpcfg_cfg_addr;
                tb_io_csr_addr_i = {8'h3b, tin_pmpcfg_addr};
                tb_io_csr_op_i = 8'd31;
            end
        endtask
        task null_csr_input;
            begin
                tb_io_csr_wdata_i = 0;
                tb_io_csr_addr_i = 0;
                tb_io_csr_op_i = 0;
            end
        endtask
        
        // PMP tasks
        task make_pmp_check (input [PLEN-1:0] tin_io_addr_i, input [2:0] tin_io_access_type_i, input [1:0] tin_io_priv_lvl_i);
            begin
                tb_io_addr_i = tin_io_addr_i;
                tb_io_access_type_i = tin_io_access_type_i;
                tb_io_priv_lvl_i = tin_io_priv_lvl_i;
            end
        endtask

        // Parameters and I/O connections
        parameter [31:0] PLEN = 34;
	    parameter [31:0] PMP_LEN = 32;
	    parameter [31:0] NR_ENTRIES = 4;
        wire [PLEN - 1:0] port_io_addr_i;
        // access type 3'b010 (stores), 3'b001 (loads)
        wire [2:0] port_io_access_type_i;
        // priv level M (3), S(1), U(0)
        wire [1:0] port_io_priv_lvl_i;
        wire [(16 * PMP_LEN) - 1:0] port_io_conf_addr_i;
        wire [127:0] port_io_conf_i;
        wire port_io_allow_o;
        // And internal equivalents
        reg [PLEN-1:0] tb_io_addr_i;
        reg [2:0] tb_io_access_type_i;
        reg [1:0] tb_io_priv_lvl_i;
        assign port_io_addr_i = tb_io_addr_i;
        assign port_io_access_type_i = tb_io_access_type_i;
        assign port_io_priv_lvl_i = tb_io_priv_lvl_i;

        pmp pmp_i (
            .addr_i(port_io_addr_i),
            .access_type_i(port_io_access_type_i),
            .priv_lvl_i(port_io_priv_lvl_i),
            .conf_addr_i(port_io_conf_addr_i),
            .conf_i(port_io_conf_i),
            .allow_o(port_io_allow_o)
        );

        simple_csr_regfile csr_f (
            .clk_i(clk),
            .rst_ni(reset),
            .csr_wdata_i(port_io_csr_wdata_i),
            .csr_addr_i(port_io_csr_addr_i),
            .csr_op_i(port_io_csr_op_i),
            .pmpcfg_o(port_io_conf_i),
            .pmpaddr_o(port_io_conf_addr_i)
        );

        initial begin
            // Setup CSR
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;
            #IMEM_INTERVAL;
            make_csr_write(32'h0000000f, 32'h20000001, 0);
            // make_csr_write(32'h0000007f, 32'hffffffff, 0);
            #20;
            null_csr_input();
            #20
            // make_csr_write(32'h00007f7f, 32'h00000000, 1);
            #40;
            make_pmp_check(34'h080000000, 1, 0);

        end
    endmodule
