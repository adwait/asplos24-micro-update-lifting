
import os
import shutil
import subprocess
from typing import Callable, Dict, List, Union, Tuple
from dataclasses import dataclass, field
from aul.moplib import DUTHook, Mop, ISignal, Signal
from aul.predicate import Formula
from aul.utils import DISTINGUISHER_TRACE
from aul.veriloggen import VSignal
from aul import synthesizer

PrefOrder = List[Tuple[Mop, Mop]]

@dataclass
class ProcessorConfig():
    NAME        : str
    # The directory where the design is housed
    PARENT_DIR  : str
    # Basename of the vcd file which holds the simulation trace
    VCDFILE     : str

    # Testbench file and vcd file
    TBFILE      : str
    TBVCD       : str
    # Macros for simulation
    # Where the simulation scripts are located
    SIMULATION_DIR      : str
    # Command to run for simulation
    SIMULATION_COMMAND  : str
    # Timing calibration for simulation
    BASE_CYCLE  : int
    MAX_CYCLE   : int
    # What is the timescale for the design
    LEAP        : int
    # Location of the generated VCD from distinguisher
    DISTINGUISHER_VCD       : str
    # Distinguisher directory (where to place the distinguisher file) and file
    DISTINGUISHER_DIR       : str
    DISTINGUISHER_FILE      : str
    # Distinguisher command
    DISTINGUISHER_COMMAND   : str
    # Distinguisher time-wise insertion point
    DISTINGUISHER_INSERTION_CYCLE   : int
    DISTINGUISHER_LEAP              : int

    # Runtime hook for running simulations
    def run_tbsim(self):
        subprocess.call(self.SIMULATION_COMMAND, shell=True, cwd=self.SIMULATION_DIR)
    @property
    def SIMULATION_RANGE(self):
        '''
            What is the range of timesteps to sample from
        '''
        return range(self.BASE_CYCLE*self.LEAP, self.MAX_CYCLE*self.LEAP, self.LEAP)
    # MSequence range
    @property
    def MSEQ_RANGE(self):
        '''
            What is the range of indices within the sampled/generated sequences
        '''
        return range(self.BASE_CYCLE, self.MAX_CYCLE-1)

    @property
    def DISTINGUISH_RANGE(self):
        return range((self.DISTINGUISHER_INSERTION_CYCLE-1)*self.DISTINGUISHER_LEAP, (self.DISTINGUISHER_INSERTION_CYCLE+1)*self.DISTINGUISHER_LEAP, self.DISTINGUISHER_LEAP)

    # # Module header path in the simulation setup
    # SIMULATION_HEAD     : str
    # # Module header path in the distinguisher setup
    # DISTINGUISH_HEAD    : str

    # Mapping from Signals to a signal base-name from then abstract design
    basename_mapping    : Dict[Signal, str]
    # Mapping from Signals to a signal basename from the concrete design
    dut_basename_mapping    : Dict[Signal, Union[str, List[str]]]
    dut_basename_mapping_dist    : Dict[Signal, Union[str, List[str]]]
    # Mapping from ISignals to a signal basename (and time-offset) from the concrete design
    dut_isig_basename_mapping   : Dict[ISignal, DUTHook]
    dut_isig_basename_mapping_dist   : Dict[ISignal, DUTHook]
    # Mapping from Signal to the name from the concrete design
    @property
    def MAPPING(self) -> Dict[Signal, Union[str, List[str]]]:
        return self.dut_basename_mapping
        # {
        #     s : f"{self.SIMULATION_HEAD}.{path}" if isinstance(path, str) else
        #         [f"{self.SIMULATION_HEAD}.{p}" for p in path]
        #         for (s, path) in self.dut_basename_mapping.items()
        # }
    @property
    def ISIGNALS(self) -> Dict[ISignal, DUTHook]:
        return self.dut_isig_basename_mapping
        # {
        #     s : DUTHook(f"{self.SIMULATION_HEAD}.{dh.dut_signal}", dh.time_delta)
        #         for (s, dh) in self.dut_isig_basename_mapping.items()
        # }

    @property
    def DIS_MAPPING(self) -> Dict[Signal, Union[str, List[str]]]:
        return self.dut_basename_mapping_dist
        # {
        #     s : f"{self.DISTINGUISH_HEAD}.{path}" if isinstance(path, str) else
        #         [f"{self.DISTINGUISH_HEAD}.{p}" for p in path]
        #         for (s, path) in self.dut_basename_mapping.items()
        # }
    @property
    def DIS_ISIGNALS(self) -> Dict[ISignal, DUTHook]:
        return self.dut_isig_basename_mapping_dist
        # return {
        #     s : DUTHook(f"{self.DISTINGUISH_HEAD}.{dh.dut_signal}", dh.time_delta)
        #         for (s, dh) in self.dut_isig_basename_mapping.items()
        # }
        
    # List of all transactions
    TRANSACTIONS        : List[Mop]
    # List of predicates
    PREDICATES          : List[Formula]
    # List of abstract signals from the design
    # ISIGNALS            : Dict[ISignal, DUTHook]

    make_testblock_by_program           : Callable[..., str]
    make_testblock_by_seed              : Callable[..., str]
    make_distinguishblock_by_prepost    : Callable[..., str]

    # Preference order on the transactions
    PREF_ORDER          : PrefOrder = field(default_factory=lambda: [])
    INDEPENDENCES       : List[Tuple[Formula, Formula]] = field(default_factory=lambda: [])

    def run_distinguisher(self, test_dir: str, uid: int, verilog_bench: str):
        with open(f"{self.DISTINGUISHER_FILE}", 'w') as fh:
            fh.write(verilog_bench)
        with open(f"{test_dir}/distinguisher_{uid}.v", 'w') as fh:
            fh.write(verilog_bench)
        return_code = subprocess.call(self.DISTINGUISHER_COMMAND, shell=True, cwd=self.DISTINGUISHER_DIR)
        shutil.copy2(self.DISTINGUISHER_VCD, f"{test_dir}/{DISTINGUISHER_TRACE}")
        return return_code

    def rerun_same_test(self, source_dir: str):
        """Reuse the same test that has been sampled/generated before

        Args:
            source_dir (str): Source directory for the test
        """
        # Get the program
        path = source_dir
        if not os.path.exists(path + "program.v"):
            print("Test direcotyr not found")
            exit(1)

        # Log the program
        with open(path + "program.v", "r") as fh1:
            prog_string = fh1.read()
        # And copy it to the testbench
        with open(self.TBFILE, "w") as fh2:
            fh2.write(prog_string)
        # Run the testbench (to collect a trace)
        self.run_tbsim()
        # Copy the generated trace to the directory
        shutil.copy2(self.TBVCD, path)

    def generate_test(self, test_dir: str, sampler: Callable[[], str] = (lambda : "")):
        """Generate a single vcd trace by running ONE test

        Args:
            num_tests (int): Number of tests you want to run
            test_dir (str): Exact directory name
            sampler (Callable[[], str]): What should the sampling strategy look like
        """
        # Make the directory
        path = test_dir
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)

        # Get the program
        prog_string = sampler()
        # Log the program
        with open(path + "program.v", "w") as fh1:
            fh1.write(prog_string)

        # And copy it to the testbench
        with open(self.TBFILE, "w") as fh2:
            fh2.write(prog_string)
        # subprocess.call("make sodor5_dmem_run", shell=True)
        # Run the testbench (to collect a trace)
        self.run_tbsim()
        # Copy the generated tb to the directory
        shutil.copy2(self.TBVCD, path)

    def generate_tests(self, num_tests: int, test_basedir: str, sampler : Callable[[], str] = (lambda : "")):
        """Generate vcd traces by running several test

        Args:
            num_tests (int): Number of tests you want to run
            test_basedir (str): Where should the test logs be written to?
            sampler (Callable[[], str]): What should the sampling strategy look like
        """
        for testnum in range(num_tests):
            # Make the directory
            path = "{}/test_{}/".format(test_basedir, testnum)
            if not os.path.exists(path):
                os.makedirs(path, exist_ok=True)

            # Get the program
            prog_string = sampler()
            # Log the program
            with open(path + "program.v", "w") as fh1:
                fh1.write(prog_string)

            # And copy it to the testbench
            with open(self.TBFILE, "w") as fh2:
                fh2.write(prog_string)
            # subprocess.call("make sodor5_dmem_run", shell=True)
            # Run the testbench (to collect a trace)
            self.run_tbsim()
            # Copy the generated tb to the directory
            shutil.copy2(self.TBVCD, path)

    def gen_instruction_sequence_script(self, predframes: List[bool], synthfile: str = ".temp/temp.smt2"):
        """Generate instructions for cover properties

        Args:
            # preds (List[Formula]): set of predicates for the design
            predframes (List[bool]): list of predicate valuations
            synthfile (str, optional): _description_. Defaults to "./temp/temp.smt2".
        """
        def get_declare_var(i: int):
            """ Create synthesis input (declare) variables """
            return f"x{i}"
        def get_declare_stmt(i: int, w: int):
            """ Create synthesis input (declare) variables """
            return f"(declare-fun {get_declare_var(i)} () (_ BitVec {w}))"
        
        isignals = list(self.ISIGNALS.keys())

        # Instruction variable names
        instruction_vars = [get_declare_var(i) for i in range(len(isignals))]
        # Map from ISignal names to SMT variable names
        instruction_vars_map = {instr.name: ivar for (instr, ivar) in zip(isignals, instruction_vars)}

        def get_frame_constraints():
            """Get constraints based on the interesting pred valuations

            Args:
                predframes_ (List[bool]): ith desirable pred valuation: [i]
            """
            all_constraints = []
            for pred, choice in zip(self.PREDICATES, predframes):
                constr = pred.get_constraint(instruction_vars_map) if choice else "(not {})".format(pred.get_constraint(instruction_vars_map))
                all_constraints.append(constr)
            return "(assert (and {}))".format("\n".join(all_constraints))

        var_declarations = "\n".join([get_declare_stmt(i, instr.sig.outw) for (i, instr) in enumerate(isignals)])
        all_frame_constraints = get_frame_constraints()
        get_values = "(get-value ({}))".format(" ".join(instruction_vars))
        script_string = var_declarations + "\n\n" +  all_frame_constraints + "\n\n(check-sat)\n" + get_values
        with open(f"{synthfile}", 'w') as fhndle:
            fhndle.write(script_string)
        b, instr_vals = synthesizer.call_z3(synthfile)
        return (b, {instr.name: int(instr_vals[ivars][2:], 2) for (instr, ivars) in zip(isignals, instruction_vars)})

    def transactions_by_name(self):
        return {
            t.name: t for t in self.TRANSACTIONS
        }
    def signals_by_name(self):
        return {
            s.name: s for s in self.MAPPING
        }
    def isignals_by_name(self):
        return {
            s.name: s for s in self.ISIGNALS
        }

    def get_extension_mapping(self, pref_: str):
        return {
            s : VSignal(pref_+self.basename_mapping[s]) for s in self.basename_mapping
        }

    @property
    def repr_mapping(self):
        '''
            This gives us the mapping from the Signal object to its name in the abstract module
        '''
        return self.get_extension_mapping("")
