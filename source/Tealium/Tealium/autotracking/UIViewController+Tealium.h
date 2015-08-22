//
//  UIViewController+TealiumTracker.h
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//
//  TODO: Rename to UIViewController+TEALAutotracking

#import <UIKit/UIKit.h>
#import "TEALBlocks.h"

@interface UIViewController (Tealium)

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion;

@end
