//
//  TEALTagNetworkService.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALDispatchNetworkService.h"
#import "TEALSystemProtocols.h"

@protocol TEALTagNetworkServiceConfiguration <NSObject, TEALOperations>

- (NSString *) tagTargetURLString;

@end


@interface TEALTagNetworkService : NSObject <TEALDispatchNetworkService>

@property (strong, nonatomic) UIWebView *webView;

- (instancetype) initWithConfiguration:(id<TEALTagNetworkServiceConfiguration>)configuration;

@end
