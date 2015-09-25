//
//  TEALDataSourcesLifecycle.m
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleDataSources.h"

@implementation TEALLifecycleDataSources

+ (NSNumber*) localDayOfWeek {
    
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

@end
