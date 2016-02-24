# Tealium Dynamic Framework Builder

This Builder project leverages Carthage's system for creating and archiving a
simulator supported framework.

Scripts output to the Carthage/ subfolder and them oves them to the target tealium-ios and tealium-tvos folders (same heirarchy level as the top level builder folder)

# Build Notes

Select any simulator to build the framework from - issues when building from a Generic device scheme.

## tvOS
tvOS currently requires the TARGETED_DEVICE_FAMILY=4 macro