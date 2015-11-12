//
//  TEALVersion.h
//  Tealium
//
//  Created by Jason Koo on 11/11/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//
// Use the stringizing operator # to make a C string out of the symbol. However, due to a quirk of the preprocessor, you need to use two extra layers of macros:
// - Adam Rosenfield

#ifdef TEAL_TARGET_IOS

#define TEAL_TARGET TEAL_TARGET_IOS
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define TEALLibraryVersion @ STRINGIZE2(TEAL_TARGET)

#define TEALPlatform @"iOS"

#endif

#ifdef TEAL_TARGET_TVOS

#define TEAL_TARGET TEAL_TARGET_TVOS
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define TEALLibraryVersion @ STRINGIZE2(TEAL_TARGET)

#define TEALPlatform @"tvOS"

#endif