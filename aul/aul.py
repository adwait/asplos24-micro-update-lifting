"""
    Driver script
"""
import logging
import os
import random
from typing import Dict, List
import argparse
from pprint import pprint
import json
import datetime

from aul.processor_config import ProcessorConfig
from aul.processor_configs import CONFIGS

from aul.moplib import DUTHook, ISignal, IFrame
from aul.predicate import Formula, apply_all
from aul.sequencer import determine_msequences, apply_transaction_sequence, find_bad_transactions, generate_msequences_distinguisher_triple, get_conflicting_transactions, get_default_vars, load_msequences, get_orderings_for_one_cycle_dfs, generate_txn_cover_triple, get_conflicting_signals
from aul.utils import print_blist, MSEQUENCES_FILE, DISTINGUISHER_LOG, DISTINGUISHER_TRACE
from aul.tracereader import get_iframe_values, get_subtrace, get_assignment_at
from vcdvcd import VCDVCD
from aul import synthesizer

def canonicalize_iframe(iframe: IFrame, isignals: Dict[ISignal, DUTHook]):
    """_summary_

    Args:
        iframe (IFrame): _description_
    """
    return {s.name: v for s, v in iframe.items()}

# Testing part
def main():
    parser = argparse.ArgumentParser(description='Toolkit for specifying and generating atomic-update-models (AUMs).')
    parser.add_argument('-o', '--option', help="(0) generate sequences (1) debug specific snapshot (2) synthesize controller (3) run distinguisher (4) simulate and dump traces", type=int)
    parser.add_argument('-d', '--debug', action='store_true', help="Debug (run in INFO logging mode)")
    parser.add_argument('-c', '--config', help="Specify the configuration (keyed in 'processor_configs.py')", type=str)

    subparsers = parser.add_subparsers(dest="aul_action")
    # Simulation oracle
    simulation_parser = subparsers.add_parser("simulate")
    simulation_parser.add_argument('-n', '--num_tests', default=1, help="Number of simulations to run", required=False, type=int)
    simulation_parser.add_argument('-l', '--loc_vcd', help="Location where the generated traces should be written to", required=True)
    # MSequence generation parser
    mseqgen_parser = subparsers.add_parser("genmseq")
    mseqgen_parser.add_argument('-l', '--loc_vcd', help="Location where the generated (VCD) trace is located", required=True, nargs='+')
    # MSequence checker (mainly as a debugging utility)
    mseqcheck_parser = subparsers.add_parser("checkmseq")
    mseqcheck_parser.add_argument('-l', '--loc_vcd', help="Location where the generated (VCD) trace is located", required=True)
    mseqcheck_parser.add_argument('-t', '--timestep', help="Which step should be checked", default=0, type=int)

    consynth_parser = subparsers.add_parser("consynth")
    consynth_parser.add_argument('-l', '--loc_vcd', help="Locations where the generated (VCD) trace is located", nargs='+')
    consynth_parser.add_argument('-x', '--dist_file', help="Location where the distinguisher log is stored", default="")
    consynth_parser.add_argument('-s', '--synth_dir', help="Location where to place the generated synthesis files", default=".temp")
    consynth_parser.add_argument('-d', '--datavar', help="Specify the data variable to aim synthesis towards", type=str, default="")

    distinguish_parser = subparsers.add_parser("distinguish")
    distinguish_parser.add_argument('-l', '--loc_vcd', help="Location where the generated msequence (and vcd) is located", required=True)
    distinguish_parser.add_argument('-t', '--timestep', help="Which step should be extracted", default=0, type=int)

    analyzedist_parser = subparsers.add_parser("analyzedist")
    analyzedist_parser.add_argument('-l', '--loc_vcd', help="Location where the generated trace vcd is located", required=True)
    analyzedist_parser.add_argument('-x', '--dist_file', help="Location of the distinguisher data", type=str, required=True)

    cover_parser = subparsers.add_parser("cover")
    cover_parser.add_argument('-l', '--loc_vcd', help="Location where the generated distinguisher file should be placed", required=True)
    cover_parser.add_argument('--tl1', help="First transaction list", required=True, nargs='+')
    cover_parser.add_argument('--tl2', help="Second transaction list", required=True, nargs='+')

    isynth_parser = subparsers.add_parser("misc")
    isynth_parser.add_argument('-l', '--loc_vcd', help="Location where the generated (VCD) trace is located", required=True)
    # isynth_parser.add_argument('-s', '--synth_dir', help="Location where to place the generated synthesis files", default=sodor5_config.PARENT_DIR)

    argp = parser.parse_args()
    
    FORMAT = '%(name)s::%(levelname)s: %(message)s'
    LOGFILE = 'aul.log'
    logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO if argp.debug else logging.ERROR)
    print(f"Logging to {LOGFILE}")

    if argp.config in CONFIGS:
        config_obj = CONFIGS[argp.config]
    else:
        print(f"Catastrophic failure... configuration {argp.config} not defined!")
        logging.error("Catastrophic failure... configuration %s not defined!", argp.config)
        exit(1)

    if argp.aul_action == "simulate":
        run_simulate(config_obj, argp.loc_vcd, argp.num_tests)
    elif argp.aul_action == "genmseq":
        run_genmseq(config_obj, argp.loc_vcd)
    elif argp.aul_action == "checkmseq":
        vcddir = argp.loc_vcd
        vcdtrace = VCDVCD(f"{vcddir}/{config_obj.VCDFILE}")
        subtrace = get_subtrace(vcdtrace, config_obj.MAPPING, config_obj.SIMULATION_RANGE)
        time = argp.timestep
        assn0 = get_assignment_at(subtrace, time)
        assn1 = get_assignment_at(subtrace, time+1)
        print("Default vars: {}".format([s.name for s in get_default_vars(assn0, assn1)]))
        apply = apply_transaction_sequence(assn0, assn1,
            # ["gen_none"],
            # ["gen_update"],
            # ["gen_flush_all"],
            # [
            #     # "gen_decode_i_imm", "gen_decode_b_imm", "gen_decode_s_imm",  "gen_decode_rs1_addr", "gen_decode_rs2_addr", "gen_decode_rd_addr", 
            #     "gen_decode_all",  "feed__alu_out__mem_reg_alu_out", "feed__mem_reg_wbaddr__reg_rd_addr_in", 
            #     # "lb_refill", "feed__lb_table__reg_rd_data_in", 
            #     "regs_write", "feed__exe_reg_wbaddr__mem_reg_wbaddr", "feed__imm_s__alu_op2", "feed__reg_rs1_data_out__alu_op1",  "alu_compute_comb",  "regs1_read", "regs2_read"],
            # ["gen_decode_i_imm", "gen_decode_b_imm", "gen_decode_rs1_addr", "gen_decode_rs2_addr", "gen_decode_rd_addr", "feed__dec_wbaddr__exe_reg_wbaddr", "feed__exe_reg_wbaddr__mem_reg_wbaddr", "feed__mem_reg_wbaddr__reg_rd_addr_in", "feed__alu_out__mem_reg_alu_out", "feed__mem_reg_alu_out__reg_rd_data_in", "regs_write", "alu_compute_comb", "lb_refill", "regs1_read", "regs2_read"],
            [
                "non_update_serve_ptr", "gen_make_store"

                # "gen_decode_i_imm", "gen_decode_b_imm", "gen_decode_rs1_addr", "gen_decode_rs2_addr", "gen_decode_rd_addr", 
                # "gen_decode_all",
                # "feed__dec_wbaddr__exe_reg_wbaddr", "feed__exe_reg_wbaddr__mem_reg_wbaddr", "feed__mem_reg_wbaddr__reg_rd_addr_in", "feed__alu_out__mem_reg_alu_out", "feed__mem_reg_alu_out__reg_rd_data_in", "regs_write", "feed__mem_reg_alu_out__alu_op2", "feed__reg_rs1_data_out__alu_op1", "alu_compute_comb", "regs1_read", "regs2_read"
            ],
            # ["gen_decode_i_imm", "gen_decode_b_imm", "gen_decode_rs1_addr", "gen_decode_rs2_addr", "gen_decode_rd_addr", "feed__dec_wbaddr__exe_reg_wbaddr", "feed__exe_reg_wbaddr__mem_reg_wbaddr", "feed__mem_reg_wbaddr__reg_rd_addr_in", "feed__mem_reg_alu_out__reg_rd_data_in", "feed__alu_out__mem_reg_alu_out", "alu_compute_rs_imm", "regs1_read", "regs2_read", "regs_write"],
        config_obj.transactions_by_name())
        pprint(assn0)
        pprint(assn1)
        print(apply)
        pprint([s.name for s in assn0.delta(assn1)])
        pprint([s.name for s in apply.delta(assn1)])
        orderings = get_orderings_for_one_cycle_dfs(config_obj.TRANSACTIONS, assn0, assn1, 1<<16)
        print("Found {} orderings: ".format(len(orderings)))
        print(orderings)
    elif argp.aul_action == "consynth":
        run_consynth(config_obj, argp.synth_dir, argp.loc_vcd, argp.dist_file, argp.datavar, argp.debug)
    elif argp.aul_action == "distinguish":
        run_distinguish(config_obj, argp.loc_vcd, argp.timestep, argp.debug)
    elif argp.aul_action == "analyzedist":
        run_analyzedist(config_obj, argp.loc_vcd, argp.dist_file)
    elif argp.aul_action == "cover":
        run_cover(config_obj, argp.loc_vcd, argp.tl1, argp.tl2)
    elif argp.aul_action == "misc":
        ninstr = 16
        interesting_frames = [
            [1, 0, 0, 0, 1, 0, 0],
            [0, 0, 1, 0, 0, 0, 1],
            [0, 1, 0, 0, 1, 1, 0]
        ]
        foundsoln, instructions = synthesizer.gen_instruction_sequence_script(ninstr, config_obj.PREDICATES, interesting_frames, ".temp/instrs.smt2")
        if not foundsoln:
            print(f"No solution to predicate signatures for num_instructions = {ninstr}")
        config_obj.generate_test(argp.loc_vcd, lambda: config_obj.make_testblock_by_program(instructions))

