import shutil
import subprocess
from predicate import get_b_imm, get_i_imm, get_i_imm_sext, get_rd, get_rs1, get_rs2
from moplib import MopBehaviour, Mop, Signal, SignalConnect, SignalSig, Assignment
from veriloggen import VArraySelect, VBAssignment, VBVConst, VFuncApplication, VLiteral, VBAssignment, VSignal, VStmtSeq
import sodor_testblock
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
funct3              = Signal("funct3", SignalSig(None, 3, SignalConnect.DSIG))

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

lb_table_addr       = Signal("lb_table_addr", data_t)
lb_table_data       = Signal("lb_table_data", data_t)
lb_table_valid      = Signal("lb_table_valid", SignalSig(None, 1, SignalConnect.CSIG, 'x'))

basename_mapping = {
    regfile : "regfile",
    inst : "inst",
    imm_i : "imm",
    imm_b : "imm_b",
    funct3 : "alu_fun",
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

# Defing mapping from signals to design elements
MAPPING = {
    regfile             : ['sodor_tb.coretop.core.d.regfile.\\regfile[{}][31:0]'.format(i) for i in range(32)],
    imm_i               : 'sodor_tb.coretop.core.d.imm_itype_sext[31:0]',
    imm_b               : 'sodor_tb.coretop.core.d.imm_sbtype_sext[31:0]',
    alu_out             : 'sodor_tb.coretop.core.d.exe_alu_out[31:0]',
    reg_rs1_addr_in     : 'sodor_tb.coretop.core.d.regfile_io_rs1_addr[4:0]',
    reg_rs2_addr_in     : 'sodor_tb.coretop.core.d.regfile_io_rs2_addr[4:0]',
    reg_rs1_data_out    : 'sodor_tb.coretop.core.d.regfile_io_rs1_data[31:0]',
    reg_rs2_data_out    : 'sodor_tb.coretop.core.d.regfile_io_rs2_data[31:0]',
    reg_rd_data_in      : 'sodor_tb.coretop.core.d.wb_reg_wbdata[31:0]',
    reg_rd_addr_in      : 'sodor_tb.coretop.core.d.wb_reg_wbaddr[4:0]',
    dec_wbaddr          : 'sodor_tb.coretop.core.d.dec_wbaddr[4:0]',
    exe_reg_wbaddr      : 'sodor_tb.coretop.core.d.exe_reg_wbaddr[4:0]',
    mem_reg_wbaddr      : 'sodor_tb.coretop.core.d.mem_reg_wbaddr[4:0]',
    mem_reg_alu_out     : 'sodor_tb.coretop.core.d.mem_reg_alu_out[31:0]',
    inst                : 'sodor_tb.coretop.core.io_imem_resp_bits_data[31:0]',
    funct3              : 'sodor_tb.coretop.core.d.io_ctl_alu_fun[3:0]',
    lb_table_addr       : 'sodor_tb.coretop.core.d.lb_table_addr[31:0]',
    lb_table_data       : 'sodor_tb.coretop.core.d.lb_table_data[31:0]',
    lb_table_valid      : 'sodor_tb.coretop.core.d.lb_table_valid'
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
    assignmentmap[imm_b] = get_b_imm(assignmentmap[inst])
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
    elif assignmentmap[funct3] == 0:
        assignmentmap[alu_out] = (assignmentmap[_src_s] + assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[funct3] == 2:
        _imm_s = assignmentmap[imm_i] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] << _imm_s) % (1 << 32)
    elif assignmentmap[funct3] == 3:
        _imm_s = assignmentmap[imm_i] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] >> _imm_s) % (1 << 32)
    elif assignmentmap[funct3] == 4:
        _imm_s = assignmentmap[imm_i] & 31
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s >> _imm_s) % (1 << 32)
    elif assignmentmap[funct3] == 5:
        assignmentmap[alu_out] = (assignmentmap[_src_s] & assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[funct3] == 6:
        assignmentmap[alu_out] = (assignmentmap[_src_s] | assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[funct3] == 7:
        assignmentmap[alu_out] = (assignmentmap[_src_s] ^ assignmentmap[imm_i]) % (1 << 32)
    elif assignmentmap[funct3] == 8:
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s < assignmentmap[imm_i])
    elif assignmentmap[funct3] == 9:
        imm_normal = (assignmentmap[imm_i]) if (assignmentmap[imm_i] < (1 << 31)) else (assignmentmap[imm_i]-(1<<32)+(1<<12))
        assignmentmap[alu_out] = (assignmentmap[_src_s] < imm_normal)
    return assignmentmap

def sim_alu_compute_gen_rs(assignmentmap: Assignment, _src_s: Signal, _rs_s: Signal):
    ''' compute on src1, src2 inputs '''
    if isinstance(assignmentmap[_src_s], str) or isinstance(assignmentmap[_rs_s], str):
        assignmentmap[alu_out] = 'x'
    elif assignmentmap[funct3] == 0:
        assignmentmap[alu_out] = (assignmentmap[_src_s] + assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[funct3] == 1:
        assignmentmap[alu_out] = (assignmentmap[_src_s] - assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[funct3] == 2:
        _rs_s = assignmentmap[_rs_s] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] << _rs_s) % (1 << 32)
    elif assignmentmap[funct3] == 3:
        _rs_s = assignmentmap[_rs_s] & 31
        assignmentmap[alu_out] = (assignmentmap[_src_s] >> _rs_s) % (1 << 32)
    elif assignmentmap[funct3] == 4:
        _rs_s = assignmentmap[_rs_s] & 31
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s >> _rs_s) % (1 << 32)
    elif assignmentmap[funct3] == 5:
        assignmentmap[alu_out] = (assignmentmap[_src_s] & assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[funct3] == 6:
        assignmentmap[alu_out] = (assignmentmap[_src_s] | assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[funct3] == 7:
        assignmentmap[alu_out] = (assignmentmap[_src_s] ^ assignmentmap[_rs_s]) % (1 << 32)
    elif assignmentmap[funct3] == 8:
        _rs_s = assignmentmap[_rs_s] if (assignmentmap[_rs_s] < (1<<31)) else (assignmentmap[_rs_s]-(1<<32))
        _src_s = assignmentmap[_src_s] if (assignmentmap[_src_s] < (1<<31)) else (assignmentmap[_src_s]-(1<<32))
        assignmentmap[alu_out] = (_src_s < _rs_s)
    elif assignmentmap[funct3] == 9:
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
    assignmentmap[regfile][assignmentmap[reg_rd_addr_in]] = (assignmentmap[reg_rd_data_in])
    return assignmentmap



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
feed__exe_reg_wbaddr__mem_reg_wbaddr = Mop("feed__exe_reg_wbaddr__mem_reg_wbaddr",
    sim_feed__exe_reg_wbaddr__mem_reg_wbaddr,
    [exe_reg_wbaddr], [mem_reg_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[mem_reg_wbaddr], pre_map[exe_reg_wbaddr]))
zero__exe_reg_wbaddr = Mop("zero__exe_reg_wbaddr", sim_zero__exe_reg_wbaddr,
    [], [exe_reg_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[exe_reg_wbaddr], VBVConst("0", 32)))
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

alu_compute_rs_imm = Mop("alu_compute_rs_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, reg_rs1_data_out),
    [funct3, reg_rs1_data_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[reg_rs1_data_out], pre_map[imm_i], pre_map[funct3]])))
