
`define NUM_REGS    32
`define WORD_SIZE   32

// sodor_tb.v

module sodor_formal(
    input clk,
    input [31:0] fe_in_io_imem_resp_bits_data,
    output [`WORD_SIZE*`NUM_REGS-1:0] port_regfile
);
    
    reg reset;
    reg [2:0] counter;
    reg init;

    initial begin
        reset = 1;
        init = 1;
        counter = 0;
    end

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end
    end

    // Architectural variables
    reg [31:0] regfile [0:31];
    reg [31:0] pc;

    // Surface level micro-architecture
    // Fields extracted from the instrction
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    reg [6:0]  opcode;
    reg [11:0] imm;
    reg [4:0]  rs1;
    reg [4:0]  rs2;
    reg [4:0]  rd;
    // Data values
    reg [31:0] rs1_data;
    reg [31:0] rs2_data;
    reg [31:0] imm_data;
    reg [31:0] alu_out_data;
    reg [31:0] branch_pc;

    // assign funct3 = fe_in_io_imem_resp_bits_data[14:12];
    // assign opcode = fe_in_io_imem_resp_bits_data[6:0];
    // assign rs1 = fe_in_io_imem_resp_bits_data[19:15];
    // assign rs2 = fe_in_io_imem_resp_bits_data[24:20];
    // assign rd = fe_in_io_imem_resp_bits_data[11:7];
    // assign imm = fe_in_io_imem_resp_bits_data[31:20];
    // assign src1 = regfile[rs1];
    // assign src2 = regfile[rs2];

    genvar i_port;
    for (i_port = 0; i_port<`NUM_REGS; i_port=i_port+1) begin
        assign port_regfile[`WORD_SIZE*i_port+31:`WORD_SIZE*i_port] = regfile[i_port];
    end

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
			get_b_imm = {{20{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8]};
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
                funct3 == 1 ? rs1_data << rs2_data : (
                funct3 == 2 ? (($signed(rs1_data) < $signed(rs2_data)) ? 1 : 0) : (
                funct3 == 3 ? ((rs1_data < rs2_data) ? 1 : 0) : (
                funct3 == 4 ? rs1_data ^ rs2_data : (
                funct3 == 5 ? (funct7 == 7'b0100000 ? sra({{32{rs1_data[31]}},rs1_data},rs2_data) : rs1_data>>rs2_data) : (
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
                funct3 == 7 ? ((rs1 < rs2)  ? pc+imm_data : pc+32'd4) : 
                    pc+32'd4)))));
                
        end
    endfunction
//     `include "functions.v"
// `endif


    integer i;
    always @(posedge clk) begin
        if (reset) begin
        
            // Only make assumptions about the architectural state
            for (i = 0; i < 32; i=i+1) begin
                regfile[i] <= 0;
            end
            pc <= 0;
        
        end else begin
            
            // First micro-operation
            opcode = get_opcode(fe_in_io_imem_resp_bits_data);

            // R-type ALU operation
            if (opcode == 7'b0110011) begin
                // Second micro-operation
                rs1 = get_rs1(fe_in_io_imem_resp_bits_data);
                rs2 = get_rs2(fe_in_io_imem_resp_bits_data);
                rd  = get_rd(fe_in_io_imem_resp_bits_data);
                funct3 = get_funct3(fe_in_io_imem_resp_bits_data);
                funct7 = get_funct7(fe_in_io_imem_resp_bits_data);

                // Third micro-operation
                rs1_data = regfile[rs1];
                rs2_data = regfile[rs2];

                // Fourth micro-operation
                alu_out_data = alu_compute_r(rs1_data, rs2_data, funct7, funct3);

                // Fifth micro-operation
                regfile[rd] = alu_out_data;
                pc = pc + 31'd4;
            end 
            // I-type ALU operation
            else if (opcode == 7'b0010011) begin
                // Second micro-operation
                rs1 = get_rs1(fe_in_io_imem_resp_bits_data);
                imm_data = get_i_imm(fe_in_io_imem_resp_bits_data);
                rd  = get_rd(fe_in_io_imem_resp_bits_data);
                funct3 = get_funct3(fe_in_io_imem_resp_bits_data);

                // Third micro-operation
                rs1_data = regfile[rs1];

                // Fourth micro-operation
                alu_out_data = alu_compute_i(rs1_data, imm_data, funct3);

                // Fifth micro-operation
                regfile[rd] = alu_out_data;
                pc = pc + 31'd4;        
            end
            // Branch instruction
            else if (opcode == 7'b1100011) begin
                // Second micro-operation
                rs1 = get_rs1(fe_in_io_imem_resp_bits_data);
                rs2 = get_rs2(fe_in_io_imem_resp_bits_data);
                imm_data = get_b_imm(fe_in_io_imem_resp_bits_data);
                funct3 = get_funct3(fe_in_io_imem_resp_bits_data);

                // Third micro-operation
                rs1_data = regfile[rs1];
                rs2_data = regfile[rs2];

                // Fourth micro-operation
                branch_pc = branch_compute(rs1_data, rs2_data, pc, imm_data, funct3);

                // Fifth micro-operation
                pc = branch_pc;
            end
            
            
            // if (opcode == 7'b0110011) begin
            //     case(funct3)
            //         3'd0 : regfile[rd] <= (src1 + src2);
            //         3'd4 : regfile[rd] <= (src1 ^ src2);
            //         3'd6 : regfile[rd] <= (src1 | src2);
            //         3'd7 : regfile[rd] <= (src1 & src2);
            //         default: regfile[rd] <= regfile[rd];
            //     endcase
            // end else if (opcode == 7'b0010011) begin
            //     case (funct3)
            //         3'd0 : regfile[rd] <= (src1 + imm);
            //         3'd4 : regfile[rd] <= (src1 ^ imm);
            //         3'd6 : regfile[rd] <= (src1 | imm);
            //         3'd7 : regfile[rd] <= (src1 & imm);
            //         default: regfile[rd] <= regfile[rd];
            //     endcase                
            // end
        end
    end


endmodule



