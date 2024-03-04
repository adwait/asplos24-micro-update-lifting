

from aul.processor_config import ProcessorConfig
from aul.moplib import SignalSig, SignalConnect, Signal, Mop, Assignment, MopBehaviour, ISignal, DUTHook
from aul.predicate import Predicate

from aul.veriloggen import VArraySelect, VBAssignment, VBVConst, VBases, VLiteral, VStmtSeq

from aul.cva6_configs import cva6_lsu_testblock



store_queue = Signal("store_queue", SignalSig(2, 33, SignalConnect.CSIG, 'x'))
store_ptr   = Signal("store_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))
commit_ptr  = Signal("commit_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))
serve_ptr   = Signal("serve_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))

store_state_q   = Signal("store_state_q", SignalSig(2, 2, SignalConnect.CSIG, 'x'))

load_state      = Signal("load_state", SignalSig(None, 2, SignalConnect.CSIG, 'x'))

instr_i         = Signal("instr_i", SignalSig(None, 32, SignalConnect.DSIG, 'x'))
page_offset     = Signal("page_offset", SignalSig(None, 12, SignalConnect.DSIG, 'x'))

basename_mapping = {
    load_state      : "load_state",
    instr_i         : "instr_i"
}

LEAP        = 20
PARENT_DIR  = "cva6-model"
SIMULATION_DIR  = f"{PARENT_DIR}"
VCDFILE     = "lsu_model_wave_pipeline.vcd"


# Defining mapping from signals to elements in the DUT
dut_basename_mapping = {
    instr_i     : 'cva6_lsu_model_tb.model_i.x_inner_instr_i[31:0]',
    load_state  : 'cva6_lsu_model_tb.shim_i.lsu_i.i_load_unit.state_q[1:0]'
}

def set_state_commit(assignmentmap: Assignment):
    assignmentmap[store_state_q][assignmentmap[commit_ptr]] = 1
    return assignmentmap

def set_state_serve(assignmentmap: Assignment):
    assignmentmap[store_state_q][assignmentmap[serve_ptr]] = 0
    return assignmentmap

def set_state_store(assignmentmap: Assignment):
    assignmentmap[store_state_q][assignmentmap[store_ptr]] = 3
    return assignmentmap

def update_commit_ptr(assignmentmap: Assignment):
    assignmentmap[commit_ptr] = (assignmentmap[commit_ptr] + 1) % 4
    return assignmentmap

def update_serve_ptr(assignmentmap: Assignment):
    assignmentmap[serve_ptr] = (assignmentmap[serve_ptr] + 1) % 4
    return assignmentmap

def make_store(assignmentmap: Assignment):
    assignmentmap[store_queue][assignmentmap[store_ptr]] = assignmentmap[instr_i]
    assignmentmap[store_ptr] = (assignmentmap[store_ptr] + 1) % 4
    return assignmentmap

gen_commit_ptr_update = Mop("update_commit_ptr", update_commit_ptr,
    [commit_ptr], [commit_ptr], MopBehaviour.SEQ,
    lambda new_map, pre_map: VBAssignment(new_map[commit_ptr], pre_map[commit_ptr] + VBVConst(1, 2, VBases.BIN))
    )
gen_commit_ptr_non_update = Mop("non_update_commit_ptr", lambda assignmentmap: assignmentmap,
    [commit_ptr], [commit_ptr], MopBehaviour.SEQ,
    lambda new_map, pre_map: VBAssignment(new_map[commit_ptr], pre_map[commit_ptr])
    )
gen_serve_ptr_update = Mop("update_serve_ptr", update_serve_ptr,
    [serve_ptr], [serve_ptr], MopBehaviour.SEQ,
    lambda new_map, pre_map: VBAssignment(new_map[serve_ptr], pre_map[serve_ptr] + VBVConst(1, 2, VBases.BIN))
    )
gen_serve_ptr_non_update = Mop("non_update_serve_ptr", lambda assignmentmap: assignmentmap,
    [serve_ptr], [serve_ptr], MopBehaviour.SEQ,
    lambda new_map, pre_map: VBAssignment(new_map[serve_ptr], pre_map[serve_ptr])
    )
gen_make_store = Mop("gen_make_store", make_store,
        [store_queue, store_ptr], [store_queue, store_ptr], MopBehaviour.SEQ,
        lambda new_map, pre_map:
        VStmtSeq([
            VBAssignment(VArraySelect(new_map[store_queue], [pre_map[store_ptr]]), pre_map[instr_i]),
            VBAssignment(new_map[store_ptr], pre_map[store_ptr] + VBVConst(1, 2, VBases.BIN))
        ])
    )
gen_store_non_update = Mop("gen_store_non_update", lambda assignmentmap: assignmentmap,
        [store_queue, store_ptr], [store_queue, store_ptr], MopBehaviour.SEQ,
        lambda new_map, pre_map: VStmtSeq([])
    )

gen_set_state_commit = Mop("gen_set_state_commit", set_state_commit,
    [store_state_q, commit_ptr], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[commit_ptr]]), VBVConst(1, 2, VBases.BIN))
    )
