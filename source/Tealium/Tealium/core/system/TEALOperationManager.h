//
//  TEALOperationManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALBlocks.h"

@interface TEALOperationManager : NSObject

- (instancetype _Nullable) initWithInstanceID:(NSString * _Nonnull)instanceID;

- (void) addOperationWithBlock:(TEALVoidBlock _Nullable)block;

- (void) addIOOperationWithBlock:(TEALVoidBlock _Nullable)ioBlock;

- (dispatch_queue_t _Nullable) underlyingQueue;

@end
