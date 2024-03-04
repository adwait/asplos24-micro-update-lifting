
from dataclasses import dataclass
import logging

from enum import Enum


class VBases (Enum):
    '''
        The main class for the embedded DSL.

        Maintains context such as definitions
        and statements.
    '''    
    BIN = 0
    DEC = 1
    HEX = 2
    OCT = 3
    def __inject__(self, pref_=""):
        if (self.value == 0):
            return 'b'
        elif (self.value == 1):
            return 'd'
        elif (self.value == 2):
            return 'x'
        elif (self.value == 3):
            return 'o'

class VOperators:
    OpMapping = {
        "or"        : ("||",    -1),
        "and"       : ("&&",    -1),
        "bvadd"     : ("+",     2),
        "bvsub"     : ("-",     2),
        "bvand"     : ("&",     2),
        "bvor"      : ("|",     2),
        "bvxor"     : ("^",     2),
        "bvnot"     : ("~",     1),
        "bvugt"     : (">",     2),
        "bvugte"    : (">=",    2),
        "bvult"     : ("<",     2),
        "bvulte"    : ("<=",    2),
        "eq"        : ("==",    2),
        "neq"       : ("!=",    2),
        "not"       : ("!",     1),
        "implies"   : ("==>",   2),
    }
    def __init__(self, op : str) -> None:
        self.op = op
    def __inject__(self, pref_=""):
        return VOperators.OpMapping[self.op][0]


class VExpr ():
    '''
        Abstract VExpr class:
            boolean expressions
            bitvector expressions
    '''
    def __init__(self) -> None:
        pass
    def __inject__ (self, pref_="") -> str:
        raise NotImplementedError
    def __eq__(self, other):
        return VOpExpr("eq", [self, other])
    def __neq__(self, other):
        return VOpExpr("neq", [self, other])
    def __invert__(self):
        return VOpExpr("bvnot", [self])
    def __gt__(self, other):
        return VOpExpr("bvugt", [self, other])
    def __ge__(self, other):
        return VOpExpr("bvugte", [self, other])
    def __lt__(self, other):
        return VOpExpr("bvult", [self, other])
    def __le__(self, other):
        return VOpExpr("bvulte", [self, other])
    def __add__(self, other):
        return VOpExpr("bvadd", [self, other])
    def __sub__(self, other):
        return VOpExpr("bvsub", [self, other])
    def __or__(self, other):
        return VOpExpr("bvor", [self, other])
    def __and__(self, other):
        return VOpExpr("bvand", [self, other])
    def __xor__(self, other):
        return VOpExpr("bvxor", [self, other])

class ElemType (Enum):
    NONE = 0
    SIGNAL = 1
    REG = 2
    WIRE = 3

@dataclass
class VType():
    width  : int = 1
    size   : int = 1

class VElem(VExpr):
    def __init__(self) -> None:
        self.name : str = None
        self.type : VType = None
        self.vartype : ElemType = None
    def __inject__(self, pref_="") -> str:
        raise NotImplementedError
'''
    A (sequential) register element.
'''
class VReg(VElem):
    def __init__(self, name_, width_, size_=1, init_value_=0, anyconst_=True) -> None:
        super().__init__()
        self.name : str = name_
        self.anyconst = anyconst_
        self.init_value = init_value_
        self.type = VType(width_, size_)
        self.vartype = ElemType.REG
        _ = VDecl(self)
    def __inject__(self, pref_=""):
        return "{}".format(self.name)
'''
    A (combinational) wire element.
'''
class VWire(VExpr):
    def __init__(self, name_, width_, size_=1, expr_=None) -> None:
        super().__init__()
        self.name : str = name_
        self.expr = expr_
        self.type = VType(width_, size_)
        self.vartype = ElemType.WIRE
        _ = VDecl(self)
    def __inject__(self, pref_=""):
        return "{}".format(self.name)
'''
    An existing named element from the design.
'''
class VSignal(VElem):
    def __init__(self, name_, width_=1, size_=1, path_=[]) -> None:
        super().__init__()
        self.name : str = name_
        self.type = VType(width_, size_)
        self.path = path_
        self.vartype = ElemType.SIGNAL
    def __inject__(self, pref_=""):
        return pref_ + '.'.join(self.path) + self.name

class VLiteral(VExpr):
    def __init__(self, name_):
        super().__init__()
        self.name = name_ if isinstance(name_, str) else str(name_)
    def __inject__(self, pref_=""):
        return self.name
VBoolTrue   = VLiteral("1")
VBoolFalse  = VLiteral("0")

'''
    A constant value.
'''
class VBVConst(VExpr):
    def __init__(self, val_ : str, width_, base_ : VBases = VBases.DEC):
        super().__init__()
        self.val  = val_
        self.width = width_
        self.base = base_
        self.type = VType(width_, 1)
    def __inject__(self, pref_="") -> str:
        if self.width == 0:
            return "{}".format(self.val)
        else:
            return "{}'{}{}".format(
                self.width, self.base.__inject__(pref_), self.val
            )

