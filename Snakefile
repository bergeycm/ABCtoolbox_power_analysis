
# ========================================================================================
# --- Run analyses for ABC STR power analysis
# ========================================================================================

# ----------------------------------------------------------------------------------------
# --- Variables
# ----------------------------------------------------------------------------------------

dsi_vals = [[10000, 10000, 25],
            [ 1000,  1000, 25]]

# For testing, just one:
#dsi_vals = [[1000, 1000, 25]]

dsi_ids = list()
for dsi in dsi_vals:
    dsi_str = "DNA" + str(dsi[0]) + "_STR" + str(dsi[1]) + "_IND" + str(dsi[2])
    dsi_ids.append(dsi_str)

import string
letters = list(string.ascii_uppercase)[0:19]
dsi_parts = list()
for dsi_id in dsi_ids:
    for letter in letters:
        dsi_parts.append(dsi_id + "_part" + letter)

# ----------------------------------------------------------------------------------------
# --- Make all
# ----------------------------------------------------------------------------------------

rule all:
    input:
        # do_simulation:
        #expand("STDOUT_STDERR_{dsi_part_id}.log", dsi_part_id=dsi_parts),
        expand("results/simulated_data/sim_{dsi_id}_part{letter}/ABCsampler_output_{dsi_id}.sumstats.txt",
            dsi_id=dsi_ids, letter=letters)

localrules: all

# ----------------------------------------------------------------------------------------
# --- Do big simulation
# ----------------------------------------------------------------------------------------

rule do_simulation:
    output:
        "results/simulated_data/sim_{dsi_part_id}/ABCsampler_output_{dsi_string}.sumstats.txt"
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
