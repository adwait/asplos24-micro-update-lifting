
`define SODOR3_SIGNALS
`undef SODOR3_SIGNALS

`define SODOR5_SIGNALS
// `undef SODOR5_SIGNALS

`define SODORU_SIGNALS
`undef SODORU_SIGNALS

`define RF_EXPOSED

module CoreTop (
    input clock,
    input reset,
`ifdef SODOR5_SIGNALS
        output [31:0]   port_imm,
        output [31:0]   port_alu_out,
        output [31:0]   port_exe_alu_op1,
        output [31:0]   port_exe_alu_op2,
        output [4:0]    port_reg_rs1_addr_in,
        output [4:0]    port_reg_rs2_addr_in,
        output [31:0]   port_reg_rs1_data_out,
        output [31:0]   port_reg_rs2_data_out,
        output [31:0]   port_reg_rd_data_in,
        output [4:0]    port_reg_rd_addr_in,
        output [31:0]   port_dec_reg_inst,
        output [31:0]   port_exe_reg_inst,
        output [31:0]   port_mem_reg_inst,
        output [31:0]   port_mem_reg_alu_out,
        output [31:0]   port_if_reg_pc,
        output [31:0]   port_dec_reg_pc,
        output [31:0]   port_exe_reg_pc,
        output [31:0]   port_mem_reg_pc,
        output          port_lb_table_valid,
        output [31:0]   port_lb_table_addr,
        output [31:0]   port_lb_table_data,
        output [4:0]    port_dec_wbaddr,
        output [4:0]    port_exe_reg_wbaddr,
        output [4:0]    port_mem_reg_wbaddr,
        output [31:0]   port_imm_sbtype_sext,
        output [3:0]    port_alu_fun,
        output          port_mem_fcn,
        output [2:0]    port_mem_typ,
`endif
`ifdef SODOR3_SIGNALS
        output [4:0]    port_reg_rs1_addr_in,
        output [4:0]    port_reg_rs2_addr_in,
        output [31:0]   port_reg_rs1_data_out,
        output [31:0]   port_reg_rs2_data_out,
                
        output [31:0]   port_alu_out,
        output [4:0]    port_exe_reg_wbaddr,
        output [31:0]   port_reg_rd_data_in,
        output [4:0]    port_reg_rd_addr_in,
    
        output [31:0]   port_wb_reg_pc,
        output [31:0]   port_wb_reg_inst,

        output [31:0]   port_imm_itype_sext,
        output [31:0]   port_imm_sbtype_sext,
        output [31:0]   port_imm_stype_sext,
        
        output [3:0]    port_alu_fun,
        output          port_mem_fcn,
        output [2:0]    port_mem_typ,
`endif
`ifdef SODORU_SIGNALS
        output [31:0] port_pc,
`endif
`ifdef RF_EXPOSED
        output [1023:0] port_regfile,
`endif
    input [31:0] fe_in_io_imem_resp_bits_data,
    output [31:0] fe_ou_io_imem_req_bits_addr,
    output fe_ou_io_imem_req_valid,
);

`ifdef SODOR5_SIGNALS  
    assign port_mem_fcn = fe_ou_io_dmem_req_bits_fcn;
    assign port_mem_typ = fe_ou_io_dmem_req_bits_typ;
`endif
`ifdef SODOR3_SIGNALS  
    assign port_mem_fcn = fe_ou_io_dmem_req_bits_fcn;
    assign port_mem_typ = fe_ou_io_dmem_req_bits_typ;
