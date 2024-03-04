import os
from random import randint
import shutil
import subprocess
from typing import Callable
from predicate import get_b_imm_sext, get_i_imm_sext, get_rd, get_rs1, get_rs2, PipelinePredicate, is_4033, reads_from_zero, writes_to_zero, check_rs1_dep, check_rs2_dep, is_alui, is_alur
from moplib import IFrame, ISignal, MopBehaviour, Mop, Signal, SignalConnect, SignalSig, Assignment
from veriloggen import VArraySelect, VBAssignment, VBVConst, VFuncApplication, VLiteral, VSignal, VStmtSeq
import sodor5_testblock

PARENT_DIR = "riscv-sodor-model/"
ITYPE = "i"
VCDFILE = "sodor5_model_wave_pipeline.vcd"

# Design hooks for simulation
TBFILE : str = f"{PARENT_DIR}verification/sodor5/sodor5_verif_{ITYPE}type_tb.v"
TBVCD : str = f"{PARENT_DIR}verification/{VCDFILE}"
# def make_tbblock(_: str) -> str:
#     return sodor5_testblock.make_testblock_by_seed(randint(0, 1<<10), ITYPE)
def run_tbsim() -> None:
    subprocess.call(f"make sodor5_verif_{ITYPE}type_tb_run", shell=True, cwd=PARENT_DIR+"verification/")
def generate_tests(num_tests: int, test_basedir: str, sampler : Callable[[], str] = (lambda : "")):
    """Generate vcd traces by running several test

    Args:
        num_tests (int): Number of tests you want to run
        test_basedir (str): Where should the test logs be written to?
        sampler (Callable[[], str]): What should the sampling strategy look like
    """
    for testnum in range(num_tests):
        # Make the directory
        path = "{}/test_{}/".format(test_basedir, testnum)
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)

        # Get the program
        prog_string = sampler()
        # Log the program
        with open(path + "program.v", "w") as fh1:
            fh1.write(prog_string)

        # And copy it to the testbench
        with open(TBFILE, "w") as fh2:
            fh2.write(prog_string)
        # subprocess.call("make sodor5_dmem_run", shell=True)
        # Run the testbench (to collect a trace)
        run_tbsim()
        # Copy the generated tb to the directory
        shutil.copy2(TBVCD, path)

# Timing calibration for simulation
BASE_CYCLE  = 10
MAX_CYCLE   = 30
# What is the timescale for the design
LEAP = 20
SIMULATION_RANGE = range(BASE_CYCLE*LEAP, MAX_CYCLE*LEAP, LEAP)
# MSequence range
MSEQ_RANGE = range(BASE_CYCLE, MAX_CYCLE-1)

# Hook for distinguisher
def run_distinguisher(test_dir, test_id, t, assumes, block, asserts):
    with open('{}/test_{}/distinguisher_{}.v'.format(test_dir, test_id, t), 'w') as fh:
        fh.write(sodor5_testblock.make_distinguish_block(t, assumes, block, asserts))

# =====================
# Define signals
# =====================
data_t              = SignalSig(None, 32, SignalConnect.CSIG, 'x')
regaddr_t           = SignalSig(None, 5, SignalConnect.CSIG, 'x')
imm_t               = SignalSig(None, 32, SignalConnect.CSIG, 'x')

regfile             = Signal("regfile", SignalSig(5, 32, SignalConnect.CSIG))
inst                = Signal("inst", SignalSig(None, 32, SignalConnect.DSIG))

imm_i               = Signal("imm_i", imm_t)
imm_b               = Signal("imm_b", imm_t)
# funct3              = Signal("funct3", SignalSig(None, 3, SignalConnect.DSIG))
alu_fun             = Signal("alu_fun", SignalSig(None, 4, SignalConnect.DSIG))

reg_rs1_addr_in     = Signal("reg_rs1_addr_in", regaddr_t)
reg_rs2_addr_in     = Signal("reg_rs2_addr_in", regaddr_t)
reg_rs1_data_out    = Signal("reg_rs1_data_out", data_t)
reg_rs2_data_out    = Signal("reg_rs2_data_out", data_t)

alu_out             = Signal("alu_out", data_t)
mem_reg_alu_out     = Signal("mem_reg_alu_out", data_t)
reg_rd_data_in      = Signal("reg_rd_data_in", data_t)

dec_wbaddr          = Signal("dec_wbaddr", regaddr_t)
exe_reg_wbaddr      = Signal("exe_reg_wbaddr", regaddr_t)
mem_reg_wbaddr      = Signal("mem_reg_wbaddr", regaddr_t)
reg_rd_addr_in      = Signal("reg_rd_addr_in", regaddr_t)

lb_table_addr       = Signal("lb_table_addr", SignalSig(None, 32, SignalConnect.DSIG, 'x'))
lb_table_data       = Signal("lb_table_data", SignalSig(None, 32, SignalConnect.DSIG, 'x'))
lb_table_valid      = Signal("lb_table_valid", SignalSig(None, 1, SignalConnect.DSIG, 'x'))


