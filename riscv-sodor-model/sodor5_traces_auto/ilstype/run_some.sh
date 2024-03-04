#!/bin/bash

CVC5=~/bin/cvc5-Linux

for var in "$@"
do
    echo "$var" >> logfile; (time timeout -s 9 3600 $CVC5 --lang=sygus2 "$var") &>> logfile; 
    echo >> logfile; echo "$var"
done


