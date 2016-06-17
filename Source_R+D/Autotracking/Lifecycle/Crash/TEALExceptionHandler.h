//
//  TEALExceptionHandler.h
//  Tealium
//
//  Created by Jason Koo on 9/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALBlocks.h"

extern void TEALException(NSException *exception);

@interface TEALExceptionHandler : NSObject

+ (void) enableWithProcessingBlock:(TEALDictionaryCompletionBlock)block;
+ (void) disable;

@end
