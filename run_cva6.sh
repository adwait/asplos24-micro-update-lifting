

#!/bin/bash


echo "Running CVA6 case study"

echo "Running wbuffer model generation for CVA6"
python3 cva6_wbuffer_script.py

echo "Running TLB model generation for CVA6"
python3 cva6_tlb_script.py

echo "Running SU model generation for CVA6"
python3 cva6_su_script.py

echo "Running LSU model generation without hierarchy for CVA6"
echo " Warning: This will take a long time (> 1 hour)"
python3 cva6_lsu_script_mono.py

echo "Running LSU model generation with hierarchy for CVA6"
echo " Warning: This will take moderate time (~30 mins)"
python3 cva6_lsu_script_hier.py

echo "Running security proofs for CVA6"
echo "Proof scripts are located in the cva6-model/verification/cva6_security directory"
echo " Warning: This will take moderate time (~30 mins)"
cd cva6-model/verification/cva6_security
# The following script runs a security proof for each symbolic testcase on the design and the model
#   and records the runtimes
python3 run_all.py

echo "Printing the results table."
cat times.log