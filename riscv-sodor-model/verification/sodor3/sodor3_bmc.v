// sodor_tb.v

// `define MODEL_FULL
`define ITYPE

module sodor3_verif(
    input clk,
    input [31:0] instr
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

    wire [31:0] in_io_imem_resp_bits_data;

`ifdef FORMAL
// Formal verification check, use this as the top module (and so spawn instructions here)

`ifdef ITYPE
    (* anyseq *) reg [11:0] imm;
    (* anyseq *) reg [4:0] rs1;
    (* anyseq *) reg [4:0] rs2;
    (* anyseq *) reg [4:0] rd;
    (* anyseq *) reg [2:0] funct3;
    wire [11:0] imm_clean;

    assign imm_clean = (funct3 == 5) ? (imm & 12'b010000011111) : ((funct3 == 1) ? (imm & 12'b000000011111) : imm);
    // tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : {imm_clean, rs1, funct3, rd, 7'b0010011};
    assign in_io_imem_resp_bits_data = reset ? 32'h00000013 : {imm_clean, rs1, funct3, rd, 7'b0010011};
    // tb_in_io_imem_resp_bits_data;
`endif
`else
// Testing/co-simulation check: spawn instructions in the *_tb module and only forward them in this file
    assign in_io_imem_resp_bits_data = de_io_imem_req_valid ? instr : prev_instr;
`endif


    // Model signals
    wire [3:0] mo_io_port_alu_fun;
    wire [31:0] mo_io_port_alu_out;
    wire [4:0] mo_io_port_exe_reg_wbaddr;
    wire [31:0] mo_io_port_imm_itype_sext;
    wire [31:0] mo_io_port_imm_sbtype_sext;
    wire [31:0] mo_io_port_imm_stype_sext;
    wire mo_io_port_mem_fcn;
    wire [2:0] mo_io_port_mem_typ;
    wire [4:0] mo_io_port_reg_rd_addr_in;
    wire [31:0] mo_io_port_reg_rd_data_in;
    wire [4:0] mo_io_port_reg_rs1_addr_in;
    wire [31:0] mo_io_port_reg_rs1_data_out;
    wire [4:0] mo_io_port_reg_rs2_addr_in;
    wire [31:0] mo_io_port_reg_rs2_data_out;
    wire [1023:0] mo_io_port_regfile;
    wire [31:0] mo_io_port_wb_reg_inst;
    wire [31:0] mo_io_port_wb_reg_pc;

    // Design signals
    wire [31:0] de_io_imem_req_bits_addr;
    wire de_io_imem_req_valid;
    
    wire [3:0] de_io_port_alu_fun;
    wire [31:0] de_io_port_alu_out;
    wire [4:0] de_io_port_exe_reg_wbaddr;
    wire [31:0] de_io_port_imm_itype_sext;
    wire [31:0] de_io_port_imm_sbtype_sext;
    wire [31:0] de_io_port_imm_stype_sext;
    wire de_io_port_mem_fcn;
    wire [2:0] de_io_port_mem_typ;
    wire [4:0] de_io_port_reg_rd_addr_in;
    wire [31:0] de_io_port_reg_rd_data_in;
    wire [4:0] de_io_port_reg_rs1_addr_in;
    wire [31:0] de_io_port_reg_rs1_data_out;
    wire [4:0] de_io_port_reg_rs2_addr_in;
    wire [31:0] de_io_port_reg_rs2_data_out;
    wire [1023:0] de_io_port_regfile;
    wire [31:0] de_io_port_wb_reg_inst;
    wire [31:0] de_io_port_wb_reg_pc;
    
    // Equality signals
    wire eq_alu_fun;
    wire eq_alu_out;
    wire eq_exe_reg_wbaddr;
    wire eq_imm_itype_sext;
    wire eq_imm_sbtype_sext;
    wire eq_imm_stype_sext;
    wire eq_mem_fcn;
    wire eq_mem_typ;
    wire eq_reg_rd_addr_in;
    wire eq_reg_rd_data_in;
    wire eq_reg_rs1_addr_in;
    wire eq_reg_rs1_data_out;
    wire eq_reg_rs2_addr_in;
    wire eq_reg_rs2_data_out;
    wire eq_regfile;
    wire eq_wb_reg_inst;
    wire eq_wb_reg_pc;
    assign eq_alu_fun = (mo_io_port_alu_fun == de_io_port_alu_fun);
    assign eq_alu_out = (mo_io_port_alu_out == de_io_port_alu_out);
    assign eq_exe_reg_wbaddr = (mo_io_port_exe_reg_wbaddr == de_io_port_exe_reg_wbaddr);
    assign eq_imm_itype_sext = (mo_io_port_imm_itype_sext == de_io_port_imm_itype_sext);
    assign eq_imm_sbtype_sext = (mo_io_port_imm_sbtype_sext == de_io_port_imm_sbtype_sext);
    assign eq_imm_stype_sext = (mo_io_port_imm_stype_sext == de_io_port_imm_stype_sext);
    assign eq_mem_fcn = (mo_io_port_mem_fcn == de_io_port_mem_fcn);
    assign eq_mem_typ = (mo_io_port_mem_typ == de_io_port_mem_typ);
    assign eq_reg_rd_addr_in = (mo_io_port_reg_rd_addr_in == de_io_port_reg_rd_addr_in);
    assign eq_reg_rd_data_in = (mo_io_port_reg_rd_data_in == de_io_port_reg_rd_data_in);
    assign eq_reg_rs1_addr_in = (mo_io_port_reg_rs1_addr_in == de_io_port_reg_rs1_addr_in);
    assign eq_reg_rs1_data_out = (mo_io_port_reg_rs1_data_out == de_io_port_reg_rs1_data_out);
    assign eq_reg_rs2_addr_in = (mo_io_port_reg_rs2_addr_in == de_io_port_reg_rs2_addr_in);
    assign eq_reg_rs2_data_out = (mo_io_port_reg_rs2_data_out == de_io_port_reg_rs2_data_out);
    assign eq_regfile = (mo_io_port_regfile == de_io_port_regfile);
    assign eq_wb_reg_inst = (mo_io_port_wb_reg_inst == de_io_port_wb_reg_inst);
    assign eq_wb_reg_pc = (mo_io_port_wb_reg_pc == de_io_port_wb_reg_pc);
    wire all_equal;
    assign all_equal = 
    // eq_alu_fun && 
    eq_alu_out && eq_exe_reg_wbaddr && eq_imm_itype_sext && eq_imm_sbtype_sext && eq_imm_stype_sext 
    // && eq_mem_fcn && eq_mem_typ 
    && eq_reg_rd_addr_in && eq_reg_rd_data_in && eq_reg_rs1_addr_in && eq_reg_rs1_data_out && eq_reg_rs2_addr_in && eq_reg_rs2_data_out && eq_regfile;
    //  && eq_wb_reg_inst && eq_wb_reg_pc;

    CoreTop coretop (
        .clock(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid),
        .port_alu_fun(de_io_port_alu_fun),
        .port_alu_out(de_io_port_alu_out),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr),
        .port_imm_itype_sext(de_io_port_imm_itype_sext),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext),
        .port_imm_stype_sext(de_io_port_imm_stype_sext),
        .port_mem_fcn(de_io_port_mem_fcn),
        .port_mem_typ(de_io_port_mem_typ),
        .port_reg_rd_addr_in(de_io_port_reg_rd_addr_in),
        .port_reg_rd_data_in(de_io_port_reg_rd_data_in),
        .port_reg_rs1_addr_in(de_io_port_reg_rs1_addr_in),
        .port_reg_rs1_data_out(de_io_port_reg_rs1_data_out),
        .port_reg_rs2_addr_in(de_io_port_reg_rs2_addr_in),
        .port_reg_rs2_data_out(de_io_port_reg_rs2_data_out),
        .port_regfile(de_io_port_regfile),
        .port_wb_reg_inst(de_io_port_wb_reg_inst),
        .port_wb_reg_pc(de_io_port_wb_reg_pc)
    );

    sodor3_model s3m (
        .clk(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        // Model output ports
        .port_alu_fun(de_io_port_alu_fun),
        .port_alu_out(mo_io_port_alu_out),
        .port_exe_reg_wbaddr(mo_io_port_exe_reg_wbaddr),
        .port_imm_itype_sext(mo_io_port_imm_itype_sext),
        .port_imm_sbtype_sext(mo_io_port_imm_sbtype_sext),
        .port_imm_stype_sext(mo_io_port_imm_stype_sext),
        .port_mem_fcn(de_io_port_mem_fcn),
        .port_mem_typ(de_io_port_mem_typ),
        .port_reg_rd_addr_in(mo_io_port_reg_rd_addr_in),
        .port_reg_rd_data_in(mo_io_port_reg_rd_data_in),
        .port_reg_rs1_addr_in(mo_io_port_reg_rs1_addr_in),
        .port_reg_rs1_data_out(mo_io_port_reg_rs1_data_out),
        .port_reg_rs2_addr_in(mo_io_port_reg_rs2_addr_in),
        .port_reg_rs2_data_out(mo_io_port_reg_rs2_data_out),
        .port_regfile(mo_io_port_regfile),
        .port_wb_reg_inst(mo_io_port_wb_reg_inst),
        .port_wb_reg_pc(mo_io_port_wb_reg_pc)
    );


    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end
        // Buffered version of previous instruction in the case that the core is not ready to accept fresh instructions
        prev_instr <= in_io_imem_resp_bits_data;

`ifdef FORMAL
    // TODO: add formal verification conditions here
`endif
    end

endmodule


