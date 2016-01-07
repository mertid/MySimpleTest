//
//  UIViewController+TEALPerformanceAdditions.m
//  Performance_UICatalog
//
//  Created by George Webster on 7/7/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import "UIViewController+TEALPerformanceAdditions.h"

@implementation UIViewController (TEALPerformanceAdditions)

- (NSString *) teal_titleForDispatch {
    
    NSString *title = self.title;
    
    if (!title || [title isEqualToString:@""]) {
        title = NSStringFromClass([self class]);
    }
    
    return title;
}

@end
