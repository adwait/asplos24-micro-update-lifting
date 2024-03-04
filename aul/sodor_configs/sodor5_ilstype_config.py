
from aul.processor_config import ProcessorConfig
from aul.predicate import get_b_imm_sext, get_i_imm_sext, get_s_imm_sext, get_rd, get_rs1, get_rs2, PipelinePredicate, is_4033, reads1_from_zero, reads2_from_zero, writes_to_zero, check_rs1_dep, check_rs2_dep, is_alui, is_alur, is_load, is_store, Predicate, is_i_type
from aul.moplib import DUTHook, ISignal, MopBehaviour, Mop, Signal, SignalConnect, SignalSig, Assignment
from aul.veriloggen import VArraySelect, VBAssignment, VBVConst, VFuncApplication, VLiteral, VStmtSeq, VBases, VITE, VOpExpr
from aul.sodor_configs import sodor5_testblock

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
imm_s               = Signal("imm_s", imm_t)
# funct3              = Signal("funct3", SignalSig(None, 3, SignalConnect.DSIG))
alu_fun             = Signal("alu_fun", SignalSig(None, 4, SignalConnect.DSIG))

reg_rs1_addr_in     = Signal("reg_rs1_addr_in", regaddr_t)
reg_rs2_addr_in     = Signal("reg_rs2_addr_in", regaddr_t)
reg_rs1_data_out    = Signal("reg_rs1_data_out", data_t)
reg_rs2_data_out    = Signal("reg_rs2_data_out", data_t)

alu_op1             = Signal("alu_op1", data_t)
alu_op2             = Signal("alu_op2", data_t)
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

mem_data            = Signal("mem_data", SignalSig(None, 32, SignalConnect.DSIG))
# mem_addr            = Signal("mem_addr", SignalSig(None, 32, SignalConnect.DSIG))

# Mapping between signal and the name in the AUM
# TODO: add stuff for memory (loads type) and imm_s_sext (for stores)
basename_mapping = {
    regfile : "regfile",
    inst : "inst",
    imm_i : "imm",
    imm_b : "imm_b",
    imm_s   : "imm_s",
    alu_fun : "alu_fun",
    reg_rs1_addr_in : "reg_rs1_addr_in",
    reg_rs2_addr_in : "reg_rs2_addr_in",
    reg_rs1_data_out : "reg_rs1_data_out",
    reg_rs2_data_out : "reg_rs2_data_out",
    alu_op1 : "alu_op1",
    alu_op2 : "alu_op2",
    alu_out : "alu_out",
    mem_reg_alu_out : "mem_reg_alu_out",
    reg_rd_data_in : "reg_rd_data_in",
    dec_wbaddr : "dec_wbaddr",
    exe_reg_wbaddr : "exe_reg_wbaddr",
    mem_reg_wbaddr : "mem_reg_wbaddr",
    reg_rd_addr_in : "reg_rd_addr_in",
    lb_table_addr : "lb_table_addr",
    lb_table_data : "lb_table_data",
    lb_table_valid : "lb_table_valid",
    mem_data    : "mem_data",
    # mem_addr    : "mem_addr"
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
def sim_gen_decode_s_imm(assignmentmap: Assignment):
    ''' decode immediate address '''
    assignmentmap[imm_s] = get_s_imm_sext(assignmentmap[inst])
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
def sim_gen_decode_all(assignmentmap: Assignment):
    return sim_gen_decode_i_imm(
        sim_gen_decode_b_imm(
            sim_gen_decode_s_imm(
                sim_gen_decode_rd_addr(
                    sim_gen_decode_rs1_addr(
                        sim_gen_decode_rs2_addr(assignmentmap))))))
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

def sim_alu_compute_comb(assignmentmap: Assignment):
    ''' compute on alu_op inputs '''
    if isinstance(assignmentmap[alu_op1], str) or isinstance(assignmentmap[alu_op2], str):
        assignmentmap[alu_out] = 'x'
    elif assignmentmap[alu_fun] == 0:
        assignmentmap[alu_out] = (assignmentmap[alu_op1] + assignmentmap[alu_op2]) % (1 << 32)
    elif assignmentmap[alu_fun] == 2:
        _imm_s = assignmentmap[alu_op2] & 31
        assignmentmap[alu_out] = (assignmentmap[alu_op1] << _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 3:
        _imm_s = assignmentmap[alu_op2] & 31
        assignmentmap[alu_out] = (assignmentmap[alu_op1] >> _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 4:
        _imm_s = assignmentmap[alu_op2] & 31
        _op1 = assignmentmap[alu_op1] if (assignmentmap[alu_op1] < (1<<31)) else (assignmentmap[alu_op1]-(1<<32))
        assignmentmap[alu_out] = (_op1 >> _imm_s) % (1 << 32)
    elif assignmentmap[alu_fun] == 5:
        assignmentmap[alu_out] = (assignmentmap[alu_op1] & assignmentmap[alu_op2]) % (1 << 32)
    elif assignmentmap[alu_fun] == 6:
        assignmentmap[alu_out] = (assignmentmap[alu_op1] | assignmentmap[alu_op2]) % (1 << 32)
    elif assignmentmap[alu_fun] == 7:
        assignmentmap[alu_out] = (assignmentmap[alu_op1] ^ assignmentmap[alu_op2]) % (1 << 32)
    elif assignmentmap[alu_fun] == 8:
        _op1 = assignmentmap[alu_op1] if (assignmentmap[alu_op1] < (1<<31)) else (assignmentmap[alu_op1]-(1<<32))
        imm_normal = (assignmentmap[alu_op2]) if (assignmentmap[alu_op2] < (1 << 31)) else (assignmentmap[alu_op2]-(1<<32))
        assignmentmap[alu_out] = int(_op1 < imm_normal)
    elif assignmentmap[alu_fun] == 9:
        assignmentmap[alu_out] = int(assignmentmap[alu_op1] < assignmentmap[alu_op2])
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
def sim_regs_read(assignmentmap: Assignment):
    return sim_regs1_read(sim_regs2_read(assignmentmap))
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
gen_decode_s_imm = Mop("gen_decode_s_imm", sim_gen_decode_s_imm,
    [inst], [imm_s], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[imm_s], VFuncApplication("get_s_imm", [pre_map[inst]])))
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

gen_decode_all = Mop("gen_decode_all", sim_gen_decode_all,
    [inst], [imm_i, imm_b, imm_s, reg_rs1_addr_in, reg_rs2_addr_in, dec_wbaddr], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[imm_i], VFuncApplication("get_i_imm", [pre_map[inst]])),
        VBAssignment(new_map[imm_b], VFuncApplication("get_b_imm", [pre_map[inst]])),
        VBAssignment(new_map[imm_s], VFuncApplication("get_s_imm", [pre_map[inst]])),
        VBAssignment(new_map[reg_rs1_addr_in], VFuncApplication("get_rs1", [pre_map[inst]])),
        VBAssignment(new_map[reg_rs2_addr_in], VFuncApplication("get_rs2", [pre_map[inst]])),
        VBAssignment(new_map[dec_wbaddr], VFuncApplication("get_rd", [pre_map[inst]]))
    ]))
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


