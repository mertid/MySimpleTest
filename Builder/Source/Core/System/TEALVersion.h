//
//  TEALVersion.h
//  Tealium
//
//  Created by Jason Koo on 11/11/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//


#define TEALLibraryVersion @"5.0.3"

// iOS
#ifdef TEAL_TARGET_IOS

#define TEALPlatform @"iOS"

#endif


// tvOS
#ifdef TEAL_TARGET_TVOS

#define TEALPlatform @"tvOS"

#endif


// watchOS
#ifdef TEAL_TARGET_WATCHOS

#define TEALPlatform @"watchOS"

#endif