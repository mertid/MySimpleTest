//
//  TEALCollect-Bridging-Header.h
//  Tealium Mobile Library
//
//  Created by George Webster on 3/5/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifdef TEAL_SOURCE

#import "Tealium.h"
#import "Tealium+Lifecycle.h"

#else
@import TealiumIOS;
#endif