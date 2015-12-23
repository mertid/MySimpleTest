#!/bin/sh

######### BRIEF #################
# This is the automation main run loop
# Incoming arguments list:
# $1 = Project paths to search for xcode projects
# $2 = Array of build targets
# $3 = Array of tracetemplates to use
# $4 = Array of tracetemplate short names
# $5 = Target output folder
# $6 = Start Time as HHMMSS
# $7 = Number of test iterations to run
# $8 = Optional Prefix
# $9 = Optional Suffix

########## SETUP #############
projectPaths=$1
builds=($2)
traceTemplates=($3)
traceTemplatesShortNames=($4)
targetFolder=$5
# re-init start dates here as dates seem to pass through args strangely
startDateAsString=`date +%Y-%m-%d:%H:%M:%S`
startDate=$(date +"%s")
startTime=$6
runs=$7
prefix=$8
suffix=$9
#futureArg = ${10} - bash oddity for args 10+


######### Main Loop ##########
# replace unmatched glob with zero text
shopt -s nullglob


#startDateFolder=$(date +%F)

echo "\nStarting Tealium Performance Tests..."
echo "\n------------ STARTING SUMMARY -------------"
echo "Starting at: $startDateAsString"


# ITERATE through all iDevices connected
devicesR=`system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
devices=($devicesR)

    # Start test summary
    echo "Testing on ${#devices[@]} iDevice(s): ${devices[@]}"
    echo "Number of build targets: '${#builds[@]}' \n'${builds[@]}'"
    echo "Number of Traces to run: '${#traceTemplates[@]}' \n'${traceTemplates[@]}'"
    echo "Number of runs per Trace: $runs"
    echo "--------------------------------------------"

    for udid in ${devices[@]}
    do
        echo "\nTesting on device '$udid'"
        for build in ${builds[@]}
        do
            echo "\nProcessing build: $build"
            # BUILD
            sleep 2
            ./TestsScripts/BuildProjects.sh "$projectPaths/*.xcodeproj" $udid $build

            # DEPLOY TO DEVICE
            sleep 2
            app= $projectPaths/build/*/$build.app
            ./TestsScripts/DeployApp.sh $projectPaths/build/*/$build.app $udid

            # TEST against each target instruments template
            for (( i=0; $i < ${#traceTemplates[@]}; i+=1 ))
            do
                # Set Trace name
                traceTemplate=${traceTemplates[$i]}
                traceShortName=${traceTemplatesShortNames[$i]}
                traceFilename="$prefix$udid"_"$build"_"$traceShortName$suffix.trace"
                tracePath=$targetFolder"/"$traceFilename

                echo "\nRunning trace '$traceShortName' for build '$build' on device '$udid'"
                echo "Tracefilename: $traceFilename"
                echo "TracePath: $tracePath"

                ./TestsScripts/RunInstruments.sh "$tracePath" "$udid" "$build" "$traceTemplate" $runs
            done
        done
    done

endDate=$(date +"%s")
diff=$(($endDate-$startDate))
endDateString=`date +%Y-%m-%d:%H:%M:%S`
echo "\n------------ ENDING SUMMARY -------------"
echo "Testing Completed at $endDateString"
echo "Testing took $(($diff / 60)) minutes and $(($diff % 60)) seconds."
echo "--------------------------------------------"

