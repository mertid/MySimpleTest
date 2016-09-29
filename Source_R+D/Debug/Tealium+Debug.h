//
//  Tealium+Debug.h
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef TEAL_SOURCE

#import "Tealium.h"

#elif defined(TEAL_TARGET_IOS)

#import <TealiumIOS/TealiumIOS.h>

#elif defined(TEAL_TARGET_TVOS)

#import <TealiumTVOS/TealiumTVOS.h>

#endif

@interface Tealium (Debug)


@end
