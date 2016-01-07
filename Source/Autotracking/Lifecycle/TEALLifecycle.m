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

- (void) reset {
    
    [self.store resetData];
    
    self.privateLaunchEvents = nil;
    self.privateWakeEvents = nil;
    self.privateSleepEvents = nil;
    
}

- (void) recordLaunch {
    
    [self processLifecycleEventWithName:TEALDataSourceValue_LifecycleLaunch];
    
}

- (BOOL) isEnabled {
    return self.enabled;
}

#warning Update to use set dates for testing

- (NSDictionary *)currentLifecycleData {
    
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    
    NSNumber *daysSinceLaunch = [TEALLifecycleDataSources daysSinceDate:[launchEvents firstEvent]];
    NSNumber *daysSinceUpdate = [TEALLifecycleDataSources daysSinceDate:[launchEvents lastUpdate]];
    NSNumber *dayOfWeekLocal = [TEALLifecycleDataSources dayOfWeekLocal];
    NSString *hourOfDayLocal = [TEALLifecycleDataSources hourOfDayLocal];
    
    NSNumber *secondsAwake = @((unsigned int)[self secondsAwake]);
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    [mDict addEntriesFromDictionary:[self staticLifecycleData]];
    [mDict addEntriesFromDictionary:self.privateLastIncrementedLifecycleData];

    if (dayOfWeekLocal) mDict[TEALDataSourceKey_LifecycleDayOfWeek] = dayOfWeekLocal;
    if (daysSinceLaunch)mDict[TEALDataSourceKey_LifecycleDaysSinceLaunch] = daysSinceLaunch;
    if (daysSinceUpdate)mDict[TEALDataSourceKey_LifecycleDaysSinceUpdate] = daysSinceUpdate;
    if (secondsAwake) mDict[TEALDataSourceKey_LifecycleSecondsAwake] = secondsAwake;
    if (hourOfDayLocal) mDict[TEALDataSourceKey_LifecycleHourOfDayLocal] = hourOfDayLocal;

    // total seconds awake
    // prior seconds awake
    
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

    [self incrementEventWithName:eventName
                            date:[NSDate date]
                      completion:^(NSDictionary *dataDictionary, NSError *error) {
                          
                          
                          if (weakSelf.eventProcessingBlock) {
                              
                              weakSelf.eventProcessingBlock(dataDictionary, error);
                          }
                          
                      }];
    
//    [self incrementEventWithName:eventName
//                            date:[NSDate date]
//                      completion:^(BOOL success, NSError *error) {
//        
//        NSDictionary *lifecycleData = nil;
//        
//        if (success) {
//            mDict[TEALDataSourceKey_LifecycleType] = eventName;
//            
//            [mDict addEntriesFromDictionary:[weakSelf currentLifecycleData]];
//            
//            // Special event based data sources
//            if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
//                [mDict addEntriesFromDictionary:[weakSelf additionalLaunchOnlyDataForEvents:[weakSelf launchEvents]]];
//                [mDict addEntriesFromDictionary:[weakSelf additionalWakeOrLaunchData]];
//            }
//            
//            if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
//                [mDict addEntriesFromDictionary:[weakSelf additionalWakeOrLaunchData]];
//            }
//            
//            if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
//                [weakSelf updatePriorSecondsAwake];
//            }
//            
//            lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
//        }
//        
//        if (weakSelf.eventProcessingBlock) {
//            
//            weakSelf.eventProcessingBlock(lifecycleData, error);
//        }
//        
//    }];
    

}


