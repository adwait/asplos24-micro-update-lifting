
import aul
from aul.processor_configs import CONFIGS
import time, logging
from aul import rv32i
from random import choice, randint

import json
import os
import shutil

# Sodor 5 stage configuration
sodor5_config = CONFIGS["sodor5_ilstype"]

TIME_LOGGER = {}

def log_timestamp(action, curr_time):
    run_time = time.time() - curr_time
    curr_time = time.time()
    TIME_LOGGER[action] = run_time

def gen_model():
    CURR_TIME = time.time()
    databasedir = "riscv-sodor-model/sodor5_traces_auto/ilstype/"

    FORMAT = '%(name)s::%(levelname)s: %(message)s'
    LOGFILE = 'aul.log'
    logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO)
    print(f"Logging to {LOGFILE}")

    # # Call the simulation script
    # aul.run_simulate(sodor5_config, f"{databasedir}/", 10)
    # log_timestamp(CURR_TIME)

    # aul.run_genmseq(sodor5_config, [f"{databasedir}/test_{i}/" for i in range(10)])
    # log_timestamp(CURR_TIME)

    def get_instrs(test):
        return [i[1] for i in test]

    # Generate some targetted tests:
    regs_standard = [0, 1, 2]
    test_0_reg_rd_data_in = [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(8)
    ] + [
        rv32i.rv32i_addi(7, 0, 4), rv32i.rv32i_addi(149, 13, 6), rv32i.rv32i_lb(7, 0, 3), rv32i.rv32i_lb(7, 0, 3) 
    ] + [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(4)
    ]

    test_0_exe_reg_wbaddr = [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(8)
    ] + [
        rv32i.rv32i_addi(7, 0, 4), rv32i.rv32i_addi(149, 13, 6), rv32i.rv32i_lb(7, 0, 3), rv32i.rv32i_addi(7, 3, 4) 
    ] + [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(4)
    ]

    test_0_decode = [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(8)
    ] + [
        rv32i.rv32i_addi(7, 0, 4), rv32i.rv32i_addi(149, 13, 6), rv32i.rv32i_lb(7, 0, 3), rv32i.rv32i_sb(18, 0, 3)
    ] + [
        rv32i.rv32i_addi(randint(0, 1 << 10), choice(regs_standard), choice(regs_standard)) for i in range(4)
    ]

    # aul.run_simulate_by_program(sodor5_config, f"{databasedir}/custom_0_decode/", get_instrs(test_0_decode))
    # aul.run_genmseq(sodor5_config, [f"{databasedir}/custom_0_decode/"])
    # log_timestamp(CURR_TIME)

    # aul.run_consynth(sodor5_config, databasedir, 
    #     # [f"{databasedir}/custom_0/"] + 
    #     [f"{databasedir}/test_{i}/" for i in range(10)] + [f"{databasedir}/custom_0_reg_rd_data_in/", f"{databasedir}/custom_0_exe_reg_wbaddr/"],
    #     "", "regfile", True, True, True)
    # log_timestamp(CURR_TIME)

    aul.run_consynth(sodor5_config, databasedir, 
        # [f"{databasedir}/custom_0/"] + 
        [f"{databasedir}/test_{i}/" for i in range(10)] + [f"{databasedir}/custom_0_reg_rd_data_in/", f"{databasedir}/custom_0_exe_reg_wbaddr/", f"{databasedir}/custom_0_decode/"],
        "", "alu_op2", True, True, True)
    log_timestamp(CURR_TIME)

    '''
        Equivalence proof
    '''
    # Change directory to the equivalence proof directory
    cdir = os.getcwd()
    os.chdir("riscv-sodor-model/verification/sodor_equivalence")
    os.system("time sby -f equiv.sby taskBMC12_sodor5_ilstype")
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