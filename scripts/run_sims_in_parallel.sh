#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Run simulations in parallel
# ----------------------------------------------------------------------------------------

# screen -S ABC_sim

PARAMS="1000 1000 25 100 10000 1 100 100000"

for LETT in A B C D E F G H I J; do
    sh scripts/generate_simulated_broad.sh $PARAMS \
        results/simulated_data/sim_${LETT} 2>&1 | tee STDOUT_STDERR_${LETT}.log &
done

wc -l results/simulated_data/sim_*/ABCsampler_output_DNA1000_STR1000_IND25_Obs*