# Mapping between signal and the name in the AUM
# TODO: add stuff for memory (loads type) and imm_s_sext (for stores)
basename_mapping = {
    regfile : "regfile",
    inst : "inst",
    imm_i : "imm",
    imm_b : "imm_b",
    alu_fun : "alu_fun",
    reg_rs1_addr_in : "reg_rs1_addr_in",
    reg_rs2_addr_in : "reg_rs2_addr_in",
    reg_rs1_data_out : "reg_rs1_data_out",
    reg_rs2_data_out : "reg_rs2_data_out",
    alu_out : "alu_out",
    mem_reg_alu_out : "mem_reg_alu_out",
    reg_rd_data_in : "reg_rd_data_in",
    dec_wbaddr : "dec_wbaddr",
    exe_reg_wbaddr : "exe_reg_wbaddr",
    mem_reg_wbaddr : "mem_reg_wbaddr",
    reg_rd_addr_in : "reg_rd_addr_in",
}

def get_extension_mapping(pref_: str):
    return {
        s : VSignal(pref_+basename_mapping[s]) for s in basename_mapping
    }

repr_mapping = get_extension_mapping("")

# Defing mapping from signals to elements in the DUT
MAPPING = {
    regfile             : ['sodor5_verif_tb.sv.coretop.core.d.regfile.\\regfile[{}][31:0]'.format(i) for i in range(32)],
    imm_i               : 'sodor5_verif_tb.sv.coretop.core.d.imm_itype_sext[31:0]',
    imm_b               : 'sodor5_verif_tb.sv.coretop.core.d.imm_sbtype_sext[31:0]',
    alu_out             : 'sodor5_verif_tb.sv.coretop.core.d.exe_alu_out[31:0]',
    reg_rs1_addr_in     : 'sodor5_verif_tb.sv.coretop.core.d.regfile_io_rs1_addr[4:0]',
    reg_rs2_addr_in     : 'sodor5_verif_tb.sv.coretop.core.d.regfile_io_rs2_addr[4:0]',
    reg_rs1_data_out    : 'sodor5_verif_tb.sv.coretop.core.d.regfile_io_rs1_data[31:0]',
    reg_rs2_data_out    : 'sodor5_verif_tb.sv.coretop.core.d.regfile_io_rs2_data[31:0]',
    reg_rd_data_in      : 'sodor5_verif_tb.sv.coretop.core.d.wb_reg_wbdata[31:0]',
    reg_rd_addr_in      : 'sodor5_verif_tb.sv.coretop.core.d.wb_reg_wbaddr[4:0]',
    dec_wbaddr          : 'sodor5_verif_tb.sv.coretop.core.d.dec_wbaddr[4:0]',
    exe_reg_wbaddr      : 'sodor5_verif_tb.sv.coretop.core.d.exe_reg_wbaddr[4:0]',
    mem_reg_wbaddr      : 'sodor5_verif_tb.sv.coretop.core.d.mem_reg_wbaddr[4:0]',
    mem_reg_alu_out     : 'sodor5_verif_tb.sv.coretop.core.d.mem_reg_alu_out[31:0]',
    inst                : 'sodor5_verif_tb.sv.coretop.core.io_imem_resp_bits_data[31:0]',
    alu_fun             : 'sodor5_verif_tb.sv.coretop.core.d.io_ctl_alu_fun[3:0]',
    lb_table_addr       : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_addr[31:0]',
    lb_table_data       : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_data[31:0]',
    lb_table_valid      : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_valid'
}


# =====================
# Decode operations
# =====================
def sim_gen_decode_i_imm(assignmentmap: Assignment):
    ''' decode immediate address '''
    assignmentmap[imm_i] = get_i_imm_sext(assignmentmap[inst])
    return assignmentmap
def sim_gen_decode_b_imm(assignmentmap: Assignment):
    ''' decode immediate address '''
    assignmentmap[imm_b] = get_b_imm_sext(assignmentmap[inst])
    return assignmentmap
def sim_gen_decode_rd_addr(assignmentmap: Assignment):
    ''' decode dest address '''
    assignmentmap[dec_wbaddr] = get_rd(assignmentmap[inst])
    return assignmentmap
def sim_gen_decode_rs1_addr(assignmentmap: Assignment):
    ''' decode source 1 addresses '''
    assignmentmap[reg_rs1_addr_in] = get_rs1(assignmentmap[inst])
    return assignmentmap
def sim_gen_decode_rs2_addr(assignmentmap: Assignment):
    ''' decode source 2 addresses '''
    assignmentmap[reg_rs2_addr_in] = get_rs2(assignmentmap[inst])
    return assignmentmap

