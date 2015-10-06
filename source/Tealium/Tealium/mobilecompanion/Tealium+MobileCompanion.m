//
//  Tealium+MobileCompanion.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+MobileCompanion.h"
#import "Tealium+PrivateHeader.h"
#import "TEALMobileCompanion.h"
#import "TEALMobileCompanionDelegate.h"
#import "TEALMobileCompanionContent.h"
#import "TEALMobileCompanionConstants.h"
#import "TEALModulesDelegate.h"
#import "NSString+Tealium.h"
#import <objc/runtime.h>

#ifdef TEAL_MODULE_AUTOTRACKING
#import "NSObject+TealiumAutotracking.h"
#endif

//char const * const TEALKVO_MobileCompanion = "com.tealium.kvo.mobilecompanion";
NSString * const TEALKeyMobileCompanion = @"com.tealium.mobilecompanion";

@interface Tealium() <TEALMobileCompanionDelegate, TEALModulesDelegate>

@end

@implementation Tealium (MobileCompanion)

#pragma mark - PUBLIC INSTANCE

- (void) revealMobileCompanion {
    
    [[self mobileCompanionInstance] reveal];
}

#pragma mark - PRIVATE INSTANCE

- (void) enableMobileCompanion {
    
    TEALMobileCompanion *mobileCompanion = [self mobileCompanionInstance];
    
    if ([mobileCompanion isEnabled])return;
    
    [[self mobileCompanionInstance] enable];
    [self enableMobileCompanionRevealListener];
    
    [self.logger logVerbose:@"Mobile Companion enabled."];
    
}

- (void) enableMobileCompanionRevealListener {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealMobileCompanion) name:@"com.tealium.mobilecompanion.reveal" object:self.operationManager];
}

- (void) disableMobileCompanionRevealListener {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) disableMobileCompanion {
    
    TEALMobileCompanion *mobileCompanion = [self mobileCompanionInstance];
    
    if (![mobileCompanion isEnabled]) return;
    
    [self disableMobileCompanionRevealListener];
    [[self mobileCompanionInstance] disable];
    
    [self.logger logVerbose:@"Mobile Companion disabled."];

    
}

- (TEALMobileCompanion *) mobileCompanionInstance {
    
    id raw = [self moduleDataCopy][TEALKeyMobileCompanion];
    if (![raw isKindOfClass:([TEALMobileCompanion class])]){
        return [self newMobileCompanionInstance];
    }
    
    TEALMobileCompanion *mobileCompanion = (TEALMobileCompanion*)raw;
    return mobileCompanion;
    
}

- (TEALMobileCompanion *) newMobileCompanionInstance {

    TEALMobileCompanion *mobileCompanion = [[TEALMobileCompanion alloc] initWithInstanceID:self.settings.instanceID];
    
    mobileCompanion.delegate = self;
    
    [self addModuleData:@{TEALKeyMobileCompanion:mobileCompanion}];
    
    return mobileCompanion;

}


#pragma mark - TEALMOBILECOMPANION DELEGATE

- (void) tealiumMobileCompanionDidDismiss {

    [self.operationManager addOperationWithBlock:^{
        
        [self removeModuleDataForKey:TEALKeyMobileCompanion];
        
    }];

}

- (void) tealiumMobileCompanionRequestsSettings:(TEALMobileCompanion *)mobileCompanion {
    
    NSArray *contentData = @[
                             @{@"Configuration":@[
                                 @{@"account":self.settings.account},
                                 @{@"profile":self.settings.tiqProfile},
                                 @{@"target":self.settings.environment},
                                 @{@"autotracking UIEvents":[NSString teal_stringFromBool:self.settings.autotrackingUIEventsEnabled]}
                                 ]},
                             @{@"Mobile Publish Settings":@[
                                 @{@"Published At":@"Not yet implemented"},
                                 ]}
                             ];
    
    TEALMobileCompanionContent *content = [TEALMobileCompanionContent contentFromArray:contentData];
    [mobileCompanion refreshWithContent:content];
    
//    [mobileCompanion addContent:[TEALMobileCompanionContent contentFromArray:contentData]
//                       forTitle:TEALMobileCompanionTabTitleOverview];
    
}

