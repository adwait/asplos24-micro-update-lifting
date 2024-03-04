
`define NUM_REGS    32
`define WORD_SIZE   32

`define INSTR_QUEUE_SIZE 3

// sodor_tb.v

module sodor3_model(
    input clk,
    input reset,
    input [31:0] fe_in_io_imem_resp_bits_data,

    output [`WORD_SIZE*`NUM_REGS-1:0] port_regfile,
    output [31:0] port_pc,

    output [2:0]  port_funct3,
    output [4:0] port_reg_rs1_addr_in,
    output [31:0] port_reg_rs1_data_out,
    output [4:0] port_reg_rs2_addr_in,
    output [31:0] port_reg_rs2_data_out,

    output [31:0] port_alu_out,
    output [4:0] port_exe_reg_wbaddr,
    output [31:0] port_reg_rd_data_in,
    output [4:0] port_reg_rd_addr_in,

    output [31:0] port_wb_reg_inst,
    output [31:0] port_wb_reg_pc,

    output [31:0] port_imm_itype_sext,
    output [31:0] port_imm_sbtype_sext,
    output [31:0] port_imm_stype_sext,
    
    input [3:0] port_alu_fun,
    input port_mem_fcn,
    input [2:0] port_mem_typ
);


    // Architectural variables
    reg [31:0] regfile [0:31];
    reg [31:0] pc;    
    // Micro-architectural state variables
    reg [2:0] funct3;
    reg [4:0] reg_rs1_addr_in;
    reg [31:0] reg_rs1_data_out;
    reg [4:0] reg_rs2_addr_in;
    reg [31:0] reg_rs2_data_out;
    reg [31:0] alu_out;
    reg [4:0] exe_reg_wbaddr;
    reg [31:0] reg_rd_data_in;
    reg [4:0] reg_rd_addr_in;
    reg [31:0] wb_reg_inst;
    reg [31:0] wb_reg_pc;
    reg [31:0] imm_itype_sext;
    reg [31:0] imm_sbtype_sext;
    reg [31:0] imm_stype_sext;
    // And dependencies from the design: these are purely combinational (wires)
    wire [3:0] alu_fun;
    wire mem_fcn;
    wire [2:0] mem_typ;

    // And their copies
    reg [2:0] copy_funct3;
    reg [4:0] copy_reg_rs1_addr_in;
    reg [31:0] copy_reg_rs1_data_out;
    reg [4:0] copy_reg_rs2_addr_in;
    reg [31:0] copy_reg_rs2_data_out;
    reg [31:0] copy_alu_out;
    reg [4:0] copy_exe_reg_wbaddr;
    reg [31:0] copy_reg_rd_data_in;
    reg [4:0] copy_reg_rd_addr_in;
    reg [31:0] copy_wb_reg_inst;
    reg [31:0] copy_wb_reg_pc;
    reg [31:0] copy_imm_itype_sext;
    reg [31:0] copy_imm_sbtype_sext;
    reg [31:0] copy_imm_stype_sext;
    // DOnt really need this as copy since it is an external dependency
    reg [3:0] copy_alu_fun;
    
    
    // Expose these variables
    genvar i_port;
    for (i_port = 0; i_port<`NUM_REGS; i_port=i_port+1) begin
        assign port_regfile[`WORD_SIZE*i_port+31:`WORD_SIZE*i_port] = regfile[i_port];
    end
    assign port_pc = pc;
    assign port_funct3 = funct3;
    assign port_reg_rs1_addr_in = reg_rs1_addr_in;
    assign port_reg_rs1_data_out = reg_rs1_data_out;
    assign port_reg_rs2_addr_in = reg_rs2_addr_in;
    assign port_reg_rs2_data_out = reg_rs2_data_out;
    assign port_alu_out = alu_out;
    assign port_exe_reg_wbaddr = exe_reg_wbaddr;
    assign port_reg_rd_data_in = reg_rd_data_in;
    assign port_reg_rd_addr_in = reg_rd_addr_in;
    assign port_wb_reg_inst = wb_reg_inst;
    assign port_wb_reg_pc = wb_reg_pc;
    assign port_imm_itype_sext = imm_itype_sext;
    assign port_imm_sbtype_sext = imm_sbtype_sext;
    assign port_imm_stype_sext = imm_stype_sext;
    // And the reverse connections
    assign alu_fun = port_alu_fun;
    assign mem_fcn = port_mem_fcn;
    assign mem_typ = port_mem_typ;


