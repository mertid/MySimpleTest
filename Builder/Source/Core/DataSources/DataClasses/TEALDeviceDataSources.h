//
//  TEALDeviceDataSources.h
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TEALDeviceDataSources : NSObject

+ (NSDictionary *) backgroundDataSources;
+ (NSDictionary *) mainThreadDataSources;

+ (BOOL) isCharging;
+ (double) batteryLevel;

@end
