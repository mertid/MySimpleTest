//
//  TEALSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALPublishSettings.h"

@class TEALConfiguration;
@class TEALURLSessionManager;

typedef void (^TEALFetchPublishSettingsCompletionBlock)(TEALPublishSettingsStatus status, NSError *error);

@interface TEALSettings : NSObject

@property (weak) TEALURLSessionManager *urlSessionManager;
@property (weak) NSString *traceID;
@property (weak) NSString *visitorIDCopy;

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (BOOL) audienceStreamEnabled;
- (BOOL) autotrackingDeviceInfoEnabled;
- (BOOL) autotrackingIvarsEnabled;
- (BOOL) autotrackingLifecycleEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) autotrackingCrashesEnabled;
- (BOOL) mobileCompanionEnabled;
- (BOOL) remoteCommandsEnabled;
- (BOOL) isValid;
- (BOOL) tagManagementEnabled;
- (BOOL) useHTTP;

- (double) daysDispatchesValid;

- (NSString *) account;
- (NSString *) asProfile;
- (NSString *) tiqProfile;
- (NSString *) environment;
- (NSString *) instanceID;

- (NSUInteger) dispatchSize;
- (NSUInteger) logLevel;
- (NSUInteger) offlineDispatchQueueSize;

- (NSString *) publishSettingsDescription;
- (NSString *) publishSettingsURLString;
- (NSString *) publishURLString;
- (NSString *) dispatchURLString;
- (NSUInteger) pollingFrequency;
- (NSURL *) profileURL;
- (NSURL *) profileDefinitionsURL;
- (void) fetchPublishSettingsWithCompletion:(TEALFetchPublishSettingsCompletionBlock)completion;
- (void) loadArchivedSettings;



@end
