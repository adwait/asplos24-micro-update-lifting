"""
Defines predicates defined over instructions and extended to instruction frames
"""


from enum import Enum
import logging
from typing import Any, Callable, List

def get_i_imm(instr):
    return int(("{:032b}".format(instr))[0:12], 2)
def get_i_imm_sext(instr):
    i_imm = get_i_imm(instr)
    i_imm_s = i_imm if (i_imm < (1<<11)) else (i_imm | ((1<<32) - (1<<12)))
    return i_imm_s
def get_b_imm(instr):
    instr_s = "{:032b}".format(instr)
    return int(instr_s[0] + instr_s[24] + instr_s[1:7] + instr_s[20:24] + "0", 2)
def get_b_imm_sext(instr):
    b_imm = get_b_imm(instr)
    b_imm_s = b_imm if (b_imm < (1<<12)) else (b_imm | ((1<<32) - (1<<12)))
    return b_imm_s
def get_s_imm(instr):
    instr_s = "{:032b}".format(instr)
    return int(instr_s[0:7] + instr_s[20:25], 2)
def get_s_imm_sext(instr):
    s_imm = get_s_imm(instr)
    s_imm_s = s_imm if (s_imm < (1<<11)) else (s_imm | ((1<<32) - (1<<12)))
    return s_imm_s
def get_rd(instr):
    return int(("{:032b}".format(instr))[20:25], 2)
def get_rs1(instr):
    return int(("{:032b}".format(instr))[12:17], 2)
def get_rs2(instr):
    return int(("{:032b}".format(instr))[7:12], 2)
def get_opcode(instr) -> int:
    return int(("{:032b}".format(instr))[25:], 2)


class BoolOp(Enum):
    ATOM = 0
    NOT = 1
    AND = 2
    OR = 3
class Formula():
    def __init__(self, root: BoolOp, first, second = None) -> None:
        self.root = root
        self.first = first
        self.second = second
    @property
    def name(self) -> str:
        return f"formula_{hash(self)}"
    def __and__(self, other):
        return Formula(BoolOp.AND, self, other)
    def __or__(self, other):
        return Formula(BoolOp.OR, self, other)
    def __invert__(self):
        return Formula(BoolOp.NOT, self)
    def apply(self, frame):
        if self.root == BoolOp.AND:
            return self.first.apply(frame) and self.second.apply(frame)
        elif self.root == BoolOp.OR:
            return self.first.apply(frame) or self.second.apply(frame)
        elif self.root == BoolOp.NOT:
            return not self.first.apply(frame)
        else:
            return self.apply(frame)
    @property
    def depth(self) -> int:
        if self.root == BoolOp.ATOM or self.root == BoolOp.NOT:
            return self.first.depth
        else:
            return max(self.first.depth, self.second.depth)
    def get_constraint(self, frame):
        if self.root == BoolOp.AND:
            fc = self.first.get_constraint(frame)
            sc = self.second.get_constraint(frame)
            return f"(and {fc} {sc})"
        elif self.root == BoolOp.OR:
            fc = self.first.get_constraint(frame)
            sc = self.second.get_constraint(frame)
            return f"(or {fc} {sc})"
        elif self.root == BoolOp.NOT:
            fc = self.first.get_constraint(frame)
            return f"(not {fc})"
        else:
            return self.get_constraint(frame)
    def __str__(self):
        if self.root == BoolOp.AND:
            return f"({self.first} & {self.second})"
        elif self.root == BoolOp.OR:
            return f"({self.first} | {self.second})"
        elif self.root == BoolOp.NOT:
            return f"~{self.first}"
        else:
            return f"({self.first})"

class Predicate(Formula):
    '''
        A predicate takes as input a frame and returns a boolean
        specifying whether some property holds over that frame
    '''
    def __init__(self, _name: str, _pred: Callable[[Any], bool], _constraint: Callable[[Any], str]):
        super().__init__(BoolOp.ATOM, _name)
        self._name   = _name
        self._pred   = _pred
        self._constraint = _constraint
    @property
    def name(self) -> str:
        return self._name
    def apply(self, frame):
        return self._pred(frame)
    def get_constraint(self, frame):
        if self._constraint is None:
            logging.error("Cannot constrain: constraint mappng not specified")
        return self._constraint(frame)
    def __str__(self):
        return self.name

class PipelinePredicate(Predicate):
    '''
        A predicate specialized to pipeline structures
    '''
    def __init__(self, _name: str, _pred: Callable[[Any], bool], _depth: int, _constraint: Callable[[Any], str] = None):
        super().__init__(_name, _pred, _constraint)
        self._depth = _depth
    @property
    def depth(self) -> int:
        ''' What is the depth of the pipeline that this predicate requires '''
        return self._depth

# class UCPredicate(Predicate):
#     '''
#         An unconstrained value (which can allow slack in the synthesis runtime)
#     '''
#     def __init__(self, _name: str):
#         super().__init__(_name, lambda _: 'x', lambda _: 'x')
#     def get_constraint(self, _):
#         logging.error("Get constraint not defined for UCPredicates")
#     def apply(self, _):
#         return 'x'

OPCODE_ALUR = 51
OPCODE_ALUI = 19
OPCODE_L    = 3
OPCODE_S    = 35
OPCODE_B    = 99
OPCODE_JAL  = 111
OPCODE_JALR = 103

def filter_xz(p):
    def wrapper_filter_xz(*args, **kwargs):
        if any([isinstance(a, str) for a in args]):
            return False
        return p(*args, **kwargs)
    return wrapper_filter_xz

@filter_xz
def is_i_type(i0):
    return get_opcode(i0) in [OPCODE_ALUI, OPCODE_L, OPCODE_JALR]
@filter_xz
def is_r_type(i0):
    return get_opcode(i0) == OPCODE_ALUR
@filter_xz
def is_alui(i0):
    return get_opcode(i0) == OPCODE_ALUI
@filter_xz
def is_alur(i0):
    return get_opcode(i0) == OPCODE_ALUR
@filter_xz
def is_load(i0):
    return get_opcode(i0) == OPCODE_L
@filter_xz
def is_store(i0):
    return get_opcode(i0) == OPCODE_S
@filter_xz
def is_branch(i0):
    return get_opcode(i0) == OPCODE_B
@filter_xz
def check_rs1_dep(i0, i1):
    return get_rs1(i0) == get_rd(i1)
@filter_xz
def check_rs2_dep(i0, i1):
    return get_rs2(i0) == get_rd(i1)
@filter_xz
def is_4033(i0):
    return int("4033", 16) == i0
@filter_xz
def writes_to_zero(i0):
    return get_rd(i0) == 0
@filter_xz
def reads1_from_zero(i0):
    return get_rs1(i0) == 0
@filter_xz
def reads2_from_zero(i0):
    return get_rs2(i0) == 0


def apply_all(frame, predicate_list: List[Predicate]):
    return [p.apply(frame) for p in predicate_list]
