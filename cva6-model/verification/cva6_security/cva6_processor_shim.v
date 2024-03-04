

module cva6_processor_shim (
    input wire clk_i,
    input wire rst_ni,
    input wire [31:0] instr_i,
    input wire instr_valid_i,
    output wire instr_ready_o,
    input wire store_mem_resp_i,
    input wire load_mem_resp_i
`ifdef EXPOSE_STATE    
    , output wire [32*32-1:0] regfile_o
    , output wire [32*32-1:0] mem_o
`endif
);


    reg [31:0] regfile [31:0];
    reg [31:0] mem [31:0];

    reg [31:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17, reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26, reg_27, reg_28, reg_29, reg_30, reg_31;

    reg [31:0] mem_0, mem_1, mem_2, mem_3, mem_4, mem_5, mem_6, mem_7, mem_8, mem_9, mem_10, mem_11, mem_12, mem_13, mem_14, mem_15, mem_16, mem_17, mem_18, mem_19, mem_20, mem_21, mem_22, mem_23, mem_24, mem_25, mem_26, mem_27, mem_28, mem_29, mem_30, mem_31;
    
    assign regfile_o = {regfile[0], regfile[1], regfile[2], regfile[3], regfile[4], regfile[5], regfile[6], regfile[7], regfile[8], regfile[9], regfile[10], regfile[11], regfile[12], regfile[13], regfile[14], regfile[15], regfile[16], regfile[17], regfile[18], regfile[19], regfile[20], regfile[21], regfile[22], regfile[23], regfile[24], regfile[25], regfile[26], regfile[27], regfile[28], regfile[29], regfile[30], regfile[31]};
    assign mem_o = {mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7], mem[8], mem[9], mem[10], mem[11], mem[12], mem[13], mem[14], mem[15], mem[16], mem[17], mem[18], mem[19], mem[20], mem[21], mem[22], mem[23], mem[24], mem[25], mem[26], mem[27], mem[28], mem[29], mem[30], mem[31]};

    // assign reg_0 = regfile[0];
    // assign reg_1 = regfile[1];
    // assign reg_2 = regfile[2];
    // assign reg_3 = regfile[3];
    // assign reg_4 = regfile[4];
    // assign reg_5 = regfile[5];
    // assign reg_6 = regfile[6];
    // assign reg_7 = regfile[7];
    // assign reg_8 = regfile[8];
    // assign reg_9 = regfile[9];
    // assign reg_10 = regfile[10];
    // assign reg_11 = regfile[11];
    // assign reg_12 = regfile[12];
    // assign reg_13 = regfile[13];
    // assign reg_14 = regfile[14];
    // assign reg_15 = regfile[15];
    // assign reg_16 = regfile[16];
    // assign reg_17 = regfile[17];
    // assign reg_18 = regfile[18];
    // assign reg_19 = regfile[19];
    // assign reg_20 = regfile[20];
    // assign reg_21 = regfile[21];
    // assign reg_22 = regfile[22];
    // assign reg_23 = regfile[23];
    // assign reg_24 = regfile[24];
    // assign reg_25 = regfile[25];
    // assign reg_26 = regfile[26];
    // assign reg_27 = regfile[27];
    // assign reg_28 = regfile[28];
    // assign reg_29 = regfile[29];
    // assign reg_30 = regfile[30];
    // assign reg_31 = regfile[31];

    reg ready_o;
    assign instr_ready_o = ready_o;

    function is_store;
        input [31:0] instr;
        is_store = (instr[6:0] == 7'b0100011);
    endfunction
    function is_load;
        input [31:0] instr;
        is_load = (instr[6:0] == 7'b0000011);
    endfunction
    function is_alui;
        input [31:0] instr;
        is_alui = (instr[6:0] == 7'b0010011);
    endfunction
    function [31:0] get_s_imm;
		input [31:0] inst;
		begin
			get_s_imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
		end
	endfunction
    function [31:0] get_i_imm;
		input [31:0] inst;
		begin
			get_i_imm = {{20{inst[31]}}, inst[31:20]};
		end
	endfunction
    function [31:0] sra (input [63:0] d, input [4:0] shamt);
        begin
            sra = (d >> shamt);
        end
    endfunction
    function [31:0] alu_compute_i (input [31:0] reg_data, input [31:0] imm_data, input [2:0] alu_fun);
        begin
            alu_compute_i = 
                alu_fun == 0 ? imm_data + reg_data : (
                alu_fun == 1 ? reg_data >> imm_data[4:0] : (
                alu_fun == 5 ? 
                    (imm_data[11:5] == 0 ? 
                        reg_data << imm_data[4:0] : sra({{32{reg_data[31]}}, reg_data}, imm_data[4:0]))
                : (
                alu_fun == 7 ? (imm_data & reg_data) : (
                alu_fun == 6 ? (imm_data | reg_data) : (
                alu_fun == 4 ? (imm_data ^ reg_data) : (
                alu_fun == 3 ? (($signed(reg_data) < $signed(imm_data)) ? 1 : 0) : (
                alu_fun == 2 ? ((reg_data < imm_data) ? 1 : 0) : (0)
            )))))));
        end
    endfunction


    wire [31:0] de_io_instr_i;
    reg [31:0] tb_io_instr_i;
    assign de_io_instr_i = tb_io_instr_i;    
    wire de_io_is_load_i;
    reg tb_io_is_load_i;
    assign de_io_is_load_i = tb_io_is_load_i;
    wire de_io_instr_valid_i;
    reg tb_io_instr_valid_i;
    assign de_io_instr_valid_i = tb_io_instr_valid_i;    
    wire de_io_store_mem_resp_i;
    reg tb_io_store_mem_resp_i;
    assign de_io_store_mem_resp_i = tb_io_store_mem_resp_i;    
    wire de_io_load_mem_resp_i;
    reg tb_io_load_mem_resp_i;
    assign de_io_load_mem_resp_i = tb_io_load_mem_resp_i;

    wire de_io_ready_o;

    wire de_io_store_commit_i;
    reg tb_io_store_commit_i;
    assign de_io_store_commit_i = tb_io_store_commit_i;
    wire de_io_load_req_o;

`ifdef USE_SHIM
    cva6_lsu_shim lsu_shim_i (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .instr_i(de_io_instr_i),
        .is_load_i(de_io_is_load_i),
        .store_commit_i(de_io_store_commit_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .load_mem_resp_i(de_io_load_mem_resp_i),
        .load_req_o(de_io_load_req_o),
        .ready_o(de_io_ready_o)
    );
`elsif USE_MODEL
    cva6_lsu_model lsu_model_i (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .instr_i(de_io_instr_i),
        .is_load_i(de_io_is_load_i),
        .store_commit_i(de_io_store_commit_i),
        .instr_valid_i(de_io_instr_valid_i),
        .store_mem_resp_i(de_io_store_mem_resp_i),
        .load_mem_resp_i(de_io_load_mem_resp_i),
        .load_req_o(de_io_load_req_o),
        .ready_o(de_io_ready_o)
    );
`endif



    reg loadstore_state;
    reg [31:0] loadstore_addr;
    reg [2:0] loadstore_fsm;

    reg load_count;
    reg store_cooldown;
    reg [2:0] store_count;
    reg [2:0] load_cooldown;

    reg store_uncommitted;
    

    integer i;
    

`ifdef RANDOMIZE


    initial begin
        
        for (i = 0; i < 32; i++) begin
            regfile[i] = $random;
            mem[i] = $random;
        end
    end
`endif

    always @(posedge clk_i) begin
        
        if (!rst_ni) begin   
`ifndef RANDOMIZE
    // `ifdef ZERO
            // for (i = 0; i < 32; i++) begin
            //     regfile[i] <= 32'b0;
            //     mem[i] <= 32'b0;
            // end
    // `endif
`endif

            ready_o = 1'b1;

            loadstore_state <= 1'b0;
            loadstore_addr <= 32'b0;
            loadstore_fsm <= 3'd0;
            load_count <= 0;
            load_cooldown <= 0;
            store_count <= 0;
            store_cooldown <= 0;

            tb_io_instr_i <= 0;
            tb_io_is_load_i <= 0;
            tb_io_instr_valid_i <= 0;
            tb_io_store_mem_resp_i <= 0;
            tb_io_load_mem_resp_i <= 0;
            tb_io_store_commit_i <= 0;

            store_uncommitted <= 0;

        end else begin
            
            if (instr_valid_i) begin
                if (is_store(instr_i)) begin
                    loadstore_addr = get_s_imm(instr_i) + regfile[instr_i[19:15]];
                    mem[loadstore_addr[6:2]] = regfile[instr_i[19:15]];
                    loadstore_state = 1'b0;
                    loadstore_fsm = 3'd4;
                    ready_o = 1'b0;
                end else if (is_load(instr_i)) begin
                    loadstore_addr = get_i_imm(instr_i) + regfile[instr_i[19:15]];
                    regfile[instr_i[11:7]] = mem[loadstore_addr[6:2]];
                    loadstore_state = 1'b1;
                    loadstore_fsm = 3'd4;
                    ready_o = 1'b0;
                end else if (is_alui(instr_i)) begin
                    regfile[instr_i[11:7]] = alu_compute_i(regfile[instr_i[19:15]], get_i_imm(instr_i), instr_i[14:12]);
                    ready_o = 1'b1;
                end
            end else if (!ready_o) begin
                if (loadstore_fsm == 3'd4) begin
                    if (loadstore_state) begin
                        tb_io_instr_i = loadstore_addr;
                        tb_io_is_load_i = 1'b1;
                        tb_io_instr_valid_i = 1'b1;
                        load_count = load_count + 1;
                    end else begin
                        tb_io_instr_i = loadstore_addr;
                        tb_io_is_load_i = 1'b0;
                        store_uncommitted = 1;
                        tb_io_instr_valid_i = 1'b1;
                        store_count = store_count + 1;
                    end
                    loadstore_fsm = 3'd3;
                end else if (loadstore_fsm == 3'd3) begin
                    tb_io_instr_valid_i = 1'b0;
                    loadstore_fsm = 0;
                    loadstore_fsm = 3'd2;
                end else if (loadstore_fsm == 3'd2) begin
                    loadstore_fsm = 3'd1;
                end else if (loadstore_fsm == 3'd1) begin
                    if (store_uncommitted && !loadstore_state) begin
                        tb_io_store_commit_i = 1;
                        store_uncommitted = 0;
                    end
                    loadstore_fsm = 3'd0;
                end else if (loadstore_fsm == 0) begin
                    tb_io_store_commit_i = 0;
                    if (de_io_ready_o) begin
                        ready_o = 1;
                    end
                end
            end

            if (loadstore_fsm == 0) begin
                if (
                    // load_cooldown != 0 || 
                store_cooldown != 0) begin
                    // if (load_cooldown != 0) begin
                    //     load_cooldown = load_cooldown - 1;
                    //     // tb_io_load_mem_resp_i = 1'b0;
                    // end
                    // if (store_cooldown != 0) begin
                        store_cooldown = store_cooldown - 1;
                        tb_io_store_mem_resp_i = 1'b0;
                    // end
                // end else if (load_count && load_mem_resp_i && (load_cooldown == 0)) begin
                //     tb_io_load_mem_resp_i = 1'b1;
                //     load_cooldown = 1;
                //     load_count = 0;
                end else if ((store_count != 0) && store_mem_resp_i) begin
                    tb_io_store_mem_resp_i = 1'b1;
                    store_cooldown = 1;
                    store_count = store_count - 1;
                end
            end else if (
                // load_cooldown != 0 || 
            store_cooldown != 0) begin
                // if (load_cooldown != 0) begin
                //     load_cooldown = load_cooldown - 1;
                //     tb_io_load_mem_resp_i = 1'b0;
                // end
                // if (store_cooldown != 0) begin
                    store_cooldown = store_cooldown - 1;
                    tb_io_store_mem_resp_i = 1'b0;
                // end
            end 

            if (de_io_load_req_o && load_mem_resp_i && load_cooldown == 0) begin
                tb_io_load_mem_resp_i = 1'b1;
                load_cooldown = 3;
            end else begin
                if (load_cooldown != 0) begin
                    load_cooldown = load_cooldown - 1;
                end
                tb_io_load_mem_resp_i = 1'b0;
            end


        end

        reg_0 = regfile[0];
        reg_1 = regfile[1];
        reg_2 = regfile[2];
        reg_3 = regfile[3];
        reg_4 = regfile[4];
        reg_5 = regfile[5];
        reg_6 = regfile[6];
        reg_7 = regfile[7];
        reg_8 = regfile[8];
        reg_9 = regfile[9];
        reg_10 = regfile[10];
        reg_11 = regfile[11];
        reg_12 = regfile[12];
        reg_13 = regfile[13];
        reg_14 = regfile[14];
        reg_15 = regfile[15];
        reg_16 = regfile[16];
        reg_17 = regfile[17];
        reg_18 = regfile[18];
        reg_19 = regfile[19];
        reg_20 = regfile[20];
        reg_21 = regfile[21];
        reg_22 = regfile[22];
        reg_23 = regfile[23];
        reg_24 = regfile[24];
        reg_25 = regfile[25];
        reg_26 = regfile[26];
        reg_27 = regfile[27];
        reg_28 = regfile[28];
        reg_29 = regfile[29];
        reg_30 = regfile[30];
        reg_31 = regfile[31];

        mem_0 = mem[0];
        mem_1 = mem[1];
        mem_2 = mem[2];
        mem_3 = mem[3];
        mem_4 = mem[4];
        mem_5 = mem[5];
        mem_6 = mem[6];
        mem_7 = mem[7];
        mem_8 = mem[8];
        mem_9 = mem[9];
        mem_10 = mem[10];
        mem_11 = mem[11];
        mem_12 = mem[12];
        mem_13 = mem[13];
        mem_14 = mem[14];
        mem_15 = mem[15];
        mem_16 = mem[16];
        mem_17 = mem[17];
        mem_18 = mem[18];
        mem_19 = mem[19];
        mem_20 = mem[20];
        mem_21 = mem[21];
        mem_22 = mem[22];
        mem_23 = mem[23];
        mem_24 = mem[24];
        mem_25 = mem[25];
        mem_26 = mem[26];
        mem_27 = mem[27];
        mem_28 = mem[28];
        mem_29 = mem[29];
        mem_30 = mem[30];
        mem_31 = mem[31];

    end
    
endmodule