#!/bin/sh

######## BRIEF ##########
# Deploys xcode build to target device then kicks off tests
# $1 = path to app
# $2 = target device udid

######### SETUP ##########
appPath=$1
echo "\nDeploying app from: $appPath"
echo "Deploying to device: $2"


######### Main Loop ##########
shopt -s nullglob

# Install to each testing device, if connected
ios-deploy -b $appPath -t 1 -i $2



