
# riscv-sodor

This repo holds files generated for modelling and verifying the `riscv-sodor` processor collection.
This repo is not standalone and needs to be placed in a `chipyard` build for the toplevel
RTL sources to be generatable. But, once these top level RTL sources are available (in the `rtl` directory) it 
includes files to simulate (`iverilog` directory) and verify (`verification` directory) the designs.

---

## Core IO

```
clock                   : in
reset                   : in
io_imem_req_valid       : out
io_imem_req_bits_addr   : out
io_imem_resp_valid      : in (data available)
io_imem_resp_bits_data  : in (data)
io_dmem_req_valid       : out (memory request)
io_dmem_req_bits_addr   : out (w/r addr)
io_dmem_req_bits_data   : out (write data)
io_dmem_req_bits_fcn    : out (w/r flag)
io_dmem_req_bits_typ    : out (w/r size)
io_dmem_resp_valid      : in (data available)
io_dmem_resp_bits_data  : in (data)
io_interrupt_debug      : in (?)
io_interrupt_mtip       : in (?) 
io_interrupt_msip       : in (?)
io_interrupt_meip       : in (?)
io_hartid               : in (hardware thread id)
io_reset_vector         : in (which PC to reset to)
```

## Core-wise timing behaviour

### 1Stage

- 1.5 cycle reset (for the purposes of simulation)
- Otherwise, everything is single cycle (halt on memory resp valid signal)

### 3Stage

**Cycling:**
- Same reset behaviour (1.5 cycles for the purposes of simulation)
- Need to check what is behaviour in the case of verification

**Memory:**
- Requires a req ready bit to be set from the (dmem/imem) memories
  - stalls for this bit in the case of instruction load (was causing a one cycle delay)

## Stage 5

**Cycling**
I was stuck: the original reset/cycling setup did not work :(. I made the following changes to the register initialization in `dpath.scala<L79:84>`:

```scala
  val exe_reg_wbaddr        = RegInit(0.asUInt(5.W))
  val exe_reg_rs1_addr      = RegInit(0.asUInt(5.W))
  val exe_reg_rs2_addr      = RegInit(0.asUInt(5.W))
  val exe_reg_op1_data      = RegInit(0.asUInt(conf.xprlen.W))
  val exe_reg_op2_data      = RegInit(0.asUInt(conf.xprlen.W))
  val exe_reg_rs2_data      = RegInit(0.asUInt(conf.xprlen.W))
```

The initialization gets rid of the undefined values issue.
Now a normal 1.5 cycle reset operations works (simiar to the other cores). 

---

### Verification:

The `verification` directory contains scripts and models that can be checked against the design.
The listing is as follows:

- `sodor1` subdir contains stuff specific to the 1stage design
- `sodor5` subdir contains stuff specific to 5stage design
  - `sodor_bmc.v` is the BMC script that invokes instances of the design and the model
  - `sodor5_*model_*.v` files implement a model that can be composed with the design under test
  - `sodor5_verif_tb.v` is a tb wrapper around `sodor5_bmc.v`
  - `sodor5_model_tb.v` is a tb wrapper around `sodor5*_model_*.v` files



#### The main design that is referenced is `sodor5_dmem_top.v`/`sodor3_dmem_top.v`:

- Be careful about the macros in  `ifdef DESIGN_REGS_RANDOMIZE` and `ifndef FORMAL` in this file. The protocol is as follows:
  - for random tests, enable `DESIGN_REGS_RANDOMIZE`, disable `FORMAL`: now we can get rid of `DESIGN_REGS_RANDOMIZE` and do all randomization through tb (both simulation and verification)
  - for distinguishers and formal checks, enable `FORMAL` 
  - for equivalence testbench, `FORMAL` is disabled but `DESIGN_REGS_RANDOMIZE` is disabled too (randomization is done in the `tb`)


### Misc.:

- `yosys -l <logfile>` helps to identify issues (even when you don't actually want to run yosys).
- registers are randomly initilized: when recompiling need to add this code to the generated verilog manually



### Other demonstration:

- error localization: if a pipeline component fails, for some cycle, but was correct for all cycles before that point, we know what is the failing transaction (and trigger) is
- error correction: since we can localize, we can also correct (give example of how this is done in the context of incremental model fixing)



