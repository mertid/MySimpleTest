//
//  TEALCollectDispatchManager.m
//  Tealium Mobile Library
//
//  Created by George Webster on 2/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALCollectDispatchService.h"
#import "TEALNetworkHelpers.h"
#import "TEALURLSessionManager.h"
#import "TEALDispatch.h"
#import "TEALBlocks.h"

@interface TEALCollectDispatchService ()

@property (nonatomic, weak) NSString *dispatchURLString;
@property (nonatomic, weak) TEALURLSessionManager *sessionManager;
@property (nonatomic) TEALDispatchNetworkServiceStatus privateStatus;

@end

@implementation TEALCollectDispatchService

#pragma mark - PUBLIC

- (instancetype) initWithDispatchURLString:(NSString *)dispatchURLString sessionManager:(TEALURLSessionManager *)sessionManager {
    self = [super init];
    if (self) {
        _dispatchURLString = dispatchURLString;
        _sessionManager = sessionManager;
    }
    return self;
}


- (NSString *) dispatchURLStringCopy {
    
    return  [self.dispatchURLString copy];
    
}

#pragma mark - PRIVATE

- (BOOL) isReady {
    
    if (!self.dispatchURLString || !self.sessionManager) {
        return NO;
    }
    
    return YES;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<TEALCollectDispatch Service dispatchURL:%@ status:%lu>", self.dispatchURLString, (unsigned long)[self status]];
}

#pragma mark - TEALNETWORKSERVICE DELEGATES


- (void) setup {
    
    // Any additional setup here
    
}

- (void) sendDispatch:(TEALDispatch *)dispatch
           completion:(TEALDispatchBlock)completion {
    
    
    if (![self isReady]) {
        NSError *error = nil; // TODO: make error helper
        if (completion) {
            completion( TEALDispatchStatusFailed, dispatch, error);
        }
        return;
    }
    
    NSString *baseURLString = self.dispatchURLString;
    
    NSError *error = nil;
    
    NSString *urlString = [TEALNetworkHelpers appendUrlParamString:baseURLString withDictionary:dispatch.payload];
    
    if (!urlString && completion) {
        completion(TEALDispatchStatusFailed, dispatch, error);
        return;
    }
    
    NSURLRequest *request = [TEALNetworkHelpers requestWithURLString:urlString];
    
    if (!request) {
        if (completion){
            completion( TEALDispatchStatusFailed, dispatch, nil );
        }
        return;
    }
    
    TEALHTTPResponseBlock requestCompletion = ^(NSHTTPURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (completion) {

            TEALDispatchStatus status = (connectionError) ? TEALDispatchStatusFailed : TEALDispatchStatusSent;

            completion( status, dispatch, connectionError );
        }
    };
    
    [self.sessionManager performRequest:request
                         withCompletion:requestCompletion];

}

- (NSString *) name {
    return NSLocalizedString(@"Collect", @"");
}

- (TEALDispatchNetworkServiceStatus) status{
    return self.privateStatus;
}

@end
