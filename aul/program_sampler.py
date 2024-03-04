'''
    This generates program instances, runs them on the simulator and saves the program
        and the simulation result in directory
'''

from random import Random, randint
from typing import List
from rv32i import rv32i_nop, ITYPE_INSTS, BTYPE_INSTS, RTYPE_INSTS, rv32i_add, rv32i_addi, rv32i_beq

def sample_random_imm():
    return randint(0, 200)
def sample_random_imm_btype():
    return randint(0, 200)*4
def sample_random_rdaddr():
    return randint(0, 31)

def create_program(insts: List, fill_inst=rv32i_nop()):
    bln = 1<<(len(insts)-1).bit_length()
    prog_array = "wire [31:0] program_array [0:{}];\n".format(bln-1)
    prog_insts = []
    insts.extend([fill_inst for _ in range(bln-len(insts))])
    for i, inst in enumerate(insts):
        prog_insts.append(
            "assign program_array[{}] = {}; // {} : {:08x}\n".format(i, inst[1], inst[0], int(inst[1][4:], 2))
        )
    return "{}\n{}".format(prog_array, "".join(prog_insts))

def create_random_add_program():
    randr = Random()
    prog_array = [randr.choice([rv32i_add(sample_random_rdaddr(), sample_random_rdaddr(), sample_random_rdaddr()),
                    rv32i_addi(sample_random_imm(), sample_random_rdaddr(), sample_random_rdaddr())])
        for _ in range(8)]
    return create_program(prog_array)

def create_random_i_program():
    randr = Random()
    prog_array = [randr.choice(ITYPE_INSTS)(sample_random_imm(), sample_random_rdaddr(), sample_random_rdaddr())
        for _ in range(8)]
    return create_program(prog_array)

def create_random_i_r_program():
    randr = Random()
    prog_array = []
    for _ in range(8):
        if randr.randint(0, 1) == 0:
            inst = randr.choice(ITYPE_INSTS)
            prog_array.append(inst(sample_random_imm(),
                sample_random_rdaddr(), sample_random_rdaddr()))
        else:
            inst = randr.choice(RTYPE_INSTS)
            prog_array.append(inst(sample_random_rdaddr(),
                sample_random_rdaddr(), sample_random_rdaddr()))
    return create_program(prog_array)

def create_random_i_b_program():
    randr = Random()
    prog_array = []
    for _ in range(8):
        if randr.randint(0, 1) == 0:
            inst = randr.choice(ITYPE_INSTS)
            prog_array.append(inst(sample_random_imm(),
                sample_random_rdaddr(), sample_random_rdaddr()))
        else:
            inst = randr.choice(BTYPE_INSTS)
            prog_array.append(inst(sample_random_imm_btype(),
                sample_random_rdaddr(), sample_random_rdaddr()))
    return create_program(prog_array)

if __name__ == "__main__":
    # Create tests and run the above functions

    # p = create_program([addi(2,0,6)]*3 + [beq(-4,0,0)] + [addi(4,0,6)] + [addi(2,0,6)]*3)
    # p = create_program([addi(2,0,6)]*3 + [bne(-4,1,6)] + [addi(4,0,6)] + [addi(2,0,6)]*3)
    # p = create_program([rv32i_nop(), rv32i_addi(2,0,6), rv32i_addi(4,0,1), rv32i_xori(-4,1,6), rv32i_addi(4,0,6)] + [rv32i_addi(2,0,6)]*3)
    # p = create_program([rv32i_addi(4, 0, 1)] + [rv32i_nop()]*3 + [rv32i_sw(4, 0, 1)] + [rv32i_nop()]*3)
    # p = create_program([rv32i_nop(), rv32i_addi(2, 0, 1), rv32i_sw(4, 0, 1), rv32i_lw(4, 0, 2)] + [rv32i_nop()]*4)
    # p = create_program([rv32i_nop(), rv32i_lb(4, 0, 2), rv32i_lb(0, 2, 3), rv32i_sw(4, 0, 1)] + [rv32i_nop()]*4)
    # p = create_program([rv32i_addi(2*i, 0, i) for i in range(1,9)])
    p = create_program([rv32i_addi(2, 2, 2), rv32i_addi(2, 2, 2), rv32i_beq(-8, 2, 2), rv32i_addi(2, 0, 3), rv32i_nop(), rv32i_nop(), rv32i_nop(), rv32i_nop()])
    print(p)
    # generate_tests(NUM_ITERS, "run_IB_type", create_random_i_b_program)
