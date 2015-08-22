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
#import "TEALDispatchService.h"

@class TEALURLSessionManager;


//@protocol TEALCollectNetworkServiceConfiguration <NSObject, TEALURLSessions>
//
//- (NSString *) collectDispatchURLString;
//
//@end

@interface TEALCollectDispatchService : NSObject <TEALDispatchService>

- (instancetype) initWithDispatchURLString:(NSString *)dispatchURLString sessionManager:(TEALURLSessionManager *)sessionManager;

    
//+ (instancetype) networkServiceWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration;
//
//- (instancetype) initWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration;

@end