class VOpExpr(VExpr):
    def __init__(self, op, children):
        super().__init__()
        self.op = op
        self.children = [VLiteral(str(child)) if isinstance(child, int) else child for child in children]
    def __inject__(self, pref_="") -> str:
        children_code = ["({})".format(child.__inject__(pref_)) for child in self.children]
        oprep = VOperators.OpMapping[self.op]
        if oprep[1] == 1:
            assert len(children_code) == 1, "Unary operator must have one argument"
            return "{} {}".format(oprep[0], children_code[0])
        if oprep[1] == 2:
            assert len(children_code) == 2, "Unary operator must have two arguments"
            return "{} {} {}".format(children_code[0], oprep[0], children_code[1])
        if oprep[1] == -1:
            return (" "+oprep[0]+" ").join(children_code)
        else:
            logging.error("Operator arity not yet supported in __inject__vlog__")

class VTernary(VExpr):
    def __init__(self, ifcond : VExpr, texpr : VExpr, eexpr : VExpr):
        self.ifcond = ifcond
        self.texpr  = texpr
        self.eexpr  = eexpr
    def __inject__(self, pref_="") -> str:
        return "({}) ? ({}) : ({})".format(
            self.ifcond.__inject__(pref_), self.texpr.__inject__(pref_), self.eexpr.__inject__(pref_))

class VSlice(VExpr):
    # Range is inclusive
    def __init__(self, elem : VExpr, hi, lo):
        super().__init__()
        self.hi = hi
        self.lo = lo
        self.elem = elem
    def __inject__(self, pref_=""):
        return "{}[{}:{}]".format(self.elem.__inject__(pref_), self.hi, self.lo)

class VSignExtend(VExpr):
    def __init__(self, elem : VExpr, newwidth: int, currwidth: int = 0) -> None:
        self.newwidth = newwidth
        self.elem = elem
        if isinstance(elem, VElem):
            self.currwidth = elem.type.width
        elif currwidth == 0:
            logging.error("VSignExtend with raw-literal requires current width")
        else:
            self.currwidth = currwidth
    def __inject__(self, pref_=""):
        extension = "{{ {} {{ {}[{}] }} }}".format(
            self.newwidth-self.currwidth, self.elem.__inject__(pref_), self.currwidth-1)
        return "{{ {{ {} }}, {}  }}".format(extension, self.elem.__inject__(pref_))

class VArraySelect(VExpr):
    def __init__(self, array, indices):
        self.array = VLiteral(array) if isinstance(array, str) else array
        self.indices = indices
    def __inject__(self, pref_="") -> str:
        return "{}[{}]".format(self.array.__inject__(pref_), ']['.join([ind.__inject__(pref_) for ind in self.indices]))

class VFuncApplication(VExpr):
    def __init__(self, func : str, args):
        self.func = func
        self.args = args
    def __inject__(self, pref_="") -> str:
        return "{}({})".format(self.func, ', '.join([arg.__inject__(pref_) for arg in self.args]))

'''
    Abstract base class for statements:
    assign, assume, assert, ite, sequential composition
'''
class VStatement():
    def __init__(self):
        pass
    def __inject__(self, pref_=""):
        raise NotImplementedError


'''
    Assignments of form:
    reg/wire = expr
'''
class VSAssignment(VStatement):
    """
        Sequential assignment    
    """
    def __init__(self, lhs_, rhs_ : VExpr) -> None:
        super().__init__()
        self.lhs = lhs_
        self.rhs = rhs_
    def __inject__(self, pref_=""):
        return "{} <= {};\n".format(
            self.lhs.__inject__(pref_),
            self.rhs.__inject__(pref_)
        )
class VBAssignment(VStatement):
    """
        Blocking assignment
    """
    def __init__(self, lhs_, rhs_ : VExpr) -> None:
        super().__init__()
        self.lhs = lhs_
        self.rhs = rhs_
    def __inject__(self, pref_=""):
        return "{} = {};\n".format(
            self.lhs.__inject__(pref_),
            self.rhs.__inject__(pref_)
        )

'''
    Assumption statements:
    assume (expr)
'''
class VAssume(VStatement):
    def __init__(self, expr_ : VExpr) -> None:
        super().__init__()
        self.expr = expr_
    def __inject__ (self, pref_=""):
        return "assume ({});\n".format(
            self.expr.__inject__(pref_)
        )

'''
    Assertion statements:
    assert (expr)
'''
class VAssert (VStatement):
    def __init__(self, expr_ : VExpr) -> None:
        super().__init__()
        self.expr = expr_
    def __inject__(self, pref_=""):
        return "assert ({});\n".format(
            self.expr.__inject__(pref_)
        )

