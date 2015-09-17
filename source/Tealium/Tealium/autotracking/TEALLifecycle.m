//
//  TEALApplicationLifecycle.m
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycle.h"
#import "TEALLifecycleStore.h"
#import "Tealium.h"
#import "TEALDataSourceConstants.h"

@interface TEALLifecycle ()

@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) NSString *ivarInstanceID;
@property (nonatomic, copy) TEALDictionaryCompletionBlock eventProcessingBlock;
@property (nonatomic, strong) TEALLifecycleStore *ivarStore;

@end

@implementation TEALLifecycle

#warning ADD milestone dates tracking system

#pragma mark - PUBLIC

- (instancetype) initWithInstanceID:(NSString *)instanceID {
    self = [super init];
    if (self) {
        
        _ivarInstanceID = instanceID;
        
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
    return self.ivarInstanceID;
}

- (TEALLifecycleStore *) store {

    if (!self.ivarStore){
        self.ivarStore = [[TEALLifecycleStore alloc] initWithInstanceID:[self instanceID]];
    }
    
    return self.ivarStore;
    
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

- (void) processLifecycleEvent:(NSNotification*) notification {
    
    if (!self.isEnabled){
        return;
    }
    
    NSString *name = notification.name;
    NSString *eventName = nil;
        
    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]){
        eventName = TEALDataSourceValue_LifecycleLaunch;
    }
    else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]){
        eventName = TEALDataSourceValue_LifecycleSleep;
    }
    else if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]){
        eventName = TEALDataSourceValue_LifecycleWake;
    }
    else if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        eventName = TEALDataSourceValue_LifecycleSleep;
    }
    else if ([name isEqualToString:UIApplicationWillTerminateNotification]){
        eventName = TEALDataSourceValue_LifecycleTerminate;
    }
    else {
        eventName = TEALDataSourceValue_Unknown;
    }

#warning COMPLETE with additional lifeycycle data
    
    NSDictionary *lifecycleData = @{TEALDataSourceKey_LifecycleType: eventName};
    
    if (self.eventProcessingBlock) {
        // TODO: Add error handling?
        
        self.eventProcessingBlock(lifecycleData, nil);
    }
}

//- (NSString *) description {
//    return [NSString stringWithFormat:@"TEALLifecycle with instanceID: %@", self.instanceID];
//}

- (void) dealloc {
    
    [self disableListeners];
        
}

#pragma mark - HELPERS



@end