- (void) tealiumMobileCompanionRequestsViewDataSources:(TEALMobileCompanion *)mobileCompanion forObject:(NSObject *)object {
    
    NSArray *contentData = nil;
    
    if (!object) object = [self activeViewController];
    
    if (!object){
        contentData = @[
                        @{NSLocalizedString(@"No View data currently available.", @""):@""}
                        ];
        
    } else {
        
//#ifdef TEAL_MODULE_AUTOTRACKING
//        NSDictionary *autotrackedObjectData = [object teal_autotrackDataSources];
//        [objectDataSources addEntriesFromDictionary:autotrackedObjectData];
//#endif
        
        
        // Info
        NSMutableDictionary *objectInfoDataSources = [NSMutableDictionary dictionary];
        
        BOOL trackingObject;
        SEL selector = NSSelectorFromString(@"teal_autotrackingEnabledForInstance:");
        IMP impSelector = [object methodForSelector:selector];
        BOOL (*funcInfo)(id, SEL) = (void *)impSelector;
        trackingObject = funcInfo(object, selector);
        
        objectInfoDataSources[@"Autotracking"] = [NSString stringWithFormat:@"%@", trackingObject? @"YES":@"NO"];
        
        // Data Sources
        NSMutableDictionary *objectDataSources = [NSMutableDictionary dictionary];
        NSDictionary *autotrackedObjectData = nil;
        
        SEL autotrackDataSources = NSSelectorFromString(@"teal_autotrackDataSources");
        IMP impAutotrackDataSources = [object methodForSelector:autotrackDataSources];
        id (*func)(id, SEL) = (void *)impAutotrackDataSources;
        autotrackedObjectData = func(object, autotrackDataSources);
        
        [objectDataSources addEntriesFromDictionary:autotrackedObjectData];
        [objectDataSources addEntriesFromDictionary:[self volatileDataSourcesCopy]];
        [objectDataSources addEntriesFromDictionary:[self persistentDataSourcesCopy]];
        
        NSDictionary *objectData = [object teal_dataSources];
        [objectDataSources addEntriesFromDictionary:objectData];
        
        
        // Content Data
        contentData = @[
                        @{@"Info":@[objectInfoDataSources]},
                        @{@"Data Sources":@[objectDataSources]}
                        ];
    }
    
    TEALMobileCompanionContent *content = [TEALMobileCompanionContent contentFromArray:contentData];
    [mobileCompanion refreshWithContent:content];
    
//    [mobileCompanion addContent:[TEALMobileCompanionContent contentFromArray:contentData]
//                       forTitle:TEALMobileCompanionTabTitleView];
    
}

- (void) tealiumMobileCompanionRequestsEventDataSources:(TEALMobileCompanion *)mobileCompanion forObject:(NSObject *)object {
    
    NSArray *contentData = nil;
    
    if (!object){
        contentData = @[
                        @{NSLocalizedString(@"No Element data currently available.", @""):[NSNull null]}
                        ];
        
    } else {
#warning FINISH
    }
    
    TEALMobileCompanionContent *content = [TEALMobileCompanionContent contentFromArray:contentData];
    [mobileCompanion refreshWithContent:content];
    
//    [mobileCompanion addContent:[TEALMobileCompanionContent contentFromArray:contentData]
//                       forTitle:TEALMobileCompanionTabTitleElement];
    
}

- (void) tealiumMobileCompanionRequestsDispatchLogs:(TEALMobileCompanion *)mobileCompanion {
    
   
    NSArray *sentDispatches = [self.dispatchManager sentDispatchesCopy];
    NSArray *queuedDispatches = [self.dispatchManager queuedDispatchesCopy];
    NSArray *sent = [self payloadDataFromDispatchArray:sentDispatches];
    NSArray *queued = [self payloadDataFromDispatchArray:queuedDispatches];
    
    // Content Data
    NSArray *contentData = @[
                             @{@"Sent Dispatches":sent},
                               @{@"Queued Dispatches":queued}
                             ];
    
    TEALMobileCompanionContent *content = [TEALMobileCompanionContent contentFromArray:contentData];
    [mobileCompanion refreshWithContent:content];
    
//    [mobileCompanion addContent:[TEALMobileCompanionContent contentFromArray:contentData]
//                       forTitle:TEALMobileCompanionTabTitleLogs];
    
}

- (void) tealiumMobileCompanionRequestsTools:(TEALMobileCompanion *)mobileCompanion {
    
    
    TEALMobileCompanionContent *content = [TEALMobileCompanionContent contentFromArray:nil];
    [mobileCompanion refreshWithContent:content];
    
//    [mobileCompanion addContent:[TEALMobileCompanionContent contentFromArray:nil]
//                       forTitle:TEALMobileCompanionTabTitleTools];
}

- (void) tealiumMobileCompanionEnabledTrace:(TEALMobileCompanion *)mobileCompanion withID:(NSString *)traceID {
    
#ifdef TEAL_MODULE_COLLECT
    
#endif

}

- (void) tealiumMobileCompanionDisabledTrace:(TEALMobileCompanion *)mobileCompanion {
 
#ifdef TEAL_MODULE_COLLECT
    
#endif
    
}

#pragma mark - HELPERS

// TODO move to a category

- (NSArray *) payloadDataFromDispatchArray:(NSArray *)array {
    
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (TEALDispatch *dispatch in array) {
        NSString *key = [NSString stringWithFormat:@"%@", [NSDate dateWithTimeIntervalSince1970:dispatch.timestamp]];
        NSString *value = [TEALDispatch stringFromDispatchType:dispatch.dispatchType];
        NSDictionary *payload = @{key:value};
        [mArray addObject:payload];
    }
    
    return [NSArray arrayWithArray:mArray];
}

@end
