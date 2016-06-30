#!/bin/bash

cd Builder_Dynamic
sh buildlibs.sh

cd ..
cd Builder_Dynamic_Lifecycle
sh buildlifecycle.sh