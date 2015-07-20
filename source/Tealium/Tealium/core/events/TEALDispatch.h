//
//  TEALDispatch.h
//  TealiumUtilities
//
//  Created by George Webster on 2/13/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALEvent.h"

@interface TEALDispatch : NSObject <NSCoding>

@property (nonatomic) TEALEventType eventType;
@property (strong, nonatomic) NSDictionary *payload;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) BOOL queued;

+ (TEALDispatch *) dispatchForEvent:(TEALEventType)eventType withData:(NSDictionary *)userInfo;

@end
