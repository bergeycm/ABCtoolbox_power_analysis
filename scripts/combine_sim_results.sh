#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Combine simulation results and remove invariant columns
# ----------------------------------------------------------------------------------------

PARAM_d=$1
PARAM_s=$2
PARAM_i=$3

DSI_STRING=DNA${PARAM_d}_STR${PARAM_s}_IND${PARAM_i}

SS_FILENAME=ABCsampler_output_${DSI_STRING}_sampling1.txt
COMBINED_OUT=results/simulated_data/ABCsampler_output_${DSI_STRING}.sumstats.combined.txt

SS_FILES=($(ls results/simulated_data/sim_${DSI_STRING}_part*/$SS_FILENAME))
head -n1 ${SS_FILES[0]} | sed -e "s/Obs._//g" > ${COMBINED_OUT}_temp

for ss in ${SS_FILES[*]}; do
    tail -n+2 $ss >> $COMBINED_OUT_temp
done

# --- Find out which columns are invariant

NUM_COLS=`awk '{print NF}' ${COMBINED_OUT}_temp | sort -nu | tail -n 1`

COL_STR=

for col in `seq 1 $NUM_COLS`; do

    COL_NAME=`head -n 1 ${COMBINED_OUT}_temp | cut -f $col`

    MODAL_VAL=`head -n 1000 ${COMBINED_OUT}_temp | tail -n 999 | cut -f $col | \
        sort | uniq -c | head -n1 | sed -e "s/ *\([0-9]*\) [0-9]*.*/\1/"`

    if [[ $MODAL_VAL -ne 999 ]]; then
        COL_STR="${COL_STR},${col}"
    else
        echo "Removing column $col ($COL_NAME) because it is invariant."
    fi

done

COL_STR=${COL_STR/,/}

cut -f $COL_STR ${COMBINED_OUT}_temp > $COMBINED_OUT

rm ${COMBINED_OUT}_temp
