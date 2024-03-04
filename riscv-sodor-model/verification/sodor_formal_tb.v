`define NUM_REGS    32
`define WORD_SIZE   32

module sodor_formal_tb();
    
    parameter CLK_CYCLE_TIME = 10;
    parameter IMEM_INTERVAL = 30;
    parameter SIM_CYCLE = 100; // 100000000;
    parameter SIM_TIME = SIM_CYCLE * CLK_CYCLE_TIME * 2;

    reg [31:0] 			CLK_CYCLE;
    reg 				clk;
    reg 				reset;
    
    initial begin
        clk = 1;
        forever #CLK_CYCLE_TIME clk = ~clk;
    end
    initial begin
        reset = 1;
        // #IMEM_INTERVAL reset = 1;
        #IMEM_INTERVAL reset = 0;
    end
    initial begin
        CLK_CYCLE = 32'h0;
    end
    always @(posedge clk) begin
        CLK_CYCLE <= CLK_CYCLE + 1;
    end
    
    initial begin
        $dumpfile("sodor_formal_wave_pipeline.vcd");
        $dumpvars(0, sodor_formal_tb);
    end

    initial begin
        #IMEM_INTERVAL;
        #SIM_TIME;
        $finish;
    end

    wire [31:0] tb_in_io_imem_resp_bits_data;
    // wire [31:0] tb_ou_io_imem_req_bits_addr;
    // wire tb_ou_io_imem_req_valid;

    wire [`NUM_REGS*`WORD_SIZE-1:0] port_regfile;
    wire [31:0] port_pc;
    
    assign tb_in_io_imem_resp_bits_data = (CLK_CYCLE[0]) ? 32'h00200313 : 32'h04002283;

    sodor_formal sf (
        .clk(clk),
        .fe_in_io_imem_resp_bits_data(tb_in_io_imem_resp_bits_data),
        .port_regfile(port_regfile),
        .port_pc(port_pc),
    );
endmodule