wire [31:0] \regfile[0] ;
wire [31:0] \regfile[1] ;
wire [31:0] \regfile[2] ;
wire [31:0] \regfile[3] ;
wire [31:0] \regfile[4] ;
wire [31:0] \regfile[5] ;
wire [31:0] \regfile[6] ;
wire [31:0] \regfile[7] ;
wire [31:0] \regfile[8] ;
wire [31:0] \regfile[9] ;
wire [31:0] \regfile[10] ;
wire [31:0] \regfile[11] ;
wire [31:0] \regfile[12] ;
wire [31:0] \regfile[13] ;
wire [31:0] \regfile[14] ;
wire [31:0] \regfile[15] ;
wire [31:0] \regfile[16] ;
wire [31:0] \regfile[17] ;
wire [31:0] \regfile[18] ;
wire [31:0] \regfile[19] ;
wire [31:0] \regfile[20] ;
wire [31:0] \regfile[21] ;
wire [31:0] \regfile[22] ;
wire [31:0] \regfile[23] ;
wire [31:0] \regfile[24] ;
wire [31:0] \regfile[25] ;
wire [31:0] \regfile[26] ;
wire [31:0] \regfile[27] ;
wire [31:0] \regfile[28] ;
wire [31:0] \regfile[29] ;
wire [31:0] \regfile[30] ;
wire [31:0] \regfile[31] ;

assign \regfile[0] = regfile[0] ;
assign \regfile[1] = regfile[1] ;
assign \regfile[2] = regfile[2] ;
assign \regfile[3] = regfile[3] ;
assign \regfile[4] = regfile[4] ;
assign \regfile[5] = regfile[5] ;
assign \regfile[6] = regfile[6] ;
assign \regfile[7] = regfile[7] ;
assign \regfile[8] = regfile[8] ;
assign \regfile[9] = regfile[9] ;
assign \regfile[10] = regfile[10] ;
assign \regfile[11] = regfile[11] ;
assign \regfile[12] = regfile[12] ;
assign \regfile[13] = regfile[13] ;
assign \regfile[14] = regfile[14] ;
assign \regfile[15] = regfile[15] ;
assign \regfile[16] = regfile[16] ;
assign \regfile[17] = regfile[17] ;
assign \regfile[18] = regfile[18] ;
assign \regfile[19] = regfile[19] ;
assign \regfile[20] = regfile[20] ;
assign \regfile[21] = regfile[21] ;
assign \regfile[22] = regfile[22] ;
assign \regfile[23] = regfile[23] ;
assign \regfile[24] = regfile[24] ;
assign \regfile[25] = regfile[25] ;
assign \regfile[26] = regfile[26] ;
assign \regfile[27] = regfile[27] ;
assign \regfile[28] = regfile[28] ;
assign \regfile[29] = regfile[29] ;
assign \regfile[30] = regfile[30] ;
assign \regfile[31] = regfile[31] ;


