//
//  TEALAutotracking.h
//  Tealium
//
//  Created by Jason Koo on 8/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef TEAL_MODULE_AUTOTRACKING
#define TEAL_MODULE_AUTOTRACKING
#endif

#import "Tealium.h"
#import "TEALModulesDelegate.h"

@interface Tealium (AutoTracking) <TEALModulesDelegate>

+ (NSArray *) allAutotrackingLifecycleInstances;

+ (NSArray *) allAutotrackingViewInstances;

+ (NSArray *) allAutotrackingIvarInstances;

+ (NSArray *) allAutotrackingUIEventInstances;

- (NSDictionary *) currentLifecycleData;

- (NSDictionary *) getAutotrackedDataSourcesForObject:(NSObject *)object;

- (void) setAutotrackingForObject:(NSObject *)object enable:(BOOL)isEnabled;

@end