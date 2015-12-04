//
//  TealiumHelper.h
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import WatchConnectivity;

/*
 *  Using an abstract class like this is the recommended best practice for 
 *  utilizing analytics or other third party libraries requiring an event 
 *  trigger with optional data.
 */
@interface TealiumWKHelper : NSObject<WCSessionDelegate>

+ (void) startTracking;

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) stopTracking;

//+ (void) incrementLifetimeValueForKey:(NSString *)key amount:(int)number;

@end
