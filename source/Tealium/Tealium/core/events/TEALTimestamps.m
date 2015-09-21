//
//  TEALTimestamps.m
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALTimestamps.h"
#import "TEALDataSourceConstants.h"

@implementation TEALTimestamps

+ (NSDictionary *) timestampDataSourcesForDate:(NSDate *)date {

    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    dataSources[TEALDataSourceKey_Timestamp] = [TEALTimestamps stringOfTimestampAsISOFrom:date];
    dataSources[TEALDataSourceKey_TimestampLocal] = [TEALTimestamps stringOfTimestampAsISOLocalFrom:date];
    dataSources[TEALDataSourceKey_TimestampOffset] = [TEALTimestamps stringOfLocalGMTOffset];
    dataSources[TEALDataSourceKey_TimestampUnix] = [TEALTimestamps stringOfTimestampAsUnixFrom:date];
 
    return dataSources;
}



+ (NSString*) stringOfLocalGMTOffset{
    // return hours offset
    int offset = (int)([[NSTimeZone localTimeZone] secondsFromGMT] / 3600);
    return [NSString stringWithFormat:@"%i", offset];
}

static NSDateFormatter *staticISO8601Local;
+ (NSString*) stringOfTimestampAsISOLocalFrom:(NSDate*)date{
    // modified from original by Radu Poenaru
    staticISO8601Local = nil;
    if (!staticISO8601Local) {
        staticISO8601Local = [[NSDateFormatter alloc] init];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss"];
        [staticISO8601Local setTimeStyle:NSDateFormatterFullStyle];
        [staticISO8601Local setDateFormat:strFormat];
    }
    if (date) return[staticISO8601Local stringFromDate:date];
    return nil;
}

static NSDateFormatter *staticISO8601;
+ (NSString*) stringOfTimestampAsISOFrom:(NSDate*)date{
    // modified from original by Radu Poenaru
    NSDateFormatter *staticISO8601 = nil;
    
    if (!staticISO8601) {
        staticISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [staticISO8601 setTimeZone:timeZone];
        [staticISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [staticISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    if (date) return[staticISO8601 stringFromDate:date];
    return nil;
}

+ (NSString *) stringOfTimestampAsUnixFrom:(NSDate *)date {
    
    NSTimeInterval ti = [date timeIntervalSince1970];
    long tiLong = (long)ti;
    NSString *timestamp = [NSString stringWithFormat:@"%li", tiLong];
    return timestamp;

}

@end