// `ifndef __MOP_FUNCTIONS__
//     `define __MOP_FUNCTIONS__
    /* ================= Functions ================= */
    // define get_i_imm(inst : inst_t) : bv12 = inst[31:20];
	// and extends it with sign
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
        function is_loadtype;
        input [31:0] inst;
        begin
            is_loadtype = (inst[6:0] == 7'b0000011);
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
    
    // define get_funct3 (inst : inst_t) : funct3_t = inst[14:12];
	function [2:0] get_funct3 (input [31:0] inst);
		begin
			get_funct3 = inst[14:12];
		end
	endfunction
    // define get_funct7 (inst : inst_t) : funct7_t = inst[31:25];
	function [6:0] get_funct7 (input [31:0] inst);
		begin
			get_funct7 = inst[31:25];
		end
	endfunction

    // ! this is a HACK (arith shift is not working)
    function [31:0] sra (input [63:0] d, input [4:0] shamt);
        begin
            sra = (d >> shamt);
        end
    endfunction
    // function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [2:0] funct3);
    //     begin
    //         alu_compute_i = 
    //             funct3 == 0 ? imm_data + reg_data : (
    //             funct3 == 1 ? reg_data << imm_data[4:0] : (
    //             funct3 == 2 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
    //             funct3 == 3 ? ((reg_data < imm_data) ? 1 : 0) : (
    //             funct3 == 4 ? imm_data ^ reg_data : (
    //             funct3 == 5 ? (imm_data[11:5] == 7'b0100000 ? sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]) : reg_data >> imm_data[4:0]) : (
    //                 // (({{{32{reg_data[31]}}, reg_data} >> imm_data[4:0])[31:0])
    //             funct3 == 6 ? (imm_data | reg_data) : (imm_data & reg_data)
    //             ))))));
    //     end
    // endfunction

    // val ALU_X    = 0.U // TODO use a more optimal decode table, which uses "???" format
    // val ALU_ADD  = 0.U
    // val ALU_SLL  = 1.U
    // val ALU_XOR  = 4.U
    // val ALU_OR   = 6.U
    // val ALU_AND  = 7.U
    // val ALU_SRL  = 5.U
    // val ALU_SUB  = 10.U
    // val ALU_SRA  = 11.U
    // val ALU_SLT  = 12.U
    // val ALU_SLTU = 14.U
    // val ALU_COPY1= 8.U
    
    function [3:0] alu_opcode (input [31:0] instr);
        begin
            alu_opcode = 
                instr[14:12] == 0 ? 0 : (
                instr[14:12] == 1 ? 1 : (
                instr[14:12] == 5 ? (instr[31:25] == 7'h00 ? 5 : 11) : (
                instr[14:12] == 7 ? 7 : (
                instr[14:12] == 6 ? 6 : (
                instr[14:12] == 4 ? 4 : (
                instr[14:12] == 2 ? 12 : (
                instr[14:12] == 3 ? 14 : 8
                // instr[14:12] == ? 10 : (
                // instr[14:12] == ? 8 : 0
            )))))));
        end
    endfunction
    function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [3:0] alu_fun);
        begin
            alu_compute_i = 
                alu_fun == 0 ? imm_data + reg_data : (
                alu_fun == 1 ? reg_data << imm_data[4:0] : (
                alu_fun == 5 ? reg_data >> imm_data[4:0] : (
                alu_fun == 11 ? sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]) : (
                alu_fun == 7 ? (imm_data & reg_data) : (
                alu_fun == 6 ? (imm_data | reg_data) : (
                alu_fun == 4 ? (imm_data ^ reg_data) : (
                alu_fun == 12 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
                alu_fun == 14 ? ((reg_data < imm_data) ? 1 : 0) : (
                alu_fun == 10 ? (reg_data - imm_data) : (
                alu_fun == 8 ? reg_data : 0
            ))))))))));
        end
    endfunction
    // function [31:0] alu_compute_r (input [31:0] rs1_data, input [31:0] rs2_data, input [6:0] funct7, input [2:0] funct3);
    //     begin
    //         alu_compute_r = 
    //             funct3 == 0 ?  ((funct7 == 7'b0) ? (rs1_data+rs2_data) : (rs1_data-rs2_data)) : (
    //             funct3 == 1 ? rs1_data << (rs2_data[4:0]) : (
    //             funct3 == 2 ? (($signed(rs1_data) < $signed(rs2_data)) ? 1 : 0) : (
    //             funct3 == 3 ? ((rs1_data < rs2_data) ? 1 : 0) : (
    //             funct3 == 4 ? rs1_data ^ rs2_data : (
    //             funct3 == 5 ? (funct7 == 7'b0100000 ? sra({{32{rs1_data[31]}},rs1_data},rs2_data[4:0]) : rs1_data>>(rs2_data[4:0])) : (
    //             funct3 == 6 ? (rs1_data | rs2_data) : (rs1_data & rs2_data)
    //             ))))));
    //     end
    // endfunction
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
//     `include "functions.v"
// `endif


    // This is the structure that holds the instruction sequence
    reg [31:0] instr_queue [0:`INSTR_QUEUE_SIZE-1];
    // And the validity information for it
    reg instr_queue_valid [0:`INSTR_QUEUE_SIZE-1];

wire [31:0] instr_m1;
assign instr_m1 = fe_in_io_imem_resp_bits_data;
wire [31:0] \instr_queue[0] ;
wire [31:0] \instr_queue[1] ;
wire [31:0] \instr_queue[2] ;
// wire [31:0] \instr_queue[3] ;
// wire [31:0] \instr_queue[4] ;
wire \instr_queue_valid[0] ;
wire \instr_queue_valid[1] ; 
wire \instr_queue_valid[2] ;
// wire \instr_queue_valid[3] ;
// wire \instr_queue_valid[4] ;

