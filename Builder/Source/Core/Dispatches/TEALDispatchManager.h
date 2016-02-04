//
//  TEALDispatchManager.h
//  TealiumUtilities
//
//  Created by George Webster on 1/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDispatch.h"
#import "TEALSystemProtocols.h"

@class TEALDispatchManager;

@protocol TEALDispatchManagerDelegate <NSObject>

// Internal
- (BOOL) dispatchManagerShouldDestroyDispatch:(TEALDispatch * _Nonnull)dispatch;

- (BOOL) dispatchManagerShouldDispatch:(NSError * __autoreleasing *)error;

- (BOOL) dispatchManagerShouldQueueDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManager:(TEALDispatchManager * _Nonnull)dataManager
        requestsDispatch:(TEALDispatch * _Nonnull)dispatch
         completionBlock:(TEALDispatchBlock _Nullable)completionBlock;

- (BOOL) dispatchManagerShouldPurgeDispatch:(TEALDispatch * _Nonnull)dispatch;

- (void) dispatchManagerdDidPurgeDispatch:(TEALDispatch * _Nonnull)dispatch;

@end

@interface TEALDispatchManager : NSObject

+ (instancetype _Nullable) dispatchManagerWithInstanceID:(NSString * _Nonnull) instanceID
                                                delegate:(id<TEALDispatchManagerDelegate> _Nonnull)delegate;

- (instancetype _Nullable) initWithInstanceID:(NSString * _Nonnull)instanceID
                                     delegate:(id<TEALDispatchManagerDelegate> _Nonnull)delegate;

- (void) addDispatch:(TEALDispatch * _Nonnull)dispatch
     completionBlock:(TEALDispatchBlock _Nullable)completionBlock;

- (void) autoAdjustQueueSize:(NSMutableArray* _Nonnull)queue;

- (void) disable;

- (void) enable;

- (BOOL) isEnabled;

- (void) purgeQueuedDispatches;

- (void) runQueuedDispatches;

- (void) updateQueuedCapacity:(NSUInteger)capacity;

- (NSArray * _Nonnull) queuedDispatches;


@end
