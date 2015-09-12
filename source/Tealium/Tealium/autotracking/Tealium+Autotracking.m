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
#import <objc/runtime.h>

char const * const TEALKVOAutotrackLifecycle = "com.tealium.kvo.autotracking.lifecycle";

@implementation Tealium (Autotracking)

#pragma mark - PRIVATE PUBLIC

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

    TEALLifecycle *lifecycle = [[TEALLifecycle alloc] init];
    
    [lifecycle enableWithEventProcessingBlock:^(NSDictionary *dataDictionary, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *autotrackedDataSources = [TEALDataSources autotrackDataSourcesForDispatchType:TEALDispatchTypeEvent withObject:lifecycle];
            NSDictionary *deliveryData = [TEALSystemHelpers compositeDictionaries:@[dataDictionary? dataDictionary:@{},
                                                                                    autotrackedDataSources? autotrackedDataSources:@{}]];
            [weakSelf trackEventWithTitle:nil dataSources:deliveryData];
        });
        
    }];
    
    [self addModuleData:@{[self lifecycleInstanceID ]:lifecycle}];
    
    return lifecycle;
    
}

//- (NSSet *) lifecycleSet {
//    id raw = objc_getAssociatedObject(self, TEALKVOAutotrackLifecycle);
//    
//    if (![raw isKindOfClass:([NSSet class])]){
//        raw = [[NSSet alloc] init];
//    }
//    return raw;
//}
//
//- (void) addLifecycleInstance:(TEALLifecycle *)instance {
//    NSSet *lifecycles = [[self lifecycleSet] copy];
//    NSMutableSet *mSet = [NSMutableSet setWithSet:lifecycles];
//    [mSet addObject:instance];
//    
//    NSSet *newSet = [NSSet setWithSet:mSet];
//
//    [self.operationManager addOperationWithBlock:^{
//        objc_setAssociatedObject(self, TEALKVOAutotrackLifecycle, newSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }];
//}
//
//- (TEALLifecycle *) lifecycleInstanceFromSet:(NSSet *)set {
//    
//    __block TEALLifecycle *targetLifecycle = nil;
//    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
//        
//        if ([obj isKindOfClass:([TEALLifecycle class])]){
//            TEALLifecycle *lifecycle = obj;
//            if ([lifecycle.instanceIDCopy isEqualToString:self.settings.instanceID]){
//                targetLifecycle = lifecycle;
//                *stop = YES;
//            }
//        }
//    }];
//    
//    return targetLifecycle;
//}
//
//- (void) removeLifecycleInstance:(TEALLifecycle*)lifecycle{
//    
//    NSSet *set = [[self lifecycleSet] copy];
//    
//    TEALLifecycle *targetInstance = [self lifecycleInstanceFromSet:set];
//    if (!targetInstance){
//        return;
//    }
//    
//    NSMutableSet *mSet = [NSMutableSet setWithSet:set];
//    [mSet removeObject:targetInstance];
//    NSSet *newSet = [NSSet setWithSet:mSet];
//    
//    [self.operationManager addOperationWithBlock:^{
//        objc_setAssociatedObject(self, TEALKVOAutotrackLifecycle, newSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }];
//}

@end