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
#import "TEALEvent.h"

@implementation UIViewController (TealiumTracker)

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

        NSString *viewTitle = [TEALEvent titleForEvent:TEALEventTypeView
                                            withObject:self];

        NSDictionary *autoDataSources = [TEALEvent datasourcesForEvent:TEALEventTypeView
                                                            withObject:self
                                                           autotracked:YES];
        
        NSMutableDictionary *dataSources = [NSMutableDictionary dictionaryWithDictionary:autoDataSources];
        
        NSDictionary *customDataSources = [self teal_dataSources];
        [dataSources addEntriesFromDictionary:customDataSources];
        
        [[Tealium sharedInstance] trackViewWithTitle:viewTitle
                                         dataSources:dataSources];
        
        oViewDidAppear(self, _cmd, a);
    }
}

@end