def sim_feed__A__B(assignmentmap: Assignment, src: Signal, dest: Signal):
    assignmentmap[dest] = assignmentmap[src]
    return assignmentmap
feed__reg_rs1_data_out__alu_op1 = Mop("feed__reg_rs1_data_out__alu_op1", 
    lambda ass: sim_feed__A__B(ass, reg_rs1_data_out, alu_op1),
    [reg_rs1_data_out], [alu_op1], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op1], pre_map[reg_rs1_data_out]))
feed__alu_out__alu_op1 = Mop("feed__alu_out__alu_op1", 
    lambda ass: sim_feed__A__B(ass, alu_out, alu_op1),
    [alu_out], [alu_op1], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op1], pre_map[alu_out]))
feed__mem_reg_alu_out__alu_op1 = Mop("feed__mem_reg_alu_out__alu_op1", 
    lambda ass: sim_feed__A__B(ass, mem_reg_alu_out, alu_op1),
    [mem_reg_alu_out], [alu_op1], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op1], pre_map[mem_reg_alu_out]))
feed__reg_rd_data_in__alu_op1 = Mop("feed__reg_rd_data_in__alu_op1", 
    lambda ass: sim_feed__A__B(ass, reg_rd_data_in, alu_op1),
    [reg_rd_data_in], [alu_op1], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op1], pre_map[reg_rd_data_in]))
feed__imm_i__alu_op2 = Mop("feed__imm_i__alu_op2",
    lambda ass: sim_feed__A__B(ass, imm_i, alu_op2),
    [imm_i], [alu_op2], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op2], pre_map[imm_i]))
feed__imm_s__alu_op2 = Mop("feed__imm_s__alu_op2",
    lambda ass: sim_feed__A__B(ass, imm_s, alu_op2),
    [imm_s], [alu_op2], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op2], pre_map[imm_s]))
feed__mem_data__alu_op1 = Mop("feed__mem_data__alu_op1", 
    lambda ass: sim_feed__A__B(ass, mem_data, alu_op1),
    [mem_data], [alu_op1], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(new_map[alu_op1], pre_map[mem_data]))
