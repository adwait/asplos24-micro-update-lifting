// sodor_tb.v

`define OPCODE_INDEX_WIDTH  2
`define FUNCT3_WIDTH        3
`define FUNCT7_WIDTH        1
`define IMM_WIDTH           12
`define REG_ADDR_WIDTH      5
// `define MODEL_FULL

module sodor5_verif(
    input clk,
    input [31:0] instr
    // input [`OPCODE_INDEX_WIDTH-1:0] opcode_rep,
    // input [`REG_ADDR_WIDTH-1:0]     rs1_rep,
    // input [`REG_ADDR_WIDTH-1:0]     rs2_rep,
    // input [`REG_ADDR_WIDTH-1:0]     rd_rep,
    // input [`IMM_WIDTH-1:0]          imm_rep,
    // input [`FUNCT3_WIDTH-1:0]       funct3_rep,
    // input [`FUNCT7_WIDTH-1:0]       funct7_rep
);

    reg reset;
    reg past_reset;
    reg [2:0] counter;
    reg init;
    reg [31:0] prev_instr;
    wire [31:0] curr_instr;
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
`elsif RTYPE
    (* anyseq *) reg [11:0] imm, imm_l;
    (* anyseq *) reg [4:0] rs1;
    (* anyseq *) reg [4:0] rs2;
    (* anyseq *) reg [4:0] rd;
    (* anyseq *) reg [2:0] funct3;
    (* anyseq *) reg [6:0] funct7;
    
    assign curr_instr = reset ? 32'h00000013 : {7'd0, rs2, rs1, funct3, rd, 7'b0110011};
    assign in_io_imem_resp_bits_data = de_io_imem_req_valid ? curr_instr : prev_instr;
`elsif ILSTYPE
    (* anyseq *) reg [11:0] imm, imm_l;
    (* anyseq *) reg [4:0] rs1;
    (* anyseq *) reg [4:0] rs2;
    (* anyseq *) reg [4:0] rd;
    (* anyseq *) reg [2:0] funct3;
    (* anyseq *) reg [1:0] ils_choice;
    wire [11:0] imm_clean;

    assign imm_clean = (funct3 == 5) ? (imm & 12'b010000011111) : ((funct3 == 1) ? (imm & 12'b000000011111) : imm);
    assign curr_instr = reset ? 32'h00000013 : 
        ils_choice[1] ? {imm_clean, rs1, funct3, rd, 7'b0010011} : (
            (ils_choice[0] ? {imm_l[11:5], rs2, rs1, 3'b0, imm_l[4:0], 7'b0100011} : {imm_l, rs1, 3'b0, rd, 7'b0000011})
        );
    assign in_io_imem_resp_bits_data = de_io_imem_req_valid ? curr_instr : prev_instr;
`endif

`else
    assign in_io_imem_resp_bits_data = de_io_imem_req_valid ? instr : prev_instr;
