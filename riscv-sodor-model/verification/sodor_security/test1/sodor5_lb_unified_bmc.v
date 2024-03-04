// sodor_tb.v

module sodor5_verif(
    input clk
);

    reg reset;
    reg past_reset;
    reg [4:0] counter;
    reg init;
    reg [31:0] prev_instr;
    
    wire [31:0] program_array [0:15];

`ifdef FORMAL
    (* anyconst *) reg [11:0] imm1, imm2, imm3, imm4;
    (* anyconst *) reg [4:0] rs1, rs2, rs3, rs4;
    (* anyconst *) reg [4:0] rd1, rd2, rd3, rd4;
    // (* anyconst *) reg [11:0] imm2;
    // (* anyconst *) reg [4:0] rs2;
    // (* anyconst *) reg [4:0] rd2;
    (* anyconst *) reg choice1, choice2, choice3, choice4;

    assign program_array[0] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[1] = {imm1, rs1, 3'b000, rd1, (choice1 ? 7'd3 : 7'b0010011)}; // load 1
    assign program_array[2] = {imm2, rs2, 3'b000, rd2, (choice2 ? 7'd3 : 7'b0010011)}; // load 1
    assign program_array[3] = {imm3, rs3, 3'b000, rd3, (choice3 ? 7'd3 : 7'b0010011)}; // load 1
    assign program_array[4] = {imm4, rs4, 3'b000, rd4, (choice4 ? 7'd3 : 7'b0010011)}; // load 1
    assign program_array[5] = 32'b00000000000100000010001000100011; // sw r0(4) r1 : 00102223
    assign program_array[6] = 32'b00000000000000000000000000010011; // 32'b00000000000100000010001000100011; // sw r0(4) r1 : 00102223
    assign program_array[7] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[8] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[9] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[10] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[11] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[12] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[13] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[14] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[15] = 32'b00000000000000000000000000010011; // nop : 00000013
`else
    assign program_array[0] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[1] = {12'd100, 5'b00000, 3'b000, 5'b00001, 7'd3}; // load 1
    assign program_array[2] = 32'b00000000101000011000000000010011; // addi r0 r3 10
    assign program_array[3] = 32'b00000000101100011000000000010011; // addi r0 r3 11
    assign program_array[4] = 32'b00000000110000011000000000010011; // addi r0 r3 12
    assign program_array[5] = 32'b00000000000000000000000000010011; // 32'b00000000000100000010001000100011; // sw r0(4) r1 : 00102223
    assign program_array[6] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[7] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[8] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[9] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[10] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[11] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[12] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[13] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[14] = 32'b00000000000000000000000000010011; // nop : 00000013
    assign program_array[15] = 32'b00000000000000000000000000010011; // nop : 00000013
`endif

    wire [31:0] in_io_imem_resp_bits_data1;
    wire [31:0] in_io_imem_resp_bits_data2;

`ifdef MODEL
    assign in_io_imem_resp_bits_data1 = program_array[de_io_port_pc1[5:2]];
    assign in_io_imem_resp_bits_data2 = program_array[de_io_port_pc2[5:2]];
`else
    assign in_io_imem_resp_bits_data1 = program_array[de_io_imem_req_bits_addr1[5:2]];
    assign in_io_imem_resp_bits_data2 = program_array[de_io_imem_req_bits_addr2[5:2]];
`endif

    // Design signals
    wire [31:0] de_io_imem_req_bits_addr1;
    wire de_io_imem_req_valid1;
    wire [1023:0] de_io_port_regfile1;
    wire [31:0] de_io_port_pc1;
    wire [31:0] de_io_port_imm1;
    wire [31:0] de_io_port_alu_out1;
    wire [4:0] de_io_port_reg_rs1_addr_in1;
    wire [4:0] de_io_port_reg_rs2_addr_in1;
    wire [31:0] de_io_port_reg_rs1_data_out1;
    wire [31:0] de_io_port_reg_rs2_data_out1;
    wire [31:0] de_io_port_reg_rd_data_in1;
    wire [4:0] de_io_port_reg_rd_addr_in1;
    // Design signals 2
    wire [31:0] de_io_port_if_reg_pc1;
    wire [31:0] de_io_port_dec_reg_pc1;
    wire [31:0] de_io_port_exe_reg_pc1;
    wire [31:0] de_io_port_mem_reg_pc1;
    wire        de_io_port_lb_table_valid1;
    wire [31:0] de_io_port_lb_table_addr1;
    wire [31:0] de_io_port_lb_table_data1;
    wire [31:0] de_io_port_mem_reg_alu_out1;
    // Design control signals
    wire [31:0] de_io_port_dec_reg_inst1;
    wire [31:0] de_io_port_exe_reg_inst1;
    wire [31:0] de_io_port_mem_reg_inst1;

    wire [4:0] de_io_port_dec_wbaddr1;
    wire [4:0] de_io_port_exe_reg_wbaddr1;
    wire [4:0] de_io_port_mem_reg_wbaddr1;
    wire [31:0] de_io_port_imm_sbtype_sext1;
    wire [3:0] de_io_port_alu_fun1;
    wire de_io_port_mem_fcn1;
    wire [2:0] de_io_port_mem_typ1;

    // For copy 2
    wire [31:0] de_io_imem_req_bits_addr2;
    wire de_io_imem_req_valid2;
    wire [1023:0] de_io_port_regfile2;
    wire [31:0] de_io_port_pc2;
    wire [31:0] de_io_port_imm2;
    wire [31:0] de_io_port_alu_out2;
    wire [4:0] de_io_port_reg_rs1_addr_in2;
    wire [4:0] de_io_port_reg_rs2_addr_in2;
    wire [31:0] de_io_port_reg_rs1_data_out2;
    wire [31:0] de_io_port_reg_rs2_data_out2;
    wire [31:0] de_io_port_reg_rd_data_in2;
    wire [4:0] de_io_port_reg_rd_addr_in2;
    wire [31:0] de_io_port_if_reg_pc2;
    wire [31:0] de_io_port_dec_reg_pc2;
    wire [31:0] de_io_port_exe_reg_pc2;
    wire [31:0] de_io_port_mem_reg_pc2;
    wire        de_io_port_lb_table_valid2;
    wire [31:0] de_io_port_lb_table_addr2;
    wire [31:0] de_io_port_lb_table_data2;
    wire [31:0] de_io_port_mem_reg_alu_out2;
    wire [31:0] de_io_port_dec_reg_inst2;
    wire [31:0] de_io_port_exe_reg_inst2;
    wire [31:0] de_io_port_mem_reg_inst2;
    wire [4:0] de_io_port_dec_wbaddr2;
    wire [4:0] de_io_port_exe_reg_wbaddr2;
    wire [4:0] de_io_port_mem_reg_wbaddr2;
    wire [31:0] de_io_port_imm_sbtype_sext2;
    wire [3:0] de_io_port_alu_fun2;
    wire de_io_port_mem_fcn2;
    wire [2:0] de_io_port_mem_typ2;


    initial begin
        past_reset = 1;
        reset = 1;
        init = 1;
        counter = 0;
    end
    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end
        // prev_instr1 <= in_io_imem_resp_bits_data1;
        // prev_instr2 <= in_io_imem_resp_bits_data2;

`ifdef FORMAL
        if (counter == 2 && init) begin
            assume(de_io_port_regfile1 == de_io_port_regfile2);
        end

        if (counter == 20) begin
            assert(!lb_diverge);
        end
`endif
    end

    wire eq_regfile;
    assign eq_regfile = (de_io_port_regfile1 == de_io_port_regfile2);
    wire eq_imm;
    assign eq_imm = (de_io_port_imm1 == de_io_port_imm2);
    wire eq_alu_out;
    assign eq_alu_out = (de_io_port_alu_out1 == de_io_port_alu_out2);
    wire eq_reg_rs1_addr_in;
    assign eq_reg_rs1_addr_in = (de_io_port_reg_rs1_addr_in1 == de_io_port_reg_rs1_addr_in2);
    wire eq_reg_rs2_addr_in;
    assign eq_reg_rs2_addr_in = (de_io_port_reg_rs2_addr_in1 == de_io_port_reg_rs2_addr_in2);
    wire eq_reg_rs1_data_out;
    assign eq_reg_rs1_data_out = (de_io_port_reg_rs1_data_out1 == de_io_port_reg_rs1_data_out2);
    wire eq_reg_rs2_data_out;
    assign eq_reg_rs2_data_out = (de_io_port_reg_rs2_data_out1 == de_io_port_reg_rs2_data_out2);
    wire eq_reg_rd_data_in;
    assign eq_reg_rd_data_in = (de_io_port_reg_rd_data_in1 == de_io_port_reg_rd_data_in2);
    wire eq_reg_rd_addr_in;
    assign eq_reg_rd_addr_in = (de_io_port_reg_rd_addr_in1 == de_io_port_reg_rd_addr_in2);
    wire eq_dec_reg_inst;
    assign eq_dec_reg_inst = (de_io_port_dec_reg_inst1 == de_io_port_dec_reg_inst2);
    wire eq_exe_reg_inst;
    assign eq_exe_reg_inst = (de_io_port_exe_reg_inst1 == de_io_port_exe_reg_inst2);
    wire eq_mem_reg_inst;
    assign eq_mem_reg_inst = (de_io_port_mem_reg_inst1 == de_io_port_mem_reg_inst2);
    wire eq_mem_reg_alu_out;
    assign eq_mem_reg_alu_out = (de_io_port_mem_reg_alu_out1 == de_io_port_mem_reg_alu_out2);
    wire eq_if_reg_pc;
    assign eq_if_reg_pc = (de_io_port_if_reg_pc1 == de_io_port_if_reg_pc2);
    wire eq_dec_reg_pc;
    assign eq_dec_reg_pc = (de_io_port_dec_reg_pc1 == de_io_port_dec_reg_pc2);
    wire eq_exe_reg_pc;
    assign eq_exe_reg_pc = (de_io_port_exe_reg_pc1 == de_io_port_exe_reg_pc2);
    wire eq_mem_reg_pc;
    assign eq_mem_reg_pc = (de_io_port_mem_reg_pc1 == de_io_port_mem_reg_pc2);
    wire eq_lb_table_valid;
    assign eq_lb_table_valid = (de_io_port_lb_table_valid1 == de_io_port_lb_table_valid2);
    wire eq_lb_table_addr;
    assign eq_lb_table_addr = (de_io_port_lb_table_addr1 == de_io_port_lb_table_addr2);
    wire eq_lb_table_data;
    assign eq_lb_table_data = (de_io_port_lb_table_data1 == de_io_port_lb_table_data2);
    wire eq_dec_wbaddr;
    assign eq_dec_wbaddr = (de_io_port_dec_wbaddr1 == de_io_port_dec_wbaddr2);
    wire eq_exe_reg_wbaddr;
    assign eq_exe_reg_wbaddr = (de_io_port_exe_reg_wbaddr1 == de_io_port_exe_reg_wbaddr2);
    wire eq_mem_reg_wbaddr;
    assign eq_mem_reg_wbaddr = (de_io_port_mem_reg_wbaddr1 == de_io_port_mem_reg_wbaddr2);
    wire eq_imm_sbtype_sext;
    assign eq_imm_sbtype_sext = (de_io_port_imm_sbtype_sext1 == de_io_port_imm_sbtype_sext2);
    wire eq_alu_fun;
    assign eq_alu_fun = (de_io_port_alu_fun1 == de_io_port_alu_fun2);
    wire eq_mem_fcn;
    assign eq_mem_fcn = (de_io_port_mem_fcn1 == de_io_port_mem_fcn2);
    wire eq_mem_typ;
    assign eq_mem_typ = (de_io_port_mem_typ1 == de_io_port_mem_typ2);
    wire all_equal;
    assign all_equal = eq_regfile && eq_imm && eq_alu_out && eq_reg_rs1_addr_in && eq_reg_rs2_addr_in && eq_reg_rs1_data_out && eq_reg_rs2_data_out && eq_reg_rd_data_in && eq_reg_rd_addr_in && eq_dec_reg_inst && eq_exe_reg_inst && eq_mem_reg_inst && eq_mem_reg_alu_out && eq_if_reg_pc && eq_dec_reg_pc && eq_exe_reg_pc && eq_mem_reg_pc && eq_lb_table_valid && eq_lb_table_addr && eq_lb_table_data && eq_dec_wbaddr && eq_exe_reg_wbaddr && eq_mem_reg_wbaddr && eq_imm_sbtype_sext && eq_alu_fun && eq_mem_fcn && eq_mem_typ;

    wire lb_diverge;
    assign lb_diverge = (de_io_port_lb_table_valid1 ^ de_io_port_lb_table_valid2) || 
        ((de_io_port_lb_table_valid1 && de_io_port_lb_table_valid2) && (de_io_port_lb_table_addr1 != de_io_port_lb_table_addr2)) 
        // || ((de_io_port_lb_table_valid1 && de_io_port_lb_table_valid2) && (de_io_port_lb_table_data1 != de_io_port_lb_table_data2))
        ;

`ifdef MODEL
    sodor5_model model1 (
        .clk(clk),
`else
    CoreTop coretop1 (
        .clock(clk),
`endif
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data1),
        // .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr1),
        // .fe_ou_io_imem_req_valid(de_io_imem_req_valid1),
        .port_regfile(de_io_port_regfile1),
`ifdef MODEL
        .port_pc(de_io_port_pc1),
`else
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr1),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid1),
`endif
        .port_imm(de_io_port_imm1),
        .port_alu_out(de_io_port_alu_out1),
        .port_reg_rs1_addr_in(de_io_port_reg_rs1_addr_in1),
        .port_reg_rs2_addr_in(de_io_port_reg_rs2_addr_in1),
        .port_reg_rs1_data_out(de_io_port_reg_rs1_data_out1),
        .port_reg_rs2_data_out(de_io_port_reg_rs2_data_out1),
        .port_reg_rd_data_in(de_io_port_reg_rd_data_in1),
        .port_reg_rd_addr_in(de_io_port_reg_rd_addr_in1),
        .port_dec_reg_inst(de_io_port_dec_reg_inst1),
        .port_exe_reg_inst(de_io_port_exe_reg_inst1),
        .port_mem_reg_inst(de_io_port_mem_reg_inst1),
        .port_mem_reg_alu_out(de_io_port_mem_reg_alu_out1),
        .port_if_reg_pc(de_io_port_if_reg_pc1),
        .port_dec_reg_pc(de_io_port_dec_reg_pc1),
        .port_exe_reg_pc(de_io_port_exe_reg_pc1),
        .port_mem_reg_pc(de_io_port_mem_reg_pc1),
        .port_lb_table_valid(de_io_port_lb_table_valid1),
        .port_lb_table_addr(de_io_port_lb_table_addr1),
        .port_lb_table_data(de_io_port_lb_table_data1),
        .port_dec_wbaddr(de_io_port_dec_wbaddr1),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr1),
        .port_mem_reg_wbaddr(de_io_port_mem_reg_wbaddr1),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext1),
        .port_alu_fun(de_io_port_alu_fun1),
        .port_mem_fcn(de_io_port_mem_fcn1),
        .port_mem_typ(de_io_port_mem_typ1)
    );

