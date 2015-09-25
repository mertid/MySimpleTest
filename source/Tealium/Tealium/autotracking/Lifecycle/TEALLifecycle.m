//
//  TEALApplicationLifecycle.m
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycle.h"
#import "TEALLifecycleEvents.h"
#import "TEALLifecycleStore.h"
#import "Tealium.h"
#import "TEALDataSourceConstants.h"

@interface TEALLifecycle ()

@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) NSString *privateInstanceID;
@property (nonatomic, copy) TEALDictionaryCompletionBlock eventProcessingBlock;
@property (nonatomic, strong) TEALLifecycleStore *privateStore;

@property (nonatomic, strong) TEALLifecycleEvents *privateLaunchEvents;
@property (nonatomic, strong) TEALLifecycleEvents *privateWakeEvents;
@property (nonatomic, strong) TEALLifecycleEvents *privateSleepEvents;

@end

@implementation TEALLifecycle

#warning ADD milestone dates tracking system

#pragma mark - PUBLIC

- (instancetype) initWithInstanceID:(NSString *)instanceID {
    self = [super init];
    if (self) {
        
        _privateInstanceID = instanceID;
        _privateStore = [[TEALLifecycleStore alloc] initWithInstanceID:instanceID];
        [_privateStore loadArchive];
        
        _privateLaunchEvents = _privateStore[@"launchEvents"];
        _privateWakeEvents = _privateStore[@"wakeEvents"];
        _privateSleepEvents = _privateStore[@"sleepEvents"];
        
    }
    return self;
}

- (void) enableWithEventProcessingBlock:(TEALDictionaryCompletionBlock)block {
    
    // listen to main thread events
    
    self.enabled = YES;
    
    [self enableListeners];
    
    self.eventProcessingBlock = block;
    
}

- (void) disable {
    
    if (self.enabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.enabled = NO;
    }
}

- (void) reEnable {
    if (!self.enabled) {
        self.enabled = YES;
        [self enableListeners];
    }
}

- (void) recordLaunch {
    NSNotification *notification = [NSNotification notificationWithName:UIApplicationDidFinishLaunchingNotification object:self];
    [self processLifecycleEvent:notification];
}

- (BOOL) isEnabled {
    return self.enabled;
}

- (NSDictionary *)currentLifecycleData {
    
//    NSString *launchCount
    
#warning IMPLEMENT
    return nil;
    
}

#pragma mark - PRIVATE INSTANCE

- (instancetype) init {
    
    [NSException raise:@"Should not be initialize directly"
                format:@"Use the initWithInstanceID instead."];
    
    return nil;

}

- (NSString *) instanceID {
    return self.privateInstanceID;
}

- (TEALLifecycleStore *) store {

    if (!self.privateStore){
        self.privateStore = [[TEALLifecycleStore alloc] initWithInstanceID:[self instanceID]];
    }
    
    return self.privateStore;
    
}

- (void) enableListeners {
    
    NSArray *events = @[
                        UIApplicationDidBecomeActiveNotification,
                        UIApplicationDidEnterBackgroundNotification,
                        UIApplicationWillTerminateNotification
                        ];
    
    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processLifecycleEvent:)
                                                     name:obj
                                                   object:nil];
    }];
    
}

- (void) disableListeners {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (TEALLifecycleEvents *) launchEvents {
    if (!self.privateLaunchEvents) {
        self.privateLaunchEvents = [[TEALLifecycleEvents alloc] init];
    }
    return self.privateLaunchEvents;
}

- (TEALLifecycleEvents *) wakeEvents {
    if (!self.privateWakeEvents) {
        self.privateWakeEvents = [[TEALLifecycleEvents alloc] init];
    }
    return self.privateWakeEvents;
}

- (TEALLifecycleEvents *) sleepEvents {
    if (!self.privateSleepEvents) {
        self.privateSleepEvents = [[TEALLifecycleEvents alloc] init];
    }
    return self.privateSleepEvents;
}

- (void) processLifecycleEvent:(NSNotification*) notification {
    
    if (!self.isEnabled){
        return;
    }
    
    NSString *name = notification.name;
    NSString *eventName = nil;
        
    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]){
        eventName = TEALDataSourceValue_LifecycleLaunch;
    } else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]){
        eventName = TEALDataSourceValue_LifecycleSleep;
    } else if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]){
        eventName = TEALDataSourceValue_LifecycleWake;
    } else if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        eventName = TEALDataSourceValue_LifecycleSleep;
    } else if ([name isEqualToString:UIApplicationWillTerminateNotification]){
        eventName = TEALDataSourceValue_LifecycleTerminate;
    } else {
        eventName = TEALDataSourceValue_Unknown;
    }
    
#warning COMPLETE with additional lifeycycle data
    
    NSDictionary *lifecycleData = @{TEALDataSourceKey_LifecycleType: eventName};
    
    if (self.eventProcessingBlock) {
        // TODO: Add error handling?
        
        self.eventProcessingBlock(lifecycleData, nil);
    }
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ with instanceID: %@ launched:\n %@ wakes:\n%@ sleeps:\n%@",
            NSStringFromClass([self class]),
            self.instanceID,
            [self launchEvents],
            [self wakeEvents],
            [self sleepEvents]];
}

- (void) dealloc {
    
    [self disableListeners];
        
}

#pragma mark - HELPERS


@end
