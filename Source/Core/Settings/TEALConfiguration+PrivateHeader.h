//
//  TEALConfiguration+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 9/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALConfiguration_PrivateHeader_h
#define TEALConfiguration_PrivateHeader_h

#import "TEALConfiguration.h"

@interface TEALConfiguration (Private)

// TODO: comments
@property (nonatomic) BOOL autotrackingCrashesEnabled;

// TODO: comments
@property (nonatomic) BOOL autotrackingDeviceInfoEnabled;

// TODO: comments
@property (nonatomic) BOOL autotrackingIvarsEnabled;

// TODO: comments
@property (nonatomic) BOOL autotrackingLifecycleEnabled;

// TODO: comments
@property (nonatomic) BOOL autotrackingUIEventsEnabled;

// TODO: comments
@property (nonatomic) BOOL autotrackingViewsEnabled;

// TODO: comments
@property (nonatomic) BOOL mobileCompanionEnabled;

// TODO: comments
@property (nonatomic) BOOL remoteCommandsEnabled;

@property (nonatomic) BOOL autotrackingApplicationInfoEnabled;
@property (nonatomic) BOOL autotrackingCarrierInfoEnabled;
@property (nonatomic) BOOL autotrackingTimestampInfoEnabled;

@property (nonatomic) NSString *overridePublishSettingsVersion;

@end

#endif
