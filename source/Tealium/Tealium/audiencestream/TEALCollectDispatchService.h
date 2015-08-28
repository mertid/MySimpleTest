//
//  TEALCollectDispatchManager.h
//  Tealium Mobile Library
//
//  Created by George Webster on 2/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALSystemProtocols.h"
#import "TEALDispatchService.h"

@class TEALURLSessionManager;


@interface TEALCollectDispatchService : NSObject <TEALDispatchService>

- (instancetype) initWithDispatchURLString:(NSString *)dispatchURLString sessionManager:(TEALURLSessionManager *)sessionManager;

@end
