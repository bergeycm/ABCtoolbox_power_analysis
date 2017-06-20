
# ========================================================================================
# --- Run analyses for ABC STR power analysis
# ========================================================================================

# ----------------------------------------------------------------------------------------
# --- Variables
# ----------------------------------------------------------------------------------------

dsi_vals = [[10000, 10000, 25],
            [ 1000,  1000, 25]]

# For testing, just litte ones:
#                            
dsi_vals = [[ 100,  100, 25],
            [1000, 1000, 25]]
#                            

dsi_ids = list()
for dsi in dsi_vals:
    dsi_str = "DNA" + str(dsi[0]) + "_STR" + str(dsi[1]) + "_IND" + str(dsi[2])
    dsi_ids.append(dsi_str)

import string
import itertools
letters = list(string.ascii_uppercase)
letter_combos = ["".join(i) for i in itertools.product(letters, letters)]
# Reuce from 676 down to 500 to do 500 sets of 100,000 (AKA 50,000,000)
letter_combos = letter_combos[0:500]

dsi_parts = list()
for dsi_id in dsi_ids:
    for letcmb in letter_combos:
        dsi_parts.append(dsi_id + "_part" + letcmb)

# ----------------------------------------------------------------------------------------
# --- Make all
# ----------------------------------------------------------------------------------------

rule all:
    input:
        # do_simulation:
        expand("results/simulated_data/sim_{dsi_id}_part{letter}/ABCsampler_output_{dsi_id}_sampling1.txt",
            dsi_id=dsi_ids, letter=letter_combos),
        # combine_sim_results:
        expand("results/simulated_data/ABCsampler_output_{dsi_id}.sumstats.combined.txt",
            dsi_id=dsi_ids),
        # run_estimator:
        expand("results/estimator_output/ABCestimator.{dsi_id}.results.txt",
            dsi_id=dsi_ids),

localrules: all

# ----------------------------------------------------------------------------------------
# --- Do big simulation
# ----------------------------------------------------------------------------------------

rule do_simulation:
    output:
        "results/simulated_data/sim_{dsi_part_id}/ABCsampler_output_{dsi_string}_sampling1.txt"
    threads: 1
    params: runtime="24",
            mem=",mem=5gb"
    shell:
        "DSI_VALS=`echo '{wildcards.dsi_part_id}' | sed -e 's/_part*//' | "
        "tr '_' ' ' | sed -e 's/[A-Z]//g'`;"
        "sh scripts/generate_simulated_broad.sh "
        "$DSI_VALS "
        "100 10000 1 100 100000 results/simulated_data/sim_{wildcards.dsi_part_id} "
        "2>&1 | tee STDOUT_STDERR_{wildcards.dsi_part_id}.log"

# ----------------------------------------------------------------------------------------
# --- Combine simulation results
# ----------------------------------------------------------------------------------------

rule combine_sim_results:
    input:
        expand("results/simulated_data/sim_{dsi_id}_part{letter}/ABCsampler_output_{dsi_id}_sampling1.txt",
            dsi_id=dsi_ids, letter=letter_combos)
    output:
        "results/simulated_data/ABCsampler_output_{dsi_id}.sumstats.combined.txt"
    threads: 1
    params: runtime="1",
            mem=",mem=5gb"
    shell:
        "DSI_VALS=`echo '{wildcards.dsi_id}' | "
        "tr '_' ' ' | sed -e 's/[A-Z]//g'`;"
        "sh scripts/combine_sim_results.sh $DSI_VALS"

# ----------------------------------------------------------------------------------------
# --- Run estimator on pseudo-observed data
# ----------------------------------------------------------------------------------------

rule run_estimator:
    input:
        "results/simulated_data/ABCsampler_output_{dsi_id}.sumstats.combined.txt"
    output:
        "results/estimator_output/ABCestimator.{dsi_id}.results.txt"
    threads: 20
    params: runtime="12",
            mem=",mem=5gb"
    shell:
        "DSI_VALS=`echo '{wildcards.dsi_id}' | "
        "tr '_' ' ' | sed -e 's/[A-Z]//g'`;"
        "sh scripts/run_estimator_all_PODs_in_parallel.sh $DSI_VALS 1000"

# ========================================================================================
# --- Set default for optional mem parameter
# ========================================================================================

default = ""
name = 'mem'
for r in workflow.rules:
    try:
        getattr(r.params, name)
    except AttributeError:
        r.params.append(default)
        r.params.add_name(name)
