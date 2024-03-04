'''
    Synthesizer elements
'''

import cvc5
from cvc5 import Kind

import subprocess
from typing import List, Tuple

from aul.sexp import parse
from aul.predicate import Formula
import random

from functools import reduce

# class Grammar

def remove_redundant(txns: List[str], mseqs: List[List[bool]]):
    """Remove transactions that are always false
    Args:
        txns (List[str]): list of microops
        mseqs (List[List[bool]]): trigger sequence
    """
    clean_txns = []
    clean_mseqs = []
    for (txn_name, mseq) in zip(txns, mseqs):
        if any(mseq):
            clean_txns.append(txn_name)
            clean_mseqs.append(mseq)
    return (clean_txns, clean_mseqs)

def gen_control_synthesis_script(txns: List[str], txn_classes: List[List[str]], mseqs: List[List[bool]], predframes: List[List[bool]], synthfile: str = "temp.smt2"):
    """Controller synthesis script:
        given the predicate value sequence and allowed msequences, synthesize the control signals

    Args:
        txns (List[str]): names of synthesis functions
        mseqs (List[List[bool]]): for a transaction what is the trigger sequence: [txn_id][time]
        predframes (List[List[bool]]): for each predicate the values-sequence [pred_id][time]
    """
    # txns, mseqs = remove_redundant(txns, mseqs)
    # Number of inputs to the synthesis function(s)
    num_inputs = len(predframes)
    # Their names, and declarations
    input_names = [f"x{i}" for i in range(num_inputs)]
    input_decl = " ".join([f"({n} Bool)" for n in input_names])
    input_name_seq = " ".join(input_names)
    # Applications of the synthesis functions to the inputs
    synthfun_apps = [f"({txn_name} {input_name_seq})" for txn_name in txns]
    # synthfun_apps_seq = " ".join(synthfun_apps)
    synthfun_txn_mapping = {txn_name : app for (txn_name, app) in zip(txns, synthfun_apps)}

    def get_finite_grammar(inputs: str, depth: int):
        non_terms   = ' '.join(['(B{} Bool)'.format(i) for i in range(depth-1, -1, -1)])
        expansions  = []
        for i in reversed(range(depth-1)):
            expansions.append(
                '(B{} Bool (true false (and B{} B{}) (or B{} B{}) (not B{}) {}))'.format(
                    i+1, i, i, i, i, i, inputs))
        base = '(B0 Bool (true false {}))'.format(inputs)
        expansions = '\n'.join(expansions + [base])
        return f"""
    ;; Declare the non-terminals that would be used in the grammar
    ({non_terms})

    ;; Define the grammar for allowed implementations of max2
    ({expansions})
        """

    def get_infinite_grammar(inputs: str):
        return f"""
    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) {inputs}) ) )
        """

    def get_declare_var(i: int):
        """ Create synthesis input (declare) variables """
        return f"(declare-var x{i} Bool)"
    def get_synth_fun(name: str):
        """ Create the grammar for each synthesis function """
        return f"""
(synth-fun {name} ({input_decl}) Bool
    {get_finite_grammar(input_name_seq, 4)}
)
        """
    def get_constraints_no_spurious_trigger(mseqs_t: List[List[bool]], predframes_t: List[List[bool]]) -> str:
        """Generate the constraints for no spurious triggering

        Args:            
            mseqs_t (List[List[bool]]): for a timestep what is the trigger signature: [time][txn_id]
            predframes_t (List[List[bool]]): for a timestep what is the pred valuation: [time][txn_id]

        Returns:
            str: SMT constraint string
        """
        constraints = []
        for mseq, predf in zip(mseqs_t, predframes_t):
            for txn_name, b in zip(txns, mseq):
                if not b:
                    inputs = ' '.join(['true' if predv else 'false' for predv in predf])
                    constraints.append(f"(constraint (not ({txn_name} {inputs})))")
        return '\n'.join(constraints)

    def get_constraints_one_must_be_triggered(txn_list: List[str]):
        constraints_one_must_be_triggered : List[str] = []
        for i in txn_list:
            for j in txn_list:
                if i != j:
                    constraints_one_must_be_triggered.append(
                        f"(constraint (not (and {synthfun_txn_mapping[i]} {synthfun_txn_mapping[j]})))")
        synthfun_apps_seq = " ".join([synthfun_txn_mapping[txn_] for txn_ in txn_list])
        constraints_one_must_be_triggered.append(f"(constraint (or {synthfun_apps_seq}))")
        return "\n".join(constraints_one_must_be_triggered)

    input_declarations = "\n".join([get_declare_var(i) for i in range(num_inputs)])
    logic_decl = "(set-logic UF)"
    synth_funs = "\n\n".join([get_synth_fun(txn_name) for txn_name in txns])
    # Transpose to [time][txn_id]
    consistency_constraints = get_constraints_no_spurious_trigger(list(map(list, zip(*mseqs))), list(map(list, zip(*predframes))))
    cardinality_constraints = "\n".join([get_constraints_one_must_be_triggered(tl_) for tl_ in txn_classes])
    script_string = logic_decl + synth_funs + "\n" + input_declarations + "\n" + cardinality_constraints + "\n" + consistency_constraints + "\n\n(check-synth)"
    with open(f"{synthfile}", 'w') as fhndle:
        fhndle.write(script_string)


