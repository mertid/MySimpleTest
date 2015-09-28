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

    
#warning IMPLEMENT
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

    }
    return self.privateWakeEvents;
}

- (TEALLifecycleEvents *) sleepEvents {
    if (!self.privateSleepEvents) {
        self.privateSleepEvents = [[TEALLifecycleEvents alloc] init];
        [self.privateSleepEvents loadFromUserDefaults:[_privateStore loadDataForKey:TEALKeyLifecycleSleepEvents]];
    }
    return self.privateSleepEvents;
}


#pragma mark - PRIVATE 

- (void) processLifecycleEventWithNotification:(NSNotification*) notification {
    
    if (!self.isEnabled){
        return;
    }
    
    NSString *eventName = [self eventNameFromNotification:notification];
    
    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
        if (self.launchAlreadyDetected){
            return;
        }
    }
    
    [self processLifecycleEventWithName:eventName];
    
}

- (void) processLifecycleEventWithName:(NSString *)eventName {
    
    if(!eventName){
        return;
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];

    [self incrementEventWithName:eventName];
    
    [self updateStoreDataForEventWithName:eventName];

    mDict[TEALDataSourceKey_LifecycleType] = eventName;
    
    [mDict addEntriesFromDictionary:[self currentLifecycleData]];
    
    NSDictionary *lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
    
#warning duplicate lifecycle launch events seen.
    
#warning First launch event does not have updated count, but all other events at the same time do

#warning Wakes and sleep events not loading from archive
    
    if (self.eventProcessingBlock) {
        // TODO: Add error handling?
        
        self.eventProcessingBlock(lifecycleData, nil);
    }
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

- (void) incrementEventWithName:(NSString *)eventName {
    
    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]) {
        [[self launchEvents] addEvent];
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        [[self wakeEvents] addEvent];
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        [[self sleepEvents] addEvent];
    }
    
}

- (void) updateStoreDataForEventWithName:(NSString *)eventName {
    
    NSDictionary *data = nil;
    NSString *key = nil;
    
    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]) {
        data = [[self launchEvents] dataForUserDefaults];
        key = TEALKeyLifecycleLaunchEvents;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        data = [[self wakeEvents] dataForUserDefaults];
        key = TEALKeyLifecycleWakeEvents;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        data = [[self sleepEvents] dataForUserDefaults];
        key = TEALKeyLifecycleSleepEvents;
        
    }
    
    if (!eventName ||
        !data){
        return;
    }
    
    [self.store saveData:data forKey:eventName];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ with instanceID: %@ launched:\n %@ wakes:\n%@ sleeps:\n%@",
            NSStringFromClass([self class]),
            self.instanceID,
            [self launchEvents],
            [self wakeEvents],
            [self sleepEvents]];
}

@end