def run_simulate(config_obj: ProcessorConfig, loc_vcd: str, num_tests: int):
    config_obj.generate_tests(num_tests, loc_vcd, lambda: config_obj.make_testblock_by_seed(random.randint(0, 1<<10)))

def run_simulate_by_program(config_obj: ProcessorConfig, loc_vcd: str, instructions: List[str]):
    config_obj.generate_test(loc_vcd, lambda: config_obj.make_testblock_by_program(instructions))

def run_genmseq(config_obj: ProcessorConfig, loc_vcd: List[str]):
    for vcddir in loc_vcd:
        vcdtrace = VCDVCD(f"{vcddir}/{config_obj.VCDFILE}")
        msequences = determine_msequences(vcddir, vcdtrace, config_obj.SIMULATION_RANGE,
            config_obj.MAPPING, config_obj.TRANSACTIONS, config_obj.PREF_ORDER)
        with open(f"{vcddir}/{MSEQUENCES_FILE}", 'w') as fhandler:
            fhandler.write(json.dumps(msequences))
        logging.info("Done with generating m-sequences for %s", vcddir)

def run_consynth(config_obj: ProcessorConfig, synth_dir: str, loc_vcd: List[str], 
    dist_file: str = "", datavar: str = "", debug: bool = False, collapse_opt: bool = False, isolated: bool = False):
    if datavar == "":
        con_c_signals = [s for s in config_obj.basename_mapping if s.is_csig]
    elif not isolated:
        con_c_signals = sorted(get_conflicting_signals(config_obj, config_obj.signals_by_name()[datavar]), key=lambda s: s.name)
    else:
        con_c_signals = [config_obj.signals_by_name()[datavar]]

    def get_triggers_iframes_from_simulation(vcddir: str, mod_txns):
        t_dict = {txn_name: [] for txn_name in mod_txns}
        for txn_name in mod_txns:
            t_dict[txn_name].extend(load_msequences(
                        f"{vcddir}/{MSEQUENCES_FILE}", txn_name, config_obj.MSEQ_RANGE))
        raw_iframes = get_iframe_values(VCDVCD(f"{vcddir}/{config_obj.VCDFILE}"), config_obj.ISIGNALS, config_obj.SIMULATION_RANGE)
        # Add the instruction frames
        return t_dict, [canonicalize_iframe(riframe, config_obj.ISIGNALS) for riframe in raw_iframes[:-1]]
    
    def get_triggers_iframes_from_distinguisher(distlog: str, mod_txns):
        t_dict = {txn_name: [] for txn_name in mod_txns}
        with open(distlog, 'r') as fhndle:
            frames = json.load(fhndle)
            for frame in frames:
                for txn_name in mod_txns:
                    t_dict[txn_name].append(txn_name not in frame["bad_txns"])
            return t_dict, [canonicalize_iframe({config_obj.isignals_by_name()[sname]: val 
                for (sname, val) in frame["iframe"].items()}, config_obj.ISIGNALS)
                for frame in frames
            ]            

    txn_map = config_obj.transactions_by_name()
    modifying_txns_classes = [[txn_name for txn_name in txn_map if sig in txn_map[txn_name].modifies] for sig in con_c_signals]
    modifying_txns = sorted(list(set([txn_ for txn_class in modifying_txns_classes for txn_ in txn_class])))
    mseqs = []
    trigger_dict = {txn_name: [] for txn_name in modifying_txns}
    iframes = []

    # Get constraints from the VCD traces and generated M sequences
    for loc in loc_vcd:
        # If there is a test subdirectory, then move into it
        for filename in os.listdir(loc):
            vcddir = os.path.join(loc, filename)
            if os.path.isdir(vcddir):
                # Add the modifying transactions
                _trigger_dict, _iframes = get_triggers_iframes_from_simulation(vcddir, modifying_txns)
                for txn_name in modifying_txns:
                    trigger_dict[txn_name].extend(_trigger_dict[txn_name])
                iframes.extend(_iframes)
        # Check whether there is a msequence file in the current directory
        vcddir = loc
        if os.path.isfile(f"{vcddir}/{MSEQUENCES_FILE}") and os.path.isfile(f"{vcddir}/{config_obj.VCDFILE}"):
            # There is a msequence and VCD file here
            _trigger_dict, _iframes = get_triggers_iframes_from_simulation(vcddir, modifying_txns)
            for txn_name in modifying_txns:
                trigger_dict[txn_name].extend(_trigger_dict[txn_name])
            iframes.extend(_iframes)

    # Get constraints from the distinguishing examples
    if dist_file != "":
        _trigger_dict, _iframes = get_triggers_iframes_from_distinguisher(dist_file, modifying_txns)
        for txn_name in modifying_txns:
            trigger_dict[txn_name].extend(_trigger_dict[txn_name])
        iframes.extend(_iframes)

    if debug:
        print("M Sequences")
    for txn_name in modifying_txns:
        if debug:
            print(f"Txn name {txn_name}")
            print_blist(trigger_dict[txn_name])
        mseqs.append(trigger_dict[txn_name])
    predframes = list(map(list,
        zip(*[apply_all(iframe, config_obj.PREDICATES) for iframe in iframes])))
    if debug:
        print("Predicate frames")
        for (pred, predframe) in zip(config_obj.PREDICATES, predframes):
            print(pred)
            print_blist(predframe)
    class_name = 'synthclass__' + '__'.join([s.name for s in con_c_signals])
    if collapse_opt:
        (new_modifying_txns, new_modifying_txns_classes, new_mseqs) = collapse_equivalent(modifying_txns, modifying_txns_classes, mseqs)
        synthesizer.gen_control_synthesis_script(new_modifying_txns, new_modifying_txns_classes, new_mseqs, predframes, f"{synth_dir}/{class_name}.smt2")
    else:
        # synthesizer.gen_control_synthesis_script(modifying_txns, modifying_txns_classes, mseqs, predframes, f"{synth_dir}/{class_name}.smt2")
        indeps = [(config_obj.PREDICATES.index(p1), config_obj.PREDICATES.index(p2)) for (p1, p2) in config_obj.INDEPENDENCES]
        guards = synthesizer.run_control_synthesis_cvc5(modifying_txns, modifying_txns_classes, mseqs, config_obj.PREDICATES, predframes, indeps)
        if len(guards) == 0:
            logging.error(f"Could not synthesize a guard for {class_name}")
        else:
            logging.info(f"Synthesized guards for {class_name}")
            for (txn_name, guard) in guards.items():
                logging.info(f"Txn {txn_name} guard {guard}")
            # Write the guards to a file
            mapping = config_obj.get_extension_mapping("")
            with open(f"{synth_dir}/{config_obj.NAME}.aul", 'w') as fhndle:
                fhndle.write("// Synthesized guards for {} \n".format(class_name))
                fhndle.write("// This file was generated by PAUL: {} \n".format(datetime.datetime.now()))
                for (txn_name, guard) in guards.items():
                    fhndle.write("[{}] {{\n // {} \n {} \n}}\n\n".format(
                        guard, txn_name,
                        config_obj.transactions_by_name()[txn_name].vstmts(mapping, mapping).__inject__()))