`endif

    // DMEM output and input buses
    wire [31:0] fe_ou_io_dmem_req_bits_addr;
    wire [31:0] fe_ou_io_dmem_req_bits_data;
    wire fe_ou_io_dmem_req_bits_fcn;
    wire [2:0] fe_ou_io_dmem_req_bits_typ;
    wire fe_ou_io_dmem_req_valid;
    wire [31:0] fe_in_io_dmem_resp_bits_data;
    wire fe_in_io_dmem_resp_valid;
    wire fe_in_io_dmem_req_ready;
    wire fe_in_io_hartid;
    // IMEM input bus
    wire fe_in_io_imem_resp_valid;
    wire fe_in_io_imem_req_ready;
    // Interrupts
    wire fe_in_io_interrupt_debug;
    wire fe_in_io_interrupt_meip;
    wire fe_in_io_interrupt_msip;
    wire fe_in_io_interrupt_mtip;
    // reset vector
    wire [31:0] fe_in_io_reset_vector;
    // Hardcode some inputs (all other than instruction input)
    assign fe_in_io_hartid = 0;
    assign fe_in_io_interrupt_debug = 0;
    assign fe_in_io_interrupt_meip = 0;
    assign fe_in_io_interrupt_msip = 0;
    assign fe_in_io_interrupt_mtip = 0;
    assign fe_in_io_reset_vector = 0;
    assign fe_in_io_imem_req_ready = 1;
    assign fe_in_io_imem_resp_valid = 1;

    Core core (
        .clock(clock),
        .reset(reset),
        .io_dmem_req_bits_addr(fe_ou_io_dmem_req_bits_addr),
        .io_dmem_req_bits_data(fe_ou_io_dmem_req_bits_data),
        .io_dmem_req_bits_fcn(fe_ou_io_dmem_req_bits_fcn),
        .io_dmem_req_bits_typ(fe_ou_io_dmem_req_bits_typ),
        .io_dmem_req_valid(fe_ou_io_dmem_req_valid),
        .io_dmem_resp_bits_data(fe_in_io_dmem_resp_bits_data),
        .io_dmem_resp_valid(fe_in_io_dmem_resp_valid),
        .io_hartid(fe_in_io_hartid),
        .io_imem_req_bits_addr(fe_ou_io_imem_req_bits_addr),
        .io_imem_req_valid(fe_ou_io_imem_req_valid),
        .io_imem_resp_bits_data(fe_in_io_imem_resp_bits_data),
        .io_imem_resp_valid(fe_in_io_imem_resp_valid),
        .io_interrupt_debug(fe_in_io_interrupt_debug),
        .io_interrupt_meip(fe_in_io_interrupt_meip),
        .io_interrupt_msip(fe_in_io_interrupt_msip),
        .io_interrupt_mtip(fe_in_io_interrupt_mtip),
    `ifdef RF_EXPOSED
        .io_sigIO_lft_tile_regfile(port_regfile),
    `endif
    `ifdef SODOR3_SIGNALS
        // Only in Stage3
        .io_sigIO_lft_tile_regfile_io_rs1_addr(port_reg_rs1_addr_in),
        .io_sigIO_lft_tile_regfile_io_rs2_addr(port_reg_rs2_addr_in),
        .io_sigIO_lft_tile_regfile_io_rs1_data(port_reg_rs1_data_out),
        .io_sigIO_lft_tile_regfile_io_rs2_data(port_reg_rs2_data_out),
        
        .io_sigIO_lft_tile_exe_alu_out(port_alu_out),
        .io_sigIO_lft_tile_wb_reg_wbdata(port_reg_rd_data_in),
        .io_sigIO_lft_tile_exe_reg_wbaddr(port_exe_reg_wbaddr),
        .io_sigIO_lft_tile_wb_reg_wbaddr(port_reg_rd_addr_in),

        .io_sigIO_lft_tile_wb_reg_inst(port_wb_reg_inst),
        .io_sigIO_lft_tile_wb_reg_pc(port_wb_reg_pc),

        .io_sigIO_lft_tile_imm_itype_sext(port_imm_itype_sext),
        .io_sigIO_lft_tile_imm_sbtype_sext(port_imm_sbtype_sext),
        .io_sigIO_lft_tile_imm_stype_sext(port_imm_stype_sext),
        
        .io_sigIO_lft_tile_alu_fun(port_alu_fun),

        .io_dmem_req_ready(fe_in_io_dmem_req_ready),
        .io_imem_req_ready(fe_in_io_imem_req_ready),
    `endif
    `ifdef SODOR5_SIGNALS
        .io_sigIO_lft_tile_imm_itype_sext(port_imm),
        .io_sigIO_lft_tile_exe_alu_out(port_alu_out),
        .io_sigIO_lft_tile_exe_alu_op1(port_exe_alu_op1),
        .io_sigIO_lft_tile_exe_alu_op2(port_exe_alu_op2),
        .io_sigIO_lft_tile_regfile_io_rs1_addr(port_reg_rs1_addr_in),
        .io_sigIO_lft_tile_regfile_io_rs2_addr(port_reg_rs2_addr_in),
        .io_sigIO_lft_tile_regfile_io_rs1_data(port_reg_rs1_data_out),
        .io_sigIO_lft_tile_regfile_io_rs2_data(port_reg_rs2_data_out),
        .io_sigIO_lft_tile_wb_reg_wbdata(port_reg_rd_data_in),
        .io_sigIO_lft_tile_wb_reg_wbaddr(port_reg_rd_addr_in),
        
        .io_sigIO_lft_tile_dec_reg_inst(port_dec_reg_inst),
        .io_sigIO_lft_tile_exe_reg_inst(port_exe_reg_inst),
        .io_sigIO_lft_tile_mem_reg_inst(port_mem_reg_inst),
        .io_sigIO_lft_tile_mem_reg_alu_out(port_mem_reg_alu_out),
        .io_sigIO_lft_tile_if_reg_pc(port_if_reg_pc),
        .io_sigIO_lft_tile_dec_reg_pc(port_dec_reg_pc),
        .io_sigIO_lft_tile_exe_reg_pc(port_exe_reg_pc),
        .io_sigIO_lft_tile_mem_reg_pc(port_mem_reg_pc),
        .io_sigIO_lft_tile_lb_table_valid(port_lb_table_valid),
        .io_sigIO_lft_tile_lb_table_addr(port_lb_table_addr),
        .io_sigIO_lft_tile_lb_table_data(port_lb_table_data),
        .io_sigIO_lft_tile_dec_wbaddr(port_dec_wbaddr),
        .io_sigIO_lft_tile_exe_reg_wbaddr(port_exe_reg_wbaddr),
        .io_sigIO_lft_tile_mem_reg_wbaddr(port_mem_reg_wbaddr),
        .io_sigIO_lft_tile_imm_sbtype_sext(port_imm_sbtype_sext),
        .io_sigIO_lft_tile_alu_fun(port_alu_fun),
    `endif
    `ifdef SODORU_SIGNALS
        .io_sigIO_lft_tile_pc(port_pc),
    `endif
        .io_reset_vector(fe_in_io_reset_vector)
    );

    SimpleDMEM dmem (
        .clock(clock), 
        .reset(reset), 
        .dmem_in_io_dmem_req_bits_addr(fe_ou_io_dmem_req_bits_addr),
        .dmem_in_io_dmem_req_bits_data(fe_ou_io_dmem_req_bits_data),
        .dmem_in_io_dmem_req_bits_fcn(fe_ou_io_dmem_req_bits_fcn),
        .dmem_in_io_dmem_req_bits_typ(fe_ou_io_dmem_req_bits_typ),
        .dmem_in_io_dmem_req_valid(fe_ou_io_dmem_req_valid),
        .dmem_ou_io_dmem_resp_bits_data(fe_in_io_dmem_resp_bits_data),
        .dmem_ou_io_dmem_resp_valid(fe_in_io_dmem_resp_valid),
        .dmem_ou_io_dmem_req_ready(fe_in_io_dmem_req_ready)
    );

endmodule