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
    
    NSDictionary *newIncrementData =[TEALLifecycleDataSources incrementedLifetimeValuesForKeys:keys
                                                                    amount:number
                                                            persistentData:[self persistentDataSourcesCopy]];
    
    [self addPersistentDataSources:newIncrementData];
}

- (NSDictionary * _Nonnull) currentLifecycleDataSources:(NSDate *)overrideDate {

    return [TEALLifecycleDataSources newLifecycleDataSourcesForType:TEALLifecycleTypeNone
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
        
    NSDictionary *dataToPersist = [TEALLifecycleDataSources updatePersistentDataSourcesForType:type
                                                                      date:date
                                                            persistentData:persistentData];
    
    [self addPersistentDataSources:dataToPersist];
    
}

- (void) trackLifecycleEventForType:(TEALLifecycleType)type
                               date:(NSDate* _Nonnull)date
                     persistentData:(NSDictionary *)persistentData
                        dataSources:(NSDictionary *)dataSources{
    
    if (type == TEALDispatchTypeNone) return;
    
    if (!date) return;
    
    NSMutableDictionary *lifecycleDataSources = [NSMutableDictionary dictionary];
    
    [lifecycleDataSources addEntriesFromDictionary:[TEALLifecycleDataSources newLifecycleDataSourcesForType:type
                                                                                                       date:date
                                                                                             persistentData:persistentData]];
    
    [lifecycleDataSources addEntriesFromDictionary:dataSources];
    
    NSString *title = [TEALLifecycleDataSources stringFromLifecyleType:type];
    
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