def parse_define(expr, mapping) -> Formula:
    if expr.getKind() == Kind.AND:
        return reduce(Formula.__and__, [parse_define(expr[i], mapping) for i in range(1, expr.getNumChildren())], parse_define(expr[0], mapping))
    elif expr.getKind() == Kind.OR:
        return reduce(Formula.__or__, [parse_define(expr[i], mapping) for i in range(1, expr.getNumChildren())], parse_define(expr[0], mapping))
    elif expr.getKind() == Kind.NOT:
        return parse_define(expr[0], mapping).__invert__()
    elif expr.getKind() == Kind.VARIABLE:
        return mapping[expr.getSymbol()]


def run_control_synthesis_cvc5(txns: List[str], txn_classes: List[List[str]], mseqs: List[List[bool]], predicates: List[Formula], predframes: List[List[bool]], indeps: List[Tuple[int, int]]):
    """_summary_

    Args:
        txn (List[str]): _description_
        txn_classes (List[List[str]]): _description_
        mseqs (List[List[bool]]): _description_
        predframes (List[List[bool]]): _description_
    """
    slv = cvc5.Solver()
    slv.setOption("sygus", "true")
    slv.setOption("incremental", "false")

    boolean = slv.getBooleanSort()

    # txns, mseqs = remove_redundant(txns, mseqs)
    # Number of inputs to the synthesis function(s)
    num_inputs = len(predicates)
    # Their names, and declarations
    input_names = [f"x{i}" for i in range(num_inputs)]
    # input_decl = " ".join([f"({n} Bool)" for n in input_names])
    # input_name_seq = " ".join(input_names)
    inputs = [slv.mkVar(boolean, n) for n in input_names]

    def get_finite_grammar(inps: str, depth: int):
        nonterms = [slv.mkVar(boolean, f"nt_B{i}") for i in range(depth)]
        g = slv.mkGrammar(inps, nonterms)
        # bind each non-terminal to its rules
        for i in range(depth-1):
            g.addRules(nonterms[i], inps + [
                slv.mkTerm(Kind.AND, nonterms[i+1], nonterms[i+1]),
                slv.mkTerm(Kind.OR, nonterms[i+1], nonterms[i+1]),
                slv.mkTerm(Kind.NOT, nonterms[i+1])
            ])
        g.addRules(nonterms[depth-1], inps)
        return g

    grammar = get_finite_grammar(inputs, 4)

    # Synthesis functions
    synthfuns = [slv.synthFun(txn_name, inputs, boolean, grammar) for txn_name in txns]
    # Quantified variables
    qvars = [slv.declareSygusVar(n, boolean) for n in input_names]
    # Applications of the synthesis functions to the inputs
    synthfun_apps = [slv.mkTerm(Kind.APPLY_UF, sf, *qvars) for sf in synthfuns]
    
    # txn_name to synthfun name
    synthfun_txn_mapping = {txn_name : app for (txn_name, app) in zip(txns, synthfuns)}
    # txn_name to synthfun application
    synthfun_app_mapping = {txn_name : app for (txn_name, app) in zip(txns, synthfun_apps)}

