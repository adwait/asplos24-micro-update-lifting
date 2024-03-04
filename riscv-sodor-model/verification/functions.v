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
			get_opcode = inst[31:25];
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
    