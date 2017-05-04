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

# --- Transform N into log(N)
#PARAM_N_min_log=$(echo "l($PARAM_N_min)" | bc -l)
#PARAM_N_max_log=$(echo "l($PARAM_N_max)" | bc -l)

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

echo -e "[RULES]" >> $EST_FILE
echo -e "LOG_N_ANCESTRAL > LOG_N_NOW" >> $EST_FILE
echo -e "" >> $EST_FILE

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

#for i in `seq 1 $PARAM_d`; do
    echo "//Per chromosome: Number of linkage blocks" >> $PAR_FILE_DNA
    echo "1" >> $PAR_FILE_DNA
    echo "//per Block: data type, num loci, rec. rate and mut rate + " \
         "optional parameters" >> $PAR_FILE_DNA
    echo "DNA 500 0.00000 0.00000002 0.33" >> $PAR_FILE_DNA
#done


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
# ----------------------------------------------------------------------------------------

#echo -e "LOG_N_NOW\tLOG_N_ANCESTRAL\tT_SHRINK\tSTR_MUTATION\tMTDNA_MUTATION\tGAMMA\t" \
#        "H_1\tS_1\tD_1\tFS_1\tPi_1\tKsd_1\tHsd_1\tGW_1\tR_1\tRsd_1" > fake.obs
#echo -e "100\t100\t100\t0.01\t0.01\t0.01\t1" \
#        "0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1" >> fake.obs
#
#echo -e "GAMMA\tLOG_N_ANCESTRAL\tLOG_N_NOW\tMTDNA_MUTATION\tSTR_MUTATION\tT_SHRINK\t" \
#        "N_ANCESTRAL\tN_ANCESTRAL_REL\tN_NOW\tN_NOW_MTDNA\tN_NOW_REL\t" \
#        "H_1" > fake.obs
#echo -e "9.99502\t10.0185\t5.88774\t4.76461e-07\t6.01922e-05\t98\t1\t1.29498e-06\t772211\t193053\t772211\t" \
#        "0.1" >> fake.obs
#
#echo -e "GAMMA\tLOG_N_ANCESTRAL\tLOG_N_NOW\tMTDNA_MUTATION\tSTR_MUTATION\tT_SHRINK\t" \
#        "N_ANCESTRAL\tN_ANCESTRAL_REL\tN_NOW\tN_NOW_MTDNA\tN_NOW_REL\t" \
#        "H_1" > fake.obs
#echo -e "9.99502\t10.0185\t5.88774\t4.76461e-07\t6.01922e-05\t98\t1\t1.29498e-06\t772211\t193053\t772211\t" \
#        "0.1" >> fake.obs

#echo -e "H_1\tS_1\tD_1\tFS_1\tPi_1\tKsd_1\tHsd_1\tGW_1\tR_1\tRsd_1" > fake.obs
#echo -e "0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1\t0.1" >> fake.obs

echo -e "H_1\tS_1\tD_1\tFS_1\tPi_1\t" > fake_DNA.obs
echo -e "0.1\t0.1\t0.1\t0.1\t0.1" >> fake_DNA.obs

echo -e "Ksd_1\tHsd_1\tGW_1\tR_1\tRsd_1" > fake_STR.obs
echo -e "0.1\t0.1\t0.1\t0.1\t0.1" >> fake_STR.obs

# ----------------------------------------------------------------------------------------
# --- Write ABCsampler input file
# ----------------------------------------------------------------------------------------

echo "samplerType standard" > $SAMPLER_INPUT
echo "estName $EST_FILE" >> $SAMPLER_INPUT
#echo "//obsName dna_${PARAM_d}_${PARAM_i}_sum_stats_TEST.obs;str_${PARAM_s}_${PARAM_i}_sum_stats_TEST.obs" >> $SAMPLER_INPUT
echo "obsName fake_DNA.obs" >> $SAMPLER_INPUT
#echo "//simDataName dna_${PARAM_d}_${PARAM_i}_sum_stats_TEST.arp;str_${PARAM_s}_${PARAM_i}_sum_stats_TEST.arp" >> $SAMPLER_INPUT
echo "outName example_output_DNA${PARAM_d}_STR${PARAM_s}_IND${PARAM_i}" >> $SAMPLER_INPUT
echo "separateOutputFiles 1" >> $SAMPLER_INPUT
echo "nbSims 1000" >> $SAMPLER_INPUT
echo "writeHeader 1" >> $SAMPLER_INPUT
echo "simulationProgram fsc25" >> $SAMPLER_INPUT
##echo "simInputName ${PAR_FILE_DNA};${PAR_FILE_STR}" >> $SAMPLER_INPUT
###echo "simInputName ${PAR_FILE_DNA}" >> $SAMPLER_INPUT
##echo "simParam -i#${PAR_FILE_DNA}#-n#1;-i#${PAR_FILE_STR}#-n#1" >> $SAMPLER_INPUT
##echo "simParam -i#${PAR_FILE_DNA}#-n#1" >> $SAMPLER_INPUT
echo "simInputName ${PAR_FILE_DNA}" >> $SAMPLER_INPUT
echo "simParam -i#SIMINPUTNAME#-n#1" >> $SAMPLER_INPUT
echo "sumStatProgram arlsumstat" >> $SAMPLER_INPUT
###echo "sumStatParam SIMDATANAME#SSFILENAME#0#1" >> $SAMPLER_INPUT
echo "sumStatParam ${PAR_FILE_DNA/.par}-temp/${PAR_FILE_DNA/.par}-temp_1_1.arp#SSFILENAME#0#1" >> $SAMPLER_INPUT
      # arlsumstat $ARP        $OUT       0 1

cp ../../../data/arl_run.ars .
cp ../../../data/ssdefs.txt .

module load fastsimcoal
module load arlsumstat/3522

ln -s `which fsc25` fsc25
ln -s `which arlsumstat` arlsumstat

~/bin/ABCtoolbox/binaries/linux/ABCsampler $SAMPLER_INPUT