alu_compute_comb = Mop("alu_compute_comb",
    lambda ass: sim_alu_compute_comb(ass),
    [alu_fun, alu_op1, alu_op2], [alu_out], MopBehaviour.COM,
    lambda new_map, pre_map: 
    VBAssignment(new_map[alu_out],
    VFuncApplication("alu_compute_i", [pre_map[alu_op1], pre_map[alu_op2], pre_map[alu_fun]])))

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
regs_read = Mop("regs_read", sim_regs_read,
    [regfile, reg_rs1_addr_in, reg_rs2_addr_in], [reg_rs1_data_out, reg_rs2_data_out], MopBehaviour.COM,
    lambda new_map, pre_map:
    VStmtSeq([
        VITE(VOpExpr("eq", [pre_map[reg_rs1_addr_in], VLiteral("0")]), 
            [VBAssignment(new_map[reg_rs1_data_out], VLiteral("0"))], 
            [VBAssignment(new_map[reg_rs1_data_out], VArraySelect(pre_map[regfile], [pre_map[reg_rs1_addr_in]]))]
        ),
        VITE(VOpExpr("eq", [pre_map[reg_rs2_addr_in], VLiteral("0")]), 
            [VBAssignment(new_map[reg_rs2_data_out], VLiteral("0"))], 
            [VBAssignment(new_map[reg_rs2_data_out], VArraySelect(pre_map[regfile], [pre_map[reg_rs2_addr_in]]))]
        )
    ]))
regs_write = Mop("regs_write", sim_regs_write,
    [regfile, reg_rd_addr_in, reg_rd_data_in], [regfile], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[regfile], [pre_map[reg_rd_addr_in]]), pre_map[reg_rd_data_in]))


def sim_lb_invalidate(assignmentmap: Assignment):
    assignmentmap[lb_table_valid] = 0
    return assignmentmap
lb_invalidate = Mop("lb_invalidate",
    lambda ass: sim_lb_invalidate(ass),
    [lb_table_addr, lb_table_data], [lb_table_addr, lb_table_data, lb_table_valid], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[lb_table_addr], pre_map[lb_table_addr]),
        VBAssignment(new_map[lb_table_data], pre_map[lb_table_data]),
        VBAssignment(new_map[lb_table_valid], VBVConst("0", 1, VBases.BIN))
    ]))
def sim_lb_refill(assignmentmap: Assignment):
    assignmentmap[lb_table_valid] = 1
    assignmentmap[lb_table_addr] = assignmentmap[mem_reg_alu_out]
    assignmentmap[lb_table_data] = assignmentmap[mem_data]
    return assignmentmap
lb_refill = Mop("lb_refill",
    lambda ass: sim_lb_refill(ass),
    [mem_reg_alu_out, mem_data], [lb_table_addr, lb_table_data, lb_table_valid], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[lb_table_addr], pre_map[mem_reg_alu_out]),
        VBAssignment(new_map[lb_table_data], pre_map[mem_data]),
        VBAssignment(new_map[lb_table_valid], VBVConst("1", 1, VBases.BIN))
    ]))
def sim_lb_hold(assignmentmap: Assignment):
    return assignmentmap
lb_hold = Mop("lb_hold",
    lambda ass: sim_lb_hold(ass),
    [lb_table_addr, lb_table_data, lb_table_valid], [lb_table_addr, lb_table_data, lb_table_valid], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[lb_table_addr], pre_map[lb_table_addr]),
        VBAssignment(new_map[lb_table_data], pre_map[lb_table_data]),
        VBAssignment(new_map[lb_table_valid], pre_map[lb_table_valid])
    ]))

def sim_feed__mem_resp__reg_rd_data_in(assignmentmap: Assignment):
    assignmentmap[reg_rd_data_in] = assignmentmap[mem_data]
    return assignmentmap
feed__mem_resp__reg_rd_data_in = Mop("feed__mem_resp__reg_rd_data_in",
    lambda ass: sim_feed__mem_resp__reg_rd_data_in(ass),
    [mem_data], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
        VBAssignment(new_map[reg_rd_data_in], pre_map[mem_data])
    )

def sim_feed__lb_table__reg_rd_data_in(assignmentmap: Assignment):
    assignmentmap[reg_rd_data_in] = assignmentmap[lb_table_data]
    return assignmentmap
feed__lb_table__reg_rd_data_in = Mop("feed__lb_table__reg_rd_data_in",
    lambda ass: sim_feed__lb_table__reg_rd_data_in(ass),
    [lb_table_data], [reg_rd_data_in], MopBehaviour.SEQ,
    lambda new_map, pre_map:
        VBAssignment(new_map[reg_rd_data_in], pre_map[lb_table_data])
    )

# alu_compute_load_imm = Mop("alu_compute_load_imm",
#     lambda ass: sim_alu_compute_gen_imm(ass, mem_data),
#     [alu_fun, mem_data, imm_i], [alu_out], MopBehaviour.SEQ,
#     lambda new_map, pre_map:
#     VBAssignment(new_map[alu_out],
#     VFuncApplication("alu_compute_i", [pre_map[mem_data], pre_map[imm_i], pre_map[alu_fun]])))

def sim_pipeline_hold(assignmentmap: Assignment):
    return assignmentmap
