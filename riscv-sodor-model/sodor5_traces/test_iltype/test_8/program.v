
`define NUM_REGS    32
`define WORD_SIZE   32

`define RANDOMIZE

module sodor5_verif_tb();
    
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
        $dumpfile("sodor5_model_wave_pipeline.vcd");
        $dumpvars(0, sodor5_verif_tb);
    end

    initial begin
        #IMEM_INTERVAL;
        #SIM_TIME;
        $finish;
    end

    integer seed = 96;
    // Set up instructions for this particular test type
    reg [11:0] imm, imm_l;
    reg [4:0] rs1, rs2, rd;
    reg [2:0] funct3, funct3_l;
    reg il_choice;

    always @(posedge clk) begin
        // Immediate
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

        // Load
        funct3_l = $urandom(seed);
        // if (funct3_l[1]) begin
        //     funct3_l = 2;
        // end
        funct3_l = funct3_l & 3'b100;
        imm_l = $urandom(seed);
        // imm_l = imm_l & 12'hff;
        il_choice = $urandom(seed);

        tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : (
            il_choice ? {imm, rs1, funct3, rd, 7'b0010011} : {imm_l, rs1, funct3_l, rd, 7'b0000011}
        );
    end

    reg [31:0] tb_in_io_imem_resp_bits_data;
    sodor5_verif sv (
        .clk(clk),
        .instr(tb_in_io_imem_resp_bits_data)
    );

`ifdef RANDOMIZE
    initial begin
        sv.s5m.regfile[0][31:0] = $random;
        sv.s5m.regfile[1][31:0] = $random;
        sv.s5m.regfile[2][31:0] = $random;
        sv.s5m.regfile[3][31:0] = $random;
        sv.s5m.regfile[4][31:0] = $random;
        sv.s5m.regfile[5][31:0] = $random;
        sv.s5m.regfile[6][31:0] = $random;
        sv.s5m.regfile[7][31:0] = $random;
        sv.s5m.regfile[8][31:0] = $random;
        sv.s5m.regfile[9][31:0] = $random;
        sv.s5m.regfile[10][31:0] = $random;
        sv.s5m.regfile[11][31:0] = $random;
        sv.s5m.regfile[12][31:0] = $random;
        sv.s5m.regfile[13][31:0] = $random;
        sv.s5m.regfile[14][31:0] = $random;
        sv.s5m.regfile[15][31:0] = $random;
        sv.s5m.regfile[16][31:0] = $random;
        sv.s5m.regfile[17][31:0] = $random;
        sv.s5m.regfile[18][31:0] = $random;
        sv.s5m.regfile[19][31:0] = $random;
        sv.s5m.regfile[20][31:0] = $random;
        sv.s5m.regfile[21][31:0] = $random;
        sv.s5m.regfile[22][31:0] = $random;
        sv.s5m.regfile[23][31:0] = $random;
        sv.s5m.regfile[24][31:0] = $random;
        sv.s5m.regfile[25][31:0] = $random;
        sv.s5m.regfile[26][31:0] = $random;
        sv.s5m.regfile[27][31:0] = $random;
        sv.s5m.regfile[28][31:0] = $random;
        sv.s5m.regfile[29][31:0] = $random;
        sv.s5m.regfile[30][31:0] = $random;
        sv.s5m.regfile[31][31:0] = $random;
        sv.coretop.core.d.regfile.\regfile[0] = sv.s5m.regfile[0][31:0];
        sv.coretop.core.d.regfile.\regfile[1] = sv.s5m.regfile[1][31:0];
        sv.coretop.core.d.regfile.\regfile[2] = sv.s5m.regfile[2][31:0];
        sv.coretop.core.d.regfile.\regfile[3] = sv.s5m.regfile[3][31:0];
        sv.coretop.core.d.regfile.\regfile[4] = sv.s5m.regfile[4][31:0];
        sv.coretop.core.d.regfile.\regfile[5] = sv.s5m.regfile[5][31:0];
        sv.coretop.core.d.regfile.\regfile[6] = sv.s5m.regfile[6][31:0];
        sv.coretop.core.d.regfile.\regfile[7] = sv.s5m.regfile[7][31:0];
        sv.coretop.core.d.regfile.\regfile[8] = sv.s5m.regfile[8][31:0];
        sv.coretop.core.d.regfile.\regfile[9] = sv.s5m.regfile[9][31:0];
        sv.coretop.core.d.regfile.\regfile[10] = sv.s5m.regfile[10][31:0];
        sv.coretop.core.d.regfile.\regfile[11] = sv.s5m.regfile[11][31:0];
        sv.coretop.core.d.regfile.\regfile[12] = sv.s5m.regfile[12][31:0];
        sv.coretop.core.d.regfile.\regfile[13] = sv.s5m.regfile[13][31:0];
        sv.coretop.core.d.regfile.\regfile[14] = sv.s5m.regfile[14][31:0];
        sv.coretop.core.d.regfile.\regfile[15] = sv.s5m.regfile[15][31:0];
        sv.coretop.core.d.regfile.\regfile[16] = sv.s5m.regfile[16][31:0];
        sv.coretop.core.d.regfile.\regfile[17] = sv.s5m.regfile[17][31:0];
        sv.coretop.core.d.regfile.\regfile[18] = sv.s5m.regfile[18][31:0];
        sv.coretop.core.d.regfile.\regfile[19] = sv.s5m.regfile[19][31:0];
        sv.coretop.core.d.regfile.\regfile[20] = sv.s5m.regfile[20][31:0];
        sv.coretop.core.d.regfile.\regfile[21] = sv.s5m.regfile[21][31:0];
        sv.coretop.core.d.regfile.\regfile[22] = sv.s5m.regfile[22][31:0];
        sv.coretop.core.d.regfile.\regfile[23] = sv.s5m.regfile[23][31:0];
        sv.coretop.core.d.regfile.\regfile[24] = sv.s5m.regfile[24][31:0];
        sv.coretop.core.d.regfile.\regfile[25] = sv.s5m.regfile[25][31:0];
        sv.coretop.core.d.regfile.\regfile[26] = sv.s5m.regfile[26][31:0];
        sv.coretop.core.d.regfile.\regfile[27] = sv.s5m.regfile[27][31:0];
        sv.coretop.core.d.regfile.\regfile[28] = sv.s5m.regfile[28][31:0];
        sv.coretop.core.d.regfile.\regfile[29] = sv.s5m.regfile[29][31:0];
        sv.coretop.core.d.regfile.\regfile[30] = sv.s5m.regfile[30][31:0];
        sv.coretop.core.d.regfile.\regfile[31] = sv.s5m.regfile[31][31:0];

        
        sv.s5m.dmem.\mem[0] = 32'h00000000;
        sv.s5m.dmem.\mem[1] = 32'h11111111;
        sv.s5m.dmem.\mem[2] = 32'h22222222;
        sv.s5m.dmem.\mem[3] = 32'h33333333;
        sv.s5m.dmem.\mem[4] = 32'h44444444;
        sv.s5m.dmem.\mem[5] = 32'h55555555;
        sv.s5m.dmem.\mem[6] = 32'h66666666;
        sv.s5m.dmem.\mem[7] = 32'h77777777;
        sv.s5m.dmem.\mem[8] = 32'h88888888;
        sv.s5m.dmem.\mem[9] = 32'h99999999;
        sv.s5m.dmem.\mem[10] = 32'haaaaaaaa;
        sv.s5m.dmem.\mem[11] = 32'hbbbbbbbb;
        sv.s5m.dmem.\mem[12] = 32'hcccccccc;
        sv.s5m.dmem.\mem[13] = 32'hdddddddd;
        sv.s5m.dmem.\mem[14] = 32'heeeeeeee;
        sv.s5m.dmem.\mem[15] = 32'hffffffff;
        
        sv.coretop.dmem.\mem[0] = 32'h00000000;
        sv.coretop.dmem.\mem[1] = 32'h11111111;
        sv.coretop.dmem.\mem[2] = 32'h22222222;
        sv.coretop.dmem.\mem[3] = 32'h33333333;
        sv.coretop.dmem.\mem[4] = 32'h44444444;
        sv.coretop.dmem.\mem[5] = 32'h55555555;
        sv.coretop.dmem.\mem[6] = 32'h66666666;
        sv.coretop.dmem.\mem[7] = 32'h77777777;
        sv.coretop.dmem.\mem[8] = 32'h88888888;
        sv.coretop.dmem.\mem[9] = 32'h99999999;
        sv.coretop.dmem.\mem[10] = 32'haaaaaaaa;
        sv.coretop.dmem.\mem[11] = 32'hbbbbbbbb;
        sv.coretop.dmem.\mem[12] = 32'hcccccccc;
        sv.coretop.dmem.\mem[13] = 32'hdddddddd;
        sv.coretop.dmem.\mem[14] = 32'heeeeeeee;
        sv.coretop.dmem.\mem[15] = 32'hffffffff;
    end

`endif

endmodule