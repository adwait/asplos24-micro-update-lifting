module simple_csr_regfile (
    input clk_i,                // Clock
    input rst_ni,               // Asynchronous reset active low
    
    input [31:0] csr_wdata_i,
    input [11:0] csr_addr_i,
    input [7:0] csr_op_i,

    // PMPs
    output [127:0] pmpcfg_o,    // PMP configuration containing pmpcfg for max 16 PMPs
    output [511:0] pmpaddr_o    // PMP addresses
);
	parameter [31:0] NrPMPEntries = 8;
    
    reg [127:0] pmpcfg_q, pmpcfg_d;
    reg [511:0] pmpaddr_q, pmpaddr_d;

    assign pmpcfg_o = pmpcfg_q;
    assign pmpaddr_o = pmpaddr_q;

    wire [11:0] csr_addr;
    assign csr_addr = csr_addr_i;

	reg csr_we;
    reg [31:0] csr_wdata;

    always @(*) begin : csr_update
        // Default update
        pmpcfg_d = pmpcfg_q;
        pmpaddr_d = pmpaddr_q;
        if (csr_we) begin
            case (csr_addr[11-:12])
				12'h3a0: begin : sv2v_autoblock_3
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[(i * 8) + 7])
							pmpcfg_d[i * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a1: begin : sv2v_autoblock_4
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 4) * 8) + 7])
							pmpcfg_d[(i + 4) * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a2: begin : sv2v_autoblock_5
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 8) * 8) + 7])
							pmpcfg_d[(i + 8) * 8+:8] = csr_wdata[i * 8+:8];
				end
				12'h3a3: begin : sv2v_autoblock_6
					reg signed [31:0] i;
					for (i = 0; i < 4; i = i + 1)
						if (!pmpcfg_q[((i + 12) * 8) + 7])
							pmpcfg_d[(i + 12) * 8+:8] = csr_wdata[i * 8+:8];
				end
                12'h3b0, 12'h3b1, 12'h3b2, 12'h3b3, 12'h3b4, 12'h3b5, 12'h3b6, 12'h3b7, 12'h3b8, 12'h3b9, 12'h3ba, 12'h3bb, 12'h3bc, 12'h3bd, 12'h3be, 12'h3bf: begin : sv2v_autoblock_7
					reg signed [31:0] index;
					index = csr_addr[3:0];
					if (!pmpcfg_q[(index * 8) + 7] && !(pmpcfg_q[(index * 8) + 7] && (pmpcfg_q[(index * 8) + 4-:2] == 2'b01))) begin
						pmpaddr_d[index * 32+:32] = csr_wdata[31:0];
					end
				end
            endcase
        end
    end

    always @(*) begin : csr_op_logic
		csr_wdata = csr_wdata_i;
		csr_we = 1'b1;
		// csr_read = 1'b1;
		// mret = 1'b0;
		// sret = 1'b0;
		// dret = 1'b0;
		case (csr_op_i)
			8'd31: csr_wdata = csr_wdata_i;
			// 8'd33: csr_wdata = csr_wdata_i | csr_rdata;
			// 8'd34: csr_wdata = ~csr_wdata_i & csr_rdata;
			8'd32: csr_we = 1'b0;
			8'd24: begin
				csr_we = 1'b0;
				// csr_read = 1'b0;
				// sret = 1'b1;
			end
			8'd23: begin
				csr_we = 1'b0;
				// csr_read = 1'b0;
				// mret = 1'b1;
			end
			8'd25: begin
				csr_we = 1'b0;
				// csr_read = 1'b0;
				// dret = 1'b1;
			end
			default: begin
				csr_we = 1'b0;
				// csr_read = 1'b0;
			end
		endcase
		// if (privilege_violation) begin
		// 	csr_we = 1'b0;
		// 	csr_read = 1'b0;
		// end
	end

    always @(posedge clk_i or negedge rst_ni)
        if (~rst_ni) begin
            // PMP
            pmpcfg_q <= 1'sb0;
            pmpaddr_q <= 1'sb0;

        end else begin
            begin : sv2v_autoblock_8
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					if (i < NrPMPEntries) begin
						if ((pmpcfg_d[(i*8) + 4-:2] != 2'b10) && !((pmpcfg_d[i * 8] == 1'b0) && 
                            (pmpcfg_d[(i * 8) + 1] == 1'b1)))
							pmpcfg_q[i*8+:8] <= pmpcfg_d[i * 8+:8];
						else
							pmpcfg_q[i * 8+:8] <= pmpcfg_q[i * 8+:8];
                        pmpaddr_q[i * 32+:32] <= pmpaddr_d[i * 32+:32];
					    end
                    else begin
                        pmpcfg_q[i * 8+:8] <= 1'sb0;
                        pmpaddr_q[i * 32+:32] <= 1'sb0;
                    end
			end
        end

endmodule