#!/bin/bash

cd examples/ibex
#python3 assemble.py --program programs/isw_and.S --netlist ../../tmp/circuit.v
python3 assemble.py --program programs/isw_and_ld_st.S --init-file programs/isw_and_ld_st_init --netlist ../../tmp/circuit.v
cd -
python3 trace.py --testbench tmp/verilator_tb.c --netlist tmp/circuit.v --output-bin tmp/circuit.elf --skip-compile-netlist