- (void) incrementEventWithName:(NSString *)eventName
                           date:(NSDate *)date
                     completion:(TEALDictionaryCompletionBlock)completion{
    
    // Setup
    BOOL success = NO;
    NSError *error = nil;
    NSString *errorReason = nil;
    NSDictionary *data = nil;
    NSString *key = nil;
    TEALLifecycleEvents *events = nil;
    
    
    // Update applicable lifecycle event data
    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]) {
        
        events = [self launchEvents];
        [events addEvent:date];
        data = [[self launchEvents] dataForUserDefaults];
        key = TEALDataSourceValue_LifecycleLaunch;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        
        events = [self wakeEvents];
        [events addEvent:date];
        data = [[self wakeEvents] dataForUserDefaults];
        key = TEALDataSourceValue_LifecycleWake;
        
    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        
        events = [self sleepEvents];
        [events addEvent:date];
        data = [[self sleepEvents] dataForUserDefaults];
        key = TEALDataSourceValue_LifecycleSleep;
    }
    
    if (!events){
        
        errorReason = [NSString stringWithFormat:@"No lifecycle event associated with eventName:%@", eventName];
        
    } else if (!data){
        
        errorReason = [NSString stringWithFormat:@"Unable to retrieve lifecycle data for eventName:%@", eventName];
        
    } else {
        
        success = YES;
        
    }
    
    
    // Bail out if error occurred
    if (!success) {
        if (!errorReason) {
            errorReason = NSLocalizedString(@"Unknown error.", @"");
        }
        
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Could not increment lifecycle data.", @"")
                                  reason:errorReason
                              suggestion:NSLocalizedString(@"Contact Tealium Mobile Engineering - Lifecycle Line 382", @"")];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    // Prep Lifecycle data
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    mDict[TEALDataSourceKey_LifecycleType] = eventName;

    [mDict addEntriesFromDictionary:[self currentLifecycleData]];

    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
        [mDict addEntriesFromDictionary:[self additionalLaunchOnlyDataForEvents:[self launchEvents]]];
        [mDict addEntriesFromDictionary:[self additionalWakeOrLaunchData]];
    }

    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
        [mDict addEntriesFromDictionary:[self additionalWakeOrLaunchData]];
    }

    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
        [self updatePriorSecondsAwake];
    }

    NSDictionary * lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
    
    
    // Save data and return data to callback
    __block typeof(self) __weak weakSelf = self;
    
    [self.store saveData:data forKey:eventName completion:^(BOOL success, NSError *error) {
        
        [weakSelf updateLastIncrementedLifecycleData];
        
        if (completion) completion(lifecycleData, error);
        
    }];
    
}

