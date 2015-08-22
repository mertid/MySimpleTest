//
//  TEALTagNetworkService.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALDispatchService.h"
#import "TEALSystemProtocols.h"

@interface TEALTagDispatchService : NSObject <TEALDispatchService>

@property (strong, nonatomic) UIWebView *webView;

- (instancetype) initWithPublishURLString:(NSString *)urlString operationManager:(TEALOperationManager *)operationManager;

@end
