//
//  TEALLifecycleEvents.m
//  Tealium
//
//  Created by Jason Koo on 9/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleEvents.h"

@interface TEALLifecycleEvents()

@property (nonatomic, strong) NSDate *privateFirstEventDate;
@property (nonatomic, strong) NSDate *privateLastEventDate;
@property (nonatomic, strong) NSDate *privateLastUpdateDate;
@property (nonatomic) double privateCurrentCount;
@property (nonatomic) double privateTotalCount;

@end

@implementation TEALLifecycleEvents

#pragma mark - PUBLIC INSTANCE

- (void) incrementCountNow {
    
    self.privateCurrentCount++;
    self.privateTotalCount++;
    
    NSDate *now = [NSDate date];
    self.privateLastEventDate = now;
    if (!self.privateFirstEventDate){
        self.privateFirstEventDate = now;
    }
}

- (void) startNewCountNow {
    
    self.privateCurrentCount = 1;
    self.privateTotalCount++;
    NSDate *now = [NSDate date];
    self.privateLastEventDate = now;
    self.privateLastUpdateDate = now;
}

- (NSDate *) lastEventDate {
    
    return [self.privateLastEventDate copy];
}


- (NSDate *) lastNewCountRecorded {
    
    return [self.privateLastEventDate copy];
}

- (NSNumber *) currentCount {
    
    return @(self.privateCurrentCount);
    
}

- (NSNumber *) totalCount {
    
    return @(self.privateTotalCount);
}

#pragma mark - PRIVATE INSTANCE

- (instancetype) init {
    self = [super init];
    if (self) {
        
        _privateCurrentCount = 0;
        _privateTotalCount = 0;
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        _privateFirstEventDate = [aDecoder decodeObjectForKey:@"firstEventDate"];
        _privateLastEventDate = [aDecoder decodeObjectForKey:@"lastEventDate"];
        _privateLastUpdateDate = [aDecoder decodeObjectForKey:@"lastUpdateDate"];
        _privateCurrentCount = [aDecoder decodeDoubleForKey:@"currentCount"];
        _privateTotalCount = [aDecoder decodeDoubleForKey:@"totalCount"];
        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.privateFirstEventDate forKey:@"firstEventDate"];
    [aCoder encodeObject:self.privateLastEventDate forKey:@"lastEventDate"];
    [aCoder encodeObject:self.privateLastUpdateDate forKey:@"lastUpdateDate"];
    [aCoder encodeDouble:self.privateCurrentCount forKey:@"currentCount"];
    [aCoder encodeDouble:self.privateTotalCount forKey:@"totalCount"];
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%@ lastEventDate:%@ lastAppVersionUpdateDate:%@ currentCount:%@ totalCount:%@>",
            NSStringFromClass([self class]),
            [self lastEventDate],
            [self.privateLastUpdateDate copy],
            [self currentCount],
            [self totalCount]];
}
@end
