Tealium iOS Performance Test Automations
========================================

This folder contains all the elements needed to run the current suite of Performance tests automatically.


Requirements
--------------------

- Xcode Command line tools (packaged with Xcode)
- Instruments (packaged with Xcode)
- iOS-Deploy installed: commandline: "npm install -g ios-deploy" (more info at: https://github.com/phonegap/ios-deploy )


Setup
----------

1. On dev machine: open all target /UIAutomationTemplates/*.tracetemplates and reimport the walkthrough.js automation script.  This is necessary as Instruments does not use relative paths for these scripts
2. If target iDevices have never been ran through Instruments on dev machine, manually run once for each device, as the command line Instruments can not see such devices until then
3. Make certain all build target names EXACTLY MATCH the executable (product name in build settings)
4. Adjust any configuration settings in the StartTest.sh file with Xcode


How To Use
----------
Drag the StartTests.sh file into any terminal window.  The script will change the working directory to it's own and execute from there.


Output
------
A sub-folder named PerformanceTestResults will be populated with logs and trace files located in folders separated by date and time (HHMMSS) of test start (ie, ~/PerformanceTestResults/2015-01-15/164501/...)


UDID References
---------------

- iPad4 = "0308f0502478b3ddb6bacf1537c99bb106f58f58"
- iPad1 = "ead2f7a2bf93dce597c488f9e837c6cbd19e08eb"
- iPadMini1 = "b6e51b9f477fb622ff80666caa964dfe3a5527ab"
- iPhone5_Jason = "a08886fffae3a244d82b3463e1a3b2d6836a93cf"
