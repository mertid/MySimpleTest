//
//  TEALSettings+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 9/19/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALSettings_PrivateHeader_h
#define TEALSettings_PrivateHeader_h

#import "TEALSettings.h"

@interface TEALSettings (Private)

- (BOOL) autotrackingApplicationInfoEnabled;
- (BOOL) autotrackingCarrierInfoEnabled;
- (BOOL) autotrackingTimestampInfoEnabled;

@end

#endif /* TEALSettings_PrivateHeader_h */
