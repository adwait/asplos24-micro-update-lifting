
import aul
from aul.processor_configs import CONFIGS
import time
import logging
import random
import json
import os
import shutil

cva6_lsu_config = CONFIGS['cva6_lsu_2']
SEED = 710

random.seed(SEED)

TIME_LOGGER = {}

def log_timestamp(action, curr_time):
    run_time = time.time() - curr_time
    curr_time = time.time()
    TIME_LOGGER[action] = run_time


def get_model():
    CURR_TIME = time.time()

    databasedir = "cva6-model-runs/lsu_traces/lsu_traces_2"

    FORMAT = '%(name)s::%(levelname)s: %(message)s'
    LOGFILE = 'aul.log'
    logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO)
    print(f"Logging to {LOGFILE}")

    '''
        Random simulation and genmseq
    '''
    # Call the simulation script
    aul.run_simulate(cva6_lsu_config, f"{databasedir}/", 10)
    log_timestamp("simulation", CURR_TIME)
    aul.run_genmseq(cva6_lsu_config, [f"{databasedir}/test_{i}/" for i in range(10)])
    log_timestamp("mseq_generation", CURR_TIME)


    '''
        Guard synthesis
    '''
    aul.run_consynth(cva6_lsu_config, databasedir,
        [f"{databasedir}/test_{i}/" for i in range(1)],
        "", "", True)
    log_timestamp("guard_synthesis", CURR_TIME)


    '''
        Equivalence proof
    '''
    # Change directory to the equivalence proof directory
    cdir = os.getcwd()
    os.chdir("cva6-model/verification/cva6_equivalence")
    os.system("time sby -f equiv.sby taskBMC15_equiv_lsu")
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
    print(get_model())