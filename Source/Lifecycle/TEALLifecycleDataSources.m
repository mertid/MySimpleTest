//
//  TEALLifecycleDataSources.m
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import "TEALLifecycleDataSources.h"
#import "TEALDataSourceConstants.h"

@implementation TEALLifecycleDataSources

static NSDateFormatter *_hourOfDayFormatter;
static NSDateFormatter *_ISO8601Formatter;
static NSDateFormatter *_mmddyyyyFormatter;

#pragma mark - PUBLIC CLASS METHODS

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
+ (NSDictionary *) incrementedLifetimeValuesForKeys:(NSArray *)keys
                                             amount:(int)number
                                     persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *newDataSources = [NSMutableDictionary dictionary];
    
    for (NSString *key in keys){
        
        int oldNumber = 0;
        
        if (persistentData){
            oldNumber = [persistentData[key] intValue];
        }
        
        int newNumber = oldNumber + number;
        
        newDataSources[key] = @(newNumber);
        
    }
    
    return [NSDictionary dictionaryWithDictionary:newDataSources];
    
}

/**
 *  Returns all lifecycle related data for a given call type. Does NOT set any
 *  lifecycle data, use the updatePersistentDataSourcesForType: method to set.
 *
 *  @param type The TEALLifecycleType of call.
 *  @param date An optional NSDate override for the method call. If not provided,
 *      [NSDate date] will be used at time of call.
 *  @param increment BOOL indicating whether or not the incremented values should
 *      be commited to persistence.
 */
+ (NSDictionary *) newLifecycleDataSourcesForType:(TEALLifecycleType)type
                                             date:(NSDate *)date
                                   persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    if (date == nil){
        date = [NSDate date];
    }
    
    [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSources:date
                                                                 persistentData:persistentData]];
    
    if (type == TEALLifecycleTypeWake ||
        type == TEALLifecycleTypeLaunch){
        
        // Launches are also considered wakes - thank you Adobe
        [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSourcesForWakesAt:date
                                                                               persistentData:dataSources]];
        
        [dataSources addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForWakesAt:date
                                                                                                     persistentData:persistentData]];

        
    }
    
    if (type == TEALLifecycleTypeLaunch){
        
        // Place after wake check as initial launch will change the lifecycle_type
        [dataSources addEntriesFromDictionary:[self newVolatileLifecycleDataSourcesForLaunchesAt:date
                                                                                  persistentData:dataSources]];
        
        [dataSources addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForLaunchesAt:date
                                                                                                        persistentData:persistentData]];

       
        
    }
    
    if (type == TEALLifecycleTypeSleep){
        
        [dataSources addEntriesFromDictionary: [TEALLifecycleDataSources newPersistentLifecycleDataSourcesForSleepsAt:date
                                                                                                       persistentData:persistentData]];
        
        dataSources[TEALDataSourceKey_LifecycleType] = TEALDataSourceValue_LifecycleSleep;
        
    }
    
    return [NSDictionary dictionaryWithDictionary:dataSources];
    
}


+ (NSDictionary *) updatePersistentDataSourcesForType:(TEALLifecycleType)type
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

+ (NSString * _Nonnull) stringLifecycleType:(TEALLifecycleType)type {
    
    if (type == TEALLifecycleTypeLaunch) return @"launch";
    if (type == TEALLifecycleTypeWake) return @"wake";
    if (type == TEALLifecycleTypeSleep) return @"sleep";
    return @"none";
    
}

