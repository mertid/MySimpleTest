//
//  TEALWKDelegate.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TEALWKDelegate.h"
#import "TEALWKConstants.h"
#import "TEALError.h"

typedef void (^tealiumEndBGTask)();

@implementation TEALWKDelegate

#pragma mark - WC SESSION DELEGATE

+ (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    [self session:session didReceiveMessage:message replyHandler:nil];
    
}

+ (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
    [self processTrackCallFromPayload:message[TEALWKCommandTrackKey] reply:replyHandler];
    
    // Create background processing block with end callback
    tealiumEndBGTask endBlock = [self endBlock];

    // Re-assign the "reply" block to include a call to "endBlock" after "reply" is called.
    replyHandler = ^(NSDictionary *replyInfo) {
        replyHandler(replyInfo);
        
        endBlock();
    };
    
    // Sends a confirmation message to the WatchKit app extension that the input result was received.
    replyHandler(@{@"Confirmation" : @"Tealium extension call was received."});
}

+ (tealiumEndBGTask) endBlock {
    
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
    
    // The "endBlock" ensures that the background task is ended and the identifier is reset.
    dispatch_block_t endBlock = ^ {
        if (identifier != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:identifier];
        }
        identifier = UIBackgroundTaskInvalid;
    };
    
    identifier = [application beginBackgroundTaskWithExpirationHandler:endBlock];
    
    return endBlock;
}

+ (void) processTrackCallFromPayload:(NSDictionary *)payload reply:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
    // Little dense because we're using runtime methods to check and run
    // Tealium track calls so we can avoid importing them from this module
    
    // Bail out checks
    NSError *error = nil;
    
    if (!payload) {
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Track call failed.", @"")
                                  reason:NSLocalizedString(@"No arguments for call passed.", @"")
                              suggestion:NSLocalizedString(@"Check origin track call in Extension.", @"")];
    }
    if (!error &&
        ![payload isKindOfClass:[NSDictionary class]]) {
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Track call failed.", @"")
                                  reason:NSLocalizedString(@"Arguments not passed in dictionary form.", @"")
                              suggestion:NSLocalizedString(@"Check data format of origin track call in Extension.", @"")];
    }
    
    // Call Tealium using runtime methods so we don't have to include / embed
    Class Tealium = NSClassFromString(@"Tealium");
    if (!Tealium){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Track call failed.", @"")
                                  reason:NSLocalizedString(@"Tealium Library not available.", @"")
                              suggestion:NSLocalizedString(@"Check that the Tealium framework has been added.", @"")];
    }
    
    if (error){
        if (replyHandler){
            replyHandler(@{@"Error":error});
        }
        return;
    }
    
    // Get target Tealium instance
    NSString *instanceID = payload[TEALWKCommandTrackArgumentInstanceIDKey];
    id tealiumInstance;
    
    SEL aSelector = NSSelectorFromString(@"instanceForKey:");
    IMP impInstance = [Tealium methodForSelector:aSelector];
    NSString * (*funcInstance)(id, SEL, NSString *key) = (void *)impInstance; // add arguments after SEL if needed
    tealiumInstance = funcInstance(Tealium, aSelector, instanceID); // add arguments after selectorCarrierName if needed
    
    if (!tealiumInstance){
        return;
    }
    
    // Extract arguments
    NSString *title = payload[TEALWKCommandTrackArgumentTitleKey];
    NSDictionary *dataSources = payload[TEALWKCommandTrackArgumentCustomDataKey];
    NSString *type = payload[TEALWKCommandTrackTypeKey];
    
    // Tealium Track call using runtime
    id call;
    SEL trackSelector;
    
    if ([type isEqualToString:TEALWKCommandTrackValueView]){
        
        trackSelector = NSSelectorFromString(@"trackViewWithTitle:dataSources:");

        
    } else {
        
        trackSelector = NSSelectorFromString(@"trackEventWithTitle:dataSources:");

    }
    
    IMP impTrack = [tealiumInstance methodForSelector:trackSelector];
    NSString * (*funcTrack)(id, SEL, NSString *title, NSDictionary *data) = (void *)impTrack; // add arguments after SEL if needed
    call = funcTrack(tealiumInstance, trackSelector, title, dataSources); // add arguments after selectorCarrierName if needed
    
}

@end
