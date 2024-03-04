
`define INSTR_QUEUE_DEPTH 4
`define INSTR_QUEUE_DEPTH_WIDTH 2
`define SBUF_DEPTH 1
`define SBUFFER_ENTRY 32

`define LBUF_DEPTH 1
`define LBUFFER_ENTRY 32

`define INSTR_PC_WIDTH 8

module cva6_su_model (
    input wire clk_i,
    input wire rst_ni,
    input wire [31:0] instr_i,
    input wire instr_valid_i,
    input wire store_mem_resp_i,
    input wire commit_i
`ifdef EXPOSE_STATE
    , input wire [11:0] page_offset_i
    , output wire page_offset_matches_o
    , output wire ready_o
    , output wire [2*`INSTR_QUEUE_DEPTH-1:0] port_store_instr_queue_state
`endif
);


    reg [31:0] 			CLK_CYCLE;

    // // Store buffer: {valid, address}
    // reg [`SBUFFER_ENTRY-1:0] sbuffer_q [0:`SBUF_DEPTH-1];
    // // Load queue: {valid, address}
    // reg [`LBUFFER_ENTRY-1:0] lbuffer_q [0:`LBUF_DEPTH-1];

    reg [`INSTR_PC_WIDTH-1:0] instr_i_pc;

    // Instruction (input) queue
    reg [31:0] store_instr_i_queue [0:`INSTR_QUEUE_DEPTH-1];
    reg [`INSTR_PC_WIDTH-1:0] store_instr_i_queue_pc [0:`INSTR_QUEUE_DEPTH-1];
    reg [1:0] store_instr_queue_state [0:`INSTR_QUEUE_DEPTH-1];
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_store_ptr;
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_commit_ptr;
    reg [`INSTR_QUEUE_DEPTH_WIDTH-1:0] queue_serve_ptr;

    assign port_store_instr_queue_state = {store_instr_queue_state[3], store_instr_queue_state[2], store_instr_queue_state[1], store_instr_queue_state[0]};
    
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

    // reg de_page_offset_matches_o;
    assign page_offset_matches_o = (inner_instr_i[11:3] == page_offset_i[11:3] && inner_instr_valid_i) ||
        (store_instr_i_queue[0][11:3] == page_offset_i[11:3] && store_instr_queue_state[0] != 0) ||
        (store_instr_i_queue[1][11:3] == page_offset_i[11:3] && store_instr_queue_state[1] != 0) ||
        (store_instr_i_queue[2][11:3] == page_offset_i[11:3] && store_instr_queue_state[2] != 0) ||
        (store_instr_i_queue[3][11:3] == page_offset_i[11:3] && store_instr_queue_state[3] != 0);
    assign ready_o = (store_instr_queue_state[queue_store_ptr] == 0);
    // reg load_flag;
    // reg ready_flag;
    // assign ready_o = ready_flag;

    // Inner signals
    reg [31:0] inner_instr_i;
    reg inner_instr_valid_i;
    reg inner_store_mem_resp_i;


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
            queue_serve_ptr <= 0;
            queue_commit_ptr <= 0;
            instr_i_pc <= 0;

            inner_instr_valid_i <= 0;
            inner_instr_i <= 0;
            inner_store_mem_resp_i <= 0;
            
		end else begin
            CLK_CYCLE <= CLK_CYCLE + 1;
        
            if (inner_instr_valid_i) begin
                if (store_instr_queue_state[queue_store_ptr] != 0) begin
`ifndef FORMAL
                    $display("Store blocked!");
`endif 
                end else begin
                    store_instr_i_queue[queue_store_ptr] <= inner_instr_i;
                    store_instr_i_queue_pc[queue_store_ptr] <= instr_i_pc;
                    store_instr_queue_state[queue_store_ptr] <= 3;
                    queue_store_ptr <= queue_store_ptr + 1;
                    instr_i_pc = instr_i_pc + 1;
                end
            end

            // Using the context
            if (store_mem_resp_i) begin
                if (store_instr_queue_state[queue_serve_ptr] == 0) begin
`ifndef FORMAL
                    $display("Store not found! %d", CLK_CYCLE);
`endif 
                end else if (store_instr_queue_state[queue_serve_ptr] == 3) begin
`ifndef FORMAL
                    $display("Store uncommitted! %d", CLK_CYCLE);
`endif
                end else begin
                    store_instr_queue_state[queue_serve_ptr] <= 0;
                    queue_serve_ptr <= queue_serve_ptr + 1;
                end
            end 

            if (commit_i) begin
                if (store_instr_queue_state[queue_commit_ptr] == 0) begin
`ifndef FORMAL
                    $display("Store not found! %d", CLK_CYCLE);
`endif 
                end else if (store_instr_queue_state[queue_commit_ptr] == 1) begin
`ifndef FORMAL
                    $display("Store already committed! %d", CLK_CYCLE);
`endif 
                end else begin
                    store_instr_queue_state[queue_commit_ptr] <= 1;
                    queue_commit_ptr <= queue_commit_ptr + 1;
                end
            end

            inner_instr_valid_i <= instr_valid_i;
            inner_instr_i <= instr_i;
            inner_store_mem_resp_i <= store_mem_resp_i;

        end

`ifndef FORMAL
        store_instr_i_queue_flatten_0 = store_instr_i_queue[0];
        store_instr_i_queue_flatten_1 = store_instr_i_queue[1];    
        store_instr_i_queue_flatten_2 = store_instr_i_queue[2];
        store_instr_i_queue_flatten_3 = store_instr_i_queue[3];
        store_instr_i_queue_flatten_0_pc = store_instr_i_queue_pc[0];
        store_instr_i_queue_flatten_1_pc = store_instr_i_queue_pc[1];
        store_instr_i_queue_flatten_2_pc = store_instr_i_queue_pc[2];
        store_instr_i_queue_flatten_3_pc = store_instr_i_queue_pc[3];
        store_instr_queue_state_flatten_0 = store_instr_queue_state[0];
        store_instr_queue_state_flatten_1 = store_instr_queue_state[1];
        store_instr_queue_state_flatten_2 = store_instr_queue_state[2];
        store_instr_queue_state_flatten_3 = store_instr_queue_state[3];
`endif

	end
    
endmodule