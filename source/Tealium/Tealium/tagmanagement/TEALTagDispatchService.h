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

@class TEALLogger;
@class TEALRemoteCommandManager;

@protocol TEALTagDispatchServiceDelegate <NSObject>

- (void) TEALTagDispatchServiceWebViewReady:(id)webView;

@end

@interface TEALTagDispatchService : NSObject <TEALDispatchService>

@property (nonatomic, strong) id *webView;
@property (nonatomic, weak) id<TEALTagDispatchServiceDelegate> delegate;

- (instancetype) initWithPublishURLString:(NSString *)urlString operationManager:(TEALOperationManager *)operationManager;

- (NSString *) publishURLStringCopy;

- (void) setStatus:(TEALDispatchNetworkServiceStatus) status;

- (TEALRemoteCommandManager *) remoteCommandManager;


@end
