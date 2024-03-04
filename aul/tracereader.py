"""
    Utilities to read VCD files
"""

from typing import Dict, List, Union
from aul.utils import UNCONSTRAINED
from vcdvcd import VCDVCD
from aul.moplib import DUTHook, ISignal, Signal, Assignment, IFrame

import re


def signalstr_to_vcdid(sig: str):
    """Convert a signal string to a VCD string

    Args:
        sig (str): signal string

    Returns:
        str: VCD string
    """
    r = r"([^[]+)\[([0-9]+):([0-9]+)\]"
    gs = re.search(r, sig)
    if gs is not None:
        gs = gs.groups()
        # This is a sliced signal
        return (gs[0], int(gs[1]), int(gs[2]))
    else:
        # This is an unsliced signal
        return (sig, -1, -1)
    

def get_subtrace(vcdr: VCDVCD, sig_to_des: Dict[Signal, Union[str, List[str]]], rng: range) -> List[Assignment]:
    """Extract the signals from the vcd trace between the start_cyc and end_cyc (both inclusive)
        This is done only for signals that have counterparts in the design (CSIGs and DSIGs)

    Args:
        vcdr (VCDVCD): VCDVCD object read from vcd file
        sig_to_des (Dict[Signal, Union[str,List[str]]]): map from Signal to element in DUT
        rng (range): range denoting the time steps to be sampled at

    Returns:
        List[Assignment]: a list of Assignment objects, one for each step in rng
    """
    
    frames : List[Assignment] = []
    vcd_signals = vcdr.references_to_ids.keys()
    for i in rng:
        frame = Assignment()
        for sig in sig_to_des:
            # Does the signal correspond to anything in the design (CSIG/DSIG)
            if sig.is_csig or sig.is_dsig:
                # Allow for signals that are not bound (arbitrary)
                if sig_to_des[sig] == UNCONSTRAINED:
                    frame[sig] = UNCONSTRAINED
                # If the signal is a reg
                else:
                    if sig.is_typ_sig:
                        vcdid = signalstr_to_vcdid(sig_to_des[sig])
                        matches = [i for i in vcd_signals if vcdid[0] + '[' in i]
                        if len(matches) > 1:
                            raise ValueError(f"More than one signal matches {vcdid[0]}")
                        elif len(matches) == 0:
                            raise ValueError(f"No signal matches {vcdid[0]}")
                        else:
                            basename = matches[0]
                            if vcdid[1] != -1:    
                                val = (vcdr[basename][i][::-1])[vcdid[2]:(vcdid[1]+1)][::-1]
                            else:
                                val = vcdr[basename][i]
                        frame[sig] = int(('0' + val), 2) if 'x' not in val else 'x'
                    # Or if it is a map
                    else:
                        # vals = [vcdr[subsig][i] if subsig in vcd_signals else 'x' for subsig in sig_to_des[sig]]
                        vals = []
                        for subsig in sig_to_des[sig]:
                            vcdid = signalstr_to_vcdid(subsig)
                            matches = [i for i in vcd_signals if vcdid[0] + '[' in i]
                            if len(matches) > 1:
                                raise ValueError(f"More than one signal matches {vcdid[0]}")
                            elif len(matches) == 0:
                                raise ValueError(f"No signal matches {vcdid[0]}")
                            else:
                                basename = matches[0]
                                if vcdid[1] != -1:
                                    val = ((vcdr[basename][i][::-1])[vcdid[2]:(vcdid[1]+1)])[::-1]
                                else:
                                    val = vcdr[basename][i]
                            vals.append(int(('0' + val), 2) if 'x' not in val else 'x')
                            # frame[sig] = int(val, 2) if 'x' not in val else 'x'
                        # frame[sig] = [int(v, 2)  if 'x' not in v else 'x' for v in vals]
                        frame[sig] = vals
        frames.append(frame)
    return frames

def get_subtrace_simple(vcdr : VCDVCD, sigs: List[str], rng: range):
    """Extract signal values from the VCD trace directly from the signal names.

    Args:
        vcdr (VCDVCD): VCDVCD object read from vcd file
        sigs (List[str]): list of signal names to read from the vcd file
        rng (range): range denoting the time steps to be sampled at

    Returns:
        List[Dict[str, Union[int, str]]]: a list of dictionaries,
            representing the memory values at each point
    """
    frames = []
    for i in rng:
        frame = {}
        for sig in sigs:
            val = vcdr[sig][i]
            frame[sig] = int(val, 2) if ('x' not in val and 'z' not in val) else val
        frames.append(frame)
    return frames

def get_iframe_values(vcdr: VCDVCD, isig_to_des: Dict[ISignal, DUTHook], rng: range) -> List[IFrame]:
    """Generates set of values that form the control part of the state in the AUM

    Args:
        vcdr (VCDVCD): vcd trace dump object
        iframe_signals (List[ISignal]): list of signals that will sit in the C-state
        rng (range): range for value to sample in

    Returns:
        List[IFrame]: generated sequence of iframes
    """
    iframes : List[IFrame] = []
    vcd_signals = vcdr.references_to_ids.keys()
    for i in rng:
        iframe = dict()
        for (isig, duthook) in isig_to_des.items():
            vcdid = signalstr_to_vcdid(duthook.dut_signal)
            matches = [i for i in vcd_signals if (vcdid[0] + '[' in i or vcdid[0] == i)]
            if len(matches) > 1:
                raise ValueError(f"More than one isignal matches {vcdid[0]}")
            elif len(matches) == 0:
                raise ValueError(f"No isignal matches {vcdid[0]}")
            else:
                basename = matches[0]
                if vcdid[1] != -1:    
                    val = (vcdr[basename][i+duthook.time_delta][::-1])[vcdid[2]:(vcdid[1]+1)][::-1]
                else:
                    val = vcdr[basename][i+duthook.time_delta]
            # val = vcdr[duthook.dut_signal][i+duthook.time_delta]
            iframe[isig] = int(val, 2)
        iframes.append(iframe)
    return iframes

def get_assignment_at(frames : List[Assignment], timestep) -> Assignment:
    """
    Grab the assignment from a frame
    """
    return frames[timestep]
