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
+ (NSDictionary *) overwriteDataSources;
+ (TEALConfiguration *) liveConfig;
+ (TEALConfiguration *) nonExistentConfig;
+ (TEALConfiguration *) configWithOverridePublishSetting:(NSString *)overrideURL;
+ (TEALConfiguration *) configFromTestHTMLFile:(NSString *)filename;
+ (TEALConfiguration *) configFromTestJSONFile:(NSString *)filename;
+ (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs;
+ (NSDictionary *) dictionaryFromJSONFile:(NSString *)filename;


@end
