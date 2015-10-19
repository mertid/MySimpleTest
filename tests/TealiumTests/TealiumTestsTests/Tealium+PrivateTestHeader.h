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

@interface Tealium (PrivateTest)

@property (nonatomic, strong) TEALSettings * _Nullable settings;
@property (nonatomic, strong) TEALOperationManager * _Nullable operationManager;
@property (nonatomic, strong) TEALVisitorProfileStore * _Nullable profileStore;
@property (nonatomic, strong) TEALDispatchManager * _Nullable dispatchManager;
@property (nonatomic, strong) TEALURLSessionManager * _Nullable urlSessionManager;

@property (nonatomic) BOOL enabled;

+ (void) addInstanceForKey:(NSString * _Nonnull)key
             configuration:(TEALConfiguration * _Nonnull)configuration
                completion:(void (^ _Nullable)(Tealium * _Nullable instance, NSError * _Nullable error))completion;
    
+ (_Nullable instancetype) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration completion:(TEALBooleanCompletionBlock _Nullable) completion;

- (_Nullable instancetype) initPrivate;

- (void) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration
                 completion:(TEALBooleanCompletionBlock _Nullable)setupCompletion;


- (void) fetchSettings:(TEALSettings * _Nonnull)settings
            completion:(TEALBooleanCompletionBlock _Nullable)setupCompletion;

- (void) enable;

- (void) joinTraceWithToken:(NSString * _Nonnull)token;

- (void) leaveTrace;

@end

