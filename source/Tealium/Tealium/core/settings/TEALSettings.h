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
@property (nonatomic, weak) NSString *traceID;
@property (nonatomic, weak) NSString *visitorIDCopy;

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (BOOL) audienceStreamEnabled;
- (BOOL) autotrackingIvarsEnabled;
- (BOOL) autotrackingLifecycleEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) remoteCommandsEnabled;
- (BOOL) isValid;
- (BOOL) tagManagementEnabled;
- (BOOL) useHTTP;

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
