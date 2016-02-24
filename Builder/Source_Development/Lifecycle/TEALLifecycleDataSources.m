//
//  TEALLifecycleDataSources.m
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import "TEALLifecycleDataSources.h"

@implementation TEALLifecycleDataSources

static NSDateFormatter *_hourOfDayFormatter;
static NSDateFormatter *_ISO8601Formatter;
static NSDateFormatter *_mmddyyyyFormatter;

#pragma mark - PUBLIC

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

+ (NSString* _Nonnull) daysFromDate:(NSDate * _Nonnull)earlierDate
                             toDate:(NSDate * _Nonnull)laterDate {
    
    unsigned int unitFlags = NSCalendarUnitDay;
    
    NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:earlierDate toDate:laterDate  options:0];
    
    NSString *days = [NSString stringWithFormat:@"%li", (long)components.day];
    
    return days;
}

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

#pragma mark - INTERNAL

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

+ (NSDate *) dateFromISOString:(NSString *)string {
    
    if (!string) return nil;
    
    NSDateFormatter *formatter = [TEALLifecycleDataSources isoDateFormatter];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
}

@end
