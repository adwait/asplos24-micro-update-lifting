`define NUM_REGS    32
`define WORD_SIZE   32

`define MODEL_FULL

module sodor5_model_tb();
    
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
        $dumpfile("sodor5_model_wave_pipeline.vcd");
        $dumpvars(0, sodor5_model_tb);
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
    wire [2:0] port_funct3;
    wire [31:0] port_imm;
    wire [31:0] port_alu_out;
    wire [4:0] port_reg_rs1_addr_in;
    wire [4:0] port_reg_rs2_addr_in;
    wire [31:0] port_reg_rs1_data_out;
    wire [31:0] port_reg_rs2_data_out;
    wire [31:0] port_reg_rd_data_in;
    wire [4:0] port_reg_rd_addr_in;


    assign tb_in_io_imem_resp_bits_data = (CLK_CYCLE == 8) ? 32'h00102223 : 32'h00000013;

    sodor5_model sf (
        .clk(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(tb_in_io_imem_resp_bits_data),
`ifdef MODEL_FULL
        .control_fetch_i(CLK_CYCLE != 11),
        // .control_shift_iq(1'b1),
`endif
        .port_regfile(port_regfile),
        .port_pc(port_pc),
        .port_funct3(port_funct3),
        .port_imm(port_imm),
        .port_alu_out(port_alu_out),
        .port_reg_rs1_addr_in(port_reg_rs1_addr_in),
        .port_reg_rs2_addr_in(port_reg_rs2_addr_in),
        .port_reg_rs1_data_out(port_reg_rs1_data_out),
        .port_reg_rs2_data_out(port_reg_rs2_data_out),
        .port_reg_rd_data_in(port_reg_rd_data_in),
        .port_reg_rd_addr_in(port_reg_rd_addr_in)
    );
endmodule