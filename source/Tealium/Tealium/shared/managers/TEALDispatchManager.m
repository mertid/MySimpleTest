//
//  TEALDispatchManager.m
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALDispatchManager.h"

#import "TEALDispatch.h"
#import "TEALBlocks.h"
#import "TEALNetworkHelpers.h"

#import "TEALLogger.h"

static NSString * const Tealium_DispatchQueueKey = @"com.tealium.dispatch_queue";
static NSString * const Tealium_IOQueueKey = @"com.tealium.io_queue";

@interface TEALDispatchManager ()

@property (strong, nonatomic) TEALDataQueue *sentDispatches;
@property (strong, nonatomic) TEALDataQueue *queuedDispatches;
@property (strong, nonatomic) TEALDataQueue *processingQueue;

@property (weak, nonatomic) id<TEALDispatchManagerDelegate> delegate;
@property (weak, nonatomic) id<TEALDispatchManagerConfiguration> configuration;

@property (strong, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation TEALDispatchManager

+ (instancetype) dispatchManagerWithConfiguration:(id<TEALDispatchManagerConfiguration>)configuration
                                         delegate:(id<TEALDispatchManagerDelegate>)delegate {

    return [[[self class] alloc] initWithConfiguration:configuration
                                              delegate:delegate];
}

- (instancetype) initWithConfiguration:(id<TEALDispatchManagerConfiguration>)configuration
                              delegate:(id<TEALDispatchManagerDelegate>)delegate {

    self = [self init];
    
    if (self) {
        _configuration      = configuration;
        _delegate           = delegate;
        _ioQueue            = dispatch_queue_create([Tealium_IOQueueKey cStringUsingEncoding:NSUTF8StringEncoding],
                                                    DISPATCH_QUEUE_SERIAL);
        
        NSUInteger dispatchCapacity = [_configuration dispatchQueueCapacity];
        
        _queuedDispatches = [TEALDataQueue queueWithCapacity:dispatchCapacity];
        
        _sentDispatches = [TEALDataQueue queueWithCapacity:12];
        
        _processingQueue = nil;

    }
    
    return self;
}


- (void) updateQueuedCapacity:(NSUInteger)capacity {

    [self runQueuedDispatches];
    [self.queuedDispatches updateCapacity:capacity];
}

- (void) disableDispatchQueue {
    
    [self.queuedDispatches dequeueAllObjects];
}

- (void) dequeueAllData {

    [self.queuedDispatches dequeueAllObjects];
    [self.sentDispatches dequeueAllObjects];
    
}

#pragma mark - enqueue / dequeue dispatches

- (TEALDispatch *) dispatchForEvent:(TEALEventType)eventType withData:(NSDictionary *)userInfo {
    
    NSDictionary *datasources = [self.configuration datasourcesForEventType:eventType];
    
    if (userInfo) {
        
        NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithDictionary:datasources];
        
        [combined addEntriesFromDictionary:userInfo];
        datasources = combined;
    }
    
    TEALDispatch *dispatch = [TEALDispatch new];
    
    dispatch.payload    = datasources;
    dispatch.timestamp  = [[NSDate date] timeIntervalSince1970];
    
    return dispatch;
}

- (void) addDispatchForEvent:(TEALEventType)eventType
                    withData:(NSDictionary *)userInfo
             completionBlock:(TEALDispatchBlock)completionBlock {
    
    TEALDispatch *dispatch = [self dispatchForEvent:eventType withData:userInfo];
    
    TEALDispatchBlock dispatchCompletion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        completionBlock(status, dispatch, error);
    };
    
    [self addDispatch:dispatch
      completionBlock:dispatchCompletion];
}

- (void) addDispatch:(TEALDispatch *)aDispatch completionBlock:(TEALDispatchBlock)completionBlock {

    [self purgeStaleDispatches];
    
    NSUInteger batchSize    = [self.configuration dispatchBatchSize];
    NSUInteger queueCount   = [self.queuedDispatches count];
    
    BOOL shouldBatch = batchSize > 1;
    
    if (!shouldBatch && queueCount == 0) {
        
        __weak TEALDispatchManager *weakSelf = self;
        
        [self attemptDispatch:aDispatch
              completionBlock:^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {

                  if (status != TEALDispatchStatusSent) {
                      [weakSelf enqueueDispatch:dispatch completionBlock:completionBlock];
                  } else if (completionBlock) {
                      completionBlock(status, dispatch, error);
                  }
              }];
    } else {
        
        [self enqueueDispatch:aDispatch completionBlock:completionBlock];
    }

    if ([self.queuedDispatches count] >= batchSize) {
        [self runQueuedDispatches];
    }
    
    [self.delegate didUpdateDispatchQueues];
}

- (void) enqueueDispatch:(TEALDispatch *)dispatch completionBlock:(TEALDispatchBlock)completionBlock {
    
    [self.delegate willEnqueueDispatch:dispatch];
    
    dispatch.queued = YES;
    
    TEALDispatch *dequeued = [self.queuedDispatches enqueueObject:dispatch];
    
    if (dequeued) {
        [self attemptDispatch:dequeued
              completionBlock:nil];
    }
    
    [self.delegate didEnqueueDispatch:dispatch];
    
    if (completionBlock) {
        completionBlock(TEALDispatchStatusQueued, dispatch, nil);
    }
}

- (void) requeueDispatch:(TEALDispatch *)dispatch {
    
    [self.queuedDispatches enqueueObjectToFirstPosition:dispatch];
}

- (void) enqueueSentDispatch:(TEALDispatch *)sentDispatch {
    
    [self.sentDispatches enqueueObject:sentDispatch];
    
    [self.delegate didUpdateDispatchQueues];
}


