# from __future__ import annotations
import logging
from typing import Callable, List, Union, Dict
from dataclasses import dataclass
from aul import veriloggen
from enum import Enum
import collections

from copy import deepcopy


class SignalConnect(Enum):
    """
    In terms of verification what kind of a signal is this?
        Signals can either:
            - map to some signal and be held in correspondence with it (C)
            - map to ome signal in the design (D)
            - be an external (control) signal (E)
    """
    CSIG = 0
    DSIG = 1
    ESIG = 2
@dataclass
class SignalSig:
    """
    Input and output types for a Signal object. (also only relevant for maps)
    """
    inw         : Union[int, None]
    outw        : int
    styp        : SignalConnect
    # behaviour is 'z' if the default value is just the value at the previous cycle,
    #   otherwise it is some int if it 'x' then it means that it should be actively driven
    behaviour   : Union[str, int] = "x"
class Signal():
    """
    This class represents an individual Signal captured in the abstract model.
    It can either be an individual Signal (BV) or a map (BV->BV).
    """
    def __init__(self, name, sig : SignalSig, initial=None):
        """ This is a signal. """
        if (sig.behaviour != 'z' and sig.behaviour != 'x') or sig.styp == SignalConnect.ESIG:
            logging.error('While initializing Signal %s: currently default values or externals are not supported', name)
        self.name = name
        self.initial = initial
        self.sig = sig
    @property
    def is_typ_sig(self):
        ''' A register signal (bv) '''
        return self.sig.inw is None
    @property
    def is_typ_map(self):
        ''' A memory signal (map from bv to bv) '''
        return self.sig.inw is not None
    @property
    def inw(self):
        ''' Get the inputs width of the signal '''
        return self.sig.inw
    @property
    def outw(self):
        ''' Get the output width of the signal '''
        return self.sig.outw
    @property
    def is_csig(self):
        ''' Signals that correspond witih the design (and are held for equality) '''
        return self.sig.styp == SignalConnect.CSIG
    @property
    def is_dsig(self):
        ''' Signals that are sampled from the design (no check for equality) '''
        return self.sig.styp == SignalConnect.DSIG
    @property
    def is_esig(self):
        ''' Signals that external to the design (no relation with design) '''
        return self.sig.styp == SignalConnect.ESIG
    def __repr__(self):
        return self.name
    @property
    def holds_value(self):
        ''' Does this signal preserve its value when not being actively driven? '''
        return self.sig.behaviour == "z"
    @property
    def default(self):
        ''' What is the default value that it holds? '''
        return self.sig.behaviour


class MopBehaviour(Enum):
    """
    Either this is a sequential element, or it is a combinational element, which always executes
    """
    SEQ = 0
    COM = 1
@dataclass
class MopSig:
    """ Input, output, uses and functional behaviour of this mop. """
    uses        : List[Signal]
    modifies    : List[Signal]
    behaviour   : MopBehaviour

class Mop():
    """ A micro-update, transaction, micro-operation. """
    def __init__(self, name: str, trans, uses: List[Signal], modifies: List[Signal],
            behaviour: MopBehaviour, vstmts: Callable[[str, str], veriloggen.VStatement] = None):
        self.name = name
        self.trans = trans
        self.sig = MopSig(uses, modifies, behaviour)
        self.vstmts = vstmts
    @property
    def is_seq(self):
        ''' Is this a sequential element '''
        return self.sig.behaviour == MopBehaviour.SEQ
    @property
    def is_com(self):
        ''' Or a combinational one '''
        return self.sig.behaviour == MopBehaviour.COM
    def depends_on(self, other):
        return len(set(self.sig.uses).intersection(set(other.sig.modifies))) != 0
    @property
    def modifies(self):
        ''' What is the modifies set for this transaction? '''
        return self.sig.modifies
    @property
    def modifies_names(self):
        ''' Get the names of the modified signals '''
        return set([s.name for s in self.sig.modifies])
    @property
    def uses(self):
        ''' What are the variables that this mop consumes '''
        return self.sig.uses
    def __call__(self, assignment):
        return self.trans(assignment)
    def block(self, pre_, post_):
        return self.vstmts(pre_, post_)
    def guarded_block(self, trigger: str, pre_, post_) -> str:
        ''' Insert this code block into the design '''
        con_block = veriloggen.VITE(veriloggen.VLiteral("{}_{}".format(trigger, self.name)), 
            self.vstmts(pre_, post_))
        return con_block.__inject__()

# A value in thes imulation can either be a string (for x or z) or a concrete value
StateValue      = Union[str, int, List[Union[int, str]]]
class Assignment(collections.MutableMapping):
    '''
        This class maintains a mapping between Signals and their values in the simulation
    '''
    def __init__(self, *args, **kwargs):
        self.assignment : Dict[Signal, StateValue] = {}
        self.update(dict(*args, **kwargs))
    def __getitem__(self, s: Signal) -> StateValue:
        if s in self.assignment:
            return self.assignment[s]
        else:
            print('WARN: signal {} not in assignment'.format(s.name))
            return 'x'
    def __setitem__(self, s: Signal, v: StateValue):
        self.assignment[s] = v
    def __delitem__(self, s: Signal) -> None:
        del self.assignment[s]
    def __len__(self) -> int:
        return len(self.assignment)
    def __iter__(self):
        return iter(self.assignment)
    def __repr__(self) -> str:
        return str({s.name: v for (s, v) in self.assignment.items()})
    def __deepcopy__(self, memo):
        cls = self.__class__
        result = cls.__new__(cls)
        memo[id(self)] = result
        new_assignment = {}
        for sig, val in self.assignment.items():
            new_assignment[sig] = deepcopy(val, memo)
        setattr(result, "assignment", new_assignment)
        return result
    def delta(self, other):
        """
            Get the signals at which two assignments differ
        """
        return [s for s in self.assignment if
            (self[s] != other[s]) or self[s] == 'x' or other[s] == 'x']
    def matches(self, other):
        return len(self.delta(other)) == 0
    def matches_on_sigs(self, other, sigs):
        return all([self[i] == other[i] for i in sigs])
    def update_on_sigs(self, other, sigs):
        """ COPY UPDATE """
        new_assn = deepcopy(self)
        for sig in sigs:
            new_assn[sig] = other[sig]
        return new_assn


@dataclass
class DUTHook():
    """Defines a mapping from the abstract ISignal to the
        (possibly time-delayed) signal in the DUT
    """
    dut_signal : str
    time_delta : int
class ISignal():
    """Defines a state element that is used to perfom predicated execution

    Attributes:
        name (str): colloquial name of the isignal
        width (int): bv-width of the signal
        dut_sig (str): name of the element from the design
        delta (int): the time-delay in the value of the signal sampled from the DUT
    """
    def __init__(self, name: str, width: int) -> None:
        self.name = name
        self.sig = SignalSig(None, width, SignalConnect.DSIG)
IFrame = Dict[ISignal, int]
