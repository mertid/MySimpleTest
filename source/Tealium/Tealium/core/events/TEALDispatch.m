//
//  TEALDispatch.m
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDispatch.h"
#import "TEALDatasources.h"
#import "NSDate+TealiumAdditions.h"

@implementation TEALDispatch

+ (TEALDispatch *) dispatchForEvent:(TEALEventType)eventType withData:(NSDictionary *)userInfo {

    TEALDispatch *dispatch = [TEALDispatch new];
 
    dispatch.eventType  = eventType;
    dispatch.payload    = userInfo;

    NSDate *now = [NSDate date];
    
    dispatch.timestamp = [now timeIntervalSince1970];
    
    NSMutableDictionary *datasources = nil;
    
    if (userInfo) {
        datasources = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    } else {
        datasources = [NSMutableDictionary new];
    }
    datasources[TEALDatasourceKey_Timestamp] = [now teal_timestampISOStringValue];

    dispatch.payload = [NSDictionary dictionaryWithDictionary:datasources];
    
    return dispatch;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        _eventType  = [aDecoder decodeIntegerForKey:@"eventType"];
        _payload    = [aDecoder decodeObjectForKey:@"payload"];
        _timestamp  = [aDecoder decodeDoubleForKey:@"timestamp"];
        _queued     = [aDecoder decodeBoolForKey:@"queued"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeInteger:self.eventType forKey:@"eventType"];
    [aCoder encodeObject:self.payload forKey:@"payload"];
    [aCoder encodeDouble:self.timestamp forKey:@"timestamp"];
    [aCoder encodeBool:self.queued forKey:@"queued"];
}

@end
