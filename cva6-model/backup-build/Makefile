
CVA6_ROOT := /home/adwait/Documents/hardware-designs/cva6

# SOurce folders
MMU_DIR 	:= $(CVA6_ROOT)/core/mmu_sv32
PMP_DIR		:= $(CVA6_ROOT)/core/pmp
MAIN_DIR	:= $(CVA6_ROOT)/core

# Build folder name
OUTDIR   := build

# Include directories relative to this Makefile
INC_DIRS :=                    \
  	$(CVA6_ROOT)/core/include


SRCS_MMU ?= \
	$(MMU_DIR)/cva6_mmu_sv32.sv \
	$(MMU_DIR)/cva6_ptw_sv32.sv \
	$(MMU_DIR)/cva6_tlb_sv32.sv

SRCS_PMP ?= \
	$(PMP_DIR)/src/pmp.sv \
	$(PMP_DIR)/src/pmp_entry.sv

SRCS_MAIN ?= \
	$(MAIN_DIR)/alu.sv \
	$(MAIN_DIR)/amo_buffer.sv \
	$(MAIN_DIR)/ariane.sv \
	$(MAIN_DIR)/ariane_regfile.sv \
	$(MAIN_DIR)/ariane_regfile_ff.sv \
	$(MAIN_DIR)/axi_adapter.sv \
	$(MAIN_DIR)/axi_shim.sv \
	$(MAIN_DIR)/branch_unit.sv \
	$(MAIN_DIR)/commit_stage.sv  \
	$(MAIN_DIR)/controller.sv \
	$(MAIN_DIR)/csr_buffer.sv \
	$(MAIN_DIR)/csr_regfile.sv \
	$(MAIN_DIR)/cva6.sv \
	$(MAIN_DIR)/cvxif_fu.sv  \
	$(MAIN_DIR)/dromajo_ram.sv \
	$(MAIN_DIR)/ex_stage.sv \
	$(MAIN_DIR)/fpu_wrap.sv \
	$(MAIN_DIR)/id_stage.sv \
	$(MAIN_DIR)/instr_realign.sv  \
	$(MAIN_DIR)/load_store_unit.sv \
	$(MAIN_DIR)/load_unit.sv \
	$(MAIN_DIR)/lsu_bypass.sv \
	$(MAIN_DIR)/mult.sv \
	$(MAIN_DIR)/multiplier.sv \
	$(MAIN_DIR)/perf_counters.sv  \
	$(MAIN_DIR)/serdiv.sv \
	$(MAIN_DIR)/store_buffer.sv \
	$(MAIN_DIR)/store_unit.sv

PKGS ?=                                        	\
  	$(CVA6_ROOT)/core/include/ariane_pkg.sv		\
	$(CVA6_ROOT)/core/include/riscv_pkg.sv		\
	$(CVA6_ROOT)/core/include/cv32a6_imac_sv0_config_pkg.sv \
	$(CVA6_ROOT)/core/include/ariane_axi_pkg.sv \
	$(CVA6_ROOT)/core/include/std_cache_pkg.sv \
	$(CVA6_ROOT)/core/include/wt_cache_pkg.sv \
	$(CVA6_ROOT)/corev_apu/axi/src/axi_pkg.sv \

# $(CVA6_ROOT)/core/fpu/src/common_cells/src/lzc.sv


# $(OUTDIR)/cva6_ptw_sv32.v	\
# $(OUTDIR)/cva6_tlb_sv32.v	\
# $(OUTDIR)/pmp.v				\
# $(OUTDIR)/pmp_entry.v


$(OUTDIR):
	mkdir -p $(OUTDIR)

# Convert each SystemVerilog source into a Verilog file
$(OUTDIR)/cva6_mmu_sv32.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(SRCS_MMU) $(SRCS_PMP) > $@

$(OUTDIR)/cva6_ptw_sv32.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MMU_DIR)/cva6_ptw_sv32.sv > $@

$(OUTDIR)/cva6_tlb_sv32.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MMU_DIR)/cva6_tlb_sv32.sv > $@

$(OUTDIR)/lzc.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(CVA6_ROOT)/core/fpu/src/common_cells/src/lzc.sv > $@

$(OUTDIR)/fifo_v3.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(CVA6_ROOT)/core/fpu/src/common_cells/src/fifo_v3.sv > $@

$(OUTDIR)/rr_arb_tree.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(CVA6_ROOT)/core/fpu/src/common_cells/src/rr_arb_tree.sv > $@

$(OUTDIR)/shift_reg.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(CVA6_ROOT)/core/fpu/src/common_cells/src/shift_reg.sv > $@

# $(OUTDIR)/pmp_entry.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
# 	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
# 		$(PMP_DIR)/src/pmp_entry.sv > $@

$(OUTDIR)/pmp.v: $(SRCS_MMU) $(SRCS_PMP) $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(PMP_DIR)/src/pmp_entry.sv $(PMP_DIR)/src/pmp.sv > $@

$(OUTDIR)/cva6.v: $(SRCS_MMU) $(SRCS_PMP) $(SRCS_MAIN) $(PKGS) | $(OUTDIR)
	sv2v --define=PITON_ARIANE $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(SRCS_MMU) $(SRCS_PMP) $(SRCS_MAIN) > $@

$(OUTDIR)/load_unit.v: $(MAIN_DIR)/load_unit.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/load_unit.sv > $@

$(OUTDIR)/lsu_bypass.v: $(MAIN_DIR)/lsu_bypass.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/lsu_bypass.sv > $@

$(OUTDIR)/store_buffer.v: $(MAIN_DIR)/store_buffer.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/store_buffer.sv > $@

$(OUTDIR)/amo_buffer.v: $(MAIN_DIR)/amo_buffer.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/amo_buffer.sv > $@

$(OUTDIR)/store_unit.v: $(MAIN_DIR)/store_unit.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/store_unit.sv > $@

$(OUTDIR)/load_store_unit.v: $(MAIN_DIR)/load_store_unit.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/load_store_unit.sv > $@

$(OUTDIR)/csr_regfile.v: $(MAIN_DIR)/csr_regfile.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/csr_regfile.sv > $@

$(OUTDIR)/cache_ctrl.v: $(MAIN_DIR)/cache_subsystem/cache_ctrl.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/cache_subsystem/cache_ctrl.sv > $@

$(OUTDIR)/wt_dcache_wbuffer.v: $(MAIN_DIR)/cache_subsystem/wt_dcache_wbuffer.sv $(PKGS) | $(OUTDIR)
	sv2v $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$(MAIN_DIR)/cache_subsystem/wt_dcache_wbuffer.sv  > $@



verilog_mem: $(OUTDIR)/cva6_mmu_sv32.v $(OUTDIR)/cva6_ptw_sv32.v $(OUTDIR)/cva6_tlb_sv32.v $(OUTDIR)/pmp.v $(OUTDIR)/load_unit.v $(OUTDIR)/load_store_unit.v $(OUTDIR)/lsu_bypass.v $(OUTDIR)/amo_buffer.v $(OUTDIR)/store_buffer.v $(OUTDIR)/store_unit.v $(OUTDIR)/csr_regfile.v $(OUTDIR)/lzc.v

verilog_mmu: $(OUTDIR)/cva6_mmu_sv32.v

verilog_core: $(OUTDIR)/cva6.v

clean:
	-rm -rf $(OUTDIR)
