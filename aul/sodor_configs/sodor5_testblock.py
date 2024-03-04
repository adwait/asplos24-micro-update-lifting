


from typing import List


def make_testblock(program: str, forcing_values: str = None):
    return """
    // sodor_tb.v
    `define DESIGN_REGS_RANDOMIZE

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
            $dumpfile(\"sodor_wave_pipeline.vcd\");
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
    {}

    // Forcing values
    {}

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
    endmodule
    """.format(program, '' if forcing_values is None else forcing_values)


def make_testblock_by_seed(seed, ityp:str = "i"):
    if ityp == "i":
        instr = "tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : {imm, rs1, funct3, rd, 7'b0010011};"
    elif ityp == "r":
        instr = "tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : {7'd0, rs2, rs1, funct3, rd, 7'b0110011};"
    elif ityp == "il":
        instr = """tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : (
            ils_choice[0] ? {imm, rs1, funct3, rd, 7'b0010011} : {imm_l, rs1, funct3_l, rd, 7'b0000011}
        );"""
    elif ityp == "ils":
        instr = """tb_in_io_imem_resp_bits_data = reset ? 32'h00000013 : (
            (ils_choice[1]) ? {imm, rs1, funct3, rd, 7'b0010011} : (ils_choice[0] ? {imm_l[11:5], rs2, rs1, 3'b0, imm_l[4:0], 7'b0100011} : {imm_l, rs1, funct3_l, rd, 7'b0000011})
        );"""

    if ityp == "il" or ityp == "ils":
        memblock = """
        sv.s5m.dmem.\\mem[0] = 32'h00000000;
        sv.s5m.dmem.\\mem[1] = 32'h11111111;
        sv.s5m.dmem.\\mem[2] = 32'h22222222;
        sv.s5m.dmem.\\mem[3] = 32'h33333333;
        sv.s5m.dmem.\\mem[4] = 32'h44444444;
        sv.s5m.dmem.\\mem[5] = 32'h55555555;
        sv.s5m.dmem.\\mem[6] = 32'h66666666;
        sv.s5m.dmem.\\mem[7] = 32'h77777777;
        sv.s5m.dmem.\\mem[8] = 32'h88888888;
        sv.s5m.dmem.\\mem[9] = 32'h99999999;
        sv.s5m.dmem.\\mem[10] = 32'haaaaaaaa;
        sv.s5m.dmem.\\mem[11] = 32'hbbbbbbbb;
        sv.s5m.dmem.\\mem[12] = 32'hcccccccc;
        sv.s5m.dmem.\\mem[13] = 32'hdddddddd;
        sv.s5m.dmem.\\mem[14] = 32'heeeeeeee;
        sv.s5m.dmem.\\mem[15] = 32'hffffffff;
        """
    else:
        memblock = ""
    return f"""
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

    integer seed = {seed};
    // Set up instructions for this particular test type
    reg [11:0] imm, imm_l;
    reg [4:0] rs1, rs2, rd;
    reg [2:0] funct3, funct3_l;
    reg [1:0] ils_choice;

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
        ils_choice = $urandom(seed);

        {instr}
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
        sv.coretop.core.d.regfile.\\regfile[0] = sv.s5m.regfile[0][31:0];
        sv.coretop.core.d.regfile.\\regfile[1] = sv.s5m.regfile[1][31:0];
        sv.coretop.core.d.regfile.\\regfile[2] = sv.s5m.regfile[2][31:0];
        sv.coretop.core.d.regfile.\\regfile[3] = sv.s5m.regfile[3][31:0];
        sv.coretop.core.d.regfile.\\regfile[4] = sv.s5m.regfile[4][31:0];
        sv.coretop.core.d.regfile.\\regfile[5] = sv.s5m.regfile[5][31:0];
        sv.coretop.core.d.regfile.\\regfile[6] = sv.s5m.regfile[6][31:0];
        sv.coretop.core.d.regfile.\\regfile[7] = sv.s5m.regfile[7][31:0];
        sv.coretop.core.d.regfile.\\regfile[8] = sv.s5m.regfile[8][31:0];
        sv.coretop.core.d.regfile.\\regfile[9] = sv.s5m.regfile[9][31:0];
        sv.coretop.core.d.regfile.\\regfile[10] = sv.s5m.regfile[10][31:0];
        sv.coretop.core.d.regfile.\\regfile[11] = sv.s5m.regfile[11][31:0];
        sv.coretop.core.d.regfile.\\regfile[12] = sv.s5m.regfile[12][31:0];
        sv.coretop.core.d.regfile.\\regfile[13] = sv.s5m.regfile[13][31:0];
        sv.coretop.core.d.regfile.\\regfile[14] = sv.s5m.regfile[14][31:0];
        sv.coretop.core.d.regfile.\\regfile[15] = sv.s5m.regfile[15][31:0];
        sv.coretop.core.d.regfile.\\regfile[16] = sv.s5m.regfile[16][31:0];
        sv.coretop.core.d.regfile.\\regfile[17] = sv.s5m.regfile[17][31:0];
        sv.coretop.core.d.regfile.\\regfile[18] = sv.s5m.regfile[18][31:0];
        sv.coretop.core.d.regfile.\\regfile[19] = sv.s5m.regfile[19][31:0];
        sv.coretop.core.d.regfile.\\regfile[20] = sv.s5m.regfile[20][31:0];
        sv.coretop.core.d.regfile.\\regfile[21] = sv.s5m.regfile[21][31:0];
        sv.coretop.core.d.regfile.\\regfile[22] = sv.s5m.regfile[22][31:0];
        sv.coretop.core.d.regfile.\\regfile[23] = sv.s5m.regfile[23][31:0];
        sv.coretop.core.d.regfile.\\regfile[24] = sv.s5m.regfile[24][31:0];
        sv.coretop.core.d.regfile.\\regfile[25] = sv.s5m.regfile[25][31:0];
        sv.coretop.core.d.regfile.\\regfile[26] = sv.s5m.regfile[26][31:0];
        sv.coretop.core.d.regfile.\\regfile[27] = sv.s5m.regfile[27][31:0];
        sv.coretop.core.d.regfile.\\regfile[28] = sv.s5m.regfile[28][31:0];
        sv.coretop.core.d.regfile.\\regfile[29] = sv.s5m.regfile[29][31:0];
        sv.coretop.core.d.regfile.\\regfile[30] = sv.s5m.regfile[30][31:0];
        sv.coretop.core.d.regfile.\\regfile[31] = sv.s5m.regfile[31][31:0];

        {memblock}
        sv.coretop.dmem.\\mem[0] = 32'h00000000;
        sv.coretop.dmem.\\mem[1] = 32'h11111111;
        sv.coretop.dmem.\\mem[2] = 32'h22222222;
        sv.coretop.dmem.\\mem[3] = 32'h33333333;
        sv.coretop.dmem.\\mem[4] = 32'h44444444;
        sv.coretop.dmem.\\mem[5] = 32'h55555555;
        sv.coretop.dmem.\\mem[6] = 32'h66666666;
        sv.coretop.dmem.\\mem[7] = 32'h77777777;
        sv.coretop.dmem.\\mem[8] = 32'h88888888;
        sv.coretop.dmem.\\mem[9] = 32'h99999999;
        sv.coretop.dmem.\\mem[10] = 32'haaaaaaaa;
        sv.coretop.dmem.\\mem[11] = 32'hbbbbbbbb;
        sv.coretop.dmem.\\mem[12] = 32'hcccccccc;
        sv.coretop.dmem.\\mem[13] = 32'hdddddddd;
        sv.coretop.dmem.\\mem[14] = 32'heeeeeeee;
        sv.coretop.dmem.\\mem[15] = 32'hffffffff;
    end

`endif

endmodule"""