+ (NSString *)stringFromLifecycleType:(TEALLifecycleType)type {
    
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

+ (BOOL) isFirstWakeTodayForDate:(NSDate* _Nonnull)date
                       priorDate:(NSDate* _Nullable)earlierDate{
    
    // The date needs to be both past the day start time & not be preceeded by
    // an earlier valid date.
    
    NSDate *startOfToday = [self beginningOfDayLocalForDate:date];
    
    if (earlierDate &&
        [earlierDate compare:startOfToday] == NSOrderedDescending){ // earlier date is past day start
        if ([date compare:earlierDate] == NSOrderedSame ||
            [date compare:earlierDate] == NSOrderedAscending){ // if date is earlier than earlierDate
            return YES;
        }
        
    } else if ([date compare: startOfToday] == NSOrderedSame ||
               [date compare: startOfToday] == NSOrderedDescending){ // if date is equal or past the day start line
        return YES;
    }
    
    
    return NO;
}

+ (NSString*) dayOfWeekForDate:(NSDate*)date{
    
    NSNumber *dayOfWeek = @0;
    
    if (date != nil){
        
        // get the current timestamp and parse for day of week as a numeric value
        NSDateComponents *weekdayComponents =
        [[NSCalendar autoupdatingCurrentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
        if (weekdayComponents) {
            int d = (int)[weekdayComponents weekday];
            dayOfWeek = [NSNumber numberWithInt:d];
        }
    }
    
    NSString *dayOfWeekString = [NSString stringWithFormat:@"%@", dayOfWeek];
    
    return dayOfWeekString;
}

+ (NSString* _Nonnull) secondsFrom:(NSDate* _Nullable)earlierDate
                                to:(NSDate* _Nullable)laterDate {
    
    // Whole seconds only
    
    if (!earlierDate) return @"0";
    if (!laterDate) return @"0";
    
    unsigned int unitFlags = NSCalendarUnitSecond;
    
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:earlierDate toDate:laterDate  options:0];
    
    NSNumber *number = [NSNumber numberWithInteger:[components second]];
    NSString *numberString = [NSString stringWithFormat:@"%i", [number intValue]];
    
    return numberString;
}

+ (NSDate *) dateFromISOString:(NSString *)string {
    
    if (!string) return nil;
    
    NSDateFormatter *formatter = [TEALLifecycleDataSources isoDateFormatter];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
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

+ (NSDictionary *) lifecycleFirstLaunchPersistentData:(NSDate *)date {
    
    NSString *versionString = [self bundleVersion];
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
                                     TEALDataSourceKey_LifecycleTotalCrashCount : @"0",
                                     TEALDataSourceKey_LifecycleSleepCount : @"0",
                                     TEALDataSourceKey_LifecycleTotalSleepCount : @"0",
                                     TEALDataSourceKey_LifecyclePriorSecondsAwake : @"0",
                                     TEALDataSourceKey_LifecycleTotalSecondsAwake : @"0"
                                     }];
    
    return [NSDictionary dictionaryWithDictionary:data];
    
}

+ (NSDictionary *) lifecycleNewAppVersionData:(NSDate *)date {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    mDict[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate] = TEALDataSourceValue_True;
    mDict[TEALDataSourceKey_LifecycleWakeCount] = @"1";
    mDict[TEALDataSourceKey_LifecycleLaunchCount] = @"1";
    mDict[TEALDataSourceKey_LifecycleSleepCount] = @"0";
    mDict[TEALDataSourceKey_LifecycleDaysSinceUpdate] = @"0";
    mDict[TEALDataSourceKey_LifecycleUpdateLaunchDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    
    NSString *appVersion = [self bundleVersion];
    
    if (appVersion){
        mDict[TEALDataSourceKey_ApplicationVersion] = appVersion;
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];

}

+ (NSMutableDictionary *) newPersistentLifecycleDataSourcesForLaunchesAt:(NSDate *)date
                                                          persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *incrementArray = [NSMutableArray array];
    
    [incrementArray addObject:TEALDataSourceKey_LifecycleLaunchCount];
    [incrementArray addObject:TEALDataSourceKey_LifecycleTotalLaunchCount];

    
    // Launch & Wake Counts
    [data addEntriesFromDictionary:[self incrementedLifetimeValuesForKeys:incrementArray
                                                                   amount:1
                                                           persistentData:persistentData]];
    
    // Initial Launch Persistent data
    NSString *firstLaunch = persistentData[TEALDataSourceKey_LifecycleFirstLaunchDate];
    if (!firstLaunch){
        
        [data addEntriesFromDictionary:[self lifecycleFirstLaunchPersistentData:date]];
        
    } else if ([self isNewAppVersionDetectedFromPersistentData:persistentData]){
        
        [data addEntriesFromDictionary:[self lifecycleNewAppVersionData:date]];
        
    }
    
    return data;
    
}

+ (NSMutableDictionary *) newPersistentLifecycleDataSourcesForWakesAt:(NSDate *)date
                                                       persistentData:(NSDictionary *)persistentData{
    
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *incrementArray = [NSMutableArray array];

    if([TEALLifecycleDataSources didDetectCrashFromPersistentData:persistentData
                                            currentLifecycleEvent:TEALLifecycleTypeWake]) {
        [incrementArray addObject:TEALDataSourceKey_LifecycleTotalCrashCount];
    }
    
    [incrementArray addObject:TEALDataSourceKey_LifecycleWakeCount];
    [incrementArray addObject:TEALDataSourceKey_LifecycleTotalWakeCount];
    
    NSDictionary *increments = [self incrementedLifetimeValuesForKeys:incrementArray
                                                               amount:1
                                                       persistentData:persistentData];
    
    [data addEntriesFromDictionary:increments];
    
    return data;
    
}


+ (NSMutableDictionary *) newPersistentLifecycleDataSourcesForSleepsAt:(NSDate *)date
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



+ (NSDictionary *) updateLaunchDataSources:(NSDate *)date
                            persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForWakesAt:date
                                                                                          persistentData:persistentData]];
    [data addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForLaunchesAt:date
                                                                                             persistentData:persistentData]];
    
    data[TEALDataSourceKey_LifecycleLastLaunchDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    data[TEALDataSourceKey_LifecycleLastWakeDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    data[TEALDataSourceKey_LifecyclePriorSecondsAwake] = @"0";
    
    return data;
}

+ (NSDictionary *) updateWakeDataSources:(NSDate *)date
                          persistentData:(NSDictionary *)persistentData {
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForWakesAt:date
                                                                                          persistentData:persistentData]];
    
    data[TEALDataSourceKey_LifecycleLastWakeDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    
    return data;
}

