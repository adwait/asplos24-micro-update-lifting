
#!/bin/bash 

echo "Running Sodor5 case study"

echo "Running model generation for Sodor5"
echo " Warning: This will take a long time (~ 1 hour)"
python3 sodor5_itype_script.py
echo "Result will be generated in the out directory"


echo "Running security proofs for Sodor5"
echo "Proof scripts are located in the riscv-sodor-model/verification/sodor_security directory"
echo " Warning: This will take a long time, especially on low compute machines (~2 hours)"
cd riscv-sodor-model/verification/sodor_security

# The following script runs a security proof for each symbolic testcase on the design and the model
#   and records the runtimes
python3 run_all.py

echo "Printing the results table."
cat times.log