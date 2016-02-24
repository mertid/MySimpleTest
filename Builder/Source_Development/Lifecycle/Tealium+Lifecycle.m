//
//  Tealium+Lifecycle.m
//  UIKitCatalog
//
//  Created by Jason Koo on 3/1/16.
//  Copyright © 2016 f. All rights reserved.
//

#import "Tealium+Lifecycle.h"
#import "TEALDataSourceConstants.h"
#import "TEALLifecycleDataSources.h"

@implementation Tealium (Lifecycle)

// For standalone copy ONLY
static BOOL TealiumLifecycleAutotrackingIsEnabled = NO;

NSString * const TealiumPriorSecondsAwakeTemp = @"lifecycle_priorsecondsawake_temp";

#pragma mark - PUBLIC

- (void) launch {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                            overrideDate:nil
                             autoTracked:NO];
    
}

- (void) wake {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeWake
                            overrideDate:nil
                             autoTracked:NO];
}

- (void) sleep {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeSleep
                            overrideDate:nil
                             autoTracked:NO];

}


- (void) incrementLifetimeValuesForKeys:(NSArray *)keys
                                 amount:(int)number{
    
    NSDictionary *newIncrementData =[self incrementedLifetimeValuesForKeys:keys
                                                                    amount:number
                                                            persistentData:[self persistentDataSourcesCopy]];
    
    [self addPersistentDataSources:newIncrementData];
}

- (NSDictionary * _Nonnull) currentLifecycleDataSources:(NSDate *)overrideDate {

    return [self newLifecycleDataSourcesForType:TEALLifecycleTypeNone
                                           date:overrideDate
                                 persistentData:self.persistentDataSourcesCopy];
}

#pragma mark - PRIVATE INSTANCE

- (void) executeLifecycleCommandForType:(TEALLifecycleType)type
                           overrideDate:(NSDate *)date
                            autoTracked:(BOOL)autoTracked{
    
    if (!autoTracked &&
        TealiumLifecycleAutotrackingIsEnabled) return;
    
    NSDictionary *dataSources = nil;
    
    if (autoTracked){
        dataSources = @{
                        TEALDataSourceKey_Autotracked : TEALDataSourceValue_True
                        };
    }
    
    if (!date) date = [NSDate date];
    
    NSDictionary *persistentData = [self persistentDataSourcesCopy];
    
    [self trackLifecycleEventForType:type
                                date:date
                      persistentData:persistentData
                         dataSources:dataSources];
    
    [self updatePersistentDataSourcesForType:type
                                        date:date
                              persistentData:persistentData];
    
}

- (void) trackLifecycleEventForType:(TEALLifecycleType)type
                               date:(NSDate* _Nonnull)date
                     persistentData:(NSDictionary *)persistentData
                        dataSources:(NSDictionary *)dataSources{
    
    if (type == TEALDispatchTypeNone) return;
    
    if (!date) return;
    
    NSMutableDictionary *lifecycleDataSources = [NSMutableDictionary dictionary];
    
    [lifecycleDataSources addEntriesFromDictionary:[self newLifecycleDataSourcesForType:type
                                                                date:date
                                                      persistentData:persistentData]];
    
    [lifecycleDataSources addEntriesFromDictionary:dataSources];
    
    NSString *title = [Tealium stringFromLifecyleType:type];
    
    [self trackEventWithTitle:title
                  dataSources:lifecycleDataSources];
    
}

- (void) resetLifecycleData {
    
    [self removePersistentDataSourcesForKeys:@[
                                               TEALDataSourceKey_LifecycleFirstLaunchDate,
                                               TEALDataSourceKey_LifecycleFirstLaunchDate_MMDDYYYY,
                                               TEALDataSourceKey_LifecycleLastLaunchDate,
                                               TEALDataSourceKey_LifecycleLastSleepDate,
                                               TEALDataSourceKey_LifecycleLastWakeDate,
                                               TEALDataSourceKey_LifecycleLaunchCount,
                                               TEALDataSourceKey_LifecyclePriorSecondsAwake,
                                               TEALDataSourceKey_LifecycleSleepCount,
                                               TEALDataSourceKey_LifecycleTotalLaunchCount,
                                               TEALDataSourceKey_LifecycleTotalWakeCount,
                                               TEALDataSourceKey_LifecycleTotalSleepCount,
                                               TEALDataSourceKey_LifecycleUpdateLaunchDate,
                                               TEALDataSourceKey_LifecycleWakeCount

                                               ]];
}