+ (NSDictionary *) updateSleepDataSources:(NSDate *)date
                           persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data addEntriesFromDictionary:[TEALLifecycleDataSources newPersistentLifecycleDataSourcesForSleepsAt:date
                                                                                           persistentData:persistentData]];
    
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    
    NSString *secondsAwakeString = [TEALLifecycleDataSources secondsAwakeTo:date
                                                           fromLastWakeDate:lastWakeDate];
    
    int secondsAwake = [secondsAwakeString intValue];
    
    NSDictionary *secondsAwakeIncrements = [TEALLifecycleDataSources incrementedLifetimeValuesForKeys:@[
                                                                                                        @"lifecycle_totalsecondsawake",
                                                                                                        TEALDataSourceKey_LifecyclePriorSecondsAwake
                                                                                                        //                                        TealiumPriorSecondsAwakeTemp
                                                                                                        ]
                                                                                               amount:secondsAwake
                                                                                       persistentData:persistentData];
    
    [data addEntriesFromDictionary:secondsAwakeIncrements];
    
    data[TEALDataSourceKey_LifecycleLastSleepDate] = [TEALLifecycleDataSources isoStringFromDate:date];
    
    return data;
    
}


+ (NSMutableDictionary *) newVolatileLifecycleDataSourcesForLaunchesAt:(NSDate *)date
                                                        persistentData:(NSDictionary *)persistentData{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    data[TEALDataSourceKey_LifecycleType] = [self stringFromLifecycleType:TEALLifecycleTypeLaunch];
    
    // Prior seconds awake
    NSString *priorSecondsAwake = persistentData[TEALDataSourceKey_LifecyclePriorSecondsAwake];
    if (priorSecondsAwake) data[TEALDataSourceKey_LifecyclePriorSecondsAwake] = priorSecondsAwake;
    
    // isFirstLaunch value
    NSString *totalLaunchCount = persistentData[TEALDataSourceKey_LifecycleTotalLaunchCount];
    if (!totalLaunchCount ||
        [totalLaunchCount integerValue] == 1){
        data[TEALDataSourceKey_LifecycleIsFirstLaunch] = TEALDataSourceValue_True;
    }
    
    return data;
}

+ (BOOL)didDetectCrashFromPersistentData:(NSDictionary *)persistentData currentLifecycleEvent:(TEALLifecycleType)type {
  
    TEALLifecycleType lastEvent = [TEALLifecycleDataSources mostRecentDateFromPersistentData:persistentData];
    
    // Only correct lastEvent currentEvent combinations
    if (lastEvent == TEALLifecycleTypeSleep &&
        (type == TEALLifecycleTypeWake || type == TEALLifecycleTypeLaunch)){
        return NO;
    }
    if ((lastEvent == TEALLifecycleTypeWake || lastEvent == TEALLifecycleTypeLaunch) &&
        type == TEALLifecycleTypeSleep){
        return NO;
    }
    
    return YES;
}

