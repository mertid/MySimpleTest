//
//  TEALDispatchManager.m
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import "TEALDispatchManager.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALBlocks.h"

static NSString * const Tealium_DispatchQueueKey = @"com.tealium.dispatch_queue";
static NSString * const TEALIODispatchBaseQueueName = @"com.tealium.dispatch.ioqueue";

@interface TEALDispatchManager ()

@property (nonatomic, strong) TEALDataQueue *sentDispatches;
//@property (nonatomic, strong) TEALDataQueue *queuedDispatches;
@property TEALDataQueue *privateQueuedDispatches;
@property (nonatomic, strong) TEALDataQueue *processingQueue;

@property (weak, nonatomic) id<TEALDispatchManagerDelegate> delegate;
@property (weak, nonatomic) id<TEALDispatchManagerConfiguration> configuration;

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation TEALDispatchManager


#pragma mark - PUBLIC CLASS

+ (instancetype) dispatchManagerWithInstanceID:(NSString * _Nonnull) instanceID
                                 Configuration:(id<TEALDispatchManagerConfiguration>)configuration
                                         delegate:(id<TEALDispatchManagerDelegate>)delegate {

    return [[[self class] alloc] initWithInstanceID: instanceID
                                      Configuration:configuration
                                           delegate:delegate];
}

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString * _Nonnull)instanceID
                      Configuration:(id<TEALDispatchManagerConfiguration>)configuration
                              delegate:(id<TEALDispatchManagerDelegate>)delegate {

    self = [self init];
    
    if (self) {
        _configuration      = configuration;
        _delegate           = delegate;
        
        NSString *fullQueueName = [NSString stringWithFormat:@"%@.%@", TEALIODispatchBaseQueueName , instanceID];
        const char * ioQueueName = [fullQueueName UTF8String];
        
        _ioQueue            = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL);
        
//        NSUInteger dispatchCapacity = [_configuration dispatchQueueCapacity];
//        
//        _queuedDispatches = [TEALDataQueue queueWithCapacity:dispatchCapacity];
        
        _sentDispatches = [TEALDataQueue queueWithCapacity:12];
        
        _processingQueue = nil;

    }
    
    return self;
}


- (void) updateQueuedCapacity:(NSUInteger)capacity {

    [self.queuedDispatches updateCapacity:capacity];
}

- (void) disableDispatchQueue {
    
    [self.queuedDispatches dequeueAllObjects];
}

- (void) dequeueAllData {

    [self.queuedDispatches dequeueAllObjects];
    [self.sentDispatches dequeueAllObjects];
    
}

- (NSArray *) queuedDispatchesCopy {
    return [self.queuedDispatches.allQueuedObjects copy];
}

- (NSArray *) sentDispatchesCopy {
    return [self.sentDispatches.allQueuedObjects copy];
}



#pragma mark - enqueue / dequeue dispatches

- (TEALDataQueue *) queuedDispatches{
    
    if (!self.privateQueuedDispatches){
     
        NSUInteger dispatchCapacity = [self.configuration dispatchQueueCapacity];
        
        self.privateQueuedDispatches = [TEALDataQueue queueWithCapacity:dispatchCapacity];
    }
    
    return self.privateQueuedDispatches;
}

- (void) addDispatch:(TEALDispatch *)dispatch completionBlock:(TEALDispatchBlock)completionBlock {
    
    [self purgeStaleDispatches];
    
    [[self queuedDispatches] enqueueObject:dispatch];
    
    BOOL sendNow = [self shouldBeginQueueTraversal];
    
    // Can update to mark was_queued, but never unset in case it was set by client
    //  or other service.
    
    if (sendNow == YES){
        
        dispatch.assignedBlock = completionBlock;
        
        [self runQueuedDispatches];
        
    } else {

        [self.delegate dispatchManagerWillEnqueueDispatch:dispatch];

        [dispatch queue:YES];
        
        [self.delegate dispatchManagerDidEnqueueDispatch:dispatch];
        
        [self archiveDispatchQueue];
        
        if (completionBlock){
            completionBlock(TEALDispatchStatusQueued, dispatch, nil);
        }
        
    }
    
    [self.delegate dispatchManagerDidUpdateDispatchQueues];
}

//- (void) queueDispatch:(TEALDispatch *)dispatch
//  sendImmediatelyAfter:(BOOL)send {
//
//    if (!send){
//        
//        [self.delegate dispatchManagerWillEnqueueDispatch:dispatch];
//        
//        [dispatch queue:YES];
//        
//        [self.queuedDispatches enqueueObject:dispatch];
//        
//        [self.delegate dispatchManagerDidEnqueueDispatch:dispatch];
//        
//        [self archiveDispatchQueue];
//    
//    } else {
//        
//        [dispatch queue:NO];
//        
//        [self.queuedDispatches enqueueObject:dispatch];
//
//    }
//    
//}

- (void) enqueueDispatch:(TEALDispatch *)dispatch completionBlock:(TEALDispatchBlock)completionBlock {
    
    [self.delegate dispatchManagerWillEnqueueDispatch:dispatch];
    
    [dispatch queue:YES];
    
    TEALDispatch *dequeued = [self.queuedDispatches enqueueObject:dispatch];
    
    if (dequeued) {
        [self attemptDispatch:dequeued
              completionBlock:nil];
    }
    
    [self.delegate dispatchManagerDidEnqueueDispatch:dispatch];
    
    [self archiveDispatchQueue];
    
    if (completionBlock) {
        completionBlock(TEALDispatchStatusQueued, dispatch, nil);
    }
}