`ifdef MODEL
    sodor5_model model2 (
        .clk(clk),
`else
    CoreTop coretop2 (
        .clock(clk),
`endif
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data2),
        // .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr2),
        // .fe_ou_io_imem_req_valid(de_io_imem_req_valid2),
        .port_regfile(de_io_port_regfile2),
`ifdef MODEL
        .port_pc(de_io_port_pc2),
`else
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr2),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid2),
`endif

        .port_imm(de_io_port_imm2),
        .port_alu_out(de_io_port_alu_out2),
        .port_reg_rs1_addr_in(de_io_port_reg_rs1_addr_in2),
        .port_reg_rs2_addr_in(de_io_port_reg_rs2_addr_in2),
        .port_reg_rs1_data_out(de_io_port_reg_rs1_data_out2),
        .port_reg_rs2_data_out(de_io_port_reg_rs2_data_out2),
        .port_reg_rd_data_in(de_io_port_reg_rd_data_in2),
        .port_reg_rd_addr_in(de_io_port_reg_rd_addr_in2),
        .port_dec_reg_inst(de_io_port_dec_reg_inst2),
        .port_exe_reg_inst(de_io_port_exe_reg_inst2),
        .port_mem_reg_inst(de_io_port_mem_reg_inst2),
        .port_mem_reg_alu_out(de_io_port_mem_reg_alu_out2),
        .port_if_reg_pc(de_io_port_if_reg_pc2),
        .port_dec_reg_pc(de_io_port_dec_reg_pc2),
        .port_exe_reg_pc(de_io_port_exe_reg_pc2),
        .port_mem_reg_pc(de_io_port_mem_reg_pc2),
        .port_lb_table_valid(de_io_port_lb_table_valid2),
        .port_lb_table_addr(de_io_port_lb_table_addr2),
        .port_lb_table_data(de_io_port_lb_table_data2),
        .port_dec_wbaddr(de_io_port_dec_wbaddr2),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr2),
        .port_mem_reg_wbaddr(de_io_port_mem_reg_wbaddr2),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext2),
        .port_alu_fun(de_io_port_alu_fun2),
        .port_mem_fcn(de_io_port_mem_fcn2),
        .port_mem_typ(de_io_port_mem_typ2)
    );

endmodule