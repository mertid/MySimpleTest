//
//  Tealium+Autotracking.m
//  Tealium
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Autotracking.h"
#import "UIApplication+Tealium.h"
#import "UIViewController+Tealium.h"

@implementation Tealium (Autotracking)

- (void) enableAutotrackingUIEvents {
    
    NSLog(@"%s ", __FUNCTION__);
    [UIApplication swizzle];

}

- (void) enableAutotrackingViews {
    
    NSLog(@"%s ", __FUNCTION__);
    [UIViewController swizzle];
    
}


@end