/**
 *  Get new values for given persistent keys.
 *
 *  @param keys NSArray of NSStrin keys to get new increment values for.
 *  @param number Int value to increment target values by
 *  @param increment BOOL indicating whether the incremented amounts should be
 *      committed.
 *
 *  @return An NSDictionary with the given keys and new values.
 */
- (NSDictionary *) incrementedLifetimeValuesForKeys:(NSArray *)keys
                                             amount:(int)number
                                     persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *newDataSources = [NSMutableDictionary dictionary];
    
    for (NSString *key in keys){
        
        int oldNumber = [persistentData[key] intValue];
        
        int newNumber = oldNumber + number;
        
        newDataSources[key] = @(newNumber);
        
    }
    
    return [NSDictionary dictionaryWithDictionary:newDataSources];
    
}

#pragma mark - PRIVATE INSTANCE DATA SOURCES

/**
 *  Returns all lifecycle related data for a given call type. Does NOT set any
 *  lifecycle data, use the updateLifecycleDataWithDate: method to set.
 *
 *  @param type The TEALLifecycleType of call.
 *  @param date An optional NSDate override for the method call. If not provided,
 *      [NSDate date] will be used at time of call.
 *  @param increment BOOL indicating whether or not the incremented values should
 *      be commited to persistence.
 */
- (NSDictionary *) newLifecycleDataSourcesForType:(TEALLifecycleType)type
                                             date:(NSDate *)date
                                   persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    if (type == TEALLifecycleTypeWake ||
        type == TEALLifecycleTypeLaunch){
        
        // Launches are also considered wakes - thank you Adobe

        [dataSources addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForWakesAt:date
                                                                                 persistentData:persistentData]];
        [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSourcesForWakesAt:date
                                                                               persistentData:persistentData]];
        
    }
    
    if (type == TEALLifecycleTypeLaunch){
        
        // Place after wake check as initial launch will change the lifecycle_type
        
        [dataSources addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForLaunchesAt:date
                                               persistentData:persistentData]];
        [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSourcesForLaunchesAt:date
                                               persistentData:persistentData]];
        
    }
    
    if (type == TEALLifecycleTypeSleep){
        
        [dataSources addEntriesFromDictionary: [self newPersistentLifecycleDataSourcesForSleepsAt:date
                                                                                   persistentData:persistentData]];
        
        dataSources[TEALDataSourceKey_LifecycleType] = TEALDataSourceValue_LifecycleSleep;

    }

    [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSources:date
                                           persistentData:persistentData]];
    
    return [NSDictionary dictionaryWithDictionary:dataSources];
    
}

- (NSMutableDictionary *) newPersistentLifecycleDataSourcesForLaunchesAt:(NSDate *)date
                                                          persistentData:(NSDictionary *)persistentData{
    

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Launch & Wake Counts
    [data addEntriesFromDictionary:[self incrementedLifetimeValuesForKeys:@[
                                        TEALDataSourceKey_LifecycleLaunchCount,
                                        TEALDataSourceKey_LifecycleTotalLaunchCount,
                                        ]
                               amount:1
                       persistentData:persistentData]];
    
    // Initial Launch Persistent data
    NSString *firstLaunch = persistentData[TEALDataSourceKey_LifecycleFirstLaunchDate];
    if (!firstLaunch){
        
        [data addEntriesFromDictionary:[Tealium lifecycleFirstLaunchData:date]];
        
    } else if ([self isNewAppVersionDetectedFromPersistentData:persistentData]){
        
        [data addEntriesFromDictionary:[Tealium lifecycleNewAppVersionData:date]];
        
    }

    
    return data;
    
}

