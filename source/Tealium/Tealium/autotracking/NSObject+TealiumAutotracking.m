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

static CFStringRef  const TEALKVOAutotrackDatasources = CFSTR("TEALIUM_KVO_AUTOTRACKING_DATASOURCES");
static CFStringRef  const TEALKVOAutotrackIvars = CFSTR("TEALIUM_KVO_AUTOTRACKING_IVARS");

@implementation NSObject (TealiumAutotracking)

#pragma mark - PUBLIC INSTANCE

- (void) teal_setAutotrackingEnabled:(BOOL)enabled
{
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, &TEALKVOAutotrackDatasources, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) teal_autotrackingEnabled
{
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TEALKVOAutotrackDatasources);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (void) teal_setAutotrackIvarsEnabled:(BOOL)enabled {
    NSNumber *enableOnNumber = [NSNumber numberWithBool:enabled];
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
    }
    else {
        type = TEALDispatchTypeEvent;
    }
    
    NSDictionary *dataSources = [TEALDataSources autotrackDataSourcesForDispatchType:type withObject:self];

    return dataSources;
}

- (NSDictionary *) teal_autotrackIvarDataSources {
#warning This not producing data as expected
    
    return [TEALDataSources ivarDataForObject:self];
}

@end
