#!/bin/bash


#######################################
#
# SurLaTablo
#
# Try our best to grab the latest surlatablo python script from http://endlessnow.com/ten/SurLaTablo/
#  The maintainer of this keeps version numbers in the file names,
#  so we'll never know the exact file to grab for sure.
#  Try to determine the file to grab by matching on a pattern, then
#  grabbing the newest dated file.
#
#######################################

# Candidate files match the following pattern
SAR=surlatablo-*-py*
SLT_TEMP=/tmp/surlatablo
dSCRIPTS=/config/scripts
dCONF=/config/conf

mkdir -p $SLT_TEMP $dSCRIPTS $dCONF

wget -r -l1 -nd http://endlessnow.com/ten/SurLaTablo/ -P $SLT_TEMP -A "$SAR"
fileToKeep=`ls $SLT_TEMP/$SAR -t | head -1`
cp $fileToKeep /config/scripts/surlatablo.py
rm -rf $SLT_TEMP
chmod +x /config/scripts/surlatablo.py

# Example files for user specialization.
# Update these and remove their "example_" prefix to enable their use.
cp /root/surlatablo/conf/example_surlatablo.conf /config/conf/example_surlatablo.conf
cp /root/surlatablo/scripts/example_cpFromTablo /config/scripts/example_cpFromTablo

exit 0
