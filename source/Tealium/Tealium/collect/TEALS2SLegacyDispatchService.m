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
@property (nonatomic) TEALDispatchNetworkServiceStatus status;


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

- (BOOL) isReady {
    
    if (!self.dispatchURLString || !self.sessionManager) {
        return NO;
    }
    
    return YES;
}

#pragma mark - PRIVATE

- (NSString *) description {
    return [NSString stringWithFormat:@"<TEALS2SLegacyDispatchService dispatchURL:%@ status:%lu>", self.dispatchURLString, (unsigned long)self.status];
}

#pragma mark - TEALNETWORKSERVICE DELEGATES


- (void) setup {
    
    // Any additional work here

}

- (void) sendDispatch:(TEALDispatch *)dispatch
           completion:(TEALDispatchBlock)completion {
    
    NSError *error = nil;

    if (![self isReady]) {
        // TODO: add error details
        if (completion) {
            completion( TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }

    // Set HTTP Config
    NSString *originURLString = self.dispatchURLString;
    
    NSString *dataQueryString = [self dataQueryString:dispatch.payload error:&error];
    
    if (error != nil) {
        if (completion) {
            completion( TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }
    
    NSString *encodedDataQueryString = [dataQueryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    
    NSString *fullURLString = [NSString stringWithFormat:@"%@%@", originURLString, encodedDataQueryString];
    
//    NSString *encodedURLString = [fullURLString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    
    NSURL *url = [NSURL URLWithString:fullURLString];
    
    // Create new request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPShouldHandleCookies:YES];
    
    [self.sessionManager performRequest:request
                         withCompletion:^(NSHTTPURLResponse *response,
                                          NSData *data,
                                          NSError *connectionError) {
                             
         if (completion) {
             
             TEALDispatchStatus status = (connectionError) ? TEALDispatchStatusFailed : TEALDispatchStatusSent;
             
             completion( status, dispatch, connectionError );
         }
         
     }];

}

- (NSString *) dataQueryString:(NSDictionary *)data error:(NSError * __autoreleasing *)error{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:data];
    
    mDict[@"cp.utag_main_v_id"] = self.visitorID;
    mDict[@"dom.domain"] = @"tealium.com";
//    mDict[@"dom.pathname"] = @"/test";
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
    return self.status;
}

@end
