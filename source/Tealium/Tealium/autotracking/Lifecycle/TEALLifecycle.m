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
#import "TEALLifecycleDataSources.h"
#import "TEALBlocks.h"
#import "TEALError.h"

@interface TEALLifecycle ()

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL launchAlreadyDetected;
@property (nonatomic) double privateSecondAwake;
@property (nonatomic, strong) NSString *privateInstanceID;
@property (nonatomic, strong) NSDictionary *privateStaticLifecycleData;
@property (nonatomic, strong) NSDictionary *privateLastIncrementedLifecycleData;
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
        [_privateStore loadAllData];
        
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
    
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    
    NSNumber *daysSinceLaunch = [TEALLifecycleDataSources daysSinceDate:[launchEvents firstEvent]];
    NSNumber *daysSinceUpdate = [TEALLifecycleDataSources daysSinceDate:[launchEvents lastUpdate]];
    
    NSNumber *secondsAwake = @((unsigned int)[self secondsAwake]);
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    [mDict addEntriesFromDictionary:[self staticLifecycleData]];
    [mDict addEntriesFromDictionary:self.privateLastIncrementedLifecycleData];

    if (daysSinceLaunch)mDict[TEALDataSourceKey_LifecycleDaysSinceLaunch] = daysSinceLaunch;
    if (daysSinceUpdate)mDict[TEALDataSourceKey_LifecycleDaysSinceUpdate] = daysSinceUpdate;
    if (secondsAwake) mDict[TEALDataSourceKey_LifecycleSecondsAwake] = secondsAwake;

    
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
        NSDictionary *saveData = self.privateStore[TEALDataSourceValue_LifecycleLaunch];
        [self.privateLaunchEvents loadFromUserDefaults:saveData];
        
    }
    return self.privateLaunchEvents;
}

- (TEALLifecycleEvents *) wakeEvents {
    if (!self.privateWakeEvents) {
        self.privateWakeEvents = [[TEALLifecycleEvents alloc] init];
        NSDictionary *saveData = self.privateStore[TEALDataSourceValue_LifecycleWake];
        [self.privateWakeEvents loadFromUserDefaults:saveData];
    }
    return self.privateWakeEvents;
}

- (TEALLifecycleEvents *) sleepEvents {
    if (!self.privateSleepEvents) {
        self.privateSleepEvents = [[TEALLifecycleEvents alloc] init];
        NSDictionary *saveData = self.privateStore[TEALDataSourceValue_LifecycleSleep];
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
            
            [mDict addEntriesFromDictionary:[weakSelf currentLifecycleData]];
            
            // Special Launch time data sources
            if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
                [mDict addEntriesFromDictionary:[weakSelf additionalLaunchDataForEvents:[weakSelf launchEvents]]];
            }
            
            // Special sleep time processing
            
            
            lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
        }
        
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
        key = TEALDataSourceValue_LifecycleLaunch;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        
        events = [self wakeEvents];
        [events addEvent];
        data = [[self wakeEvents] dataForUserDefaults];
        key = TEALDataSourceValue_LifecycleWake;
    
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        
        events = [self sleepEvents];
        [events addEvent];
        data = [[self sleepEvents] dataForUserDefaults];
        key = TEALDataSourceValue_LifecycleSleep;
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
    
    
    __block typeof(self) __weak weakSelf = self;

    [self.store saveData:data forKey:eventName completion:^(BOOL success, NSError *error) {
        
        [weakSelf updateLastIncrementedLifecycleData];

        if (completion) completion(success, error);
        
    }];
    
}

