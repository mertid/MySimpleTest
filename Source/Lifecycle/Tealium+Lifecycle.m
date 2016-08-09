//
//  Tealium+Lifecycle.m
//  UIKitCatalog
//
//  Created by Jason Koo on 3/1/16.
//  Copyright © 2016 f. All rights reserved.
//

#import "Tealium+Lifecycle.h"
#import "Tealium+PrivateHeader.h"
#import "TEALConfiguration+Lifecycle.h"
#import "TEALDataSourceConstants.h"
#import "TEALSettings+Lifecycle.h"
#import "TEALLifecycleDataSources.h"

@implementation Tealium (Lifecycle)

// For standalone copy ONLY
static BOOL TealiumLifecycleAutotrackingIsEnabled = NO;

#pragma mark - PUBLIC

- (void) launch {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:NO];
    
}

- (void) wake {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeWake
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:NO];
}

- (void) sleep {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeSleep
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:NO];

}

- (void) launchWithDataSources:(NSDictionary *)dataSources {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                            overrideDate:nil
                             dataSources:dataSources
                             autoTracked:NO];
    
}

- (void) wakeWithDataSources:(NSDictionary *)dataSources {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeWake
                            overrideDate:nil
                             dataSources:dataSources
                             autoTracked:NO];
    
}

- (void) sleepWithDataSources:(NSDictionary *)dataSources {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeSleep
                            overrideDate:nil
                             dataSources:dataSources
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

- (void) updateLifecycle {
    
    if (![self.settings libraryShouldDisable] &&
        [self.settings autotrackingLifecycleEnabled]){
        
        [self enableLifecycleAutotracking];
        
    } else {
        [self disableLifecycleAutotracking];
    }
    
}

- (void) executeLifecycleCommandForType:(TEALLifecycleType)type
                           overrideDate:(NSDate *)date
                            dataSources:(NSDictionary *)dataSources
                            autoTracked:(BOOL)autoTracked{
    
//    if (!autoTracked &&
//        TealiumLifecycleAutotrackingIsEnabled) return;
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];

    if (autoTracked){
        NSArray *keys = [dataSources allKeys];
        if (![keys containsObject:TEALDataSourceKey_Autotracked]){
        
            [mDict addEntriesFromDictionary:@{
                            TEALDataSourceKey_Autotracked : TEALDataSourceValue_True
                            }];
        }
    }
    
    [mDict addEntriesFromDictionary:dataSources];
    
    if (!date) date = [NSDate date];
    
    NSDictionary *persistentData = [self persistentDataSourcesCopy];
    
    // Aggregate persistent and volatile event data & trigger track event
    [self trackLifecycleEventForType:type
                                date:date
                      persistentData:persistentData
                         dataSources:mDict];
    
    // Updates persistent data only
    [self persistNewDataSourcesForType:type
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
    
    [lifecycleDataSources addEntriesFromDictionary:[TEALLifecycleDataSources newLifecycleDataSourcesForType:type
                                                                                                       date:date
                                                                                             persistentData:persistentData]];
    
    [lifecycleDataSources addEntriesFromDictionary:dataSources];
    
    NSString *title = [TEALLifecycleDataSources stringLifecycleType:type];
    
    [self trackEventWithTitle:title
                  dataSources:lifecycleDataSources];
    
}

- (void) persistNewDataSourcesForType:(TEALLifecycleType)type
                                 date:(NSDate*)date
                       persistentData:(NSDictionary*)persistentData{
    
    NSDictionary *dataToPersist = [TEALLifecycleDataSources updatePersistentDataSourcesForType:type
                                                                                          date:date
                                                                                persistentData:persistentData];
    
    [self addPersistentDataSources:dataToPersist];
    
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
    
    if (TealiumLifecycleAutotrackingIsEnabled == FALSE){
        
        [self enableLifecycleAutotracking];
        
    } else {
        
        [self disableLifecycleAutotracking];
    }
    
}

- (void) enableLifecycleAutotracking {
    
    if (TealiumLifecycleAutotrackingIsEnabled) {
        return;
    }
    
    [self lifecycleAutotrackingLaunchDetected];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(lifecycleAutotrackingLaunchDetected)
//                                                 name:UIApplicationDidFinishLaunchingNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lifecycleAutotrackingWakeDetected)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lifecycleAutotrackingSleepDetected)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    TealiumLifecycleAutotrackingIsEnabled = YES;
    
    [self.logger logDev:@"Autotracking Lifecycle enabled."];

}

- (void) disableLifecycleAutotracking {
    
    if (!TealiumLifecycleAutotrackingIsEnabled){
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    TealiumLifecycleAutotrackingIsEnabled = NO;
    
    [self.logger logDev:@"Autotracking Lifecycle enabled."];

}

- (void) lifecycleAutotrackingLaunchDetected {

    [self executeLifecycleCommandForType:TEALLifecycleTypeLaunch
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:YES];
    
}

- (void) lifecycleAutotrackingWakeDetected {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeWake
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:YES];
    
    
}

- (void) lifecycleAutotrackingSleepDetected {
    
    [self executeLifecycleCommandForType:TEALLifecycleTypeSleep
                            overrideDate:nil
                             dataSources:nil
                             autoTracked:YES];
    
}

@end
