//
//  TEALAutotrackDataSources.h
//  Tealium
//
//  Created by Jason Koo on 8/5/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  !!! CONVERT TO TEALDatasources+TEALAutotracking

#import <UIKit/UIKit.h>
#import "TEALDispatch.h"

@interface TEALAutotrackDataSources : NSObject

+ (NSDictionary *) datasourcesForDispatchType:(TEALDispatchType)dispatchType
                            withObject:(NSObject *)obj;


@end
