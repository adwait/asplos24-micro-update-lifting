// sodor_tb.v

`define OPCODE_INDEX_WIDTH  2
`define FUNCT3_WIDTH        3
`define FUNCT7_WIDTH        1
`define IMM_WIDTH           12
`define REG_ADDR_WIDTH      5

module sodor1_verif(
    input clk,
    input [`OPCODE_INDEX_WIDTH-1:0] opcode_rep,
    input [`REG_ADDR_WIDTH-1:0]     rs1_rep,
    input [`REG_ADDR_WIDTH-1:0]     rs2_rep,
    input [`REG_ADDR_WIDTH-1:0]     rd_rep,
    input [`IMM_WIDTH-1:0]          imm_rep,
    input [`FUNCT3_WIDTH-1:0]       funct3_rep,
    input [`FUNCT7_WIDTH-1:0]       funct7_rep
);

    CoreTop coretop (
        .clock(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .fe_ou_io_imem_req_bits_addr(de_ou_io_imem_req_bits_addr),
        .fe_ou_io_imem_req_valid(de_ou_io_imem_req_valid),
        .fe_ou_io_port_regfile(de_ou_io_port_regfile)
    );

    sodor1_model s1m (
        .clk(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .port_regfile(mo_ou_io_port_regfile),
        .port_pc(mo_ou_io_port_pc)
    );

    reg reset;
    reg [2:0] counter;
    reg init;

    wire [31:0] in_io_imem_resp_bits_data;

    initial begin
        reset = 1;
        init = 1;
        counter = 0;
    end

    wire [6:0]  opcode;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [4:0]  rd;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [11:0] imm;

    assign opcode   = (opcode_rep == 0) ? (7'b0110011) : ((opcode_rep == 1) ? (7'b0010011) : (7'b1100011));
    assign rs1      = rs1_rep;
    assign rs2      = rs2_rep;
    assign rd       = rd_rep;
    assign funct3   = (opcode == 7'b1100011) ? ((funct3_rep[2]) ? funct3_rep : {2'b0, funct3_rep[0]}) : funct3_rep;
    assign funct7   = (opcode == 7'b0110011 && (funct3 == 3'b000 || funct3 == 3'b101)) ? ((funct7_rep) ? 7'h20 : 7'h00) : 7'h0;
    assign imm      = (opcode == 7'b0010011) ? (
        (funct3 == 3'b1) ? {7'd0, imm_rep[4:0]} : 
        (funct3 == 3'd5) ? {1'b0, imm_rep[10], 5'd0, imm_rep[4:0]} : imm_rep
    ) : ((opcode == 7'b1100011) ? {imm_rep[11:1], 1'b0} : imm_rep);

    assign in_io_imem_resp_bits_data = 
        (reset) ? (32'h00000013) : 
        (opcode == 7'b0110011) ? ({funct7, rs2, rs1, funct3, rd, opcode}) : 
        (opcode == 7'b0010011) ? ({imm, rs1, funct3, rd, opcode}) : ({imm[11], imm[9:4], rs2, rs1, funct3, imm[3:0], imm[10], opcode});


    always @(posedge clk) begin
        counter <= counter + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
            assume(mo_ou_io_port_regfile == de_ou_io_port_regfile);
        end
    end

        
    wire [1023:0] mo_ou_io_port_regfile;
    wire [31:0] mo_ou_io_port_pc;

    wire [31:0] de_ou_io_imem_req_bits_addr;
    wire de_ou_io_imem_req_valid;
    wire [1023:0] de_ou_io_port_regfile;
    
    

    always @(posedge clk ) begin
        if (counter >= 4) begin
            
            assert(mo_ou_io_port_pc == de_ou_io_imem_req_bits_addr);
            assert(mo_ou_io_port_regfile == de_ou_io_port_regfile);
        end
    end

endmodule