def make_testblock_by_program(program: List[str], ityp: str = "i"):
    bl = (len(program)-1).bit_length()
    bln = 1<<bl
    prog_array = "wire [31:0] program_array [0:{}];\n".format(bln-1)
    prog_insts = []
    program.extend(["32'h00000013" for _ in range(bln-len(program))])
    for i, inst in enumerate(program):
        prog_insts.append(
            "assign program_array[{}] = {};\n".format(i, inst)
        )
    program = "{}\n{}".format(prog_array, "".join(prog_insts))
    instr = f"tb_in_io_imem_resp_bits_data <= reset ? 32'h00000013 : program_array[CLK_CYCLE[{bl-1}:0]];"
    if ityp == "i":
        memblock = ""
    elif ityp == "r":
        memblock = ""
    elif ityp == "il" or ityp == "ils":
        memblock = """
        sv.s5m.dmem.\\mem[0] = 32'h00000000;
        sv.s5m.dmem.\\mem[1] = 32'h11111111;
        sv.s5m.dmem.\\mem[2] = 32'h22222222;
        sv.s5m.dmem.\\mem[3] = 32'h33333333;
        sv.s5m.dmem.\\mem[4] = 32'h44444444;
        sv.s5m.dmem.\\mem[5] = 32'h55555555;
        sv.s5m.dmem.\\mem[6] = 32'h66666666;
        sv.s5m.dmem.\\mem[7] = 32'h77777777;
        sv.s5m.dmem.\\mem[8] = 32'h88888888;
        sv.s5m.dmem.\\mem[9] = 32'h99999999;
        sv.s5m.dmem.\\mem[10] = 32'haaaaaaaa;
        sv.s5m.dmem.\\mem[11] = 32'hbbbbbbbb;
        sv.s5m.dmem.\\mem[12] = 32'hcccccccc;
        sv.s5m.dmem.\\mem[13] = 32'hdddddddd;
        sv.s5m.dmem.\\mem[14] = 32'heeeeeeee;
        sv.s5m.dmem.\\mem[15] = 32'hffffffff;
        """
    return f"""
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

    {program}

    always @(posedge clk) begin
        {instr}
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
        sv.coretop.core.d.regfile.\\regfile[0] = sv.s5m.regfile[0][31:0];
        sv.coretop.core.d.regfile.\\regfile[1] = sv.s5m.regfile[1][31:0];
        sv.coretop.core.d.regfile.\\regfile[2] = sv.s5m.regfile[2][31:0];
        sv.coretop.core.d.regfile.\\regfile[3] = sv.s5m.regfile[3][31:0];
        sv.coretop.core.d.regfile.\\regfile[4] = sv.s5m.regfile[4][31:0];
        sv.coretop.core.d.regfile.\\regfile[5] = sv.s5m.regfile[5][31:0];
        sv.coretop.core.d.regfile.\\regfile[6] = sv.s5m.regfile[6][31:0];
        sv.coretop.core.d.regfile.\\regfile[7] = sv.s5m.regfile[7][31:0];
        sv.coretop.core.d.regfile.\\regfile[8] = sv.s5m.regfile[8][31:0];
        sv.coretop.core.d.regfile.\\regfile[9] = sv.s5m.regfile[9][31:0];
        sv.coretop.core.d.regfile.\\regfile[10] = sv.s5m.regfile[10][31:0];
        sv.coretop.core.d.regfile.\\regfile[11] = sv.s5m.regfile[11][31:0];
        sv.coretop.core.d.regfile.\\regfile[12] = sv.s5m.regfile[12][31:0];
        sv.coretop.core.d.regfile.\\regfile[13] = sv.s5m.regfile[13][31:0];
        sv.coretop.core.d.regfile.\\regfile[14] = sv.s5m.regfile[14][31:0];
        sv.coretop.core.d.regfile.\\regfile[15] = sv.s5m.regfile[15][31:0];
        sv.coretop.core.d.regfile.\\regfile[16] = sv.s5m.regfile[16][31:0];
        sv.coretop.core.d.regfile.\\regfile[17] = sv.s5m.regfile[17][31:0];
        sv.coretop.core.d.regfile.\\regfile[18] = sv.s5m.regfile[18][31:0];
        sv.coretop.core.d.regfile.\\regfile[19] = sv.s5m.regfile[19][31:0];
        sv.coretop.core.d.regfile.\\regfile[20] = sv.s5m.regfile[20][31:0];
        sv.coretop.core.d.regfile.\\regfile[21] = sv.s5m.regfile[21][31:0];
        sv.coretop.core.d.regfile.\\regfile[22] = sv.s5m.regfile[22][31:0];
        sv.coretop.core.d.regfile.\\regfile[23] = sv.s5m.regfile[23][31:0];
        sv.coretop.core.d.regfile.\\regfile[24] = sv.s5m.regfile[24][31:0];
        sv.coretop.core.d.regfile.\\regfile[25] = sv.s5m.regfile[25][31:0];
        sv.coretop.core.d.regfile.\\regfile[26] = sv.s5m.regfile[26][31:0];
        sv.coretop.core.d.regfile.\\regfile[27] = sv.s5m.regfile[27][31:0];
        sv.coretop.core.d.regfile.\\regfile[28] = sv.s5m.regfile[28][31:0];
        sv.coretop.core.d.regfile.\\regfile[29] = sv.s5m.regfile[29][31:0];
        sv.coretop.core.d.regfile.\\regfile[30] = sv.s5m.regfile[30][31:0];
        sv.coretop.core.d.regfile.\\regfile[31] = sv.s5m.regfile[31][31:0];

        {memblock}
        sv.coretop.dmem.\\mem[0] = 32'h00000000;
        sv.coretop.dmem.\\mem[1] = 32'h11111111;
        sv.coretop.dmem.\\mem[2] = 32'h22222222;
        sv.coretop.dmem.\\mem[3] = 32'h33333333;
        sv.coretop.dmem.\\mem[4] = 32'h44444444;
        sv.coretop.dmem.\\mem[5] = 32'h55555555;
        sv.coretop.dmem.\\mem[6] = 32'h66666666;
        sv.coretop.dmem.\\mem[7] = 32'h77777777;
        sv.coretop.dmem.\\mem[8] = 32'h88888888;
        sv.coretop.dmem.\\mem[9] = 32'h99999999;
        sv.coretop.dmem.\\mem[10] = 32'haaaaaaaa;
        sv.coretop.dmem.\\mem[11] = 32'hbbbbbbbb;
        sv.coretop.dmem.\\mem[12] = 32'hcccccccc;
        sv.coretop.dmem.\\mem[13] = 32'hdddddddd;
        sv.coretop.dmem.\\mem[14] = 32'heeeeeeee;
        sv.coretop.dmem.\\mem[15] = 32'hffffffff;
    end

`endif

endmodule"""

