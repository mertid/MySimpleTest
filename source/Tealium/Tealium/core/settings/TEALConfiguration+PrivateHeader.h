//
//  TEALConfiguration+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 9/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALConfiguration_PrivateHeader_h
#define TEALConfiguration_PrivateHeader_h

#import "TEALConfiguration.h"

@interface TEALConfiguration (Private)

@property () BOOL autotrackingApplicationInfoEnabled;
@property () BOOL autotrackingCarrierInfoEnabled;
@property () BOOL autotrackingTimestampInfoEnabled;

@end

#endif
