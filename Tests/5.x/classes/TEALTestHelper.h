//
//  TEALTestHelpers.h
//  TealiumiOS
//
//  Created by Jason Koo on 12/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//
//  Class level methods that can be used by other Tealium test classes

#import <Foundation/Foundation.h>
#import "TEALDataSourceConstants.h"
#import "TEALTestHelperConstants.h"
#import "TEALConfiguration+PrivateHeader.h"

@interface TEALTestHelper : NSObject

+ (NSArray *) defaultViewDataSourceKeys;
+ (NSArray *) defaultEventDataSourceKeys;
+ (TEALConfiguration *) liveConfig;
+ (TEALConfiguration *) nonExistentConfig;
+ (TEALConfiguration *) configWithOverridePublishSetting:(NSString *)overrideURL;
+ (TEALConfiguration *) configFromTestHTMLFile:(NSString *)filename;
+ (TEALConfiguration *) configFromTestJSONFile:(NSString *)filename;


#warning add a library class start method

@end