- (NSMutableDictionary *) newVolatileLifecycleDataSourcesForLaunchesAt:(NSDate *)date
                                                        persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    data[TEALDataSourceKey_LifecycleType] = [Tealium stringFromLifecyleType:TEALLifecycleTypeLaunch];
    
    // Prior seconds awake
    NSString *priorSecondsAwake = persistentData[TealiumPriorSecondsAwakeTemp];
    if (priorSecondsAwake) data[TEALDataSourceKey_LifecyclePriorSecondsAwake] = priorSecondsAwake;

    
    return data;
}

- (NSMutableDictionary *) newPersistentLifecycleDataSourcesForWakesAt:(NSDate *)date
                                                       persistentData:(NSDictionary *)persistentData{

    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSDictionary *increments = [self incrementedLifetimeValuesForKeys:@[
                                                                        TEALDataSourceKey_LifecycleWakeCount,
                                                                        TEALDataSourceKey_LifecycleTotalWakeCount
                                                                        ]
                                                               amount:1
                                                       persistentData:persistentData];
    
    [data addEntriesFromDictionary:increments];
    
    return data;
    
}

- (NSMutableDictionary *) newVolatileLifecycleDataSourcesForWakesAt:(NSDate *)date
                                                     persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    
    if ([TEALLifecycleDataSources isFirstWakeTodayForDate:date
                                                priorDate:lastWakeDate]){
        
        dataSources[TEALDataSourceKey_LifecycleIsFirstWakeToday] = TEALDataSourceValue_True;
        
    }
    
    if ([TEALLifecycleDataSources isFirstWakeOfMonthForDate:date
                                                  priorDate:lastWakeDate]){
        
        dataSources[TEALDataSourceKey_LifecycleIsFirstWakeThisMonth] = TEALDataSourceValue_True;
        
    }
    
    dataSources[TEALDataSourceKey_LifecycleType] = TEALDataSourceValue_LifecycleWake;
    
    return dataSources;
}


- (NSMutableDictionary *) newPersistentLifecycleDataSourcesForSleepsAt:(NSDate *)date
                                                        persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Sleep Counts
    NSDictionary *increments = [self incrementedLifetimeValuesForKeys:@[TEALDataSourceKey_LifecycleSleepCount,
                                                                        TEALDataSourceKey_LifecycleTotalSleepCount]
                                                               amount:1
                                persistentData:persistentData];
    
    [data addEntriesFromDictionary:increments];

    
    // Seconds Awake Count
    
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    
    NSString *secondsAwakeString = [self secondsAwakeTo:date
                                       fromLastWakeDate:lastWakeDate];
    
    int secondsAwake = [secondsAwakeString intValue];

    NSDictionary *secondsAwakeIncrements = [self incrementedLifetimeValuesForKeys:@[
                                                                                    @"lifecycle_totalsecondsawake"
                                                                                    ]
                                                                           amount:secondsAwake
                                                                   persistentData:persistentData];
    
    [data addEntriesFromDictionary:secondsAwakeIncrements];
    
    return data;
    
}

- (NSMutableDictionary *) newVolatileLifecycleDataSources:(NSDate *)date
                                           persistentData:(NSDictionary *)persistentData {
    
    // Days since launch
    NSString *firstLaunchDateString = persistentData[TEALDataSourceKey_LifecycleFirstLaunchDate];
    NSString *daysSinceLaunch = @"0";
    
    if (firstLaunchDateString){
        NSDate *firstLaunchDate = [TEALLifecycleDataSources dateFromISOString:firstLaunchDateString];
        if (firstLaunchDate){
            daysSinceLaunch = [TEALLifecycleDataSources daysFromDate:firstLaunchDate
                                                          toDate:date];
        }
    }
    
    // Days since last wake
    NSString *lastWakeString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSString *daysSinceLastWake = @"0";
    if (lastWakeString){
        NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeString];
        
        if (lastWakeDate){
            daysSinceLastWake = [TEALLifecycleDataSources daysFromDate:lastWakeDate toDate:date];
            
        }
    }
    
    
    NSString *dayOfWeek = [TEALLifecycleDataSources dayOfWeekForDate:date];
    NSString *hourOfDayLocal = [TEALLifecycleDataSources hourOfDayLocalFromDate:date];
    
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    NSString *secondsAwake = [self secondsAwakeTo:date
                                 fromLastWakeDate:lastWakeDate];
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    // Safely set all Lifecycle data
    if (dayOfWeek) dataSources[TEALDataSourceKey_LifecycleDayOfWeek] = dayOfWeek;
    if (hourOfDayLocal) dataSources[TEALDataSourceKey_LifecycleHourOfDayLocal] = hourOfDayLocal;
    if (secondsAwake) dataSources[TEALDataSourceKey_LifecycleSecondsAwake] = secondsAwake;

    dataSources[@"lifecycle_dayssincelastwake"] = daysSinceLastWake;
    dataSources[TEALDataSourceKey_LifecycleDaysSinceLaunch] = daysSinceLaunch;
    
    return dataSources;
}

