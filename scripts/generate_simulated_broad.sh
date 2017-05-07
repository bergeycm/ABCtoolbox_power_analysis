#!/bin/bash

# ========================================================================================
# --- Generate simulated datasets under broad uniform distributions
# ========================================================================================

# Number of DNA loci
PARAM_d=$1
# Number of STR loci
PARAM_s=$2
# Number of individuals
PARAM_i=$3

# Initial and final effective population sizes - minimum in uniform distribution
PARAM_N_min=$4
# Initial and final effective population sizes - maximum in uniform distribution
PARAM_N_max=$5
# Time since pop size change - minimum in uniform distribution
PARAM_t_min=$6
# Time since pop size change - minimum in uniform distribution
PARAM_t_max=$7

# Output directory
OUT_DIR=$8

# ----------------------------------------------------------------------------------------
# Example:
PARAM_d=500; PARAM_s=100; PARAM_i=25;
PARAM_N_min=100; PARAM_N_max=10000; PARAM_t_min=1; PARAM_t_max=100
OUT_DIR=results/simulated_data/broad/
# ----------------------------------------------------------------------------------------

cd $SCRATCH/STR_power_analysis/ABCtoolbox_power_analysis

mkdir -p $OUT_DIR
cd $OUT_DIR

# Generic name
SAMPLER_INPUT=ABCsampler.input
EST_FILE="DNA_and_STR.est"
PAR_FILE_DNA="DNA_${PARAM_d}_${PARAM_i}.par"
PAR_FILE_STR="STR_${PARAM_s}_${PARAM_i}.par"
ESTIMATOR_INPUT=ABCestimator.input

# --- Transform N into log(N) - Base 10!
PARAM_N_min_log=$(echo "l($PARAM_N_min)/l(10)" | bc -l)
PARAM_N_max_log=$(echo "l($PARAM_N_max)/l(10)" | bc -l)

# ----------------------------------------------------------------------------------------
# --- Write .est file with simulation parameters
# ----------------------------------------------------------------------------------------

echo -e "// Priors and rules file" > $EST_FILE
echo -e "// *********************" >> $EST_FILE
echo -e "" >> $EST_FILE

echo -e "[PARAMETERS]" >> $EST_FILE

echo -e "// All N are in number of diploid individuals" >> $EST_FILE
echo -e "0\tLOG_N_NOW\tunif\t$PARAM_N_min_log\t$PARAM_N_max_log" >> $EST_FILE
echo -e "0\tLOG_N_ANCESTRAL\tunif\t$PARAM_N_min_log\t$PARAM_N_max_log" >> $EST_FILE

echo -e "1\tT_SHRINK\tunif\t$PARAM_t_min\t$PARAM_t_max" >> $EST_FILE

echo -e "0\tSTR_MUTATION\tunif\t0.00001\t0.0001" >> $EST_FILE
echo -e "0\tMTDNA_MUTATION\tunif\t0.0000001\t0.000001" >> $EST_FILE
echo -e "0\tGAMMA\tunif\t8\t15" >> $EST_FILE

echo -e "" >> $EST_FILE

# Add this back in if we ever want to test only pop growths or pop declines
# echo -e "[RULES]" >> $EST_FILE
# echo -e "LOG_N_ANCESTRAL > LOG_N_NOW" >> $EST_FILE
# echo -e "" >> $EST_FILE

echo -e "[COMPLEX PARAMETERS]" >> $EST_FILE
echo -e "1\tN_NOW = pow10( LOG_N_NOW )" >> $EST_FILE
echo -e "1\tN_ANCESTRAL = pow10( LOG_N_ANCESTRAL )" >> $EST_FILE
echo -e "0\tN_ANCESTRAL_REL = N_ANCESTRAL / N_NOW" >> $EST_FILE
echo -e "0\tN_NOW_REL = N_NOW / N_ANCESTRAL" >> $EST_FILE
echo -e "1\tN_NOW_MTDNA = N_NOW / 4" >> $EST_FILE
echo -e "" >> $EST_FILE

