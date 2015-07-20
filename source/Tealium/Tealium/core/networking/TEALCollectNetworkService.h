//
//  TEALCollectDispatchManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDispatchConstants.h"
#import "TEALSystemProtocols.h"
#import "TEALEvent.h"

#import "TEALDispatchNetworkService.h"

@class TEALURLSessionManager;


@protocol TEALCollectNetworkServiceConfiguration <NSObject, TEALURLSessions>

- (NSString *) collectDispatchURLString;

@end

@interface TEALCollectNetworkService : NSObject <TEALDispatchNetworkService>

+ (instancetype) networkServiceWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration;

- (instancetype) initWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration;

@end
