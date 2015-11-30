//
//  TEALIDGenerator.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning Move to autotracking module

@interface TEALIDGenerator : NSObject

+ (NSString*)tealiumIdForObject:(id)object;

@end
