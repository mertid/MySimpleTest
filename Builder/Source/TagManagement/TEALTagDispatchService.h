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
@class TEALRemoteCommandResponse;

@protocol TEALTagDispatchServiceDelegate <NSObject>

- (BOOL) tagDispatchServiceShouldPermitRequest:(NSURLRequest*)request webView:(id)webView;
- (void) tagDispatchServiceWebViewReady:(id)webView;
- (void) tagDispatchServiceWebView:(id)webView encounteredError:(NSError *)error;
- (void) tagDispatchServiceWebView:(id)webView processedCommandResponse:(TEALRemoteCommandResponse *)response;

@end

@interface TEALTagDispatchService : NSObject <TEALDispatchService>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, weak) id<TEALTagDispatchServiceDelegate> delegate;

- (instancetype) initWithPublishURLString:(NSString *)urlString
                         operationManager:(TEALOperationManager *)operationManager;

- (NSString *) publishURLStringCopy;

- (void) setStatus:(TEALDispatchNetworkServiceStatus) status;

@end
