
`define SODOR3_SIGNALS
// `undef SODOR3_SIGNALS

`define SODOR5_SIGNALS
`undef SODOR5_SIGNALS

`define SODORU_SIGNALS
`undef SODORU_SIGNALS

`define RF_EXPOSED

`define RANDOMIZE

    module sodor_tb();
        parameter CLK_CYCLE_TIME = 10;
        parameter IMEM_INTERVAL = 30;
        parameter SIM_CYCLE = 21; // 100000000;
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
            $dumpfile("sodor_wave_pipeline.vcd");
            $dumpvars(0, sodor_tb);
        end

        
        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        wire [31:0] tb_in_io_imem_resp_bits_data;
        wire [31:0] tb_ou_io_imem_req_bits_addr;
        wire tb_ou_io_imem_req_valid;
        
    // Program array
wire [31:0] program_array [0:7];

assign program_array[0] = 32'h00000013; // 32'h00000013; // nop : 00000013
assign program_array[1] = 32'h00200093; // 32'h97b00883; // addi r1 r0 2 : 00200093
assign program_array[2] = 32'h00102223; // 32'hb3b71d03; // sw r0(4) r1 : 00102223
assign program_array[3] = 32'h00402103; // 32'h07768803; // lw r2 r0(4) : 00402103
assign program_array[4] = 32'h00000013; // 32'hdacd2793; // nop : 00000013
assign program_array[5] = 32'h00000013; // 32'h109e1983; // nop : 00000013
assign program_array[6] = 32'h00000013; // 32'h00b05713; // nop : 00000013
assign program_array[7] = 32'h00000013; // 32'h6ab99303; // nop : 00000013

    // Forcing values
    

        assign tb_in_io_imem_resp_bits_data = program_array[(tb_ou_io_imem_req_bits_addr[4:2])];
            // (!CLK_CYCLE[0]) ? 32'h04002283 : 
            // (CLK_CYCLE < 4'd5) ? 32'h00200313 : 32'h;

        CoreTop coretop (
            .clock(clk),
            .reset(reset),
            .fe_in_io_imem_resp_bits_data(tb_in_io_imem_resp_bits_data),
            .fe_ou_io_imem_req_bits_addr(tb_ou_io_imem_req_bits_addr),
            .fe_ou_io_imem_req_valid(tb_ou_io_imem_req_valid)
        );

`ifdef RANDOMIZE
    initial begin
    `ifdef SODOR5_SIGNALS
        coretop.core.d.regfile.\regfile[0] = $random;
        coretop.core.d.regfile.\regfile[1] = $random;
        coretop.core.d.regfile.\regfile[2] = $random;
        coretop.core.d.regfile.\regfile[3] = $random;
        coretop.core.d.regfile.\regfile[4] = $random;
        coretop.core.d.regfile.\regfile[5] = $random;
        coretop.core.d.regfile.\regfile[6] = $random;
        coretop.core.d.regfile.\regfile[7] = $random;
        coretop.core.d.regfile.\regfile[8] = $random;
        coretop.core.d.regfile.\regfile[9] = $random;
        coretop.core.d.regfile.\regfile[10] = $random;
        coretop.core.d.regfile.\regfile[11] = $random;
        coretop.core.d.regfile.\regfile[12] = $random;
        coretop.core.d.regfile.\regfile[13] = $random;
        coretop.core.d.regfile.\regfile[14] = $random;
        coretop.core.d.regfile.\regfile[15] = $random;
        coretop.core.d.regfile.\regfile[16] = $random;
        coretop.core.d.regfile.\regfile[17] = $random;
        coretop.core.d.regfile.\regfile[18] = $random;
        coretop.core.d.regfile.\regfile[19] = $random;
        coretop.core.d.regfile.\regfile[20] = $random;
        coretop.core.d.regfile.\regfile[21] = $random;
        coretop.core.d.regfile.\regfile[22] = $random;
        coretop.core.d.regfile.\regfile[23] = $random;
        coretop.core.d.regfile.\regfile[24] = $random;
        coretop.core.d.regfile.\regfile[25] = $random;
        coretop.core.d.regfile.\regfile[26] = $random;
        coretop.core.d.regfile.\regfile[27] = $random;
        coretop.core.d.regfile.\regfile[28] = $random;
        coretop.core.d.regfile.\regfile[29] = $random;
        coretop.core.d.regfile.\regfile[30] = $random;
        coretop.core.d.regfile.\regfile[31] = $random;
    `endif
    `ifdef SODOR3_SIGNALS
        coretop.core.dpath.\regfile[0] = $random;
        coretop.core.dpath.\regfile[1] = $random;
        coretop.core.dpath.\regfile[2] = $random;
        coretop.core.dpath.\regfile[3] = $random;
        coretop.core.dpath.\regfile[4] = $random;
        coretop.core.dpath.\regfile[5] = $random;
        coretop.core.dpath.\regfile[6] = $random;
        coretop.core.dpath.\regfile[7] = $random;
        coretop.core.dpath.\regfile[8] = $random;
        coretop.core.dpath.\regfile[9] = $random;
        coretop.core.dpath.\regfile[10] = $random;
        coretop.core.dpath.\regfile[11] = $random;
        coretop.core.dpath.\regfile[12] = $random;
        coretop.core.dpath.\regfile[13] = $random;
        coretop.core.dpath.\regfile[14] = $random;
        coretop.core.dpath.\regfile[15] = $random;
        coretop.core.dpath.\regfile[16] = $random;
        coretop.core.dpath.\regfile[17] = $random;
        coretop.core.dpath.\regfile[18] = $random;
        coretop.core.dpath.\regfile[19] = $random;
        coretop.core.dpath.\regfile[20] = $random;
        coretop.core.dpath.\regfile[21] = $random;
        coretop.core.dpath.\regfile[22] = $random;
        coretop.core.dpath.\regfile[23] = $random;
        coretop.core.dpath.\regfile[24] = $random;
        coretop.core.dpath.\regfile[25] = $random;
        coretop.core.dpath.\regfile[26] = $random;
        coretop.core.dpath.\regfile[27] = $random;
        coretop.core.dpath.\regfile[28] = $random;
        coretop.core.dpath.\regfile[29] = $random;
        coretop.core.dpath.\regfile[30] = $random;
        coretop.core.dpath.\regfile[31] = $random;
    `endif
        coretop.dmem.\mem[0] = 32'h00000000;
        coretop.dmem.\mem[1] = 32'h11111111;
        coretop.dmem.\mem[2] = 32'h22222222;
        coretop.dmem.\mem[3] = 32'h33333333;
        coretop.dmem.\mem[4] = 32'h44444444;
        coretop.dmem.\mem[5] = 32'h55555555;
        coretop.dmem.\mem[6] = 32'h66666666;
        coretop.dmem.\mem[7] = 32'h77777777;
        coretop.dmem.\mem[8] = 32'h88888888;
        coretop.dmem.\mem[9] = 32'h99999999;
        coretop.dmem.\mem[10] = 32'haaaaaaaa;
        coretop.dmem.\mem[11] = 32'hbbbbbbbb;
        coretop.dmem.\mem[12] = 32'hcccccccc;
        coretop.dmem.\mem[13] = 32'hdddddddd;
        coretop.dmem.\mem[14] = 32'heeeeeeee;
        coretop.dmem.\mem[15] = 32'hffffffff;
    end
`endif
    endmodule
    