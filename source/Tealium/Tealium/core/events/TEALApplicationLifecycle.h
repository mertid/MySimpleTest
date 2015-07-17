//
//  TEALApplicationLifecycle.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALBlocks.h"

@interface TEALApplicationLifecycle : NSObject

- (void) enableWithEventProcessingBlock:(TEALDictionaryCompletionBlock)block;
- (void) disable;

@end
