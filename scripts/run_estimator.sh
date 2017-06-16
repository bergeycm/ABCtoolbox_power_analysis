#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Run ABCestimator
# ----------------------------------------------------------------------------------------

PARAM_d=$1
PARAM_s=$2
PARAM_i=$3

ITER_NUM=$4

module load abctoolbox

OBS_LINE=$((ITER_NUM + 1))

ESTIMATOR_INPUT=ABCestimator_Obs${ITER_NUM}.input

SUM_STATS=results/simulated_data/ABCsampler_output
SUM_STATS=${SUM_STATS}_DNA${PARAM_d}_STR${PARAM_s}_IND${PARAM_i}.sumstats.combined.txt

echo "//inputfile for the program ABCestimator" > $ESTIMATOR_INPUT
echo "estimationType standard" >> $ESTIMATOR_INPUT
echo "simName $SUM_STATS" >> $ESTIMATOR_INPUT
echo "obsName pseudoObservedData_Obs${ITER_NUM}.obs" >> $ESTIMATOR_INPUT
echo "params 3-12" >> $ESTIMATOR_INPUT
echo "//rejection" >> $ESTIMATOR_INPUT
#echo "numRetained 1000000" >> $ESTIMATOR_INPUT
echo "tolerance 0.05" >> $ESTIMATOR_INPUT
echo "maxReadSims 1000000" >> $ESTIMATOR_INPUT
echo "//parameters for posterior estimation" >> $ESTIMATOR_INPUT
echo "diracPeakWidth 0.01" >> $ESTIMATOR_INPUT
echo "posteriorDensityPoints 200" >> $ESTIMATOR_INPUT
echo "standardizeStats 1" >> $ESTIMATOR_INPUT
echo "pruneCorrelatedStats 1" >> $ESTIMATOR_INPUT
echo "writeRetained 1" >> $ESTIMATOR_INPUT
echo "task estimate" >> $ESTIMATOR_INPUT
echo "verbose" >> $ESTIMATOR_INPUT

sed -n -e '1p' -e "${OBS_LINE}p" $SUM_STATS \
    | cut -f 13-20 > pseudoObservedData_Obs${ITER_NUM}.obs

# Set output prefix to inclue observation number
echo "outputPrefix ABC_GLM_Obs${ITER_NUM}_" >> $ESTIMATOR_INPUT

ABCtoolbox $ESTIMATOR_INPUT &> /dev/null

# Creates:
#  ABC_GLM_Obs8_model0_BestSimsParamStats_Obs0.txt
#  ABC_GLM_Obs8_model0_MarginalPosteriorDensities_Obs0.txt
#  ABC_GLM_Obs8_model0_MarginalPosteriorCharacteristics.txt
#  ABC_GLM_Obs8_modelFit.txt

#module load R
#R --vanilla $ESTIMATOR_INPUT < ~/bin/ABCtoolbox/scripts/plotPosteriorsGLM.r

# ----------------------------------------------------------------------------------------
# --- Gather important results
# ----------------------------------------------------------------------------------------

POD_INPUT=`sed -n -e "${OBS_LINE}p" $SUM_STATS`

BOUNDS=`tail -n1 ABC_GLM_Obs${ITER_NUM}_model0_MarginalPosteriorCharacteristics.txt`

echo -e "$ITER_NUM\t$POD_INPUT\t$BOUNDS"

# ----------------------------------------------------------------------------------------
# --- Clean everything up
# ----------------------------------------------------------------------------------------

rm pseudoObservedData_Obs${ITER_NUM}.obs
rm ABCestimator_Obs${ITER_NUM}.input
rm ABC_GLM_Obs${ITER_NUM}_model0_BestSimsParamStats_Obs0.txt
rm ABC_GLM_Obs${ITER_NUM}_model0_MarginalPosteriorDensities_Obs0.txt
rm ABC_GLM_Obs${ITER_NUM}_model0_MarginalPosteriorCharacteristics.txt
rm ABC_GLM_Obs${ITER_NUM}_modelFit.txt
