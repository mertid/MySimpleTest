//
//  UIViewController+TealiumTracker.m
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//

#import "UIViewController+Tealium.h"
#import "NSObject+Tealium.h"
#import "NSObject+TealiumAutotracking.h"
#import <objc/runtime.h>
#import "Tealium.h"
//#import "TEALDataSourceConstants.h"
#import "TEALDataSources+Autotracking.h"

@implementation UIViewController (Tealium)

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion{

    Method origMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
    oViewDidAppear = (void *)method_getImplementation(origMethod);
    
    if(!class_addMethod(self,
                        @selector(viewDidAppear:),
                        (IMP)teal_viewDidAppear,
                        method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, (IMP)teal_viewDidAppear);
    }
    
    if (completion) completion(YES, nil);
}

void (*oViewDidAppear)(id, SEL, bool a);

static void teal_viewDidAppear(UIViewController *self, SEL _cmd, bool a) {
    
    if ([self teal_autotrackingEnabled] &&
        [Tealium sharedInstance].settings.autotrackingViewsEnabled) {

        // Auto captures title
        NSDictionary *autoDataSources = [TEALDataSources autotrackDataSourcesForDispatchType:TEALDispatchTypeView withObject:self];
        
        NSMutableDictionary *dataSources = [NSMutableDictionary dictionaryWithDictionary:autoDataSources];
        
        NSDictionary *ivars = [self teal_autotrackIvarDataSources];
        [dataSources addEntriesFromDictionary:ivars];
        
        NSDictionary *customDataSources = [self teal_dataSources];
        [dataSources addEntriesFromDictionary:customDataSources];
        
        [[Tealium sharedInstance] trackViewWithTitle:nil
                                         dataSources:dataSources];
    }
        oViewDidAppear(self, _cmd, a);
}

@end
