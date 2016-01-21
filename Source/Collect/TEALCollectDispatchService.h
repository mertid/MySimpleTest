//
//  TEALCollectDispatchManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: This uses the newer VData i.gif call

#import <Foundation/Foundation.h>
#import "TEALSystemProtocols.h"
#import "TEALDispatchService.h"

@class TEALURLSessionManager;


@interface TEALCollectDispatchService : NSObject <TEALDispatchService>

- (instancetype _Nullable) initWithDispatchURLString:(NSString * _Nonnull)dispatchURLString sessionManager:(TEALURLSessionManager * _Nonnull)sessionManager;

- (NSString * _Nonnull) dispatchURLStringCopy;

@end
