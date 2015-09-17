//
//  Tealium+Autotracking.m
//  Tealium
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Autotracking.h"
#import "Tealium+PrivateHeader.h"
#import "UIApplication+Tealium.h"
#import "UIViewController+Tealium.h"
#import "TEALDataSources+Autotracking.h"
#import "TEALLifecycle.h"
#import "TEALSystemHelpers.h"
#import "TEALViewScanner.h"
#import <objc/runtime.h>

char const * const TEALKVOAutotrackLifecycle = "com.tealium.kvo.autotracking.lifecycle";

@implementation Tealium (Autotracking)

#pragma mark - PUBLIC CLASS

+ (NSArray *) allAutotrackingLifecycleInstances {
    
    NSDictionary *allInstances = [[Tealium allInstances] copy];
    NSMutableArray *targetInstances = [NSMutableArray array];
    
    [allInstances enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id raw = obj;
        if (![raw isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = raw;
        if (instance.settings.autotrackingLifecycleEnabled){
            [targetInstances addObject:instance];
        }
        
    }];
    
    return [NSArray arrayWithArray:targetInstances];
}

+ (NSArray *) allAutotrackingViewInstances {
    
    NSDictionary *allInstances = [[Tealium allInstances] copy];
    NSMutableArray *targetInstances = [NSMutableArray array];
    
    [allInstances enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id raw = obj;
        if (![raw isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = raw;
        if (instance.settings.autotrackingViewsEnabled){
            [targetInstances addObject:instance];
        }
        
    }];
    
    return [NSArray arrayWithArray:targetInstances];
    
}

+ (NSArray *) allAutotrackingIvarInstances {
    
    NSDictionary *allInstances = [[Tealium allInstances] copy];
    NSMutableArray *targetInstances = [NSMutableArray array];
    
    [allInstances enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id raw = obj;
        if (![raw isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = raw;
        if (instance.settings.autotrackingIvarsEnabled){
            [targetInstances addObject:instance];
        }
        
    }];
    
    return [NSArray arrayWithArray:targetInstances];
    
}

+ (NSArray *) allAutotrackingUIEventInstances {
    
    NSDictionary *allInstances = [[Tealium allInstances] copy];
    NSMutableArray *targetInstances = [NSMutableArray array];
    
    [allInstances enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id raw = obj;
        if (![raw isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = raw;
        if (instance.settings.autotrackingUIEventsEnabled){
            [targetInstances addObject:instance];
        }
        
    }];
    
    return [NSArray arrayWithArray:targetInstances];
}

#pragma mark - PUBLIC INSTANCE

- (NSDictionary *) currentLifecycleData {
    
    NSDictionary *lifecycleData = [[self lifecycleInstance] currentLifecycleData];
    
    return lifecycleData;
    
}


#pragma mark - PRIVATE INSTANCE

- (void) enableAutotrackingLifecycle {
    
    TEALLifecycle *lifecycle = [self lifecycleInstance];

    // If was disabled prior
    if (![lifecycle isEnabled]){
        [lifecycle reEnable];
    }
    
    if ([lifecycle isEnabled]){
        [self.logger logVerbose:@"Autotracking Lifecycle enabled."];
    }
    
}

- (void) enableAutotrackingUIEvents {
    
    [UIApplication swizzleWithCompletion:^(BOOL success, NSError *error) {
        if (success){
            [self.logger logVerbose:@"Autotracking UIEvents enabled."];
        }
    }];

}

- (void) enableAutotrackingViews {
    
    [UIViewController swizzleWithCompletion:^(BOOL success, NSError *error) {
        if (success){
            [self.logger logVerbose:@"Autotracking Views enabled."];
        }
    }];
    
    [[TEALViewScanner rootWindowController] teal_viewDidAppearCallOnly];
    
}

- (void) disableAutotrackingLifecycle {
    
    TEALLifecycle *lifecycle = [self lifecycleInstance];
    
    if ([lifecycle isEnabled]){
        [lifecycle disable];
        [self.logger logVerbose:@"Autotracking Lifecycle disabled."];
    }
    
}

#pragma mark - PRIVATE LIFECYCLE HANLDING

- (NSString *) lifecycleInstanceID {
    
    return [NSString stringWithFormat:@"com.tealium.lifecycle.%@", self.settings.instanceID];
}

- (TEALLifecycle *) lifecycleInstance {
    
    id raw = [self moduleDataCopy][[self lifecycleInstanceID]];
    if (!raw ||
        ![raw isKindOfClass:([TEALLifecycle class])]){
        return [self newLifecycleInstance];
    }
    
    TEALLifecycle *lifecycle = (TEALLifecycle*)raw;
    return lifecycle;
    
}

- (TEALLifecycle *) newLifecycleInstance {
    
    __block typeof(self) __weak weakSelf = self;

    TEALLifecycle *lifecycle = [[TEALLifecycle alloc] initWithInstanceID:[self.settings instanceID]];
    
    [lifecycle enableWithEventProcessingBlock:^(NSDictionary *dataDictionary, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *autotrackedDataSources = [TEALDataSources autotrackDataSourcesForDispatchType:TEALDispatchTypeEvent withObject:lifecycle];
            NSDictionary *deliveryData = [TEALSystemHelpers compositeDictionaries:@[dataDictionary? dataDictionary:@{},
                                                                                    autotrackedDataSources? autotrackedDataSources:@{}]];
            [weakSelf trackEventWithTitle:nil dataSources:deliveryData];
        });
        
    }];
    
    [lifecycle recordLaunch];
    
    [self addModuleData:@{[self lifecycleInstanceID ]:lifecycle}];
    
    return lifecycle;
    
}

@end