


`define NUM_REGS    32
`define WORD_SIZE   32

// sodor_tb.v

module cva6_lsu_formal (
    input clk
    // input [31:0] fe_in_io_imem_resp_bits_data,
    // output [`WORD_SIZE*`NUM_REGS-1:0] port_regfile
);
    
    reg reset;
    reg [2:0] counter;
    reg [4:0] CLK_CYCLE;
    reg init;

    initial begin
        reset = 1;
        init = 1;
        counter = 0;
        CLK_CYCLE = 0;
    end

    always @(posedge clk) begin
        counter <= counter + 1'b1;
        CLK_CYCLE <= CLK_CYCLE + 1'b1;
        if (counter == 7 && init) begin
            init <= 0;
        end
        if (counter == 0 && init) begin
            reset <= 0;
        end
        if (counter == 2 && init) begin
            reset <= 1;
        end

        if (init) begin
            
            // assume(de_io_mem_o_1 == de_io_mem_o_2);
        end
    end


    wire [31:0] de_io_instr_i_2;
    reg [31:0] tb_io_instr_i_2;
    assign de_io_instr_i_2 = tb_io_instr_i_2;
    wire de_io_instr_valid_i_2;
    reg tb_io_instr_valid_i_2;
    assign de_io_instr_valid_i_2 = tb_io_instr_valid_i_2;
    wire de_io_store_mem_resp_i_2;
    (* anyseq *) reg tb_io_store_mem_resp_i_2;
    assign de_io_store_mem_resp_i_2 = tb_io_store_mem_resp_i_2;
    wire de_io_load_mem_resp_i_2;
    (* anyseq *) reg tb_io_load_mem_resp_i_2;
    assign de_io_load_mem_resp_i_2 = tb_io_load_mem_resp_i_2;
    wire de_io_instr_ready_o_2;

    wire [32*32-1:0] de_io_regfile_o_2;
    wire [32*32-1:0] de_io_mem_o_2;

    cva6_processor_shim shim_i_2 (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i_2),
        .instr_valid_i(de_io_instr_valid_i_2),
        .instr_ready_o(de_io_instr_ready_o_2),
        .store_mem_resp_i(1'b0),
        .load_mem_resp_i(1'b1)
`ifdef EXPOSE_STATE
        , .regfile_o(de_io_regfile_o_2)
        , .mem_o(de_io_mem_o_2)
`endif
    );
    

    wire [31:0] de_io_instr_i_1;
    reg [31:0] tb_io_instr_i_1;
    assign de_io_instr_i_1 = tb_io_instr_i_1;
    wire de_io_instr_valid_i_1;
    reg tb_io_instr_valid_i_1;
    assign de_io_instr_valid_i_1 = tb_io_instr_valid_i_1;
    wire de_io_store_mem_resp_i_1;
    (* anyseq *) reg tb_io_store_mem_resp_i_1;
    assign de_io_store_mem_resp_i_1 = tb_io_store_mem_resp_i_1;
    wire de_io_load_mem_resp_i_1;
    (* anyseq *) reg tb_io_load_mem_resp_i_1;
    assign de_io_load_mem_resp_i_1 = tb_io_load_mem_resp_i_1;
    wire de_io_instr_ready_o_1;

    wire [32*32-1:0] de_io_regfile_o_1;
    wire [32*32-1:0] de_io_mem_o_1;

    cva6_processor_shim shim_i_1 (
        .clk_i(clk),
        .rst_ni(reset),
        .instr_i(de_io_instr_i_1),
        .instr_valid_i(de_io_instr_valid_i_1),
        .instr_ready_o(de_io_instr_ready_o_1),
        .store_mem_resp_i(1'b0),
        .load_mem_resp_i(1'b1)
`ifdef EXPOSE_STATE
        , .regfile_o(de_io_regfile_o_1)
        , .mem_o(de_io_mem_o_1)
`endif
    );


    (* anyconst *) reg [11:0] imm;

    // wire [31:0] prog [0:3];
    // // addi x1, x0, 0
    // assign prog[0] = 32'h00000093;
    // // riscv lw instruction
    // // assign prog[0] = {12'h000, 5'b00000, 3'b010, 5'b00010, 7'b0000011}; // 32'h0022183;
    // // assign prog[0] = 32'h0022183;
    // // sw x1, 0(x2)
    // assign prog[1] = {7'd0, 5'b00001, 5'b00010, 3'b010, 5'b00000, 7'b0100011}; // 32'h00112023;
    // // lw x3, 0(x4)
    // assign prog[2] = {12'h000, 5'b00100, 3'b010, 3'b00011, 7'b0000011}; // 32'h00022183;
    // // addi x1, x0, 0
    // assign prog[3] = 32'h00000093;


    (* anyconst *) reg [31:0] instr0;
    (* anyconst *) reg [31:0] instr1;
    (* anyconst *) reg [31:0] instr2;
    (* anyconst *) reg [31:0] instr3;

    wire [31:0] prog [0:3];
    assign prog[0] = instr0;
    assign prog[1] = instr1;
    assign prog[2] = instr2;
    assign prog[3] = instr3;

    reg [31:0] pc_1;
    reg [31:0] pc_2;

    reg local_ready_1;
    reg local_ready_2;


    always @(posedge clk ) begin
        

        if (init && (counter <= 2)) begin
            pc_1 <= 0;
            pc_2 <= 0;
            tb_io_instr_valid_i_1 <= 0;
            tb_io_instr_valid_i_2 <= 0;
            tb_io_instr_i_1 <= 0;
            tb_io_instr_i_2 <= 0;
            local_ready_1 <= 1;
            local_ready_2 <= 1;

            // LW SW LW LW
            assume(instr0[6:0] == 7'b0000011 && instr0[14:12] == 3'b010);
            assume(instr1[6:0] == 7'b0100011 && instr1[14:12] == 3'b010);
            assume(instr2[6:0] == 7'b0000011 && instr2[14:12] == 3'b010);
            assume(instr3[6:0] == 7'b0000011 && instr3[14:12] == 3'b010);
            // RD(LW1) != RS1(SW)
            assume(instr0[11:7] != instr1[19:15]);
            // RD(LW1) != RS1(LW2)
            assume(instr0[11:7] != instr2[19:15]);
            // RD(LW1) != RS1(LW3)
            // assume(instr0[11:7] != instr3[19:15]);
            // assume(instr2[11:7] != instr3[19:15]);

            assume(de_io_regfile_o_1 == de_io_regfile_o_2);
            // assume(de_io_mem_o_1 == de_io_mem_o_2);
        end else if (!init || counter > 2) begin

            assume (de_io_load_mem_resp_i_1 == de_io_load_mem_resp_i_2);
            assume (de_io_store_mem_resp_i_1 == de_io_store_mem_resp_i_2);
            
            tb_io_instr_i_1 = prog[pc_1];

            if (de_io_instr_ready_o_1 && local_ready_1 && pc_1 < 4) begin
                if (tb_io_instr_i_1[6:0] == 7'b0100011 || tb_io_instr_i_1[6:0] == 7'b0000011) begin
                    local_ready_1 = 0;
                end else begin
                    local_ready_1 = 1;
                end
                
                tb_io_instr_valid_i_1 = 1;
                pc_1 = pc_1 + 1;
                tb_io_instr_valid_i_1 = 1;
            end else begin
                local_ready_1 = 1;
                tb_io_instr_valid_i_1 = 0;
            end

            tb_io_instr_i_2 = prog[pc_2];

            if (de_io_instr_ready_o_2 && local_ready_2 && pc_2 < 4) begin
                if (tb_io_instr_i_2[6:0] == 7'b0100011 || tb_io_instr_i_2[6:0] == 7'b0000011) begin
                    local_ready_2 = 0;
                end else begin
                    local_ready_2 = 1;
                end

                tb_io_instr_valid_i_2 = 1;
                pc_2 = pc_2 + 1;
                tb_io_instr_valid_i_2 = 1;
            end else begin
                local_ready_2 = 1;
                tb_io_instr_valid_i_2 = 0;
            end

            assert (de_io_instr_ready_o_1 == de_io_instr_ready_o_2);
            // assert (de_io_regfile_o_1 == de_io_regfile_o_2);
            // assert ((pc_1 != 32'd4) || (pc_2 != 32'd4));

        end

    end

endmodule