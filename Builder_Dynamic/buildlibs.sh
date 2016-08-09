#!/bin/bash

# Destination Options:
# OS X, your Mac
# iOS, a connected iOS device
# iOS Simulator
# watchOS
# watchOS Simulator
# tvOS
# tvOS Simulator

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOS -destination "platform=iOS Simulator,name=iPhone 6" -configuration Release
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOS_DevicesOnly -destination generic/platform=iOS -configuration Release

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOSLifecycle -destination "platform=iOS Simulator,name=iPhone 6" -configuration Release
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOSLifecycle_DevicesOnly -destination generic/platform=iOS -configuration Release

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS -destination "platform=tvOS Simulator,name=Apple TV 1080p" -configuration Release
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS_DevicesOnly -destination generic/platform=tvOS -configuration Release

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOSLifecycle -destination "platform=tvOS Simulator,name=Apple TV 1080p" -configuration Release
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOSLifecycle_DevicesOnly -destination generic/platform=tvOS -configuration Release

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumWATCHOSExtension -destination "platform=watchOS Simulator,name=Apple Watch - 38mm" -configuration Release
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumWATCHOSExtension_DevicesOnly -destination generic/platform=watchOS -configuration Release