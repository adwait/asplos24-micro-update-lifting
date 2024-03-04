
from random import random, shuffle
from aul.processor_config import ProcessorConfig
from aul.moplib import MopBehaviour, Mop, Signal, SignalConnect, SignalSig, Assignment, ISignal, DUTHook
from aul.veriloggen import VArraySelect, VBAssignment, VBVConst, VBases, VLiteral, VStmtSeq
from aul.predicate import Predicate
from aul.utils import UNCONSTRAINED

import os

from aul.cva6_configs import cva6_tlb_testblock

# =====================
# Define signals
# =====================
# Valid bits
content = Signal("content", SignalSig(2, 33, SignalConnect.CSIG, 'x'))
tags = Signal("tags", SignalSig(2, 32, SignalConnect.CSIG, 'x'))

cdata = Signal("cdata", SignalSig(None, 32, SignalConnect.DSIG, 'x'))
tdata = Signal("tdata", SignalSig(None, 31, SignalConnect.DSIG, 'x'))

magic = Signal("magic", SignalSig(None, 2, SignalConnect.DSIG, 'x'))

# Mapping between signal and the name in the AUM
basename_mapping = {
    content : "content_q",
    tags    : "tags_q",
    cdata   : "cdata",
    tdata   : "tdata",
    magic   : "magic"
}

def sim_flush_all(assignmentmap: Assignment):
    assignmentmap[tags][0] = (assignmentmap[tags][0] >> 1) << 1
    assignmentmap[tags][1] = (assignmentmap[tags][1] >> 1) << 1
    assignmentmap[tags][2] = (assignmentmap[tags][2] >> 1) << 1
    assignmentmap[tags][3] = (assignmentmap[tags][3] >> 1) << 1
    return assignmentmap
def sim_update(assignmentmap: Assignment):
    assignmentmap[content][assignmentmap[magic]] = assignmentmap[cdata]
    assignmentmap[tags][assignmentmap[magic]] = assignmentmap[tdata]
    return assignmentmap
def sim_flush_one(assignmentmap: Assignment):
    assignmentmap[tags][assignmentmap[magic]] = (assignmentmap[tags][assignmentmap[magic]] >> 1) << 1
    return assignmentmap
def sim_none(assignmentmap: Assignment):
    return assignmentmap

gen_flush_all = Mop("gen_flush_all", sim_flush_all,
    [tags, content], [tags, content], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(VArraySelect(new_map[tags], [VLiteral('0')]), VBVConst("0", 1, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[tags], [VLiteral('31')]), VBVConst("0", 1, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[tags], [VLiteral('62')]), VBVConst("0", 1, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[tags], [VLiteral('93')]), VBVConst("0", 1, VBases.BIN))
    ])
    )
gen_update = Mop("gen_update", sim_update,
    [magic, content, tags], [content, tags], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(VArraySelect(new_map[tags], [pre_map[magic]]), pre_map[tdata]),
        VBAssignment(VArraySelect(new_map[content], [pre_map[magic]]), pre_map[cdata])
    ])
    )
gen_flush_one = Mop("gen_flush_one", sim_flush_one,
    [magic, tags, content], [tags, content], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(
        VArraySelect(VArraySelect(new_map[tags], [pre_map[magic]]), [VLiteral('0')]), VBVConst('0', 1, VBases.BIN)
    )
    )
gen_none = Mop("gen_none", sim_none,
    [tags, content], [content, tags], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(new_map[tags], pre_map[tags]),
        VBAssignment(new_map[content], pre_map[content])
    ])
    )
    

LEAP        = 20
PARENT_DIR  = "cva6-model"
SIMULATION_DIR  = f"{PARENT_DIR}"
VCDFILE     = "tlb_wave_pipeline.vcd"

# Distinguisher macros and hooks
# TODO: distinguisher not defined
DISTINGUISHER_LEAP              = 10
DISTINGUISHER_INSERTION_CYCLE   = 7
DISTINGUISHER_DIR   = f"{SIMULATION_DIR}/verification"
DISTINGUISHER_FILE  = f"{SIMULATION_DIR}/verification/tlb/cva6_tlb_distinguisher.v"
DISTINGUISHER_COMMAND   = "time sby -f dist.sby taskBMC12_distinguish_tlb"
DISTINGUISHER_VCD       = f"{DISTINGUISHER_DIR}/dist_taskBMC12_distinguish_tlb/engine_0/trace.vcd"

# Defing mapping from signals to elements in the DUT
dut_basename_mapping = {
    content : ['tlb_tb.tlb_i.content_q_{}[31:0]'.format(i) for i in range(4)],
    tags    : ['tlb_tb.tlb_i.tags_q_{}[30:0]'.format(i) for i in range(4)],
    tdata   : 'tlb_tb.tdata[30:0]',
    cdata   : 'tlb_tb.cdata[31:0]',
    # Magic is unconstrained
    magic   : UNCONSTRAINED
}
# Need to add
dut_basename_mapping_dist = {
    content : ['tlb_tb.tlb_i.content_q_{}'.format(i) for i in range(4)],
    tags    : ['tlb_tb.tlb_i.tags_q_{}'.format(i) for i in range(4)],
    tdata   : 'tlb_tb.tdata',
    cdata   : 'tlb_tb.cdata',
    # Magic is unconstrained
    magic   : UNCONSTRAINED
}

update = ISignal("update", 63)
flush = ISignal("flush", 1)

dut_isig_basename_mapping = {
    update : DUTHook('tlb_tb.tlb_i.update_i[62:0]', 1*LEAP),
    flush  : DUTHook('tlb_tb.tb_io_flush_i', 1*LEAP)
}
dut_isig_basename_mapping_dist = {
    update  : DUTHook('tlb_tb.tb_io_update_i', 0),
    flush   : DUTHook('tlb_tb.tb_io_flush_i', 0)
}

is_flush = Predicate("is_flush", 
    lambda frame: frame["flush"] == 1,
    lambda frame: "(= {} #b1)".format(frame["flush"])
)
is_update = Predicate("is_update", 
    lambda frame: frame["update"] >> 62 == 1,
    lambda frame: "(= ((_ extract 62 62) {}) #b1)".format(frame["update"])
)

def make_testblock_by_program(instructions):
    return cva6_tlb_testblock.make_testblock_by_program(instructions)
def make_testblock_by_seed(seed):
    return cva6_tlb_testblock.make_testblock_by_seed(seed)
def make_distinguishblock_by_prepost(assumes, block, asserts):
    return cva6_tlb_testblock.make_distinguish_block(DISTINGUISHER_INSERTION_CYCLE, assumes, block, asserts)

cva6_tlb_config = ProcessorConfig(
    NAME="cva6_tlb",
    PARENT_DIR=PARENT_DIR,
    VCDFILE=VCDFILE,
    TBFILE=f"{SIMULATION_DIR}/rtl/cva6_tlb_tb.v",
    TBVCD=f"{SIMULATION_DIR}/{VCDFILE}",
    SIMULATION_DIR=SIMULATION_DIR,
    SIMULATION_COMMAND="make tlb_tb_run",
    BASE_CYCLE=4, MAX_CYCLE=10, LEAP=LEAP,
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
        gen_flush_all, gen_update, gen_none
    ],
    PREDICATES=[
        is_flush, is_update
    ],
    make_testblock_by_program=make_testblock_by_program,
    make_testblock_by_seed=make_testblock_by_seed,
    make_distinguishblock_by_prepost=make_distinguishblock_by_prepost
)
