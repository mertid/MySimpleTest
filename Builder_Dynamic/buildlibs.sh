#!/bin/bash

# Destination Options:
# OS X, your Mac
# iOS, a connected iOS device
# iOS Simulator
# watchOS
# watchOS Simulator
# tvOS
# tvOS Simulator

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOS -destination "platform=iOS Simulator,name=iPhone 6"
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOS_DevicesOnly -destination generic/platform=iOS

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS -destination "platform=tvOS Simulator,name=Apple TV 1080p"
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS_DevicesOnly -destination generic/platform=tvOS


# TODO: watchOS
