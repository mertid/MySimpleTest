//
//  TEALSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALPublishSettings.h"
#import "TEALBlocks.h"
#import "TEALLogger.h"

@class TEALConfiguration;
@class TEALURLSessionManager;

typedef void (^TEALFetchPublishSettingsCompletionBlock)(TEALPublishSettingsStatus status, NSError *error);

@interface TEALSettings : NSObject

@property (weak) TEALURLSessionManager *urlSessionManager;
@property (readonly) TEALPublishSettings *publishSettings;
@property (weak) NSString *traceID;
@property (weak) NSString *visitorIDCopy;

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (BOOL) autotrackingDeviceInfoEnabled;
- (BOOL) autotrackingIvarsEnabled;
- (BOOL) autotrackingLifecycleEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) autotrackingCrashesEnabled;
- (BOOL) collectEnabled;
- (BOOL) collectLegacyEnabled;
- (BOOL) libraryShouldDisable;
- (BOOL) mobileCompanionEnabled;
- (BOOL) remoteCommandsEnabled;
- (BOOL) isValid;
- (BOOL) tagManagementEnabled;
- (BOOL) useHTTP;
- (BOOL) wifiOnlySending;
- (BOOL) goodBatteryLevelOnlySending;
- (BOOL) isDefaultPublishSettings;

- (double) daysDispatchesValid;

- (NSString *) account;
- (NSString *) asProfile;
- (NSString *) tiqProfile;
- (NSString *) environment;
- (NSString *) instanceID;

- (NSUInteger) dispatchSize;
- (TEALLogLevel) logLevel;
- (NSUInteger) offlineDispatchQueueSize;

- (NSString *) collectDispatchURLString;
- (NSString *) collectLegacyDispatchURLString;
- (NSString *) configurationDescription;
- (NSString *) publishSettingsDescription;
- (NSString *) publishSettingsURLString;
- (NSString *) publishURLString;
- (NSUInteger) pollingFrequency;
- (NSURL *) profileURL;
- (NSURL *) profileDefinitionsURL;

/*
 *  Trigger settings to check for new publish settings
 *
 *  @param completion Returns a completion block when complete. Success equals
 *      true if new settings found, false if no settings found or if no change
 *      in settings found.
 */
- (void) fetchNewRawPublishSettingsWithCompletion:(TEALBooleanCompletionBlock)completion;

@end