# =====================
# Generic pipeline connections
# =====================
def sim_feed__reg_rs1_data_out__reg_rd_data_in(assignmentmap: Assignment):
    ''' rd <= rs1 '''
    assignmentmap[reg_rd_data_in] = assignmentmap[reg_rs1_data_out]
    return assignmentmap
def sim_feed__reg_rs2_data_out__reg_rd_data_in(assignmentmap: Assignment):
    ''' rd <= rs2 '''
    assignmentmap[reg_rd_data_in] = assignmentmap[reg_rs2_data_out]
    return assignmentmap
def sim_feed__imm__reg_rd_data_in(assignmentmap: Assignment):
    ''' rd <= imm_i '''
    assignmentmap[reg_rd_data_in] = assignmentmap[imm_i]
    return assignmentmap
def sim_feed__alu_out__reg_rd_data_in(assignmentmap: Assignment):
    ''' rd <= alu_out '''
    assignmentmap[reg_rd_data_in] = assignmentmap[alu_out]
    return assignmentmap
def sim_feed__alu_out__mem_reg_alu_out(assignmentmap: Assignment):
    ''' mem_reg_alu_out <= alu_out '''
    assignmentmap[mem_reg_alu_out] = assignmentmap[alu_out]
    return assignmentmap
def sim_feed__mem_reg_alu_out__reg_rd_data_in(assignmentmap: Assignment):
    ''' rd <= mem_reg_alu_out '''
    assignmentmap[reg_rd_data_in] = assignmentmap[mem_reg_alu_out]
    return assignmentmap
def sim_feed__dec_wbaddr__exe_reg_wbaddr(assignmentmap: Assignment):
    ''' mem_reg_alu_out <= alu_out '''
    assignmentmap[exe_reg_wbaddr] = assignmentmap[dec_wbaddr]
    return assignmentmap
def sim_zero__exe_reg_wbaddr(assignmentmap: Assignment):
    assignmentmap[exe_reg_wbaddr] = 0
    return assignmentmap
def sim_feed__exe_reg_wbaddr__mem_reg_wbaddr(assignmentmap: Assignment):
    ''' mem_reg_alu_out <= alu_out '''
    assignmentmap[mem_reg_wbaddr] = assignmentmap[exe_reg_wbaddr]
    return assignmentmap
def sim_feed__mem_reg_wbaddr__reg_rd_addr_in(assignmentmap: Assignment):
    ''' rd <= mem_reg_alu_out '''
    assignmentmap[reg_rd_addr_in] = assignmentmap[mem_reg_wbaddr]
    return assignmentmap


