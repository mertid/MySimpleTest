//
//  TEALDataSourcesLifecycle.h
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALLifecycleDataSources : NSException


+ (NSNumber *) daysSinceDate:(NSDate *)date;

+ (double) secondsAppHasBeenAwakeToNowFrom:(NSDate*)date;

+ (NSDate *) earlierDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate;

+ (NSDate *) laterDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate;

+ (NSString*) timestampISOFromDate:(NSDate*)date;

+ (NSString*) timestampAsMMDDYYYYFromDate:(NSDate*)timestamp;

+ (BOOL) isFirstWakeTodayForDate:(NSDate*)date;

+ (BOOL) isFirstWakeOfMonthForDate:(NSDate*)date;

@end