assign \instr_queue[0] = instr_queue[0];
assign \instr_queue[1] = instr_queue[1];
assign \instr_queue[2] = instr_queue[2];
// assign \instr_queue[3] = instr_queue[3];
// assign \instr_queue[4] = instr_queue[4];
assign \instr_queue_valid[0] = instr_queue_valid[0];
assign \instr_queue_valid[1] = instr_queue_valid[1];
assign \instr_queue_valid[2] = instr_queue_valid[2];
// assign \instr_queue_valid[3] = instr_queue_valid[3];
// assign \instr_queue_valid[4] = instr_queue_valid[4];

    // Decoding transactions
    wire synth__txn_gen_decode_i_imm;
    assign synth__txn_gen_decode_i_imm = 1'b1;
    wire synth__txn_gen_decode_b_imm;
    assign synth__txn_gen_decode_b_imm = 1'b1;
    wire synth__txn_gen_decode_s_imm;
    assign synth__txn_gen_decode_s_imm = 1'b1;
    wire synth__txn_gen_decode_rs1_addr;
    assign synth__txn_gen_decode_rs1_addr = 1'b1;
    wire synth__txn_gen_decode_rs2_addr;
    assign synth__txn_gen_decode_rs2_addr = 1'b1;
    wire synth__txn_gen_decode_rd_addr;
    assign synth__txn_gen_decode_rd_addr = 1'b1;
    // This doesn't match with what should be
    wire synth__txn_zero__exe_reg_wbaddr;
    assign synth__txn_zero__exe_reg_wbaddr = 1'b0;
    wire synth__txn_feed__exe_reg_wbaddr__reg_rd_addr_in;
    assign synth__txn_feed__exe_reg_wbaddr__reg_rd_addr_in = 1'b1;
    wire synth__txn_feed__alu_out__reg_rd_data_in;
    assign synth__txn_feed__alu_out__reg_rd_data_in = 1'b1;
    wire synth__txn_regs1_read;
    assign synth__txn_regs1_read = 1'b1;
    wire synth__txn_regs2_read;
    assign synth__txn_regs2_read = 1'b1;
    
    wire synth__txn_regs_write;
    assign synth__txn_regs_write = (get_rd(instr_queue[1]) != 5'b0) && !is_branchtype(instr_queue[1]); //(instr_queue[3]) && (get_rd(instr_queue[3]) != 5'b0);
    
    wire synth__txn_alu_compute_rs_imm;
    assign synth__txn_alu_compute_rs_imm = (is_aluitype(instr_m1))
        && ((get_rd(instr_queue[0]) != get_rs1(instr_m1)) || !is_not_a_nop(instr_queue[0]) || (get_rd(instr_queue[0]) == 0));
        // && ((get_rd(instr_queue[1]) != get_rs1(instr_m1)) || !is_not_a_nop(instr_queue[1]) || (get_rd(instr_queue[1]) == 0));
    // This doesn't match
    wire synth__txn_alu_compute_alu_out_imm;
    assign synth__txn_alu_compute_alu_out_imm = (is_aluitype(instr_m1))
        && (get_rd(instr_queue[0]) == get_rs1(instr_m1) && (get_rd(instr_queue[0]) != 0));
    // This doesn't match
    wire synth__txn_alu_compute_rd_imm;
    assign synth__txn_alu_compute_rd_imm = 1'b0;
        // (is_aluitype(instr_m1))
        // && (get_rd(instr_queue[0]) != get_rs1(instr_m1)) 
        // && (get_rd(instr_queue[1]) == get_rs1(instr_m1) && (get_rd(instr_queue[1]) != 0));
    // All of these are imprecise
    wire synth__txn_alu_compute_rs_rs;
    assign synth__txn_alu_compute_rs_rs = 1'b0;
    wire synth__txn_alu_compute_alu_out_rs;
    assign synth__txn_alu_compute_alu_out_rs = 1'b0;
    wire synth__txn_alu_compute_rd_rs;
    assign synth__txn_alu_compute_rd_rs = 1'b0;
    wire synth__txn_alu_compute_alu_out_rs2;
    assign synth__txn_alu_compute_alu_out_rs2 = 1'b0;
    wire synth__txn_alu_compute_rd_rs2;
    assign synth__txn_alu_compute_rd_rs2 = 1'b0;

    integer i;
    always @(posedge clk) begin

        if (reset) begin
