//
//  TEALS2SLegacyDispatchManager.m
//  Tealium Mobile Library
//
//  Created by Jason Koo on 10/29/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALS2SLegacyDispatchService.h"
#import "TEALNetworkHelpers.h"
#import "TEALURLSessionManager.h"
#import "TEALDispatch.h"
#import "TEALBlocks.h"
#import "TEALError.h"
#import "TEALDataSourceConstants.h"

@interface TEALS2SLegacyDispatchService ()

@property (nonatomic, weak) NSString *dispatchURLString;
@property (nonatomic, strong) NSString *visitorID;
@property (nonatomic, weak) TEALURLSessionManager *sessionManager;
@property (nonatomic) TEALDispatchNetworkServiceStatus privateStatus;

@end

@implementation TEALS2SLegacyDispatchService

- (instancetype) initWithDispatchURLString:(NSString *)dispatchURLString
                                 visitorID:(NSString *)visitorID
                            sessionManager:(TEALURLSessionManager *)sessionManager {
    self = [super init];
    if (self) {
        _dispatchURLString = dispatchURLString;
        _sessionManager = sessionManager;
        _visitorID = visitorID;
    }
    return self;
}

- (NSString *) dispatchURLStringCopy {
    
    return [self.dispatchURLString copy];
    
}

#pragma mark - PRIVATE

- (BOOL) isReady {
    
    if (!self.dispatchURLString || !self.sessionManager) {
        return NO;
    }
    
    return YES;
}


- (NSString *) description {
    return [NSString stringWithFormat:@"<TEALS2SLegacyDispatchService dispatchURL:%@ status:%lu>", self.dispatchURLString, (unsigned long)[self status]];
}

#pragma mark - TEALNETWORKSERVICE DELEGATES


- (void) setup {
    
    // Any additional work here

}


- (void) sendDispatch:(TEALDispatch *)dispatch
           completion:(TEALDispatchBlock)completion {
    
    NSError *error = nil;
    
    // Dispatch Service ready?
    if (![self isReady]) {
        // TODO: add error details
        
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"S2S Legacy Dispatch failed", @"")
                                  reason:NSLocalizedString(@"S2S Legacy Dispatch Service not ready.", @"")
                              suggestion:NSLocalizedString(@"Check that S2S Legacy Dispatch Service was initialized with correct dispatch URL String (check overrideS2SLegacyDispatchURL) OR try again later.", @"")];
        
        if (completion) {
            completion( TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }
    
    // Request valid?
    NSURLRequest *request = [self requestForDispatch:dispatch
                                               error:&error];
    if (!request){
        if (completion){
            completion(TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }
    
    // Okay - fire away
    [self.sessionManager performRequest:request
                         withCompletion:^(NSHTTPURLResponse *response,
                                          NSData *data,
                                          NSError *connectionError) {
                             
         if (completion) {
             
             // Should really be looking at the response code instead
             
             TEALDispatchStatus status = (connectionError) ? TEALDispatchStatusFailed : TEALDispatchStatusSent;
             
             completion( status, dispatch, connectionError );
         }
         
     }];
    
}

- (NSURLRequest *) requestForDispatch:(TEALDispatch *) dispatch
                                error:(NSError *__autoreleasing *)error {
    
    NSString *originURLString = self.dispatchURLString;
    
    NSString *dataQueryString = [self dataQueryString:dispatch.payload error:error];
    
    if (!dataQueryString) {
        // S2S Legacy won't work without the additioanl query data
        return nil;
    }
    
    NSString *encodedDataQueryString = [dataQueryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    
    if (![originURLString hasSuffix:@"?"]){
        originURLString = [originURLString stringByAppendingString:@"?"];
    }
    
    NSString *fullURLString = [NSString stringWithFormat:@"%@%@", originURLString, encodedDataQueryString];
    
    NSURL *url = [NSURL URLWithString:fullURLString];
    
    // Create new request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPShouldHandleCookies:YES];
    
    return request;
}

+ (NSURLRequest *) requestWithURLString:(NSString *)urlString {
    
    // Options different than networkHelpers options
    
    if (!urlString) {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPShouldHandleCookies = YES;
    request.networkServiceType = NSURLNetworkServiceTypeBackground;
    request.HTTPMethod = @"GET";
    
    return request;
}

- (NSString *) dataQueryString:(NSDictionary *)data
                         error:(NSError * __autoreleasing *)error{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:data];
    
    mDict[@"cp.utag_main_v_id"] = self.visitorID;
    mDict[@"dom.domain"] = @"tealium.com";
    mDict[@"resolution"] = @"3x2";
    
    NSDictionary *dataForJson = @{@"data":[NSDictionary dictionaryWithDictionary:mDict]};
    
    NSMutableString *dataString = [NSMutableString stringWithFormat:@"data="];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataForJson
                                               options:0
                                                 error:error];
    
    NSString *dataContentString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dataString appendFormat:@"%@", dataContentString];
    
    return [NSString stringWithString:dataString];
    
}

- (NSString *) name {
    return NSLocalizedString(@"S2S", @"");
}

- (TEALDispatchNetworkServiceStatus) status{
    return self.privateStatus;
}

@end
