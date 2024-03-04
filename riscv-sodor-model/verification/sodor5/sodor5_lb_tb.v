
`define RANDOMIZE

module sodor5_verif_tb();
    
    parameter CLK_CYCLE_TIME = 10;
    parameter IMEM_INTERVAL = 30;
    parameter SIM_CYCLE = 30; // 100000000;
    parameter SIM_TIME = SIM_CYCLE * CLK_CYCLE_TIME * 2;

    reg [31:0] 			CLK_CYCLE;
    reg 				clk;
    
    initial begin
        clk = 1;
        forever #CLK_CYCLE_TIME clk = ~clk;
    end

    initial begin
        CLK_CYCLE = 32'h0;
    end
    always @(posedge clk) begin
        CLK_CYCLE <= CLK_CYCLE + 1;
    end
    
    initial begin
`ifdef SRC
        $dumpfile("sodor5_lb_wave_pipeline.vcd");
`endif
`ifdef MODEL
        $dumpfile("sodor5_lb_model_wave_pipeline.vcd");
`endif
        $dumpvars(0, sodor5_verif_tb);
    end

    initial begin
        #IMEM_INTERVAL;
        #SIM_TIME;
        $finish;
    end

    reg [31:0] temp [0:31];

    sodor5_verif sv (
        .clk(clk)
    );

`ifdef RANDOMIZE
    initial begin
        temp[0] = $random;
        temp[1] = $random;
        temp[2] = $random;
        temp[3] = $random;
        temp[4] = $random;
        temp[5] = $random;
        temp[6] = $random;
        temp[7] = $random;
        temp[8] = $random;
        temp[9] = $random;
        temp[10] = $random;
        temp[11] = $random;
        temp[12] = $random;
        temp[13] = $random;
        temp[14] = $random;
        temp[15] = $random;
        temp[16] = $random;
        temp[17] = $random;
        temp[18] = $random;
        temp[19] = $random;
        temp[20] = $random;
        temp[21] = $random;
        temp[22] = $random;
        temp[23] = $random;
        temp[24] = $random;
        temp[25] = $random;
        temp[26] = $random;
        temp[27] = $random;
        temp[28] = $random;
        temp[29] = $random;
        temp[30] = $random;
        temp[31] = $random;
