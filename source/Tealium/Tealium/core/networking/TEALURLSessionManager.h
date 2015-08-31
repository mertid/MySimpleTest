//
//  TEALNetworkManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALReachabilityManager.h"

#import "TEALBlocks.h"

@interface TEALURLSessionManager : NSObject

@property (nonatomic, strong) TEALReachabilityManager *reachability;
@property (nonatomic, strong) dispatch_queue_t completionQueue;


- (instancetype) initWithConfiguration:(NSURLSessionConfiguration *)configuration;

- (void) performRequest:(NSURLRequest *)request withCompletion:(TEALHTTPResponseBlock)completion;

- (void) performRequest:(NSURLRequest *)request withJSONCompletion:(TEALHTTPResponseJSONBlock)completion;

@end
