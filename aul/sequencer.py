from copy import deepcopy
import logging
import json
from time import time
from typing import List, Set, Tuple, Dict
from aul.processor_config import ProcessorConfig, PrefOrder
from aul.utils import UNCONSTRAINED
from vcdvcd import VCDVCD
# from distinguisher import generate_distinguisher_commands
from aul.moplib import Mop, Assignment, Signal
from aul.tracereader import get_assignment_at, get_iframe_values, get_subtrace
from aul.veriloggen import VAssert, VAssume, VOpExpr, VBAssignment


MSequenceType = List[str]

# Dependency analysis
def get_dependency_matrix(txns : List[Mop]):
    """
    Returns a 2D array in which an entry [i][j] is True
        if i depends on j
    Transaction i is dependent on j if i is sequential and j is combinational
        or both are combinational and there is a data dependency
    """
    return [
        [(txns[j].is_seq and txns[i].is_com)
            or (txns[i].is_com and txns[j].is_com and txns[i].depends_on(txns[j]))
            for j in range(len(txns))
        ] for i in range(len(txns))]

# Modification analysis
def get_modified_vars(pre_assign: Assignment, post_assign: Assignment):
    ''' Get the modified variables given pre/post '''
    return [i for i in pre_assign if pre_assign[i] != post_assign[i]]
def get_modified_vars_non_low(pre_assign: Assignment, post_assign: Assignment):
    ''' Get the modified variables given pre/post '''
    # This identifies the CSIGS that need to be actively driven
    return [i for i in pre_assign if ((pre_assign[i] != post_assign[i] or (not i.holds_value)) and
        post_assign[i] != i.default and i.is_csig)]
def get_default_vars(pre_assign: Assignment, post_assign: Assignment):
    '''
    This identifies the set of signals that are not actively
    driven as they take their natural value at the next state
    '''
    return [i for i in pre_assign if (i.is_dsig or post_assign[i] == i.default or
        (i.holds_value and pre_assign[i] == post_assign[i]))]
def get_modified_vars_at(trace, timestep):
    ''' What are the variables that changed from t to t+1 '''
    return get_modified_vars(get_assignment_at(trace, timestep),
        get_assignment_at(trace, timestep+1))
def get_modified_vars_non_low_at(trace, timestep):
    ''' What are the variables that changed from t to t+1 with a non-zero value '''
    return get_modified_vars_non_low(get_assignment_at(trace, timestep),
        get_assignment_at(trace, timestep+1))

def has_uc_signal(sigs: List[Signal], assn: Assignment) -> bool:
    return any([assn[s] == UNCONSTRAINED for s in sigs])

def enumerate_uc_candidates(txn: Mop, pre_assign: Assignment, post_assign: Assignment, cutoff: int = 8) -> List[Assignment]:
    """Tries multiple values of unconstrained variables to check if one fits

    Args:
        txn (Mop): the micro-operation to check for
        pre_assign (Assignment): previous assignment value
        post_assign (Assignment): next assignment value
        cutoff (int, optional): number of values to try. Defaults to 8.

    Returns:
        List[Assignment]: possible next assignments
    """
    curr_possibilities = []
    logging.warn("Trying out possibilities over unconstrained variables, only do this over small spaces")
    unconstrained_sigs = [s for s, v in pre_assign.items() if v == UNCONSTRAINED]
    if (len(unconstrained_sigs) > 1):
        logging.warn("Is only allowed for one variable for scalability reasons")
        return []

    # Only consider first u_sig
    u_sig : Signal = unconstrained_sigs[0]
    for trial_v in range(min((1 << u_sig.outw), cutoff)):
        pre_cand = deepcopy(pre_assign)
        pre_cand[u_sig] = trial_v
        pre_cand.update({s: 0 for s in unconstrained_sigs[1:]})
        post_assign_cand = txn(pre_cand)
        if post_assign_cand.matches_on_sigs(post_assign, txn.modifies):
            curr_possibilities.append(post_assign_cand)
    return curr_possibilities


