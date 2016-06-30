//
//  TEALApplicationLifecycle.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALBlocks.h"

@interface TEALLifecycle : NSObject

- (instancetype) initWithInstanceID:(NSString *)instanceID;
- (void) enableWithEventProcessingBlock:(TEALDictionaryCompletionBlock)block;
- (void) disable;
- (void) reEnable;
- (void) reset;
- (void) recordLaunch;
- (BOOL) isEnabled;
- (NSDictionary *) currentLifecycleData;


@end