# =====================
# ALU computations
# =====================
# def sim_alu_compute_add_rs(assignmentmap: Assignment):
#     ''' compute alu on rs inputs '''
#     if isinstance(assignmentmap[reg_rs1_data_out], str) or isinstance(assignmentmap[reg_rs2_data_out], str):
#         assignmentmap[alu_out] = 'x'
#     else:
#         assignmentmap[alu_out] = (assignmentmap[reg_rs1_data_out] + assignmentmap[reg_rs2_data_out]) % (1 << 32)
#     return assignmentmap
# def sim_alu_compute_add_rs_imm(assignmentmap: Assignment):
#     ''' compute on rs1 and imm_i inputs '''
#     if isinstance(assignmentmap[reg_rs1_data_out], str) or isinstance(assignmentmap[imm_i], str):
#         assignmentmap[alu_out] = 'x'
#     elif assignmentmap[funct3] == 0:
#         imm_s = assignmentmap[imm_i] if (assignmentmap[imm_i] < (1<<11)) else (assignmentmap[imm_i]-(1<<12))
#         assignmentmap[alu_out] = (assignmentmap[reg_rs1_data_out] + imm_s) % (1 << 32)
#     elif assignmentmap[funct3] == 6:
#         imm_s = assignmentmap[imm_i] if (assignmentmap[imm_i] < (1<<11)) else (assignmentmap[imm_i]-(1<<12))
#         assignmentmap[alu_out] = (assignmentmap[reg_rs1_data_out] | imm_s) % (1 << 32)
#     elif assignmentmap[funct3] == 8:
#         imm_s = assignmentmap[imm_i] if (assignmentmap[imm_i] < (1<<11)) else (assignmentmap[imm_i]-(1<<12))
#         assignmentmap[alu_out] = (assignmentmap[reg_rs1_data_out] < imm_s)
#     elif assignmentmap[funct3] == 9:
#         assignmentmap[alu_out] = (assignmentmap[reg_rs1_data_out] < assignmentmap[imm_i])
#     return assignmentmap
def sim_alu_compute_gen_imm(assignmentmap: Assignment, _src_s: Signal):
    ''' compute on src1, src2 inputs '''
    if isinstance(assignmentmap[_src_s], str) or isinstance(assignmentmap[imm_i], str):
        assignmentmap[alu_out] = 'x'
    elif assignmentmap[alu_fun] == 0:
        assignmentmap[alu_out] = (assignmentmap[_src_s] + assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[alu_fun] == 2:
        _imm_s = assignmentmap[imm_i] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] << _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 3:
        _imm_s = assignmentmap[imm_i] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] >> _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 4:
        _imm_s = assignmentmap[imm_i] & 31
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s >> _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 5:
        assignmentmap[alu_out] = (assignmentmap[_src_s] & assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[alu_fun] == 6:
        assignmentmap[alu_out] = (assignmentmap[_src_s] | assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[alu_fun] == 7:
        assignmentmap[alu_out] = (assignmentmap[_src_s] ^ assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[alu_fun] == 8:
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        imm_normal = (assignmentmap[imm_i]) if (assignmentmap[imm_i] < (1 << 31)) else (assignmentmap[imm_i]-(1<<32))
        assignmentmap[alu_out] = int(_src_s < imm_normal)
    elif assignmentmap[alu_fun] == 9:
        assignmentmap[alu_out] = int(assignmentmap[_src_s] < assignmentmap[imm_i])
    return assignmentmap

def sim_alu_compute_gen_rs(assignmentmap: Assignment, _src_s: Signal, _rs_s: Signal):
    ''' compute on src1, src2 inputs '''
    if isinstance(assignmentmap[_src_s], str) or isinstance(assignmentmap[_rs_s], str):
        assignmentmap[alu_out] = 'x'
    elif assignmentmap[alu_fun] == 0:
        assignmentmap[alu_out] = (assignmentmap[_src_s] + assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[alu_fun] == 1:
        assignmentmap[alu_out] = (assignmentmap[_src_s] - assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[alu_fun] == 2:
        _rs_s = assignmentmap[_rs_s] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] << _rs_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 3:
        _rs_s = assignmentmap[_rs_s] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] >> _rs_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 4:
        _rs_s = assignmentmap[_rs_s] & 31
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s >> _rs_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 5:
        assignmentmap[alu_out] = (assignmentmap[_src_s] & assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[alu_fun] == 6:
        assignmentmap[alu_out] = (assignmentmap[_src_s] | assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[alu_fun] == 7:
        assignmentmap[alu_out] = (assignmentmap[_src_s] ^ assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[alu_fun] == 8:
        _rs_s = assignmentmap[_rs_s] if (assignmentmap[_rs_s] < (1<<31)) else (assignmentmap[_rs_s]-(1<<32))
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s < _rs_s)
    elif assignmentmap[alu_fun] == 9:
        assignmentmap[alu_out] = (assignmentmap[_src_s] < assignmentmap[_rs_s])
    return assignmentmap

def sim_alu_compute_add_gen_imm_b(assignmentmap, _src_s: Signal):
    ''' compute on alu_out and imm_b inputs '''
    if isinstance(assignmentmap[_src_s], str) or isinstance(assignmentmap[imm_b], str):
        assignmentmap[alu_out] = 'x'
    else:
        imm_s_sext = assignmentmap[imm_b] if (assignmentmap[imm_b] < (1 << 11)) else (assignmentmap[imm_b]-(1<<12))
        assignmentmap[alu_out] = (assignmentmap[_src_s] + imm_s_sext) % (1 << 32)
    return assignmentmap
# =====================
# RegFile procedures
# =====================
def sim_regs1_read(assignmentmap: Assignment):
    ''' read rs 1 values from the register file '''
    if assignmentmap[reg_rs1_addr_in] == 0:
        assignmentmap[reg_rs1_data_out] = 0
    else:
        assignmentmap[reg_rs1_data_out] = (assignmentmap[regfile][assignmentmap[reg_rs1_addr_in]])
    return assignmentmap
def sim_regs2_read(assignmentmap: Assignment):
    ''' read rs 2 values from the register file '''
    if assignmentmap[reg_rs2_addr_in] == 0:
        assignmentmap[reg_rs2_data_out] = 0
    else:
        assignmentmap[reg_rs2_data_out] = (assignmentmap[regfile][assignmentmap[reg_rs2_addr_in]])
    return assignmentmap
def sim_regs_write(assignmentmap: Assignment):
    ''' write data to the regsiter file '''
    if assignmentmap[reg_rd_addr_in] != 0:
        assignmentmap[regfile][assignmentmap[reg_rd_addr_in]] = assignmentmap[reg_rd_data_in]
    return assignmentmap

# wire synth__txn_gen_decode_i_imm;
# wire synth__txn_gen_decode_b_imm;
# wire synth__txn_gen_decode_rs1_addr;
# wire synth__txn_gen_decode_rs2_addr;
# wire synth__txn_gen_decode_rd_addr;
gen_decode_i_imm = Mop("gen_decode_i_imm", sim_gen_decode_i_imm,
    [inst], [imm_i], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[imm_i], VFuncApplication("get_i_imm", [pre_map[inst]])))
gen_decode_b_imm = Mop("gen_decode_b_imm", sim_gen_decode_b_imm,
    [inst], [imm_b], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[imm_b], VFuncApplication("get_b_imm", [pre_map[inst]])))
gen_decode_rs1_addr = Mop("gen_decode_rs1_addr", sim_gen_decode_rs1_addr,
    [inst], [reg_rs1_addr_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rs1_addr_in], VFuncApplication("get_rs1", [pre_map[inst]])))
gen_decode_rs2_addr = Mop("gen_decode_rs2_addr", sim_gen_decode_rs2_addr,
    [inst], [reg_rs2_addr_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rs2_addr_in], VFuncApplication("get_rs2", [pre_map[inst]])))
gen_decode_rd_addr = Mop("gen_decode_rd_addr", sim_gen_decode_rd_addr,
    [inst], [dec_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[dec_wbaddr], VFuncApplication("get_rd", [pre_map[inst]])))
# wire synth__txn_feed__imm__reg_rd_data_in;
# wire synth__txn_feed__dec_wbaddr__exe_reg_wbaddr;
feed__imm__reg_rd_data_in = Mop("feed__imm__reg_rd_data_in",
    sim_feed__imm__reg_rd_data_in,
    [imm_i], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_data_in], pre_map[imm_i]))
