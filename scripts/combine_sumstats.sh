#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Combine STR and DNA summary stats for the same run
# --- (joined by individual count and iteration number)
# ----------------------------------------------------------------------------------------

DNA_CTS=($(find results/arlsumstat_output -name dna_* -type d | \
    cut -d'/' -f 3 | cut -d'_' -f 2 | sort | uniq))
STR_CTS=($(find results/arlsumstat_output -name str_* -type d | \
    cut -d'/' -f 3 | cut -d'_' -f 2 | sort | uniq))

IND_CTS=($(find results/arlsumstat_output -name dna_* -type d | \
    cut -d'/' -f 3 | cut -d'_' -f 3 | sort | uniq))

# How many iterations were done for each DNA x individual or STR x individual combination?
REP_CT=`ls results/arlsumstat_output/dna_${DNA_CTS[0]}_${IND_CTS[0]} | wc -l`

OUT_DIR=results/combined_sum_stats
mkdir -p $OUT_DIR

echo "Combining for..."

for i in ${IND_CTS[*]}; do

    echo -e "\t$i INDs and..."

    for s in ${STR_CTS[*]}; do

        echo -e "\t\t$s STRs and..."

        for d in ${DNA_CTS[*]}; do

            echo -e "\t\t\t$d DNA seqs."

            STR_PREFIX=results/arlsumstat_output/str_${s}_${i}/str_${s}_${i}_sumstat_
            DNA_PREFIX=results/arlsumstat_output/dna_${d}_${i}/dna_${d}_${i}_sumstat_

            for r in `seq 1 $REP_CT`; do

                OUT_OBS_FILE=$OUT_DIR/both_sum_stats_DNA${d}_STR${s}_IND${i}_REP${r}.obs

                cut -f6,11,16,19,22 ${DNA_PREFIX}${r} > $OUT_OBS_FILE.part1
                cut -f2,7,11,20,21  ${STR_PREFIX}${r} > $OUT_OBS_FILE.part2

                paste $OUT_OBS_FILE.part1 $OUT_OBS_FILE.part2 > $OUT_OBS_FILE
                rm $OUT_OBS_FILE.part*

                FULL_OBS=$OUT_DIR/both_sum_stats_DNA${d}_STR${s}_IND${i}.txt

                # Write header
                if [[ $r == 1 ]]; then
                    head -n1 $OUT_OBS_FILE > $FULL_OBS
                fi

                sed "1d" $OUT_OBS_FILE >> $FULL_OBS

                echo -e "\t\t\tCombined output file is [$OUT_OBS_FILE]."
            done

            # Combine iterations into single file
            # full.obs = read.table("results/combined_sum_stats/both_sum_stats_DNA500_STR100_IND25.txt", header=TRUE)
            # full.obs$sim = 1:nrow(full.obs)
            # write.table(full.obs[c(11,1:10)], file="results/combined_sum_stats/both_sum_stats_DNA500_STR100_IND25.fix.txt", sep="\t", quote=FALSE)

        done
    done
done
