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
#import "Tealium+Autotracking.h"
#import "Tealium+PrivateHeader.h"
#import "TEALDataSources+Autotracking.h"

static BOOL alreadySwizzled;

@implementation UIViewController (Tealium)

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion{
    
    if (alreadySwizzled){
        return;
    }

    alreadySwizzled = true;
        
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

- (void) teal_viewDidAppearCallOnly {
    
    NSArray *validInstances = [Tealium allAutotrackingViewInstances];
    
    [validInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (![obj isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = obj;
        
        NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];

        // General autotrack object data
        NSDictionary *autoDataSources = [self teal_autotrackDataSources];
        [dataSources addEntriesFromDictionary:autoDataSources];
        
        // Lifecycle info
        if (instance.settings.autotrackingLifecycleEnabled) {
            [dataSources addEntriesFromDictionary:[instance currentLifecycleData]];
        }
        
        // iVars
        if (instance.settings.autotrackingIvarsEnabled){
            NSDictionary *ivars = [self teal_autotrackIvarDataSources];
            [dataSources addEntriesFromDictionary:ivars];
        }
        
        // Client data
        NSDictionary *customDataSources = [self teal_dataSources];
        [dataSources addEntriesFromDictionary:customDataSources];
        
        [instance setActiveViewController:self];
        [instance trackViewWithTitle:nil
                         dataSources:dataSources];
        
    }];
}

void (*oViewDidAppear)(id, SEL, bool a);

static void teal_viewDidAppear(UIViewController *self, SEL _cmd, bool a) {

//    NSArray *validInstances = [Tealium allAutotrackingViewInstances];
//    
//    [validInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//        if (![obj isKindOfClass:([Tealium class])]){
//            return;
//        }
//        
//        Tealium *instance = obj;
//        
//        // Auto captures title
//        NSDictionary *autoDataSources = [self teal_autotrackDataSources];
//        
//        NSMutableDictionary *dataSources = [NSMutableDictionary dictionaryWithDictionary:autoDataSources];
//        
//        if (instance.settings.autotrackingIvarsEnabled){
//            NSDictionary *ivars = [self teal_autotrackIvarDataSources];
//            [dataSources addEntriesFromDictionary:ivars];
//        }
//        
//        NSDictionary *customDataSources = [self teal_dataSources];
//        [dataSources addEntriesFromDictionary:customDataSources];
//        
//        [instance setActiveViewController:self];
//        [instance trackViewWithTitle:nil
//                         dataSources:dataSources];
//        
//    }];
    
    [self teal_viewDidAppearCallOnly];
    
    oViewDidAppear(self, _cmd, a);
}

@end
