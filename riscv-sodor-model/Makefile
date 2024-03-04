
# All the RTLs from full design
sodor1_coreonly_top: 
	yosys sodor1_coreonly.ys

sodor1_coremem_top: 
	yosys sodor1_coremem.ys

sodor2_coreonly_top: 
	yosys sodor2_coreonly.ys

sodor2_coremem_top: 
	yosys sodor2_coremem.ys

sodor3_coreonly_top: 
	yosys sodor3_coreonly.ys

sodor3_coremem_top: 
	yosys sodor3_coremem.ys

# All the iverilog testbenches
sodor1_coreonly_tb:
	iverilog -o iverilog/sodor1_coreonly_tb iverilog/sodor1_tb.v rtl/sodor1_coreonly_top.v

sodor1_coremem_tb:
	iverilog -o iverilog/sodor1_coremem_tb iverilog/sodor1_tb.v rtl/sodor1_coremem_top.v

sodor1_dmem_tb:
	iverilog -o iverilog/sodor1_dmem_tb iverilog/sodor_tb.v rtl/sodor1_dmem_top.v

sodor2_coreonly_tb:
	iverilog -o iverilog/sodor2_coreonly_tb iverilog/sodor2_tb.v rtl/sodor2_coreonly_top.v

sodor2_coremem_tb:
	iverilog -o iverilog/sodor2_coremem_tb iverilog/sodor2_tb.v rtl/sodor2_coremem_top.v

sodor3_coreonly_tb:
	iverilog -o iverilog/sodor3_coreonly_tb iverilog/sodor3_tb.v rtl/sodor3_coreonly_top.v

sodor3_coremem_tb:
	iverilog -o iverilog/sodor3_coremem_tb iverilog/sodor3_tb.v rtl/sodor3_coremem_top.v

sodor3_dmem_tb:
	iverilog -o iverilog/sodor3_dmem_tb iverilog/sodor_tb.v rtl/sodor3_dmem_top.v

sodor5_dmem_tb:
	iverilog -o iverilog/sodor5_dmem_tb iverilog/sodor_tb.v rtl/sodor5_dmem_top.v 

sodoru_dmem_tb:
	iverilog -o iverilog/sodoru_dmem_tb iverilog/sodor_tb.v rtl/sodoru_dmem_top.v 


# Actually run the simulation
sodor1_coreonly_run: sodor1_coreonly_tb
	cd iverilog; ./sodor1_coreonly_tb; cd ..;

sodor1_coremem_run: sodor1_coremem_tb
	cd iverilog; ./sodor1_coremem_tb; cd ..;

sodor1_dmem_run: sodor1_dmem_tb
	cd iverilog; ./sodor1_dmem_tb; cd ..;

sodor2_coreonly_run: sodor2_coreonly_tb
	cd iverilog; ./sodor2_coreonly_tb; cd ..;

sodor2_coremem_run: sodor2_coremem_tb
	cd iverilog; ./sodor2_coremem_tb; cd ..;

sodor3_coreonly_run: sodor3_coreonly_tb
	cd iverilog; ./sodor3_coreonly_tb; cd ..;

sodor3_coremem_run: sodor3_coremem_tb
	cd iverilog; ./sodor3_coremem_tb; cd ..;

sodor3_dmem_run: sodor3_dmem_tb
	cd iverilog; ./sodor3_dmem_tb; cd ..;

sodor5_dmem_run: sodor5_dmem_tb
	cd iverilog; ./sodor5_dmem_tb; cd ..;

sodoru_dmem_run: sodoru_dmem_tb
	cd iverilog; ./sodoru_dmem_tb; cd ..;

# Macros
all_rtl: sodor1_coreonly sodor2_coreonly sodor1_coremem sodor2_coremem

all_tb: sodor1_coreonly_tb sodor1_coremem_tb sodor2_coreonly_tb sodor2_coremem_tb
