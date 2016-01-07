#!/bin/sh

######## BRIEF ##########
# Builds a single xcode build target for device
# $1 = array locations of xcode projects as string
# $2 = target device udid
# $3 = build target

######### SETUP ##########
projects=$1
udid=$2
build=$3

######### Main Loop ##########
echo "\nBuilding target '$build' for device '$udid'"

# replace unmatched glob with zero text
shopt -s nullglob

if [ -z $projects ]
then
    echo "No projects to build. Check target directory: $apps"
else
    # BUILD all projects for target device
    for x in $projects
        do
            echo "Building xcodeproject: '$x' from '$projects' for build '$build'"
            xcodebuild -project $x -target $build -destination platform=iOS,id=$udid -configuration Release clean build
        done
    #TODO: Add actual verification
    echo "Finished building xcodeprojects from " $projects
fi



