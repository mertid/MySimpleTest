//
//  TEALAutotrackDataSources.h
//  Tealium
//
//  Created by Jason Koo on 8/5/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  !!! CONVERT TO TEALDatasources+TEALAutotracking

#import "TEALDataSources.h"

@interface TEALDataSources (Autotracking)

+ (NSDictionary *) autotrackDataSourcesForDispatchType:(TEALDispatchType)dispatchType withObject:(NSObject *)obj;

+ (NSDictionary *) ivarDataForObject:(NSObject *)object;


@end
