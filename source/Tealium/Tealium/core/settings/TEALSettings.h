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

@property (nonatomic, weak) TEALURLSessionManager *urlSessionManager;
@property (nonatomic, weak) NSString *visitorID;
@property (nonatomic, weak) NSString *traceID;

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (void) fetchPublishSettingsWithCompletion:(TEALFetchPublishSettingsCompletionBlock)completion;

- (void) loadArchivedSettings;

- (BOOL) isValid;
- (BOOL) lifecycleEnabled;
- (BOOL) tagManagementEnabled;
- (BOOL) audienceStreamEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) useHTTP;

- (NSUInteger) dispatchSize;
- (NSUInteger) offlineDispatchQueueSize;
- (NSUInteger) logLevel;
- (NSUInteger) pollingFrequency;

- (NSString *) account;
- (NSString *) asProfile;
- (NSString *) tiqProfile;
- (NSString *) environment;
- (NSString *) overridePublishSettingsURL;
- (NSString *) overridePublishURL;
- (NSString *) publishSettingsDescription;

@end
