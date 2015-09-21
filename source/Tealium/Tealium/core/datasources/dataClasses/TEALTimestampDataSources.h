//
//  TEALTimestampDataSources.h
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALTimestampDataSources : NSObject

+ (NSDictionary *) dataSourcesForDate:(NSDate *)date;

@end
