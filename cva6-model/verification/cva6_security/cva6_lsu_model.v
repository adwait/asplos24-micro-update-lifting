
`define INSTR_QUEUE_DEPTH 4
`define INSTR_QUEUE_DEPTH_WIDTH 2
`define SBUF_DEPTH 1
`define SBUFFER_ENTRY 32

`define LBUF_DEPTH 1
`define LBUFFER_ENTRY 32

`define INSTR_PC_WIDTH 8

module cva6_lsu_model (
    input wire clk_i,
    input wire rst_ni,
    input wire [31:0] instr_i,
    input wire is_load_i,
    input wire store_commit_i,
    input wire instr_valid_i,
    input wire store_mem_resp_i,
    input wire load_mem_resp_i,
    output wire load_req_o,
    output wire ready_o
`ifdef EXPOSE_STATE
    , output wire [2*`INSTR_QUEUE_DEPTH-1:0] port_store_instr_queue_state
    , output wire [1:0] port_load_instr_queue_state
`endif
);


    reg [31:0] 			CLK_CYCLE;

    reg [`INSTR_PC_WIDTH-1:0] instr_i_pc;

    // Instruction (input) queue
    reg [31:0] store_instr_i_queue [0:`INSTR_QUEUE_DEPTH-1];
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_pc [0:`INSTR_QUEUE_DEPTH-1];
    reg [1:0] store_instr_queue_state [0:`INSTR_QUEUE_DEPTH-1];
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_store_ptr;
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_commit_ptr;
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_serve_ptr;

    reg [31:0] load_instr_i_queue;
    reg [`INSTR_PC_WIDTH-1:0] load_instr_i_queue_pc;
    reg [1:0] load_instr_queue_state;
    
    assign port_store_instr_queue_state = {store_instr_queue_state[3], store_instr_queue_state[2], store_instr_queue_state[1], store_instr_queue_state[0]};
    assign port_load_instr_queue_state = load_instr_queue_state;

    // Instruction queue flattening
    reg [31:0] store_instr_i_queue_flatten_0;
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_flatten_0_pc;
    reg [31:0] store_instr_i_queue_flatten_1;
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_flatten_1_pc;
    reg [31:0] store_instr_i_queue_flatten_2;
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_flatten_2_pc;
    reg [31:0] store_instr_i_queue_flatten_3;
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_flatten_3_pc;

    reg [1:0] store_instr_queue_state_flatten_0;
    reg [1:0] store_instr_queue_state_flatten_1;
    reg [1:0] store_instr_queue_state_flatten_2;
    reg [1:0] store_instr_queue_state_flatten_3;

    reg ready_flag;
    assign ready_o = ready_flag;

    wire no_dep;
    assign no_dep = ((store_instr_i_queue[queue_serve_ptr][11:3] != load_instr_i_queue[11:3]) 
                || (store_instr_i_queue_pc[queue_serve_ptr] >= load_instr_i_queue_pc) 
                || store_instr_queue_state[queue_serve_ptr][0] == 0);

    assign load_req_o = load_instr_queue_state == 2'b01;

    // Inner signals
    reg [31:0] inner_instr_i;
    reg [31:0] x_inner_instr_i;
    reg inner_instr_valid_i;
    reg x_inner_instr_valid_i;
    reg inner_is_load_i;
    reg x_inner_is_load_i;
    reg inner_store_mem_resp_i;
    reg x_inner_store_mem_resp_i;
    reg inner_load_mem_resp_i;

	always @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin

            CLK_CYCLE <= 0;
            
            store_instr_i_queue[0] <= 0;
            store_instr_i_queue[1] <= 0;
            store_instr_i_queue[2] <= 0;
            store_instr_i_queue[3] <= 0;
            store_instr_i_queue_pc[0] <= 0;
            store_instr_i_queue_pc[1] <= 0;
            store_instr_i_queue_pc[2] <= 0;
            store_instr_i_queue_pc[3] <= 0;
            store_instr_queue_state[0] <= 0;
            store_instr_queue_state[1] <= 0;
            store_instr_queue_state[2] <= 0;
            store_instr_queue_state[3] <= 0;

            load_instr_i_queue <= 0;
            load_instr_i_queue_pc <= 0;
            load_instr_queue_state <= 0;

            store_instr_i_queue_flatten_0 <= 0;
            store_instr_i_queue_flatten_1 <= 0;
            store_instr_i_queue_flatten_2 <= 0;
            store_instr_i_queue_flatten_3 <= 0;
            store_instr_i_queue_flatten_0_pc <= 0;
            store_instr_i_queue_flatten_1_pc <= 0;
            store_instr_i_queue_flatten_2_pc <= 0;
            store_instr_i_queue_flatten_3_pc <= 0;
            store_instr_queue_state_flatten_0 <= 0;
            store_instr_queue_state_flatten_1 <= 0;
            store_instr_queue_state_flatten_2 <= 0;
            store_instr_queue_state_flatten_3 <= 0;

            queue_store_ptr <= 0;
            queue_commit_ptr <= 0;
            queue_serve_ptr <= 0;

            instr_i_pc <= 0;
            ready_flag <= 1;

            inner_instr_i <= 0;
            x_inner_instr_i <= 0;
            inner_instr_valid_i <= 0;
            x_inner_instr_valid_i <= 0;
            inner_is_load_i <= 0;
            x_inner_is_load_i <= 0;
            inner_store_mem_resp_i <= 0;
            x_inner_store_mem_resp_i <= 0;
            inner_load_mem_resp_i <= 0;
            
		end else begin
            CLK_CYCLE <= CLK_CYCLE + 1;

            // Building the context        
            if (x_inner_instr_valid_i && !x_inner_is_load_i) begin
                if (store_instr_queue_state[queue_store_ptr] != 0) begin
`ifndef FORMAL
                    $display("Store blocked!");
`endif
                end else begin
                    store_instr_i_queue[queue_store_ptr] <= x_inner_instr_i;
                    store_instr_i_queue_pc[queue_store_ptr] <= instr_i_pc;
                    store_instr_queue_state[queue_store_ptr] <= 3;
                    queue_store_ptr <= queue_store_ptr + 1;
                    instr_i_pc = instr_i_pc + 1;
                end
            end   
            
            if (inner_instr_valid_i && inner_is_load_i) begin
                if (load_instr_queue_state != 0) begin
`ifndef FORMAL
                    $display("Load blocked!");
`endif
                end else begin
                    load_instr_i_queue <= inner_instr_i;
                    load_instr_i_queue_pc <= instr_i_pc;
                    if ((store_instr_i_queue[queue_serve_ptr][11:3] != inner_instr_i[11:3]) 
                        || (store_instr_i_queue_pc[queue_serve_ptr] >= instr_i_pc) 
                        || store_instr_queue_state[queue_serve_ptr][0] == 0) begin
                        load_instr_queue_state <= 1;
                        // queue_load_ptr <= queue_load_ptr + 1;
                        // ready_flag <= 1;
                    end else begin
                        load_instr_queue_state <= 3;
                    end
                    ready_flag <= 0;
                    instr_i_pc = instr_i_pc + 1;
                end
            end else if (inner_load_mem_resp_i) begin
                if (load_instr_queue_state == 0) begin
`ifndef FORMAL
                    $display("Load not found!");
`endif
                end else begin
`ifndef FORMAL
                    $display("Load resp acquired!");
`endif
                        ready_flag <= 1;
                        load_instr_queue_state <= 2;
                end
            end else if (load_instr_queue_state == 2) begin
                load_instr_queue_state <= 0;
                // queue_load_ptr <= queue_load_ptr + 1;
                // ready_flag <= 1;
            end else if (((store_instr_i_queue[queue_serve_ptr][11:3] != load_instr_i_queue[11:3]) 
                || (store_instr_i_queue_pc[queue_serve_ptr] >= load_instr_i_queue_pc) 
                || store_instr_queue_state[queue_serve_ptr][0] == 0)) begin
                if (load_instr_queue_state == 3) begin
                    load_instr_queue_state <= 1;
                end
            end

            // Using the context
            if (inner_store_mem_resp_i) begin
                if (store_instr_queue_state[queue_serve_ptr] != 1) begin
`ifndef FORMAL
                    $display("Store not ready for commit! %d", CLK_CYCLE);
`endif 
                end else begin
                    store_instr_queue_state[queue_serve_ptr] <= 0;
                    queue_serve_ptr <= queue_serve_ptr + 1;
                end
            end

            if (store_commit_i) begin
                if (store_instr_queue_state[queue_commit_ptr] != 3) begin
`ifndef FORMAL
                    $display("Store not uncommited! %d", CLK_CYCLE);
`endif
                end else begin
                    store_instr_queue_state[queue_commit_ptr] <= 1;
                    queue_commit_ptr <= queue_commit_ptr + 1;
                end
            end

            

            

            inner_is_load_i <= is_load_i;
            x_inner_is_load_i <= inner_is_load_i;
            inner_instr_valid_i <= instr_valid_i;
            x_inner_instr_valid_i <= inner_instr_valid_i;
            inner_instr_i <= instr_i;
            x_inner_instr_i <= inner_instr_i;
            inner_store_mem_resp_i <= store_mem_resp_i;
            x_inner_store_mem_resp_i <= inner_store_mem_resp_i;
            inner_load_mem_resp_i <= load_mem_resp_i;

        end

	end
    
endmodule