#!/bin/bash

SECONDS=0
# START BUILD -->

cd Builder_Dynamic
sh buildlibs.sh

# <--- END BUILD
duration=$SECONDS
echo ""
echo "********************************************************"
echo "Build all completed in $(($duration / 60)) minutes and $(($duration % 60)) seconds."
echo "********************************************************"