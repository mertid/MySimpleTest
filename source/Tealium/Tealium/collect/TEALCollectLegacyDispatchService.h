//
//  TEALCollectLegacyDispatchManager.h
//  Tealium Mobile Library
//
//  Created by Jason Koo on 10/29/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: This uses the original i.gif POST call

#import <Foundation/Foundation.h>
#import "TEALSystemProtocols.h"
#import "TEALDispatchService.h"

@class TEALURLSessionManager;


@interface TEALCollectLegacyDispatchService : NSObject <TEALDispatchService>

- (instancetype) initWithDispatchURLString:(NSString *)dispatchURLString
                                 visitorID:(NSString *)visitorID
                            sessionManager:(TEALURLSessionManager *)sessionManager;

@end