# ----------------------------------------------------------------------------------------
# --- Write *.par file
# ----------------------------------------------------------------------------------------

echo "//Number of population samples (demes)" > $PAR_FILE_DNA
echo "1" >> $PAR_FILE_DNA
echo "//Population effective sizes (number of genes)" >> $PAR_FILE_DNA
echo "N_ANCESTRAL" >> $PAR_FILE_DNA
echo "//Sample sizes: 2*N" >> $PAR_FILE_DNA
echo $((PARAM_i * 2)) >> $PAR_FILE_DNA
echo "//Growth rates  : negative growth implies population expansion" >> $PAR_FILE_DNA
echo "0" >> $PAR_FILE_DNA
echo "//Number of migration matrices :" >> $PAR_FILE_DNA
echo "0" >> $PAR_FILE_DNA

echo "//historical event: time, source, sink, migrants, new size, " \
     "new growth rate, migration matrix" >> $PAR_FILE_DNA
echo "1 historical event" >> $PAR_FILE_DNA
echo "T_SHRINK 0 0 0 N_NOW_REL 0 0" >> $PAR_FILE_DNA
echo "//Number of independent loci [chromosome]" >> $PAR_FILE_DNA
echo "$PARAM_d 1" >> $PAR_FILE_DNA

cp $PAR_FILE_DNA $PAR_FILE_STR

# --- DNA
echo "//Per chromosome: Number of linkage blocks" >> $PAR_FILE_DNA
echo "1" >> $PAR_FILE_DNA
echo "//per Block: data type, num loci, rec. rate and mut rate + " \
     "optional parameters" >> $PAR_FILE_DNA
echo "DNA 500 0.00000 0.00000002 0.33" >> $PAR_FILE_DNA

# --- STR
echo "//Per chromosome: Number of linkage blocks" >> $PAR_FILE_STR
echo "1" >> $PAR_FILE_STR
echo "//per Block: data type, num loci, rec. rate and mut rate + " \
     "optional parameters" >> $PAR_FILE_STR
echo "MICROSAT 1 0.0000 0.0005 0 0" >> $PAR_FILE_STR

# Test:
# module load fastsimcoal
# sed -e "s/N_ANCESTRAL/1000000/" -e "s/T_SHRINK/5000/" -e "s/N_NOW_REL/0.001/" $PAR_FILE_DNA > tmp.par
# fsc25 -i tmp.par -n 1000
# rm -r tmp/
# rm tmp.par
# sed -e "s/N_ANCESTRAL/1000000/" -e "s/T_SHRINK/5000/" -e "s/N_NOW_REL/0.001/" $PAR_FILE_STR > tmp.par
# fsc25 -i tmp.par -n 1000
# rm -r tmp/
# rm tmp.par

# ----------------------------------------------------------------------------------------
# --- Create fake placeholder observation file
# --- ABCsampler needs it, even if not used during sampling, to ensure that the
# --- correct summary stats are being generated
# ----------------------------------------------------------------------------------------

echo -e "H_1\tS_1\tD_1\tFS_1\tPi_1\t" > fake_DNA.obs
echo -e "0.1\t0.1\t0.1\t0.1\t0.1" >> fake_DNA.obs

echo -e "Ksd_1\tHsd_1\tGW_1\tR_1\tRsd_1" > fake_STR.obs
echo -e "0.1\t0.1\t0.1\t0.1\t0.1" >> fake_STR.obs

# ----------------------------------------------------------------------------------------
# --- Write ABCsampler input file
# ----------------------------------------------------------------------------------------

