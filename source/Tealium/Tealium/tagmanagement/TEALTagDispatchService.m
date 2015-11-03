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
    
    NSString *utagString = [self utagCommandFromDispatch:dispatch completion:completion];
    if (!utagString) return;
    
    __block __weak UIWebView *weakWebView = self.webView;
    __block NSString *result = nil;
    
    __weak TEALTagDispatchService *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        result = [weakWebView stringByEvaluatingJavaScriptFromString:utagString];
        
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
    
//        __weak __block TEALLogger *weakLogger = self.logger;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.remoteCommandManager processRequest:request
                                    completionHandler:^(TEALRemoteCommandResponse *response) {
                                        
#warning Implement some other means of logging remote command reponse
//                                        [weakLogger logDev:@"Remote command processed:%@", response];
                                        
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
                [self.delegate TEALTagDispatchServiceWebViewReady:webView];
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
            
#warning Implement alternative log method
//            [weakSelf.logger logDev:@"Webkit was unable to process callback command: %@", command];
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

@end
