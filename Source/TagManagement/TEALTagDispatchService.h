//
//  TEALTagNetworkService.h
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/Webkit.h>
#import "TEALDispatchService.h"
#import "TEALSystemProtocols.h"

@class TEALLogger;
@class TEALRemoteCommandResponse;

@protocol TEALTagDispatchServiceDelegate <NSObject>

- (BOOL) tagDispatchServiceShouldPermitRequest:(NSURLRequest*)request;
- (void) tagDispatchServiceWKWebViewCallback:(NSString *)message;
- (void) tagDispatchServiceWKWebViewReady:(id)wkWebView;
//- (void) tagDispatchServiceWebViewReady:(id)webView;
- (void) tagDispatchServiceWebView:(id)webView encounteredError:(NSError *)error;
//- (void) tagDispatchServiceWebView:(id)webView processedCommandResponse:(TEALRemoteCommandResponse *)response;

@end

@interface TEALTagDispatchService : NSObject <TEALDispatchService>

//@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, weak) id<TEALTagDispatchServiceDelegate> delegate;

- (instancetype) initWithPublishURLString:(NSString *)urlString
                         operationManager:(TEALOperationManager *)operationManager;

- (NSString *) publishURLStringCopy;

- (void) setStatus:(TEALDispatchNetworkServiceStatus) status;

@end
