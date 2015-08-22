//
//  UIViewController+TealiumTracker.m
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//

#import "UIViewController+Tealium.h"
#import "NSObject+Tealium.h"
#import <objc/runtime.h>
#import "Tealium.h"
#import "TEALDatasourceConstants.h"
#import "TEALDataSources+Autotracking.h"

@implementation UIViewController (Tealium)

+ (void) swizzle {
    
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

        // Auto captures title
        NSDictionary *autoDataSources = [TEALDatasources autotrackDataSourcesForDispatchType:TEALDispatchTypeView withObject:self];
        
        NSMutableDictionary *dataSources = [NSMutableDictionary dictionaryWithDictionary:autoDataSources];
        
        NSDictionary *customDataSources = [self teal_dataSources];
        [dataSources addEntriesFromDictionary:customDataSources];
        
        [[Tealium sharedInstance] trackViewWithTitle:nil
                                         dataSources:dataSources];
        
        oViewDidAppear(self, _cmd, a);
    }
}

@end
