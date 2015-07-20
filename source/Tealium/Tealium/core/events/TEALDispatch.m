//
//  TEALDispatch.m
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDispatch.h"

@implementation TEALDispatch

+ (TEALDispatch *) dispatchForEvent:(TEALEventType)eventType withPayload:(NSDictionary *)payload {

    TEALDispatch *dispatch = [TEALDispatch new];
 
    dispatch.eventType  = eventType;
    dispatch.payload    = payload;

    dispatch.timestamp = [[NSDate date] timeIntervalSince1970];
    
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