def collapse_equivalent(mod_txns: List[str], modifying_txns_classes: List[List[str]], mseqs: List[List[bool]]):
    equiv_classes = {}
    for mod_txn, mseq in zip(mod_txns, mseqs):
        footprint = ''.join(['1' if b else '0' for b in mseq])
        if footprint in equiv_classes:
            equiv_classes[footprint].append(mod_txn)
        else:
            equiv_classes[footprint] = [mod_txn]
    collapsed_map = {}
    new_mod_txns = []
    new_mseqs = []
    for (fp, eclass) in equiv_classes.items():
        for txn_name in eclass:
            collapsed_map[txn_name] = '__'.join(eclass)
        new_mod_txns.append('__'.join(eclass))
        new_mseqs.append([True if f == '1' else False for f in fp])
    new_modifying_txns_classes = []
    for txn_class in modifying_txns_classes:
        new_modifying_txns_classes.append([collapsed_map[txn_] for txn_ in txn_class])
    return (new_mod_txns, new_modifying_txns_classes, new_mseqs)

def run_distinguish(config_obj: ProcessorConfig, loc_vcd: str, timestep: int, debug: bool):
    vcddir = loc_vcd
    vcdtrace = VCDVCD(f"{vcddir}/{config_obj.VCDFILE}")
    time = timestep
    distrecord, cmds = generate_msequences_distinguisher_triple(config_obj, f"{vcddir}/{MSEQUENCES_FILE}", time)
    # distlogfile = f"{vcddir}/{DISTINGUISHER_LOG}"
    # if not os.path.isfile(distlogfile):
    #     data = [distrecord]
    #     with open(distlogfile, 'w') as fhndle:
    #         json.dump(data, fhndle)
    # else:
    #     # If filename exists
    #     with open(distlogfile, 'r+') as fhndle:
    #         file_data = json.load(fhndle)
    #         file_data.append(distrecord)
    #         fhndle.seek(0)
    #         json.dump(file_data, fhndle, indent=4)
    # if debug:
    #     print(cmds)
    dist_code = config_obj.make_distinguishblock_by_prepost(*cmds)
    return_code = config_obj.run_distinguisher(vcddir, distrecord["uid"], dist_code)
    # Return code is 2 for FAIL and 0 for PASS (symbiyosys specific)
    if return_code == 0:
        logging.info("Could not distinguisher no distinguishing input for script {vcddir}_{time}")
    elif return_code == 2:
        # Distinguishing succeeded (save the vcd trace)
        logging.info("Distinguishing successful trace generated")

