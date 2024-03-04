
`define NUM_REGS    32
`define WORD_SIZE   32

`define END_STATE   5

// sodor_tb.v

module sodor5_model(
    input clk,
    input reset,
    input [31:0] fe_in_io_imem_resp_bits_data,
    output [`WORD_SIZE*`NUM_REGS-1:0] port_regfile,
    output [31:0] port_pc,

    output [2:0]  port_funct3,
    output [31:0] port_imm,
    output [31:0] port_alu_out,
    output [4:0] port_reg_rs1_addr_in,
    output [4:0] port_reg_rs2_addr_in,
    output [31:0] port_reg_rs1_data_out,
    output [31:0] port_reg_rs2_data_out,
    output [31:0] port_reg_rd_data_in,
    output [4:0] port_reg_rd_addr_in,

    output port_done,
    output port_start
);
    
    // Architectural variables
    reg [31:0] regfile [0:31];
    reg [31:0] pc;

    // Surface level micro-architecture
    // Fields extracted from the instrction
    // reg [2:0]  funct3;
    // reg [6:0]  funct7;
    reg [6:0]  opcode;
    // reg [11:0] imm;
    // reg [4:0]  rs1;
    // reg [4:0]  rs2;
    // reg [4:0]  rd;
    // // Data values
    // reg [31:0] rs1_data;
    // reg [31:0] rs2_data;
    // reg [31:0] imm_data;
    // reg [31:0] alu_out_data;
    // reg [31:0] branch_pc;
    // Micro-architectural state variables
    reg [2:0]  funct3;
    reg [31:0] imm;
    reg [31:0] alu_out;
    reg [4:0] reg_rs1_addr_in;
    reg [4:0] reg_rs2_addr_in;
    reg [31:0] reg_rs1_data_out;
    reg [31:0] reg_rs2_data_out;
    reg [31:0] reg_rd_data_in;
    reg [4:0] reg_rd_addr_in;


    wire [2:0]  port_funct3;
    wire [31:0] port_imm;
    wire [31:0] port_alu_out;
    wire [4:0] port_reg_rs1_addr_in;
    wire [4:0] port_reg_rs2_addr_in;
    wire [31:0] port_reg_rs1_data_out;
    wire [31:0] port_reg_rs2_data_out;
    wire [31:0] port_reg_rd_data_in;
    wire [4:0] port_reg_rd_addr_in;

    wire port_done;
    wire port_start;

    assign port_funct3 = funct3;
    assign port_imm = imm;
    assign port_alu_out = alu_out;
    assign port_reg_rs1_addr_in = reg_rs1_addr_in;
    assign port_reg_rs2_addr_in = reg_rs2_addr_in;
    assign port_reg_rs1_data_out = reg_rs1_data_out;
    assign port_reg_rs2_data_out = reg_rs2_data_out;
    assign port_reg_rd_data_in = reg_rd_data_in;
    assign port_reg_rd_addr_in = reg_rd_addr_in   ;

    assign port_done = done;
    assign port_start = start;

    genvar i_port;
    for (i_port = 0; i_port<`NUM_REGS; i_port=i_port+1) begin
        assign port_regfile[`WORD_SIZE*i_port+31:`WORD_SIZE*i_port] = regfile[i_port];
    end
    assign port_pc = pc;


    

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
    function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [2:0] funct3);
        begin
            alu_compute_i = 
                funct3 == 0 ? imm_data + reg_data : (
                funct3 == 1 ? reg_data << imm_data[4:0] : (
                funct3 == 2 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
                funct3 == 3 ? ((reg_data < imm_data) ? 1 : 0) : (
                funct3 == 4 ? imm_data ^ reg_data : (
                funct3 == 5 ? (imm_data[11:5] == 7'b0100000 ? sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]) : reg_data >> imm_data[4:0]) : (
                    // (({{{32{reg_data[31]}}, reg_data} >> imm_data[4:0])[31:0])
                funct3 == 6 ? (imm_data | reg_data) : (imm_data & reg_data)
                ))))));
        end
    endfunction
    function [31:0] alu_compute_r (input [31:0] rs1_data, input [31:0] rs2_data, input [6:0] funct7, input [2:0] funct3);
        begin
            alu_compute_r = 
                funct3 == 0 ?  ((funct7 == 7'b0) ? (rs1_data+rs2_data) : (rs1_data-rs2_data)) : (
                funct3 == 1 ? rs1_data << (rs2_data[4:0]) : (
                funct3 == 2 ? (($signed(rs1_data) < $signed(rs2_data)) ? 1 : 0) : (
                funct3 == 3 ? ((rs1_data < rs2_data) ? 1 : 0) : (
                funct3 == 4 ? rs1_data ^ rs2_data : (
                funct3 == 5 ? (funct7 == 7'b0100000 ? sra({{32{rs1_data[31]}},rs1_data},rs2_data[4:0]) : rs1_data>>(rs2_data[4:0])) : (
                funct3 == 6 ? (rs1_data | rs2_data) : (rs1_data & rs2_data)
                ))))));
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
//     `include "functions.v"
// `endif


    reg [3:0] state;
    reg start;
    reg done;

    // reg prev_reset;

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            // prev_reset <= 1;
            // Only make assumptions about the architectural state
            for (i = 0; i < 32; i=i+1) begin
                regfile[i] <= 0;
            end
            pc <= 0;
            state = 0;
            start <= 0;
            done <= 0;
        
        end else if (!start && !done) begin
            // Grab the opcode
            opcode = get_opcode(fe_in_io_imem_resp_bits_data);
            
            // Check when to start execution
            if (fe_in_io_imem_resp_bits_data == 32'h00000013) begin
                pc <= pc + 4;
            end
            // I-type ALU operation
            else if (opcode == 7'b0010011) begin
                // Second micro-operation

                start <= 1;
                state = 1;
            end
        end else if (start && state != `END_STATE) begin
            state = state + 1;
        end else begin
            done <= 1;
            start <= 0;
        end

        reg [31:0] pipeline_inst_dec;
        reg [31:0] pipeline_inst_exe;
        reg [31:0] pipeline_inst_mem;
        reg [31:0] mem_reg_alu_out;

        if (state == 1) begin
            // Instruction decode
            reg_rs1_addr_in = get_rs1(fe_in_io_imem_resp_bits_data);
            reg_rs2_addr_in = get_rs2(fe_in_io_imem_resp_bits_data);
            imm = get_i_imm(fe_in_io_imem_resp_bits_data);
            funct3 = get_funct3(fe_in_io_imem_resp_bits_data);

            // Load from registers
            reg_rs1_data_out = regfile[reg_rs1_addr_in];
            reg_rs2_data_out = regfile[reg_rs2_addr_in];

            pipeline_inst_dec <= fe_in_io_imem_resp_bits_data;
            
            // All are metastable
            alu_out = 0;
            reg_rd_data_in = 0;
            reg_rd_addr_in = 0;

        end else if (state == 2) begin
            alu_out = alu_compute_i(reg_rs1_data_out, imm, funct3);
            pipeline_inst_exe <= pipeline_inst_dec;

            // All are metastable
            reg_rs1_addr_in = 0;
            reg_rs2_addr_in = 0;
            imm = 0;
            reg_rs1_data_out = 0;
            reg_rs2_data_out = 0;

        end else if (state == 3) begin
            pipeline_inst_mem <= pipeline_inst_exe;
            mem_reg_alu_out = alu_out;

            // All are metastable
            alu_out = 0;
            reg_rd_data_in = 0;
            reg_rd_addr_in = 0;
            reg_rs1_addr_in = 0;
            reg_rs2_addr_in = 0;
            imm = 0;
            reg_rs1_data_out = 0;
            reg_rs2_data_out = 0;

        end else if (state == 4) begin 
            reg_rd_data_in = mem_reg_alu_out;
            reg_rd_addr_in = get_rd(pipeline_inst_mem);

        end else if (state == 5) begin
            regfile[reg_rd_addr_in] = (reg_rd_addr_in == 5'd0) ? 32'h0 : reg_rd_data_in;

            // All are metastable
            reg_rd_data_in = 0;
            reg_rd_addr_in = 0;
        end
    end


endmodule



