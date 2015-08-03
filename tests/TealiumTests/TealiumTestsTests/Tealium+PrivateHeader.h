//
//  TealiumCollect+PrivateHeader.h
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettings.h>
#import <Tealium/TEALDispatchManager.h>
#import <Tealium/TEALURLSessionManager.h>
#import <Tealium/TEALVisitorProfileStore.h>

@interface Tealium (Private)

@property (strong, nonatomic) TEALSettings *settings;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALVisitorProfileStore *profileStore;
@property (strong, nonatomic) TEALDispatchManager *dispatchManager;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;

@property (nonatomic) BOOL enabled;

+ (instancetype) sharedInstanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion;

- (instancetype) initPrivate;

- (void) instanceWithConfiguration:(TEALConfiguration *)configuration
                 completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) fetchSettings:(TEALSettings *)settings
            completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) enable;

- (void) joinTraceWithToken:(NSString *)token;
- (void) leaveTrace;

@end

