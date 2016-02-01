//
//  TEALReachabilityManager.h
//  TealiumiOS
//
//  Created by Jason Koo on 11/30/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALReachabilityManager : NSObject

+ (instancetype) reachabilityManagerWithHostName:(NSString *)hostname;

- (BOOL) isReachable;

- (BOOL) isReachableBlockEnabled;

- (BOOL) isReachableViaWifi;

- (void) startListeningForReachabilityChanges;

- (void) reachabilityChanged:(void (^)(BOOL canReach))responseBlock;

- (NSDictionary *) reachabilityDataSources:(NSDictionary *)clientDataSources;

@end