'''
    Declaration statements:
    wire/reg <name> <width> (= <>)?

    Auto-generated when a new VReg / VWire is instantiated. 
    Stored in wires/regs Symtab in VFormal.
'''
class VDecl(VStatement):
    def __init__(self, obj : VElem) -> None:
        self.name = obj.name
        self.type = obj.type
        self.vartype = obj.vartype
        if self.vartype == ElemType.REG: 
            self.anyconst : bool = obj.anyconst
            self.init_value = obj.init_value
            # if self.name in VFormal.regs:
            #     logging.warn("Redeclaration of register variable {}".format(self.name))
            # else:
            #     VFormal.regs[self.name] = self
        elif self.vartype == ElemType.WIRE:
            self.expr = obj.expr
            # if self.name in VFormal.wires:
            #     logging.warn("Redeclaration of register variable {}".format(self.name))
            # else:
            #     VFormal.wires[self.name] = self
    def __inject__(self, pref_=""):
        if self.vartype == ElemType.REG:
            return "{} reg [{}:0] {} {} {};\n".format(
                "(* anyconst *)" if self.anyconst else "",
                self.type.width-1,
                self.name,
                "[0:{}]".format(self.type.size-1) if self.type.size > 1 else "",
                " = {}'b{}".format(
                    self.type.width, bin(self.init_value)[2:].zfill(self.type.width)
                ) if not self.anyconst else ""
            )
        elif self.vartype == ElemType.WIRE:
            return "wire [{}:0] {} {} {};\n".format(
                self.type.width-1,
                self.name,
                "[0:{}]".format(self.type.size-1) if self.type.size > 1 else "",
                ("= " + self.expr.__inject__(pref_)) if self.expr is not None else ""
            )
        else:
            logging.error("Unmatched case on VarType in {}".format("__inject__"))


'''
    Sequential composition of VStatements:
    <>;<>
'''
class VStmtSeq (VStatement):
    def __init__(self, stmts_) -> None:
        super().__init__()
        self.stmts = stmts_
        
    def __inject__(self, pref_="") -> None:
        return "".join(
            [stmt.__inject__(pref_) for stmt in self.stmts]
        )

'''
    If-then-else:
    if () begin <> end else begin <> end
'''
class VITE (VStatement):
    def __init__(self, cond_ : VExpr, stmtseq_t_, stmtseq_e_ = None) -> None:
        super().__init__()
        self.cond = cond_
        self.hasElse = (stmtseq_e_ is not None)
        self.stmtseq_t = stmtseq_t_
        if isinstance(stmtseq_t_, list):
            self.stmtseq_t = VStmtSeq(stmtseq_t_)
        else:
            self.stmtseq_t = stmtseq_t_
        if self.hasElse:
            if isinstance(stmtseq_e_, list):
                self.stmtseq_e = VStmtSeq(stmtseq_e_)
            else:
                self.stmtseq_e = stmtseq_e_

    '''
    if (cond) begin
    stmtseq_t
    end else begin
    stmtseq_e
    end
    '''
    def __inject__(self, pref_=""):
        if self.hasElse:
            return '''
if ({}) begin
{}
end else begin
{}
end
'''.format(
    self.cond.__inject__(pref_),
    self.stmtseq_t.__inject__(pref_),
    self.stmtseq_e.__inject__(pref_)
)
        else:
            return '''
if ({}) begin
{}
end
'''.format(
    self.cond.__inject__(pref_),
    self.stmtseq_t.__inject__(pref_)
)

'''
    Verilog edge trigger-types
    TODO: Any other trigger types?
'''
class VEdge(Enum):
    NONEDGE = 0
    POSEDGE = 1
    NEGEDGE = 2

    def __inject__(self, pref_=""):
        if (self.value == 0):
            return ''
        elif (self.value == 1):
            return 'posedge'
        elif (self.value == 2):
            return 'negedge'
        else: 
            logging.warn("Non-matched case in VEdge.__inject__()")

'''
    Raw Verilog code injection.
'''
class VInject (VStatement):
    def __init__ (self, code_):
        self.code = code_
    def __inject__ (self):
        return self.code

'''
    VSeqElement is a VStmtSeq in a sequential code block:
    always @(trigger) begin <> end

    These are cached in stmts Symtab in VFormal.

    TODO: Other features (generalizations of always)?
'''
class VSeqElement ():
    uidGen = 0

    def __init__(self, stmtseq_, edge_=VEdge.POSEDGE, trigger_ : VExpr = VSignal(name_="clock")) -> None:
        if isinstance(stmtseq_, list):
            self.stmtseq = VStmtSeq(stmtseq_)
        else:
            self.stmtseq = stmtseq_
        self.edge = edge_
        self.trigger = trigger_
        VSeqElement.uidGen += 1
    def __inject__(self, pref_=""):
        return '''
always @({} {}) begin
{}
end
'''.format(
            self.edge.__inject__(pref_),
            self.trigger.__inject__(pref_),
            self.stmtseq.__inject__(pref_),
        )

# Tester
def main():
    v = VSignal ("fe_pc", 32)
    w = VWire("mywire", v, 32)
    # s = VSignal ("a", 4)
    c = VBVConst(200, 32, base_=VBases.HEX)
    e = (w == c)
    a = VAssert(e)
    c = VStmtSeq([a])
# if __name__ == "__main__":
#     main(argv[1:])

OpMapping = VOperators.OpMapping