- (void) updateLastIncrementedLifecycleData {
    
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    TEALLifecycleEvents *wakeEvents = [self wakeEvents];
    TEALLifecycleEvents *sleepEvents = [self sleepEvents];
    
    NSNumber *daysSinceLaunch = [TEALLifecycleDataSources daysSinceDate:[launchEvents firstEvent]];
    NSNumber *daysSinceUpdate = [TEALLifecycleDataSources daysSinceDate:[launchEvents lastUpdate]];
    
    NSNumber *currentLaunchCount = @([launchEvents currentCount]);
    NSNumber *currentWakeCount = @([wakeEvents currentCount]);
    NSNumber *currentSleepCount = @([sleepEvents currentCount]);
    NSNumber *launchCount = @([launchEvents totalCount]);
    NSNumber *wakeCount = @([wakeEvents totalCount]);
    NSNumber *sleepCount = @([sleepEvents totalCount]);
    
    NSString *lastLaunchDate = [TEALLifecycleDataSources timestampISOFromDate:[launchEvents lastEvent]];
    NSString *lastWakeDate = [TEALLifecycleDataSources timestampISOFromDate:[wakeEvents lastEvent]];
    NSString *lastSleepDate = [TEALLifecycleDataSources timestampISOFromDate:[sleepEvents lastEvent]];
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    [mDict addEntriesFromDictionary:[self staticLifecycleData]];
    
    if (daysSinceLaunch)mDict[TEALDataSourceKey_LifecycleDaysSinceLaunch] = daysSinceLaunch;
    if (daysSinceUpdate)mDict[TEALDataSourceKey_LifecycleDaysSinceUpdate] = daysSinceUpdate;
    if (currentLaunchCount) mDict[TEALDataSourceKey_LifecycleLaunchCount] = currentLaunchCount;
    if (currentWakeCount) mDict[TEALDataSourceKey_LifecycleWakeCount] = currentWakeCount;
    if (currentSleepCount)mDict[TEALDataSourceKey_LifecycleSleepCount] = currentSleepCount;
    if (launchCount)mDict[TEALDataSourceKey_LifecycleTotalLaunchCount] = launchCount;
    if (wakeCount)  mDict[TEALDataSourceKey_LifecycleTotalWakeCount] = wakeCount;
    if (sleepCount) mDict[TEALDataSourceKey_LifecycleTotalSleepCount] = sleepCount;
    if (lastLaunchDate) mDict[TEALDataSourceKey_LifecycleLastLaunchDate] = lastLaunchDate;
    if (lastWakeDate) mDict[TEALDataSourceKey_LifecycleLastWakeDate] = lastWakeDate;
    if (lastSleepDate)mDict[TEALDataSourceKey_LifecycleLastSleepDate] = lastSleepDate;
    
#warning IMPLEMENT remaining data sources
    
    self.privateLastIncrementedLifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (NSDictionary *) staticLifecycleData {
    
    if (!self.privateStaticLifecycleData){
        TEALLifecycleEvents *launchEvents = [self launchEvents];
        
        NSString *firstLaunch = [TEALLifecycleDataSources timestampISOFromDate:[launchEvents firstEvent]];
        NSString *firstLaunchMMDDYYY = [TEALLifecycleDataSources timestampAsMMDDYYYYFromDate:[launchEvents firstEvent]];
        
        
        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        
        if (firstLaunch) mDict[TEALDataSourceKey_LifecycleFirstLaunchDate] = firstLaunch;
        if (firstLaunchMMDDYYY) mDict[TEALDataSourceKey_LifecycleFirstLaunchDate_MMDDYYYY] = firstLaunchMMDDYYY;
        
        self.privateStaticLifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
    }
    
    return self.privateStaticLifecycleData;
}

- (NSDictionary *) additionalLaunchDataForEvents:(TEALLifecycleEvents *)launchEvents {
    
    BOOL isFirstLaunch = NO;
    if ([launchEvents totalCount] == 1){
        isFirstLaunch = YES;
    }
    
    BOOL isFirstLaunchAfterUpdate = NO;
    if ([launchEvents totalCount] > [launchEvents currentCount] &&
        [launchEvents currentCount] == 1){
        isFirstLaunchAfterUpdate = YES;
    }
    
#warning Prior seconds awake calculation here
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    if (isFirstLaunch) mDict[TEALDataSourceKey_LifecycleIsFirstLaunch] = TEALDataSourceValue_True;
    if (isFirstLaunchAfterUpdate) mDict[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate] = TEALDataSourceValue_True;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

- (double) priorSecondsAwake {
    
#warning IMPLEMENT
    
    return 0.0;
}

- (double) secondsAwake {

    NSDate *lastLaunchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[[self launchEvents] lastEvent] anotherDate:[[self wakeEvents] lastEvent]];
    
    double seconds = [TEALLifecycleDataSources secondsAppHasBeenAwakeToNowFrom:lastLaunchOrWake];
    
    return seconds;
    
}

- (void) updateSecondsAwake {
    
    
#warning IMPLEMENt
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
