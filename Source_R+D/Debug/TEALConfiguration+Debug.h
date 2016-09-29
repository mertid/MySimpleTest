//
//  TEALConfiguration+Debug.h
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#ifdef TEAL_SOURCE
#import "TEALConfiguration.h"
#elif defined(TEAL_TARGET_IOS)
#import <TealiumIOS/TEALConfiguration.h>
#elif defined(TEAL_TARGET_TVOS)
#import <TealiumTVOS/TEALConfiguration.h>
#endif

@interface TEALConfiguration (Debug)

- (BOOL) isDebugEnabled;

- (void) setDebugEnabled:(BOOL)enable;

@end
