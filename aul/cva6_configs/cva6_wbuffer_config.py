
from random import shuffle, randint, choices
from aul.processor_config import ProcessorConfig
from aul.moplib import MopBehaviour, Mop, Signal, SignalConnect, SignalSig, Assignment, ISignal, DUTHook
from aul.predicate import Predicate
from aul.veriloggen import VArraySelect, VBAssignment, VBVConst, VBases, VITE, VOpExpr, VStmtSeq, VLiteral
from aul.cva6_configs import cva6_wbuffer_testblock

# =====================
# Define signals
# =====================
wbuffer = Signal("wbuffer", SignalSig(3, 3, SignalConnect.CSIG, 'x'))
write_ptr = Signal("write_ptr", SignalSig(None, 3, SignalConnect.DSIG, 'x'))
redo_ptr = Signal("redo_ptr", SignalSig(None, 3, SignalConnect.DSIG, 'x'))
mem_ack_ptr = Signal("mem_ack_ptr", SignalSig(None, 3, SignalConnect.DSIG, 'x'))
mem_resp_ptr = Signal("mem_resp_ptr", SignalSig(None, 3, SignalConnect.DSIG, 'x'))

basename_mapping = {
    wbuffer : "wbuffer_summary",
    write_ptr : "write_ptr",
    redo_ptr : "redo_ptr",
    mem_ack_ptr : "mem_ack_ptr",
    mem_resp_ptr : "mem_resp_ptr"
}

def sim_write_req(assignmentmap: Assignment):
    if assignmentmap[wbuffer][assignmentmap[write_ptr]] == int("000", 2):
        assignmentmap[wbuffer][assignmentmap[write_ptr]] = int("110", 2)
    else:
        assignmentmap[wbuffer][assignmentmap[write_ptr]] = -1
    return assignmentmap
def sim_redo_write_req(assignmentmap: Assignment):
    if assignmentmap[wbuffer][assignmentmap[redo_ptr]] == int("011", 2):
        assignmentmap[wbuffer][assignmentmap[redo_ptr]] = int("111", 2)
    else:
        assignmentmap[wbuffer][assignmentmap[redo_ptr]] = -1
    return assignmentmap
def sim_mem_ack(assignmentmap: Assignment):
    if assignmentmap[wbuffer][assignmentmap[mem_ack_ptr]] == int("110", 2):
        assignmentmap[wbuffer][assignmentmap[mem_ack_ptr]] = int("011", 2)
    else:
        assignmentmap[wbuffer][assignmentmap[mem_ack_ptr]] = -1
    return assignmentmap
def sim_mem_resp(assignmentmap: Assignment):
    if assignmentmap[wbuffer][assignmentmap[mem_resp_ptr]] == int("011", 2):
        assignmentmap[wbuffer][assignmentmap[mem_resp_ptr]] = int("000", 2)
    elif assignmentmap[wbuffer][assignmentmap[mem_resp_ptr]] == int("111", 2):
        assignmentmap[wbuffer][assignmentmap[mem_resp_ptr]] = int("110", 2)
    else:
        assignmentmap[wbuffer][assignmentmap[mem_resp_ptr]] = -1
    return assignmentmap
def sim_none(assignmentmap: Assignment):
    return assignmentmap

gen_write_req = Mop("gen_write_req", sim_write_req,
    [write_ptr, wbuffer], [wbuffer], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VITE(VOpExpr("eq",  [VArraySelect(pre_map[wbuffer], [pre_map[write_ptr]]), VBVConst("000", 3, VBases.BIN)]), 
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[write_ptr]]), VBVConst("110", 3, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[write_ptr]]), VBVConst("100", 3, VBases.BIN))))
gen_redo_write_req = Mop("gen_redo_write_req", sim_redo_write_req,
    [redo_ptr, wbuffer], [wbuffer], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VITE(VOpExpr("eq",  [VArraySelect(pre_map[wbuffer], [pre_map[redo_ptr]]), VBVConst("011", 3, VBases.BIN)]), 
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[redo_ptr]]), VBVConst("111", 3, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[redo_ptr]]), VBVConst("100", 3, VBases.BIN))))
gen_mem_ack = Mop("gen_mem_ack", sim_mem_ack,
    [mem_ack_ptr, wbuffer], [wbuffer], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VITE(VOpExpr("eq",  [VArraySelect(pre_map[wbuffer], [pre_map[mem_ack_ptr]]), VBVConst("110", 3, VBases.BIN)]), 
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[mem_ack_ptr]]), VBVConst("011", 3, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[mem_ack_ptr]]), VBVConst("100", 3, VBases.BIN))))
gen_mem_resp = Mop("gen_mem_resp", sim_mem_resp,
    [mem_resp_ptr, wbuffer], [wbuffer], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VITE(VOpExpr("eq",  [VArraySelect(pre_map[wbuffer], [pre_map[mem_resp_ptr]]), VBVConst("011", 3, VBases.BIN)]), 
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[mem_resp_ptr]]), VBVConst("000", 3, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[wbuffer], [pre_map[mem_resp_ptr]]), VBVConst("110", 3, VBases.BIN))))
gen_none = Mop("gen_none", sim_none,
    [wbuffer], [wbuffer], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VStmtSeq([
        VBAssignment(VArraySelect(new_map[wbuffer], [VLiteral(int(i))]), VArraySelect(pre_map[wbuffer], [VLiteral(int(i))]))
            for i in range(8)
    ]))


ITYPE       = "i"
LEAP        = 20
PARENT_DIR  = "cva6-model"
SIMULATION_DIR  = f"{PARENT_DIR}"
VCDFILE     = "wbuffer_model_wave_pipeline.vcd"

