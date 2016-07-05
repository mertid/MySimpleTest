//
//  TEALDispatchNetworkService.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDispatch.h"

typedef NS_ENUM(NSUInteger, TEALDispatchNetworkServiceStatus){
    TEALDispatchNetworkServiceStatusUnknown = 0,
    TEALDispatchNetworkServiceStatusReady
};

@protocol TEALDispatchService <NSObject>

- (void) setup;
- (void) sendDispatch:(TEALDispatch *)dispatch completion:(TEALDispatchBlock)completion;
- (NSString *) name;
- (TEALDispatchNetworkServiceStatus) status;

@end
