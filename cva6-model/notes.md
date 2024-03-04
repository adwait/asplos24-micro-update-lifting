

### Notes on the CVA 6 processor (and instrumentation)

**Hierarchy**: 
```
ex_stage -> lsu -> (lu, su, mmu)
mmu -> (pmp, tlb, ptw)
lu -> ?
su -> ?
```

**Interconnects**:

### Controller <-> *
- The  `controller` in cva6 (`core`) spits outputs (such as flush for tlb). Btw, a flush is triggered by the `sfence.vma` instruction (reaching its commit stage)
- The controller receives flush signals from the commit stage (and maybe more places).

### MMU <-> *
- The main inputs that the MMU receives have to deal req addr, data, pmpcfg, priv_lvl, etc. -
- `priv_lvl` and `pmpcfg`s are loaded from the `csr_regfile` (external to the `ex_stage`). These inputs directly affect the `pmp` behaviour.

### PMP <-> *
- The `pmp` gets a coded connection from the CSRs for the `pmpcfg` and `pmpaddr`.
- The main intricacy of the PMP is the addressing scheme used (`TOR` is easiest to handle, where the address checks are simply range containment for the `pmpaddr`s). `TOR` ode address checks are [here](../../build/pmp.v) line 29.

#### PMP configurations have a specific format:
- see [here](https://ascslab.org/conferences/secriscv/materials/papers/paper_19.pdf) for more details. Each `pmpcfg` register is of the form `{locked[1], reserved[2], mode[2], x[1], w[1], r[1]}`. Here mode can be one of `{OFF, TOR, NA4, NAPOT}` (typically `TOR` is easiest to manage).
- Current testbench only works for the `TOR` mode; also make sure that the locked flag is off.

### The testbenches:

#### PMP:
- Connects the PMP to a toy CSR file (functionally identical to original CSR file as far as `pmpcfg` registers are concerned).
- Contains tasks defined to write to `pmpcfg`s and perform `pmp` checks.

#### CSR file:

