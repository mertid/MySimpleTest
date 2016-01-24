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

- (instancetype _Nullable) initWithConfiguration:(TEALConfiguration * _Nonnull)configuration;

- (BOOL) autotrackingDeviceInfoEnabled;
- (BOOL) autotrackingIvarsEnabled;
- (BOOL) autotrackingLifecycleEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) autotrackingCrashesEnabled;
- (BOOL) libraryShouldDisable;
- (BOOL) mobileCompanionEnabled;
- (BOOL) isValid;
- (BOOL) wifiOnlySending;
- (BOOL) goodBatteryLevelOnlySending;
- (BOOL) isDefaultPublishSettings;

- (double) daysDispatchesValid;
- (double) minutesBetweenRefresh;

- (NSString * _Nonnull) account;
- (NSString * _Nonnull) asProfile;
- (NSString * _Nonnull) tiqProfile;
- (NSString * _Nonnull) environment;

- (NSUInteger) dispatchSize;
- (NSString * _Nonnull) logLevelString;
- (NSUInteger) offlineDispatchQueueSize;

- (NSString * _Nullable) configurationDescription;
- (NSString * _Nullable) publishSettingsDescription;
- (NSString * _Nullable) publishSettingsURLString;

- (TEALPublishSettings * _Nonnull) publishSettings;

/*
 *  Trigger settings to check for new publish settings
 *
 *  @param completion Returns a completion block when complete. Success equals
 *      true if new settings found, false if no settings found or if no change
 *      in settings found.
 */
- (void) fetchNewRawPublishSettingsWithCompletion:(void (^ _Nonnull)(BOOL success, NSError * _Nullable error))completion;

/**
 *  Set current trace id.  Calls current Configurations setTraceID.
 *
 *  @param traceID String identifier of trace to use.
 */
//- (void) setTraceID:(NSString * _Nullable)traceID;

/**
 *  Removes all publish settings from archive.
 */
- (void) purgeAllArchives;

@end