`endif


    // Model signals
    wire [1023:0] mo_io_port_regfile;
    wire [31:0] mo_io_port_pc;
    wire [2:0] mo_io_port_funct3;
    wire [11:0] mo_io_port_imm_inter;
    wire [31:0] mo_io_port_imm;
    wire [31:0] mo_io_port_alu_op1;
    wire [31:0] mo_io_port_alu_op2;
    wire [31:0] mo_io_port_alu_out;
    wire [4:0] mo_io_port_reg_rs1_addr_in;
    wire [4:0] mo_io_port_reg_rs2_addr_in;
    wire [31:0] mo_io_port_reg_rs1_data_out;
    wire [31:0] mo_io_port_reg_rs2_data_out;
    wire [31:0] mo_io_port_reg_rd_data_in;
    wire [4:0] mo_io_port_reg_rd_addr_in;
    // Model signals 2
    wire [31:0] mo_io_port_if_reg_pc;
    wire [31:0] mo_io_port_dec_reg_pc;
    wire [31:0] mo_io_port_exe_reg_pc;
    wire [31:0] mo_io_port_mem_reg_pc;
    wire        mo_io_port_lb_table_valid;
    wire [31:0] mo_io_port_lb_table_addr;
    wire [31:0] mo_io_port_lb_table_data;
    wire [31:0] mo_io_port_mem_reg_alu_out;
    // Model control signals
    wire [31:0] mo_io_port_dec_reg_inst;
    wire [31:0] mo_io_port_exe_reg_inst;
    wire [31:0] mo_io_port_mem_reg_inst;

    wire [4:0] mo_io_port_dec_wbaddr;
    wire [4:0] mo_io_port_exe_reg_wbaddr;
    wire [4:0] mo_io_port_mem_reg_wbaddr;
    wire [31:0] mo_io_port_imm_sbtype_sext;

    wire [31:0] mo_io_port_dmem_resp_bits_data;
    wire mo_io_port_dmem_resp_valid;
    wire mo_io_port_dmem_req_ready;

    wire port_done;
    wire port_start;

    // Design signals
    wire [31:0] de_io_imem_req_bits_addr;
    wire de_io_imem_req_valid;
    wire [1023:0] de_io_port_regfile;
    wire [31:0] de_io_port_imm;
    wire [31:0] de_io_port_alu_op1;
    wire [31:0] de_io_port_alu_op2;
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

    wire de_io_port_dmem_req_ready;
    wire [31:0] de_io_port_dmem_resp_bits_data;
    wire de_io_port_dmem_resp_valid;

    // Equality signals
    wire eq_imem_req_bits_addr;
    wire eq_imem_req_valid;
    wire eq_port_regfile;
    wire eq_port_imm;
    wire eq_port_alu_op1;
    wire eq_port_alu_op2;
    wire eq_port_alu_out;
    wire eq_port_reg_rs1_addr_in;
    wire eq_port_reg_rs2_addr_in;
    wire eq_port_reg_rs1_data_out;
    wire eq_port_reg_rs2_data_out;
    wire eq_port_reg_rd_data_in;
    wire eq_port_reg_rd_addr_in;
    wire eq_port_if_reg_pc;
    wire eq_port_dec_reg_pc;
    wire eq_port_exe_reg_pc;
    wire eq_port_mem_reg_pc;
    wire eq_port_lb_table_valid;
    wire eq_port_lb_table_addr;
    wire eq_port_lb_table_data;
    wire eq_port_mem_reg_alu_out;
    wire eq_port_dec_wbaddr;
    wire eq_port_exe_reg_wbaddr;
    wire eq_port_mem_reg_wbaddr;
    wire eq_port_imm_sbtype_sext;
    wire eq_port_alu_fun;
    assign eq_port_regfile = (de_io_port_regfile == mo_io_port_regfile);
    assign eq_port_imm = (de_io_port_imm == mo_io_port_imm);
    assign eq_port_alu_op1 = (de_io_port_alu_op1 == mo_io_port_alu_op1);
    assign eq_port_alu_op2 = (de_io_port_alu_op2 == mo_io_port_alu_op2);
    assign eq_port_alu_out = (de_io_port_alu_out == mo_io_port_alu_out);
    assign eq_port_reg_rs1_addr_in = (de_io_port_reg_rs1_addr_in == mo_io_port_reg_rs1_addr_in);
    assign eq_port_reg_rs2_addr_in = (de_io_port_reg_rs2_addr_in == mo_io_port_reg_rs2_addr_in);
    assign eq_port_reg_rs1_data_out = (de_io_port_reg_rs1_data_out == mo_io_port_reg_rs1_data_out);
    assign eq_port_reg_rs2_data_out = (de_io_port_reg_rs2_data_out == mo_io_port_reg_rs2_data_out);
    assign eq_port_reg_rd_data_in = (de_io_port_reg_rd_data_in == mo_io_port_reg_rd_data_in);
    assign eq_port_reg_rd_addr_in = (de_io_port_reg_rd_addr_in == mo_io_port_reg_rd_addr_in);
    assign eq_port_if_reg_pc = (de_io_port_if_reg_pc == mo_io_port_if_reg_pc);
    assign eq_port_dec_reg_pc = (de_io_port_dec_reg_pc == mo_io_port_dec_reg_pc);
    assign eq_port_exe_reg_pc = (de_io_port_exe_reg_pc == mo_io_port_exe_reg_pc);
    assign eq_port_mem_reg_pc = (de_io_port_mem_reg_pc == mo_io_port_mem_reg_pc);
    assign eq_port_lb_table_valid = (de_io_port_lb_table_valid == mo_io_port_lb_table_valid);
    assign eq_port_lb_table_addr = (de_io_port_lb_table_addr == mo_io_port_lb_table_addr);
    assign eq_port_lb_table_data = (de_io_port_lb_table_data == mo_io_port_lb_table_data);
    assign eq_port_mem_reg_alu_out = (de_io_port_mem_reg_alu_out == mo_io_port_mem_reg_alu_out);
    assign eq_port_dec_wbaddr = (de_io_port_dec_wbaddr == mo_io_port_dec_wbaddr);
    assign eq_port_exe_reg_wbaddr = (de_io_port_exe_reg_wbaddr == mo_io_port_exe_reg_wbaddr);
    assign eq_port_mem_reg_wbaddr = (de_io_port_mem_reg_wbaddr == mo_io_port_mem_reg_wbaddr);
    assign eq_port_imm_sbtype_sext = (de_io_port_imm_sbtype_sext == mo_io_port_imm_sbtype_sext);
    wire all_equal;
    assign all_equal = eq_port_regfile && eq_port_imm && eq_port_alu_out && eq_port_reg_rs1_addr_in && eq_port_reg_rs2_addr_in && eq_port_reg_rs1_data_out && eq_port_reg_rs2_data_out && eq_port_reg_rd_data_in && eq_port_reg_rd_addr_in
    && eq_port_alu_op1 && eq_port_alu_op2 
    // eq_port_if_reg_pc && eq_port_dec_reg_pc && eq_port_exe_reg_pc && eq_port_mem_reg_pc 
    // && eq_port_lb_table_valid && eq_port_lb_table_addr && eq_port_lb_table_data 
    && eq_port_mem_reg_alu_out && eq_port_dec_wbaddr && eq_port_exe_reg_wbaddr && eq_port_mem_reg_wbaddr && eq_port_imm_sbtype_sext;

    CoreTop coretop (
        .clock(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid),
        .port_regfile(de_io_port_regfile),
        .port_imm(de_io_port_imm),
        .port_exe_alu_op1(de_io_port_alu_op1),
        .port_exe_alu_op2(de_io_port_alu_op2),
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

`ifdef FORMAL
    `ifdef ILSTYPE
        .fe_in_io_dmem_req_ready(de_io_port_dmem_req_ready),
        .fe_in_io_dmem_resp_bits_data(de_io_port_dmem_resp_bits_data),
        .fe_in_io_dmem_resp_valid(de_io_port_dmem_resp_valid),
    `endif
