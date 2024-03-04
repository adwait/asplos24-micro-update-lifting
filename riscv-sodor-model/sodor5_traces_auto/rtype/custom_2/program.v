
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

    wire [31:0] program_array [0:15];

assign program_array[0] = 32'b00000000110110000000101000110011;
assign program_array[1] = 32'b00000001001101110000000100110011;
assign program_array[2] = 32'b00000000000100011000000000110011;
assign program_array[3] = 32'b00000000100111110000010110110011;
assign program_array[4] = 32'b00000000110110010000001110110011;
assign program_array[5] = 32'b00000001000011111000110100110011;
assign program_array[6] = 32'b00000000001111100000011000110011;
assign program_array[7] = 32'b00000000011000100000110010110011;
assign program_array[8] = 32'b00000000101101010000000000110011;
assign program_array[9] = 32'b00000000110000000000011010110011;
assign program_array[10] = 32'b00000001110000101000100100110011;
assign program_array[11] = 32'b00000000101010111000000010110011;
assign program_array[12] = 32'b00000001001010100000110110110011;
assign program_array[13] = 32'b00000000101001011000111110110011;
assign program_array[14] = 32'b00000000110111000000010110110011;
assign program_array[15] = 32'b00000000001111011000001010110011;


    always @(posedge clk) begin
        tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : program_array[CLK_CYCLE[3:0]];
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