#     def get_declare_var(i: int):
#         """ Create synthesis input (declare) variables """
#         return f"(declare-var x{i} Bool)"
#     def get_synth_fun(name: str):
#         """ Create the grammar for each synthesis function """
#         return f"""
# (synth-fun {name} ({input_decl}) Bool
#     {get_finite_grammar(input_name_seq, 4)}
# )
#         """
    def get_constraints_no_spurious_trigger(slv, mseqs_t: List[List[bool]], predframes_t: List[List[bool]]) -> str:
        """Generate the constraints for no spurious triggering

        Args:            
            mseqs_t (List[List[bool]]): for a timestep what is the trigger signature: [time][txn_id]
            predframes_t (List[List[bool]]): for a timestep what is the pred valuation: [time][txn_id]

        Returns:
            str: SMT constraint string
        """
        for mseq, predf in zip(mseqs_t, predframes_t):
            for txn_name, b in zip(txns, mseq):
                if not b:
                    cons = slv.mkTerm(Kind.NOT, slv.mkTerm(Kind.APPLY_UF, synthfun_txn_mapping[txn_name], *[slv.mkTrue() if predv else slv.mkFalse() for predv in predf]))
                    slv.addSygusConstraint(cons)

    def get_constraints_one_must_be_triggered(slv, txn_list: List[str]):
        if len(indeps) != 0:
            cons_pre = slv.mkTerm(Kind.AND, *[slv.mkTerm(Kind.NOT, slv.mkTerm(Kind.AND, qvars[i1], qvars[i2])) for (i1, i2) in indeps])
        for i in txn_list:
            for j in txn_list:
                if i != j:
                    cons = slv.mkTerm(Kind.NOT, slv.mkTerm(Kind.AND, synthfun_app_mapping[i], synthfun_app_mapping[j]))
                    if len(indeps) != 0:
                        slv.addSygusConstraint(slv.mkTerm(Kind.IMPLIES, cons_pre, cons))
                    else:
                        slv.addSygusConstraint(cons)
        slv.addSygusConstraint(slv.mkTerm(Kind.OR, *[synthfun_app_mapping[txn_] for txn_ in txn_list]))

    get_constraints_no_spurious_trigger(slv, list(map(list, zip(*mseqs))), list(map(list, zip(*predframes))))
    for tl_ in txn_classes:
        get_constraints_one_must_be_triggered(slv, tl_)

    pred_mapping = {inp: form for (inp, form) in zip(input_names, predicates)}

    if slv.checkSynth().hasSolution():
        return {
            txn_name: parse_define(slv.getSynthSolution(sf)[1], pred_mapping) for (txn_name, sf) in zip(txns, synthfuns)
        }
    else:
        print("No solution found")
        return {}

