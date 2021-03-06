//
//  TEALActionQueueManager.m
//  Tealium Mobile Library
//
//  Created by George Webster on 1/9/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALActionQueueManager.h"

#import "TEALDataQueue.h"

@interface TEALActionQueueManager ()

@property (nonatomic, strong) TEALDataQueue *queuedActions;

@end

@implementation TEALActionQueueManager

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        _queuedActions = [TEALDataQueue queueWithCapacity:1000];
    }
    
    return self;
}


- (void) enqueueActionWithBlock:(TEALVoidBlock)block {

    [self.queuedActions enqueueObject:[block copy]];
}

- (void) runQueuedActions {
    
    @synchronized(self) {
        while ([self.queuedActions count]) {
            
            TEALVoidBlock block = [self.queuedActions dequeueFirstObject];
            block();
        }
    }
}

@end
