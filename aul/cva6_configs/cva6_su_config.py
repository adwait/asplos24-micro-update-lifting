

from aul.processor_config import ProcessorConfig, PrefOrder
from aul.moplib import SignalSig, SignalConnect, Signal, Mop, Assignment, MopBehaviour, ISignal, DUTHook
from aul.predicate import Predicate

from aul.veriloggen import VArraySelect, VBAssignment, VBVConst, VBases, VLiteral, VStmtSeq

from aul.cva6_configs import cva6_su_testblock



store_q = Signal("store_q", SignalSig(2, 33, SignalConnect.CSIG, 'x'))
store_ptr = Signal("store_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))
commit_ptr = Signal("commit_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))
serve_ptr = Signal("serve_ptr", SignalSig(None, 2, SignalConnect.CSIG, 'x'))

state_q = Signal("state_q", SignalSig(2, 2, SignalConnect.CSIG, 'x'))
instr_i = Signal("instr_i", SignalSig(None, 32, SignalConnect.DSIG, 'x'))


basename_mapping = {
    store_q     : "store_q",
    store_ptr   : "store_ptr",
    commit_ptr  : "commit_ptr",
    serve_ptr   : "serve_ptr",
    state_q     : "state_q",
    instr_i     : "instr_i"
}

LEAP        = 20
PARENT_DIR  = "cva6-model"
SIMULATION_DIR  = f"{PARENT_DIR}"
VCDFILE     = "su_model_wave_pipeline.vcd"


# Defining mapping from signals to elements in the DUT
dut_basename_mapping = {
    store_q     : ['store_unit_model_tb.su_i.store_buffer_i.speculative_queue_q[{}:{}]'.format(73*(i+1)-1, 73*(i+1)-34) for i in range(4)],
    store_ptr   : 'store_unit_model_tb.su_i.store_buffer_i.speculative_write_pointer_q[1:0]',
    commit_ptr  : 'store_unit_model_tb.su_i.store_buffer_i.speculative_read_pointer_q[1:0]',
    serve_ptr   : 'store_unit_model_tb.su_i.store_buffer_i.commit_read_pointer_q[1:0]',
    instr_i     : 'store_unit_model_tb.de_io_instr_i[31:0]',
    state_q     : ['store_unit_model_tb.su_i.store_buffer_i.state_q_{}[1:0]'.format(i) for i in range(4)]
}

def set_state_commit(assignmentmap: Assignment):
    assignmentmap[state_q][assignmentmap[commit_ptr]] = 1
    return assignmentmap

def set_state_serve(assignmentmap: Assignment):
    assignmentmap[state_q][assignmentmap[serve_ptr]] = 0
    return assignmentmap

def set_state_store(assignmentmap: Assignment):
    assignmentmap[state_q][assignmentmap[store_ptr]] = 3
    return assignmentmap

def update_commit_ptr(assignmentmap: Assignment):
    assignmentmap[commit_ptr] = (assignmentmap[commit_ptr] + 1) % 4
    return assignmentmap

def update_serve_ptr(assignmentmap: Assignment):
    assignmentmap[serve_ptr] = (assignmentmap[serve_ptr] + 1) % 4
    return assignmentmap

def make_store(assignmentmap: Assignment):
    assignmentmap[store_q][assignmentmap[store_ptr]] = assignmentmap[instr_i]
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
        [store_q, store_ptr], [store_q, store_ptr], MopBehaviour.COM,
        lambda new_map, pre_map:
        VStmtSeq([
            VBAssignment(VArraySelect(new_map[store_q], [pre_map[store_ptr]]), pre_map[instr_i]),
            VBAssignment(new_map[store_ptr], pre_map[store_ptr] + VBVConst(1, 2, VBases.BIN))
        ])
    )
gen_store_non_update = Mop("gen_store_non_update", lambda assignmentmap: assignmentmap,
        [store_q, store_ptr], [store_q, store_ptr], MopBehaviour.COM,
        lambda new_map, pre_map: VStmtSeq([])
    )
            

gen_set_state_commit = Mop("gen_set_state_commit", set_state_commit,
    [state_q, commit_ptr], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[state_q], [pre_map[commit_ptr]]), VBVConst(1, 2, VBases.BIN))
    )
gen_set_state_serve = Mop("gen_set_state_serve", set_state_serve,
    [state_q, serve_ptr], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    )
gen_set_state_store = Mop("gen_set_state_store", set_state_store,
    [state_q, store_ptr], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map:
    VBAssignment(VArraySelect(new_map[state_q], [pre_map[store_ptr]]), VBVConst(3, 2, VBases.BIN))
    )