# Main enumerative search routine
def get_orderings_for_one_cycle_dfs(transactions: List[Mop],
    pre_assign : Assignment, post_assign : Assignment, cutoff: int):
    """Main DFS+pruning algorithm to narrow down possible candidates

    Args:
        transactions (List[Mop]): possible transaction candidates
        pre_assign (Assignment): previous assignment
        post_assign (Assignment): goal assignment (for default values)

    Returns:
        List[List[int]]: possible orderings that explain pre and post pair
    """
    # Enumerate all transactions and classify by seq and com
    numbered_transactions = list(enumerate(transactions))
    seq_transactions = [
        (i, t) for (i, t) in numbered_transactions if t.is_seq
    ]
    com_transactions = [
        (i, t) for (i, t) in numbered_transactions if t.is_com
    ]

    # Accumulation container for all possible orderings
    possible_orderings : List[List[int]] = []
    modified_vars = get_modified_vars_non_low(pre_assign, post_assign)
    modified_vars_names = set([s.name for s in modified_vars])
    dependency_matrix = get_dependency_matrix(transactions)

    def dfs_helper(frame : List[Tuple[int, Assignment, Set[str], bool]]):
        if len(possible_orderings) >= cutoff:
            return
        # Decode the top frame in the DFS stack
        if len(frame) != 0:
            top_assign  = frame[-1][1]
            delta_set   = frame[-1][2]
            search_in_seq = frame[-1][3]
        else:
            top_assign  = pre_assign
            delta_set   = set()
            search_in_seq = True
        # The first element of the frame is then sentinel for the default behaviours
        curr_txns = [p[0] for p in frame[1:]]
        # If already matches with post and there are no more unmodified variables, we're done
        if top_assign.matches_on_sigs(post_assign, modified_vars) and len(modified_vars_names.difference(delta_set)) == 0:
            possible_orderings.append(curr_txns)
            return
        # If not but the modified set is covered, we're negatively done
        elif delta_set == modified_vars_names:
            return

        # Should we check in the SEQ transactions
        if search_in_seq:
            for (i, txn) in seq_transactions:
                if i not in curr_txns:
                    # Only proceed if the txn modifies variables within the modifies set
                    if txn.modifies_names.issubset(modified_vars_names.difference(delta_set)):
                        # And if the next transaction has higher index (symmetry breaking)
                        if len(curr_txns) == 0 or (curr_txns[-1] < i):
                            if has_uc_signal(txn.uses, pre_assign):
                                candidates = enumerate_uc_candidates(txn, pre_assign, post_assign)
                                if len(candidates) > 0:
                                    post_txn_assign = candidates[0]
                                    dfs_helper(frame+[(i, top_assign.update_on_sigs(post_txn_assign, txn.modifies), delta_set.union(txn.modifies_names), True)])
                            else:
                                post_txn_assign = txn(deepcopy(pre_assign))
                                # And if the change in values is agreeable
                                if post_assign.matches_on_sigs(post_txn_assign, txn.modifies):
                                    dfs_helper(frame+[(i, top_assign.update_on_sigs(post_txn_assign, txn.modifies), delta_set.union(txn.modifies_names), True)])

        # If not only search in COM: this is monotonic
        # if len(curr_txns) == 0:
        #     return
        for (i, txn) in com_transactions:
            if i not in curr_txns and txn.modifies_names.issubset(modified_vars_names.difference(delta_set)):
                unpositionable = len(curr_txns) > 0 and (any([dependency_matrix[j][i] for j in curr_txns]) or (not dependency_matrix[i][curr_txns[-1]] and curr_txns[-1] > i))
                if not unpositionable:
                    post_txn_assign = txn(deepcopy(top_assign))
                    if post_assign.matches_on_sigs(post_txn_assign, txn.modifies):
                        dfs_helper(frame+[(i, post_txn_assign, delta_set.union(txn.modifies_names), False)])

    # Make the assignment agree on all default values
    new_top_assign = pre_assign.update_on_sigs(post_assign,
        get_default_vars(pre_assign, post_assign))
    dfs_helper([(-1, new_top_assign, set(), True)])
    return possible_orderings

