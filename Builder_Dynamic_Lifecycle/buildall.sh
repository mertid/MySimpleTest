#!/bin/bash

xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumIOSLifecycle -destination 'platform=iOS Simulator,name=iPhone 6'
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOS -destination 'platform=tvOS Simulator,name=Apple TV 1080p'
xcodebuild -project FrameworkBuilder.xcodeproj -scheme TealiumTVOSLifecycle -destination 'platform=tvOS Simulator,name=Apple TV 1080p'

