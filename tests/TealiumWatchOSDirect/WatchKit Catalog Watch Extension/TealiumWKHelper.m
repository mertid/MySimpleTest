//
//  TealiumHelper.m
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TealiumWKHelper.h"

@import WatchConnectivity;

// Tealium supports multiple instances, but if only using one, can use a constant
NSString * const TEALIUM_INSTANCE_ID = @"1";

@implementation TealiumWKHelper

static TealiumWKHelper * _sharedInstance;

#pragma mark - PUBLIC

+ (void) startTracking {
    
    // Edit below for supporting more than one instance
    if ([TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID]) {
        return;
    }
    
    TEALWKExtensionConfiguration *config = [TEALWKExtensionConfiguration configuration];
    
    [TEALWKExtension newInstanceForKey:TEALIUM_INSTANCE_ID configuration:config];
    
}

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackEventWithTitle:title dataSources:data];
}

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackViewWithTitle:title dataSources:data];
}

#pragma mark - PRIVATE

+ (instancetype) sharedInstance {
    
    if (!_sharedInstance){
        _sharedInstance = [[TealiumWKHelper alloc] init];
    }
    
    return _sharedInstance;
}



#pragma mark - SAMPLE

// Implement a public method like this if providing a disable tracking option.
+ (void) stopTracking{
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] destroy];
    
}

#pragma mark - R&D

+ (NSString *) stringValueOfObject:(id)object {
    
    if (![object isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@", object];
    }
    return [(NSString *)object copy];
    
}

+ (NSString *) percentEscapeURLParameter:(NSString *)string {
    
    if (!string) {
        return nil;
    }
    
    
    return [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    
}

+ (NSString *) urlParamStringFromDictionary:(NSDictionary *)data {
    
    NSMutableArray *paramArray = [NSMutableArray array];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *stringValue = [self stringValueOfObject:obj];
        NSString *escapedValue = [self percentEscapeURLParameter:stringValue];
        NSString *paramStr = [NSString stringWithFormat:@"%@=%@", key, escapedValue];
        [paramArray addObject:paramStr];
    }];
    
    return [paramArray componentsJoinedByString:@"&"];
}

+ (NSString *) appendUrlParamString:(NSString *)urlString withDictionary:(NSDictionary *)data {
    
    NSString *stringToAppend = [self urlParamStringFromDictionary:data];
    
    if (![urlString containsString:@"?"]){
        urlString = [urlString stringByAppendingString:@"?"];
    }
    
    return [urlString stringByAppendingFormat:@"&%@", stringToAppend];
}

+ (void) directURLCallTestWithArguments:(NSDictionary *)arguments {
    
    //    NSString *baseURLString = [NSString stringWithFormat:@"http://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=demo&watchOSDirectTestKey=watchOSDirectTestValue"];
    

    NSString *baseURLString = [NSString stringWithFormat:@"http://requestb.in/s1a15ts1"];
    
    NSString *urlString = [TealiumWKHelper appendUrlParamString:baseURLString withDictionary:arguments];

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:[TealiumWKHelper sharedInstance]
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
    }];
    
    [task resume];
    
    
}

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"%s error:%@", __FUNCTION__, error);
}

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"%s session:%@", __FUNCTION__, session);
}

- (void) URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    NSLog(@"%s ", __FUNCTION__);
    
}

@end
