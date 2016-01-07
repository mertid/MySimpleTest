//
//  TEALDataSourcesLifecycle.m
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleDataSources.h"

@implementation TEALLifecycleDataSources


#pragma mark - PUBLIC

+ (NSNumber*) dayOfWeekLocal {
    
    NSNumber *dayOfWeek = @0;
    
    NSDate *date = [NSDate date];
    
    // get the current timestamp and parse for day of week as a numeric value
    NSDateComponents *weekdayComponents =
    [[NSCalendar autoupdatingCurrentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
    if (weekdayComponents) {
        int d = (int)[weekdayComponents weekday];
        dayOfWeek = [NSNumber numberWithInt:d];
    }
    
    return dayOfWeek;
}

+ (NSNumber *) daysSinceDate:(NSDate *)date {
    
    if (date){
        NSDate *now = [NSDate date];
        unsigned int unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth;
        NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:unitFlags fromDate:date toDate:now  options:0];
        NSNumber *number = [NSNumber numberWithInteger:[components day]];
        if (number) return number;
    }
    
    return @0;
    
}

static NSDateFormatter *_HH;

+ (NSString *) hourOfDayLocal{
    
    NSDate *date = [NSDate date];
    if (!_HH){
        _HH = [[NSDateFormatter alloc]init];
        _HH.dateFormat = @"HH";
        [NSTimeZone resetSystemTimeZone];
        [_HH setTimeZone:[NSTimeZone systemTimeZone]];
    }
    if (date) return [_HH stringFromDate:date];
    return nil;
}

+ (double) secondsAppHasBeenAwakeToNowFrom:(NSDate*)date{
    // compare now against most recent wake to determine seconds app has been awake for
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:date];
    if (elapsedTime>0){
        return elapsedTime;
    }
    return -1;
}

static NSDateFormatter *_sISO8601;

+ (NSString*) timestampISOFromDate:(NSDate*)date{
    
    // modified from original by Radu Poenaru
    if (!_sISO8601) {
        _sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_sISO8601 setTimeZone:timeZone];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        [_sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [_sISO8601 setDateFormat:strFormat];
    }
    
    if (date) {
     
        return [_sISO8601 stringFromDate:date];
        
    }
    
    return nil;
}

static NSDateFormatter *_MMDDYYYY;

+ (NSString*) timestampAsMMDDYYYYFromDate:(NSDate*)timestamp{
    if (!_MMDDYYYY){
        _MMDDYYYY = [[NSDateFormatter alloc]init];
        [_MMDDYYYY setDateFormat:@"MM/dd/YYYY"];
    }
    if (timestamp) return [_MMDDYYYY stringFromDate:timestamp];
    return nil;
}

+ (BOOL) wasYesterdayDate:(NSDate *) date {
 
    NSDate *dayThreshold = [self beginningOfDayForDate:[NSDate date]];
    
    NSDate *earlierDate = [self earlierDateBetweenDate:date anotherDate:dayThreshold];
    
    return [earlierDate isEqualToDate:date];
    
}

+ (BOOL) wasLastMonthDate:(NSDate *) date {
    
    NSDate *monthThreshold = [self beginningOfMonthForDate:[NSDate date]];
    
    NSDate *earlierDate = [self earlierDateBetweenDate:date anotherDate:monthThreshold];
    
    return [earlierDate isEqual:date];
}

+ (NSDate *) earlierDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate {
    
    if([date compare: anotherDate] == NSOrderedAscending){ // if first is earlier in time than second
        return date;
    }
    return anotherDate;
}

+ (NSDate *) laterDateBetweenDate:(NSDate *)date anotherDate:(NSDate*)anotherDate {
    
    if (!date &&
        !anotherDate){
        return nil;
    } else if (!date) {
        return anotherDate;
    } else if (!anotherDate){
        return date;
    }
    
    if([date compare: anotherDate] == NSOrderedDescending){
        return date;
    }
    return anotherDate;
}

#pragma mark - PRIVATE


+ (NSDateComponents*) componentCalculationsForDate:(NSDate*)date{
    // Use the user's current calendar and time zone
    if (date){
        NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        if (comps) return comps;
    }
    return nil;
}

+ (NSDate*) beginningOfDayForDate:(NSDate*)date{
    NSDate *beginningOfDay  = nil;
    
    if (date){
        NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        // Set the time components manually
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        
        // Convert back
        beginningOfDay = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:comps];
    }
    return beginningOfDay;
}

+ (NSDate*) beginningOfMonthForDate:(NSDate*)date{
    NSDate *beginningOfMonth = nil;
    
    if (date){
        // Selectively convert the date components (year, month, day) of the input date
        NSDateComponents *dateComps = [[NSCalendar autoupdatingCurrentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        // Set the time components manually
        [dateComps setDay:1];
        [dateComps setHour:0];
        [dateComps setMinute:0];
        [dateComps setSecond:0];
        
        // Convert back
        beginningOfMonth = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:dateComps];
    }
    return beginningOfMonth;
}

@end
