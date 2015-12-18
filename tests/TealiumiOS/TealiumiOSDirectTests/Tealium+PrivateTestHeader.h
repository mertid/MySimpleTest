//
//  TealiumCollect+PrivateHeader.h
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  USE Tealium+PrivateHeader instead

#import "Tealium.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALDispatchManager.h"
#import "TEALURLSessionManager.h"
#import "TEALVisitorProfileStore.h"

@interface Tealium (PrivateTest)

@property (nonatomic, strong) TEALSettings * _Nullable settings;
@property (nonatomic, strong) TEALOperationManager * _Nullable operationManager;
@property (nonatomic, strong) TEALVisitorProfileStore * _Nullable profileStore;
@property (nonatomic, strong) TEALDispatchManager * _Nullable dispatchManager;
@property (nonatomic, strong) TEALURLSessionManager * _Nullable urlSessionManager;

@property (nonatomic) BOOL enabled;

+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key
                               configuration:(TEALConfiguration * _Nonnull)configuration
                                  completion:(TEALBooleanCompletionBlock _Nullable)completion;
    
+ (void) addInstanceForKey:(NSString * _Nonnull)key
             configuration:(TEALConfiguration * _Nonnull)configuration
                completion:(void (^ _Nullable)(Tealium * _Nullable instance, NSError * _Nullable error))completion;
    
+ (_Nullable instancetype) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration completion:(TEALBooleanCompletionBlock _Nullable) completion;

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock _Nullable)completion;

- (void) fetchSettings:(TEALSettings * _Nonnull)settings
            completion:(TEALBooleanCompletionBlock _Nullable)setupCompletion;

- (void) enable;

- (void) joinTraceWithToken:(NSString * _Nonnull)token;

- (void) leaveTrace;

@end

