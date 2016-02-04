//
//  UIApplication+TealiumTracker.h
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//
//  BRIEF: Category extension for message tracking
//  TODO: Rename to UIApplication+TEALAutotracking

#import <UIKit/UIKit.h>
#import "TEALBlocks.h"

@interface UIApplication (Tealium)

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion;


@end
