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

- (void) addOperationWithBlock:(TEALVoidBlock)block;

- (void) addIOOperationWithBlock:(TEALVoidBlock)ioBlock;

- (dispatch_queue_t) underlyingQueue;

@end
