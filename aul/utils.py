'''
    Random utilities that are then refactored into their own files
'''

from typing import List


NUM_REGS    = 32
WORD_SIZE   = 32

UNCONSTRAINED = '__AUL__unconstrained__value__'

class BColors:
    ''' FOr pretty printing '''
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_blist(blist: List[bool]):
    ''' Prints color annotated list of booleans '''
    print(''.join([(BColors.OKGREEN + "T" + BColors.ENDC) 
        if b else (BColors.FAIL + "F" + BColors.ENDC) for b in blist]))

def print_feature_map(df):
    ''' Print several features '''
    for feat in df:
        print("For feature {}".format(feat.name))
        print_blist(df[feat])

def generate_reg_flattening():
    wires = []
    assigns = []
    for i in range(NUM_REGS):
        wires.append("wire [31:0] \\regfile[{}] ;\n".format(i))
        assigns.append("assign \\regfile[{}] = regfile[{}] ;\n".format(i, i))
    print(''.join(wires) + '\n' + ''.join(assigns))

# Filenames:
DISTINGUISHER_TRACE = "disttrace.vcd"
DISTINGUISHER_LOG   = "distlog.json"
MSEQUENCES_FILE     = "msequences.json"