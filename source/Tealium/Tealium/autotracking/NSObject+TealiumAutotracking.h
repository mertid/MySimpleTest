//
//  NSObject+TealiumAutotracking.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TealiumAutotracking)

- (void) teal_setAutotrackingEnabled:(BOOL)enabled;
- (BOOL) teal_autotrackingEnabled;
- (void) teal_setAutotrackIvarsEnabled:(BOOL)enabled;
- (BOOL) teal_autotrackIvarsEnabled;

- (NSDictionary *) teal_autotrackDataSources;
- (NSDictionary *) teal_autotrackIvarDataSources;


@end
