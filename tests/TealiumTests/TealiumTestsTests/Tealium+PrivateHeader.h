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

@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALVisitorProfileStore *profileStore;
@property (nonatomic, strong) TEALDispatchManager *dispatchManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;

@property (nonatomic) BOOL enabled;

//+ (instancetype) sharedInstanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion;

+ (instancetype) instanceForKey:(NSString *)key configuration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock)completion;

- (instancetype) initPrivate;

- (void) instanceWithConfiguration:(TEALConfiguration *)configuration
                 completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) fetchSettings:(TEALSettings *)settings
            completion:(TEALBooleanCompletionBlock)setupCompletion;

- (void) enable;

- (void) joinTraceWithToken:(NSString *)token;

- (void) leaveTrace;

@end