//- (void) processLifecycleEventWithName:(NSString *)eventName {
//    
//    if(!eventName){
//        return;
//    }
//    
//    __block typeof(self) __weak weakSelf = self;
//    __block NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
//    
//    [self incrementEventWithName:eventName
//                            date:[NSDate date]
//                      completion:^(BOOL success, NSError *error) {
//                          
//                          NSDictionary *lifecycleData = nil;
//                          
//                          if (success) {
//                              mDict[TEALDataSourceKey_LifecycleType] = eventName;
//                              
//                              [mDict addEntriesFromDictionary:[weakSelf currentLifecycleData]];
//                              
//                              // Special event based data sources
//                              if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]){
//                                  [mDict addEntriesFromDictionary:[weakSelf additionalLaunchOnlyDataForEvents:[weakSelf launchEvents]]];
//                                  [mDict addEntriesFromDictionary:[weakSelf additionalWakeOrLaunchData]];
//                              }
//                              
//                              if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
//                                  [mDict addEntriesFromDictionary:[weakSelf additionalWakeOrLaunchData]];
//                              }
//                              
//                              if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
//                                  [weakSelf updatePriorSecondsAwake];
//                              }
//                              
//                              lifecycleData = [NSDictionary dictionaryWithDictionary:mDict];
//                          }
//                          
//                          if (weakSelf.eventProcessingBlock) {
//                              
//                              weakSelf.eventProcessingBlock(lifecycleData, error);
//                          }
//                          
//                      }];
//    
//    
//}
//- (void) incrementEventWithName:(NSString *)eventName
//                           date:(NSDate *)date
//                     completion:(TEALBooleanCompletionBlock)completion{
//    
//    NSDictionary *data = nil;
//    NSString *key = nil;
//    TEALLifecycleEvents *events = nil;
//    
//    if ([eventName isEqualToString:TEALDataSourceValue_LifecycleLaunch]) {
//        
//        events = [self launchEvents];
//        [events addEvent:date];
//        data = [[self launchEvents] dataForUserDefaults];
//        key = TEALDataSourceValue_LifecycleLaunch;
//        
//    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleWake]) {
//        
//        events = [self wakeEvents];
//        [events addEvent:date];
//        data = [[self wakeEvents] dataForUserDefaults];
//        key = TEALDataSourceValue_LifecycleWake;
//    
//    } else if ([eventName isEqualToString:TEALDataSourceValue_LifecycleSleep]) {
//        
//        events = [self sleepEvents];
//        [events addEvent:date];
//        data = [[self sleepEvents] dataForUserDefaults];
//        key = TEALDataSourceValue_LifecycleSleep;
//    }
//    
//    if (!events){
//        
//        NSString *reason = [NSString stringWithFormat:@"No lifecycle event associated with eventName:%@", eventName];
//        NSError *error = [TEALError errorWithCode:400
//                                      description:@"Failed to increment lifecycle event."
//                                           reason:reason
//                                       suggestion:@"Contact Tealium Mobile Engineering - Reference Lifecycle Line 315."];
//        
//        if (completion) completion(NO, error);
//        return;
//    }
//    
//    if (!data){
//        
//        NSString *reason = [NSString stringWithFormat:@"Unable to retrieve lifecycle data for eventName:%@", eventName];
//        NSError *error = [TEALError errorWithCode:400
//                                      description:@"Failed to increment lifecycle event."
//                                           reason:reason
//                                       suggestion:@"Contact Tealium Mobile Engineering - Reference Lifecycle Line 327."];
//        
//        if (completion) completion(NO, error);
//        return;
//    }
//    
//    
//    __block typeof(self) __weak weakSelf = self;
//
//    [self.store saveData:data forKey:eventName completion:^(BOOL success, NSError *error) {
//        
//        [weakSelf updateLastIncrementedLifecycleData];
//
//        if (completion) completion(success, error);
//        
//    }];
//    
//}

- (void) updateLastIncrementedLifecycleData {
    
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    TEALLifecycleEvents *wakeEvents = [self wakeEvents];
    TEALLifecycleEvents *sleepEvents = [self sleepEvents];
    
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
    
    if (currentLaunchCount) mDict[TEALDataSourceKey_LifecycleLaunchCount] = currentLaunchCount;
    if (currentWakeCount) mDict[TEALDataSourceKey_LifecycleWakeCount] = currentWakeCount;
    if (currentSleepCount)mDict[TEALDataSourceKey_LifecycleSleepCount] = currentSleepCount;
    if (launchCount)mDict[TEALDataSourceKey_LifecycleTotalLaunchCount] = launchCount;
    if (wakeCount)  mDict[TEALDataSourceKey_LifecycleTotalWakeCount] = wakeCount;
    if (sleepCount) mDict[TEALDataSourceKey_LifecycleTotalSleepCount] = sleepCount;
    if (lastLaunchDate) mDict[TEALDataSourceKey_LifecycleLastLaunchDate] = lastLaunchDate;
    if (lastWakeDate) mDict[TEALDataSourceKey_LifecycleLastWakeDate] = lastWakeDate;
    if (lastSleepDate)mDict[TEALDataSourceKey_LifecycleLastSleepDate] = lastSleepDate;
    
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

- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ with instanceID:%@ \n launches:%@ \n wakes:%@ \n sleeps:%@",
            NSStringFromClass([self class]),
            self.instanceID,
            [self launchEvents],
            [self wakeEvents],
            [self sleepEvents]];
}

#pragma mark - PRIVATE HELPERS