- (NSString *) secondsAwakeTo:(NSDate *)date
             fromLastWakeDate:(NSDate *)lastWakeDate {
    
    NSString *secondsAwake = @"0";
    
    if (lastWakeDate){
        
        secondsAwake = [TEALLifecycleDataSources secondsFrom:lastWakeDate
                                                          to:date];
    }
    
    return secondsAwake;
}

- (BOOL) isNewAppVersionDetectedFromPersistentData:(NSDictionary *)persistentData {
    
    // Since we didn't put the app version into persistence for 5.0 & 5.0.1, we'll
    // have to do it now so we have something to compare against.
    
    NSString *savedVersion = persistentData[TEALDataSourceKey_ApplicationVersion];
    
    if (!savedVersion){
        return YES;
    }
    
    NSString *currentVersion = [Tealium bundleVersion];
    
    return ![currentVersion isEqualToString:savedVersion];
    
}

#pragma mark - PRIVATE INSTANCE UPDATES

- (NSDictionary *) updatePersistentDataSourcesForType:(TEALLifecycleType)type
                                                 date:(NSDate*)date
                                       persistentData:(NSDictionary *)persistentData{
    
    if (type == TEALLifecycleTypeLaunch) {
        return [self updateLaunchDataSources:date
                              persistentData:persistentData];
    }
    
    if (type == TEALLifecycleTypeWake) {
        return [self updateWakeDataSources:date
                            persistentData:persistentData];
    }
    
    if (type == TEALLifecycleTypeSleep){
        return [self updateSleepDataSources:date
                             persistentData:persistentData];
    }
    
    return @{};
}

- (NSDictionary *) updateLaunchDataSources:(NSDate *)date
                            persistentData:(NSDictionary *)persistentData{

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForWakesAt:date
                                                                      persistentData:persistentData]];
    [data addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForLaunchesAt:date
                                                                         persistentData:persistentData]];
    data[TEALDataSourceKey_LifecycleLastLaunchDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    data[TEALDataSourceKey_LifecycleLastWakeDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    data[TealiumPriorSecondsAwakeTemp] = @"0";

    [self addPersistentDataSources:data];

    return data;
}

- (NSDictionary *) updateWakeDataSources:(NSDate *)date
                          persistentData:(NSDictionary *)persistentData {

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForWakesAt:date
                                                                      persistentData:persistentData]];
    
    data[TEALDataSourceKey_LifecycleLastWakeDate] = [TEALLifecycleDataSources isoStringFromDate:date];

    [self addPersistentDataSources:data];
    
    return data;
}

- (NSDictionary *) updateSleepDataSources:(NSDate *)date
                           persistentData:(NSDictionary *)persistentData{

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[self newPersistentLifecycleDataSourcesForSleepsAt:date
                                                                       persistentData:persistentData]];
    
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    
    NSString *secondsAwakeString = [self secondsAwakeTo:date
                                    fromLastWakeDate:lastWakeDate];
    
    int secondsAwake = [secondsAwakeString intValue];
    
    NSDictionary *secondsAwakeIncrements = [self incrementedLifetimeValuesForKeys:@[
                                        @"lifecycle_totalsecondsawake",
                                        TealiumPriorSecondsAwakeTemp
                                        ]
                               amount:secondsAwake
                       persistentData:persistentData];

    [data addEntriesFromDictionary:secondsAwakeIncrements];
    
    data[TEALDataSourceKey_LifecycleLastSleepDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    
    [self addPersistentDataSources:data];
    
    return data;
    
}

