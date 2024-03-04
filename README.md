

# Artifact for ASPLOS 24: Lifting Micro-Update Models from RTL for Formal Security Analysis


## Dependencies/Requirements:

### Python 3.6 or later

Packages: `pip install tabulate cvc5 vcdvcd`

### CVC5 Solver

We require an installation of CVC5 for performing synthesis. You can obtain CVC5 from the CVC5 Releases tab for your corresponding OS. Make sure that the downloaded binaries/source install is on your `$PATH`.

### HW Tooling: Yosys, SymbiYosys, and Icarus Verilog

We also require an RTL simulator and HW formal model checker. We highly recommend using the freely available OSS CAD Suite which can be conveniently downloaded from the here. Please follow the corresponding README.md and ensure that the yosys, sby, boolector, and iverilog tools are on your `$PATH`. 

You can check this by running (for example): `yosys --help`.



## Running Synthesis:

We have provided the convenience scripts:

```
cva6_wbuffer_script.py
cva6_tlb_script.py
cva6_su_script.py
cva6_lsu_script_hier.py
cva6_lsu_script_mono.py
```

Which can be invoked with: `python3 <script_name>`. The results of this script will be stored in the `out` directory.

## Running Security Analysis:

We have provided the convenience scripts:

```
cva6_security_script.py
sodor5_security_script.py
```

These will produce tables comparing the performance of the micro-update model with the original RTL, in files, `cva6_sec_times.log` and `sodor5_sec_times.log` respectively.


## Library

The core library code is in the `aul` directory. This also includes the configuration files used for micro-update model generation: `cva6_configs` and `sodor_configs`. One can change configurations such as signals being extracted, micro-updates library used using these files. 