pipeline_hold = Mop("pipeline_hold",
    lambda ass: sim_pipeline_hold(ass),
    [mem_reg_alu_out, reg_rd_data_in, exe_reg_wbaddr, mem_reg_wbaddr, reg_rd_addr_in],
    [mem_reg_alu_out, reg_rd_data_in, exe_reg_wbaddr, mem_reg_wbaddr, reg_rd_addr_in],
    MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        # VBAssignment(new_map[alu_out], pre_map[alu_out]),
        VBAssignment(new_map[mem_reg_alu_out], pre_map[mem_reg_alu_out]),
        VBAssignment(new_map[reg_rd_data_in], pre_map[reg_rd_data_in]),
        VBAssignment(new_map[exe_reg_wbaddr], pre_map[exe_reg_wbaddr]),
        VBAssignment(new_map[mem_reg_wbaddr], pre_map[mem_reg_wbaddr]),
        VBAssignment(new_map[reg_rd_addr_in], pre_map[reg_rd_addr_in])
    ]))

def sim_flush_decode(assignmentmap: Assignment):
    assignmentmap[reg_rs1_addr_in] = 0
    assignmentmap[reg_rs2_addr_in] = 0
    assignmentmap[dec_wbaddr] = 0
    assignmentmap[imm_i] = 0
    assignmentmap[imm_b] = 0
    assignmentmap[imm_s] = 0
    return assignmentmap
flush_decode = Mop("flush_decode",
        sim_flush_decode,
        [], [reg_rs1_addr_in, reg_rs2_addr_in, dec_wbaddr, imm_i, imm_s, imm_b], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[reg_rs1_addr_in], VLiteral("0")),
        VBAssignment(new_map[reg_rs2_addr_in], VLiteral("0")),
        VBAssignment(new_map[dec_wbaddr], VLiteral("0")),
        VBAssignment(new_map[imm_i], VLiteral("0")),
        VBAssignment(new_map[imm_s], VLiteral("0")),
        VBAssignment(new_map[imm_b], VLiteral("0"))
    ]))
def sim_hold_decode(assignmentmap: Assignment):
    return assignmentmap
hold_decode = Mop("hold_decode",
    sim_hold_decode,
    [imm_i, reg_rs1_addr_in, reg_rs2_addr_in, dec_wbaddr, imm_b, imm_s, alu_op1, alu_op2],
    [imm_i, reg_rs1_addr_in, reg_rs2_addr_in, dec_wbaddr, imm_b, imm_s, alu_op1, alu_op2], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[imm_i], pre_map[imm_i]),
        VBAssignment(new_map[reg_rs1_addr_in], pre_map[reg_rs1_addr_in]),
        VBAssignment(new_map[reg_rs2_addr_in], pre_map[reg_rs2_addr_in]),
        VBAssignment(new_map[dec_wbaddr], pre_map[dec_wbaddr]),
        VBAssignment(new_map[imm_b], pre_map[imm_b]),
        VBAssignment(new_map[imm_s], pre_map[imm_s]),
        VBAssignment(new_map[alu_op1], pre_map[alu_op1]),
        VBAssignment(new_map[alu_op2], pre_map[alu_op2])
    ])) 
def sim_no_regs_write(assignmentmap: Assignment):
    return assignmentmap
no_regs_write = Mop("no_regs_write",
    sim_no_regs_write,
    [regfile], [regfile], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq()) 


is_4033_fet = PipelinePredicate("is_4033_fet",
    lambda frame: is_4033(frame["inst_fet"]), 1,
    lambda frame: "(= {} #x00004033)".format(frame["inst_fet"])
)
is_4033_dec = PipelinePredicate("is_4033_dec",
    lambda frame: is_4033(frame["inst_dec"]), 2,
    lambda frame: "(= {} #x00004033)".format(frame["inst_dec"])
)
is_4033_exe = PipelinePredicate("is_4033_exe",
    lambda frame: is_4033(frame["inst_exe"]), 3,
    lambda frame: "(= {} #x00004033)".format(frame["inst_exe"])
)
is_4033_mem = PipelinePredicate("is_4033_mem",
    lambda frame: is_4033(frame["inst_mem"]), 4,
    lambda frame: "(= {} #x00004033)".format(frame["inst_mem"])
)
is_4033_wb = PipelinePredicate("is_4033_wb",
    lambda frame: is_4033(frame["inst_wb"]), 5,
    lambda frame: "(= {} #x00004033)".format(frame["inst_wb"])
)

