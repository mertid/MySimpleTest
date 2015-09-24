//
//  TEALException.m
//  Tealium
//
//  Created by Jason Koo on 9/24/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALExceptionEvents.h"
#import "TEALDataSourceConstants.h"

@interface TEALExceptionEvents()

@property (nonatomic, strong) NSString *exceptionName;
@property (nonatomic, strong) NSString *exceptionReason;
@property (nonatomic, strong) NSString *exceptionTrace;

@end
@implementation TEALExceptionEvents

- (void) loadFromDictionary:(NSDictionary *)dictionary {
    
    if (![dictionary isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    [self setEvents:dictionary];
    
    self.exceptionName = dictionary[TEALDataSourceKey_ExceptionName];
    self.exceptionReason = dictionary[TEALDataSourceKey_ExceptionReason];
    self.exceptionTrace = dictionary[TEALDataSourceKey_ExceptionTrace];

}

- (void) updateLastException:(NSException *)exception {
    
    self.exceptionName = exception.name;
    self.exceptionReason = exception.reason;
    self.exceptionTrace = [NSString stringWithFormat:@"%@", exception.callStackSymbols];
    
}

- (BOOL) hasLastException {
    
    if (self.exceptionTrace) return YES;
    return NO;
    
}

- (NSDictionary *) dataSources {
    
    NSMutableDictionary *exceptionData = [NSMutableDictionary dictionary];
    
    if (self.exceptionName) exceptionData[TEALDataSourceKey_ExceptionName] = self.exceptionName;
    if (self.exceptionReason)exceptionData[TEALDataSourceKey_ExceptionReason] = self.exceptionReason;
    if (self.exceptionTrace) exceptionData[TEALDataSourceKey_ExceptionTrace] = self.exceptionTrace;
    
    [exceptionData addEntriesFromDictionary:[self allEvents]];
    
    NSDictionary *exceptionCallData = [NSDictionary dictionaryWithDictionary:exceptionData];
    
    return exceptionCallData;
    
}

//#pragma mark - PRIVATE
//
- (void) resetLastExceptionInfo {
    
    self.exceptionName = nil;
    self.exceptionReason = nil;
    self.exceptionTrace = nil;
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithDictionary:[self allEvents]];
    
    [events removeObjectForKey:TEALDataSourceKey_ExceptionName];
    [events removeObjectForKey:TEALDataSourceKey_ExceptionReason];
    [events removeObjectForKey:TEALDataSourceKey_ExceptionTrace];
    
    [self setEvents:[NSDictionary dictionaryWithDictionary:events]];
    
}

//- (NSString *) lastExceptionTrace {
//
//    NSArray *stackTrace = self.lastException.callStackSymbols;
//    
//    if (!stackTrace) {
//        return nil;
//    }
//    
//    return [NSString stringWithFormat:@"%@", stackTrace];
//}

//- (id) initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//    
//        _lastException = [aDecoder decodeObjectOfClass:[NSException class] forKey:@"lastException"];
//        
//    }
//    return self;
//}
//
//- (instancetype) copyWithZone:(NSZone *)zone {
//    TEALExceptionEvents *newEvents = [super copyWithZone:zone];
//    
//    newEvents->_lastException = [_lastException copyWithZone:zone];
//    
//    return newEvents;
//    
//}
//
//- (void) encodeWithCoder:(NSCoder *)aCoder {
//    [super encodeWithCoder:aCoder];
//    
//    [aCoder encodeObject:self.lastException forKey:@"lastException"];
//}

@end