def run_analyzedist(config_obj: ProcessorConfig, loc_vcd: str, dist_file: str):
    distrecord = {}
    vcdfile = f"{loc_vcd}/{DISTINGUISHER_TRACE}"
    discrimatorylogfile = dist_file
    # Load the generated trace and invoke discriminator
    iframe_repr, bad_txns = find_bad_transactions(config_obj, VCDVCD(f"{vcdfile}"))
    distrecord["bad_txns"] = bad_txns
    distrecord["iframe"] = iframe_repr
    with open(discrimatorylogfile, 'r+') as fhndle:
        file_data = json.load(fhndle)
        file_data.append(distrecord)
        fhndle.seek(0)
        json.dump(file_data, fhndle, indent=4)

def run_cover(config_obj: ProcessorConfig, loc_vcd: str, txn1: List[str], txn2: List[str]):
    vcddir = loc_vcd
    cmds = generate_txn_cover_triple(config_obj, txn1, txn2)
    dist_code = config_obj.make_distinguishblock_by_prepost(*cmds)
    return_code = config_obj.run_distinguisher(vcddir, "cover", dist_code)
    # Return code is 2 for FAIL and 0 for PASS (symbiyosys specific)
    if return_code == 0:
        logging.info("Could not cover no covering input for script")
    elif return_code == 2:
        # Distinguishing succeeded (save the vcd trace)
        logging.info("Distinguishing successful trace generated")

def get_cover_instructions(config_obj : ProcessorConfig, predicates: Formula, loc_vcd: str, ninstr: int, interesting_frames: List[List[bool]]):
        foundsoln, instructions = synthesizer.gen_instruction_sequence_script(ninstr, predicates, interesting_frames, ".temp/instrs.smt2")
        if not foundsoln:
            print(f"No solution to predicate signatures for num_instructions = {ninstr}")
        config_obj.generate_test(loc_vcd, lambda: config_obj.make_testblock_by_program(instructions))

if __name__ == '__main__':
    main()
