//
//  TEALMobileCompanionDelegate.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALMobileCompanion;

@protocol TEALMobileCompanionDelegate <NSObject>

@optional

- (void) tealiumMobileCompanionDidDismiss;
- (void) tealiumMobileCompanionRequestsSettings:(TEALMobileCompanion *)mobileCompanion;
- (void) tealiumMobileCompanionRequestsViewDataSources:(TEALMobileCompanion *)mobileCompanion forObject:(NSObject *)object;
- (void) tealiumMobileCompanionRequestsEventDataSources:(TEALMobileCompanion *)mobileCompanion forObject:(NSObject *)object;
- (void) tealiumMobileCompanionRequestsDispatchLogs:(TEALMobileCompanion *)mobileCompanion;
- (void) tealiumMobileCompanionRequestsTools:(TEALMobileCompanion *)mobileCompanion;
- (void) tealiumMobileCompanionEnabledTrace:(TEALMobileCompanion *)mobileCompanion withID:(NSString *)traceID;
- (void) tealiumMobileCompanionDisabledTrace:(TEALMobileCompanion *)mobileCompanion;

@end