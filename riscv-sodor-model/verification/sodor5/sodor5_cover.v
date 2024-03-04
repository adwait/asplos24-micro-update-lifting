// sodor_tb.v

`define OPCODE_INDEX_WIDTH  2
`define FUNCT3_WIDTH        3
`define FUNCT7_WIDTH        1
`define IMM_WIDTH           12
`define REG_ADDR_WIDTH      5
// `define MODEL_FULL
`define ITYPE

module sodor5_verif(
    input clk
);

    reg reset;
    reg past_reset;
    reg [2:0] counter;
    reg init;
    reg [31:0] prev_instr;
    initial begin
        past_reset = 1;
        reset = 1;
        init = 1;
        counter = 0;
    end

    // Inject based on some signal
    wire inject_instr;
    assign inject_instr = (counter == 7 && init);
    // (inject_instr) ? {imm_rep, rs1_rep, 3'b0, rd_rep, 7'b0010011} : 32'h00000013;

    wire [31:0] in_io_imem_resp_bits_data;
    // Insert a concrete instruction once every iteration
    
    // (inject_instr) ? {imm_rep, rs1_rep, 3'b0, rd_rep, 7'b0010011} : 32'h00000013;


`ifdef FORMAL

`ifdef ITYPE
    (* anyseq *) reg [11:0] imm;
    (* anyseq *) reg [4:0] rs1;
    (* anyseq *) reg [4:0] rs2;
    (* anyseq *) reg [4:0] rd;
    (* anyseq *) reg [2:0] funct3;
    wire [11:0] imm_clean;

    assign imm_clean = (funct3 == 5) ? (imm & 12'b010000011111) : ((funct3 == 1) ? (imm & 12'b000000011111) : imm);
    assign in_io_imem_resp_bits_data = reset ? 32'h00000013 : {imm_clean, rs1, funct3, rd, 7'b0010011};
`endif

`else
    assign in_io_imem_resp_bits_data = de_io_imem_req_valid ? instr : prev_instr;
`endif

    // Design signals
    wire [31:0] de_io_imem_req_bits_addr;
    wire de_io_imem_req_valid;
    wire [1023:0] de_io_port_regfile;
    wire [31:0] de_io_port_imm;
    wire [31:0] de_io_port_alu_out;
    wire [4:0] de_io_port_reg_rs1_addr_in;
    wire [4:0] de_io_port_reg_rs2_addr_in;
    wire [31:0] de_io_port_reg_rs1_data_out;
    wire [31:0] de_io_port_reg_rs2_data_out;
    wire [31:0] de_io_port_reg_rd_data_in;
    wire [4:0] de_io_port_reg_rd_addr_in;
    // Design signals 2
    wire [31:0] de_io_port_if_reg_pc;
    wire [31:0] de_io_port_dec_reg_pc;
    wire [31:0] de_io_port_exe_reg_pc;
    wire [31:0] de_io_port_mem_reg_pc;
    wire        de_io_port_lb_table_valid;
    wire [31:0] de_io_port_lb_table_addr;
    wire [31:0] de_io_port_lb_table_data;
    wire [31:0] de_io_port_mem_reg_alu_out;
    // Design control signals
    wire [31:0] de_io_port_dec_reg_inst;
    wire [31:0] de_io_port_exe_reg_inst;
    wire [31:0] de_io_port_mem_reg_inst;

    wire [4:0] de_io_port_dec_wbaddr;
    wire [4:0] de_io_port_exe_reg_wbaddr;
    wire [4:0] de_io_port_mem_reg_wbaddr;
    wire [31:0] de_io_port_imm_sbtype_sext;
    wire [3:0] de_io_port_alu_fun;
    wire de_io_port_mem_fcn;
    wire [2:0] de_io_port_mem_typ;

    CoreTop coretop (
        .clock(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid),
        .port_regfile(de_io_port_regfile),
        .port_imm(de_io_port_imm),
        .port_alu_out(de_io_port_alu_out),
        .port_reg_rs1_addr_in(de_io_port_reg_rs1_addr_in),
        .port_reg_rs2_addr_in(de_io_port_reg_rs2_addr_in),
        .port_reg_rs1_data_out(de_io_port_reg_rs1_data_out),
        .port_reg_rs2_data_out(de_io_port_reg_rs2_data_out),
        .port_reg_rd_data_in(de_io_port_reg_rd_data_in),
        .port_reg_rd_addr_in(de_io_port_reg_rd_addr_in),

        .port_dec_reg_inst(de_io_port_dec_reg_inst),
        .port_exe_reg_inst(de_io_port_exe_reg_inst),
        .port_mem_reg_inst(de_io_port_mem_reg_inst),
        .port_mem_reg_alu_out(de_io_port_mem_reg_alu_out),
        .port_if_reg_pc(de_io_port_if_reg_pc),
        .port_dec_reg_pc(de_io_port_dec_reg_pc),
        .port_exe_reg_pc(de_io_port_exe_reg_pc),
        .port_mem_reg_pc(de_io_port_mem_reg_pc),
        .port_lb_table_valid(de_io_port_lb_table_valid),
        .port_lb_table_addr(de_io_port_lb_table_addr),
        .port_lb_table_data(de_io_port_lb_table_data),

        .port_dec_wbaddr(de_io_port_dec_wbaddr),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr),
        .port_mem_reg_wbaddr(de_io_port_mem_reg_wbaddr),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext),
        .port_alu_fun(de_io_port_alu_fun),
        .port_mem_fcn(de_io_port_mem_fcn),
        .port_mem_typ(de_io_port_mem_typ)
    );

    always @(posedge clk) begin

    end

endmodule


