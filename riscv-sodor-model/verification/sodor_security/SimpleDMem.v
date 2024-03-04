`define MEM_ADDR_BITS 6
`define MEM_WORD_ADDR_BITS (`MEM_ADDR_BITS-2)
`define MEM_SIZE 2**`MEM_WORD_ADDR_BITS

`define DELAY_CYCLES 0

module SimpleDMEM(
    clock, reset, 
    dmem_in_io_dmem_req_bits_addr,
    dmem_in_io_dmem_req_bits_data,
    dmem_in_io_dmem_req_bits_fcn,
    dmem_in_io_dmem_req_bits_typ,
    dmem_in_io_dmem_req_valid,
    dmem_ou_io_dmem_resp_bits_data,
    dmem_ou_io_dmem_resp_valid,
    dmem_ou_io_dmem_req_ready
);

    input clock;
    input reset;
    // DMEM input (to DMEM) bus
    input [31:0] dmem_in_io_dmem_req_bits_addr;
    input [31:0] dmem_in_io_dmem_req_bits_data;
    input dmem_in_io_dmem_req_bits_fcn;
    input [2:0] dmem_in_io_dmem_req_bits_typ;
    input dmem_in_io_dmem_req_valid;
    // DMEM output (from DMEM) bus
    output [31:0] dmem_ou_io_dmem_resp_bits_data;
    output dmem_ou_io_dmem_resp_valid;
    output dmem_ou_io_dmem_req_ready;

    // Internal regs
    reg [31:0] dmem_resp_bits_data;
    reg dmem_resp_valid;
    // reg dmem_req_ready;
    
    wire [`MEM_WORD_ADDR_BITS-1:0] dmem_in_io_dmem_req_bits_addr_base;
    wire [1:0] dmem_in_io_dmem_req_bits_addr_offset;
    wire [31:0] mem_data;

    assign dmem_ou_io_dmem_resp_bits_data = dmem_resp_bits_data;
    assign dmem_ou_io_dmem_resp_valid = dmem_resp_valid;
    `ifdef SODOR5_SIGNALS
        assign dmem_ou_io_dmem_req_ready = !(dmem_resp_valid ^ dmem_in_io_dmem_req_valid);
    `endif
    `ifdef SODOR3_SIGNALS
        assign dmem_ou_io_dmem_req_ready = 1;
    `endif
    // dmem_req_ready;
    
    assign dmem_in_io_dmem_req_bits_addr_base = dmem_in_io_dmem_req_bits_addr[`MEM_ADDR_BITS-1:2];
    assign dmem_in_io_dmem_req_bits_addr_offset = dmem_in_io_dmem_req_bits_addr[1:0];
    assign mem_data = mem[dmem_in_io_dmem_req_bits_addr_base];

    reg [31:0] mem [0:`MEM_SIZE-1];

    initial begin
        dmem_resp_bits_data = 0;
        dmem_resp_valid = 0;
        // dmem_req_ready = 1;
    end

    reg [3:0] cycle_counter;

    always @(posedge clock) begin
        if (reset) begin
            dmem_resp_bits_data <= 0;
            dmem_resp_valid <= 0;
            // dmem_req_ready <= 1;
            cycle_counter <= 0;
        end else begin
`ifdef SODOR5_SIGNALS
        if (dmem_in_io_dmem_req_valid && !dmem_resp_valid) begin
`endif 
`ifdef SODOR3_SIGNALS
        if (dmem_in_io_dmem_req_valid) begin
`endif
            if (cycle_counter == `DELAY_CYCLES) begin
                // Is a write
                if (dmem_in_io_dmem_req_bits_fcn) begin
                    dmem_resp_bits_data <= 0;
                    if (dmem_in_io_dmem_req_bits_typ == 1) begin
                        if (dmem_in_io_dmem_req_bits_addr_offset == 3) begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                dmem_in_io_dmem_req_bits_data[7:0], mem_data[23:0]
                            };
                        end else if (dmem_in_io_dmem_req_bits_addr_offset == 2) begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                mem_data[31:24], dmem_in_io_dmem_req_bits_data[7:0], mem_data[15:0]
                            };
                        end else if (dmem_in_io_dmem_req_bits_addr_offset == 1) begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                mem_data[31:16], dmem_in_io_dmem_req_bits_data[7:0], mem_data[7:0]
                            };
                        end else begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                mem_data[31:8], dmem_in_io_dmem_req_bits_data[7:0]
                            };
                        end
                    end else if (dmem_in_io_dmem_req_bits_typ == 2) begin
                        if (dmem_in_io_dmem_req_bits_addr_offset[1] == 1) begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                dmem_in_io_dmem_req_bits_data[15:0], mem_data[15:0]
                            };
                        end else begin
                            mem[dmem_in_io_dmem_req_bits_addr_base] <= {
                                mem_data[31:16], dmem_in_io_dmem_req_bits_data[15:0]
                            };
                        end
                    end else if (dmem_in_io_dmem_req_bits_typ == 3) begin
                        mem[dmem_in_io_dmem_req_bits_addr_base] <= dmem_in_io_dmem_req_bits_data[31:0];
                    end
                end
                // Is a read
                else begin
                    
                    if (dmem_in_io_dmem_req_bits_typ == 1) begin
                        if (dmem_in_io_dmem_req_bits_addr_offset == 3) begin
                            dmem_resp_bits_data <= {24'h0, mem_data[31:24]};
                        end else if (dmem_in_io_dmem_req_bits_addr_offset == 2) begin
                            dmem_resp_bits_data <= {24'h0, mem_data[23:16]};
                        end else if (dmem_in_io_dmem_req_bits_addr_offset == 1) begin
                            dmem_resp_bits_data <= {24'h0, mem_data[15:8]};
                        end else begin
                            dmem_resp_bits_data <= {24'h0, mem_data[7:0]};
                        end
                    end else if (dmem_in_io_dmem_req_bits_typ == 2) begin
                        if (dmem_in_io_dmem_req_bits_addr_offset[1] == 1) begin
                            dmem_resp_bits_data <= {16'h0, mem_data[31:16]};
                        end else begin
                            dmem_resp_bits_data <= {16'h0, mem_data[15:0]};
                        end
                    end else if (dmem_in_io_dmem_req_bits_typ == 3) begin
                        dmem_resp_bits_data <= mem_data;
                    end
                end
                dmem_resp_valid <= 1; 
                // dmem_req_ready <= 1;
                cycle_counter <= 0;
            end else begin
                dmem_resp_valid <= 0; 
                // dmem_req_ready <= 0;
                cycle_counter <= dmem_resp_valid ? 0 : cycle_counter + 1;
            end
        end else begin
            dmem_resp_valid <= 0; 
            // dmem_req_ready <= 1;
            cycle_counter <= 0;
        end
        end
    end

endmodule
