//
//  TEALVersion.h
//  Tealium
//
//  Created by Jason Koo on 11/11/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//
// Use the stringizing operator # to make a C string out of the symbol. However, due to a quirk of the preprocessor, you need to use two extra layers of macros:
// - Adam Rosenfield


#define TEALLibraryVersion @"5.0.2"

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