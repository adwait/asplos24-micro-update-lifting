

pmp_tb_build:
	iverilog -g2005-sv -o pmp_tb build/pmp.v build/lzc.v rtl/simple_csr_regfile.v rtl/cva6_pmp_tb.v  

tlb_model_tb_build:
	iverilog -g2005-sv -o tlb_tb build/cva6_tlb_sv32.v verification/tlb/cva6_tlb_model.v rtl/cva6_tlb_tb.v

tlb_tb_build:
	iverilog -g2005-sv -o tlb_tb build/cva6_tlb_sv32.v rtl/cva6_tlb_tb.v

wbuffer_tb_build:
	iverilog -g2005-sv -o wbuffer_tb build/wt_dcache_wbuffer.v build/rr_arb_tree.v build/lzc.v build/fifo_v3.v rtl/cva6_wbuffer_tb.v

wbuffer_model_tb_build:
	iverilog -g2005-sv -DEXPOSE_STATE -o wbuffer_model_tb build/wt_dcache_wbuffer.v build/rr_arb_tree.v build/lzc.v build/fifo_v3.v verification/wbuffer/cva6_wbuffer_model.v rtl/cva6_wbuffer_model_tb.v

store_buffer_tb_build:
	iverilog -g2005-sv -o store_buffer_tb build/store_buffer.v rtl/cva6_store_buffer_tb.v

store_unit_tb_build:
	iverilog -g2005-sv -DLIFTING -o store_unit_tb build/store_unit.v build/store_buffer.v build/amo_buffer.v rtl/cva6_store_unit_tb.v

store_unit_model_tb_build:
	iverilog -g2005-sv -DEXPOSE_STATE -o store_unit_model_tb build/store_unit.v build/store_buffer.v build/amo_buffer.v rtl/cva6_store_unit_model_tb.v verification/lsu/cva6_su_model.v

load_store_unit_tb_build:
	iverilog -g2005-sv -o load_store_unit_tb build/load_store_unit.v build/shift_reg.v build/store_unit.v  build/store_buffer.v build/amo_buffer.v build/load_unit.v build/lsu_bypass.v rtl/cva6_lsu_tb.v

load_store_unit_model_tb_build:
	iverilog -g2005-sv -o load_store_unit_model_tb build/load_store_unit.v build/shift_reg.v build/store_unit.v  build/store_buffer.v build/amo_buffer.v build/load_unit.v build/lsu_bypass.v rtl/cva6_lsu_model_tb.v verification/lsu/cva6_lsu_shim.v verification/lsu/cva6_lsu_model.v

load_store_unit_processor_tb_build:
	iverilog -g2005-sv -DEXPOSE_STATE -DRANDOMIZE -DUSE_SHIM -o load_store_unit_processor_tb build/load_store_unit.v build/shift_reg.v build/store_unit.v  build/store_buffer.v build/amo_buffer.v build/load_unit.v build/lsu_bypass.v rtl/cva6_processor_tb.v  verification/lsu/cva6_processor_shim.v verification/lsu/cva6_lsu_shim.v

pmp_tb_run:	pmp_tb_build
	./pmp_tb

tlb_tb_run: tlb_tb_build
	./tlb_tb

wbuffer_tb_run: wbuffer_tb_build
	./wbuffer_tb

wbuffer_model_tb_run: wbuffer_model_tb_build
	./wbuffer_model_tb