`ifndef RANDOMIZE
            for (i = 0; i < 32; i=i+1) begin
                regfile[i] <= 0;
            end
`endif
            // Reset the instruction queue structure
            // INFO: this code will be more-or-less untouched
            instr_queue[0] <= 32'h0;
            instr_queue_valid[0] <= 0;
            instr_queue[1] <= 32'h0;
            instr_queue_valid[1] <= 0;
            instr_queue[2] <= 32'h0;
            instr_queue_valid[2] <= 0;
            pc <= 0;
        end else begin
            instr_queue[2] = instr_queue[1];
            instr_queue_valid[2] = instr_queue_valid[1];
            instr_queue[1] = instr_queue[0];
            instr_queue_valid[1] = instr_queue_valid[0];
            instr_queue[0] = fe_in_io_imem_resp_bits_data;
            instr_queue_valid[0] = 1'b1;
            pc = pc + 4;
        end


        // Call some transactions
            if (synth__txn_gen_decode_i_imm) begin
                copy_imm_itype_sext = get_i_imm(instr_queue[0]);
            end
            if (synth__txn_gen_decode_b_imm) begin
                copy_imm_sbtype_sext = get_b_imm(instr_queue[0]);
            end
            if (synth__txn_gen_decode_s_imm) begin
                copy_imm_stype_sext = get_s_imm(instr_queue[0]);
            end
            if (synth__txn_gen_decode_rs1_addr) begin
                copy_reg_rs1_addr_in = get_rs1(instr_queue[0]);
            end
            if (synth__txn_gen_decode_rs2_addr) begin
                copy_reg_rs2_addr_in = get_rs2(instr_queue[0]);
            end

            if (synth__txn_gen_decode_rd_addr) begin
                copy_exe_reg_wbaddr = get_rd(instr_queue[0]);
            end
            if (synth__txn_zero__exe_reg_wbaddr) begin
                copy_exe_reg_wbaddr = 32'd0;
            end


            if (synth__txn_feed__exe_reg_wbaddr__reg_rd_addr_in) begin
                copy_reg_rd_addr_in = exe_reg_wbaddr;
            end
            if (synth__txn_feed__alu_out__reg_rd_data_in) begin
                copy_reg_rd_data_in = alu_out;
            end

            // This is off
            if (synth__txn_regs_write) begin
                regfile[reg_rd_addr_in] = reg_rd_data_in;
            end

            
        // Make copies of the variables
            funct3 = copy_funct3;
            reg_rs1_addr_in = copy_reg_rs1_addr_in;
            // reg_rs1_data_out = copy_reg_rs1_data_out;
            reg_rs2_addr_in = copy_reg_rs2_addr_in;
            // reg_rs2_data_out = copy_reg_rs2_data_out;
            // alu_out = copy_alu_out;
            exe_reg_wbaddr = copy_exe_reg_wbaddr;
            reg_rd_data_in = copy_reg_rd_data_in;
            reg_rd_addr_in = copy_reg_rd_addr_in;
            wb_reg_inst = copy_wb_reg_inst;
            wb_reg_pc = copy_wb_reg_pc;
            imm_itype_sext = copy_imm_itype_sext;
            imm_sbtype_sext = copy_imm_sbtype_sext;
            imm_stype_sext = copy_imm_stype_sext;

        // alu_fun = copy_alu_fun;
            if (synth__txn_regs1_read) begin
                reg_rs1_data_out = (reg_rs1_addr_in == 5'd0) ? 32'd0 : regfile[reg_rs1_addr_in];
            end
            if (synth__txn_regs2_read) begin
                reg_rs2_data_out = (reg_rs2_addr_in == 5'd0) ? 32'd0 : regfile[reg_rs2_addr_in];
            end

            // if (synth__txn_alu_compute_rd_imm) begin
            //     alu_out = alu_compute_i(reg_rd_data_in, imm_itype_sext, alu_opcode(instr_queue[0]));
            // end
            if (synth__txn_alu_compute_alu_out_imm) begin
                alu_out = alu_compute_i(reg_rd_data_in, imm_itype_sext, alu_opcode(instr_queue[0]));
            end
            if (synth__txn_alu_compute_rs_imm) begin
                alu_out = alu_compute_i(reg_rs1_data_out, imm_itype_sext, alu_opcode(instr_queue[0]));
            end
            
            if (synth__txn_alu_compute_rs_rs) begin
                alu_out = alu_compute_r(reg_rs1_data_out, reg_rs2_data_out, alu_opcode(instr_queue[0]));
            end
            if (synth__txn_alu_compute_alu_out_rs) begin
                alu_out = alu_compute_r(reg_rs1_data_out, alu_out, alu_opcode(instr_queue[0]));
            end
            if (synth__txn_alu_compute_rd_rs) begin
                alu_out = alu_compute_r(reg_rs1_data_out, reg_rd_data_in, alu_opcode(instr_queue[0]));
            end
            if (synth__txn_alu_compute_alu_out_rs2) begin
                alu_out = alu_compute_r(alu_out, reg_rs2_data_out, alu_opcode(instr_queue[0]));
            end
            if (synth__txn_alu_compute_rd_rs2) begin
                alu_out = alu_compute_r(reg_rd_data_in, reg_rs2_data_out, alu_opcode(instr_queue[0]));
            end

    end

endmodule