feed__dec_wbaddr__exe_reg_wbaddr = Mop("feed__dec_wbaddr__exe_reg_wbaddr",
    sim_feed__dec_wbaddr__exe_reg_wbaddr,
    [dec_wbaddr], [exe_reg_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[exe_reg_wbaddr], pre_map[dec_wbaddr]))
# wire synth__txn_zero__exe_reg_wbaddr;
zero__exe_reg_wbaddr = Mop("zero__exe_reg_wbaddr", sim_zero__exe_reg_wbaddr,
    [], [exe_reg_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[exe_reg_wbaddr], VBVConst("0", 32)))
# wire synth__txn_feed__exe_reg_wbaddr__mem_reg_wbaddr;
# wire synth__txn_feed__mem_reg_wbaddr__reg_rd_addr_in;
# wire synth__txn_feed__reg_rs1_data_out__reg_rd_data_in;
# wire synth__txn_feed__reg_rs2_data_out__reg_rd_data_in;
# wire synth__txn_feed__alu_out__reg_rd_data_in;
# wire synth__txn_feed__alu_out__mem_reg_alu_out;
# wire synth__txn_feed__mem_reg_alu_out__reg_rd_data_in;
feed__exe_reg_wbaddr__mem_reg_wbaddr = Mop("feed__exe_reg_wbaddr__mem_reg_wbaddr",
    sim_feed__exe_reg_wbaddr__mem_reg_wbaddr,
    [exe_reg_wbaddr], [mem_reg_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[mem_reg_wbaddr], pre_map[exe_reg_wbaddr]))
feed__mem_reg_wbaddr__reg_rd_addr_in = Mop("feed__mem_reg_wbaddr__reg_rd_addr_in", 
    sim_feed__mem_reg_wbaddr__reg_rd_addr_in,
    [mem_reg_wbaddr], [reg_rd_addr_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_addr_in], pre_map[mem_reg_wbaddr]))
feed__reg_rs1_data_out__reg_rd_data_in = Mop("feed__reg_rs1_data_out__reg_rd_data_in", 
    sim_feed__reg_rs1_data_out__reg_rd_data_in,
    [reg_rs1_data_out], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_data_in], pre_map[reg_rs1_data_out]))
feed__reg_rs2_data_out__reg_rd_data_in = Mop("feed__reg_rs2_data_out__reg_rd_data_in", 
    sim_feed__reg_rs2_data_out__reg_rd_data_in,
    [reg_rs2_data_out], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_data_in], pre_map[reg_rs2_data_out]))
feed__alu_out__reg_rd_data_in = Mop("feed__alu_out__reg_rd_data_in", 
    sim_feed__alu_out__reg_rd_data_in,
    [alu_out], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_data_in], pre_map[alu_out]))
feed__alu_out__mem_reg_alu_out = Mop("feed__alu_out__mem_reg_alu_out", 
    sim_feed__alu_out__mem_reg_alu_out,
    [alu_out], [mem_reg_alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[mem_reg_alu_out], pre_map[alu_out]))
feed__mem_reg_alu_out__reg_rd_data_in = Mop("feed__mem_reg_alu_out__reg_rd_data_in", 
    sim_feed__mem_reg_alu_out__reg_rd_data_in,
    [mem_reg_alu_out], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rd_data_in], pre_map[mem_reg_alu_out]))

