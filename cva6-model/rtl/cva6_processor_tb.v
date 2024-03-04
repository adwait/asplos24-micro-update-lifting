


    module cva6_processor_tb ();
        parameter PHASE_TIME = 10;
        parameter CLK_CYCLE_TIME = PHASE_TIME * 2;
        parameter IMEM_INTERVAL = 20;
        parameter SIM_CYCLE = 25; // 100000000;
        parameter SIM_TIME = SIM_CYCLE * PHASE_TIME * 2;

        reg [31:0] 			CLK_CYCLE;
        reg 				clk;
        reg 				reset;
        
        initial begin
            clk = 1;
            forever #PHASE_TIME clk = ~clk;
        end

        initial begin
            reset = 1;
            // #IMEM_INTERVAL reset = 1;
            #IMEM_INTERVAL 
            reset = 0;
            #IMEM_INTERVAL 
            #IMEM_INTERVAL 
            reset = 1;
        end

        initial begin
            CLK_CYCLE = 32'h0;
        end
        
        always @(posedge clk) begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        end

        initial begin
            $dumpfile("cva6_processor_tb_wave_pipeline.vcd");
            $dumpvars(0, cva6_processor_tb);
        end

        initial begin
            #IMEM_INTERVAL;
            #SIM_TIME;
            $finish;
        end

        integer seed = 12;

    wire [31:0] de_io_instr_i;
    reg [31:0] tb_io_instr_i;
    assign de_io_instr_i = tb_io_instr_i;
    wire de_io_instr_valid_i;
    reg tb_io_instr_valid_i;
    assign de_io_instr_valid_i = tb_io_instr_valid_i;
    wire de_io_store_mem_resp_i;
    reg tb_io_store_mem_resp_i;
    assign de_io_store_mem_resp_i = tb_io_store_mem_resp_i;
    wire de_io_load_mem_resp_i;
    reg tb_io_load_mem_resp_i;
    assign de_io_load_mem_resp_i = tb_io_load_mem_resp_i;
    wire de_io_instr_ready_o;

    cva6_processor_shim shim_i (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i),
        .instr_valid_i(de_io_instr_valid_i),
        .instr_ready_o(de_io_instr_ready_o),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .load_mem_resp_i(de_io_load_mem_resp_i)
    );
    

    reg [11:0] imm;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [6:0] opcode;
    reg [3:0] funct3;
    reg [31:0] next_instr;

    reg [1:0] choice;
    integer i;


    initial begin
        #20;
            choice = 0;
            next_instr = 32'h00000013;

            tb_io_instr_i = 32'h0;
            tb_io_instr_valid_i = 0;
            tb_io_load_mem_resp_i = 0;
            tb_io_store_mem_resp_i = 0;
        #40;
    
    
        for (i = 0; i < 30; i = i + 1) begin
            
            choice = $random(seed);
            imm = $random(seed);
            rs1 = $random(seed);
            rs2 = $random(seed);
            rd = $random(seed);
            funct3 = $random(seed);
            tb_io_instr_i = next_instr;
            tb_io_load_mem_resp_i = $random(seed);
            tb_io_store_mem_resp_i = $random(seed);

            if (funct3 == 5) begin
                imm = (imm & 12'b010000011111);
            end else if (funct3 == 1) begin
                imm = (imm & 12'b000000011111);
            end

            if (de_io_instr_ready_o) begin
                tb_io_instr_valid_i = 1;
                if (choice == 0) begin
                    // Load instruction
                    opcode = 7'b0000011;
                    funct3 = 2;
                    next_instr = {imm, rs1, funct3, rd, opcode};
                    tb_io_instr_valid_i = 1;
                end else if (choice == 1) begin
                    // Store instruction
                    opcode = 7'b0100011;
                    funct3 = 2;
                    next_instr = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
                    tb_io_instr_valid_i = 1;
                end else begin
                    // ALU instruction
                    opcode = 7'b0010011;
                    next_instr = {imm, rs1, funct3, rd, opcode};
                    tb_io_instr_valid_i = 1;
                end
            end else begin
                tb_io_instr_valid_i = 0;
            end


            #20;
        end
    end
    
endmodule
    