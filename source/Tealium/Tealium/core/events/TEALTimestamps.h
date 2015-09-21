//
//  TEALTimestamps.h
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALTimestamps : NSObject

+ (NSDictionary *) timestampDataSourcesForDate:(NSDate *)date;

@end
