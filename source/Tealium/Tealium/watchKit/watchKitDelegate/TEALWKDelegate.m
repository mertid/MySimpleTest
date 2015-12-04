//
//  TEALWKDelegate.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKDelegate.h"
#import "TEALWKConstants.h"

typedef void (^tealiumEndBGTask)();

@implementation TEALWKDelegate

#pragma mark - WC SESSION DELEGATE

+ (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    [self session:session didReceiveMessage:message replyHandler:nil];
    
}

+ (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
    // Only 2 commands from the Watch are currently supported - target methods will bail early if payload argument is empty
    [self processEventCallFromPayload:message[TEALWKCommandTrackEventKey]];
    [self processViewCallFromPayload:message[TEALWKCommandTrackViewKey]];
    
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

+ (void) processEventCallFromPayload:(NSDictionary *)payload {
    
    // Only process if payload available
    if (!payload) { return; };
    if (![payload isKindOfClass:[NSDictionary class]]) { return; }
    
    NSString *instanceID = payload[TEALWKCommandTrackArgumentInstanceIDKey];
    NSString *title = payload[TEALWKCommandTrackArgumentTitleKey];
    NSDictionary *dataSources = payload[TEALWKCommandTrackArgumentCustomDataKey];
    
    [[Tealium instanceForKey:instanceID] trackEventWithTitle:title dataSources:dataSources];
    
}

+ (void) processViewCallFromPayload:(NSDictionary *)payload {
    
    // Only process if payload available
    if (!payload) { return; };
    if (![payload isKindOfClass:[NSDictionary class]]) { return; }
    
    NSString *instanceID = payload[TEALWKCommandTrackArgumentInstanceIDKey];
    NSString *title = payload[TEALWKCommandTrackArgumentTitleKey];
    NSDictionary *dataSources = payload[TEALWKCommandTrackArgumentCustomDataKey];
    
    [[Tealium instanceForKey:instanceID] trackViewWithTitle:title dataSources:dataSources];
    
}


@end