# Defing mapping from signals to elements in the DUT
dut_basename_mapping = {
    wbuffer             : ['wbuffer_tb.wbuffer_data_o_{}[2:0]'.format(i) for i in range(8)],
    # Magic is unconstrained
    write_ptr           : 'wbuffer_tb.wbuffer_i.write_ptr_o[2:0]',
    redo_ptr           : 'wbuffer_tb.wbuffer_i.redo_ptr_o[2:0]',
    mem_ack_ptr           : 'wbuffer_tb.wbuffer_i.mem_ack_ptr_o[2:0]',
    mem_resp_ptr           : 'wbuffer_tb.wbuffer_i.mem_resp_ptr_o[2:0]'
}

prev_index  = [ISignal(f"prev_index_{i}", 12) for i in range(4)]
prev_valid  = [ISignal(f"prev_valid_{i}", 1) for i in range(4)]
prev_dirty  = [ISignal(f"prev_dirty_{i}", 1) for i in range(4)]
req_valid   = ISignal("req_valid", 1)
req_index   = ISignal("req_index", 12)
miss_ack    = ISignal("miss_ack", 1)
rtrn_vld    = ISignal("rtrn_vld", 1)

dut_isig_basename_mapping = {
    **{prev_index[i]: DUTHook(f"wbuffer_tb.prev_index_{i}[11:0]", 0) for i in range(4)},
    **{prev_valid[i]: DUTHook(f"wbuffer_tb.prev_valid_{i}", 0) for i in range(4)},
    **{prev_dirty[i]: DUTHook(f"wbuffer_tb.prev_dirty_{i}", 0) for i in range(4)},
    req_valid: DUTHook("wbuffer_tb.req_enabled", 0),
    req_index: DUTHook("wbuffer_tb.req_index[11:0]", 0),
    miss_ack: DUTHook("wbuffer_tb.tb_io_miss_ack_i", 0),
    rtrn_vld: DUTHook("wbuffer_tb.tb_io_miss_rtrn_vld_i", -1*LEAP)
}

req_on_addr = Predicate("req_on_addr", 
    lambda frame: any([(frame[f"prev_index_{i}"] == frame["req_index"] 
        and frame[f"prev_valid_{i}"]) for i in range(4)]),
    lambda frame: "(or {})".format(' '.join(
        ["(and ({}) (= {} {}))".format(
            frame[f"prev_valid_{i}"], frame[f"prev_index_{i}"], frame["req_index"])
            for i in range(4)]))
    )
req_is_valid = Predicate("req_is_valid", 
    lambda frame: frame["req_valid"] == 1,
    lambda frame: "(= {} #b1)".format(frame["req_valid"])
    )
miss_is_valid = Predicate("miss_is_valid",
    lambda frame: frame["miss_ack"] == 1,
    lambda frame: "(= {} #b1)".format(frame["miss_ack"])
    )
rtrn_on_addr = Predicate("rtrn_on_addr",
    lambda frame: any([(frame[f"prev_index_{i}"] == frame["req_index"] 
        and frame[f"prev_dirty_{i}"]) for i in range(4)]),
    lambda frame: "(or {})".format(' '.join(
        ["(and ({}) (= {} {}))".format(
            frame[f"prev_dirty_{i}"], frame[f"prev_index_{i}"], frame["req_index"])
            for i in range(4)]))
    )
rtrn_is_valid = Predicate("rtrn_is_valid",
    lambda frame: frame["rtrn_vld"] == 1,
    lambda frame: "(= {} #b1)".format(frame["rtrn_vld"])
    )

def make_testblock_by_seed(seed):
    # ops = [[i]*(randint(0, 1)+2) for i in range(1,5)] + [[0]]*20
    # shuffle(ops)
    # ops = [op for l in ops for op in l]
    ops = choices(range(1, 5), k=4) + [0]*20
    shuffle(ops)
    return cva6_wbuffer_testblock.make_testblock_by_ops_model(ops, seed)

cva6_wbuffer_config = ProcessorConfig(
    NAME="cva6_wbuffer",
    PARENT_DIR=PARENT_DIR,
    VCDFILE=VCDFILE,
    TBFILE=f"{SIMULATION_DIR}/rtl/cva6_wbuffer_model_tb.v",
    TBVCD=f"{SIMULATION_DIR}/{VCDFILE}",
    SIMULATION_DIR=SIMULATION_DIR,
    SIMULATION_COMMAND="make wbuffer_model_tb_run",
    BASE_CYCLE=3, MAX_CYCLE=50, LEAP=LEAP,
    DISTINGUISHER_VCD=None,
    DISTINGUISHER_DIR=None,
    DISTINGUISHER_FILE=None,
    DISTINGUISHER_COMMAND=None,
    DISTINGUISHER_INSERTION_CYCLE=None,
    DISTINGUISHER_LEAP=None,
    basename_mapping=basename_mapping,
    dut_basename_mapping=dut_basename_mapping,
    dut_basename_mapping_dist=None,
    dut_isig_basename_mapping=dut_isig_basename_mapping,
    dut_isig_basename_mapping_dist=None,
    TRANSACTIONS=[
        gen_write_req, gen_redo_write_req, gen_mem_ack, gen_mem_resp, gen_none
    ],
    PREDICATES=[
        rtrn_is_valid, 
        miss_is_valid, req_on_addr, req_is_valid  
    ],
    make_testblock_by_program=None,
    make_testblock_by_seed=make_testblock_by_seed,
    make_distinguishblock_by_prepost=None
)
