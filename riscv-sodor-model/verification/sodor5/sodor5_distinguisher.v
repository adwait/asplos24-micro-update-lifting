
`define ITYPE
`define NUM_REGS    32
`define WORD_SIZE   32


module sodor5_verif(
    input clk,
);

    reg reset;
    reg past_reset;
    reg [2:0] counter;
    reg [7:0] CLK_CYCLE;
    reg init;
    initial begin
        past_reset = 1;
        reset = 1;
        init = 1;
        counter = 0;
        CLK_CYCLE = 0;
    end
    wire [31:0] in_io_imem_resp_bits_data;

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

`endif

    /* ================= Functions ================= */
    function is_not_a_nop;
        input [31:0] inst;
        begin
            is_not_a_nop = (inst != 32'h00000013);
        end
    endfunction
    function is_aluitype;
        input [31:0] inst;
        begin
            is_aluitype = (inst[6:0] == 7'b0010011);
        end
    endfunction
	function is_alurtype;
        input [31:0] inst;
        begin
            is_alurtype = (inst[6:0] == 7'b0110011);
        end
    endfunction
    function is_branchtype;
        input [31:0] inst;
        begin
            is_branchtype = (inst[6:0] == 7'b1100011);
        end
    endfunction
    function is_4033;
        input [31:0] inst;
        begin
            is_4033 = (inst == 32'h00004033);
        end
    endfunction
	function [31:0] get_i_imm;
		input [31:0] inst;
		begin
			get_i_imm = {{20{inst[31]}}, inst[31:20]};
		end
	endfunction
	// define get_s_imm(inst : inst_t) : bv12 = inst[31:25] ++ inst[11:7];
	function [31:0] get_s_imm;
		input [31:0] inst;
		begin
			get_s_imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
		end
	endfunction
    // define get_b_imm(inst : inst_t) : bv12 = inst[31:25] ++ inst[11:7];
    function [31:0] get_b_imm;
		input [31:0] inst;
		begin
			get_b_imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
		end
	endfunction

	// define get_rd(inst : inst_t) : reg_addr_t = inst[11:7];
	function [4:0] get_rd;
		input [31:0] inst;
		begin
			get_rd = inst[11:7];
		end
	endfunction
    // define get_rs1(inst : inst_t) : reg_addr_t = inst[19:15];
	function [4:0] get_rs1 (input [31:0] inst);
		begin
			get_rs1 = inst[19:15];
		end
	endfunction
	// define get_rs2(inst : inst_t) : reg_addr_t = inst[24:20];
	function [4:0] get_rs2 (input [31:0] inst);
		begin
			get_rs2 = inst[24:20];
		end
	endfunction
    // define get_opcode (inst : inst_t) : opcode_t = inst[6:0];
	function [6:0] get_opcode (input [31:0] inst);
		begin
			get_opcode = inst[6:0];
		end
	endfunction
    
	function [2:0] get_funct3 (input [31:0] inst);
		begin
			get_funct3 = inst[14:12];
		end
	endfunction
	function [6:0] get_funct7 (input [31:0] inst);
		begin
			get_funct7 = inst[31:25];
		end
	endfunction

    function [31:0] sra (input [63:0] d, input [4:0] shamt);
        begin
            sra = (d >> shamt);
        end
    endfunction
    function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [3:0] alu_fun);
        begin
            alu_compute_i = 
                alu_fun == 0 ? imm_data + reg_data : (
                alu_fun == 2 ? reg_data << imm_data[4:0] : (
                alu_fun == 3 ? reg_data >> imm_data[4:0] : (
                alu_fun == 4 ? sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]) : (
                alu_fun == 5 ? (imm_data & reg_data) : (
                alu_fun == 6 ? (imm_data | reg_data) : (
                alu_fun == 7 ? (imm_data ^ reg_data) : (
                alu_fun == 8 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
                alu_fun == 9 ? ((reg_data < imm_data) ? 1 : 0) : (0)
            ))))))));
        end
    endfunction
    function [31:0] alu_compute_r (input [31:0] rs1_data, input [31:0] rs2_data, input [3:0] alu_fun);
        begin
            alu_compute_r = 
                alu_fun == 0 ? rs1_data + rs2_data : (
                alu_fun == 1 ? rs1_data - rs2_data : (
                alu_fun == 2 ? rs1_data << rs2_data[4:0] : (
                alu_fun == 3 ? rs1_data >> rs2_data[4:0] : (
                alu_fun == 4 ? sra({{32{rs1_data[31]}}, rs1_data}, rs2_data[4:0]) : (
                alu_fun == 5 ? (rs1_data & rs2_data) : (
                alu_fun == 6 ? (rs1_data | rs2_data) : (
                alu_fun == 7 ? (rs1_data ^ rs2_data) : (
                alu_fun == 8 ? (($signed(rs1_data) < $signed(rs2_data)) ? 1 : 0) : (
                alu_fun == 9 ? ((rs1_data < rs2_data) ? 1 : 0) : (0)
            )))))))));
        end
    endfunction
    function [31:0] branch_compute (input [31:0] rs1, input [31:0] rs2, input [31:0] pc, input [31:0] imm_data, input [2:0] funct3);
        begin
            branch_compute = 
                // BEQ
                funct3 == 0 ? ((rs1 == rs2) ? pc+imm_data : pc+32'd4) : (
                // BNE
                funct3 == 1 ? ((rs1 != rs2) ? pc+imm_data : pc+32'd4) : (
                // BLT
                funct3 == 4 ? (($signed(rs1) < $signed(rs2))  ? pc+imm_data : pc+32'd4) : (
                // BGE
                funct3 == 5 ? (($signed(rs1) >= $signed(rs2)) ? pc+imm_data : pc+32'd4) : (
                // BLTU
                funct3 == 6 ? ((rs1 < rs2)  ? pc+imm_data : pc+32'd4) : (
                // BGEU
                funct3 == 7 ? ((rs1 >= rs2)  ? pc+imm_data : pc+32'd4) : 
                    pc+32'd4)))));
                
        end
    endfunction
    function branch_decision (input [31:0] rs1, input [31:0] rs2, input [2:0] funct3);
        begin
            branch_decision = 
                // BEQ
                funct3 == 0 ? (rs1 == rs2) : (
                // BNE
                funct3 == 1 ? (rs1 != rs2) : (
                // BLT
                funct3 == 4 ? ($signed(rs1) < $signed(rs2)) : (
                // BGE
                funct3 == 5 ? ($signed(rs1) >= $signed(rs2)) : (
                // BLTU
                funct3 == 6 ? (rs1 < rs2) : (
                // BGEU
                funct3 == 7 ? (rs1 >= rs2) : 
                    0
                )))));
        end
    endfunction
// `endif

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
        .port_alu_fun(de_io_port_alu_fun)
    );


    wire [`WORD_SIZE*`NUM_REGS-1:0] copy1_port_regfile;
    // Copy 1
    // Architectural variables
    reg [31:0] copy1_regfile [0:31];
    reg [31:0] copy1_pc;    
    // Micro-architectural variables
    reg [2:0]  copy1_funct3;
    reg [31:0] copy1_imm;
    reg [31:0] copy1_alu_out;
    reg [4:0] copy1_reg_rs1_addr_in;
    reg [4:0] copy1_reg_rs2_addr_in;
    reg [31:0] copy1_reg_rs1_data_out;
    reg [31:0] copy1_reg_rs2_data_out;
    reg [31:0] copy1_reg_rd_data_in;
    reg [4:0] copy1_reg_rd_addr_in;
    reg [31:0] copy1_if_reg_pc;
    reg [31:0] copy1_dec_reg_pc;
    reg [31:0] copy1_exe_reg_pc;
    reg [31:0] copy1_mem_reg_pc;
    reg        copy1_lb_table_valid;
    reg [31:0] copy1_lb_table_addr;
    reg [31:0] copy1_lb_table_data;
    reg [31:0] copy1_mem_reg_alu_out;
    reg [31:0] copy1_dec_reg_inst;
    reg [31:0] copy1_exe_reg_inst;
    reg [31:0] copy1_mem_reg_inst;
    reg [4:0] copy1_dec_wbaddr;
    reg [4:0] copy1_exe_reg_wbaddr;
    reg [4:0] copy1_mem_reg_wbaddr;
    reg [31:0] copy1_imm_sbtype_sext;
    reg [3:0] copy1_alu_fun;
    // Expose these variables
    genvar copy1_i_port;
    for (copy1_i_port = 0; copy1_i_port<`NUM_REGS; copy1_i_port=copy1_i_port+1) begin
        assign copy1_port_regfile[`WORD_SIZE*copy1_i_port+31:`WORD_SIZE*copy1_i_port] = copy1_regfile[copy1_i_port];
    end

    wire [`WORD_SIZE*`NUM_REGS-1:0] copy2_port_regfile;
    // Architectural variables
    reg [31:0] copy2_regfile [0:31];
    reg [31:0] copy2_pc;
    // Micro-architectural variables
    reg [2:0]  copy2_funct3;
    reg [31:0] copy2_imm;
    reg [31:0] copy2_alu_out;
    reg [4:0] copy2_reg_rs1_addr_in;
    reg [4:0] copy2_reg_rs2_addr_in;
    reg [31:0] copy2_reg_rs1_data_out;
    reg [31:0] copy2_reg_rs2_data_out;
    reg [31:0] copy2_reg_rd_data_in;
    reg [4:0] copy2_reg_rd_addr_in;
    reg [31:0] copy2_if_reg_pc;
    reg [31:0] copy2_dec_reg_pc;
    reg [31:0] copy2_exe_reg_pc;
    reg [31:0] copy2_mem_reg_pc;
    reg        copy2_lb_table_valid;
    reg [31:0] copy2_lb_table_addr;
    reg [31:0] copy2_lb_table_data;
    reg [31:0] copy2_mem_reg_alu_out;
    reg [31:0] copy2_dec_reg_inst;
    reg [31:0] copy2_exe_reg_inst;
    reg [31:0] copy2_mem_reg_inst;
    reg [4:0] copy2_dec_wbaddr;
    reg [4:0] copy2_exe_reg_wbaddr;
    reg [4:0] copy2_mem_reg_wbaddr;
    reg [31:0] copy2_imm_sbtype_sext;
    reg [3:0] copy2_alu_fun;
    // Expose these variables
    genvar copy2_i_port;
    for (copy2_i_port = 0; copy2_i_port<`NUM_REGS; copy2_i_port=copy2_i_port+1) begin
        assign copy2_port_regfile[`WORD_SIZE*copy2_i_port+31:`WORD_SIZE*copy2_i_port] = copy2_regfile[copy2_i_port];
    end

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end

`ifdef FORMAL
    if (CLK_CYCLE == 4) begin
        
    end else if (CLK_CYCLE == 5) begin
        assume ((copy1_alu_out) == (de_io_port_alu_out));
assume ((copy1_reg_rs1_data_out) == (de_io_port_reg_rs1_data_out));
assume ((copy1_imm) == (de_io_port_imm));
assume ((copy2_alu_out) == (de_io_port_alu_out));
assume ((copy2_reg_rs1_data_out) == (de_io_port_reg_rs1_data_out));
assume ((copy2_imm) == (de_io_port_imm));

        copy1_imm = get_i_imm(de_io_port_inst);
copy1_imm_b = get_b_imm(de_io_port_inst);
copy1_reg_rs1_addr_in = get_rs1(de_io_port_inst);
copy1_reg_rs2_addr_in = get_rs2(de_io_port_inst);
copy1_dec_wbaddr = get_rd(de_io_port_inst);
copy1_exe_reg_wbaddr = de_io_port_dec_wbaddr;
copy1_mem_reg_wbaddr = de_io_port_exe_reg_wbaddr;
copy1_reg_rd_addr_in = de_io_port_mem_reg_wbaddr;
copy1_mem_reg_alu_out = de_io_port_alu_out;
copy1_reg_rd_data_in = de_io_port_mem_reg_alu_out;
copy1_regfile[de_io_port_reg_rd_addr_in] = de_io_port_reg_rd_data_in;
copy1_alu_out = alu_compute_i(de_io_port_reg_rs1_data_out, de_io_port_imm, de_io_port_alu_fun);
copy1_reg_rs1_data_out = copy1_regfile[copy1_reg_rs1_addr_in];
copy1_reg_rs2_data_out = copy1_regfile[copy1_reg_rs2_addr_in];
copy2_imm = get_i_imm(de_io_port_inst);
copy2_imm_b = get_b_imm(de_io_port_inst);
copy2_reg_rs1_addr_in = get_rs1(de_io_port_inst);
copy2_reg_rs2_addr_in = get_rs2(de_io_port_inst);
copy2_dec_wbaddr = get_rd(de_io_port_inst);
copy2_exe_reg_wbaddr = de_io_port_dec_wbaddr;
copy2_mem_reg_wbaddr = de_io_port_exe_reg_wbaddr;
copy2_reg_rd_addr_in = de_io_port_mem_reg_wbaddr;
copy2_mem_reg_alu_out = de_io_port_alu_out;
copy2_reg_rd_data_in = de_io_port_mem_reg_alu_out;
copy2_regfile[de_io_port_reg_rd_addr_in] = de_io_port_reg_rd_data_in;
copy2_alu_out = alu_compute_i(de_io_port_alu_out, de_io_port_imm, de_io_port_alu_fun);
copy2_reg_rs1_data_out = copy2_regfile[copy2_reg_rs1_addr_in];
copy2_reg_rs2_data_out = copy2_regfile[copy2_reg_rs2_addr_in];
assert ((copy1_alu_out) == (copy2_alu_out));

    end

`endif
    end

endmodule
