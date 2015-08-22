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
#import "TEALDatasourceConstants.h"
#import "TEALLogger.h"
#import "TEALDispatch.h"
#import "TEALOperationManager.h"
#import "NSDictionary+Tealium.h"

@interface TEALTagDispatchService() <UIWebViewDelegate>

@property (weak, nonatomic) NSString *publishURLString;
@property (weak, nonatomic) TEALOperationManager *operationManager;
@property (nonatomic) TEALDispatchNetworkServiceStatus status;

@end

@implementation TEALTagDispatchService

- (instancetype) initWithPublishURLString:(NSString *)urlString operationManager:(TEALOperationManager *)operationManager {
    
    self = [super init];
    if (self) {
        
        _publishURLString = urlString;
        _operationManager = operationManager;
        
    }
    
    return self;
    
}

#pragma mark - TEALNETWORKSERVICE DELEGATES

- (TEALDispatchNetworkServiceStatus) status{
    return self.status;
}

- (void) setup{
    
    __weak TEALTagDispatchService *weakSelf = self;
    NSString *urlString = self.publishURLString;
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:urlString];

    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        weakSelf.webView.delegate = weakSelf;
        [weakSelf.webView loadRequest:request];
    });

}

- (void) sendDispatch:(TEALDispatch *)dispatch completion:(TEALDispatchBlock)completion{
    
    NSString *utagString = [self utagCommandFrom:dispatch.payload];
    
    __block __weak UIWebView *weakWebView = self.webView;
    __block NSString *result = nil;
    
    __weak TEALTagDispatchService *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        result = [weakWebView stringByEvaluatingJavaScriptFromString:utagString];
        
        
        [weakSelf.operationManager addOperationWithBlock:^{
            
            if (result.length == 0 || [[result lowercaseString] isEqualToString:@"true"]){
                
                NSString *packagedDataString = [NSString stringWithFormat:@"%s Packaged Dispatch Data Sources: %@", __FUNCTION__,
                                                [dispatch.payload teal_arrayForDebugDisplay]];
                
                // TODO: should be available elsewhere
                
                TEAL_LogNormal(@"%@", packagedDataString);
                
                if (completion) {
                    completion(TEALDispatchStatusSent, dispatch, nil);
                }
                return;
            } else {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey:  NSLocalizedString(@"Dispatch was unsuccessful.", nil),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Javascript returned an unexpected result: %@ for dispatch:%@", result, dispatch.payload],
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check TIQ settings and that mobile.html has published correctly.", nil)
                                           };
                // TODO: error codes?
                NSError *error = [NSError errorWithDomain:@"Tealium"
                                                     code:400
                                                 userInfo:userInfo];
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
    
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.operationManager addOperationWithBlock:^{
        self.status = TEALDispatchNetworkServiceStatusReady;

    }];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    // TODO: retry later?
    
    [self.operationManager addOperationWithBlock:^{
        
    }];
}

#pragma mark - UTAG

- (NSString *) utagCommandFrom:(NSDictionary *)dispatchData {
    // Converts a utag item dictionary into a utag.js ready jsonString object
    
    NSError *error = nil;
    
    if ([NSJSONSerialization isValidJSONObject:dispatchData]) {
        
        NSString *trackType = dispatchData[TEALDatasourceKey_CallType];
        
        if(!trackType || trackType == (NSString*)[NSNull null]) {
            trackType = TEALDatasourceValue_Link; //default option
        }
        
        NSString *utagCommand = nil;
        @autoreleasepool {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dispatchData options:0 error:&error];
            
            if (jsonData != nil) {
                NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                utagCommand = [NSString stringWithFormat:@"utag.track('%@', %@)", trackType, jsonDataString];
            }
        }
        if (utagCommand) {
            return utagCommand;
        }
    } else {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Dispatch packaging unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Dispatch data could not be serialized into JSON."],
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure all custom values being passed into library are JSON serializable.", nil)
                                   };
        // TODO: error codes
        error = [NSError errorWithDomain:@"Tealium"
                                    code:400
                                userInfo:userInfo];
    }
    
    if (error) {
        TEAL_LogNormal(@"%@", [error localizedDescription]);
    }
    
    return nil;
    
}

@end
