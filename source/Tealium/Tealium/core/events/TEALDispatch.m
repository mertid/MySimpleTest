//
//  TEALDispatch.m
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDispatch.h"

NSString * const TEALDispatchTypeLinkStringValue = @"link";
NSString * const TEALDispatchTypeViewStringValue = @"view";

@implementation TEALDispatch

#pragma mark - PUBLIC CLASS METHODS

+ (TEALDispatch *) dispatchForType:(TEALDispatchType)dispatchType withPayload:(NSDictionary *)payload {

    TEALDispatch *dispatch = [TEALDispatch new];
 
    dispatch.dispatchType  = dispatchType;
    dispatch.payload    = payload;

    dispatch.timestamp = [[NSDate date] timeIntervalSince1970];
    
    return dispatch;
}

+ (NSString *) stringFromDispatchType:(TEALDispatchType)dispatchType {
    
    NSString *eventString = nil;
    
    switch (dispatchType) {
        case TEALDispatchTypeEvent:
            eventString = TEALDispatchTypeLinkStringValue;
            break;
        case TEALDispatchTypeView:
            eventString = TEALDispatchTypeViewStringValue;
        default:
            break;
    }
    return eventString;
}

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        _dispatchType  = [aDecoder decodeIntegerForKey:@"dispatchType"];
        _payload    = [aDecoder decodeObjectForKey:@"payload"];
        _timestamp  = [aDecoder decodeDoubleForKey:@"timestamp"];
        _queued     = [aDecoder decodeBoolForKey:@"queued"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeInteger:self.dispatchType forKey:@"dispatchType"];
    [aCoder encodeObject:self.payload forKey:@"payload"];
    [aCoder encodeDouble:self.timestamp forKey:@"timestamp"];
    [aCoder encodeBool:self.queued forKey:@"queued"];
}

- (NSString*) description {
    
    NSString *description = [NSString stringWithFormat:@"\r Dispatch type: %@ \r Dispatch service: %@ \r datasources payload: %@ \r timestamp unix: %f",
                             [TEALDispatch stringFromDispatchType:self.dispatchType],
                             self.dispatchServiceName,
                             self.payload,
                             self.timestamp];
    return description;
}

@end