# Testing generated sequences
def apply_transaction_sequence(pre_assign: Assignment, post_assign: Assignment,
    txn_seq: List[str], txn_map: Dict[str, Mop]) -> Assignment:
    """Literally applies the sequence of micro-ops on the pre_assign
        Sequential updates read form pre-state, combinational may read updated.

    Args:
        pre_assign (Assignment): assignment to apply the transactions on
        post_assign (Assignment): goal assignment (to read off defaulting values from)
        txn_seq (List[str]): sequence of transactions to be applied
        txn_map (Dict[str, Mop]): map from transaction names to transactions

    Returns:
        Assignment: actual post assignment (with non-default values as well)
    """
    post_assign = pre_assign.update_on_sigs(post_assign, get_default_vars(pre_assign, post_assign))
    print([s for txn_name in txn_seq for s in txn_map[txn_name].modifies])
    print(set(get_modified_vars_non_low(pre_assign, post_assign)).difference([s for txn_name in txn_seq for s in txn_map[txn_name].modifies]))
    for txn_name in txn_seq:
        txn = txn_map[txn_name]
        if txn.is_seq:
            post_assign = post_assign.update_on_sigs(txn(deepcopy(pre_assign)), txn.modifies)
        else:
            post_assign = post_assign.update_on_sigs(txn(deepcopy(post_assign)), txn.modifies)
    return post_assign

# Analysis of generated msequences
def load_msequences(mseq_file: str, txn_name: str, rng: range = None) -> List[bool]:
    """Load the msequences from the test directory and return whether t_id is an acceptable
        transformer for the test instances in lseq_logdir.
    Returns true if any acceptable msequence set contains t_id

    Args:
        mseq_file (str): file to load the msequence from
        txn_name (str): name of the transaction that we're trying to track
        rng (range): timestamp range

    Returns:
        List[bool]: list of booleans describing whether the transaction is a possible candidate
    """
    result = []
    with open(mseq_file, 'r') as fhndle:
        mseq_log  = json.load(fhndle)
        if rng is not None:
            for timestamp in rng:
                if str(timestamp) not in mseq_log:
                    print("Missing frame: {} in test {}".format(timestamp, mseq_file))
                    exit()
                result.append(any([(txn_name in s) for s in mseq_log[str(timestamp)]]))
        else:
            for timestamp in mseq_log:
                result.append(any([(txn_name in s) for s in mseq_log[timestamp]]))
    return result

def get_conflicting_transactions(sig: Signal, txn_map: Dict[str, Mop]) -> List[str]:
    """Get the transactions that write to the same signal

    Args:
        sig (Signal): signal which is conflicted on
        txn_map (Dict[str, Mop]): all the transactions that write to this signal

    Returns:
        List[str]: the transactions that write to the above signal
    """
    return [txn_name for txn_name in txn_map if sig in txn_map[txn_name].modifies]

def get_conflicting_signals(config_obj: ProcessorConfig, sig: Signal) -> List[Signal]:
    """Genrates all posssible dependencies for a monolithic synthesis query

    Args:
        config_obj (ProcessorConfig): processor configuration
        sig (Signal): a single signal to start the search from

    Returns:
        List[str]: list of all possible conflicting transactions, accounting for transitive closure
    """
    transaction_set = set()
    signal_set = {sig}
    all_transactions = config_obj.transactions_by_name()
    new_signals = {sig}
    while len(new_signals) > 0:
        new_txns = set([txn_name for txn_name in all_transactions for sig_ in new_signals if sig_ in all_transactions[txn_name].modifies])
        transaction_set.union(new_txns)
        all_signals = [all_transactions[new_txn_].modifies for new_txn_ in new_txns]
        all_signals = set([ns_ for nses in all_signals for ns_ in nses])
        new_signals = all_signals.difference(signal_set)
        signal_set.update(all_signals)
    return list(signal_set)