def gen_instruction_sequence_script(ninstr: int, preds: List[Formula], predframes: List[List[bool]], synthfile: str = "./temp/temp.smt2"):
    """Get possible instruction sequences that may lead to the generation of interesting iframes

    Args:
        ninstr (int): number of instructions (inputs) in the sequence
        preds (List[Formula]): possible predicates to consider when generating
        predframes (List[bool]): desired predicate valuations
    """
    # TODO: this is hardcoded for 32 bit instruction frames AND ITYPE instructions!!!!!
    def get_declare_var(i: int):
        """ Create synthesis input (declare) variables """
        return f"x{i}"
    def get_declare_stmt(i: int):
        """ Create synthesis input (declare) variables """
        return f"(declare-fun {get_declare_var(i)} () (_ BitVec 32))"
    
    instruction_vars = [get_declare_var(i) for i in range(ninstr)]
    pipeline_width = max([f.depth for f in preds])

    def window(arr, k):
        for i in range(len(arr)-k+1):
            yield arr[i:i+k]

    # return z3.And(
    #     (z3.eq(z3.Extract(6, 0, var), z3.BitVecVal(0b0010011, 7))),
    #     (z3.Implies(z3.eq(z3.Extract(14, 12, var), z3.BitVecVal(0b001, 3)),
    #         z3.eq(z3.Extract(31, 25, var), z3.BitVecVal(0, 7)))),
    #     (z3.Implies(z3.eq(z3.Extract(14, 12, var), z3.BitVecVal(0b101, 3)),
    #         z3.And(z3.eq(z3.Extract(31, 31, var), z3.BitVecVal(0, 1)),
    #             z3.eq(z3.Extract(29, 25, var), z3.BitVecVal(0, 5)))
    #     ))
    # )
    def get_validity_constraints_itype(varname: str):
        return f"""
(assert (and
    (= ((_ extract 6 0) {varname}) #b0010011)
    (=> (= ((_ extract 14 12) {varname}) #b001) (= ((_ extract 31 25) {varname}) #b0000000))
    (=> (= ((_ extract 14 12) {varname}) #b101) (and (= ((_ extract 31 31) {varname}) #b0) (= ((_ extract 29 25) {varname}) #b00000)))
))
"""

    def get_validity_constraints_rtype(varname: str):
        return f"""
(assert (and
    (= ((_ extract 6 0) {varname}) #b0110011)
    (=> (not (or (= ((_ extract 14 12) {varname}) #b101) (= ((_ extract 14 12) {varname}) #b000))) (= ((_ extract 31 25) {varname}) #b0000000))
    (or (= ((_ extract 31 25) {varname}) #b0000000) (= ((_ extract 31 25) {varname}) #b0100000))
    ;; (=> (= ((_ extract 14 12) {varname}) #b101) (and (= ((_ extract 31 31) {varname}) #b0) (= ((_ extract 29 25) {varname}) #b00000)))
))
"""

    def get_frame_constraints(predframes_t: List[List[bool]]):
        """Get constraints based on the interesting pred valuations

        Args:
            predframes_t (List[List[bool]]): ith desirable pred valuation: [i][pred_id]
        """
        frame_constraints = ["" for _ in range(len(predframes_t))]
        for group in window(instruction_vars, pipeline_width):
            iframe = dict(zip(["inst_fet", "inst_dec", "inst_exe", "inst_mem", "inst_wb"], group))
            for i, choice in enumerate(predframes_t):
                constr = " ".join([p.get_constraint(iframe) 
                    if b else "(not {})".format(p.get_constraint(iframe)) for p, b in zip(preds, choice)])
                frame_constraints[i] += (f" (and {constr})")
        all_constraints = ["(or {})".format(constr) for constr in frame_constraints]
        return "(assert (and {}))".format("\n".join(all_constraints))

    var_declarations = "\n".join([get_declare_stmt(i) for i in range(ninstr)])
    validity_constraints = "\n\n".join([get_validity_constraints_rtype(get_declare_var(i)) for i in range(ninstr)])
    all_frame_constraints = get_frame_constraints(list(map(list, zip(*predframes))))
    get_values = "(get-value ({}))".format(" ".join(instruction_vars))
    script_string = f"(set-option :random-seed {random.randint(0, 1<<10)})\n" + var_declarations + "\n\n" + validity_constraints + "\n\n" + all_frame_constraints + "\n\n(check-sat)\n" + get_values
    with open(f"{synthfile}", 'w') as fhndle:
        fhndle.write(script_string)
    b, instrs = call_z3(synthfile)
    return (b, ["32'h{}".format(instrs[ivars][2:]) for ivars in instruction_vars])

def call_z3(file: str) -> Tuple[bool, dict]:
    output = subprocess.check_output(f"z3 {file}", shell=True, encoding='utf-8')
    output = output.split('\n')
    if output[0] == "unsat":
        return (False, {})
    else:
        parsed_sexprs = parse(' '.join(output[1:]))[0]
        return (True, {pe[0][0]: pe[1][0] for pe in parsed_sexprs})
