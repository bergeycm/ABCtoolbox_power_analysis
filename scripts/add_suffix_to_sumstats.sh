#!/bin/bash

# ----------------------------------------------------------------------------------------
# --- Add suffix to summary stats
# ----------------------------------------------------------------------------------------

SUM_STAT_FILE=$1
SUFFIX=$2

mv $SUM_STAT_FILE $SUM_STAT_FILE.backup

sed -e "1s/\t/_$SUFFIX\t/g" $SUM_STAT_FILE.backup > $SUM_STAT_FILE
