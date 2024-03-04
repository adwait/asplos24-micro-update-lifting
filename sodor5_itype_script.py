
import aul
from aul.processor_configs import CONFIGS
import time, logging
from aul import rv32i
from random import choice, randint

import json
import os
import shutil

# Sodor 5 stage configuration
sodor5_config = CONFIGS["sodor5_itype"]

TIME_LOGGER = {}

def log_timestamp(action, curr_time):
    run_time = time.time() - curr_time
    curr_time = time.time()
    TIME_LOGGER[action] = run_time

def gen_model():
    CURR_TIME = time.time()

    databasedir = "riscv-sodor-model/sodor5_traces_auto/itype/"

    FORMAT = '%(name)s::%(levelname)s: %(message)s'
    LOGFILE = 'aul.log'
    logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO)
    print(f"Logging to {LOGFILE}")

    # Call the simulation script
    aul.run_simulate(sodor5_config, f"{databasedir}/", 10)
    log_timestamp("simulation", CURR_TIME)

    # aul.run_genmseq(sodor5_config, [f"{databasedir}/test_{i}/" for i in range(2)])
    # aul.run_genmseq(sodor5_config, [f"{databasedir}/custom_{i}/" for i in range(3)])
    log_timestamp("mseq_generation", CURR_TIME)

    for sig in sodor5_config.basename_mapping:
        if sig.is_csig:
            aul.run_consynth(sodor5_config, databasedir, 
                [f"{databasedir}/custom_0/", f"{databasedir}/custom_1/", f"{databasedir}/custom_2/"] + [f"{databasedir}/test_{i}/" for i in range(10)],
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
    os.system("time sby -f equiv.sby taskBMC12_sodor5_itype")
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


