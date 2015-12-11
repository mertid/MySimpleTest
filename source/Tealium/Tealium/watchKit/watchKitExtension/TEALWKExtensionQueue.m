//
//  TEALWKExtensionQueue.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/9/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtensionQueue.h"

NSString * const TEALWKSuiteName = @"com.tealium.watchkit";

@interface TEALWKExtensionQueue()

@property (nonatomic) NSArray *privateQueue;

@end

@implementation TEALWKExtensionQueue

- (instancetype) init {
    self = [super init];
    if (self){
        _privateQueue = [NSArray array];
    }
    
    return self;
}

- (void) queueCallPayload:(NSDictionary *)payload  {
    
    @synchronized(self) {
                
        NSMutableArray *mArray = [NSMutableArray array];
        
        if (
            [self.privateQueue count] > 0){
            [mArray addObjectsFromArray:self.privateQueue];
        }
        
        [mArray addObject:payload];
        
        self.privateQueue = [NSArray arrayWithArray:mArray];
        
    }
    
}

- (NSArray *) currentQueue {
    
    return [self.privateQueue copy];
    
}

- (void) removeFirstCall {

    @synchronized(self) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        
        if ([self.privateQueue count] > 0){
            [mArray addObjectsFromArray:self.privateQueue];
            
            [mArray removeObjectAtIndex:0];
        }
        
        self.privateQueue = [NSArray arrayWithArray:mArray];
    }
}

- (void) purgeQueue {

    @synchronized(self) {
        
        self.privateQueue = nil;
        
        self.privateQueue = [NSArray array];
        
    }
}

@end