# Distinguisher frontend
def generate_distinguisher_commands(proc_config: ProcessorConfig, seq1: MSequenceType, seq2: MSequenceType, orient_one: int = -1):
    """Generates the Verilog formal block required to distinguish between two l-sequences

    Identifies the difference in two lsequences, requires that the consumed values be identical
        but tries to find executions in which the produced values are different

    Args:
        proc_config: Confguration
        seq1 (MSequenceType): first sequence
        seq2 (MSequenceType): second sequence
        orient_one (int): picks the m-sequence that should match

    Returns:
        Tuple[VStmt, VAssert, VAssume]: triple defining the code block
    """
    code1 = []
    code2 = []
    copy1 = proc_config.get_extension_mapping("copy1_")
    copy2 = proc_config.get_extension_mapping("copy2_")
    desn = proc_config.get_extension_mapping("de_io_port_")
    txn_difference = set(seq1).difference(set(seq2))
    txn_map = proc_config.transactions_by_name()
    dist_signals = [sig for txn_name in txn_difference for sig in txn_map[txn_name].modifies]

    for txn_name in seq1:
        txn = txn_map[txn_name]
        if txn.is_seq:
            code1.append(txn.block(copy1, desn).__inject__())
        elif txn.is_com:
            code1.append(txn.block(copy1, copy1).__inject__())
    for txn_name in seq2:
        txn = txn_map[txn_name]
        if txn.is_seq:
            code2.append(txn.block(copy2, desn).__inject__())
        elif txn.is_com:
            code2.append(txn.block(copy2, copy2).__inject__())
    code = code1 + code2

    assertions = []
    for sig in dist_signals:
        # Not necessary to check non-mapness (SymbiYosys fails and raises an error)
        if sig.is_csig:
            if orient_one == 1:
                assertions.append(
                    VAssert(VOpExpr("or",
                        [VOpExpr("not", [VOpExpr("and", [VOpExpr("eq", [copy2[sig], desn[sig]])])]) for sig in dist_signals]
                        + [VOpExpr("eq", [copy1[sig], copy2[sig]])]
                    )).__inject__())
            elif orient_one == 0:
                assertions.append(
                    VAssert(VOpExpr("or",
                        [VOpExpr("not", [VOpExpr("and", [VOpExpr("eq", [copy1[sig], desn[sig]])])]) for sig in dist_signals]
                        + [VOpExpr("eq", [copy1[sig], copy2[sig]])]
                    )).__inject__())
            else:
                # Not necessary for any side to match
                assertions.append(VAssert(VOpExpr("eq", [copy1[sig], copy2[sig]])).__inject__())

    uses : List[Signal] = []
    for txn_name in set(seq1).symmetric_difference(set(seq2)):
        uses.extend(txn_map[txn_name].uses)
    # Remove duplicates
    uses = set(uses)
    # Use assignments instead of assumes (more robust)
    # assumptions1 = [VAssume(VOpExpr("eq", [copy1[sig], desn[sig]])).__inject__() for sig in uses if sig.is_csig]
    # assumptions2 = [VAssume(VOpExpr("eq", [copy2[sig], desn[sig]])).__inject__() for sig in uses if sig.is_csig]
    assumptions1 = [VBAssignment(copy1[sig], desn[sig]).__inject__() for sig in uses if sig.is_csig]
    assumptions2 = [VBAssignment(copy2[sig], desn[sig]).__inject__() for sig in uses if sig.is_csig]
    assumptions = assumptions1 + assumptions2

    return (assumptions, code, assertions)

def generate_msequences_distinguisher_triple(proc_config: ProcessorConfig, mseq_file: str, timestamp: int, 
        mseq_indices: Tuple[int, int] = (0, 1), orient_one: int = -1):
    """For a pair of msequences, determine an input that distinguishes them

    Args:
        proc_config: Configuration
        mseq_file (str): file with transaction sequence
        timestamp (int): timestamp (step number)
        mseq_indices (Tuple[int,int]): choice of msequences to distinguish between
        choice (int): make sure that the generated trace works for choice 0/1

    Returns:
        None: generates the distinguishing script
    """
    with open(mseq_file, 'r') as fhndle:
        mseq_log = json.load(fhndle)
        if str(timestamp) not in mseq_log:
            print("Missing frame: {} in test {}".format(timestamp, mseq_file))
            exit()
        msequences : List[MSequenceType] = mseq_log[str(timestamp)]
        if len(msequences) == 1:
            logging.info("Only one msequence, no need to distinguish")
            print("Only one msequence, no need to distinguish")
            exit()
        else:
            distrecord = {
                "uid"       : int(time()),
                "timestamp" : timestamp,
                "mseq0"     : msequences[mseq_indices[0]],
                "mseq1"     : msequences[mseq_indices[1]]
            }
            return distrecord, generate_distinguisher_commands(proc_config, msequences[mseq_indices[0]], msequences[mseq_indices[0]], orient_one)

def generate_txn_cover_triple(proc_config: ProcessorConfig, mseq1: List[str], mseq2: List[str]):
    """Create execution that works for a particular transaction sequence

    Args:
        proc_config (ProcessorConfig): configuration
        mseq1 (List[str]): first transaction sequence
        mseq2 (List[str]): second transaction sequence

    Returns:
        Tuple[str, str, str]: assumes, the code block and assertion
    """
    return generate_distinguisher_commands(proc_config, mseq1, mseq2, 0)