gen_set_state_store_serve = Mop("gen_set_state_store_serve", lambda assignmentmap: set_state_serve(set_state_store(assignmentmap)),
    [state_q, store_ptr, serve_ptr], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([
        VBAssignment(VArraySelect(new_map[state_q], [pre_map[store_ptr]]), VBVConst(3, 2, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    ])
    )
gen_set_state_commit_serve = Mop("gen_set_state_commit_serve", lambda assignmentmap: set_state_serve(set_state_commit(assignmentmap)),
    [state_q, commit_ptr, serve_ptr], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([
        VBAssignment(VArraySelect(new_map[state_q], [pre_map[commit_ptr]]), VBVConst(1, 2, VBases.BIN)),
        VBAssignment(VArraySelect(new_map[state_q], [pre_map[serve_ptr]]), VBVConst(0, 2, VBases.BIN))
    ])
    )
gen_set_state_none = Mop("gen_set_state_none", lambda assignmentmap: assignmentmap,
    [state_q], [state_q], MopBehaviour.SEQ,
    lambda new_map, pre_map: VStmtSeq([])
    )



instr_valid_i = ISignal("instr_valid_i", 1)
commit_i = ISignal("commit_i", 1)
store_mem_resp_i = ISignal("store_mem_resp_i", 1)
queue_state = [ISignal("queue_state_{}".format(i), 2) for i in range(4)]
serve_ptr_i = ISignal("serve_ptr_i", 2)

dut_isig_basename_mapping = {
    instr_valid_i : DUTHook('store_unit_model_tb.tb_io_instr_valid_i', 0),
    commit_i      : DUTHook('store_unit_model_tb.tb_io_commit_i', 1*LEAP),
    store_mem_resp_i : DUTHook('store_unit_model_tb.tb_io_store_mem_resp_i', 1*LEAP),
    **{
        queue_state[i] : DUTHook('store_unit_model_tb.su_i.store_buffer_i.state_q_{}[1:0]'.format(i), 0)
            for i in range(4)
    },
    serve_ptr_i    : DUTHook('store_unit_model_tb.su_i.store_buffer_i.commit_read_pointer_q[1:0]', 0)
}

is_valid_instr = Predicate("is_valid_instr",
    lambda frame: frame["instr_valid_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["instr_valid_i"])
)
is_valid_commit = Predicate("is_valid_commit",
    lambda frame: frame["commit_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["commit_i"])
)
is_valid_store_mem_resp = Predicate("is_valid_store_mem_resp",
    lambda frame: frame["store_mem_resp_i"] == 1,
    lambda frame: "(= {} #b1)".format(frame["store_mem_resp_i"])
)

commit_ready_preds = []
for j in range(4):
    func = (lambda frame, k=j: [frame["queue_state_{}".format(i)] for i in range(4)][frame["serve_ptr_i"]] == k)
    commit_ready_preds.append(Predicate("is_valid_commit_ready_{}".format(j), func, None))


def make_testblock_by_seed(seed):
    return cva6_su_testblock.make_testblock_by_seed(seed)

cva6_su_config = ProcessorConfig(
    NAME="cva6_su",
    PARENT_DIR=PARENT_DIR,
    VCDFILE=VCDFILE,
    TBFILE=f"{SIMULATION_DIR}/rtl/cva6_store_unit_model_tb.v",
    TBVCD=f"{SIMULATION_DIR}/{VCDFILE}",
    SIMULATION_DIR=SIMULATION_DIR,
    SIMULATION_COMMAND="make store_unit_model_tb_build; ./store_unit_model_tb",
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
        gen_make_store,
        gen_store_non_update,
        gen_commit_ptr_update,
        gen_commit_ptr_non_update,
        gen_serve_ptr_update,
        gen_serve_ptr_non_update,
        gen_set_state_commit,
        gen_set_state_serve,
        gen_set_state_store,
        gen_set_state_none,
        gen_set_state_store_serve,
        gen_set_state_commit_serve
    ],
    PREDICATES=[
        is_valid_instr,
        is_valid_commit,
        is_valid_store_mem_resp
    ] + [commit_ready_preds[1]],
    make_testblock_by_program=None,
    make_testblock_by_seed=make_testblock_by_seed,
    make_distinguishblock_by_prepost=None,
    PREF_ORDER=[
        (gen_set_state_none, i) for i in [gen_set_state_commit, gen_set_state_serve, gen_set_state_store, gen_set_state_store_serve, gen_set_state_commit_serve]
    ] + [
        (ti, tj) for ti in [gen_set_state_commit, gen_set_state_serve, gen_set_state_store] for tj in [gen_set_state_store_serve, gen_set_state_commit_serve]
    ]
)