echo "samplerType standard" > $SAMPLER_INPUT
echo "estName $EST_FILE" >> $SAMPLER_INPUT
echo "obsName fake_DNA.obs;fake_STR.obs" >> $SAMPLER_INPUT
echo "outName ABCsampler_output_DNA${PARAM_d}_STR${PARAM_s}_IND${PARAM_i}" >> $SAMPLER_INPUT
echo "separateOutputFiles 1" >> $SAMPLER_INPUT
echo "nbSims 1000" >> $SAMPLER_INPUT
echo "writeHeader 1" >> $SAMPLER_INPUT
echo "simulationProgram fsc25" >> $SAMPLER_INPUT
echo "simInputName ${PAR_FILE_DNA};${PAR_FILE_STR}" >> $SAMPLER_INPUT
echo "simParam -i#SIMINPUTNAME#-n#1;-i#SIMINPUTNAME#-n#1" >> $SAMPLER_INPUT
##echo "simParam -i#${PAR_FILE_DNA}#-n#1;-i#${PAR_FILE_STR}#-n#1" >> $SAMPLER_INPUT
##echo "simParam -i#${PAR_FILE_DNA}#-n#1" >> $SAMPLER_INPUT
echo "sumStatProgram arlsumstat" >> $SAMPLER_INPUT
###echo "sumStatParam SIMDATANAME#SSFILENAME#0#1" >> $SAMPLER_INPUT
echo "simDataName $PAR_FILE_DNA;$PAR_FILE_STR" >> $SAMPLER_INPUT
#        arlsumstat $ARP                                                        $OUT       0 1
echo "sumStatParam ${PAR_FILE_DNA/.par}-temp/${PAR_FILE_DNA/.par}-temp_1_1.arp#SSFILENAME#0#1;${PAR_FILE_STR/.par}-temp/${PAR_FILE_STR/.par}-temp_1_1.arp#SSFILENAME#0#1" >> $SAMPLER_INPUT

cp ../../../data/arl_run.ars .
cp ../../../data/ssdefs.txt .

module load fastsimcoal
module load arlsumstat/3522

ln -s `which fsc25` fsc25
ln -s `which arlsumstat` arlsumstat

~/bin/ABCtoolbox/binaries/linux/ABCsampler $SAMPLER_INPUT

# --- Combine output results tables

join ABCsampler_output_DNA500_STR100_IND25_Obs0_sampling1.txt \
     ABCsampler_output_DNA500_STR100_IND25_Obs1_sampling1.txt | \
     tr " " "\t" | cut -f 1-17,29-33 > ABCsampler_output_DNA500_STR100_IND25.sumstats.txt

# ----------------------------------------------------------------------------------------
# --- Write input file for ABCestimator
# ----------------------------------------------------------------------------------------

echo "//inputfile for the program ABCestimator" > $ESTIMATOR_INPUT
echo "estimationType standard" >> $ESTIMATOR_INPUT
echo "simName ABCsampler_output_DNA500_STR100_IND25.sumstats.txt" >> $ESTIMATOR_INPUT
echo "obsName pseudoObservedData.obs" >> $ESTIMATOR_INPUT
echo "params 3-12" >> $ESTIMATOR_INPUT
echo "//rejection" >> $ESTIMATOR_INPUT
echo "numRetained 5000" >> $ESTIMATOR_INPUT
echo "maxReadSims 5000" >> $ESTIMATOR_INPUT
echo "//parameters for posterior estimation" >> $ESTIMATOR_INPUT
echo "diracPeakWidth 0.01" >> $ESTIMATOR_INPUT
echo "posteriorDensityPoints 200" >> $ESTIMATOR_INPUT
echo "stadardizeStats 1" >> $ESTIMATOR_INPUT
echo "writeRetained 1" >> $ESTIMATOR_INPUT

ITER_NUM=1

OBS_LINE=$((ITER_NUM + 1))

sed -n -e '1p' -e "${OBS_LINE}p" \
    ABCsampler_output_DNA500_STR100_IND25.sumstats.txt \
    | cut -f 13-22 > pseudoObservedData.obs

~/bin/ABCtoolbox/binaries/linux/ABCestimator $ESTIMATOR_INPUT

# Creates:
#  ABC_GLM_BestSimsParamStats_Obs0.txt
#  ABC_GLM_L1DistancePriorPosterior.txt
#  ABC_GLM_PosteriorEstimates_Obs0.txt
#  ABC_GLM_PosteriorCharacteristics_Obs0.txt

#module load R
#R --vanilla $ESTIMATOR_INPUT < ~/bin/ABCtoolbox/scripts/plotPosteriorsGLM.r
