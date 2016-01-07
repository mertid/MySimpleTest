#!/bin/sh

######### BRIEF ##############
# runs uiautomation tests through instruments
# $1 = full trace file path (UICatalog_Clean_aXXX...trace)
# $2 = udid
# $3 = app build path to *.app
# $4 = trace template to use
# $5 = number of test iterations to do


########## SETUP #############
date=$(date +%F)
trace=$1
udid=$2
appBuildPath=$3
traceTemplate=$4
runs=$5

######### Main Loop ##########
shopt -s nullglob

# Use applescript to quit instruments before running
osascript -e 'tell app "Instruments" to quit'

echo "Target Instruments Trace: $trace"
echo "Target Instruments device: $udid"

# Delete prior existing target trace file (can we just overwrite?)
if [ -e "$trace" ]
then
    rm -f -r $trace
    echo "Deleted prior trace file: $trace"
fi

echo "\nStarting $runs Instrument Run(s) for trace (full filepath): '$trace'"

#run tests
i=1
while [ $i -le $runs ]
do
    echo "\nRunning test: '$i' of '$runs' for trace: $trace"
    sleep 2
    instruments -w $udid -t ./UIAutomationTemplates/$traceTemplate -D $trace $appBuildPath
    i=$(( $i + 1 ))
done