- (void) purgeStaleDispatches {
    
    if (![self.queuedDispatches count]) {
        return;
    }
    
    NSMutableArray *purgeData = [NSMutableArray array];
    
    [self.queuedDispatches enumerateQueuedObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[TEALDispatch class]]) {
            
            TEALDispatch *dispatch = (TEALDispatch *)obj;
            
            if ([self.delegate shouldRemoveDispatch:dispatch]) {
                [purgeData addObject:dispatch];
            }
        }
        
    }];
    
    if ([purgeData count]) {
        [self.queuedDispatches dequeueObjects:purgeData withBlock:nil];
    }
}

- (void) runQueuedDispatches {
    
    if ([self.delegate shouldAttemptDispatch]) {

        if ([self beginQueueTraversal]) {
            [self recursivelyDispatchWithCompletion:^{
                
                [self endQueueTraversal];
            }];
        }
    }
}

- (BOOL) beginQueueTraversal {

    NSUInteger queueCount = [self queuedDispatchCount];
    if (!self.processingQueue && queueCount) {

        self.processingQueue = [TEALDataQueue queueWithCapacity:queueCount];

        __weak TEALDispatchManager *weakSelf = self;
        
        [self.queuedDispatches dequeueNumberOfObjects:queueCount
                                            withBlock:^(id dequeuedObject) {
                                                
                                                [weakSelf.processingQueue enqueueObject:dequeuedObject];
                                            }];
        
        NSUInteger processingCount = [self.processingQueue count];

        [self.delegate willRunDispatchQueueWithCount:processingCount];
            
        return YES;
    }
    return NO;
}

- (void) recursivelyDispatchWithCompletion:(TEALVoidBlock)completion {

    if (!self.processingQueue) {
        if (completion) {
            completion();
        }
        return;
    }
    
    TEALDispatch *dispatch = [self.processingQueue dequeueObject];
    
    if (!dispatch) {
        if (completion) {
            completion();
        }
        return;
    }

    __weak TEALDispatchManager *weakSelf = self;
    
    TEALDispatchBlock dispatchCompletion = ^(TEALDispatchStatus status, TEALDispatch *resultDispatch, NSError *error) {
        
        if (status == TEALDispatchStatusSent) {
            [weakSelf recursivelyDispatchWithCompletion:completion];
        } else {
            
            if (weakSelf.processingQueue) {
                [weakSelf.processingQueue enqueueObjectToFirstPosition:dispatch];
            }
            if (completion) {
                completion();
            }
        }
    };
    
    [self attemptDispatch:dispatch
          completionBlock:dispatchCompletion];
}

- (void) endQueueTraversal {

    if (self.processingQueue) {
        NSUInteger count = [self.processingQueue count];
        
        if (count) {

            __weak TEALDispatchManager *weakSelf = self;
            
            [self.processingQueue dequeueNumberOfObjects:count
                                               withBlock:^(id dequeuedObject) {
                                                   
                                                   [weakSelf.queuedDispatches enqueueObjectToFirstPosition:dequeuedObject];
                                               }];
        }

        NSUInteger remainingCount = [self.queuedDispatches count];
        [self.delegate didRunDispatchQueueWithCount:remainingCount];
    }
    self.processingQueue = nil;
}

- (void) attemptDispatch:(TEALDispatch *)aDispatch completionBlock:(TEALDispatchBlock)completionBlock {
    
    if ([self.delegate shouldAttemptDispatch]) {

        __weak TEALDispatchManager *weakSelf = self;
        
        [self.delegate dispatchManager:self
                      requestsDispatch:aDispatch
                       completionBlock:^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
                           
                           if (status == TEALDispatchStatusSent) {
                               [weakSelf enqueueSentDispatch:dispatch];
                           }
                           if (completionBlock) {
                               completionBlock(status, dispatch, error);
                           }
                       }];
    } else if (completionBlock) {
        completionBlock(TEALDispatchStatusFailed, aDispatch, nil);
    }
}

- (NSUInteger) queuedDispatchCount {
    
    return [self.queuedDispatches count];
}

- (NSUInteger) sentDispatchCount {
    
    return [self.sentDispatches count];
}



#pragma mark - Archive I/O

- (void) unarchiveDispatchQueue {
    
    NSMutableArray *archivedDispatches = [[NSUserDefaults standardUserDefaults] objectForKey:Tealium_DispatchQueueKey];
    
    if (![archivedDispatches count]) {
        return;
    }
    
    
    for (id obj in archivedDispatches) {
        
        TEALDispatch *dispatch = nil;
        
        if ([obj isKindOfClass:[NSData class]]) {
            
            dispatch = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        }
        
        if (dispatch) {
            [self.queuedDispatches enqueueObject:dispatch];
        }
    }
    
    NSUInteger dispatchCount = [self queuedDispatchCount];
    
    if (dispatchCount) {
        TEAL_LogNormal(@"%lu archived dispatches have been enqueued.", (unsigned long)dispatchCount);
    }
}

- (void) archiveDispatchQueue {
    
    NSArray *queue = [self.queuedDispatches allQueuedObjects];
    
    NSMutableArray *dataObjects = [NSMutableArray arrayWithCapacity:queue.count];
    
    for (id<NSCoding> obj in queue) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [dataObjects addObject:data];
    }
    
    dispatch_async(self.ioQueue, ^{
        
        [[NSUserDefaults standardUserDefaults] setObject:dataObjects
                                                  forKey:Tealium_DispatchQueueKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    
    NSUInteger count = [dataObjects count];
    
    if (count) {
        TEAL_LogNormal(@"%lu dispatches archived", count);
    }
}

@end