def find_bad_transactions(config_obj: ProcessorConfig, vcddistrace: VCDVCD) -> List[str]:
    """Given two sequential, assignments, discriminate between them

    Args:
        config_obj (ProcessorConfig): processor configuration data
        vcddistrace (VCDVCD): vcd dump file

    Returns:
        (List[str]): list of bad transactions
    """
    subtrace = get_subtrace(vcddistrace, config_obj.DIS_MAPPING, config_obj.DISTINGUISH_RANGE)
    raw_iframe = get_iframe_values(vcddistrace, config_obj.DIS_ISIGNALS, config_obj.DISTINGUISH_RANGE)[0]
    iframe_repr = {s.name : val for (s, val) in raw_iframe.items()}
    # iframes = [canonicalize_iframe(riframe, config_obj.DIS_ISIGNALS) for riframe in raw_iframes[:-1]]
    # predframes = list(map(list,
    #     zip(*[apply_all(iframe, config_obj.PREDICATES) for iframe in iframes])))
    # print(predframes)
    # for predframe in predframes:
    #     print_blist(predframe)
    pre_assign = get_assignment_at(subtrace, 0)
    post_assign = get_assignment_at(subtrace, 1)

    bad_transactions = []
    for txn in config_obj.TRANSACTIONS:
        # Only applies for sequential transactions since for others
        # there might be a dependency on the other parts of the state
        if txn.is_seq:
            # Not considering memory operations for now
            if all([isinstance(pre_assign[s], int) for s in txn.uses]):
                if all([isinstance(post_assign[s], int) for s in txn.modifies]):
                    if not txn(deepcopy(pre_assign)).matches_on_sigs(post_assign, txn.modifies):
                        bad_transactions.append(txn.name)
            # Do below things at risk: not checking for undefined signals
            elif has_uc_signal(txn.uses, pre_assign):
                candidates = enumerate_uc_candidates(txn, pre_assign, post_assign)
                if len(candidates) == 0:
                    bad_transactions.append(txn.name)
            elif not txn(deepcopy(pre_assign)).matches_on_sigs(post_assign, txn.modifies):
                bad_transactions.append(txn.name)
    return iframe_repr, bad_transactions

def check_rational(pref_order: PrefOrder):
    """Check if the preference order is rational

    Args:
        pref_order (PrefOrder): preference order

    Returns:
        bool: True if rational, False otherwise
    """
    # All ordered pairs must write to the same set of variables
    for (txn1, txn2) in pref_order:
        if txn1.modifies_names != txn2.modifies_names or txn1.is_com or txn2.is_com:
            return False
    return True
    

# Frontend for main DFS routine
def determine_msequences(testname: str, vcdtrace: VCDVCD, rng: range, mapping, transactions: List[Mop], pref_order: PrefOrder = None):
    """For the given vcd directory, generate msequences for the trace in the range

    Args:
        testname (str): name of the test (for logging purposes)
        vcdtrace (VCDVCD): (vcd trace object)
        rng (range): range of values to generate sequences for
        mapping (Dict[Signal, str]): mapping between the Signals and the DUT elements
        transactions (List[Mop]): list of transactions to consider

    Returns:
        Dict[int, List[str]]: a timestep indexed dict containing possible transactions
    """
    subtrace    = get_subtrace(vcdtrace, mapping, rng)
    msequences  = {}
    for index in range(len(subtrace)-1):
        timestep = index + int(rng.start/rng.step)
        assn0       = get_assignment_at(subtrace, index)
        assn1       = get_assignment_at(subtrace, index+1)
        orderings   = get_orderings_for_one_cycle_dfs(transactions, assn0, assn1, 1<<4)
        orderings_by_name = [
            [transactions[i].name for i in ordering] for ordering in orderings
        ]
        if pref_order is not None:
            if not check_rational(pref_order):
                logging.error("Preference order is not rational, skipping")
            else:
                for (mop1, mop2) in pref_order:
                    contains1 = any([mop1.name in ordering for ordering in orderings_by_name])
                    if contains1:
                        orderings_by_name = list(filter(lambda ordering: mop2.name not in ordering, orderings_by_name))
        if len(orderings) != 0:
            msequences[timestep] = orderings_by_name
            logging.info("Done with test %s at index %s (timestep %s)", testname, index, timestep)
        else:
            logging.error("Test failed: %s", testname)
            logging.info("Failed at index %s (timestep %s)", index, timestep)
            logging.info("Pre-assignment: %s", assn0)
            logging.info("Post-assignment: %s", assn1)
    return msequences
