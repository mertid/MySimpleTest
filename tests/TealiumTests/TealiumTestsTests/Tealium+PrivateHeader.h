//
//  TealiumCollect+PrivateHeader.h
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettingsStore.h>
#import <Tealium/TEALDispatchManager.h>
#import <Tealium/TEALURLSessionManager.h>
#import <Tealium/TEALVisitorProfileStore.h>

@interface Tealium (Private)

@property (strong, nonatomic) TEALSettingsStore *settingsStore;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALVisitorProfileStore *profileStore;
@property (strong, nonatomic) TEALDispatchManager *dispatchManager;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;

@property (nonatomic) BOOL enabled;

- (instancetype) initPrivate;

- (void) setupConfiguration:(TEALConfiguration *)configuration
                 completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) fetchSettings:(TEALSettings *)settings
            completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) enable;

- (void) joinTraceWithToken:(NSString *)token;
- (void) leaveTrace;

@end

