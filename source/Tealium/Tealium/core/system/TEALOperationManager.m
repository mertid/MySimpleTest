//
//  TEALOperationManager.m
//  Tealium Mobile Library
//
//  Created by George Webster on 2/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Serial background queue manager

#import "TEALOperationManager.h"

@interface TEALOperationManager ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation TEALOperationManager

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        _serialQueue = dispatch_queue_create("com.tealium.serial-queue", DISPATCH_QUEUE_SERIAL);
        _ioQueue = dispatch_queue_create("com.tealium.io-queue", DISPATCH_QUEUE_CONCURRENT);
        
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (void) addOperationWithBlock:(TEALVoidBlock)block {
    
    dispatch_async(self.serialQueue, block);
}

- (dispatch_queue_t) underlyingQueue {

    return self.serialQueue;
}

- (void) addIOOperationWithBlock:(TEALVoidBlock)ioBlock {

    dispatch_async(self.ioQueue, ioBlock);
}

- (void) addOperation:(NSOperation *)operation {
    
    [self.operationQueue addOperation:operation];
}

@end
