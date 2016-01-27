//
//  TEALOperationManager.m
//  Tealium Mobile Library
//
//  Created by George Webster on 2/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Serial background queue manager

#import "TEALOperationManager.h"

NSString * const TEALOperationManagerSerialBaseQueueName = @"com.tealium.operations.queue";
NSString * const TEALOperationManagerIOBaseQueueName = @"com.tealium.operations.ioqueue";

@interface TEALOperationManager ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation TEALOperationManager

- (instancetype) initWithInstanceID:(NSString * _Nonnull)instanceID {
    
    self = [super init];
    
    if (self) {
        
        NSString *fullSerialQueueName = [NSString stringWithFormat:@"%@.%@", TEALOperationManagerSerialBaseQueueName , instanceID];
        const char * serialQueueName = [fullSerialQueueName UTF8String];
        _serialQueue = dispatch_queue_create(serialQueueName, DISPATCH_QUEUE_SERIAL);
        
        NSString *fullIOQueueName = [NSString stringWithFormat:@"%@.%@", TEALOperationManagerIOBaseQueueName , instanceID];
        const char * ioQueueName = [fullIOQueueName UTF8String];
        _ioQueue = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_CONCURRENT);
        
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (instancetype) init {
    [NSException raise:@"TEALOperationManager init should not be directly called." format:@""];
    return nil;
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
