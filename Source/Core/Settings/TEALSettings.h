//
//  TEALSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALConfiguration;
@class TEALPublishSettings;
@class TEALURLSessionManager;

@interface TEALSettings : NSObject

@property (weak) TEALURLSessionManager *urlSessionManager;
@property (weak) NSString *traceID;
@property (weak) NSString *visitorIDCopy;

- (instancetype _Nullable) initWithConfiguration:(TEALConfiguration * _Nonnull)configuration;

- (BOOL) autotrackingDeviceInfoEnabled;
- (BOOL) autotrackingIvarsEnabled;
- (BOOL) autotrackingLifecycleEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) autotrackingCrashesEnabled;
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

- (NSString * _Nonnull) account;
- (NSString * _Nonnull) asProfile;
- (NSString * _Nonnull) tiqProfile;
- (NSString * _Nonnull) environment;
- (NSString * _Nonnull) instanceID;

- (NSUInteger) dispatchSize;
- (NSString * _Nonnull) logLevelString;
- (NSUInteger) offlineDispatchQueueSize;

- (NSString * _Nullable) configurationDescription;
- (NSString * _Nullable) publishSettingsDescription;
- (NSString * _Nullable) publishSettingsURLString;
- (NSString * _Nullable) publishURLString;

#warning move to collect module
- (NSURL * _Nullable) profileURL;
- (NSURL * _Nullable) profileDefinitionsURL;

- (TEALPublishSettings * _Nonnull) publishSettings;

/*
 *  Trigger settings to check for new publish settings
 *
 *  @param completion Returns a completion block when complete. Success equals
 *      true if new settings found, false if no settings found or if no change
 *      in settings found.
 */
- (void) fetchNewRawPublishSettingsWithCompletion:(void (^ _Nonnull)(BOOL success, NSError * _Nullable error))completion;

@end
