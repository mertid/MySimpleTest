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

- (instancetype) initWithConfiguration:(TEALConfiguration *)configuration;

- (BOOL) audienceStreamEnabled;
- (BOOL) autotrackingUIEventsEnabled;
- (BOOL) autotrackingViewsEnabled;
- (BOOL) isValid;
- (BOOL) lifecycleEnabled;
- (BOOL) tagManagementEnabled;
- (BOOL) useHTTP;

- (NSString *) account;
- (NSString *) asProfile;
- (NSString *) tiqProfile;
- (NSString *) environment;
- (NSString *) dispatchURLString;
- (NSString *) publishSettingsDescription;
- (NSString *) publishSettingsURLString;
- (NSString *) publishURLString;
- (NSString *) visitorIDCopy;

- (NSUInteger) dispatchSize;
- (NSUInteger) logLevel;
- (NSUInteger) offlineDispatchQueueSize;
- (NSUInteger) pollingFrequency;

- (NSURL *) profileURL;
- (NSURL *) profileDefinitionsURL;

- (void) fetchPublishSettingsWithCompletion:(TEALFetchPublishSettingsCompletionBlock)completion;
- (void) loadArchivedSettings;
- (void) setVisitorIDCopy:(NSString *)visitorID;

@end
