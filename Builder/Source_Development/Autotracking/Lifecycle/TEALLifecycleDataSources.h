//
//  TEALDataSourcesLifecycle.h
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALLifecycleDataSources : NSException


+ (NSNumber *) dayOfWeekLocal;

+ (NSNumber *) daysSinceDate:(NSDate *)date;

+ (NSString *) hourOfDayLocal;

+ (double) secondsAppHasBeenAwakeToNowFrom:(NSDate*)date;

+ (NSDate *) earlierDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate;

+ (NSDate *) laterDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate;

+ (NSString *) timestampISOFromDate:(NSDate*)date;

+ (NSString *) timestampAsMMDDYYYYFromDate:(NSDate*)timestamp;

+ (BOOL) wasYesterdayDate:(NSDate *) date;

+ (BOOL) wasLastMonthDate:(NSDate *) date;


@end
