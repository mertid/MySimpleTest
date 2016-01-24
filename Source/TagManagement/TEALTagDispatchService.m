//
//  TEALTagNetworkService.m
//  Tealium
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALTagDispatchService.h"
#import <UIKit/UIKit.h>
#import "TEALNetworkHelpers.h"
#import "TEALDataSourceConstants.h"
#import "TEALError.h"
#import "TEALLogger.h"
#import "TEALDispatch.h"
#import "TEALOperationManager.h"
#import "TEALRemoteCommandManager.h"
#import "NSDictionary+Tealium.h"

@import Security;

@interface TEALTagDispatchService() <UIWebViewDelegate, TEALRemoteCommandManagerDelegate>

@property (nonatomic, strong) TEALRemoteCommandManager *currentRemoteCommandManager;
@property (nonatomic, weak) NSString *publishURLString;
@property (nonatomic, weak) TEALOperationManager *operationManager;
@property (nonatomic) TEALDispatchNetworkServiceStatus privateStatus;
@property (nonatomic) BOOL webViewInitialLoadFinished;

@end

static NSString * const Tealium_TraceIdCookieKey = @"trace_id";

@implementation TEALTagDispatchService

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithPublishURLString:(NSString *)urlString operationManager:(TEALOperationManager *)operationManager {
    
    self = [super init];
    if (self) {
        
        _publishURLString = urlString;
        _operationManager = operationManager;
        _currentRemoteCommandManager = [[TEALRemoteCommandManager alloc] initWithOperationManager:operationManager];
        [_currentRemoteCommandManager setDelegate:self];
        
    }
    
    return self;
    
}

- (NSString *) publishURLStringCopy {
    return [self.publishURLString copy];
}

- (void) setStatus:(TEALDispatchNetworkServiceStatus) status {
    self.privateStatus = status;
}

- (TEALRemoteCommandManager *) remoteCommandManager {
    return self.currentRemoteCommandManager;
}

- (NSString *) name {
    return NSLocalizedString(@"Tag Management", @"");
}

- (void) setup {
    
    __weak TEALTagDispatchService *weakSelf = self;
    NSString *urlString = self.publishURLString;
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:urlString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        weakSelf.webView.delegate = weakSelf;
        [weakSelf.webView loadRequest:request];
        
    });
}

#pragma mark - PRIVATE INSTANCE

- (NSString *) description {
    return [NSString stringWithFormat:@"<TEALTagDispatch Service publishURL:%@ status:%lu>", self.publishURLString, (unsigned long)self.privateStatus];
}

#pragma mark - TEALNETWORKSERVICE DELEGATES

- (TEALDispatchNetworkServiceStatus) status{
    return self.privateStatus;
}

- (void) sendDispatch:(TEALDispatch *)dispatch completion:(TEALDispatchBlock)completion{
    
    [self processTraceFromDispatch:dispatch];
    
    NSString *utagString = [self utagCommandFromDispatch:dispatch completion:completion];
    
    if (!utagString) return;
    
    __block NSString *result = nil;
    
    __block __weak TEALTagDispatchService *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        result = [weakSelf.webView stringByEvaluatingJavaScriptFromString:utagString];
        
        [weakSelf.operationManager addOperationWithBlock:^{
            
            if (result.length == 0 || [[result lowercaseString] isEqualToString:@"true"]){
                
                if (completion) {
                    completion(TEALDispatchStatusSent, dispatch, nil);
                }
                return;
            } else {
                NSError *error = [TEALError errorWithCode:TEALRemoteResponseErrorMalformedURL
                                              description:@"Dispatch was unsuccessful"
                                                   reason:[NSString stringWithFormat:@"Javascript returned an unexpected result: %@ for dispatch:%@", result, dispatch.payload]
                                               suggestion:@"Check TIQ settings and that mobile.html has published correctly."];
                if (completion) {
                    completion(TEALDispatchStatusFailed, dispatch, error);
                }
                return;
            }
        }];
    });
    
}

#pragma mark - UIWEBVIEW DELEGATE

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([[self remoteCommandManager] isEnabled]) {
    
        __block typeof(self) __weak weakSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.remoteCommandManager processRequest:request
                                    completionHandler:^(TEALRemoteCommandResponse *response) {
                                        
                                        [weakSelf reportWebView:webView
                                                commandResponse:response];
                                        
                                    }];
            
        });

    }
    
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    

    // Initial load complete?
    if (!self.webViewInitialLoadFinished &&
        ![webView isLoading]){
        
        self.webViewInitialLoadFinished = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.privateStatus = TEALDispatchNetworkServiceStatusReady;
            
            if (self.delegate) {
                [self.delegate tagDispatchServiceWebViewReady:webView];
            }
        });
        

    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    // TODO: retry later?

}

#pragma mark - TEAL REMOTE COMMAND DELEGATE 

- (void) tagRemoteCommandManagerRequestsCommandToWebView:(NSString *)command {
    
    __block typeof(self) __weak weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *init = [weakSelf.webView stringByEvaluatingJavaScriptFromString:command];
        
        if ([[init lowercaseString] isEqualToString:@"false"]){
            
            if ([self.delegate respondsToSelector:@selector(tagDispatchServiceWebView:encounteredError:)]) {
                
                NSString *errorDescription = [NSString stringWithFormat:@"Could not process callback command: %@", command];
                NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                     description:errorDescription
                                          reason:NSLocalizedString(@"Command did not execute.", @"")
                                      suggestion:NSLocalizedString(@"Check command id in TIQ", @"")];
                
                [self reportWebView:weakSelf.webView
                              error:error];

            }

        }
    });
}

