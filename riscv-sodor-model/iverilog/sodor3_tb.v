// sodor3_tb.v

module sodor3_tb();
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
        $dumpfile("sodor3_wave_pipeline.vcd");
        $dumpvars(0, sodor3_tb);
    end

    
    initial begin
        #IMEM_INTERVAL;
        #SIM_TIME;
        $finish;
    end

    // DMEM output bus
    wire [31:0] fe_ou_io_dmem_req_bits_addr;
    wire [31:0] fe_ou_io_dmem_req_bits_data;
    wire fe_ou_io_dmem_req_bits_fcn;
    wire [2:0] fe_ou_io_dmem_req_bits_typ;
    wire fe_ou_io_dmem_req_valid;
    // DMEM input bus
    wire [31:0] fe_in_io_dmem_resp_bits_data;
    wire fe_in_io_dmem_resp_valid;
    wire fe_in_io_dmem_req_ready;
    wire fe_in_io_hartid;
    // IMEM output bus
    wire [31:0] fe_ou_io_imem_req_bits_addr;
    wire fe_ou_io_imem_req_valid;
    // IMEM input bus
    wire [31:0] fe_in_io_imem_resp_bits_data;
    wire fe_in_io_imem_resp_valid;
    wire fe_in_io_imem_req_ready;
    // Interrupts
    wire fe_in_io_interrupt_debug;
    wire fe_in_io_interrupt_meip;
    wire fe_in_io_interrupt_msip;
    wire fe_in_io_interrupt_mtip;
    // reset vector
    wire [31:0] fe_in_io_reset_vector;


    // Hardcode almost all inputs (all other than instruction input)
    // assign fe_in_io_dmem_resp_bits_data = 0;
    // assign fe_in_io_dmem_resp_valid = 0;
    assign fe_in_io_hartid = 0;
    assign fe_in_io_interrupt_debug = 0;
    assign fe_in_io_interrupt_meip = 0;
    assign fe_in_io_interrupt_msip = 0;
    assign fe_in_io_interrupt_mtip = 0;
    assign fe_in_io_reset_vector = 0;

    assign fe_in_io_imem_req_ready = 1;
    // assign fe_in_io_dmem_req_ready = 1;

    assign fe_in_io_imem_resp_bits_data = 
    // (CLK_CYCLE > 2) ? 
        (CLK_CYCLE[0]) ? 32'h00200313 : 32'h04002283;
    assign fe_in_io_imem_resp_valid = 1;
        // (CLK_CYCLE > 2) ? 1 : 0;

    // always @(posedge clk) begin
    //     if (CLK_CYCLE > 4) 

    // end

    // SimpleDMEM dmem (
    //     .clock(clk), 
    //     .reset(reset), 
    //     .dmem_in_io_dmem_req_bits_addr(fe_ou_io_dmem_req_bits_addr),
    //     .dmem_in_io_dmem_req_bits_data(fe_ou_io_dmem_req_bits_data),
    //     .dmem_in_io_dmem_req_bits_fcn(fe_ou_io_dmem_req_bits_fcn),
    //     .dmem_in_io_dmem_req_bits_typ(fe_ou_io_dmem_req_bits_typ),
    //     .dmem_in_io_dmem_req_valid(fe_ou_io_dmem_req_valid),
    //     .dmem_ou_io_dmem_resp_bits_data(fe_in_io_dmem_resp_bits_data),
    //     .dmem_ou_io_dmem_resp_valid(fe_in_io_dmem_resp_valid),
    //     .dmem_ou_io_dmem_req_ready(fe_in_io_dmem_req_ready)
    // );

    Core core (
        .clock(clk),
        .reset(reset),
        .io_dmem_req_bits_addr(fe_ou_io_dmem_req_bits_addr),
        .io_dmem_req_bits_data(fe_ou_io_dmem_req_bits_data),
        .io_dmem_req_bits_fcn(fe_ou_io_dmem_req_bits_fcn),
        .io_dmem_req_bits_typ(fe_ou_io_dmem_req_bits_typ),
            // Only in Stage3
            .io_dmem_req_ready(fe_in_io_dmem_req_ready),
        .io_dmem_req_valid(fe_ou_io_dmem_req_valid),
        .io_dmem_resp_bits_data(fe_in_io_dmem_resp_bits_data),
        .io_dmem_resp_valid(fe_in_io_dmem_resp_valid),
        .io_hartid(fe_in_io_hartid),
            // Only in Stage3
            .io_imem_req_ready(fe_in_io_imem_req_ready),
        .io_imem_req_bits_addr(fe_ou_io_imem_req_bits_addr),
        .io_imem_req_valid(fe_ou_io_imem_req_valid),
        .io_imem_resp_bits_data(fe_in_io_imem_resp_bits_data),
        .io_imem_resp_valid(fe_in_io_imem_resp_valid),
        .io_interrupt_debug(fe_in_io_interrupt_debug),
        .io_interrupt_meip(fe_in_io_interrupt_meip),
        .io_interrupt_msip(fe_in_io_interrupt_msip),
        .io_interrupt_mtip(fe_in_io_interrupt_mtip),
        .io_reset_vector(fe_in_io_reset_vector)
    );
endmodule


