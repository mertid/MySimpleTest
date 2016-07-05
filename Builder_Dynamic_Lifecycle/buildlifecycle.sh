#!/bin/bash

# Destination Options:
# OS X, your Mac
# iOS, a connected iOS device
# iOS Simulator
# watchOS
# watchOS Simulator
# tvOS
# tvOS Simulator

xcodebuild -project FrameworkBuilder_Lifecycle.xcodeproj -scheme TealiumIOSLifecycle -destination "platform=iOS Simulator,name=iPhone 6"
xcodebuild -project FrameworkBuilder_Lifecycle.xcodeproj -scheme TealiumIOSLifecycle_DevicesOnly -destination generic/platform=iOS

xcodebuild -project FrameworkBuilder_Lifecycle.xcodeproj -scheme TealiumTVOSLifecycle -destination "platform=tvOS Simulator,name=Apple TV 1080p"
xcodebuild -project FrameworkBuilder_Lifecycle.xcodeproj -scheme TealiumTVOSLifecycle_DevicesOnly -destination generic/platform=tvOS

# TODO: watchOS
