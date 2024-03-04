
# All the RTLs from full design

# sodor3 compile tb
sodor3_verif_itype_tb_build:
	iverilog -o formal_tb sodor3/sodor3_verif_itype_tb.v sodor3/sodor3_bmc.v sodor3/sodor3_model_itype_full.v ../rtl/sodor3_dmem_top.v

sodor3_verif_rtype_tb_build:
	iverilog -o formal_tb sodor3/sodor3_verif_rtype_tb.v sodor3/sodor3_bmc.v sodor3/sodor3_model_rtype_full.v ../rtl/sodor3_dmem_top.v

sodor3_verif_ibtype_tb_build:
	iverilog -o formal_tb sodor3/sodor3_verif_ibtype_tb.v sodor3/sodor3_bmc.v sodor3/sodor3_model_ibtype_full.v ../rtl/sodor3_dmem_top.v

sodor3_verif_iltype_tb_build:
	iverilog -o formal_tb sodor3/sodor3_verif_iltype_tb.v sodor3/sodor3_bmc.v sodor3/sodor3_model_iltype_full.v ../rtl/sodor3_dmem_top.v

sodor3_verif_ilstype_tb_build:
	iverilog -o formal_tb sodor3/sodor3_verif_ilstype_tb.v sodor3/sodor3_bmc.v sodor3/sodor3_model_ilstype_full.v ../rtl/sodor3_dmem_top.v

# sodor5 compile tb
sodor5_verif_itype_tb_build:
	iverilog -o formal_tb sodor5/sodor5_verif_itype_tb.v sodor5/sodor5_bmc.v sodor5/sodor5_model_itype_full.v ../rtl/sodor5_dmem_top.v

sodor5_verif_rtype_tb_build:
	iverilog -o formal_tb sodor5/sodor5_verif_rtype_tb.v sodor5/sodor5_bmc.v sodor5/sodor5_model_rtype_full.v ../rtl/sodor5_dmem_top.v

sodor5_verif_ibtype_tb_build:
	iverilog -o formal_tb sodor5/sodor5_verif_ibtype_tb.v sodor5/sodor5_bmc.v sodor5/sodor5_model_ibtype_full.v ../rtl/sodor5_dmem_top.v

sodor5_verif_iltype_tb_build:
	iverilog -o formal_tb sodor5/sodor5_verif_iltype_tb.v sodor5/sodor5_bmc.v sodor5/sodor5_model_iltype_full.v ../rtl/sodor5_dmem_top.v

sodor5_verif_ilstype_tb_build:
	iverilog -o formal_tb sodor5/sodor5_verif_ilstype_tb.v sodor5/sodor5_bmc.v sodor5/sodor5_model_ilstype_full.v ../rtl/sodor5_dmem_top.v

sodor5_lb_tb_build:
	iverilog -o formal_tb -DSRC sodor5/sodor5_lb_tb.v sodor5/sodor5_lb_bmc.v ../rtl/sodor5_dmem_top.v

sodor5_lb_model_tb_build:
	iverilog -o formal_tb -DMODEL -DLB_VERIF -DSODOR5_SIGNALS sodor5/sodor5_lb_tb.v sodor5/sodor5_lb_model_bmc.v ../rtl/SimpleDMem.v sodor5/sodor5_model_ilstype_full.v

# sodor3 run
sodor3_verif_itype_tb_run: sodor3_verif_itype_tb_build
	./formal_tb

sodor3_verif_rtype_tb_run: sodor3_verif_rtype_tb_build
	./formal_tb

sodor3_verif_ibtype_tb_run: sodor3_verif_ibtype_tb_build
	./formal_tb

sodor3_verif_iltype_tb_run: sodor3_verif_iltype_tb_build
	./formal_tb

sodor3_verif_ilstype_tb_run: sodor3_verif_ilstype_tb_build
	./formal_tb

# sodor5 run
sodor5_verif_itype_tb_run: sodor5_verif_itype_tb_build
	./formal_tb

sodor5_verif_rtype_tb_run: sodor5_verif_rtype_tb_build
	./formal_tb

sodor5_verif_ibtype_tb_run: sodor5_verif_ibtype_tb_build
	./formal_tb

sodor5_verif_iltype_tb_run: sodor5_verif_iltype_tb_build
	./formal_tb

sodor5_verif_ilstype_tb_run: sodor5_verif_ilstype_tb_build
	./formal_tb

sodor5_lb_tb_run: sodor5_lb_tb_build
	./formal_tb

sodor5_lb_model_tb_run: sodor5_lb_model_tb_build
	./formal_tb