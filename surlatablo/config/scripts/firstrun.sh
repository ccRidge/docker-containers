#!/bin/bash


#######################################
#
# SurLaTablo
#
# Use $VERSION, if specified, or just try our best
#  to grab the latest surlatablo python script from 
#  http://endlessnow.com/ten/SurLaTablo/.
# The maintainer of this keeps version numbers in the file names,
#  so we'll never know the exact file to grab for sure.
# Best effort method of determining the file to grab is 
#  based on pattern matching, then grabbing the newest
# file by modification time.
#
#######################################

# Candidate files match the following pattern
SAR=surlatablo-*-py*
SLT_TEMP=/tmp/surlatablo
dSCRIPTS=/config/scripts
dCONF=/config/conf

mkdir -p $SLT_TEMP $dSCRIPTS $dCONF

if [ -n "$VERSION" ] && [ "$VERSION" != "noupdate" ]; then  # $VERSION is non-zero length and is not equal to `noupdate`
    wget "http://endlessnow.com/ten/SurLaTablo/$VERSION" -P $SLT_TEMP
fi
# Wget non-zero exit status or null $VERSION will trigger best effort,
# most recently modified surlatablo script.
if [ $? -ne 0 ] || [ -z "$VERSION" ]; then
    wget -r -l1 -nd "http://endlessnow.com/ten/SurLaTablo/" -P $SLT_TEMP -A "$SAR"
fi
    fileToKeep=`ls $SLT_TEMP/$SAR -t | head -1`
    cp $fileToKeep /config/scripts/surlatablo.py
rm -rf $SLT_TEMP
chmod +x /config/scripts/surlatablo.py

# Example files for user specialization.
# Update these and remove their "example_" prefix to enable their use.
cp /root/surlatablo/conf/example_surlatablo.conf /config/conf/example_surlatablo.conf
cp /root/surlatablo/scripts/example_cpFromTablo /config/scripts/example_cpFromTablo

touch /var/log/cron.log
nohup /bin/bash -c "/usr/bin/tail -f /var/log/cron.log &"

exit 0
