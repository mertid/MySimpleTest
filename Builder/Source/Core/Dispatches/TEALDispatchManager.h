//
//  TEALDispatchManager.h
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDataQueue.h"
#import "TEALDispatch.h"
#import "TEALSystemProtocols.h"

@class TEALDispatchManager;

@protocol TEALDispatchManagerDelegate <NSObject>

// Internal
- (void) dispatchManager:(TEALDispatchManager * _Nonnull)dataManager
        requestsDispatch:(TEALDispatch * _Nonnull)dispatch
         completionBlock:(TEALDispatchBlock _Nullable)completionBlock;

- (BOOL) dispatchManagerShouldDispatch:(NSError * __autoreleasing _Nullable)error;

- (void) dispatchManagerDidSendDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerWillEnqueueDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerDidEnqueueDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerDidUpdateDispatchQueues;

- (BOOL) dispatchManagerShouldPurgeDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerdDidPurgeDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerdWillRunDispatchQueueWithCount:(NSUInteger)count;

- (void) dispatchManagerdDidRunDispatchQueueWithCount:(NSUInteger)count;

@end

@protocol TEALDispatchManagerConfiguration <NSObject>

- (NSUInteger) dispatchBatchSize;

- (NSUInteger) dispatchQueueCapacity;   // Good only for init time

- (NSError * _Nullable) errorSendingDispatch:(TEALDispatch * _Nonnull)dispatch;

@end

@interface TEALDispatchManager : NSObject

@property (strong, nonatomic, readonly) TEALDataQueue * _Nonnull sentDispatches;
@property (strong, nonatomic, readonly) TEALDataQueue * _Nonnull queuedDispatches;


+ (instancetype _Nullable) dispatchManagerWithInstanceID:(NSString * _Nonnull) instanceID
                                 Configuration:(id<TEALDispatchManagerConfiguration> _Nonnull)configuration
                                      delegate:(id<TEALDispatchManagerDelegate> _Nonnull)delegate;

- (instancetype _Nullable) initWithInstanceID:(NSString * _Nonnull)instanceID
                                Configuration:(id<TEALDispatchManagerConfiguration> _Nonnull)configuration
                                     delegate:(id<TEALDispatchManagerDelegate> _Nonnull)delegate;

- (void) updateQueuedCapacity:(NSUInteger)capacity;

#pragma mark - enqueue / dequeue dispatches

- (void) addDispatch:(TEALDispatch * _Nonnull)dispatch
     completionBlock:(TEALDispatchBlock _Nullable)completionBlock;

- (void) runQueuedDispatches;

- (void) disableDispatchQueue;

- (void) dequeueAllData;

- (NSArray * _Nonnull) queuedDispatchesCopy;

- (NSArray * _Nonnull) sentDispatchesCopy;

@end
