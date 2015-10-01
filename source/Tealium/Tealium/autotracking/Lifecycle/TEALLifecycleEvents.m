//
//  TEALLifecycleEvents.m
//  Tealium
//
//  Created by Jason Koo on 9/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleEvents.h"
#import "TEALApplicationDataSources.h"


NSString * const TEALKeyLifecycleCurrentCount = @"currentCount";
NSString * const TEALKeyLifecycleCurrentVersion = @"currentVersion";
NSString * const TEALKeyLifecycleFirstEvent = @"firstEvent";
NSString * const TEALKeyLifecycleLastEvent = @"lastEvent";
NSString * const TEALKeyLifecycleLastUpdate = @"lastUpdate";
NSString * const TEALKeyLifecycleTotalCount = @"totalCount";

@interface TEALLifecycleEvents()

@property (nonatomic) double privateCurrentCount;
@property (nonatomic) double privateCurrentVersion;
@property (nonatomic) double privateFirstEvent;
@property (nonatomic) double privateLastEvent;
@property (nonatomic) double privateLastUpdate;
@property (nonatomic) double privateTotalCount;

@end

@implementation TEALLifecycleEvents

#pragma mark - PUBLIC

- (void) addEvent {
    
    @synchronized(self) {
        
        if ([self newVersionDetected]){
            
            double newVersion = [[TEALApplicationDataSources appVersion] doubleValue];
            
            if (self.privateCurrentVersion) {
                self.privateLastUpdate = newVersion;
                self.privateLastUpdate = [[NSDate date] timeIntervalSince1970];
            }
            
            self.privateCurrentVersion = newVersion;
            self.privateCurrentCount = 0;
        }
        
        [self increment];
    }
    
}

- (void) increment {
    
    if (!self.privateFirstEvent) {
        self.privateFirstEvent = [[NSDate date] timeIntervalSince1970];
    }
    self.privateLastEvent = [[NSDate date] timeIntervalSince1970];
    self.privateCurrentCount++;
    self.privateTotalCount++;
    
}

- (double) currentCount {
    return self.privateCurrentCount;
}

- (double) totalCount {
    return self.privateTotalCount;
}


- (void) setEvents:(NSDictionary *)newEvents {

    @synchronized(self) {
        
        self.privateFirstEvent = [newEvents[TEALKeyLifecycleFirstEvent] doubleValue];
        self.privateLastEvent = [newEvents[TEALKeyLifecycleLastEvent] doubleValue];
        self.privateLastUpdate = [newEvents[TEALKeyLifecycleLastUpdate] doubleValue];
        self.privateCurrentCount = [newEvents[TEALKeyLifecycleCurrentCount] doubleValue];
        self.privateCurrentVersion = [newEvents[TEALKeyLifecycleCurrentVersion] doubleValue];
        self.privateTotalCount = [newEvents[TEALKeyLifecycleTotalCount] doubleValue];
        
    }
    
}

- (NSDictionary *) allEvents {
    
    return @{
             TEALKeyLifecycleCurrentCount:@(self.privateCurrentCount),
             TEALKeyLifecycleCurrentVersion:@(self.privateCurrentVersion),
             TEALKeyLifecycleFirstEvent:@(self.privateFirstEvent),
             TEALKeyLifecycleLastEvent:@(self.privateLastEvent),
             TEALKeyLifecycleLastUpdate:@(self.privateLastUpdate),
             TEALKeyLifecycleTotalCount:@(self.privateTotalCount)
             };
    
}

- (NSDate *) firstEvent {
    
    if (!self.privateFirstEvent ||
        self.privateFirstEvent <= 0) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:self.privateFirstEvent];
    
}

- (NSDate *) lastEvent {
    
    if (!self.privateLastEvent ||
        self.privateLastEvent <= 0) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:self.privateLastEvent];
    
}

- (NSDate *) lastUpdate {
    
    if (!self.privateLastUpdate ||
        self.privateLastUpdate <= 0) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:self.privateLastUpdate];
    
}

- (NSDictionary *) dataForUserDefaults {
    
    return @{
             TEALKeyLifecycleCurrentCount:@(self.privateCurrentCount),
             TEALKeyLifecycleCurrentVersion:@(self.privateCurrentVersion),
             TEALKeyLifecycleFirstEvent:@(self.privateFirstEvent),
             TEALKeyLifecycleLastEvent:@(self.privateLastEvent),
             TEALKeyLifecycleLastUpdate:@(self.privateLastUpdate),
             TEALKeyLifecycleTotalCount:@(self.privateTotalCount)
             };
}

- (void) loadFromUserDefaults:(NSDictionary *)dictionary {
    
    if (!dictionary) return;
    
    self.privateCurrentCount = [dictionary[TEALKeyLifecycleCurrentCount] doubleValue];
    self.privateCurrentVersion = [dictionary[TEALKeyLifecycleCurrentVersion] doubleValue];
    self.privateFirstEvent = [dictionary[TEALKeyLifecycleFirstEvent] doubleValue];
    self.privateLastEvent = [dictionary[TEALKeyLifecycleLastEvent] doubleValue];
    self.privateLastUpdate = [dictionary[TEALKeyLifecycleLastUpdate] doubleValue];
    self.privateTotalCount = [dictionary[TEALKeyLifecycleTotalCount] doubleValue];
    
}

#pragma mark - PRIVATE HELPERS

- (BOOL) newVersionDetected {
    
    double appVersion = [[TEALApplicationDataSources appVersion] doubleValue];
    
    if (appVersion <= self.privateCurrentVersion){
        
#warning Could we go backwards in app versions?
        
        return NO;
    }
    
    return YES;
}

#pragma mark - PRIVATE LIFECYCLE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) copyWithZone:(NSZone *)zone {
    
    TEALLifecycleEvents *newEvents = [[self class] allocWithZone:zone];
    
    newEvents->_privateFirstEvent = _privateFirstEvent;
    newEvents->_privateLastEvent = _privateLastEvent;
    newEvents->_privateLastUpdate = _privateLastUpdate;
    
    return newEvents;
    
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        _privateFirstEvent = [aDecoder decodeDoubleForKey:TEALKeyLifecycleFirstEvent];
        _privateLastEvent = [aDecoder decodeDoubleForKey:TEALKeyLifecycleLastEvent];
        _privateLastUpdate = [aDecoder decodeDoubleForKey:TEALKeyLifecycleLastUpdate];
        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeDouble:self.privateFirstEvent forKey:TEALKeyLifecycleFirstEvent];
    [aCoder encodeDouble:self.privateLastEvent forKey:TEALKeyLifecycleLastEvent];
    [aCoder encodeDouble:self.privateLastUpdate forKey:TEALKeyLifecycleLastUpdate];
    
}


- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ current count:%f total count:%f firstEvent:%@ lastEvent:%@ lastUpdate:%@>",
            NSStringFromClass([self class]),
            [self currentCount],
            [self totalCount],
            [self firstEvent],
            [self lastEvent],
            [self lastUpdate]
            ];
}
@end