+ (TEALLifecycleType) mostRecentDateFromPersistentData:(NSDictionary *)persistentData {

    NSDate *lastLaunch = [TEALLifecycleDataSources dateFromISOString:persistentData[TEALDataSourceKey_LifecycleLastLaunchDate]];
    NSDate *lastSleep = [TEALLifecycleDataSources dateFromISOString:persistentData[TEALDataSourceKey_LifecycleLastSleepDate]];
    NSDate *lastWake = [TEALLifecycleDataSources dateFromISOString:persistentData[TEALDataSourceKey_LifecycleLastWakeDate]];
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:3];
    if (lastLaunch) { [mArray addObject:lastLaunch]; }
    if (lastSleep) { [mArray addObject:lastSleep]; }
    if (lastWake) { [mArray addObject:lastWake]; }
    
    NSDate *mostRecent = [mArray valueForKeyPath:@"@max.self"];
    
    if ([mostRecent isEqualToDate:lastLaunch]) { return TEALLifecycleTypeLaunch; }
    if ([mostRecent isEqualToDate:lastSleep]) { return TEALLifecycleTypeSleep; }
    if ([mostRecent isEqualToDate:lastWake]) { return TEALLifecycleTypeWake; }
    
    return TEALLifecycleTypeNone;
}

+ (NSMutableDictionary *) newVolatileLifecycleDataSourcesForWakesAt:(NSDate *)date
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
    
    //crashDetection
    if ([TEALLifecycleDataSources didDetectCrashFromPersistentData:persistentData
                                             currentLifecycleEvent:TEALLifecycleTypeWake]) {
        
        dataSources[TEALDataSourceKey_LifecycleDidDetectCrash] = TEALDataSourceValue_True;
        
    }
    
    return dataSources;
}

+ (NSMutableDictionary *) newVolatileLifecycleDataSources:(NSDate *)date
                                           persistentData:(NSDictionary *)persistentData {

    // Prep return mutable dictionary for return
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];

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
    if (daysSinceLaunch) dataSources[TEALDataSourceKey_LifecycleDaysSinceLaunch] = daysSinceLaunch;
    
    // Days since last wake
    NSString *lastWakeString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSString *daysSinceLastWake = @"0";
    if (lastWakeString){
        NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeString];
        
        if (lastWakeDate){
            daysSinceLastWake = [TEALLifecycleDataSources daysFromDate:lastWakeDate toDate:date];
        }
    }
    if (daysSinceLastWake) dataSources[TEALDataSourceKey_LifecycleDaysSinceLastWake] = daysSinceLastWake;

    // Days since last update - if update previously occurred
    NSString *updateDateString = persistentData[TEALDataSourceKey_LifecycleUpdateLaunchDate];
    if (updateDateString){
        NSDate *updateDate = [TEALLifecycleDataSources dateFromISOString:updateDateString];
        NSString *daysSinceUpdate = [TEALLifecycleDataSources daysFromDate:updateDate toDate:date];
        if (daysSinceUpdate) dataSources[TEALDataSourceKey_LifecycleDaysSinceUpdate] = daysSinceUpdate;
    }
    
    // Dynamic data based on persistent data
    NSString *lastWakeDateString = persistentData[TEALDataSourceKey_LifecycleLastWakeDate];
    NSDate *lastWakeDate = [TEALLifecycleDataSources dateFromISOString:lastWakeDateString];
    NSString *secondsAwake = [TEALLifecycleDataSources secondsAwakeTo:date
                                                     fromLastWakeDate:lastWakeDate];
    NSString *dayOfWeek = [TEALLifecycleDataSources dayOfWeekForDate:date];
    NSString *hourOfDayLocal = [TEALLifecycleDataSources hourOfDayLocalFromDate:date];
    if (dayOfWeek) dataSources[TEALDataSourceKey_LifecycleDayOfWeek] = dayOfWeek;
    if (hourOfDayLocal) dataSources[TEALDataSourceKey_LifecycleHourOfDayLocal] = hourOfDayLocal;
    if (secondsAwake) dataSources[TEALDataSourceKey_LifecycleSecondsAwake] = secondsAwake;

    return dataSources;
}

#pragma mark - HELPERS

+ (BOOL) isFirstWakeOfMonthForDate:(NSDate * _Nonnull)date
                         priorDate:(NSDate * _Nullable)earlierDate {
    
    NSDate *startOfMonth = [self beginningOfMonthLocalForDate:date];
    
    if (earlierDate &&
        [earlierDate compare:startOfMonth] == NSOrderedDescending){ // earlier date is past day start
        if ([date compare:earlierDate] == NSOrderedSame ||
            [date compare:earlierDate] == NSOrderedAscending){ // if date is earlier than earlierDate
            return YES;
        }
        
    } else if ([date compare: startOfMonth] == NSOrderedDescending){ // if date is past the day start line
        return YES;
    }
    
    return NO;
}