# wire synth__txn_alu_compute_rs_imm;
# wire synth__txn_alu_compute_alu_out_imm;
# wire synth__txn_alu_compute_memd_imm;
# wire synth__txn_alu_compute_rd_imm;
alu_compute_rs_imm = Mop("alu_compute_rs_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, reg_rs1_data_out),
    [alu_fun, reg_rs1_data_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[reg_rs1_data_out], pre_map[imm_i], pre_map[alu_fun]])))
alu_compute_alu_out_imm = Mop("alu_compute_alu_out_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, alu_out),
    [alu_fun, alu_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[alu_out], pre_map[imm_i], pre_map[alu_fun]])))
alu_compute_memd_imm = Mop("alu_compute_memd_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, mem_reg_alu_out),
    [alu_fun, mem_reg_alu_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[mem_reg_alu_out], pre_map[imm_i], pre_map[alu_fun]])))
alu_compute_rd_imm = Mop("alu_compute_rd_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, reg_rd_data_in),
    [alu_fun, reg_rd_data_in, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[reg_rd_data_in], pre_map[imm_i], pre_map[alu_fun]])))

# ALUR with dependency on rs2
# wire synth__txn_alu_compute_rs_rs;
# wire synth__txn_alu_compute_alu_out_rs;
# wire synth__txn_alu_compute_memd_rs;
# wire synth__txn_alu_compute_rd_rs;
alu_compute_rs_rs = Mop("alu_compute_rs_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, reg_rs2_data_out),
    [alu_fun, reg_rs2_data_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[reg_rs2_data_out], pre_map[alu_fun]])))
alu_compute_alu_out_rs = Mop("alu_compute_alu_out_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, alu_out),
    [alu_fun, alu_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[alu_out], pre_map[alu_fun]])))
alu_compute_memd_rs = Mop("alu_compute_memd_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, mem_reg_alu_out),
    [alu_fun, mem_reg_alu_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[mem_reg_alu_out], pre_map[alu_fun]])))
alu_compute_rd_rs = Mop("alu_compute_rd_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, reg_rd_data_in),
    [alu_fun, reg_rd_data_in, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[reg_rd_data_in], pre_map[alu_fun]])))
# ALUR with dependency on rs1
# wire synth__txn_alu_compute_alu_out_rs2;
# wire synth__txn_alu_compute_rd_rs2;
alu_compute_alu_out_rs2 = Mop("alu_compute_alu_out_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, alu_out, reg_rs2_data_out),
    [alu_fun, alu_out, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[alu_out], pre_map[reg_rs2_data_out], pre_map[alu_fun]])))
alu_compute_memd_rs2 = Mop("alu_compute_memd_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, mem_reg_alu_out, reg_rs2_data_out),
    [alu_fun, mem_reg_alu_out, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[mem_reg_alu_out], pre_map[reg_rs2_data_out], pre_map[alu_fun]])))
alu_compute_rd_rs2 = Mop("alu_compute_rd_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rd_data_in, reg_rs2_data_out),
    [alu_fun, reg_rd_data_in, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rd_data_in], pre_map[reg_rs2_data_out], pre_map[alu_fun]])))
alu_compute_rd_alu_out = Mop("alu_compute_rd_alu_out",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rd_data_in, alu_out),
    [alu_fun, reg_rd_data_in, alu_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rd_data_in], pre_map[alu_out], pre_map[alu_fun]])))

# Interface with the register file
# wire synth__txn_regs1_read;
# wire synth__txn_regs2_read;
# wire synth__txn_regs_write;
regs1_read = Mop("regs1_read", sim_regs1_read,
    [regfile, reg_rs1_addr_in], [reg_rs1_data_out], MopBehaviour.COM,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rs1_data_out], VArraySelect(pre_map[regfile], [pre_map[reg_rs1_addr_in]])))
regs2_read = Mop("regs2_read", sim_regs2_read,
    [regfile, reg_rs2_addr_in], [reg_rs2_data_out], MopBehaviour.COM,
    lambda new_map, pre_map:
    VBAssignment(new_map[reg_rs2_data_out], VArraySelect(pre_map[regfile], [pre_map[reg_rs2_addr_in]])))
regs_write = Mop("regs_write", sim_regs_write,
    [regfile, reg_rd_addr_in, reg_rd_data_in], [regfile], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[regfile], [pre_map[reg_rd_addr_in]]), pre_map[reg_rd_data_in]))

