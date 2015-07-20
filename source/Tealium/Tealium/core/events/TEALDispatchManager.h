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

- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock;


- (BOOL) shouldAttemptDispatch;


- (void) willEnqueueDispatch:(TEALDispatch *)dispatch;

- (void) didEnqueueDispatch:(TEALDispatch *)dispatch;

- (void) didUpdateDispatchQueues;

- (BOOL) shouldRemoveDispatch:(TEALDispatch *)dispatch;

- (void) willRunDispatchQueueWithCount:(NSUInteger)count;
- (void) didRunDispatchQueueWithCount:(NSUInteger)count;

@end

@protocol TEALDispatchManagerConfiguration <NSObject>

- (NSUInteger) dispatchBatchSize;

- (NSUInteger) dispatchQueueCapacity;

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

- (void) unarchiveDispatchQueue;
- (void) archiveDispatchQueue;

// RECOMMEND: renaming to runDispatchQueue - to match with disableDispatchQueue
- (void) runQueuedDispatches;

// private ?
//- (void) addDispatch:(TEALDispatch *)dispatch completionBlock:(TEALDispatchBlock)completionBlock;

- (void) purgeStaleDispatches;

- (void) disableDispatchQueue;

- (void) dequeueAllData;

- (NSUInteger) queuedDispatchCount;
- (NSUInteger) sentDispatchCount;

@end
