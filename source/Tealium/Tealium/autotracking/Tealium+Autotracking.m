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
#import "TEALDataSources+Autotracking.h"
#import "TEALLifecycle.h"
#import "TEALSystemHelpers.h"
#import <objc/runtime.h>

char const * const TEALIUM_KVO_AUTOTRACKING_LIFECYCLE = "com.tealium.kvo.autotracking.lifecycle";

@implementation Tealium (Autotracking)

- (void) enableAutotrackingLifecycle {
    
    __block typeof(self) __weak weakSelf = self;
    TEALLifecycle *lifecycle = [self lifecycle];
    
    [lifecycle enableWithEventProcessingBlock:^(NSDictionary *dataDictionary, NSError *error) {
        
        NSDictionary *autotrackedDataSources = [TEALDatasources autotrackDataSourcesForDispatchType:TEALDispatchTypeEvent withObject:[weakSelf lifecycle]];
        NSDictionary *deliveryData = [TEALSystemHelpers compositeDictionaries:@[dataDictionary,
                                                                                autotrackedDataSources]];
        [weakSelf trackEventWithTitle:nil dataSources:deliveryData];
    }];

    if ([lifecycle isEnabled]){
        [self.logger logVerbose:@"Autotracking Lifecycle active."];
    }
}

- (void) enableAutotrackingUIEvents {
    
    [UIApplication swizzleWithCompletion:^(BOOL success, NSError *error) {
        if (success){
            [self.logger logVerbose:@"Autotracking UIEvents active."];
        }
    }];

}

- (void) enableAutotrackingViews {
    
    [UIViewController swizzleWithCompletion:^(BOOL success, NSError *error) {
        if (success){
            [self.logger logVerbose:@"Autotracking Views active."];
        }
    }];
    
}

- (void) disableAutotrackingLifecycle {
    
    TEALLifecycle *lifecycle = [self lifecycleInstanceFromSet:[self lifecycleSet]];
    
    if (!lifecycle){
        return;
    }
    
    [self removeLifecycleInstance:lifecycle];
    
}

#pragma mark - PRIVATE INSTANCE

- (NSSet *) lifecycleSet {
    id raw = objc_getAssociatedObject(self, TEALIUM_KVO_AUTOTRACKING_LIFECYCLE);
    
    if (![raw isKindOfClass:([NSSet class])]){
        raw = [[NSSet alloc] init];
    }
    return raw;
}

- (void) addLifecycleInstance:(TEALLifecycle *)instance {
    NSSet *lifecycles = [[self lifecycleSet] copy];
    NSMutableSet *mSet = [NSMutableSet setWithSet:lifecycles];
    [mSet addObject:instance];
    
    NSSet *newSet = [NSSet setWithSet:mSet];

    [self.operationManager addOperationWithBlock:^{
        objc_setAssociatedObject(self, TEALIUM_KVO_AUTOTRACKING_LIFECYCLE, newSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (TEALLifecycle *) lifecycleInstanceFromSet:(NSSet *)set {
    
    __block TEALLifecycle *targetLifecycle = nil;
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:([TEALLifecycle class])]){
            TEALLifecycle *lifecycle = obj;
            if ([lifecycle.instanceIDCopy isEqualToString:self.settings.instanceID]){
                targetLifecycle = lifecycle;
                *stop = YES;
            }
        }
    }];
    
    return targetLifecycle;
}

- (void) removeLifecycleInstance:(TEALLifecycle*)lifecycle{
    
    NSSet *set = [[self lifecycleSet] copy];
    
    TEALLifecycle *targetInstance = [self lifecycleInstanceFromSet:set];
    if (!targetInstance){
        return;
    }
    
    NSMutableSet *mSet = [NSMutableSet setWithSet:set];
    [mSet removeObject:targetInstance];
    NSSet *newSet = [NSSet setWithSet:mSet];
    
    [self.operationManager addOperationWithBlock:^{
        objc_setAssociatedObject(self, TEALIUM_KVO_AUTOTRACKING_LIFECYCLE, newSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (TEALLifecycle *) lifecycle {
    
    // Returns the correct instance for instance type
    
    TEALLifecycle *lifecycle = [self lifecycleInstanceFromSet:[self lifecycleSet]];
    
    if (!lifecycle){
        lifecycle = [[TEALLifecycle alloc] initWithInstanceID:self.settings.instanceID];
        [self addLifecycleInstance:lifecycle];
    }
    
        NSLog(@"%s lifecycle returning: %@", __FUNCTION__, lifecycle);
    
    return lifecycle;
}

@end