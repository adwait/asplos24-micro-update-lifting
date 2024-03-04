
import aul
from aul.processor_configs import CONFIGS
import time, logging
from aul import rv32i
from random import choice, randint

import json
import os
import shutil

# Sodor 5 stage configuration
sodor5_config = CONFIGS["sodor5_rtype"]

FORMAT = '%(name)s::%(levelname)s: %(message)s'
LOGFILE = 'aul.log'
logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO)
print(f"Logging to {LOGFILE}")

TIME_LOGGER = {}

def log_timestamp(action, curr_time):
    run_time = time.time() - curr_time
    curr_time = time.time()
    TIME_LOGGER[action] = run_time


def gen_model():
    CURR_TIME = time.time()

    databasedir = "riscv-sodor-model/sodor5_traces_auto/rtype/"

    # Call the simulation script
    aul.run_simulate(sodor5_config, f"{databasedir}/", 10)
    log_timestamp("simulation", CURR_TIME)
    
    # aul.run_genmseq(sodor5_config, [f"{databasedir}/test_{i}/" for i in range(10)])
    # log_timestamp(CURR_TIME)
    # aul.run_consynth(sodor5_config, databasedir, [f"{databasedir}/test_{i}/" for i in range(10)],
    #     "", "alu_out", True)
    # log_timestamp(CURR_TIME)

    def get_instrs(test):
        return [i[1] for i in test]
    # Generate some targetted tests:
    regs_standard = [0, 1, 2, 3]
    regs_all = list(range(32))
    custom_0 = [
        rv32i.rv32i_add(choice(regs_standard), choice(regs_standard), choice(regs_standard)) for i in range(16)
    ]
    custom_1 = [
        rv32i.rv32i_add(choice(regs_standard), choice(regs_standard), choice(regs_standard)) for i in range(8)
    ] + [
        rv32i.rv32i_add(10, 11, 0), rv32i.rv32i_add(0, 12, 13)
    ] + [
        rv32i.rv32i_add(choice(regs_standard), choice(regs_standard), choice(regs_standard)) for i in range(6)
    ]
    custom_2 = [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(8)
    ] + [
        rv32i.rv32i_add(10, 11, 0), rv32i.rv32i_add(0, 12, 13)
    ] + [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(6)
    ]
    custom_3 = [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(8)
    ] + [
        rv32i.rv32i_add(10, 11, 4), rv32i.rv32i_add(11, 12, 4), rv32i.rv32i_add(4, 16, 17)
    ] + [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(5)
    ]
    custom_4 = [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(8)
    ] + [
        rv32i.rv32i_add(10, 11, 4), rv32i.rv32i_add(16, 4, 17), rv32i.rv32i_add(11, 12, 4), rv32i.rv32i_add(4, 16, 17)
    ] + [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(4)
    ]
    custom_5 = [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(8)
    ] + [
        rv32i.rv32i_add(10, 11, 4), rv32i.rv32i_add(16, 4, 4), rv32i.rv32i_add(12, 4, 7), rv32i.rv32i_add(8, 16, 17)
    ] + [
        rv32i.rv32i_add(choice(regs_all), choice(regs_all), choice(regs_all)) for i in range(4)
    ]

    # aul.run_simulate_by_program(sodor5_config, f"{databasedir}/custom_5/", get_instrs(custom_5))
    # aul.run_genmseq(sodor5_config, [f"{databasedir}/custom_{i}/" for i in range(5, 6)])
    log_timestamp("mseq_generation", CURR_TIME)


    # for sig in ["alu_op2", "alu_op1"]:
    #     aul.run_consynth(sodor5_config, databasedir, 
    #         [f"{databasedir}/test_{i}/" for i in range(10)] + [f"{databasedir}/custom_{i}/" for i in range(2, 6)],
    #         "", sig, True, True, True)
    for sig in sodor5_config.basename_mapping:
        if sig.is_csig:
            aul.run_consynth(sodor5_config, databasedir, 
                [f"{databasedir}/test_{i}/" for i in range(10)] + [f"{databasedir}/custom_{i}/" for i in range(2, 6)],
                "", sig.name, True, True, True)
    
    cdir = os.getcwd()
    os.chdir(databasedir)
    for sig in sodor5_config.basename_mapping:
        if sig.is_csig:
            os.system(f"./run_some.sh {sig.name}")
    log_timestamp("guard_synthesis", CURR_TIME)
    os.chdir(cdir)

    '''
        Equivalence proof
    '''
    # Change directory to the equivalence proof directory
    cdir = os.getcwd()
    os.chdir("riscv-sodor-model/verification/sodor_equivalence")
    os.system("time sby -f equiv.sby taskBMC12_sodor5_rtype")
    os.chdir(cdir)
    log_timestamp("equiv_proof", CURR_TIME)

    jlog = json.dumps(TIME_LOGGER, indent=4)
    with open("{}/time.log".format(databasedir), 'w') as loghandle:
        loghandle.write(jlog)

    if os.path.exists("out"):
        shutil.rmtree("out")
    shutil.copytree(databasedir, "out")

    return jlog


if __name__ == "__main__":
    print(gen_model())