gen_set_state_serve = Mop("gen_set_state_serve", set_state_serve,
    [store_state_q, serve_ptr], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    )
gen_set_state_store = Mop("gen_set_state_store", set_state_store,
    [store_state_q, store_ptr], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[store_ptr]]), VBVConst(3, 2, VBases.BIN))
    )
gen_set_state_store_serve = Mop("gen_set_state_store_serve", lambda assignmentmap: set_state_serve(set_state_store(assignmentmap)),
    [store_state_q, store_ptr, serve_ptr], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([
        VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[store_ptr]]), VBVConst(3, 2, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    ])
    )
gen_set_state_commit_serve = Mop("gen_set_state_commit_serve", lambda assignmentmap: set_state_serve(set_state_commit(assignmentmap)),
    [store_state_q, commit_ptr, serve_ptr], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([
        VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[commit_ptr]]), VBVConst(1, 2, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[store_state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    ])
    )
gen_set_state_none = Mop("gen_set_state_none", lambda assignmentmap: assignmentmap,
    [store_state_q], [store_state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([])
    )

def update_load_state(k):
    def update_load_q_(assignmentmap: Assignment):
        assignmentmap[load_state] = k
        return assignmentmap
    return update_load_q_

gen_set_load_state_0 = Mop("gen_set_load_state_0", update_load_state(0),
        [load_state], [load_state], MopBehaviour.SEQ,
        lambda new_map, pre_map: VBAssignment(new_map[load_state], VBVConst(0, 3))
    )
gen_set_load_state_1 = Mop("gen_set_load_state_1", update_load_state(1),
        [load_state], [load_state], MopBehaviour.SEQ,
        lambda new_map, pre_map: VBAssignment(new_map[load_state], VBVConst(1, 3))
    )
gen_set_load_state_2 = Mop("gen_set_load_state_2", update_load_state(2),
        [load_state], [load_state], MopBehaviour.SEQ,
        lambda new_map, pre_map: VBAssignment(new_map[load_state], VBVConst(2, 3))
    )
gen_set_load_state_3 = Mop("gen_set_load_state_3", update_load_state(3),
        [load_state], [load_state], MopBehaviour.SEQ,
        lambda new_map, pre_map: VBAssignment(new_map[load_state], VBVConst(3, 3))
    )
gen_set_load_state_none = Mop("gen_set_load_state_none", lambda assignmentmap: assignmentmap,
        [load_state], [load_state], MopBehaviour.SEQ,
        lambda new_map, pre_map: VStmtSeq([])
    )


instr_valid_i = ISignal("instr_valid_i", 1)
commit_i = ISignal("commit_i", 1)
store_mem_resp_i = ISignal("store_mem_resp_i", 1)
store_state_q_i = [ISignal("queue_state_{}".format(i), 2) for i in range(4)]
serve_ptr_i = ISignal("serve_ptr_i", 2)

is_store_i = ISignal("is_store_i", 1)
l_instr_valid_i = ISignal("l_instr_valid_i", 1)
load_state_i = ISignal("load_state_i", 2)
load_mem_resp_i = ISignal("load_mem_resp_i", 1)

no_dep_i = ISignal("no_dep_i", 1)

dut_isig_basename_mapping = {
    instr_valid_i   : DUTHook('cva6_lsu_model_tb.tb_io_instr_valid_i', -1*LEAP),
    commit_i        : DUTHook('cva6_lsu_model_tb.tb_io_store_commit_i', 1*LEAP),
    store_mem_resp_i    : DUTHook('cva6_lsu_model_tb.tb_io_store_mem_resp_i', 0),
    **{
        store_state_q_i[i] : DUTHook('cva6_lsu_model_tb.shim_i.lsu_i.i_store_unit.store_buffer_i.state_q_{}[1:0]'.format(i), 0)
            for i in range(4)
    },
    serve_ptr_i     : DUTHook('cva6_lsu_model_tb.shim_i.lsu_i.i_store_unit.store_buffer_i.commit_read_pointer_q[1:0]', 0),
    
    is_store_i      : DUTHook('cva6_lsu_model_tb.tb_io_is_load_i', -1*LEAP),
    load_state_i    : DUTHook('cva6_lsu_model_tb.shim_i.lsu_i.i_load_unit.state_q[1:0]', 0),
    l_instr_valid_i : DUTHook('cva6_lsu_model_tb.tb_io_instr_valid_i', 0),
    load_mem_resp_i : DUTHook('cva6_lsu_model_tb.tb_io_load_mem_resp_i', 0),
    no_dep_i        : DUTHook('cva6_lsu_model_tb.model_i.no_dep', 0)
}

instr_valid_p = Predicate("instr_valid_p",
    lambda frame: frame["instr_valid_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["instr_valid_i"])
)
commit_p = Predicate("commit_p",
    lambda frame: frame["commit_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["commit_i"])
)
store_mem_resp_p = Predicate("store_mem_resp_p",
    lambda frame: frame["store_mem_resp_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["store_mem_resp_i"])
)
is_store_p = Predicate("is_store_p",
    lambda frame: frame["is_store_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["is_store_i"])
)

commit_ready_preds = []
for j in range(4):
    func = (lambda frame, k=j: [frame["queue_state_{}".format(i)] for i in range(4)][frame["serve_ptr_i"]] == k)
    commit_ready_preds.append(Predicate("commit_ready_preds_{}".format(j), func, None))

load_state_preds = []
for j in range(4):
    func = (lambda frame, k=j: frame["load_state_i"] == k)
    load_state_preds.append(Predicate("load_state_preds_{}".format(j), func, None))
l_instr_valid_p = Predicate("l_instr_valid_p",
    lambda frame: frame["l_instr_valid_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["l_instr_valid_i"])
)
load_mem_resp_p = Predicate("load_mem_resp_p",
    lambda frame: frame["load_mem_resp_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["load_mem_resp_i"])
)
no_dep_p = Predicate("no_dep_p",
    lambda frame: frame["no_dep_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["no_dep_i"])
)

def make_testblock_by_seed(seed):
    return cva6_lsu_testblock.make_testblock_by_seed(seed)

cva6_lsu_config = ProcessorConfig(
    NAME="cva6_lsu",
    PARENT_DIR=PARENT_DIR,
    VCDFILE=VCDFILE,
    TBFILE=f"{SIMULATION_DIR}/rtl/cva6_lsu_model_tb.v",
    TBVCD=f"{SIMULATION_DIR}/{VCDFILE}",
    SIMULATION_DIR=SIMULATION_DIR,
    SIMULATION_COMMAND="make load_store_unit_model_tb_build; ./load_store_unit_model_tb",
    BASE_CYCLE=4, MAX_CYCLE=20, LEAP=LEAP,
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
        gen_set_load_state_0,
        gen_set_load_state_1,
        gen_set_load_state_2,
        gen_set_load_state_3,
        gen_set_load_state_none
    ],
    PREDICATES=[
        instr_valid_p,
        load_mem_resp_p,
        l_instr_valid_p,
        no_dep_p
    ] + load_state_preds
    ,
    make_testblock_by_program=None,
    make_testblock_by_seed=make_testblock_by_seed,
    make_distinguishblock_by_prepost=None,
    PREF_ORDER=[
    ] + [
        (gen_set_load_state_none, i) for i in [gen_set_load_state_0, gen_set_load_state_1, gen_set_load_state_2, gen_set_load_state_3]
    ],
    INDEPENDENCES=[
    ]
)

