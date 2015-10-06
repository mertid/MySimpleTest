//
//  NSObject+TealiumAutotracking.m
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSObject+TealiumAutotracking.h"
#import "TEALDataSources+Autotracking.h"
#import <objc/runtime.h>

#define  TEALKeyAutotrackingEnabled @"com.tealium.autotracking.enableautotracking.%@"

static CFStringRef  const TEALKVOAutotrackIvars = CFSTR("TEALIUM_KVO_AUTOTRACKING_IVARS");

@implementation NSObject (TealiumAutotracking)

#pragma mark - PUBLIC INSTANCE

- (void) teal_setAutotrackingEnabled:(BOOL)enabled forInstance:(NSString *)instanceID {
    
    if (!instanceID){
        return;
    }
    
    NSString *nsKey = [NSString stringWithFormat:TEALKeyAutotrackingEnabled, instanceID];
    CFStringRef key = (__bridge CFStringRef)(nsKey);
    
    NSNumber *enableOnNumber = @(enabled);
    
    objc_setAssociatedObject(self, &key, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (BOOL) teal_autotrackingEnabledForInstance:(NSString *)instanceID {
    
    NSString *nsKey = [NSString stringWithFormat:TEALKeyAutotrackingEnabled, instanceID];
    CFStringRef key = (__bridge CFStringRef)(nsKey);
    
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &key);
        
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (void) teal_setAutotrackIvarsEnabled:(BOOL)enabled {
    NSNumber *enableOnNumber = @(enabled);
    objc_setAssociatedObject(self, &TEALKVOAutotrackIvars, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) teal_autotrackIvarsEnabled {
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TEALKVOAutotrackIvars);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (NSDictionary *) teal_autotrackDataSources {
    
    TEALDispatchType type = TEALDispatchTypeNone;
    
    if ([self isKindOfClass:([UIViewController class])]) {
        type = TEALDispatchTypeView;
    } else {
        type = TEALDispatchTypeEvent;
    }
    
    NSDictionary *dataSources = [TEALDataSources autotrackDataSourcesForDispatchType:type withObject:self];

    return dataSources;
}

- (NSDictionary *) teal_autotrackIvarDataSources {

    NSDictionary *ivars = [TEALDataSources ivarDataForObject:self];
    
    return ivars;
}

@end