`endif

        .port_dec_wbaddr(de_io_port_dec_wbaddr),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr),
        .port_mem_reg_wbaddr(de_io_port_mem_reg_wbaddr),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext),
        .port_alu_fun(de_io_port_alu_fun),
        .port_mem_fcn(de_io_port_mem_fcn),
        .port_mem_typ(de_io_port_mem_typ)
    );

    sodor5_model s5m (
        .clk(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .port_regfile(mo_io_port_regfile),
        .port_pc(mo_io_port_pc),
        .port_funct3(mo_io_port_funct3),
        .port_imm(mo_io_port_imm),
`ifdef MODEL_FULL
        .control_fetch_i(1'b1),
        .control_shift_iq(1'b1),
`endif
        .port_alu_op1(mo_io_port_alu_op1),
        .port_alu_op2(mo_io_port_alu_op2),
        .port_alu_out(mo_io_port_alu_out),
        .port_reg_rs1_addr_in(mo_io_port_reg_rs1_addr_in),
        .port_reg_rs2_addr_in(mo_io_port_reg_rs2_addr_in),
        .port_reg_rs1_data_out(mo_io_port_reg_rs1_data_out),
        .port_reg_rs2_data_out(mo_io_port_reg_rs2_data_out),
        .port_reg_rd_data_in(mo_io_port_reg_rd_data_in),
        .port_reg_rd_addr_in(mo_io_port_reg_rd_addr_in),

    
        .port_if_reg_pc(mo_io_port_if_reg_pc),
        .port_dec_reg_pc(mo_io_port_dec_reg_pc),
        .port_exe_reg_pc(mo_io_port_exe_reg_pc),
        .port_mem_reg_pc(mo_io_port_mem_reg_pc),
        .port_lb_table_valid(mo_io_port_lb_table_valid),
        .port_lb_table_addr(mo_io_port_lb_table_addr),
        .port_lb_table_data(mo_io_port_lb_table_data),
        .port_mem_reg_alu_out(mo_io_port_mem_reg_alu_out),
        .port_dec_reg_inst(mo_io_port_dec_reg_inst),
        .port_exe_reg_inst(mo_io_port_exe_reg_inst),
        .port_mem_reg_inst(mo_io_port_mem_reg_inst),

`ifdef FORMAL
    `ifdef ILSTYPE
        .in_io_dmem_resp_bits_data(mo_io_port_dmem_resp_bits_data),
        .in_io_dmem_resp_valid(mo_io_port_dmem_resp_valid),
        .in_io_dmem_req_ready(mo_io_port_dmem_req_ready),
    `endif
`endif

        .port_dec_wbaddr(mo_io_port_dec_wbaddr),
        .port_exe_reg_wbaddr(mo_io_port_exe_reg_wbaddr),
        .port_mem_reg_wbaddr(mo_io_port_mem_reg_wbaddr),
        .port_imm_sbtype_sext(mo_io_port_imm_sbtype_sext),
        .port_alu_fun(de_io_port_alu_fun),
        .port_mem_fcn(de_io_port_mem_fcn),
        .port_mem_typ(de_io_port_mem_typ)
        // .port_done(port_done),
        // .port_start(port_start)
    );


    // wire [6:0]  opcode;
    // wire [4:0]  rs1;
    // wire [4:0]  rs2;
    // wire [4:0]  rd;
    // wire [2:0]  funct3;
    // wire [6:0]  funct7;
    // wire [11:0] imm;

    // assign opcode   = (opcode_rep == 0) ? (7'b0110011) : ((opcode_rep == 1) ? (7'b0010011) : (7'b1100011));
    // assign rs1      = rs1_rep;
    // assign rs2      = rs2_rep;
    // assign rd       = rd_rep;
    // assign funct3   = (opcode == 7'b1100011) ? ((funct3_rep[2]) ? funct3_rep : {2'b0, funct3_rep[0]}) : funct3_rep;
    // assign funct7   = (opcode == 7'b0110011 && (funct3 == 3'b000 || funct3 == 3'b101)) ? ((funct7_rep) ? 7'h20 : 7'h00) : 7'h0;
    // assign imm      = (opcode == 7'b0010011) ? (
    //     (funct3 == 3'b1) ? {7'd0, imm_rep[4:0]} : 
    //     (funct3 == 3'd5) ? {1'b0, imm_rep[10], 5'd0, imm_rep[4:0]} : imm_rep
    // ) : ((opcode == 7'b1100011) ? {imm_rep[11:1], 1'b0} : imm_rep);

    // assign in_io_imem_resp_bits_data = 
    //     (reset) ? (32'h00000013) : 
    //     (opcode == 7'b0110011) ? ({funct7, rs2, rs1, funct3, rd, opcode}) : 
    //     (opcode == 7'b0010011) ? ({imm, rs1, funct3, rd, opcode}) : ({imm[11], imm[9:4], rs2, rs1, funct3, imm[3:0], imm[10], opcode});


    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end
`ifdef FORMAL
        prev_instr <= de_io_imem_req_valid ? curr_instr : prev_instr;  
`else
        prev_instr <= in_io_imem_resp_bits_data;
`endif

        // de_io_imem_req_valid ? instr : prev_instr;
        // if (de_io_imem_req_valid) begin
        //     $display("%x", in_io_imem_resp_bits_data);
        // end

`ifdef FORMAL
    `ifdef ILSTYPE
        assume(mo_io_port_dmem_resp_bits_data == de_io_port_dmem_resp_bits_data);
        assume(mo_io_port_dmem_resp_valid == de_io_port_dmem_resp_valid);
        assume(mo_io_port_dmem_req_ready == de_io_port_dmem_req_ready);
        assume(mo_io_port_lb_table_data == de_io_port_lb_table_data);
    `endif
        if (counter == 7 && init) begin
            assume(all_equal);
            assume(mo_io_port_lb_table_addr == de_io_port_lb_table_addr);
            assume(mo_io_port_lb_table_valid == de_io_port_lb_table_valid);
            // assume(de_io_port_imm == mo_io_port_imm);
            // assume(de_io_port_alu_out == mo_io_port_alu_out);
            // assume(de_io_port_reg_rs1_addr_in == mo_io_port_reg_rs1_addr_in);
            // assume(de_io_port_reg_rs2_addr_in == mo_io_port_reg_rs2_addr_in);
            // assume(de_io_port_reg_rs1_data_out == mo_io_port_reg_rs1_data_out);
            // assume(de_io_port_reg_rs2_data_out == mo_io_port_reg_rs2_data_out);
            // assume(de_io_port_reg_rd_data_in == mo_io_port_reg_rd_data_in);
            // assume(de_io_port_reg_rd_addr_in == mo_io_port_reg_rd_addr_in);
            // assume(de_io_port_regfile == mo_io_port_regfile);
        end
        if (!init) begin
            assert(
                eq_port_regfile && eq_port_imm && eq_port_alu_out && eq_port_reg_rs1_addr_in && eq_port_reg_rs2_addr_in && eq_port_reg_rs1_data_out && eq_port_reg_rs2_data_out && eq_port_reg_rd_addr_in && eq_port_alu_op1 && eq_port_alu_op2 
                && eq_port_mem_reg_alu_out && eq_port_dec_wbaddr && eq_port_exe_reg_wbaddr && eq_port_mem_reg_wbaddr 
    `ifdef ILSTYPE
                && eq_port_lb_table_valid && eq_port_lb_table_addr && eq_port_lb_table_data 
                && eq_port_imm_sbtype_sext
    `endif
            );
            // assert(de_io_port_imm == mo_io_port_imm);
            // assert(de_io_port_alu_out == mo_io_port_alu_out);
            // assert(de_io_port_reg_rs1_addr_in == mo_io_port_reg_rs1_addr_in);
            // assert(de_io_port_reg_rs2_addr_in == mo_io_port_reg_rs2_addr_in);
            // assert(de_io_port_reg_rs1_data_out == mo_io_port_reg_rs1_data_out);
            // assert(de_io_port_reg_rs2_data_out == mo_io_port_reg_rs2_data_out);
            // assert(de_io_port_reg_rd_data_in == mo_io_port_reg_rd_data_in);
            // assert(de_io_port_reg_rd_addr_in == mo_io_port_reg_rd_addr_in);
        end
`endif
    end

endmodule


