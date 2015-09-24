//
//  TEALLifecycleEvents.m
//  Tealium
//
//  Created by Jason Koo on 9/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleEvents.h"
#import "TEALApplicationDataSources.h"

@interface TEALLifecycleEvents()

/*
 * @{appVersion:arrayOfTimestampsAsNSNumbersOfDoubles}
 */
@property (nonatomic, strong) NSDictionary *privateEvents;

@end

@implementation TEALLifecycleEvents

#pragma mark - PUBLIC

- (void) addEvent {
    
    NSString *key = [TEALApplicationDataSources appVersion];
    
    NSArray *versionEvents = self.privateEvents[key];
    
    NSMutableDictionary *newEvents = [NSMutableDictionary dictionaryWithDictionary:self.privateEvents];
    
    NSMutableArray *newVersionEvents = [NSMutableArray arrayWithArray:versionEvents];
    
    @synchronized(self) {
        
        double now = [[NSDate date] timeIntervalSince1970];
        
        [newVersionEvents addObject:@(now)];
        
        newEvents[key] = [NSArray arrayWithArray:newVersionEvents];
        
        self.privateEvents = [NSDictionary dictionaryWithDictionary:newEvents];
    }
    
}

- (void) setEvents:(NSDictionary *)newEvents {

    @synchronized(self) {
        
        self.privateEvents = [newEvents copy];
        
    }

    
}

- (NSDictionary *) allEvents {
    
    return [self.privateEvents copy];
    
}

#pragma mark - PRIVATE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) copyWithZone:(NSZone *)zone {
    TEALLifecycleEvents *newEvents = [[self class] allocWithZone:zone];
    
    newEvents->_privateEvents = [_privateEvents copyWithZone:zone];
    
    return newEvents;
    
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        _privateEvents = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"allEvents"];
        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.privateEvents forKey:@"allEvents"];
    
}


- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ events:%@>",
            NSStringFromClass([self class]),
            [self allEvents]
            ];
}
@end
