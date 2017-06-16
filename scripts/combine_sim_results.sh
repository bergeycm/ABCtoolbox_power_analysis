#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Combine simulation results
# ----------------------------------------------------------------------------------------

PARAM_d=$1
PARAM_s=$2
PARAM_i=$3

DSI_STRING=DNA${PARAM_d}_STR${PARAM_s}_IND${PARAM_i}

SS_FILENAME=ABCsampler_output_${DSI_STRING}_sampling1.txt
COMBINED_OUT=results/simulated_data/ABCsampler_output_${DSI_STRING}.sumstats.combined.txt

SS_FILES=($(ls results/simulated_data/sim_${DSI_STRING}_part*/$SS_FILENAME))
head -n1 ${SS_FILES[0]} | sed -e "s/Obs._//g" > $COMBINED_OUT

for ss in ${SS_FILES[*]}; do
    tail -n+2 $ss >> $COMBINED_OUT
done