is_load_dec = PipelinePredicate("is_load_dec",
    lambda frame: is_load(frame["inst_dec"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_dec"])
)
is_load_exe = PipelinePredicate("is_load_exe",
    lambda frame: is_load(frame["inst_exe"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_exe"])
)
is_load_mem = PipelinePredicate("is_load_mem",
    lambda frame: is_load(frame["inst_mem"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_mem"])
)
is_load_wb = PipelinePredicate("is_load_wb",
    lambda frame: is_load(frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_wb"])
)
mem_resp_valid = Predicate("mem_resp_valid", 
    lambda frame: frame["mem_resp"] == 1,
    lambda frame: "(= {} #b1)".format(frame["mem_resp"])
)

is_store_dec = PipelinePredicate("is_store_dec",
    lambda frame: is_store(frame["inst_dec"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0100011)".format(frame["inst_dec"])
)
is_store_exe = PipelinePredicate("is_store_exe",
    lambda frame: is_store(frame["inst_exe"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0100011)".format(frame["inst_exe"])
)
is_store_mem = PipelinePredicate("is_store_mem",
    lambda frame: is_store(frame["inst_mem"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0100011)".format(frame["inst_mem"])
)
is_store_wb = PipelinePredicate("is_store_wb",
    lambda frame: is_store(frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 6 0) {}) #b0100011)".format(frame["inst_wb"])
)

reads1_from_zero_dec = PipelinePredicate("reads1_from_zero_dec",
    lambda frame: reads1_from_zero(frame["inst_dec"]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["inst_dec"])
)
reads1_from_zero_exe = PipelinePredicate("reads1_from_zero_exe",
    lambda frame: reads1_from_zero(frame["inst_exe"]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["inst_exe"])
)
reads1_from_zero_mem = PipelinePredicate("reads1_from_zero_mem",
    lambda frame: reads1_from_zero(frame["inst_mem"]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["inst_mem"])
)
reads1_from_zero_wb = PipelinePredicate("reads1_from_zero_wb",
    lambda frame: reads1_from_zero(frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) #b00000)".format(frame["inst_wb"])
)
reads2_from_zero_dec = PipelinePredicate("reads2_from_zero_dec",
    lambda frame: reads2_from_zero(frame["inst_dec"]), 5,
    lambda frame: "(= ((_ extract 24 20) {}) #b00000)".format(frame["inst_dec"])
)

writes_to_zero_exe = PipelinePredicate("writes_to_zero_exe",
    lambda frame: writes_to_zero(frame["inst_exe"]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["inst_exe"])
)
writes_to_zero_mem = PipelinePredicate("writes_to_zero_mem",
    lambda frame: writes_to_zero(frame["inst_mem"]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["inst_mem"])
)
writes_to_zero_wb = PipelinePredicate("writes_to_zero_wb",
    lambda frame: writes_to_zero(frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 11 7) {}) #b00000)".format(frame["inst_wb"])
)

data_rs1dep_fet_dec = PipelinePredicate("data_rs1dep_fet_dec",
    lambda frame: check_rs1_dep(frame["inst_fet"], frame["inst_dec"]), 2,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["inst_fet"], frame["inst_dec"])
)
data_rs2dep_fet_dec = PipelinePredicate("data_rs2dep_fet_dec",
    lambda frame: check_rs2_dep(frame["inst_fet"], frame["inst_dec"]), 2,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["inst_fet"], frame["inst_dec"])
)

data_rs1dep_dec_exe = PipelinePredicate("data_rs1dep_dec_exe",
    lambda frame: check_rs1_dep(frame["inst_dec"], frame["inst_exe"]), 3,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_exe"])
)
data_rs2dep_dec_exe = PipelinePredicate("data_rs2dep_dec_exe",
    lambda frame: check_rs2_dep(frame["inst_dec"], frame["inst_exe"]), 3,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_exe"])
)

data_rs1dep_dec_mem = PipelinePredicate("data_rs1dep_dec_mem",
    lambda frame: check_rs1_dep(frame["inst_dec"], frame["inst_mem"]), 4,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_mem"])
)
data_rs2dep_dec_mem = PipelinePredicate("data_rs2dep_dec_mem",
    lambda frame: check_rs2_dep(frame["inst_dec"], frame["inst_mem"]), 4,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_mem"])
)

data_rs1dep_dec_wb = PipelinePredicate("data_rs1dep_dec_wb",
    lambda frame: check_rs1_dep(frame["inst_dec"], frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 19 15) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_wb"])
)
data_rs2dep_dec_wb = PipelinePredicate("data_rs2dep_dec_wb",
    lambda frame: check_rs2_dep(frame["inst_dec"], frame["inst_wb"]), 5,
    lambda frame: "(= ((_ extract 24 20) {}) ((_ extract 11 7) {}))".format(frame["inst_dec"], frame["inst_wb"])
)

alui_fet = PipelinePredicate("alui_fet",
    lambda frame: is_alui(frame["inst_fet"]), 1,
    lambda frame: "(= ((_ extract 6 0) {}) #b0010011)".format(frame["inst_fet"])
)
alur_fet = PipelinePredicate("alur_fet",
    lambda frame: is_alur(frame["inst_fet"]), 1,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_fet"])
)
alui_dec = PipelinePredicate("alui_dec",
    lambda frame: is_alui(frame["inst_dec"]), 2,
    lambda frame: "(= ((_ extract 6 0) {}) #b0010011)".format(frame["inst_dec"])
)
itype_dec = PipelinePredicate("itype_dec",
    lambda frame: is_i_type(frame["inst_dec"]), 2,
    lambda frame: "(or (= ((_ extract 6 0) {}) #b0010011) (= ((_ extract 6 0) {}) #b0000011))".format(frame["inst_dec"])
)
alur_dec = PipelinePredicate("alur_dec",
    lambda frame: is_alur(frame["inst_dec"]), 2,
    lambda frame: "(= ((_ extract 6 0) {}) #b0110011)".format(frame["inst_dec"])
)

lb_match = Predicate("lb_match",
    lambda frame: frame["lb_valid"] == 1,
    lambda _: "false"
)
oracle = Predicate("oracle",
    lambda frame: frame["synth__hold_decode"] == 1,
    lambda _: "false"
)

inst_fet = ISignal("inst_fet", 32)
inst_dec = ISignal("inst_dec", 32)
inst_exe = ISignal("inst_exe", 32)
inst_mem = ISignal("inst_mem", 32)
inst_wb  = ISignal("inst_wb", 32)
mem_resp = ISignal("mem_resp", 1)
lb_valid = ISignal("lb_valid", 1)
synth__hold_decode   = ISignal("synth__hold_decode", 1)


ITYPE       = "ils"
LEAP        = 20
PARENT_DIR  = "riscv-sodor-model/"
SIMULATION_DIR  = f"{PARENT_DIR}/verification/"
VCDFILE     = "sodor5_model_wave_pipeline.vcd"

# Distinguisher macros and hooks
DISTINGUISHER_LEAP              = 10
DISTINGUISHER_INSERTION_CYCLE   = 5
DISTINGUISHER_DIR   = SIMULATION_DIR
DISTINGUISHER_FILE  = f"{SIMULATION_DIR}/sodor5/sodor5_distinguisher.v"
DISTINGUISHER_COMMAND   = "time sby -f dist.sby taskBMC12_distinguish_sodor5"
DISTINGUISHER_VCD       = f"{SIMULATION_DIR}/dist_taskBMC12_distinguish_sodor5/engine_0/trace.vcd"

# Defing mapping from signals to elements in the DUT
dut_basename_mapping = {
    regfile             : ['sodor5_verif_tb.sv.coretop.core.d.regfile.\\regfile[{}][31:0]'.format(i) for i in range(32)],
    imm_i               : 'sodor5_verif_tb.sv.coretop.core.d.imm_itype_sext[31:0]',
    imm_b               : 'sodor5_verif_tb.sv.coretop.core.d.imm_sbtype_sext[31:0]',
    imm_s               : 'sodor5_verif_tb.sv.coretop.core.d.imm_stype_sext[31:0]',
    alu_op1             : 'sodor5_verif_tb.sv.coretop.core.d.io_sigIO_lft_tile_exe_alu_op1[31:0]',
    alu_op2             : 'sodor5_verif_tb.sv.coretop.core.d.io_sigIO_lft_tile_exe_alu_op2[31:0]',
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
    alu_fun             : 'sodor5_verif_tb.sv.coretop.core.d.io_sigIO_lft_tile_alu_fun[3:0]',
    lb_table_addr       : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_addr[31:0]',
    lb_table_data       : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_data[31:0]',
    lb_table_valid      : 'sodor5_verif_tb.sv.coretop.core.d.lb_table_valid',
    mem_data            : 'sodor5_verif_tb.sv.coretop.fe_in_io_dmem_resp_bits_data[31:0]'
}
dut_basename_mapping_dist = {
    regfile             : ['sodor5_verif.coretop.core.d.regfile.\\regfile<{}>'.format(i) for i in range(32)],
    imm_i               : 'sodor5_verif.coretop.core.d.imm_itype_sext',
    imm_b               : 'sodor5_verif.coretop.core.d.imm_sbtype_sext',
    imm_s               : 'sodor5_verif.coretop.core.d.imm_stype_sext',
    alu_out             : 'sodor5_verif.coretop.core.d.exe_alu_out',
    reg_rs1_addr_in     : 'sodor5_verif.coretop.core.d.regfile_io_rs1_addr',
    reg_rs2_addr_in     : 'sodor5_verif.coretop.core.d.regfile_io_rs2_addr',
    reg_rs1_data_out    : 'sodor5_verif.coretop.core.d.regfile_io_rs1_data',
    reg_rs2_data_out    : 'sodor5_verif.coretop.core.d.regfile_io_rs2_data',
    reg_rd_data_in      : 'sodor5_verif.coretop.core.d.wb_reg_wbdata',
    reg_rd_addr_in      : 'sodor5_verif.coretop.core.d.wb_reg_wbaddr',
    dec_wbaddr          : 'sodor5_verif.coretop.core.d.dec_wbaddr',
    exe_reg_wbaddr      : 'sodor5_verif.coretop.core.d.exe_reg_wbaddr',
    mem_reg_wbaddr      : 'sodor5_verif.coretop.core.d.mem_reg_wbaddr',
    mem_reg_alu_out     : 'sodor5_verif.coretop.core.d.mem_reg_alu_out',
    inst                : 'sodor5_verif.coretop.core.io_imem_resp_bits_data',
    alu_fun             : 'sodor5_verif.coretop.core.d.io_ctl_alu_fun',
    lb_table_addr       : 'sodor5_verif.coretop.core.d.lb_table_addr',
    lb_table_data       : 'sodor5_verif.coretop.core.d.lb_table_data',
    lb_table_valid      : 'sodor5_verif.coretop.core.d.lb_table_valid'
}

dut_isig_basename_mapping = {
    inst_fet    : DUTHook('sodor5_verif_tb.sv.coretop.core.d.io_imem_resp_bits_data[31:0]', 0),
    inst_dec    : DUTHook('sodor5_verif_tb.sv.coretop.core.d.dec_reg_inst[31:0]', 0),
    inst_exe    : DUTHook('sodor5_verif_tb.sv.coretop.core.d.exe_reg_inst[31:0]', 0),
    inst_mem    : DUTHook('sodor5_verif_tb.sv.coretop.core.d.mem_reg_inst[31:0]', 0),
    inst_wb     : DUTHook('sodor5_verif_tb.sv.s5m.\\instr_queue[3][31:0]', 0),
    mem_resp    : DUTHook('sodor5_verif_tb.sv.s5m.in_io_dmem_resp_valid', 0),
    lb_valid    : DUTHook('sodor5_verif_tb.sv.s5m.lb_data_valid', 0),
    synth__hold_decode      : DUTHook('sodor5_verif_tb.sv.s5m.synth__txn_feed__mem_resp_reg_rd_data_in', 0)
}
dut_isig_basename_mapping_dist = {
    inst_fet    : DUTHook('sodor5_verif.coretop.core.d.io_imem_resp_bits_data', 0),
    inst_dec    : DUTHook('sodor5_verif.coretop.core.d.dec_reg_inst', 0),
    inst_exe    : DUTHook('sodor5_verif.coretop.core.d.exe_reg_inst', 0),
    inst_mem    : DUTHook('sodor5_verif.coretop.core.d.exe_reg_inst', -1*DISTINGUISHER_LEAP),
    inst_wb     : DUTHook('sodor5_verif.coretop.core.d.exe_reg_inst', -2*DISTINGUISHER_LEAP)
}

# ('coretop.core.d.io_imem_resp_bits_data[31:0]', 0)
# ('coretop.core.d.dec_reg_inst[31:0]', 0)
# ('coretop.core.d.exe_reg_inst[31:0]', 0)
# ('coretop.core.d.exe_reg_inst[31:0]', -1*LEAP)
# ('coretop.core.d.exe_reg_inst[31:0]', -2*LEAP)

def make_testblock_by_program(instructions):
    return sodor5_testblock.make_testblock_by_program(instructions, ITYPE)
def make_testblock_by_seed(seed):
    return sodor5_testblock.make_testblock_by_seed(seed, ITYPE)
def make_distinguishblock_by_prepost(assumes, block, asserts):
    return sodor5_testblock.make_distinguish_block(DISTINGUISHER_INSERTION_CYCLE, assumes, block, asserts)

sodor5_ilstype_config = ProcessorConfig(
    NAME="sodor5_ilstype",
    PARENT_DIR=PARENT_DIR,
    VCDFILE=VCDFILE,
    TBFILE=f"{SIMULATION_DIR}/sodor5/sodor5_verif_{ITYPE}type_tb.v",
    TBVCD=f"{SIMULATION_DIR}/{VCDFILE}",
    SIMULATION_DIR=SIMULATION_DIR,
    SIMULATION_COMMAND=f"make sodor5_verif_{ITYPE}type_tb_run",
    BASE_CYCLE=10, MAX_CYCLE=30, LEAP=LEAP,
    DISTINGUISHER_VCD=DISTINGUISHER_VCD,
    DISTINGUISHER_DIR=DISTINGUISHER_DIR,
    DISTINGUISHER_FILE=DISTINGUISHER_FILE,
    DISTINGUISHER_COMMAND=DISTINGUISHER_COMMAND,
    DISTINGUISHER_INSERTION_CYCLE=DISTINGUISHER_INSERTION_CYCLE,
    DISTINGUISHER_LEAP=DISTINGUISHER_LEAP,
    basename_mapping=basename_mapping,
    dut_basename_mapping=dut_basename_mapping,
    dut_basename_mapping_dist=dut_basename_mapping_dist,
    dut_isig_basename_mapping=dut_isig_basename_mapping,
    dut_isig_basename_mapping_dist=dut_isig_basename_mapping_dist,
    TRANSACTIONS=[
        # gen_decode_i_imm,
        # gen_decode_b_imm,
        # gen_decode_s_imm,
        # gen_decode_rs1_addr,
        # gen_decode_rs2_addr,
        # gen_decode_rd_addr,
        gen_decode_all,
        # feed__imm__reg_rd_data_in,
        feed__dec_wbaddr__exe_reg_wbaddr,
        zero__exe_reg_wbaddr,
        feed__exe_reg_wbaddr__mem_reg_wbaddr,
        feed__mem_reg_wbaddr__reg_rd_addr_in,
        # feed__reg_rs1_data_out__reg_rd_data_in,
        # feed__reg_rs2_data_out__reg_rd_data_in,
        # feed__alu_out__reg_rd_data_in,
        feed__alu_out__mem_reg_alu_out,
        feed__mem_reg_alu_out__reg_rd_data_in,
        # regs1_read,
        # regs2_read,
        regs_read,
        regs_write,
        no_regs_write,
        lb_invalidate,
        lb_refill,
        lb_hold,
        feed__reg_rs1_data_out__alu_op1,
        feed__alu_out__alu_op1,
        feed__mem_reg_alu_out__alu_op1,
        feed__reg_rd_data_in__alu_op1,
        feed__imm_i__alu_op2,
        feed__imm_s__alu_op2,
        feed__mem_data__alu_op1,
        alu_compute_comb,
        pipeline_hold,
        feed__mem_resp__reg_rd_data_in,
        # feed__lb_table__reg_rd_data_in,
        # flush_decode,
        hold_decode
    ],
    PREDICATES=[
        # Pipeline hold, exe, rd, mem stages
        # is_4033_mem, is_load_mem, is_store_mem, mem_resp_valid, lb_match, (data_rs1dep_dec_exe & ~reads1_from_zero_dec)
        # ((is_load_mem & ~lb_match) | is_store_mem), (~mem_resp_valid), (data_rs1dep_dec_exe & ~reads1_from_zero_dec) | (data_rs2dep_dec_exe & ~reads2_from_zero_dec & is_store_dec), is_load_exe

        # LB transactions:
        # is_load_mem, is_store_mem, mem_resp_valid

        # Regfile
        # is_4033_wb, is_load_wb, is_store_wb, writes_to_zero_wb

        # Decode
        # is_load_mem, is_store_mem, mem_resp_valid, (data_rs1dep_dec_exe & ~reads1_from_zero_dec & itype_dec & is_load_exe)
        # Correct combination:
        # is_load_mem, ~lb_match, is_store_mem, (~mem_resp_valid), (data_rs1dep_dec_exe & ~reads1_from_zero_dec), is_load_exe

        # Regfile read
        # alui_dec, is_load_dec, is_store_dec,

        # ALU OP1
        # (data_rs1dep_dec_exe & ~reads1_from_zero_dec), (~data_rs1dep_dec_exe & data_rs1dep_dec_mem & ~reads1_from_zero_dec), (~data_rs1dep_dec_exe & ~data_rs1dep_dec_mem & data_rs1dep_dec_wb & ~reads1_from_zero_dec), is_load_mem, 
        # (((is_load_mem & ~lb_match) | is_store_mem) & ~mem_resp_valid) | (is_load_exe & (((data_rs1dep_dec_exe & ~reads1_from_zero_dec) & (itype_dec)) |
        #     (((data_rs1dep_dec_exe & ~reads1_from_zero_dec) |  (data_rs2dep_dec_exe & ~reads2_from_zero_dec)) & is_store_dec))
        # )

        # ALU OP2
        (is_load_dec), is_store_dec, alui_dec, (((((is_load_mem & ~lb_match) | is_store_mem) & ~mem_resp_valid) | (is_load_exe & (((data_rs1dep_dec_exe & ~reads1_from_zero_dec) & (itype_dec)) |
            (((data_rs1dep_dec_exe & ~reads1_from_zero_dec) |  (data_rs2dep_dec_exe & ~reads2_from_zero_dec)) & is_store_dec))
        )))

        # is_store_wb,
        # writes_to_zero_wb,
        # is_load_exe,
        # is_4033_mem, 
        # is_load_wb,
        # mem_resp_valid,
        # (data_rs1dep_dec_mem & ~reads1_from_zero_dec),
        # (data_rs1dep_dec_wb & ~reads1_from_zero_dec)
        # lb_match,
        # oracle
    ],
    make_testblock_by_program=make_testblock_by_program,
    make_testblock_by_seed=make_testblock_by_seed,
    make_distinguishblock_by_prepost=make_distinguishblock_by_prepost
)