alu_compute_alu_out_imm = Mop("alu_compute_alu_out_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, alu_out),
    [funct3, alu_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[alu_out], pre_map[imm_i], pre_map[funct3]])))
alu_compute_memd_imm = Mop("alu_compute_memd_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, mem_reg_alu_out),
    [funct3, mem_reg_alu_out, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[mem_reg_alu_out], pre_map[imm_i], pre_map[funct3]])))
alu_compute_rd_imm = Mop("alu_compute_rd_imm",
    lambda ass: sim_alu_compute_gen_imm(ass, reg_rd_data_in),
    [funct3, reg_rd_data_in, imm_i], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[reg_rd_data_in], pre_map[imm_i], pre_map[funct3]])))

# ALUR with dependency on rs2
alu_compute_rs_rs = Mop("alu_compute_rs_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, reg_rs2_data_out),
    [funct3, reg_rs2_data_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[reg_rs2_data_out], pre_map[funct3]])))
alu_compute_alu_out_rs = Mop("alu_compute_alu_out_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, alu_out),
    [funct3, alu_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[alu_out], pre_map[funct3]])))
alu_compute_memd_rs = Mop("alu_compute_memd_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, mem_reg_alu_out),
    [funct3, mem_reg_alu_out, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[mem_reg_alu_out], pre_map[funct3]])))
alu_compute_rd_rs = Mop("alu_compute_rd_rs",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rs1_data_out, reg_rd_data_in),
    [funct3, reg_rd_data_in, reg_rs1_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rs1_data_out], pre_map[reg_rd_data_in], pre_map[funct3]])))
# ALUR with dependency on rs1
alu_compute_alu_out_rs2 = Mop("alu_compute_alu_out_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, alu_out, reg_rs2_data_out),
    [funct3, alu_out, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[alu_out], pre_map[reg_rs2_data_out], pre_map[funct3]])))
alu_compute_memd_rs2 = Mop("alu_compute_memd_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, mem_reg_alu_out, reg_rs2_data_out),
    [funct3, mem_reg_alu_out, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[mem_reg_alu_out], pre_map[reg_rs2_data_out], pre_map[funct3]])))
alu_compute_rd_rs2 = Mop("alu_compute_rd_rs2",
    lambda ass: sim_alu_compute_gen_rs(ass, reg_rd_data_in, reg_rs2_data_out),
    [funct3, reg_rd_data_in, reg_rs2_data_out], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_r", [pre_map[reg_rd_data_in], pre_map[reg_rs2_data_out], pre_map[funct3]])))

# Interface with the register file
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
alu_compute_add_rs_imm_b = Mop("alu_compute_add_rs_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, reg_rs1_data_out),
        [reg_rs1_data_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_alu_out_imm_b = Mop("alu_compute_add_alu_out_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, alu_out),
        [funct3, alu_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_memd_imm_b = Mop("alu_compute_add_memd_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, mem_reg_alu_out),
        [funct3, mem_reg_alu_out, imm_b], [alu_out], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_out], VBVConst("0", 32)))
alu_compute_add_rd_imm_b = Mop("alu_compute_add_rd_imm_b",
        lambda ass: sim_alu_compute_add_gen_imm_b(ass, reg_rd_data_in),
        [funct3, reg_rd_data_in, imm_b], [alu_out], MopBehaviour.SEQ,
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
    flush_decode
]

def transactions_by_name():
    return {
        t.name : t for t in TRANSACTIONS
    }

def run_distinguisher(test_dir, test_id, t, assumes, block, asserts):
    with open('{}/test_{}/distinguisher_{}.v'.format(test_dir, test_id, t), 'w') as fh:
        fh.write(sodor_testblock.make_distinguish_block(t, assumes, block, asserts))