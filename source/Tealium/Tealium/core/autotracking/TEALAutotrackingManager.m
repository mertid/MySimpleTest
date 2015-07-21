//
//  TEALAutotrackingManager.m
//  Tealium
//
//  Created by Jason Koo on 7/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALAutotrackingManager.h"
#import "UIApplication+TealiumTracker.h"
#import "UIViewController+TealiumTracker.h"

@interface TEALAutotrackingManager ()

@property (nonatomic) BOOL eventTrackingEnabled;
@property (nonatomic) BOOL viewTrackingEnabled;

@end

@implementation TEALAutotrackingManager

- (void) enableAutotracking {
    
    [self enableEventTracking];
    [self enableViewTracking];
}

- (void) enableEventTracking {
    
    if (!self.eventTrackingEnabled) {
        self.eventTrackingEnabled = YES;
        
        [UIApplication swizzle];
    }
}

- (void) enableViewTracking {
    
    if (!self.viewTrackingEnabled) {
        self.viewTrackingEnabled = YES;
        
        [UIViewController swizzle];
    }
}

@end
