//
//  TEALApplicationLifecycle.m
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALApplicationLifecycle.h"
#import <UIKit/UIKit.h>
#import "Tealium.h"
#import "TEALLogger.h"

#import "TEALDatasourceConstants.h"

@interface TEALApplicationLifecycle ()

@property (nonatomic) BOOL enabled;
@property (copy, nonatomic) TEALDictionaryCompletionBlock eventProcessingBlock;

@end

@implementation TEALApplicationLifecycle

- (void) enableWithEventProcessingBlock:(TEALDictionaryCompletionBlock)block {
    
    // listen to main thread events
    
    self.enabled = YES;
    
    self.eventProcessingBlock = block;
    
    NSArray *events = @[
//                        UIApplicationDidFinishLaunchingNotification,
//                        UIApplicationWillEnterForegroundNotification,
                        UIApplicationDidBecomeActiveNotification,
                        UIApplicationDidEnterBackgroundNotification,
                        UIApplicationWillTerminateNotification
                        ];

    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(processLifecycleEvent:)
                                                    name:obj
                                                  object:nil];
    }];
}

- (void) disable {
    
    if (self.enabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.enabled = NO;
    }
}

- (void) processLifecycleEvent:(NSNotification*) notification {
    
    NSString *name = notification.name;
    NSString *eventName = nil;
    
    TEAL_LogNormal(@"Lifecycle event detected: %@", name);
    
    if ([name isEqualToString:UIApplicationDidFinishLaunchingNotification]){
        eventName = TEALDatasourceValue_LifecycleLaunch;
    }
    else if ([name isEqualToString:UIApplicationWillEnterForegroundNotification]){
        eventName = TEALDatasourceValue_LifecycleSleep;
    }
    else if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]){
        eventName = TEALDatasourceValue_LifecycleWake;
    }
    else if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        eventName = TEALDatasourceValue_LifecycleSleep;
    }
    else if ([name isEqualToString:UIApplicationWillTerminateNotification]){
        eventName = TEALDatasourceValue_LifecycleTerminate;
    }

    NSDictionary *lifecycleData = @{TEALDatasourceKey_Autotracked : TEALDatasourceValue_True,
                                    TEALDatasourceKey_LifecycleType: eventName};
    
    if (self.eventProcessingBlock) {
        // TODO: Add error handling?
        
        self.eventProcessingBlock(lifecycleData, nil);
    }
}

@end
