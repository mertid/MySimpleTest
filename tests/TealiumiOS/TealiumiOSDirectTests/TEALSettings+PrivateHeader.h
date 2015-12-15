//
//  TEALSettings+PrivateHeader.h
//  TealiumTests
//
//  Created by Jason Koo on 8/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef TealiumTests_TEALSettings_PrivateHeader_h
#define TealiumTests_TEALSettings_PrivateHeader_h

#import "TEALSettings.h"
#import "TEALPublishSettings.h"

@interface TEALSettings (Private)

@property (nonatomic, strong) TEALConfiguration *configuration;

@property (nonatomic, strong) TEALPublishSettings *publishSettings;

@end

#endif
