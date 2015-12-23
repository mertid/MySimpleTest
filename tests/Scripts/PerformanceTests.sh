#!/bin/sh

######### BRIEF #################
# Runs automated UI tests with instruments trace data on ALL iDevices attached to the testing system
# To run script simply drag and drop thhis script into a terminal window


########## SETUP #################
# Modify only these variables of the tests

# Path for all xcode projects to build, wildcard * acceptable
#projectPaths="./UIAutomatedApps/iOS6_UICatalog"
projectPaths="./../iOS9/objc/UIKitCatalog/Tealium"

# Array of build targets to build - separate builds with single space
#builds=("iOS6_Automated_Catalog_noLib" "iOS6_Automated_Catalog_Compact" "iOS6_Automated_Catalog_Full")
#builds="iOS6_Automated_Catalog_noLib iOS6_Automated_Catalog_Compact iOS6_Automated_Catalog_Full"
builds="PerformanceTest"

# Array of tracetemplates to use for runs - separate templates with single space
#traceTemplates=("iOS6_UICatalogAutomation+Memory.tracetemplate" "iOS6_UICatalogAutomation+TimeProfiler")
#traceTemplates="iOS6_UICatalogAutomation+Memory.tracetemplate iOS6_UICatalogAutomation+TimeProfiler.tracetemplate"
traceTemplates="UIKitCatalogAutomation+Memory.tracetemplate UIKitCatalogAutomation+TimeProfiler.tracetemplate"

# Array of tracetemplate shortnames to append to output trace files in TestsScriptsResults - separate names with single space
traceTemplatesShortNames="memory profile"

# Number of test iterations per trace.
numberOfRuns=1

# Results folder path
resultsPath=./TestsScriptsResults

# Optionals - Add prefix or suffixes to log and trace name (ie online_ and _test respective)
prefix="Online_"
suffix=""

######### START ##########


# Make sure working directory is Performance app dir
DIR="$( cd "$( dirname "$0" )" && pwd )"
if [ "$PWD" != "$DIR" ]
then
echo "\nSwitching working directory to Performance Testing directory: '$DIR'"
cd $DIR
fi

# Set date & time
startDate=$(date +%F)
startTime=`date +%H%M%S`

# create new target folder OUTSIDE of our git repo
targetFolder=../../PerformanceTestResults/$startDate/$startTime
mkdir -p "../../PerformanceTestResults/$startDate/$startTime"
cd $DIR

# Execute scripts and log
./TestsScripts/MainLoop.sh "$projectPaths" "$builds" "$traceTemplates" "$traceTemplatesShortNames" $targetFolder "$startTime" $numberOfRuns "$prefix" "$suffix" 2>&1 | tee $targetFolder"/"$prefix"Performance_Tests"$suffix.log