#pragma mark - PRIVATE CLASS

// Duplicate code from TEALApplicationDataSource - remove in 5.1

+ (NSString *) bundleVersion {
    NSDictionary *bundle = [[NSBundle mainBundle] infoDictionary];
    
    NSString *version = [bundle objectForKey:@"CFBundleShortVersionString"];
    
    if (version == nil) {
        version = [bundle objectForKey:@"CFBundleVersion"];
    }
    return version;
}

+ (NSString *)stringFromLifecyleType:(TEALLifecycleType)type {
    
    if (type == TEALLifecycleTypeLaunch) return @"launch";
    if (type == TEALLifecycleTypeWake) return @"wake";
    if (type == TEALLifecycleTypeSleep) return @"sleep";
    return @"none";
    
}

+ (TEALLifecycleType)lifecycleTypeFromString:(NSString *)string {
    
    if ([@"launch" isEqualToString:string]) return TEALLifecycleTypeLaunch;
    if ([@"wake" isEqualToString:string]) return TEALLifecycleTypeWake;
    if ([@"sleep" isEqualToString:string]) return TEALLifecycleTypeSleep;
    return TEALLifecycleTypeNone;
  
}

+ (NSDictionary *) lifecycleFirstLaunchData:(NSDate *)date {
    
    NSString *versionString = [Tealium bundleVersion];
    NSString *isoDateString = [TEALLifecycleDataSources isoStringFromDate:date];
    NSString *mmddyyyDateString = [TEALLifecycleDataSources mmddyyyyStringFromDate:date];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    if (isoDateString){
        data[TEALDataSourceKey_LifecycleFirstLaunchDate] = isoDateString;
        data[TEALDataSourceKey_LifecycleLastLaunchDate] = isoDateString;
        data[TEALDataSourceKey_LifecycleLastWakeDate] = isoDateString;
    }
    if (versionString) data[TEALDataSourceKey_ApplicationVersion] = versionString;
    if (mmddyyyDateString) data[TEALDataSourceKey_LifecycleFirstLaunchDate_MMDDYYYY] = mmddyyyDateString;
    
    [data addEntriesFromDictionary:@{
                                    TEALDataSourceKey_LifecycleIsFirstLaunch : TEALDataSourceValue_True,
                                    TEALDataSourceKey_LifecycleSleepCount : @"0",
                                    TEALDataSourceKey_LifecycleTotalSleepCount : @"0",
                                    TEALDataSourceKey_LifecyclePriorSecondsAwake : @"0",
                                    @"lifecycle_totalsecondsawake" : @"0"
                                    }];
    
    return [NSDictionary dictionaryWithDictionary:data];
    
}

+ (NSDictionary *) lifecycleNewAppVersionData:(NSDate *)date {
    
    return @{
             TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate:TEALDataSourceValue_True,
             TEALDataSourceKey_ApplicationVersion:[Tealium bundleVersion]
    };
}

#pragma mark - AUTOTRACKING (TEMP - TO MOVE TO TEALCONFIGURATION)

- (BOOL) lifecycleAutotrackingIsEnabled {
    
    return TealiumLifecycleAutotrackingIsEnabled;
    
}

- (void) setLifecycleAutotrackingIsEnabled:(BOOL)autotracking {
    
    if (TealiumLifecycleAutotrackingIsEnabled == FALSE &&
        autotracking == TRUE){
        
        [self enableLifecycleAutotracking];
        
    }
    
    TealiumLifecycleAutotrackingIsEnabled = autotracking;
    
}

- (void) enableLifecycleAutotracking {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lifecycleAutotrackingLaunchDetected)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lifecycleAutotrackingWakeDetected)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lifecycleAutotrackingSleepDetected)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    
    
}

- (void) disableLifecycleAutotracking {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) lifecycleAutotrackingLaunchDetected {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                            overrideDate:nil
                             autoTracked:YES];
    
}

- (void) lifecycleAutotrackingWakeDetected {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeWake
                            overrideDate:nil
                             autoTracked:YES];
    
    
}

- (void) lifecycleAutotrackingSleepDetected {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeSleep
                            overrideDate:nil
                             autoTracked:YES];
    
}

@end