# Operations on the branch immediate field: these have faulty vstmts
# wire synth__txn_alu_compute_add_rs_imm_b;
# wire synth__txn_alu_compute_add_alu_out_imm_b;
# wire synth__txn_alu_compute_add_memd_imm_b;
# wire synth__txn_alu_compute_add_rd_imm_b;
alu_compute_add_rs_imm_b = Mop("alu_compute_add_rs_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, reg_rs1_data_out),
        [reg_rs1_data_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_alu_out_imm_b = Mop("alu_compute_add_alu_out_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, alu_out),
        [alu_fun, alu_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_memd_imm_b = Mop("alu_compute_add_memd_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, mem_reg_alu_out),
        [alu_fun, mem_reg_alu_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_rd_imm_b = Mop("alu_compute_add_rd_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, reg_rd_data_in),
        [alu_fun, reg_rd_data_in, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))

def sim_flush_decode(ass: Assignment):
    ass[reg_rs1_addr_in] = 0
    ass[reg_rs2_addr_in] = 0
    ass[dec_wbaddr] = 0
    ass[imm_i] = 0
    ass[imm_b] = 0
    return ass
flush_decode = Mop("flush_decode",
        sim_flush_decode,
        [], [reg_rs1_addr_in, reg_rs2_addr_in, dec_wbaddr, imm_i, imm_b], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[reg_rs1_addr_in], VLiteral("0")),
        VBAssignment(new_map[reg_rs2_addr_in], VLiteral("0")),
        VBAssignment(new_map[dec_wbaddr], VLiteral("0")),
        VBAssignment(new_map[imm_i], VLiteral("0")),
        VBAssignment(new_map[imm_b], VLiteral("0"))
    ]))

TRANSACTIONS = [
    gen_decode_i_imm,
    gen_decode_b_imm,
    gen_decode_rs1_addr,
    gen_decode_rs2_addr,
    gen_decode_rd_addr,
    feed__imm__reg_rd_data_in,
    feed__dec_wbaddr__exe_reg_wbaddr,
    feed__exe_reg_wbaddr__mem_reg_wbaddr,
    zero__exe_reg_wbaddr,
    feed__mem_reg_wbaddr__reg_rd_addr_in,
    feed__reg_rs1_data_out__reg_rd_data_in,
    feed__reg_rs2_data_out__reg_rd_data_in,
    feed__alu_out__reg_rd_data_in,
    feed__alu_out__mem_reg_alu_out,
    feed__mem_reg_alu_out__reg_rd_data_in,
    regs1_read,
    regs2_read,
    regs_write,
    alu_compute_rs_imm,
    alu_compute_alu_out_imm,
    alu_compute_memd_imm,
    alu_compute_rd_imm,
    alu_compute_rs_rs,
    alu_compute_alu_out_rs,
    alu_compute_memd_rs,
    alu_compute_rd_rs,
    alu_compute_alu_out_rs2,
    alu_compute_rd_rs2,
    alu_compute_add_rs_imm_b,
    alu_compute_add_alu_out_imm_b,
    alu_compute_add_memd_imm_b,
    alu_compute_add_rd_imm_b,
    alu_compute_memd_rs2,
    alu_compute_rd_alu_out,
    flush_decode
]

def transactions_by_name():
    return {
        t.name : t for t in TRANSACTIONS
    }



is_4033_fet = PipelinePredicate("is_4033_fet",
    lambda frame: is_4033(frame["pipeline"][0]), 1,
    lambda frame: "(= {} #x00004033)".format(frame["pipeline"][0])
)
is_4033_dec = PipelinePredicate("is_4033_dec",
    lambda frame: is_4033(frame["pipeline"][1]), 2,
    lambda frame: "(= {} #x00004033)".format(frame["pipeline"][1])
)
is_4033_exe = PipelinePredicate("is_4033_exe",
    lambda frame: is_4033(frame["pipeline"][2]), 3,
    lambda frame: "(= {} #x00004033)".format(frame["pipeline"][2])
)
is_4033_mem = PipelinePredicate("is_4033_mem",
    lambda frame: is_4033(frame["pipeline"][3]), 4,
    lambda frame: "(= {} #x00004033)".format(frame["pipeline"][3])
)
is_4033_wb = PipelinePredicate("is_4033_wb",
    lambda frame: is_4033(frame["pipeline"][4]), 5,
    lambda frame: "(= {} #x00004033)".format(frame["pipeline"][4])
)

reads_from_zero_exe = PipelinePredicate("reads_from_zero_exe",
    lambda frame: reads_from_zero(frame["pipeline"][2]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["pipeline"][2])
)
reads_from_zero_mem = PipelinePredicate("reads_from_zero_mem",
    lambda frame: reads_from_zero(frame["pipeline"][3]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["pipeline"][3])
)
reads_from_zero_wb = PipelinePredicate("reads_from_zero_wb",
    lambda frame: reads_from_zero(frame["pipeline"][4]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["pipeline"][4])
)

writes_to_zero_exe = PipelinePredicate("writes_to_zero_exe",
    lambda frame: writes_to_zero(frame["pipeline"][2]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["pipeline"][2])
)
writes_to_zero_mem = PipelinePredicate("writes_to_zero_mem",
    lambda frame: writes_to_zero(frame["pipeline"][3]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["pipeline"][3])
)
writes_to_zero_wb = PipelinePredicate("writes_to_zero_wb",
    lambda frame: writes_to_zero(frame["pipeline"][4]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["pipeline"][4])
)

data_rs1dep_fet_dec = PipelinePredicate("data_rs1dep_fet_dec",
    lambda frame: check_rs1_dep(frame["pipeline"][0], frame["pipeline"][1]), 2,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][0], frame["pipeline"][1])
)
data_rs2dep_fet_dec = PipelinePredicate("data_rs2dep_fet_dec",
    lambda frame: check_rs2_dep(frame["pipeline"][0], frame["pipeline"][1]), 2,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][0], frame["pipeline"][1])
)

