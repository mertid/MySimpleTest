//
//  TEALCollectDispatchManager.m
//  Tealium Mobile Library
//
//  Created by George Webster on 2/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALCollectNetworkService.h"

#import "TEALNetworkHelpers.h"
#import "TEALURLSessionManager.h"

#import "TEALDispatchConstants.h"
#import "TEALDispatch.h"

#import "TEALBlocks.h"

#import "TEALLogger.h"


@interface TEALCollectNetworkService ()

@property (weak, nonatomic) id<TEALCollectNetworkServiceConfiguration> configuration;
@property (nonatomic) TEALDispatchNetworkServiceStatus status;

@end

@implementation TEALCollectNetworkService

+ (instancetype) networkServiceWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration {
    return [[[self class] alloc] initWithConfiguration:configuration];
}


- (instancetype) initWithConfiguration:(id<TEALCollectNetworkServiceConfiguration>)configuration {
    
    self = [self init];
    
    if (self) {
        _configuration = configuration;
    }
    
    return self;
}

#pragma mark - TEALNETWORKSERVICE DELEGATES

- (TEALDispatchNetworkServiceStatus) status{
    return self.status;
}

- (void) setup {
    
}

- (void) sendDispatch:(TEALDispatch *)dispatch
           completion:(TEALDispatchBlock)completion {
    
    
    if (!self.configuration) {
        NSError *error = nil; // TODO: make error helper
        if (completion) {
            completion( TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }
    
    NSString *baseURLString = [self.configuration collectDispatchURLString];
    
    NSError *error = nil;
    
    NSString *payload    = [TEALNetworkHelpers urlParamStringFromDictionary:dispatch.payload];

    NSString *urlString = [baseURLString stringByAppendingFormat:@"&%@", payload];
    
    
    if (!urlString && completion) {
        completion(TEALDispatchStatusFailed, dispatch, error);
        return;
    }
    
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:urlString];
    
    if (!request) {
        completion( TEALDispatchStatusFailed, dispatch, nil );
        return;
    }
    
    TEALHTTPResponseBlock requestCompletion = ^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (completion) {

            TEALDispatchStatus status = (connectionError) ? TEALDispatchStatusFailed : TEALDispatchStatusSent;

            completion( status, dispatch, connectionError );
        }
    };
    
    [[self.configuration urlSessionManager] performRequest:request
                                            withCompletion:requestCompletion];

}

@end