def make_distinguish_block(t, assumes, block, asserts):
    return """
`define ITYPE
`define NUM_REGS    32
`define WORD_SIZE   32


module sodor5_verif(
    input clk,
);

    reg reset;
    reg past_reset;
    reg [2:0] counter;
    reg [7:0] CLK_CYCLE;
    reg init;
    initial begin
        past_reset = 1;
        reset = 1;
        init = 1;
        counter = 0;
        CLK_CYCLE = 0;
    end
    wire [31:0] in_io_imem_resp_bits_data;

`ifdef FORMAL

`ifdef ITYPE
    (* anyseq *) reg [11:0] imm;
    (* anyseq *) reg [4:0] rs1;
    (* anyseq *) reg [4:0] rs2;
    (* anyseq *) reg [4:0] rd;
    (* anyseq *) reg [2:0] funct3;
    wire [11:0] imm_clean;
    assign imm_clean = (funct3 == 5) ? (imm & 12'b010000011111) : ((funct3 == 1) ? (imm & 12'b000000011111) : imm);
    assign in_io_imem_resp_bits_data = reset ? 32'h00000013 : {imm_clean, rs1, funct3, rd, 7'b0010011};
`endif

`endif

    /* ================= Functions ================= */
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
    
	function [2:0] get_funct3 (input [31:0] inst);
		begin
			get_funct3 = inst[14:12];
		end
	endfunction
	function [6:0] get_funct7 (input [31:0] inst);
		begin
			get_funct7 = inst[31:25];
		end
	endfunction

    function [31:0] sra (input [63:0] d, input [4:0] shamt);
        begin
            sra = (d >> shamt);
        end
    endfunction
    function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [3:0] alu_fun);
        begin
            alu_compute_i = 
                alu_fun == 0 ? imm_data + reg_data : (
                alu_fun == 2 ? reg_data << imm_data[4:0] : (
                alu_fun == 3 ? reg_data >> imm_data[4:0] : (
                alu_fun == 4 ? sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]) : (
                alu_fun == 5 ? (imm_data & reg_data) : (
                alu_fun == 6 ? (imm_data | reg_data) : (
                alu_fun == 7 ? (imm_data ^ reg_data) : (
                alu_fun == 8 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
                alu_fun == 9 ? ((reg_data < imm_data) ? 1 : 0) : (0)
            ))))))));
        end
    endfunction
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
// `endif

    // Design signals
    wire [31:0] de_io_imem_req_bits_addr;
    wire de_io_imem_req_valid;
    wire [1023:0] de_io_port_regfile;
    wire [31:0] de_io_port_imm;
    wire [31:0] de_io_port_alu_out;
    wire [4:0] de_io_port_reg_rs1_addr_in;
    wire [4:0] de_io_port_reg_rs2_addr_in;
    wire [31:0] de_io_port_reg_rs1_data_out;
    wire [31:0] de_io_port_reg_rs2_data_out;
    wire [31:0] de_io_port_reg_rd_data_in;
    wire [4:0] de_io_port_reg_rd_addr_in;
    // Design signals 2
    wire [31:0] de_io_port_if_reg_pc;
    wire [31:0] de_io_port_dec_reg_pc;
    wire [31:0] de_io_port_exe_reg_pc;
    wire [31:0] de_io_port_mem_reg_pc;
    wire        de_io_port_lb_table_valid;
    wire [31:0] de_io_port_lb_table_addr;
    wire [31:0] de_io_port_lb_table_data;
    wire [31:0] de_io_port_mem_reg_alu_out;
    // Design control signals
    wire [31:0] de_io_port_dec_reg_inst;
    wire [31:0] de_io_port_exe_reg_inst;
    wire [31:0] de_io_port_mem_reg_inst;

    wire [4:0] de_io_port_dec_wbaddr;
    wire [4:0] de_io_port_exe_reg_wbaddr;
    wire [4:0] de_io_port_mem_reg_wbaddr;
    wire [31:0] de_io_port_imm_sbtype_sext;
    wire [3:0] de_io_port_alu_fun;

    CoreTop coretop (
        .clock(clk),
        .reset(reset),
        .fe_in_io_imem_resp_bits_data(in_io_imem_resp_bits_data),
        .fe_ou_io_imem_req_bits_addr(de_io_imem_req_bits_addr),
        .fe_ou_io_imem_req_valid(de_io_imem_req_valid),

        .port_regfile(de_io_port_regfile),
        .port_imm(de_io_port_imm),
        .port_alu_out(de_io_port_alu_out),
        .port_reg_rs1_addr_in(de_io_port_reg_rs1_addr_in),
        .port_reg_rs2_addr_in(de_io_port_reg_rs2_addr_in),
        .port_reg_rs1_data_out(de_io_port_reg_rs1_data_out),
        .port_reg_rs2_data_out(de_io_port_reg_rs2_data_out),
        .port_reg_rd_data_in(de_io_port_reg_rd_data_in),
        .port_reg_rd_addr_in(de_io_port_reg_rd_addr_in),
        .port_dec_reg_inst(de_io_port_dec_reg_inst),
        .port_exe_reg_inst(de_io_port_exe_reg_inst),
        .port_mem_reg_inst(de_io_port_mem_reg_inst),
        .port_mem_reg_alu_out(de_io_port_mem_reg_alu_out),
        .port_if_reg_pc(de_io_port_if_reg_pc),
        .port_dec_reg_pc(de_io_port_dec_reg_pc),
        .port_exe_reg_pc(de_io_port_exe_reg_pc),
        .port_mem_reg_pc(de_io_port_mem_reg_pc),
        .port_lb_table_valid(de_io_port_lb_table_valid),
        .port_lb_table_addr(de_io_port_lb_table_addr),
        .port_lb_table_data(de_io_port_lb_table_data),
        .port_dec_wbaddr(de_io_port_dec_wbaddr),
        .port_exe_reg_wbaddr(de_io_port_exe_reg_wbaddr),
        .port_mem_reg_wbaddr(de_io_port_mem_reg_wbaddr),
        .port_imm_sbtype_sext(de_io_port_imm_sbtype_sext),
        .port_alu_fun(de_io_port_alu_fun)
    );


    wire [`WORD_SIZE*`NUM_REGS-1:0] copy1_port_regfile;
    // Copy 1
    // Architectural variables
    reg [31:0] copy1_regfile [0:31];
    reg [31:0] copy1_pc;    
    // Micro-architectural variables
    reg [2:0]  copy1_funct3;
    reg [31:0] copy1_imm;
    reg [31:0] copy1_alu_out;
    reg [4:0] copy1_reg_rs1_addr_in;
    reg [4:0] copy1_reg_rs2_addr_in;
    reg [31:0] copy1_reg_rs1_data_out;
    reg [31:0] copy1_reg_rs2_data_out;
    reg [31:0] copy1_reg_rd_data_in;
    reg [4:0] copy1_reg_rd_addr_in;
    reg [31:0] copy1_if_reg_pc;
    reg [31:0] copy1_dec_reg_pc;
    reg [31:0] copy1_exe_reg_pc;
    reg [31:0] copy1_mem_reg_pc;
    reg        copy1_lb_table_valid;
    reg [31:0] copy1_lb_table_addr;
    reg [31:0] copy1_lb_table_data;
    reg [31:0] copy1_mem_reg_alu_out;
    reg [31:0] copy1_dec_reg_inst;
    reg [31:0] copy1_exe_reg_inst;
    reg [31:0] copy1_mem_reg_inst;
    reg [4:0] copy1_dec_wbaddr;
    reg [4:0] copy1_exe_reg_wbaddr;
    reg [4:0] copy1_mem_reg_wbaddr;
    reg [31:0] copy1_imm_sbtype_sext;
    reg [3:0] copy1_alu_fun;
    // Expose these variables
    genvar copy1_i_port;
    for (copy1_i_port = 0; copy1_i_port<`NUM_REGS; copy1_i_port=copy1_i_port+1) begin
        assign copy1_port_regfile[`WORD_SIZE*copy1_i_port+31:`WORD_SIZE*copy1_i_port] = copy1_regfile[copy1_i_port];
    end

    wire [`WORD_SIZE*`NUM_REGS-1:0] copy2_port_regfile;
    // Architectural variables
    reg [31:0] copy2_regfile [0:31];
    reg [31:0] copy2_pc;
    // Micro-architectural variables
    reg [2:0]  copy2_funct3;
    reg [31:0] copy2_imm;
    reg [31:0] copy2_alu_out;
    reg [4:0] copy2_reg_rs1_addr_in;
    reg [4:0] copy2_reg_rs2_addr_in;
    reg [31:0] copy2_reg_rs1_data_out;
    reg [31:0] copy2_reg_rs2_data_out;
    reg [31:0] copy2_reg_rd_data_in;
    reg [4:0] copy2_reg_rd_addr_in;
    reg [31:0] copy2_if_reg_pc;
    reg [31:0] copy2_dec_reg_pc;
    reg [31:0] copy2_exe_reg_pc;
    reg [31:0] copy2_mem_reg_pc;
    reg        copy2_lb_table_valid;
    reg [31:0] copy2_lb_table_addr;
    reg [31:0] copy2_lb_table_data;
    reg [31:0] copy2_mem_reg_alu_out;
    reg [31:0] copy2_dec_reg_inst;
    reg [31:0] copy2_exe_reg_inst;
    reg [31:0] copy2_mem_reg_inst;
    reg [4:0] copy2_dec_wbaddr;
    reg [4:0] copy2_exe_reg_wbaddr;
    reg [4:0] copy2_mem_reg_wbaddr;
    reg [31:0] copy2_imm_sbtype_sext;
    reg [3:0] copy2_alu_fun;
    // Expose these variables
    genvar copy2_i_port;
    for (copy2_i_port = 0; copy2_i_port<`NUM_REGS; copy2_i_port=copy2_i_port+1) begin
        assign copy2_port_regfile[`WORD_SIZE*copy2_i_port+31:`WORD_SIZE*copy2_i_port] = copy2_regfile[copy2_i_port];
    end

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        past_reset <= reset;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 1 && init) begin
            reset <= 0;
        end
""" + """
`ifdef FORMAL
    if (CLK_CYCLE == {}) begin
        
    end else if (CLK_CYCLE == {}) begin
        {}
        {}
    end

`endif
    end

endmodule
""".format(t-1, t, ''.join(assumes), ''.join(block)+''.join(asserts))