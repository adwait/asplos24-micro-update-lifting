
import aul
from aul.processor_configs import CONFIGS
import time
import logging
import json
import os 
import shutil

cva6_wbuffer_config = CONFIGS['cva6_wbuffer']

TIME_LOGGER = {}

def log_timestamp(action, curr_time):
    run_time = time.time() - curr_time
    curr_time = time.time()
    TIME_LOGGER[action] = run_time

def gen_model():
    CURR_TIME = time.time()

    databasedir = "cva6-model-runs/wbuffer_traces"

    FORMAT = '%(name)s::%(levelname)s: %(message)s'
    LOGFILE = 'aul.log'
    logging.basicConfig(format=FORMAT, filename=LOGFILE, level=logging.INFO)
    print(f"Logging to {LOGFILE}")

    # Call the simulation script
    aul.run_simulate(cva6_wbuffer_config, f"{databasedir}/", 10)
    log_timestamp("simulation", CURR_TIME)

    aul.run_genmseq(cva6_wbuffer_config, [f"{databasedir}/test_{i}/" for i in range(10)])
    log_timestamp("mseq_generation", CURR_TIME)

    aul.run_consynth(cva6_wbuffer_config, databasedir,
        [f"{databasedir}/test_{i}/" for i in range(10)],
        "", "wbuffer", False)
    log_timestamp("guard_synthesis", CURR_TIME)

    '''
        Equivalence proof
    '''
    # Change directory to the equivalence proof directory
    cdir = os.getcwd()
    os.chdir("cva6-model/verification/wbuffer")
    os.system("time sby -f proofs_wbuffer.sby taskBMC15_equiv_wbuffer")
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