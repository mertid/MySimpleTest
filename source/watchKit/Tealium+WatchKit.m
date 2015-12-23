//
//  Tealium+WatchKit.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/11/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "Tealium+WatchKit.h"
#import "TEALDataSourceConstants.h"
#import "TEALError.h"
#import "TEALWKConstants.h"

typedef void (^tealiumEndBGTask)();

@implementation Tealium (WatchKit)

+ (BOOL) instanceAvailableForMessage:(NSDictionary<NSString *, id> *)message {
    
    NSDictionary *tealiumMessage = message[TEALWKCommandTrackKey];
    
    NSString *targetInstanceID = tealiumMessage[TEALWKCommandTrackArgumentInstanceIDKey];
    
    Tealium *instance = [Tealium instanceForKey:targetInstanceID];
    
    if ( instance){
        return TRUE;
    }
    
    return FALSE;
}

#pragma mark - WC SESSION DELEGATE

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    [self session:session didReceiveMessage:message replyHandler:nil];
    
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
    NSDictionary *tealiumPayload = message[TEALWKCommandTrackKey];
    
    if (!tealiumPayload){
        replyHandler(@{TEALWKCommandResponseKey: @"Session message did not contain a message for Tealium processing.",
                       @"message":message});
        return;
    }
    
    NSError *error = nil;
    
    NSDictionary *finalPaylod = [self finalPayloadFromRawPayload:tealiumPayload];
    
    [self processTrackCallFromPayload:finalPaylod error:error];
    
    // Create background processing block with end callback
    tealiumEndBGTask endBlock = [self endBlock];
    
    // Re-assign the "reply" block to include a call to "endBlock" after "reply" is called.
    replyHandler = ^(NSDictionary *replyInfo) {
        replyHandler(replyInfo);
        
        endBlock();
    };
    
    // Return a response to the origin watchKit call
    if (error){
        replyHandler(@{
                       TEALWKCommandResponseKey: @"Tealium extension track call encountered an error",
                       @"error":error,
                       @"message":message
                       });
    } else {
        replyHandler(@{TEALWKCommandResponseKey : @"Tealium extension track call was received and successfully processed.",
                   @"message":message});
    }
}

- (NSDictionary *) finalPayloadFromRawPayload:(NSDictionary *)payload {

    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    mDict[TEALDataSourceKey_Platform] = TEALDataSourceValue_WatchOS;
    mDict[TEALDataSourceKey_Origin] = TEALDataSourceValue_Wearable;
    
    [mDict addEntriesFromDictionary:payload];

    return [NSDictionary dictionaryWithDictionary:mDict];
    
}


- (tealiumEndBGTask) endBlock {
    
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

- (void) processTrackCallFromPayload:(NSDictionary *)payload error:(NSError __autoreleasing *)error{
    
    // Only process if payload available
    if (!payload) {
        error = [TEALError errorWithCode:TEALErrorCodeNoContent
                             description:NSLocalizedString(@"WatchKit call failed.", @"")
                                  reason:NSLocalizedString(@"No payload for Tealium processing recieved.", @"")
                              suggestion:NSLocalizedString(@"Check origin call from WatchKit Extension app.", @"")];
        return;
    };
    if (![payload isKindOfClass:[NSDictionary class]]) {
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"WatchKit call failed.", @"")
                                  reason:NSLocalizedString(@"Payload for Tealium processing not of type NSDictionary.", @"")
                              suggestion:NSLocalizedString(@"Check origin call from WatchKit Extension app.", @"")];
        return;
    }
    
    NSString *title = payload[TEALWKCommandTrackArgumentTitleKey];
    
    if (!title){
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"WatchKit call failed.", @"")
                                  reason:NSLocalizedString(@"Payload for Tealium processing is missing a title argument.", @"")
                              suggestion:NSLocalizedString(@"Check origin call from WatchKit Extension app.", @"")];
        return;
    }
    
    NSString *type = payload[TEALWKCommandTrackArgumentTypeKey];
    
    if (!type){
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"WatchKit call failed.", @"")
                                  reason:NSLocalizedString(@"Payload for Tealium processing is missing a call type argument.", @"")
                              suggestion:NSLocalizedString(@"Check origin call from WatchKit Extension app.", @"")];
        return;
    }
    
    NSDictionary *dataSources = payload[TEALWKCommandTrackArgumentCustomDataKey];
    
    if ([type isEqualToString:TEALWKCommandTrackValueView]){
        
        [self trackViewWithTitle:title dataSources:dataSources];

    } else {
    
        [self trackEventWithTitle:title dataSources:dataSources];

    }
    
}


@end
