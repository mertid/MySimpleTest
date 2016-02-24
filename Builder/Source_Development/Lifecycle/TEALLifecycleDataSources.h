//
//  TEALLifecycleDataSources.h
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALLifecycleDataSources : NSObject

+ (BOOL) isFirstWakeTodayForDate:(NSDate* _Nonnull)date
                       priorDate:(NSDate* _Nullable)earlierDate;

+ (BOOL) isFirstWakeOfMonthForDate:(NSDate * _Nonnull)date
                         priorDate:(NSDate * _Nullable)earlierDate;

+ (NSString* _Nonnull) dayOfWeekForDate:(NSDate* _Nonnull)date;
+ (NSString* _Nonnull) daysFromDate:(NSDate * _Nonnull)earlierDate
                             toDate:(NSDate * _Nonnull)laterDate;
+ (NSString* _Nonnull) hourOfDayLocalFromDate:(NSDate* _Nonnull)date;
+ (NSString* _Nonnull) isoStringFromDate:(NSDate * _Nonnull)date;
+ (NSString* _Nonnull) mmddyyyyStringFromDate:(NSDate * _Nonnull)date;
+ (NSString* _Nonnull) secondsFrom:(NSDate* _Nullable)earlierDate
                                to:(NSDate* _Nullable)laterDate;

+ (NSDate * _Nullable) dateFromISOString:(NSString * _Nonnull)string;


@end