+ (BOOL) isNewAppVersionDetectedFromPersistentData:(NSDictionary *)persistentData {
    
    // Since we didn't put the app version into persistence for 5.0 & 5.0.1, we'll
    // have to do it now so we have something to compare against.
    
    NSString *savedVersion = persistentData[TEALDataSourceKey_ApplicationVersion];
    
    if (!savedVersion){
        return YES;
    }
    
    // This will be nil if running unit tests
    NSString *currentVersion = [self bundleVersion];
    if (currentVersion){
        return ![currentVersion isEqualToString:savedVersion];
    }
    
    // Testing override - Least amount of code update to support version udpate testing -
    // But this seems potentially disasterous
    NSString *isFirstUpdateSinceLaunchOverride = persistentData[TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate];
    if (isFirstUpdateSinceLaunchOverride){
        if ([[isFirstUpdateSinceLaunchOverride lowercaseString] isEqualToString:@"true"]){
            return YES;
        }
    }
    
    return NO;
}

+ (NSString* _Nonnull) daysFromDate:(NSDate * _Nonnull)earlierDate
                             toDate:(NSDate * _Nonnull)laterDate {
    
    unsigned int unitFlags = NSCalendarUnitSecond;
    
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:earlierDate toDate:laterDate  options:0];
    
    NSInteger days = components.second / (60 * 60 *24);
    
    NSString *daysString = [NSString stringWithFormat:@"%li", (long)days];
    
    return daysString;
}

#warning Is this trully the method we should be using?
//+ (NSString* _Nonnull) daysFromDate:(NSDate * _Nonnull)earlierDate
//                             toDate:(NSDate * _Nonnull)laterDate {
//    
//    unsigned int unitFlags = NSCalendarUnitDay;
//    
//    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:earlierDate toDate:laterDate  options:0];
//    
//    NSString *days = [NSString stringWithFormat:@"%li", (long)components.day];
//    
//    return days;
//}

+ (NSString*) hourOfDayLocalFromDate:(NSDate*)date{
    if (!_hourOfDayFormatter){
        _hourOfDayFormatter = [[NSDateFormatter alloc]init];
        _hourOfDayFormatter.dateFormat = @"H";
        [_hourOfDayFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    if (date) return [_hourOfDayFormatter stringFromDate:date];
    return nil;
}

+ (NSString* _Nonnull) isoStringFromDate:(NSDate * _Nonnull)date {
    
    return [[TEALLifecycleDataSources isoDateFormatter] stringFromDate:date];

}

+ (NSString* _Nonnull) mmddyyyyStringFromDate:(NSDate * _Nonnull)date {
    
    return [[TEALLifecycleDataSources mmddyyyyDateFormatter] stringFromDate:date];
    
}

+ (NSString *) secondsAwakeTo:(NSDate *)date
             fromLastWakeDate:(NSDate *)lastWakeDate {
    
    NSString *secondsAwake = @"0";
    
    if (lastWakeDate){
        
        secondsAwake = [TEALLifecycleDataSources secondsFrom:lastWakeDate
                                                          to:date];
    }
    
    return secondsAwake;
}

+ (NSDateComponents* _Nonnull) componentsForDate:(NSDate* _Nonnull)date{
    // Use the user's current calendar and time zone
    
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitSecond;

    NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:date];
    
    return comps;

}

+ (NSDateFormatter *) isoDateFormatter {
    
    if (!_ISO8601Formatter) {
        _ISO8601Formatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_ISO8601Formatter setTimeZone:timeZone];
        [_ISO8601Formatter setTimeStyle:NSDateFormatterFullStyle];
        [_ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    
    return _ISO8601Formatter;
}

+ (NSDateFormatter *) mmddyyyyDateFormatter {
    if (!_mmddyyyyFormatter){
        _mmddyyyyFormatter = [[NSDateFormatter alloc]init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_mmddyyyyFormatter setTimeZone:timeZone];
        [_mmddyyyyFormatter setDateFormat:@"MM/dd/YYYY"];
    }
    return _mmddyyyyFormatter;
}

// Give beginning of Day local in UTC
+ (NSDate* _Nonnull) beginningOfDayLocalForDate:(NSDate* _Nonnull)date{
    
    NSDateComponents *comps = [self componentsForDate:date];
    
    // Set the time components manually
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    // Convert back
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
    
}

// Gives beginning of Month local in UTC
+ (NSDate* _Nonnull) beginningOfMonthLocalForDate:(NSDate* _Nonnull)date{
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *comps = [self componentsForDate:date];
    
    // Set the time components manually
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    // Convert back
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];

}


@end