data_rs1dep_dec_exe = PipelinePredicate("data_rs1dep_dec_exe",
    lambda frame: check_rs1_dep(frame["pipeline"][1], frame["pipeline"][2]), 3,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][2])
)
data_rs2dep_dec_exe = PipelinePredicate("data_rs2dep_dec_exe",
    lambda frame: check_rs2_dep(frame["pipeline"][1], frame["pipeline"][2]), 3,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][2])
)

data_rs1dep_dec_mem = PipelinePredicate("data_rs1dep_dec_mem",
    lambda frame: check_rs1_dep(frame["pipeline"][1], frame["pipeline"][3]), 4,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][3])
)
data_rs2dep_dec_mem = PipelinePredicate("data_rs2dep_dec_mem",
    lambda frame: check_rs2_dep(frame["pipeline"][1], frame["pipeline"][3]), 4,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][3])
)

data_rs1dep_dec_wb = PipelinePredicate("data_rs1dep_dec_wb",
    lambda frame: check_rs1_dep(frame["pipeline"][1], frame["pipeline"][4]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][4])
)
data_rs2dep_dec_wb = PipelinePredicate("data_rs2dep_dec_wb",
    lambda frame: check_rs2_dep(frame["pipeline"][1], frame["pipeline"][4]), 5,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["pipeline"][1], frame["pipeline"][4])
)

alui_fet = PipelinePredicate("alui_fet",
    lambda frame: is_alui(frame["pipeline"][0]), 1,
    lambda frame: "(= ((_ extract 6 0) {}) #b0010011)".format(frame["pipeline"][0])
)
alur_fet = PipelinePredicate("alur_fet",
    lambda frame: is_alur(frame["pipeline"][0]), 1,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["pipeline"][0])
)
alui_dec = PipelinePredicate("alui_dec",
    lambda frame: is_alui(frame["pipeline"][1]), 2,
    lambda frame: "(= ((_ extract 6 0) {}) #b0010011)".format(frame["pipeline"][1])
)
alur_dec = PipelinePredicate("alur_dec",
    lambda frame: is_alur(frame["pipeline"][1]), 2,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["pipeline"][1])
)

PREDICATES = [
    # is_4033_fet,
    # is_4033_dec,
    # is_4033_exe,
    # is_4033_mem,
    # is_4033_wb,
    # data_rs1dep_fet_dec,
    # data_rs2dep_fet_dec,
    data_rs1dep_dec_exe,
    # data_rs2dep_dec_exe,
    data_rs1dep_dec_mem,
    # data_rs2dep_dec_mem,
    data_rs1dep_dec_wb,
    # data_rs2dep_dec_wb,
    # alui_fet,
    # # alur_fet,
    # alui_dec,
    # # alur_dec,
    reads_from_zero_exe,
    writes_to_zero_exe,
    writes_to_zero_mem,
    writes_to_zero_wb
    # (writes_to_zero_exe | writes_to_zero_mem)
]

inst_fet = ISignal("inst_fet", 32, 'sodor5_verif_tb.sv.coretop.core.d.io_imem_resp_bits_data[31:0]', 0)
inst_dec = ISignal("inst_fet", 32, 'sodor5_verif_tb.sv.coretop.core.d.dec_reg_inst[31:0]', 0)
inst_exe = ISignal("inst_fet", 32, 'sodor5_verif_tb.sv.coretop.core.d.exe_reg_inst[31:0]', 0)
inst_mem = ISignal("inst_fet", 32, 'sodor5_verif_tb.sv.coretop.core.d.exe_reg_inst[31:0]', -1*LEAP)
inst_wb = ISignal("inst_fet", 32, 'sodor5_verif_tb.sv.coretop.core.d.exe_reg_inst[31:0]', -2*LEAP)

# (0, 'sodor_tb.coretop.core.d.io_imem_resp_bits_data[31:0]')
# (0, 'sodor_tb.coretop.core.d.dec_reg_inst[31:0]')
# (0, 'sodor_tb.coretop.core.d.exe_reg_inst[31:0]')
# (-1, 'sodor_tb.coretop.core.d.exe_reg_inst[31:0]')
# (-2, 'sodor_tb.coretop.core.d.exe_reg_inst[31:0]')

ISIGNALS = [
    inst_fet, inst_dec, inst_exe, inst_mem, inst_wb
]
