"""
    This module defines the space of RV32I (riscv user, integer ISA)
"""

import logging


def rtype(funct7, rs2, rs1, funct3, rd, opcode):
    return "32'b{:07b}{:05b}{:05b}{:03b}{:05b}{:07b}".format(
        funct7, rs2, rs1, funct3, rd, opcode
    )
def itype(imm, rs1, funct3, rd, opcode):
    if abs(imm) > (1<<11):
        logging.error("Immediate value out of limits")
    if imm >= 0:
        imm_sign = imm
    else:
        imm_sign = imm+(1<<11)
    return "32'b{:012b}{:05b}{:03b}{:05b}{:07b}".format(
        imm_sign, rs1, funct3, rd, opcode
    )
def btype(imm, rs2, rs1, funct3, opcode):
    if imm >= 0:
        imm_sign = int(imm/2)
    else:
        imm_sign = 2**12+int(imm/2)
    imm_parsed = "{:012b}".format(imm_sign)
    return "32'b{}{:05b}{:05b}{:03b}{}{:07b}".format(
        (imm_parsed[0]+imm_parsed[2:8]), rs2, rs1, funct3, (imm_parsed[8:]+imm_parsed[1]), opcode
    )
def stype(imm, rs2, rs1, funct3, opcode):
    imm_parsed = "{:012b}".format(imm)
    return "32'b{}{:05b}{:05b}{:03b}{}{:07b}".format(
        imm_parsed[0:7], rs2, rs1, funct3, imm_parsed[7:], opcode
    )

# Immediate instructions
def rv32i_addi(imm, rs1, rd):
    return ("addi r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 0, rd, 19))
def rv32i_xori(imm, rs1, rd):
    return ("xori r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 4, rd, 19))
def rv32i_ori(imm, rs1, rd):
    return ("ori r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 6, rd, 19))
def rv32i_andi(imm, rs1, rd):
    return ("andi r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 7, rd, 19))
def rv32i_slli(imm, rs1, rd):
    imm = (imm & 31)
    return ("slli r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 1, rd, 19))
def rv32i_srli(imm, rs1, rd):
    imm = (imm & 31)
    return ("srli r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 5, rd, 19))
def rv32i_srai(imm, rs1, rd):
    imm = ((imm & 31) | (1 << 10))
    return ("srai r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 5, rd, 19))
def rv32i_slti(imm, rs1, rd):
    return ("slti r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 2, rd, 19))
def rv32i_sltiu(imm, rs1, rd):
    return ("sltiu r{} r{} {}".format(rd, rs1, imm), itype(imm, rs1, 3, rd, 19))

# Register-register instructions
def rv32i_add(rs1, rs2, rd):
    return ("add r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 0, rd, 51))
def rv32i_sub(rs1, rs2, rd):
    return ("sub r{} r{} r{}".format(rd, rs1, rs2), rtype((1 << 5), rs2, rs1, 0, rd, 51))
def rv32i_xor(rs1, rs2, rd):
    return ("xor r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 4, rd, 51))
def rv32i_or(rs1, rs2, rd):
    return ("or r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 6, rd, 51))
def rv32i_and(rs1, rs2, rd):
    return ("and r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 7, rd, 51))
def rv32i_sll(rs1, rs2, rd):
    return ("sll r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 1, rd, 51))
def rv32i_srl(rs1, rs2, rd):
    return ("srl r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 5, rd, 51))
def rv32i_sra(rs1, rs2, rd):
    return ("sra r{} r{} r{}".format(rd, rs1, rs2), rtype((1 << 5), rs2, rs1, 5, rd, 51))
def rv32i_slt(rs1, rs2, rd):
    return ("slt r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 2, rd, 51))
def rv32i_sltu(rs1, rs2, rd):
    return ("sltu r{} r{} r{}".format(rd, rs1, rs2), rtype(0, rs2, rs1, 3, rd, 51))


# Branching instructions
def rv32i_beq(imm, rs1, rs2):
    return ("beq r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 0, 99))
def rv32i_bne(imm, rs1, rs2):
    return ("bne r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 1, 99))
def rv32i_blt(imm, rs1, rs2):
    return ("blt r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 4, 99))
def rv32i_bge(imm, rs1, rs2):
    return ("bge r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 5, 99))
def rv32i_bltu(imm, rs1, rs2):
    return ("bltu r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 6, 99))
def rv32i_bgeu(imm, rs1, rs2):
    return ("bgeu r{} r{} {}".format(rs1, rs2, imm), btype(imm, rs2, rs1, 7, 99))

# NOP
def rv32i_nop():
    return ("nop", "32'b00000000000000000000000000010011")

# Memory instructions
# Loads
def rv32i_lb(imm, rs1, rd):
    return ("lb r{} r{}({})".format(rd, rs1, imm), itype(imm, rs1, 0, rd, 3))
def rv32i_lh(imm, rs1, rd):
    return ("lh r{} r{}({})".format(rd, rs1, imm), itype(imm, rs1, 1, rd, 3))
def rv32i_lw(imm, rs1, rd):
    return ("lw r{} r{}({})".format(rd, rs1, imm), itype(imm, rs1, 2, rd, 3))
def rv32i_lbu(imm, rs1, rd):
    return ("lbu r{} r{}({})".format(rd, rs1, imm), itype(imm, rs1, 4, rd, 3))
def rv32i_lhu(imm, rs1, rd):
    return ("lhu r{} r{}({})".format(rd, rs1, imm), itype(imm, rs1, 5, rd, 3))
# Stores
def rv32i_sb(imm, rs1, rs2):
    return ("sb r{}({}) r{}".format(rs1, imm, rs2), stype(imm, rs2, rs1, 0, 35))
def rv32i_sh(imm, rs1, rs2):
    return ("sb r{}({}) r{}".format(rs1, imm, rs2), stype(imm, rs2, rs1, 1, 35))
def rv32i_sw(imm, rs1, rs2):
    return ("sw r{}({}) r{}".format(rs1, imm, rs2), stype(imm, rs2, rs1, 2, 35))

def rv32i_ecall():
    return ("ecall", itype(0, 0, 0, 0, 115))

ITYPE_INSTS = [
    rv32i_addi, rv32i_xori, rv32i_ori, rv32i_andi, rv32i_slli,
    rv32i_srli, rv32i_srai, rv32i_slti, rv32i_sltiu
]
RTYPE_INSTS = [
    rv32i_add, rv32i_sub, rv32i_xor, rv32i_or, rv32i_and, rv32i_sll,
    rv32i_srl, rv32i_sra, rv32i_slt, rv32i_sltu
]
BTYPE_INSTS = [
    rv32i_beq, rv32i_bne, rv32i_blt, rv32i_bge,
    rv32i_bltu, rv32i_bgeu
]
