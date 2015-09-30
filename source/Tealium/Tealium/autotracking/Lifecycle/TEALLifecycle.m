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
#import "TEALBlocks.h"
#import "TEALError.h"

NSString * const TEALKeyLifecycleLaunchEvents = @"launchEvents";
NSString * const TEALKeyLifecycleWakeEvents = @"wakeEvents";
NSString * const TEALKeyLifecycleSleepEvents = @"sleepEvents";

@interface TEALLifecycle ()

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL launchAlreadyDetected;
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
    
    [self processLifecycleEventWithName:TEALDataSourceValue_LifecycleLaunch];
    
}

- (BOOL) isEnabled {
    return self.enabled;
}

- (NSDictionary *)currentLifecycleData {
    
    NSNumber *launchCount = @([[self launchEvents] totalCount]);
    NSNumber *wakeCount = @([[self wakeEvents] totalCount]);
    NSNumber *sleepCount = @([[self sleepEvents] totalCount]);
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    if (launchCount)mDict[TEALDataSourceKey_LifecycleTotalLaunchCount] = launchCount;
    if (wakeCount)  mDict[TEALDataSourceKey_LifecycleTotalWakeCount] = wakeCount;
    if (sleepCount) mDict[TEALDataSourceKey_LifecycleTotalSleepCount] = sleepCount;

    
#warning IMPLEMENT remaining data sources
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

#pragma mark - PRIVATE LIFECYCLE

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
                                                 selector:@selector(processLifecycleEventWithNotification:)
                                                     name:obj
                                                   object:nil];
    }];
    
}

- (void) disableListeners {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) dealloc {
    
    [self disableListeners];
    
}

#pragma mark - PRIVATE CONVENIENCE ACCESSORS

- (TEALLifecycleEvents *) launchEvents {
    
    if (!self.privateLaunchEvents) {
        self.privateLaunchEvents = [[TEALLifecycleEvents alloc] init];
        NSDictionary *saveData = [self.privateStore loadDataForKey:TEALKeyLifecycleLaunchEvents];
        [self.privateLaunchEvents loadFromUserDefaults:saveData];
    }
    return self.privateLaunchEvents;
}

- (TEALLifecycleEvents *) wakeEvents {
    if (!self.privateWakeEvents) {
        self.privateWakeEvents = [[TEALLifecycleEvents alloc] init];
        [self.privateWakeEvents loadFromUserDefaults:[_privateStore loadDataForKey:TEALKeyLifecycleWakeEvents]];
        NSDictionary *saveData = [self.privateStore loadDataForKey:TEALKeyLifecycleWakeEvents];
        [self.privateWakeEvents loadFromUserDefaults:saveData];
    }
    return self.privateWakeEvents;
}

- (TEALLifecycleEvents *) sleepEvents {
    if (!self.privateSleepEvents) {
        self.privateSleepEvents = [[TEALLifecycleEvents alloc] init];
        [self.privateSleepEvents loadFromUserDefaults:[_privateStore loadDataForKey:TEALKeyLifecycleSleepEvents]];
        NSDictionary *saveData = [self.privateStore loadDataForKey:TEALKeyLifecycleSleepEvents];
        [self.privateSleepEvents loadFromUserDefaults:saveData];
    }
    return self.privateSleepEvents;
}


#pragma mark - PRIVATE 

- (void) processLifecycleEventWithNotification:(NSNotification*) notification {
    
    if (!self.isEnabled){
        return;
    }
    
    NSString *eventName = [self eventNameFromNotification:notification];
    
//    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
//        if (self.launchAlreadyDetected){
//            return;
//        }
//    }
    
    [self processLifecycleEventWithName:eventName];
    
}

#warning OPTIMIZE

- (NSString *) eventNameFromNotification:(NSNotification *) notification {
    
    NSString *name = notification.name;
    NSString *eventName = nil;
    
    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]){
        
        eventName = TEALDataSourceValue_LifecycleLaunch;
        
    } else if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]){
        
        eventName = TEALDataSourceValue_LifecycleWake;
        
    } else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification] ||
               [name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        
        eventName = TEALDataSourceValue_LifecycleSleep;
        
    } else if ([name isEqualToString:UIApplicationWillTerminateNotification]){
        
        eventName = TEALDataSourceValue_LifecycleTerminate;
        
    } else {
        
        eventName = TEALDataSourceValue_Unknown;
        
    }
    
    return eventName;
    
}


- (void) processLifecycleEventWithName:(NSString *)eventName {
    
    if(!eventName){
        return;
    }
    
    __block typeof(self) __weak weakSelf = self;
    __block NSMutableDictionary *mDict = [NSMutableDictionary dictionary];

    [self incrementEventWithName:eventName completion:^(BOOL success, NSError *error) {
        
        NSDictionary *lifecycleData = nil;
        
        if (success) {
            mDict[TEALDataSourceKey_LifecycleType] = eventName;
            
            [mDict addEntriesFromDictionary:[self currentLifecycleData]];
            
            lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
        }
#warning duplicate lifecycle launch events seen.
        
#warning First launch event does not have updated count, but all other events at the same time do
        
#warning Wakes and sleep events not loading from archive
        
        if (weakSelf.eventProcessingBlock) {
            
            weakSelf.eventProcessingBlock(lifecycleData, error);
        }
        
    }];
    

}


- (void) incrementEventWithName:(NSString *)eventName completion:(TEALBooleanCompletionBlock)completion{
    
    NSDictionary *data = nil;
    NSString *key = nil;
    TEALLifecycleEvents *events = nil;
    
    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]) {
        
        events = [self launchEvents];
        [events addEvent];
        data = [[self launchEvents] dataForUserDefaults];
        key = TEALKeyLifecycleLaunchEvents;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        
        events = [self wakeEvents];
        [events addEvent];
        data = [[self wakeEvents] dataForUserDefaults];
        key = TEALKeyLifecycleWakeEvents;
    
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        
        events = [self sleepEvents];
        [events addEvent];
        data = [[self sleepEvents] dataForUserDefaults];
        key = TEALKeyLifecycleSleepEvents;
    }
    
    if (!events){
        
        NSString *reason = [NSString stringWithFormat:@"No lifecycle event associated with eventName:%@", eventName];
        NSError *error = [TEALError errorWithCode:400
                                      description:@"Failed to increment lifecycle event."
                                           reason:reason
                                       suggestion:@"Contact Tealium Mobile Engineering - Reference Lifecycle Line 315."];
        
        if (completion) completion(NO, error);
        return;
    }
    
    if (!data){
        
        NSString *reason = [NSString stringWithFormat:@"Unable to retrieve lifecycle data for eventName:%@", eventName];
        NSError *error = [TEALError errorWithCode:400
                                      description:@"Failed to increment lifecycle event."
                                           reason:reason
                                       suggestion:@"Contact Tealium Mobile Engineering - Reference Lifecycle Line 327."];
        
        if (completion) completion(NO, error);
        return;
    }
    
    
    [self.store saveData:data forKey:eventName completion:^(BOOL success, NSError *error) {
        if (completion) completion(success, error);
    }];
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ with instanceID:%@ \n launches:%@ \n wakes:%@ \n sleeps:%@",
            NSStringFromClass([self class]),
            self.instanceID,
            [self launchEvents],
            [self wakeEvents],
            [self sleepEvents]];
}

@end
