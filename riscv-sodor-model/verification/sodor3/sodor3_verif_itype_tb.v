`define RANDOMIZE

module sodor3_verif_tb();
    
    parameter CLK_CYCLE_TIME = 10;
    parameter IMEM_INTERVAL = 30;
    parameter SIM_CYCLE = 100; // 100000000;
    parameter SIM_TIME = SIM_CYCLE * CLK_CYCLE_TIME * 2;

    reg [31:0] 			CLK_CYCLE;
    reg 				clk;
    reg 				reset;
    
    initial begin
        clk = 1;
        forever #CLK_CYCLE_TIME clk = ~clk;
    end
    initial begin
        reset = 1;
        // #IMEM_INTERVAL reset = 1;
        #IMEM_INTERVAL reset = 0;
    end
    initial begin
        CLK_CYCLE = 32'h0;
    end
    always @(posedge clk) begin
        CLK_CYCLE <= CLK_CYCLE + 1;
    end
    
    initial begin
        $dumpfile("sodor3_model_wave_pipeline.vcd");
        $dumpvars(0, sodor3_verif_tb);
    end

    initial begin
        #IMEM_INTERVAL;
        #SIM_TIME;
        $finish;
    end

    // Random seed for instruction field sampling
    integer seed = 71652;
    // Set up instructions for this particular test type
    reg [11:0] imm;
    reg [4:0] rs1, rs2, rd;
    reg [2:0] funct3;

    always @(posedge clk) begin
        imm = $urandom(seed);
        rs1 = $urandom(seed);
        rs2 = $urandom(seed);
        rd = $urandom(seed);
        funct3 = $urandom(seed);
        if (funct3 == 5) begin
            imm = (imm & 12'b010000011111);
        end else if (funct3 == 1) begin
            imm = (imm & 12'b000000011111);
        end
        tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : {imm, rs1, funct3, rd, 7'b0010011};
    end

    // Register that holds the prospective next instruction
    reg [31:0] tb_in_io_imem_resp_bits_data;

    sodor3_verif sv (
        .clk(clk),
        .instr(tb_in_io_imem_resp_bits_data)
    );

`ifdef RANDOMIZE
    initial begin
        sv.s3m.regfile[0][31:0] = $random;
        sv.s3m.regfile[1][31:0] = $random;
        sv.s3m.regfile[2][31:0] = $random;
        sv.s3m.regfile[3][31:0] = $random;
        sv.s3m.regfile[4][31:0] = $random;
        sv.s3m.regfile[5][31:0] = $random;
        sv.s3m.regfile[6][31:0] = $random;
        sv.s3m.regfile[7][31:0] = $random;
        sv.s3m.regfile[8][31:0] = $random;
        sv.s3m.regfile[9][31:0] = $random;
        sv.s3m.regfile[10][31:0] = $random;
        sv.s3m.regfile[11][31:0] = $random;
        sv.s3m.regfile[12][31:0] = $random;
        sv.s3m.regfile[13][31:0] = $random;
        sv.s3m.regfile[14][31:0] = $random;
        sv.s3m.regfile[15][31:0] = $random;
        sv.s3m.regfile[16][31:0] = $random;
        sv.s3m.regfile[17][31:0] = $random;
        sv.s3m.regfile[18][31:0] = $random;
        sv.s3m.regfile[19][31:0] = $random;
        sv.s3m.regfile[20][31:0] = $random;
        sv.s3m.regfile[21][31:0] = $random;
        sv.s3m.regfile[22][31:0] = $random;
        sv.s3m.regfile[23][31:0] = $random;
        sv.s3m.regfile[24][31:0] = $random;
        sv.s3m.regfile[25][31:0] = $random;
        sv.s3m.regfile[26][31:0] = $random;
        sv.s3m.regfile[27][31:0] = $random;
        sv.s3m.regfile[28][31:0] = $random;
        sv.s3m.regfile[29][31:0] = $random;
        sv.s3m.regfile[30][31:0] = $random;
        sv.s3m.regfile[31][31:0] = $random;
        sv.coretop.core.dpath.\regfile[0] = sv.s3m.regfile[0][31:0];
        sv.coretop.core.dpath.\regfile[1] = sv.s3m.regfile[1][31:0];
        sv.coretop.core.dpath.\regfile[2] = sv.s3m.regfile[2][31:0];
        sv.coretop.core.dpath.\regfile[3] = sv.s3m.regfile[3][31:0];
        sv.coretop.core.dpath.\regfile[4] = sv.s3m.regfile[4][31:0];
        sv.coretop.core.dpath.\regfile[5] = sv.s3m.regfile[5][31:0];
        sv.coretop.core.dpath.\regfile[6] = sv.s3m.regfile[6][31:0];
        sv.coretop.core.dpath.\regfile[7] = sv.s3m.regfile[7][31:0];
        sv.coretop.core.dpath.\regfile[8] = sv.s3m.regfile[8][31:0];
        sv.coretop.core.dpath.\regfile[9] = sv.s3m.regfile[9][31:0];
        sv.coretop.core.dpath.\regfile[10] = sv.s3m.regfile[10][31:0];
        sv.coretop.core.dpath.\regfile[11] = sv.s3m.regfile[11][31:0];
        sv.coretop.core.dpath.\regfile[12] = sv.s3m.regfile[12][31:0];
        sv.coretop.core.dpath.\regfile[13] = sv.s3m.regfile[13][31:0];
        sv.coretop.core.dpath.\regfile[14] = sv.s3m.regfile[14][31:0];
        sv.coretop.core.dpath.\regfile[15] = sv.s3m.regfile[15][31:0];
        sv.coretop.core.dpath.\regfile[16] = sv.s3m.regfile[16][31:0];
        sv.coretop.core.dpath.\regfile[17] = sv.s3m.regfile[17][31:0];
        sv.coretop.core.dpath.\regfile[18] = sv.s3m.regfile[18][31:0];
        sv.coretop.core.dpath.\regfile[19] = sv.s3m.regfile[19][31:0];
        sv.coretop.core.dpath.\regfile[20] = sv.s3m.regfile[20][31:0];
        sv.coretop.core.dpath.\regfile[21] = sv.s3m.regfile[21][31:0];
        sv.coretop.core.dpath.\regfile[22] = sv.s3m.regfile[22][31:0];
        sv.coretop.core.dpath.\regfile[23] = sv.s3m.regfile[23][31:0];
        sv.coretop.core.dpath.\regfile[24] = sv.s3m.regfile[24][31:0];
        sv.coretop.core.dpath.\regfile[25] = sv.s3m.regfile[25][31:0];
        sv.coretop.core.dpath.\regfile[26] = sv.s3m.regfile[26][31:0];
        sv.coretop.core.dpath.\regfile[27] = sv.s3m.regfile[27][31:0];
        sv.coretop.core.dpath.\regfile[28] = sv.s3m.regfile[28][31:0];
        sv.coretop.core.dpath.\regfile[29] = sv.s3m.regfile[29][31:0];
        sv.coretop.core.dpath.\regfile[30] = sv.s3m.regfile[30][31:0];
        sv.coretop.core.dpath.\regfile[31] = sv.s3m.regfile[31][31:0];
    end

`endif

endmodule