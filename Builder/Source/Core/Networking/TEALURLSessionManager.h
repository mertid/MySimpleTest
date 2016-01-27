//
//  TEALNetworkManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALBlocks.h"
#import "TEALReachabilityManager.h"

@interface TEALURLSessionManager : NSObject

@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, strong) TEALReachabilityManager *reachabilityManager;

- (instancetype) initWithConfiguration:(NSURLSessionConfiguration *)configuration;

- (void) performRequest:(NSURLRequest *)request withCompletion:(TEALHTTPResponseBlock)completion;

- (void) performRequest:(NSURLRequest *)request withJSONCompletion:(TEALHTTPResponseJSONBlock)completion;


@end
