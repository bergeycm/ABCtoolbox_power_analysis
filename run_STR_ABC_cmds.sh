#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Commands to run STR ABC power analysis
# ----------------------------------------------------------------------------------------

module load python/2.7.8

# --- Create par files for DNA and STRs
python scripts/fill_dna_par_file.py
python scripts/fill_str_par_file.py

# --- Simulate data under evolutionary scenario with parameter values defined in par files
module load fastsimcoal/25221

PAR_CT=`ls results/par_files/ | wc -l`
qsub -t 1-$PAR_CT pbs/call_fastsimcoal.pbs

# --- Call arlsumstat to compute summary stats
module load arlsumstat/3522
cp data/ssdefs.txt .
cp data/arl_run.ars .

ARP_DIR_CT=`find results/fastsimcoal_output/* -maxdepth 0 -type d | wc -l`
qsub -t 1-$ARP_DIR_CT pbs/call_arlsumstat.pbs

# For those that take awhile, you can instead use:
# qsub -t 1-$ARP_DIR_CT pbs/call_arlsumstat_parallel.pbs

rm ssdefs.txt
rm arl_run.ars

# --- Combine DNA and STR summary statistics
sh scripts/combine_sumstats.sh

