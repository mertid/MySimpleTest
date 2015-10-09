//
//  TEALDispatchManager.h
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDataQueue.h"
#import "TEALDispatchConstants.h"
#import "TEALSystemProtocols.h"

@class TEALDispatchManager;

@protocol TEALDispatchManagerDelegate <NSObject>

// Internal
- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock;

- (BOOL) dispatchManagerShouldDispatch;

- (void) dispatchManagerDidSendDispatch:(TEALDispatch *)dispatch;

- (void) dispatchManagerWillEnqueueDispatch:(TEALDispatch *)dispatch;

- (void) dispatchManagerDidEnqueueDispatch:(TEALDispatch *)dispatch;

- (void) dispatchManagerDidUpdateDispatchQueues;

- (BOOL) dispatchManagerShouldPurgeDispatch:(TEALDispatch *)dispatch;

- (void) dispatchManagerdDidPurgeDispatch:(TEALDispatch *)dispatch;

- (void) dispatchManagerdWillRunDispatchQueueWithCount:(NSUInteger)count;

- (void) dispatchManagerdDidRunDispatchQueueWithCount:(NSUInteger)count;

@end

@protocol TEALDispatchManagerConfiguration <NSObject>

- (NSUInteger) dispatchBatchSize;

- (NSUInteger) dispatchQueueCapacity;

- (NSError *) errorSendingDispatch:(TEALDispatch *)dispatch;

@end

@interface TEALDispatchManager : NSObject

@property (strong, nonatomic, readonly) TEALDataQueue *sentDispatches;
@property (strong, nonatomic, readonly) TEALDataQueue *queuedDispatches;


+ (instancetype) dispatchManagerWithConfiguration:(id<TEALDispatchManagerConfiguration>)configuration
                                         delegate:(id<TEALDispatchManagerDelegate>)delegate;

- (instancetype) initWithConfiguration:(id<TEALDispatchManagerConfiguration>)configuration
                              delegate:(id<TEALDispatchManagerDelegate>)delegate;

- (void) updateQueuedCapacity:(NSUInteger)capacity;

#pragma mark - enqueue / dequeue dispatches

- (void) addDispatch:(TEALDispatch *)dispatch
     completionBlock:(TEALDispatchBlock)completionBlock;

- (void) runQueuedDispatches;

- (void) disableDispatchQueue;

- (void) dequeueAllData;

- (NSArray *) queuedDispatchesCopy;

- (NSArray *) sentDispatchesCopy;

@end
