//
//  TEALCollectLegacyDispatchManager.m
//  Tealium Mobile Library
//
//  Created by Jason Koo on 10/29/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALCollectLegacyDispatchService.h"
#import "TEALNetworkHelpers.h"
#import "TEALURLSessionManager.h"
#import "TEALDispatch.h"
#import "TEALBlocks.h"
#import "TEALError.h"
#import "TEALDataSourceConstants.h"

@interface TEALCollectLegacyDispatchService ()

@property (nonatomic, weak) NSString *dispatchURLString;
@property (nonatomic, strong) NSString *visitorID;
@property (nonatomic, weak) TEALURLSessionManager *sessionManager;
@property (nonatomic) TEALDispatchNetworkServiceStatus status;


@end

@implementation TEALCollectLegacyDispatchService

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
    return [NSString stringWithFormat:@"<TEALCollectLegacyDispatch Service dispatchURL:%@ status:%lu>", self.dispatchURLString, (unsigned long)self.status];
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
    NSURL *url = [NSURL URLWithString:originURLString];
    
    // Create new request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    // Add VisitorID to header
    NSDictionary *headers = [self headerWithVisitorID:self.visitorID];
    if (![self updateRequest:request
             withHeadersFrom:headers
                       error:&error]){
        completion(TEALDispatchStatusFailed, dispatch, error);
        return;
    }
    
    // Add Payload
    NSDictionary *payload    = dispatch.payload;
    if (![self updateRequest:request withBody:payload error:&error]){
        
        completion( TEALDispatchStatusFailed, dispatch, error );
        return;
        
    }
    
    // For inspecting output call request
//    NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    
#warning Not reporting bad url destination
    
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

/*
 *  UNCOMMENT TO ENABLE ADDITIONAL header options
 
 */
//- (NSString*) urlString:(NSString*)urlString withAuthentificationFrom:(NSDictionary*)authentification{
//    
//    // Failure will return original urlString passed in.
//    
//    NSString *username = authentification[@"username"];
//    NSString *password = authentification[@"password"];
//    
//    if (!username || [username isEqualToString:@""]){
//        //        TEALIUMLOG(@"Remote API call %@ - username key found but missing value.", urlString);
//    } else if (!password || [password isEqualToString:@""]){
//        //        TEALIUMLOG(@"Remote API Call %@ - password key found but missing value.", urlString);
//    } else {
//        NSString *httpPrefix = [urlString substringToIndex:6];
//        NSString *httpsPrefix = [urlString substringToIndex:7];
//        NSString *urlStringstripped;
//        if ([httpPrefix isEqualToString:@"http://"]) urlStringstripped = [urlString substringFromIndex:6];
//        if ([httpsPrefix isEqualToString:@"https://"]) urlStringstripped = [urlString substringFromIndex:7];
//        if (!urlStringstripped || urlStringstripped.length == 0) {
//            
//#warning SOME ERROR HANDLING?
//            return nil;
//        }
//        NSString *newUrlString = [NSString stringWithFormat:@"https://%@:%@@%@", username, password, urlStringstripped];
//        if (newUrlString) return newUrlString;
//    }
//    
//    return urlString;
//}
//
//- (NSString*) urlString:(NSString*)urlString withParametersFrom:(NSDictionary*)parameters{
//    
//    // Failure will return original urlString passed in.
//    
//    NSString *newUrlString = nil;
//    
//    if ([parameters count] == 0) newUrlString = urlString;
//    else {
//        NSMutableString *suffixString = [NSMutableString stringWithFormat:@"?"];
//        
//        NSMutableArray *sortKeys = [NSMutableArray arrayWithArray:[parameters allKeys]];
//        [sortKeys sortUsingSelector:@selector(compare:)];
//        for (unsigned int i = 0; i < [sortKeys count]; i++){
//            id key = sortKeys[i];
//            id obj = parameters[key];
//            if ([obj isKindOfClass:[NSString class]]){
//                if (![suffixString isEqualToString:@"?"])[suffixString appendFormat:@"&"];
//                [suffixString appendFormat:@"%@=%@", key, obj];
//            }
//        }
//        if (suffixString) newUrlString = [urlString stringByAppendingString:suffixString];
//    }
//    return newUrlString;
//}
//

- (NSDictionary *) headerWithVisitorID:(NSString *)visitorID {
    
    NSDictionary *cookieProperties = @{
                                       NSHTTPCookieDomain:@"tealium.com",
                                       NSHTTPCookiePath:@"\\",
                                       NSHTTPCookieName:@"cp.utag_main_v_id",
                                       NSHTTPCookieValue:self.visitorID
                                       };
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSArray* cookieArray = [NSArray arrayWithObject:cookie];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    
    return headers;
    
}


- (BOOL) updateRequest:(NSMutableURLRequest*)request withHeadersFrom:(NSDictionary*)headers error:(NSError * __autoreleasing *)error{
    
    
    if (!headers){
        if (error){
            *error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                  description:NSLocalizedString(@"NSURL Request failed.", @"")
                                       reason:NSLocalizedString(@"No headers passed into updateRequest:withHeadersFrom:error: call.", @"")
                                   suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
        }
        return FALSE;
    }
    if (!request){
        if (error){
            *error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                  description:NSLocalizedString(@"NSURL Request failed.", @"")
                                       reason:NSLocalizedString(@"No request passed into updateRequest:withHeadersFrom:error: call.", @"")
                                   suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
        }
        return FALSE;
    }
    
    // Auto bypass anything not acceptable
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]){
            [request setValue:obj forHTTPHeaderField:key];
        }
    }];
    
    return TRUE;
}


- (BOOL) updateRequest:(NSMutableURLRequest*)request withBody:(NSDictionary *)body error:(NSError * __autoreleasing *)error{
    
    // Return false if updated or original request not passable
    
    if (!body){
        if (error){
            *error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                 description:NSLocalizedString(@"NSURL Request failed.", @"")
                                      reason:NSLocalizedString(@"No body data passed into updateRequest:withBody:error: call.", @"")
                                  suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
        }
        return FALSE;
    }
    if (!request){
        if (error){
            *error = [TEALError errorWithCode:TEALErrorCodeNoContent
                                  description:NSLocalizedString(@"NSURL Request failed.", @"")
                                       reason:NSLocalizedString(@"No request passed into request:withBody:error: call.", @"")
                                   suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
        }
        return FALSE;
    }
    
    // HTTP Body
    // payload data will go into key "data"
    NSString *event = body[TEALDataSourceKey_CallType];
    if (!event) event = TEALDataSourceValue_Link;
    
    NSString *post_time = body[TEALDataSourceKey_TimestampUnix];
    if (!post_time) post_time = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]];
    
    NSDictionary *httpBody = @{
                               @"loader.cfg":@{},
                               @"data":body,
                               @"event":event,
                               @"post_time":post_time
                               };
    
    NSData *jsonData = nil;
    jsonData = [NSJSONSerialization dataWithJSONObject:httpBody
                                               options:0
                                                 error:error];

    if (jsonData){
        
        [request setHTTPBody:jsonData];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        return  TRUE;
    }
    
    return FALSE;
    
}


- (NSString *) name {
    return NSLocalizedString(@"CollectLegacy", @"");
}

- (TEALDispatchNetworkServiceStatus) status{
    return self.status;
}

@end