- (void) requeueDispatch:(TEALDispatch *)dispatch {
    
    [self.queuedDispatches enqueueObjectToFirstPosition:dispatch];
}

- (void) enqueueSentDispatch:(TEALDispatch *)sentDispatch {
    
    [self.sentDispatches enqueueObject:sentDispatch];
    
    [self.delegate dispatchManagerDidUpdateDispatchQueues];
}

- (void) purgeStaleDispatches {
    
    if (![self.queuedDispatches count]) {
        return;
    }
    
    NSMutableArray *purgeData = [NSMutableArray array];
    
    [self.queuedDispatches enumerateQueuedObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[TEALDispatch class]]) {
            
            TEALDispatch *dispatch = (TEALDispatch *)obj;
            
            if ([self.delegate dispatchManagerShouldPurgeDispatch:dispatch]) {
                [purgeData addObject:dispatch];
            }
        }
        
    }];
    
    if ([purgeData count]) {
        // Note: little slower than if implemented with the dispatchManagerShouldPurgeDispatch
        [self.queuedDispatches dequeueObjects:purgeData withBlock:^(id dequeuedObject) {
            [self.delegate dispatchManagerdDidPurgeDispatch:dequeuedObject];
        }];
    }
    
#warning This method does not actually purge anything!
    
}

- (void) runQueuedDispatches {

    if ([self shouldBeginQueueTraversal]) {

        [self beginQueueTraversal];

    }
}

- (BOOL) shouldBeginQueueTraversal {
    
    NSUInteger batchSize = [self.configuration dispatchBatchSize];
    NSUInteger queuedCount = [[self queuedDispatches] count];
    
    if (batchSize > queuedCount) {
        
        return NO;
        
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dispatchManagerShouldDispatch)] &&
        ![self.delegate dispatchManagerShouldDispatch]) {
        
        return NO;
    }
    
    return YES;
}

- (void) beginQueueTraversal {

    NSUInteger queueCount = [self queuedDispatchCount];
    
    if (!self.processingQueue && queueCount) {

        self.processingQueue = [TEALDataQueue queueWithCapacity:queueCount];

    }
    
    __weak TEALDispatchManager *weakSelf = self;
    
    
    [self.queuedDispatches dequeueNumberOfObjects:queueCount
                                        withBlock:^(id dequeuedObject) {
                                            
                                            [weakSelf.processingQueue enqueueObject:dequeuedObject];
                                            
                                        }];
    
    NSUInteger processingCount = [self.processingQueue count];

    if (processingCount > 0){
        [self.delegate dispatchManagerdWillRunDispatchQueueWithCount:processingCount];
    }
    
    [self recursivelyDispatchWithCompletion:^{
        
        [self endQueueTraversal];
        
    }];
        

}

- (void) recursivelyDispatchWithCompletion:(TEALVoidBlock)completion {

    if (!self.processingQueue) {
        if (completion) {
            completion();
        }
        return;
    }
    
    TEALDispatch *dispatch = [self.processingQueue dequeueFirstObject];
    
    if (!dispatch) {
        if (completion) {
            completion();
        }
        return;
    }

    __weak TEALDispatchManager *weakSelf = self;
    
    [self attemptDispatch:dispatch
          completionBlock:^(TEALDispatchStatus status,
                            TEALDispatch * _Nonnull dispatch,
                            NSError * _Nullable error) {
             
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
          
      }];
    
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
        [self.delegate dispatchManagerdDidRunDispatchQueueWithCount:remainingCount];
    }
    self.processingQueue = nil;
}

- (void) attemptDispatch:(TEALDispatch *)dispatch completionBlock:(TEALDispatchBlock)completionBlock {
    
    NSError *error = [self.configuration errorSendingDispatch:dispatch];
    
    if (error){
        TEALDispatchStatus status = TEALDispatchStatusUnknown;
        
        if (error.code == 999){
            status = TEALDispatchStatusShouldDestroy;
        } else if (error.code == 400){
            status = TEALDispatchStatusQueued;
        }
        
        if (completionBlock) {
            completionBlock(status, dispatch, error);
        }
        
        if (dispatch.assignedBlock){
            dispatch.assignedBlock(status, dispatch, error);
        }
        
        return;
    }
    
    [self.delegate dispatchManager:self
                  requestsDispatch:dispatch
                   completionBlock:^(TEALDispatchStatus status, TEALDispatch *returnDispatch, NSError *error) {
                    
                       if (status == TEALDispatchStatusSent &&
                           self.delegate) {
                           
                           [self.delegate dispatchManagerDidSendDispatch:returnDispatch];
                           
                       }
                       
                       // Recursive dispatch block
                       if (completionBlock){
                           completionBlock(status, returnDispatch, error);
                       }
                       
                       // Assigned block
                       if (returnDispatch.assignedBlock){
                           returnDispatch.assignedBlock(status, returnDispatch, error);
                       }

                   }];

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
//        TEAL_logQA(@"%lu archived dispatches have been enqueued.", (unsigned long)dispatchCount);
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
    
//    NSUInteger count = [dataObjects count];
//    if (count) {
//        TEAL_logQA(@"%lu dispatches archived", count);
//    }
}

@end