#pragma mark - UTAG

- (NSString *) utagCommandFromDispatch:(TEALDispatch *)dispatch completion:(TEALDispatchBlock)completion{
    // Converts a utag item dictionary into a utag.js ready jsonString object
    
    NSString *command = nil;
    NSError *error = nil;
    NSDictionary *dispatchData = dispatch.payload;
    
    if (!dispatchData){
        if (completion) {
            error = [TEALError errorWithCode:400
                                          description:NSLocalizedString(@"Convert Dispatch to utag command unsuccessful.", nil)
                                               reason:NSLocalizedString(@"Dispatch payload empty.", @"")
                                           suggestion:NSLocalizedString(@"At least one key-value pair of data most be present in payload to dispatch.", @"")];
        }
    } else if (![NSJSONSerialization isValidJSONObject:dispatchData]) {
        if (completion) {

            error = [TEALError errorWithCode:400
                                          description:NSLocalizedString(@"Dispatch packaging unsuccessful.", nil)
                                               reason:NSLocalizedString(@"Dispatch data could not be JSON serialized.", @"")
                                           suggestion:NSLocalizedString(@"Make sure all custom values passed to library are JSON serializable.", @"")];
        }
        
    } else {
        
        NSString *trackType = dispatchData[TEALDataSourceKey_CallType];
        
        if(!trackType || trackType == (NSString*)[NSNull null]) {
            trackType = TEALDataSourceValue_Link; //default option
        }
        
        @autoreleasepool {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dispatchData options:0 error:&error];
            
            if (jsonData != nil) {
                NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                command = [NSString stringWithFormat:@"utag.track('%@', %@)", trackType, jsonDataString];
            }
        }

    }
    
    if (error &&
        completion) {
        completion(TEALDispatchStatusFailed, dispatch, error);
    }
    
    return command;
    
}

#pragma mark - TRACE

- (void) processTraceFromDispatch:(TEALDispatch*)dispatch {
    
    NSString *traceID = dispatch.payload[TEALDataSourceKey_TraceID];
    
    NSHTTPCookie *exsistingCookie = [self traceCookieInCookieStorage];
    
    if (traceID) {
        
        // Add trace cookie
        if (!exsistingCookie){
            
            NSHTTPCookie *traceCookie = [self newTraceCookieWithTraceID:traceID];
            
            [self addTraceCookie:traceCookie];
            
        }
        
    } else {
        
        // Remove trace cookie
        if (exsistingCookie){
            [self removeTraceCookie:exsistingCookie];
        }
        
    }
}

- (NSHTTPCookie*) traceCookieInCookieStorage{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookieV in [cookieJar cookies]) {
        if ([[[cookieV name]lowercaseString] isEqualToString:Tealium_TraceIdCookieKey]) return cookieV;
    }
    return nil;
}

- (NSHTTPCookie*) newTraceCookieWithTraceID:(NSString*)traceId{
    // This is registering as a first party cookie
    // set Expiration to 12 hours
    NSString *maxAgeInSeconds = [NSString stringWithFormat:@"%i", 3600*12];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:@{NSHTTPCookieName:@"trace_id",
                                                                      NSHTTPCookieValue:traceId,
                                                                      NSHTTPCookieVersion:@"0",
                                                                      NSHTTPCookiePath:@"/",
                                                                      NSHTTPCookieDiscard:@"true",
                                                                      NSHTTPCookieDomain:@".tiqcdn.com",
                                                                      NSHTTPCookieOriginURL:@"",
                                                                      NSHTTPCookieMaximumAge:maxAgeInSeconds,
                                                                      }];
    return cookie;
}

- (void) addTraceCookie:(NSHTTPCookie*)cookie{
    
    // set new cookie
    NSHTTPCookieAcceptPolicy policy = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookieAcceptPolicy];
    if (policy == NSHTTPCookieAcceptPolicyNever){
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
    } else {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    __block typeof(self) __weak weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.webView reload];
        
    });

}

- (void) removeTraceCookie:(NSHTTPCookie *)cookie{
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    
    __block typeof(self) __weak weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"utag.track('kill_visitor_session', { event: 'kill_visitor_session', 'cp.trace_id' : utag.data['cp.trace_id'] });"];
        
        [weakSelf.webView reload];

    });

}

#pragma mark - HELPERS

- (void) reportWebView:(id)webView error:(NSError *) error {
    
    if ([self.delegate respondsToSelector:@selector(tagDispatchServiceWebView:encounteredError:)]){
        
        [self.delegate tagDispatchServiceWebView:webView
                                encounteredError:error];
        
    }
    
}

- (void) reportWebView:(id)webView commandResponse:(TEALRemoteCommandResponse*)response {
    
    if ([self.delegate respondsToSelector:@selector(tagDispatchServiceWebView:processedCommandResponse:)]){
        
        [self.delegate tagDispatchServiceWebView:webView
                        processedCommandResponse:response];
        
    }
}
@end
