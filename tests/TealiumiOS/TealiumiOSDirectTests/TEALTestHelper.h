//
//  TEALTestHelpers.h
//  TealiumiOS
//
//  Created by Jason Koo on 12/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALDataSourceConstants.h"
#import "TEALTestHelperConstants.h"
#import "TEALConfiguration+PrivateHeader.h"

@interface TEALTestHelper : NSObject

+ (NSArray *) defaultViewDataSourceKeys;
+ (NSArray *) defaultEventDataSourceKeys;
+ (TEALConfiguration *) liveConfig;
+ (TEALConfiguration *) nonExistentConfig;

@end
