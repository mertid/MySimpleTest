//
//  UIViewController+TealiumTracker.m
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//

#import "UIViewController+TealiumTracker.h"
#import "NSObject+TealiumAdditions.h"
#import <objc/runtime.h>
#import "Tealium.h"
#import "TEALDatasources.h"


@implementation UIViewController (TealiumTracker)




+ (void)swizzle {
    
    Method origMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
    oViewDidAppear = (void *)method_getImplementation(origMethod);
    
    if(!class_addMethod(self,
                        @selector(viewDidAppear:),
                        (IMP)teal_viewDidAppear,
                        method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, (IMP)teal_viewDidAppear);
    }
}

void (*oViewDidAppear)(id, SEL, bool a);

static void teal_viewDidAppear(UIViewController *self, SEL _cmd, bool a) {
    
    if ([self teal_autotrackingEnabled]) {
        
        // TODO: replace placeholder with actual objectForData call
        NSDictionary *objectDataSources = @{TEALDatasourceKey_Autotracked:TEALDatasourceValue_True};
        [[Tealium sharedInstance] trackViewWithTitle:nil dataSources:objectDataSources];
        
        oViewDidAppear(self, _cmd, a);
    }
}

@end