- (NSDictionary *) additionalLaunchOnlyDataForEvents:(TEALLifecycleEvents *)launchEvents {
    
    BOOL isFirstLaunch = NO;
    if ([launchEvents totalCount] == 1){
        isFirstLaunch = YES;
    }
    
    BOOL isFirstLaunchAfterUpdate = NO;
    if ([launchEvents totalCount] > [launchEvents currentCount] &&
        [launchEvents currentCount] == 1){
        isFirstLaunchAfterUpdate = YES;
    }
    
    NSDate *lastUpdate = [launchEvents lastUpdate];
    NSString *lastUpdateString = lastUpdate? [TEALLifecycleDataSources timestampISOFromDate:lastUpdate]:nil;
    
    NSNumber *priorSecondsAwake = @((unsigned int)[self priorSecondsAwake]);
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    if (isFirstLaunch) mDict[TEALDataSourceKey_LifecycleIsFirstLaunch] = TEALDataSourceValue_True;
    if (isFirstLaunchAfterUpdate) mDict[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate] = TEALDataSourceValue_True;
    if (lastUpdate) mDict[TEALDataSourceKey_LifecycleUpdateLaunchDate] = lastUpdateString;
    if (priorSecondsAwake) mDict[TEALDataSourceKey_LifecyclePriorSecondsAwake] = priorSecondsAwake;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

- (NSDictionary *) additionalWakeOrLaunchData {
    
    NSString *isFirstWakeToday = [self isFirstWakeToday]? TEALDataSourceValue_True: nil;
    NSString *isFirstWakeMonth = [self isFirstWakeThisMonth]? TEALDataSourceValue_True: nil;
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    if (isFirstWakeToday){
        mDict[TEALDataSourceKey_LifecycleIsFirstWakeToday] = isFirstWakeToday;
    }
    
    if (isFirstWakeMonth){
        mDict[TEALDataSourceKey_LifecycleIsFirstWakeThisMonth] = isFirstWakeMonth;
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (double) priorSecondsAwake {
    
    double prior = [self.privateStore[TEALDataSourceKey_LifecyclePriorSecondsAwake] doubleValue];
    
    return prior;
}

- (double) secondsAwake {
    
    NSDate *lastLaunchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[[self launchEvents] lastEvent] anotherDate:[[self wakeEvents] lastEvent]];
    
    double seconds = [TEALLifecycleDataSources secondsAppHasBeenAwakeToNowFrom:lastLaunchOrWake];
    
    return seconds;
    
}

- (void) updatePriorSecondsAwake {
    
    double priorSeconds = [self.privateStore[TEALDataSourceKey_LifecyclePriorSecondsAwake] doubleValue];
    double newSecondsToAdd = [self secondsAwake];
    double newSecondsToRecord = priorSeconds + newSecondsToAdd;
    
    self.privateStore[TEALDataSourceKey_LifecyclePriorSecondsAwake] = @(newSecondsToRecord);
    
}

- (BOOL) isFirstWakeToday {
    
    // Find most recent prior wake or launch event
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    TEALLifecycleEvents *wakeEvents = [self wakeEvents];
    
    NSDate *launchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[wakeEvents lastEvent] anotherDate:[launchEvents lastEvent]];
    NSDate *firstLaunchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[wakeEvents firstEvent] anotherDate:[launchEvents firstEvent]];
    
    // First launch or wake period
    if (!launchOrWake ||
        [launchOrWake isEqualToDate:firstLaunchOrWake]){
     
        return YES;
    }
    
    // If prior was yesterday = current event is true, false if vice-versa
    return [TEALLifecycleDataSources wasYesterdayDate:launchOrWake];
    
}

- (BOOL) isFirstWakeThisMonth {
 
    TEALLifecycleEvents *launchEvents = [self launchEvents];
    TEALLifecycleEvents *wakeEvents = [self wakeEvents];
    
    NSDate *launchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[wakeEvents lastEvent] anotherDate:[launchEvents lastEvent]];
    NSDate *firstLaunchOrWake = [TEALLifecycleDataSources laterDateBetweenDate:[wakeEvents firstEvent] anotherDate:[launchEvents firstEvent]];
    
    // First wake or launch period
    if (!launchOrWake ||
        [launchOrWake isEqualToDate:firstLaunchOrWake]) {
        
        return YES;
    }
    
    // If prior was month prior = current event is true
    return [TEALLifecycleDataSources wasLastMonthDate:launchOrWake];
    
    
}

@end