`ifdef SRC        
        sv.coretop1.core.d.regfile.\regfile[0] = temp[0];
        sv.coretop1.core.d.regfile.\regfile[1] = temp[1];
        sv.coretop1.core.d.regfile.\regfile[2] = temp[2];
        sv.coretop1.core.d.regfile.\regfile[3] = temp[3];
        sv.coretop1.core.d.regfile.\regfile[4] = temp[4];
        sv.coretop1.core.d.regfile.\regfile[5] = temp[5];
        sv.coretop1.core.d.regfile.\regfile[6] = temp[6];
        sv.coretop1.core.d.regfile.\regfile[7] = temp[7];
        sv.coretop1.core.d.regfile.\regfile[8] = temp[8];
        sv.coretop1.core.d.regfile.\regfile[9] = temp[9];
        sv.coretop1.core.d.regfile.\regfile[10] = temp[10];
        sv.coretop1.core.d.regfile.\regfile[11] = temp[11];
        sv.coretop1.core.d.regfile.\regfile[12] = temp[12];
        sv.coretop1.core.d.regfile.\regfile[13] = temp[13];
        sv.coretop1.core.d.regfile.\regfile[14] = temp[14];
        sv.coretop1.core.d.regfile.\regfile[15] = temp[15];
        sv.coretop1.core.d.regfile.\regfile[16] = temp[16];
        sv.coretop1.core.d.regfile.\regfile[17] = temp[17];
        sv.coretop1.core.d.regfile.\regfile[18] = temp[18];
        sv.coretop1.core.d.regfile.\regfile[19] = temp[19];
        sv.coretop1.core.d.regfile.\regfile[20] = temp[20];
        sv.coretop1.core.d.regfile.\regfile[21] = temp[21];
        sv.coretop1.core.d.regfile.\regfile[22] = temp[22];
        sv.coretop1.core.d.regfile.\regfile[23] = temp[23];
        sv.coretop1.core.d.regfile.\regfile[24] = temp[24];
        sv.coretop1.core.d.regfile.\regfile[25] = temp[25];
        sv.coretop1.core.d.regfile.\regfile[26] = temp[26];
        sv.coretop1.core.d.regfile.\regfile[27] = temp[27];
        sv.coretop1.core.d.regfile.\regfile[28] = temp[28];
        sv.coretop1.core.d.regfile.\regfile[29] = temp[29];
        sv.coretop1.core.d.regfile.\regfile[30] = temp[30];
        sv.coretop1.core.d.regfile.\regfile[31] = temp[31];
        sv.coretop2.core.d.regfile.\regfile[0] = temp[0];
        sv.coretop2.core.d.regfile.\regfile[1] = temp[1];
        sv.coretop2.core.d.regfile.\regfile[2] = temp[2];
        sv.coretop2.core.d.regfile.\regfile[3] = temp[3];
        sv.coretop2.core.d.regfile.\regfile[4] = temp[4];
        sv.coretop2.core.d.regfile.\regfile[5] = temp[5];
        sv.coretop2.core.d.regfile.\regfile[6] = temp[6];
        sv.coretop2.core.d.regfile.\regfile[7] = temp[7];
        sv.coretop2.core.d.regfile.\regfile[8] = temp[8];
        sv.coretop2.core.d.regfile.\regfile[9] = temp[9];
        sv.coretop2.core.d.regfile.\regfile[10] = temp[10];
        sv.coretop2.core.d.regfile.\regfile[11] = temp[11];
        sv.coretop2.core.d.regfile.\regfile[12] = temp[12];
        sv.coretop2.core.d.regfile.\regfile[13] = temp[13];
        sv.coretop2.core.d.regfile.\regfile[14] = temp[14];
        sv.coretop2.core.d.regfile.\regfile[15] = temp[15];
        sv.coretop2.core.d.regfile.\regfile[16] = temp[16];
        sv.coretop2.core.d.regfile.\regfile[17] = temp[17];
        sv.coretop2.core.d.regfile.\regfile[18] = temp[18];
        sv.coretop2.core.d.regfile.\regfile[19] = temp[19];
        sv.coretop2.core.d.regfile.\regfile[20] = temp[20];
        sv.coretop2.core.d.regfile.\regfile[21] = temp[21];
        sv.coretop2.core.d.regfile.\regfile[22] = temp[22];
        sv.coretop2.core.d.regfile.\regfile[23] = temp[23];
        sv.coretop2.core.d.regfile.\regfile[24] = temp[24];
        sv.coretop2.core.d.regfile.\regfile[25] = temp[25];
        sv.coretop2.core.d.regfile.\regfile[26] = temp[26];
        sv.coretop2.core.d.regfile.\regfile[27] = temp[27];
        sv.coretop2.core.d.regfile.\regfile[28] = temp[28];
        sv.coretop2.core.d.regfile.\regfile[29] = temp[29];
        sv.coretop2.core.d.regfile.\regfile[30] = temp[30];
        sv.coretop2.core.d.regfile.\regfile[31] = temp[31];
`endif
`ifdef MODEL
        sv.model1.regfile[0] = temp[0];
        sv.model1.regfile[1] = temp[1];
        sv.model1.regfile[2] = temp[2];
        sv.model1.regfile[3] = temp[3];
        sv.model1.regfile[4] = temp[4];
        sv.model1.regfile[5] = temp[5];
        sv.model1.regfile[6] = temp[6];
        sv.model1.regfile[7] = temp[7];
        sv.model1.regfile[8] = temp[8];
        sv.model1.regfile[9] = temp[9];
        sv.model1.regfile[10] = temp[10];
        sv.model1.regfile[11] = temp[11];
        sv.model1.regfile[12] = temp[12];
        sv.model1.regfile[13] = temp[13];
        sv.model1.regfile[14] = temp[14];
        sv.model1.regfile[15] = temp[15];
        sv.model1.regfile[16] = temp[16];
        sv.model1.regfile[17] = temp[17];
        sv.model1.regfile[18] = temp[18];
        sv.model1.regfile[19] = temp[19];
        sv.model1.regfile[20] = temp[20];
        sv.model1.regfile[21] = temp[21];
        sv.model1.regfile[22] = temp[22];
        sv.model1.regfile[23] = temp[23];
        sv.model1.regfile[24] = temp[24];
        sv.model1.regfile[25] = temp[25];
        sv.model1.regfile[26] = temp[26];
        sv.model1.regfile[27] = temp[27];
        sv.model1.regfile[28] = temp[28];
        sv.model1.regfile[29] = temp[29];
        sv.model1.regfile[30] = temp[30];
        sv.model1.regfile[31] = temp[31];
        sv.model2.regfile[0] = temp[0];
        sv.model2.regfile[1] = temp[1];
        sv.model2.regfile[2] = temp[2];
        sv.model2.regfile[3] = temp[3];
        sv.model2.regfile[4] = temp[4];
        sv.model2.regfile[5] = temp[5];
        sv.model2.regfile[6] = temp[6];
        sv.model2.regfile[7] = temp[7];
        sv.model2.regfile[8] = temp[8];
        sv.model2.regfile[9] = temp[9];
        sv.model2.regfile[10] = temp[10];
        sv.model2.regfile[11] = temp[11];
        sv.model2.regfile[12] = temp[12];
        sv.model2.regfile[13] = temp[13];
        sv.model2.regfile[14] = temp[14];
        sv.model2.regfile[15] = temp[15];
        sv.model2.regfile[16] = temp[16];
        sv.model2.regfile[17] = temp[17];
        sv.model2.regfile[18] = temp[18];
        sv.model2.regfile[19] = temp[19];
        sv.model2.regfile[20] = temp[20];
        sv.model2.regfile[21] = temp[21];
        sv.model2.regfile[22] = temp[22];
        sv.model2.regfile[23] = temp[23];
        sv.model2.regfile[24] = temp[24];
        sv.model2.regfile[25] = temp[25];
        sv.model2.regfile[26] = temp[26];
        sv.model2.regfile[27] = temp[27];
        sv.model2.regfile[28] = temp[28];
        sv.model2.regfile[29] = temp[29];
        sv.model2.regfile[30] = temp[30];
        sv.model2.regfile[31] = temp[31];
`endif
`ifdef SRC
        sv.coretop1.dmem.\mem[0] = $random; // = 32'h00000000;
        sv.coretop2.dmem.\mem[0] = $random; // = 32'h00000000;
        sv.coretop1.dmem.\mem[1] = $random; // = 32'h11111111;
        sv.coretop2.dmem.\mem[1] = $random; // = 32'h11111111;
        sv.coretop1.dmem.\mem[2] = $random; // = 32'h22222222;
        sv.coretop2.dmem.\mem[2] = $random; // = 32'h22222222;
        sv.coretop1.dmem.\mem[3] = $random; // = 32'h33333333;
        sv.coretop2.dmem.\mem[3] = $random; // = 32'h33333333;
        sv.coretop1.dmem.\mem[4] = $random; // = 32'h44444444;
        sv.coretop2.dmem.\mem[4] = $random; // = 32'h44444444;
        sv.coretop1.dmem.\mem[5] = $random; // = 32'h55555555;
        sv.coretop2.dmem.\mem[5] = $random; // = 32'h55555555;
        sv.coretop1.dmem.\mem[6] = $random; // = 32'h66666666;
        sv.coretop2.dmem.\mem[6] = $random; // = 32'h66666666;
        sv.coretop1.dmem.\mem[7] = $random; // = 32'h77777777;
        sv.coretop2.dmem.\mem[7] = $random; // = 32'h77777777;
        sv.coretop1.dmem.\mem[8] = $random; // = 32'h88888888;
        sv.coretop2.dmem.\mem[8] = $random; // = 32'h88888888;
        sv.coretop1.dmem.\mem[9] = $random; // = 32'h99999999;
        sv.coretop2.dmem.\mem[9] = $random; // = 32'h99999999;
        sv.coretop1.dmem.\mem[10] = $random; // = 32'haaaaaaaa;
        sv.coretop2.dmem.\mem[10] = $random; // = 32'haaaaaaaa;
        sv.coretop1.dmem.\mem[11] = $random; // = 32'hbbbbbbbb;
        sv.coretop2.dmem.\mem[11] = $random; // = 32'hbbbbbbbb;
        sv.coretop1.dmem.\mem[12] = $random; // = 32'hcccccccc;
        sv.coretop2.dmem.\mem[12] = $random; // = 32'hcccccccc;
        sv.coretop1.dmem.\mem[13] = $random; // = 32'hdddddddd;
        sv.coretop2.dmem.\mem[13] = $random; // = 32'hdddddddd;
        sv.coretop1.dmem.\mem[14] = $random; // = 32'heeeeeeee;
        sv.coretop2.dmem.\mem[14] = $random; // = 32'heeeeeeee;
        sv.coretop1.dmem.\mem[15] = $random; // = 32'hffffffff;
        sv.coretop2.dmem.\mem[15] = $random; // = 32'hffffffff;
`endif
`ifdef MODEL
        sv.model1.dmem.mem[0] = $random; // = 32'h00000000;
        sv.model2.dmem.mem[0] = $random; // = 32'h00000000;
        sv.model1.dmem.mem[1] = $random; // = 32'h11111111;
        sv.model2.dmem.mem[1] = $random; // = 32'h11111111;
        sv.model1.dmem.mem[2] = $random; // = 32'h22222222;
        sv.model2.dmem.mem[2] = $random; // = 32'h22222222;
        sv.model1.dmem.mem[3] = $random; // = 32'h33333333;
        sv.model2.dmem.mem[3] = $random; // = 32'h33333333;
        sv.model1.dmem.mem[4] = $random; // = 32'h44444444;
        sv.model2.dmem.mem[4] = $random; // = 32'h44444444;
        sv.model1.dmem.mem[5] = $random; // = 32'h55555555;
        sv.model2.dmem.mem[5] = $random; // = 32'h55555555;
        sv.model1.dmem.mem[6] = $random; // = 32'h66666666;
        sv.model2.dmem.mem[6] = $random; // = 32'h66666666;
        sv.model1.dmem.mem[7] = $random; // = 32'h77777777;
        sv.model2.dmem.mem[7] = $random; // = 32'h77777777;
        sv.model1.dmem.mem[8] = $random; // = 32'h88888888;
        sv.model2.dmem.mem[8] = $random; // = 32'h88888888;
        sv.model1.dmem.mem[9] = $random; // = 32'h99999999;
        sv.model2.dmem.mem[9] = $random; // = 32'h99999999;
        sv.model1.dmem.mem[10] = $random; // = 32'haaaaaaaa;
        sv.model2.dmem.mem[10] = $random; // = 32'haaaaaaaa;
        sv.model1.dmem.mem[11] = $random; // = 32'hbbbbbbbb;
        sv.model2.dmem.mem[11] = $random; // = 32'hbbbbbbbb;
        sv.model1.dmem.mem[12] = $random; // = 32'hcccccccc;
        sv.model2.dmem.mem[12] = $random; // = 32'hcccccccc;
        sv.model1.dmem.mem[13] = $random; // = 32'hdddddddd;
        sv.model2.dmem.mem[13] = $random; // = 32'hdddddddd;
        sv.model1.dmem.mem[14] = $random; // = 32'heeeeeeee;
        sv.model2.dmem.mem[14] = $random; // = 32'heeeeeeee;
        sv.model1.dmem.mem[15] = $random; // = 32'hffffffff;
        sv.model2.dmem.mem[15] = $random; // = 32'hffffffff;
`endif
    end

`endif

endmodule