//
//  TEALSimpleNetworkManager.m
//  TealiumUtilities
//
//  Created by George Webster on 2/26/15.
//
//

#import "TEALSimpleNetworkManager.h"
#import "TEALError.h"

@interface TEALSimpleNetworkManager ()

@end

@implementation TEALSimpleNetworkManager


- (void) sendAsynchronousRequest:(NSURLRequest *)request
               completionHandler:(TEALURLResponseBlock)completionHandler {

    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {

        NSURLSession *session = [NSURLSession sharedSession];
        
        TEALURLTaskResponseBlock taskCompletion = ^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (completionHandler) {
                completionHandler(response, data, error);
            }
            
        };
        
        NSURLSessionTask *task = [session dataTaskWithRequest:request
                                            completionHandler:taskCompletion];
        [task resume];
        
    }
#ifdef TEAL_TARGET_IOS
    else {
        
        NSOperationQueue *targetQueue = self.responseQueue;
        
        if (!targetQueue) {
            targetQueue = [NSOperationQueue mainQueue];
        }
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:targetQueue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (completionHandler) {
                                       completionHandler(response, data, error);
                                   }
                               }];
    }
#endif
    
#ifdef TEAL_TARGET_TVOS
    else {
        NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Could not send async request.", @"")
                                  reason:NSLocalizedString(@"NSURLSession & NSURLConnection not supported", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Mobile Engineering - SimpleNetworkManager", @"")];
        if (completionHandler){
            completionHandler(nil, nil, error);
        }
    }
#endif
}

@end
