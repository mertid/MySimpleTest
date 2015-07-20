//
//  TEALTagNetworkService.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALDispatchNetworkService.h"
#import "TEALSystemProtocols.h"

@protocol TEALTagNetworkServiceConfiguration <NSObject, TEALOperations>

- (NSString *) tagTargetURLString;

@end


@interface TEALTagNetworkService : NSObject <TEALDispatchNetworkService>

- (instancetype) initWithConfiguration:(id<TEALTagNetworkServiceConfiguration>)configuration;

@end
